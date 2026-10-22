# _global/identity-center/terragrunt.hcl

include "root" {
  path = find_in_parent_folders()
}

locals {
  common_identity = read_terragrunt_config(find_in_parent_folders("_envcommon/identity-center.hcl"))
}

terraform {
  source = "git::git@github.com:your-github-username/infrastructure-modules.git//identity-center?ref=v1.3.0"
}

# Pass the clean groups configuration directly down to your terraform resource blocks
inputs = {
  groups              = local.common_identity.inputs.identity_groups
  account_assignments = local.common_identity.inputs.group_account_assignments
}
