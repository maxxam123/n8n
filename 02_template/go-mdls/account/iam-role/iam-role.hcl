# _envcommon/security/github-oidc-provider.hcl

# Define the base module source location
terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider?version=5.48.0"
}

# Baseline default inputs shared across any account using this component
inputs = {
  client_id_list = ["https://github.com", "://amazonaws.com"]
  tags = {
    ManagedBy = "Terragrunt"
    Component = "GitHub-OIDC"
  }
}
