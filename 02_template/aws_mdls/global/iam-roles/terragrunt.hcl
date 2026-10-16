# _global/account/iam-roles-01/terragrunt.hcl

# 1. Inherit global backend states and unified provider profiles from the root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit corporate safety parameters and module source from our _envcommon template
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/account/iam-roles.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# ROLE LOGIC & POLICY ATTACHMENTS
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  role_name = "ROLE_NAME"

  # Define who or what is allowed to assume this IAM role 
  # (e.g., AWS SSO / IAM Identity Center instances or a master management account)
  trusted_role_arns = [
    "arn:aws:iam::111122223333:root" # Swap with your central Identity/Management Account ID
  ]

  # Attach AWS Managed Policies to this execution role profile
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSSupportAccess"
  ]

  tags = {
    SecurityTier = "tier-3-developer"
    Auditable    = "true"
  }
}
