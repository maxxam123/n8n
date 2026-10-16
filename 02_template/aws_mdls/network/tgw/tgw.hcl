terraform {
  source = "git@github.com//maxxam123/mod .... vTAG"
}

inputs = {
  name        = "TGW_NAME"
  description = "Central Transit Gateway for cross-VPC and hybrid cloud routing"

  amazon_side_asn                  = 64512
  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true
  enable_dns_support               = "enable"
  enable_vpn_ecmp_support          = "enable"

  # Cross-Account Organization Sharing (AWS RAM)
  share_tgw                               = true
  ram_allow_external_principals           = false

  tags = {
    InfrastructureLayer = "transit-backbone"
    ProvisionedBy       = "Terragrunt"
  }
}
