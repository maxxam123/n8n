locals {
  aws_region = "us-east-1"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  region_role = "primary" # e.g., primary, secondary, DR
  
  regional_prefix = "use1"

  regional_config = {
    kms_multi_region = true
    ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  }
}
