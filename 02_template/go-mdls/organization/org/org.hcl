# _envcommon/security/github-oidc-provider.hcl

# Define the base module source location
terraform {
  source = "../../../../../modules/github-oidc-provider/"
}

# Baseline default inputs shared across any account using this component
inputs = {
  client_id_list = ["https://github.com", "://amazonaws.com"]
  tags = {
    ManagedBy = "Terragrunt"
    Component = "GitHub-OIDC"
  }
}
