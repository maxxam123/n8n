include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:maxxam123/infra-modules.git//eks$ref=eks-v0.0.1"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  subnet_id = dependency.vpc.outputs.subnet_id
  instance_type = "t3.micro"
  ami = "ami-0df0df0adf"    
}
