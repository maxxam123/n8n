terraform {
  source = "git@github.com//maxxam123/mod  .... vTAG"
}

inputs = {
  dns_support                                    = true
  ipv6_support                                   = false
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    InfrastructureLayer = "network-attachment"
    ProvisionedBy       = "Terragrunt"
  }
}
