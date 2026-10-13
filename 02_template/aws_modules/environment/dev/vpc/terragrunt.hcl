include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
  vpc_directory = {
    "development-01" = {
      cidr_block = "10.0.0.0/16"
      team       = "engineering-01"
      critical   = true
    }
    "development-02" = {
      cidr_block = "10.1.0.0/16"
      team       = "engineering-02"
      critical   = false
    }
    "development-03" = {
      cidr_block = "10.2.0.0/16"
      team       = "engineering-03"
      critical   = false
    }
  }
}
