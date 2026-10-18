include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/iam-group-binding.hcl"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment
}

dependency "roles" {
  config_path = "../../IAM_ROLE"
}

# bastion_admins = SERVICE
# PERSONS = "alice", "bob"
inputs = {
  # Group permissions mapped precisely to different user buckets
  groups_matrix = {
    SERVICE = {
      group_name        = "SERVICE-${local.env}-group"
      users             = [PERSONS] # Only Alice & Bob manage bastions
      allowed_role_arns = [dependency.roles.outputs.role_arns["SERVICE"]]
    }
  }
}
