include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
  vpc_directory = {
    "production" = {
      cidr_block = "10.0.0.0/16"
      team       = "devops"
      critical   = true
    }
    "staging" = {
      cidr_block = "10.1.0.0/16"
      team       = "qa"
      critical   = false
    }
    "development" = {
      cidr_block = "10.2.0.0/16"
      team       = "engineering"
      critical   = false
    }
  }
}
