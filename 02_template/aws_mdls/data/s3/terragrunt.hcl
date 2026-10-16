include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/storage/s3.hcl"
}

inputs = {
  bucket = "BUCKET_NAME"

  lifecycle_rule = [
    {
      id      = "LIVECYCLE_ID"
      enabled = true
      expiration = {
        days = 365
      }
    }
  ]

  tags = {
    Environment = "staging"
    DataScope   = "application-logs"
  }
}
