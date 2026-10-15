include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../env.hcl"
  expose = true
}

terraform {
  source = "git::git@github.com:your-org/terraform-aws-iam-modules.git//modules/iam-roles?ref=v1.0.0"
}

inputs = {
  role_name        = "global-shared-execution-role"
  environment_name = include.env.locals.env # Evaluates to "global"
  
  trusted_role_services = [
    "://amazonaws.com",
    "://amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess"
  ]
}
