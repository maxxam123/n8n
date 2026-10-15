include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com//maxxam123/module-repo?version=TAG"
}

inputs = {
  bucket        = "BUCKET"
  acl           = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    enabled = true
  }
}
