include "root" {
  path = find_in_parent_folders()
}

terraform {
    source = "git@github.com:maxxam123/infra-modules.git//tgwa$ref=tgwa-vTAG"
}

dependency "tgw" {
  path = "../../../TENENT/network/tgw"
  
  mock_outputs = {
    ec2_transit_gateway_id = "tgw-mock-0123456789abcdef0"
  }
}

dependency "vpc" {
  path = "../vpc"
  
  mock_outputs = {
    vpc_id             = "vpc-mock-987654321"
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b", "subnet-mock-c"]
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl")).locals
}

inputs = {
  name = "tgw-attachment-${local.env_vars.environment}"

  transit_gateway_id = dependency.tgw.outputs.ec2_transit_gateway_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subnet_ids

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Component = "Network-Hub-Attachment"
  }
}
