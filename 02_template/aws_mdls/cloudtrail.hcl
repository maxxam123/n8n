erraform {
  source = "git::git@github.com:your-org/terraform-modules.git//network/vpc?ref=vTAG"
}

inputs = {
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = {
    ComponentClass = "network"
    ManagedBy      = "terragrunt"
  }
}
