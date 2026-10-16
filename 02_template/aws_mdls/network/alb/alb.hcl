# _envcommon/network/alb.hcl

# 1. Source the verified community AWS ALB module
terraform {
  source = "TAG"
}

# 2. Corporate safety baselines and default parameters for Load Balancers
inputs = {
  load_balancer_type = "application"

  # Enterprise Security Guardrails Enforced Globally
  drop_invalid_header_fields = true # Blocks malicious header injections at the edge
  enable_deletion_protection = true # Overridden in testing/staging environments if needed

  # Modern Security Cipher Set for SSL Termination
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  tags = {
    InfrastructureLayer = "network-ingress"
    ProvisionedBy       = "Terragrunt"
  }
}
