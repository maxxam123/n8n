terraform {
  source = "git@github.com:maxxam123/infra-modules.git//vpc$ref=vpc-v0.0.1"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env             = "dev"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["SUB_PRI_01", "SUB_PRI_02"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/dev-demo"  = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/cluster/dev-demo" = "owned"
  }
}
