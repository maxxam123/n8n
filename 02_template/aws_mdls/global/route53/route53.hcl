# _envcommon/network/route53.hcl

# 1. Source the verified community AWS Route53 zones module
terraform {
  source = "TAG"
}

# 2. Corporate safety baselines and default parameters for zone governance
inputs = {
  # Forces default tagging constraints across all managed DNS networks
  tags = {
    InfrastructureLayer = "dns-backbone"
    ProvisionedBy       = "Terragrunt"
  }
}
