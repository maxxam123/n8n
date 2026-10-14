include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com:maxxam123/infra-modules.git//ec2$ref=ec2-vTAG"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  subnet_id = dependency.vpc.outputs.subnet_id
  instance_type = "INSTANCE"
  ami = "AMI"    
}
