include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/network/vpc.hcl"
}

inputs = {
  name = "VPC_NAME"
  cidr = "VPC_CIDR"

  # Define specific availability zones for this deployment
  azs = ["AZS_01", "AZS_02"]

  # Unique environment subnet distribution blocks
  public_subnets   = ["SUBNET_PUBLIC_01", "SUBNET_PUBLIC_02"]
  private_subnets  = ["SUBNET_PRIVATE_01", "SUBNET_PRIVATE_02"]

  vpc_tags = {
    Environment = "ENV_TAG"
    CostCenter  = "COST_CENTER"
  }
}

