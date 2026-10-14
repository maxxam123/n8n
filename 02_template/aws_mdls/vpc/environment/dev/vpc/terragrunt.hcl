terraform {
  source = "git@github.com:maxxam123/infra-modules.git//vpc$ref=vpc-vTAG"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  env             = "ENV"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["SUB_PRI_01", "SUB_PRI_02"]
  public_subnets  = ["SUB_PUB_01", "SUB_PUB_02"]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/dev-demo"  = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"         = 1
    "kubernetes.io/cluster/dev-demo" = "owned"
  }
}
