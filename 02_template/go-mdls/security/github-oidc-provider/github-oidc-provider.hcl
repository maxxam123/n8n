# Base configuration for the GitHub OIDC Provider module
terraform {
  source = "git::git@github.com:terraform-module/terraform-aws-github-oidc-provider.git?ref=v1.22.0"
}

# Define base inputs that shouldn't change per environment
inputs = {
  create_oidc_provider = true
  create_oidc_role     = true
  max_session_duration = 3600
}
