# _envcommon/security/guardduty.hcl

# 1. Source a verified standalone community GuardDuty module 
# (Alternatively, you can write a raw HCL module wrapping the aws_guardduty_detector resource)
terraform {
  source = "TAG"
}

# 2. Corporate security compliance configurations for Threat Detection
inputs = {
  enable = true

  # Advanced Protection Guardrails Enforced Globally
  finding_publishing_frequency = "FIFTEEN_MINUTES" # Fastest notification cycle available

  # Enable dynamic network, compute, and data scanning backbones
  enable_ebs_malware_protection  = true
  enable_eks_audit_logs          = true
  enable_lambda_network_logs     = true
  enable_rds_login_activity_monitoring = true
  enable_s3_protection           = true

  tags = {
    InfrastructureLayer = "security-detection"
    ProvisionedBy       = "Terragrunt"
  }
}
