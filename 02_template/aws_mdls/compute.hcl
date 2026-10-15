terraform {
  source = "git::git@github.com:your-org/terraform-modules.git//compute/ec2-instance?ref=v2.4.1"
}

inputs = {
  instance_type               = "t3.micro"
  monitoring                  = true
  associate_public_ip_address = false

  tags = {
    ComponentClass = "compute"
    ManagedBy      = "terragrunt"
  }
}
