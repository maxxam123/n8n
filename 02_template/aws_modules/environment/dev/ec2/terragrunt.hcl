include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../module/vpc"
}

inputs = {
  subnet_id = ""
  instance_type = "t3.micro"
  ami = "ami-0d03cbb826412c6b0f"
}
