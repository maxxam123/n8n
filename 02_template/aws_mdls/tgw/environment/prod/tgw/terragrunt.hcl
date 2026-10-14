include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = git@github.com//maxxam123/tgw-aws-modules.git?ref=v2.10.0"
}


locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

inputs = {
  name        = "central-tgw-${local.env_vars.environment}"
  description = "Centralized Transit Gateway routing for Dev, Staging, and Prod"

  amazon_side_asn = 64512
  
  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true

  share_tgw = true
  
  ram_allow_external_principals = true
  ram_principals = [
    "arn:aws:organizations::111122223333:organization/o-exampleorgid"
  ]

  tags = {
    Layer = "Core-Networking"
  }
}
