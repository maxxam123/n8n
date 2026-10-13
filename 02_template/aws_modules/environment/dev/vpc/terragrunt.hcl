include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
  vpc_cidr = "172.20.0.0/16"
  subnet_cidr = "172.20.0.0/24"
  vpc_tags = {
    "Name" = "dev-vpc"
  }
  subnet_tags = {
    "Name" = "dev-subnet"
  }
}
