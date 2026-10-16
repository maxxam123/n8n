include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=vTAG"
}

inputs = {
  name = "VPC_NAME"
  cidr = "VPC_CIDR"

  azs = ["AZS_01", "AZS_02", "AZS_03"]

  public_subnets  = ["SUBNET_PUBLIC_01", "SUBNET_PUBLIC_02", "SUBNET_PUBLIC_03"]
  private_subnets  = ["SUBNET_PRIVATE_01", "SUBNET_PRIVATE_02", "SUBNET_PRIVATE_03"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  allocate_public_ip_to_database_subnet  = false

  vpc_tags = {
    Layer = "network-backbone"
  }
