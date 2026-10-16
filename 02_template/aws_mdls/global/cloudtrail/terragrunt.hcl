# _global/security/cloudtrail/terragrunt.hcl

# 1. Inherit global states and remote backend infrastructure setups
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit common audit parameters from our common directory template
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/security/cloudtrail.hcl"
}

# 3. Reference your centralized security storage bucket stack
dependency "audit_bucket" {
  config_path = "../../securityBUCKET_NAME"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT OVERRIDES
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  # Dynamically feed the secure bucket identifier straight from storage outputs
  s3_bucket_name = dependency.audit_bucket.outputs.s3_bucket_id

  tags = {
    SecurityClassification = "restricted-compliance"
  }
}
