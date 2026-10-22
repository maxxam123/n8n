# _envcommon/waf_cloudfront.hcl

terraform {
  source = "${get_repo_root()}//infrastructure-modules/waf-cloudfront"
}

  
inputs = {
  # Standard managed rules configuration for comprehensive protection
  managed_rules = [
    {
      name        = "AWSManagedRulesCommonRuleSet"
      priority    = 10
      vendor_name = "AWS"
    },
    {
      name        = "AWSManagedRulesKnownBadInputsRuleSet"
      priority    = 20
      vendor_name = "AWS"
    },
    {
      name        = "AWSManagedRulesAmazonIpReputationList"
      priority    = 30
      vendor_name = "AWS"
    }
  ]

  global_tags = {
    ManagedBy          = "Terragrunt-IaC"
    ArchitectureLayer   = "Edge-Security"
    DataClassification = "Public-Facing"
  }
}
