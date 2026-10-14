terraform {
    source = "git@github.com:maxxam123/infra-modules.git//eks$ref=eks-vTAG"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
  merge_stategy = "no_merge"
}

inputs = {
  eks_version = "VER"
  env = include.env.locals.env
  eks_name = "NAME"
  subnetids = dependency.vpc.outputs.private_subnet_ids

  node_groups = {
    general = {
      capacity_type = "ON_DEMAND"
      instance_types = ["MACHINE"]
      scalling_config = {
        desired_size = DES_SIZE
        max_size = MAX_SIZE
        min_size = MIN_SIZE
        }
      }
    }
  }
}

dependency "vpc" {
  config_path = "../../network/vpc"
 
  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}
