terraform {
  source = "git@github.com//maxxam123/mod ..... vTAG"
}


inputs = {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
    }
  }

  lifecycle_rule = [
    {
      id      = "archive-old-objects"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"s
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_transition = [
        {
          days          = 14
          storage_class = "GLACIER"
        }
      ]
    }
  ]

  tags = {
    InfrastructureLayer = "storage-tier"
    ProvisionedBy       = "Terragrunt"
  }
}
