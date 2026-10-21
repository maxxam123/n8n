# prod/github-oidc-provider/terragrunt.hcl

# 1. Inherit root terragrunt.hcl configuration (remote state tracking, AWS provider generation)
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit common component specifications 
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../_envcommon/github-oidc-provider.hcl"
}

# 3. Supply environment specific variables overrides
inputs = {
  # Limit token access strictly to your GitHub organization and repositories
  # Supports classic formats and post-2026 immutable subject claim formats (owner@id/repo@id)
  repositories = [
    "your-github-org/infrastructure-live-repo",
    "your-github-org/app-deployment-repo"
  ]
}

