# _global/cdn/cloudfront-01/terragrunt.hcl

# 1. Inherit global backend states and provider parameters from the root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit corporate edge parameters and module source from our common template
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/cdn/cloudfront.hcl"
}

# 3. Reference your active Application Load Balancer (ALB) or S3 Origin stack
dependency "alb" {
  config_path = "../../../../PATH_ALB" # dev/network/alb-01
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURATION INJECTIONS & OVERRIDES
# Terragrunt automatically merges these inputs on top of the defaults declared in _envcommon.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  comment = "Global Edge Distribution for Primary Web App"
  
  # Scale out to all global edge locations for low latency in production
  price_class = "PriceClass_All" 

  # Set up custom domain inputs if needed (requires referencing your ACM certificate)
  # aliases = ["://company.com"]
  # viewer_certificate = {
  #   acm_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/abc-123..."
  #   ssl_support_method  = "sni-only"
  # }

  # Dynamically map the target infrastructure backend
  origin = {
    primary-backend = {
      domain_name = dependency.alb.outputs.lb_dns_name
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only" # Enforces end-to-end encryption to the ALB
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  tags = {
    Environment = "production"
    DataScope   = "public-facing"
  }
}
