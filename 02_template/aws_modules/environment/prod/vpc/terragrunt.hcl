include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
  vpc_directory = {
    "production-01" = {
      cidr_block = "10.10.0.0/16"
      team       = "devops-01"
      critical   = true
    }
    "production-02" = {
      cidr_block = "10.11.0.0/16"
      team       = "devops-01"
      critical   = false
    }
    "production-03" = {
      cidr_block = "10.12.0.0/16"
      team       = "devops-01"
      critical   = false
    }
  }
}
