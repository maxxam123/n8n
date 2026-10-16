terraform {
  source = "git@github.com/maxxam123/mod ... vTAG"
}

inputs = {
  name = "VPC_NAME"

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  allocate_public_ip_to_database_subnet  = false

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = {
    InfrastructureLayer = "network-backbone"
    ProvisionedBy       = "Terragrunt"
  }
}

