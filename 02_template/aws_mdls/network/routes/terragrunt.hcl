include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/routes.hcl"
  expose = true
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "firewall" {
  config_path = "../../network-firewall"
}

dependency "tgw" {
  config_path = "../../tgw"
}

inputs = {
  prefix             = "corp"
  environment        = "dev"
  availability_zones = ["eu-central-1a", "eu-central-1b"]

  vpc_id                     = dependency.vpc.outputs.vpc_id
  tgw_id                     = dependency.tgw.outputs.core_tgw_id
  private_subnet_ids_by_az   = dependency.vpc.outputs.private_subnet_ids_map         # Output must return: map of AZ -> Subnet ID
  fw_endpoints_by_az          = dependency.firewall.outputs.endpoint_map_by_az        # Output must return: map of AZ -> VPCE ID
  vpc_endpoint_eni_ids_by_az  = dependency.vpc.outputs.interface_endpoints_eni_map    # Output must return: map of AZ -> ENI ID

  global_tags = merge(
    include.envcommon.inputs.global_tags,
    {
      Environment = "dev"
      CostCenter  = "CC-7789-DEV"
    }
  )
}
