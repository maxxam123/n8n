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
  config_path = "../iam-roles"
}

inputs = {
  # Group permissions mapped precisely to different user buckets
  groups_matrix = {
    bastion_admins = {
      group_name        = "bastion-admins-${local.env}-group"
      users             = ["alice", "bob"] # Only Alice & Bob manage bastions
      allowed_role_arns = [dependency.roles.outputs.role_arns["bastion_admin"]]
    }
    ecr_developers = {
      group_name        = "ecr-developers-${local.env}-group"
      users             = ["bob", "charlie"] # Bob & Charlie manage ECR containers
      allowed_role_arns = [dependency.roles.outputs.role_arns["ecr_developer"]]
    }
    auditors = {
      group_name        = "auditors-${local.env}-group"
      users             = ["david", "emily"] # David & Emily have pure read-only visibility
      allowed_role_arns = [dependency.roles.outputs.role_arns["read_only"]]
    }
  }
}

