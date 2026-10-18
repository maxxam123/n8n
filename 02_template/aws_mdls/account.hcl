locals {
  account_name   = "non-prod-dev"
  aws_account_id = "111122223333"
  environment    = "dev"

  deployment_role_name = "EnterpriseTerragruntExecutionRole"

  enable_enhanced_monitoring = false
  enable_deletion_protection = false

  account_tags = {
    BusinessUnit = "E-Commerce"
    DataClass    = "Internal"
    Owner        = "Platform-Team"
    ManagedBy    = "Terragrunt"
  }
}
