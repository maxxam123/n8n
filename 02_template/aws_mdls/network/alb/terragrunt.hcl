# environments/staging/network/alb-public/terragrunt.hcl

# 1. Inherit backend state buckets and global providers from the main root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit common corporate parameters from the _envcommon template
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/network/alb.hcl"
}

# 3. Pull dynamic outputs from target architecture layers
dependency "vpc" {
  config_path = "../../VPC"
}

dependency "waf" {
  config_path = "../../security/waf-regional"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT OVERRIDES & ROUTING TARGETS
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  name    = "staging-public-alb"
  internal = false # Exposes this ALB directly to the public internet

  # Network bindings pulled dynamically from your active VPC state engine
  vpc_id  = dependency.vpc.outputs.vpc_id
  subnets = dependency.vpc.outputs.public_subnets

  # Disable deletion protection for staging to allow easy pipeline teardowns
  enable_deletion_protection = false

  # Attach your regional WAF firewall rules natively upon creation
  associate_web_acl = true
  web_acl_arn       = dependency.waf.outputs.web_acl_arn

  # Security Group rules allowing ingress access paths
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Route definitions mapping back to your application listening ports
  listeners = {
    # Port 80 Listener: Redirects unencrypted traffic to HTTPS automatically
    http_redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    # Port 443 Listener: Routes traffic down to your compute target groups
    https_backend = {
      port            = 443
      protocol        = "HTTPS"
      # acm_certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/abc..." # Add custom SSL cert here
      
      forward = {
        target_group_key = "primary-app-tg"
      }
    }
  }

  # Target Group mappings detailing where your application nodes reside
  target_groups = {
    primary-app-tg = {
      name_prefix      = "stgapp"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "instance" # Maps directly to EC2 instances (or 'ip' for EKS/ECS pods)
      
      health_check = {
        enabled             = true
        path                = "/healthz"
        port                = "8080"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
      }
    }
  }

  tags = {
    Environment = "staging"
  }
}
