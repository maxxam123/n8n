include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/ec2"
}

dependency "vpc" {
  config_path = "../../vpc"
}

inputs = {
  subnet_id = dependency.vpc.outputs.subnet_id
  instance_type = "t3.micro"
  ami = "ami-0d03cbb826412c6b0f"
}
