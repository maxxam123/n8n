# _envcommon/security/waf-global.hcl

# 1. Source the verified community AWS WAFv2 module
terraform {
  source = "TAG"
Use code with caution.
hcl
}

# 2. Corporate safety baselines and default parameters for Global Core Firewalls
inputs = {
  name        = "global-edge-waf"
  description = "Global WAFv2 Core Firewall protecting Edge Content Delivery Networks"
  scope       = "CLOUDFRONT" # Strictly required for CloudFront associations

  # Default action to take when traffic doesn't trigger any custom firewall rules
  default_action = {
    allow = {}
  }

  visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "global-edge-waf-metrics"
    sampled_requests_enabled   = true
  }

  # Standard AWS Managed Protection Rules Layered on the Edge
  rules = [
    {
      name     = "AWSManagedRulesCommonRuleSet"
      priority = 10
      override_action = {
        none = {}
      }
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "WAFCommonRuleSetMetric"
        sampled_requests_enabled   = true
      }
    },
    {
      name     = "AWSManagedRulesKnownBadInputsRuleSet"
      priority = 20
      override_action = {
        none = {}
      }
      statement = {
        managed_rule_group_statement = {
          name        = "AWSManagedRulesKnownBadInputsRuleSet"
          vendor_name = "AWS"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "WAFKnownBadInputsMetric"
        sampled_requests_enabled   = true
      }
    }
  ]

  tags = {
    InfrastructureLayer = "security-edge-protection"
    ProvisionedBy       = "Terragrunt"
  }
}
