include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/iam-role.hcl"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment
}

inputs = {
  # Define your 3 different execution scopes as a matrix map
  roles_matrix = {
    bastion_admin = {
      role_name   = "bastion-admin-role-${local.env}"
      policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
    }
    ecr_developer = {
      role_name   = "ecr-developer-role-${local.env}"
      policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
    }
    read_only = {
      role_name   = "read-only-role-${local.env}"
      policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  }
}

