include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../../_envcommon/compute/s3.hcl"
  expose = true
}

inputs = {
  tags = {
    Environment = "ENV"
    ManagedBy   = "Terragrunt"
  }
}
