# _envcommon/github-oidc-provider.hcl

# Define the source module version and reference path
terraform {
  source = "tfr:///terraform-module/github-oidc-provider/aws?version=1.3.5"
}

# Define base inputs shared across all accounts
inputs = {
  create_oidc_provider = true
  create_oidc_role     = true
  
  # Default standard configurations 
  role_name           = "github-actions-infra-execution-role"
  max_session_duration = 3600
  
  # IAM policies you want to give to your GitHub runner (e.g., Administrator or PowerUser)
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}
