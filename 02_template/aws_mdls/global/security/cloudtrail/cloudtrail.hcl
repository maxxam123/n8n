# _envcommon/security/cloudtrail.hcl

# 1. Source the verified standalone cloudtrail module
terraform {
  source = "git@github.com vTAG"
}

# 2. Corporate security compliance configurations for CloudTrail
inputs = {
  name = "corporate-audit-trail"

  # Core Security Compliance Features
  enable_logging                = true
  enable_log_file_validation    = true # Enforces cryptographic log integrity validations
  is_multi_region_trail         = true # Captures management events across ALL AWS regions
  include_global_service_events = true # Ensures global IAM operations are logged natively

  # Data Lifecycle Policy
  log_retention_days = 90 # Trims operational logs from CloudWatch logs after 90 days

  tags = {
    InfrastructureLayer = "security-auditing"
    ProvisionedBy       = "Terragrunt"
  }
}
