include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/network/tgw.hcl"
}

dependency "vpc_spoke_a" {
  config_path = "../vpc-spoke-a"
}

dependency "vpc_spoke_b" {
  config_path = "../vpc-spoke-b"
}
-
inputs = {
  name            = "staging-tgw"
  amazon_side_asn = 64513 # Overriding ASN specifically for staging separation

  vpc_attachments = {
    vpc_a = {
      vpc_id       = dependency.vpc_spoke_a.outputs.vpc_id
      subnet_ids   = dependency.vpc_spoke_a.outputs.private_subnets
      dns_support  = true
      ipv6_support = false
      
      tgw_tags = {
        Name = "tgw-attachment-vpc-spoke-a"
      }
    },
    vpc_b = {
      vpc_id       = dependency.vpc_spoke_b.outputs.vpc_id
      subnet_ids   = dependency.vpc_spoke_b.outputs.private_subnets
      dns_support  = true
      
      tgw_tags = {
        Name = "tgw-attachment-vpc-spoke-b"
      }
    }
  }

  tags = {
    Environment = "staging"
  }
}

