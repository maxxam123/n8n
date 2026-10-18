# _envcommon/waf_alb.hcl

terraform {
  source = "${get_repo_root()}//infrastructure-modules/waf-alb"
}

inputs = {
  rate_limit_threshold = 3000

  # Standard foundational security definitions applied across all company ALBs
  managed_rules = [
    {
      name        = "AWSManagedRulesCommonRuleSet" # Shields against OWASP Top 10 exploits
      priority    = 10
      vendor_name = "AWS"
    },
    {
      name        = "AWSManagedRulesAmazonIpReputationList" # Blocks known botnets and malicious IPs
      priority    = 20
      vendor_name = "AWS"
    }
  ]
}
