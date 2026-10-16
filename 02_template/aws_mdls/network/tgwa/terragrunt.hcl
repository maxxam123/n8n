include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/network/tgwa.hcl"
}

dependency "tgw" {
  config_path = "../TGW_NAME"
}

dependency "vpc" {
  config_path = "../VPC_NAME"
}

inputs = {
  name = "TGWA_NAME"

  transit_gateway_id = dependency.tgw.outputs.ec2_transit_gateway_id
  vpc_id             = dependency.vpc.outputs.vpc_id
  subnet_ids         = dependency.vpc.outputs.private_subnets

  tags = {
    Environment = "staging"
  }
}
