# _envcommon/cloudfront.hcl

# Bind this environment common layout to your infrastructure-modules repository
terraform {
  source = "${get_repo_root()}//infrastructure-modules/cloudfront"
}

# Base configurations common across the enterprise landscape
inputs = {
  price_class = "PriceClass_100" # Optimizes costs by using only US, Canada, and Europe edge nodes
  
  # Standard secure enterprise TLS handshake baseline
  minimum_protocol_version = "TLSv1.2_2021"

  # Baseline origin caching rules
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  global_tags = {
    ManagedBy          = "Terragrunt-IaC"
    ArchitectureLayer   = "Application-Routing"
    DataClassification = "Public"
  }
}
