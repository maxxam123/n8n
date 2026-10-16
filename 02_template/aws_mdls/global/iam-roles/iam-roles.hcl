# _envcommon/account/iam-roles.hcl

# 1. Source the verified community AWS IAM Assumable Role module
terraform {
  source = "git@github.com vTAG"
}

# 2. Corporate baseline configurations for standardized IAM roles
inputs = {
  create_role = true

  # Security Guardrails Enforced Globally
  max_session_duration = 14400 # 4 Hours (Standard compliance threshold for rotation)
  force_detach_policies = true # Clean teardowns by removing policy attachments on delete

  # Explicitly require MFA for assuming this cross-account execution role
  role_requires_mfa = true

  tags = {
    InfrastructureLayer = "identity-and-access"
    ProvisionedBy       = "Terragrunt"
  }
}
