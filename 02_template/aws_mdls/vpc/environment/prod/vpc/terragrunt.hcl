include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
      vpc_cidr = "10.1.0.0/16"
      subnet_cidr = "10.1.0.0/24"
      vpc_tags = {
        "Name" = "Test-01"
      }
      subnet_tags = {
        "Name" = "Test-01"
}
