# _global/security/guardduty/terragrunt.hcl

# 1. Inherit global states and remote backend configurations from the root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit common threat detection parameters from our baseline template
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/security/guardduty.hcl"
}

# 3. Reference your centralized security storage bucket stack
dependency "audit_bucket" {
  config_path = "../../security/BUCKET_NAME"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURATION INJECTIONS & OVERRIDES
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  # Optionally override parameters for specific account instances if doing multi-account structures
  # (e.g., passing a master guardduty member account configuration)
  
  tags = {
    SecurityClassification = "restricted-monitoring"
  }
}
