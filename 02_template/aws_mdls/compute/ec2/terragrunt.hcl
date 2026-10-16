include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git@github.com//maxxam123/mod ... vTAG"
}

dependency "vpc" {
  config_path = "../../PATH" # network/vpc
}

inputs = {
  name = "EC2_NAME"

  # Hardware Configurations
  instance_type          = "INSTNACE_TYPE"
  ami_ssm_parameter      = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
  key_name               = "KEY_NAME"

  subnet_id              = dependency.vpc.outputs.private_subnets[0]
  vpc_security_group_ids = [dependency.vpc.outputs.default_security_group_id]

  enable_volume_tags = true
  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = 50
      throughput            = 125
      iops                  = 3000
      encrypted             = true
      delete_on_termination = true
    }
  ]

  monitoring             = true
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Layer = "compute"
    Role  = "application-host"
  }
}

