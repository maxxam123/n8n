# _global/dns/route53-01/terragrunt.hcl

# 1. Inherit dynamic state backends and provider engines from the root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit the standard corporate core properties from _envcommon
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../_envcommon/network/route53.hcl"
}

# 3. Pull network definitions dynamically if setting up Private Hosted Zones
dependency "production_vpc" {
  config_path = "../../../../RATH_VPC" # dev/network/vpc-01
}

dependency "staging_vpc" {
  config_path = "../../../environments/staging/network/vpc"
}

# ---------------------------------------------------------------------------------------------------------------------
# HOSTED ZONE DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  zones = {
    # Public Apex Domain: Managed globally, accessible to public edge routing
    "mycompany.com" = {
      comment = "Primary Public Apex Domain"
    }

    # Internal Private Domain: Secured natively inside your corporate VPC network perimeters
    "mycompany.internal" = {
      comment = "Internal Corporate Private Hosted Zone"
      
      # Automatically bind this DNS zone to both your Production and Staging VPC routing tables
      vpc = [
        {
          vpc_id     = dependency.production_vpc.outputs.vpc_id
          vpc_region = "us-east-1"
        },
        {
          vpc_id     = dependency.staging_vpc.outputs.vpc_id
          vpc_region = "us-east-1"
        }
      ]
    }
  }

  tags = {
    SecurityClassification = "restricted-networking"
  }
}
