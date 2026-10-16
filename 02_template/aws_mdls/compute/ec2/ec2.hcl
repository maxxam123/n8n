locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env      = local.env_vars.locals.environment
}

terraform {
  source = "git@github.com//maxxam123/mod ..... vTAG"
}

inputs = {
  bucket        = "my-company-${local.env}-data-bucket" # COMPANY
  force_destroy = false
  
  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
