# GCP Storage Permissions

Prerequisites...

Within a workspace, create two groups:
- ravenclaw
- slytherin

Create two users and stick one in each group.

The templates in <terraform/house-buckets> will then create a bucket for each house
and set up the two groups with permissions to:
- read all objects
- write to only their house bucket

This tests out in the console using cloud-shell.

Next up, os-login.
