#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  houses = [
    "ravenclaw",
    "slytherin",
  ]
  location = "US"
  force_destroy = true
  public_access_prevention = "enforced"
}

data "google_project" "project" {}

resource "google_storage_bucket" "house-bucket" {
  for_each                    = toset(local.houses)
  name                        = "${each.value}-house-bucket"
  project                     = data.google_project.project.project_id
  location                    = local.location
  force_destroy               = local.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = local.public_access_prevention
}

###########################
# IAM - Resource-specific
###########################

resource "google_storage_bucket_iam_binding" "binding" {
  for_each                    = toset(local.houses)
  bucket = "${each.value}-house-bucket"
  role = "roles/storage.admin"
  members = [
    "group:${each.value}@${var.domain}",
  ]
  depends_on = [ google_storage_bucket.house-bucket ]
}


##########################
# IAM - Project-specific
##########################

resource "google_project_iam_member" "project_service_account_user" {
  for_each                    = toset(local.houses)
  project = data.google_project.project.project_id
  role    = "roles/iam.serviceAccountUser"

  member = "group:${each.value}@${var.domain}"
}

resource "google_project_iam_member" "project_storage_admin" {
  for_each                    = toset(local.houses)
  project = data.google_project.project.project_id
  role    = "roles/storage.objectViewer"

  member = "group:${each.value}@${var.domain}"
}
 
resource "google_project_iam_member" "managed_project_oslogin_admin_user" {
  for_each                    = toset(local.houses)
  project = data.google_project.project.project_id
  role    = "roles/compute.osAdminLogin"

  member = "group:${each.value}@${var.domain}"
}
 
resource "google_iap_tunnel_iam_member" "managed_project_iap_tunnel_user" {
  for_each                    = toset(local.houses)
  project = data.google_project.project.project_id
  role = "roles/iap.tunnelResourceAccessor"

  member = "group:${each.value}@${var.domain}"
}
  
##################
# IAM - Org-wide
##################
# resource "google_organization_iam_member" "org_external_oslogin_user" {
#   count = length(var.editors)
#   org_id = var.org_id
#   role    = "roles/compute.osLoginExternalUser"
# 
#   member = var.editors[count.index]
# }
