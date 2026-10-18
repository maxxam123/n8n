include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/waf_cloudfront.hcl"
  expose = true
}

# Override or force the region constraint for CloudFront WAF deployments
inputs = {
  environment = "dev"
  aws_region  = "us-east-1" # 👈 MUST be us-east-1 for CloudFront scope!

  # Custom rate-limiting configuration specific to the dev sandbox environment
  rate_limit_threshold = 2000 # Block any IP exceeding 2000 requests per 5 minutes

  global_tags = merge(
    include.envcommon.inputs.global_tags,
    {
      Environment = "dev"
      CostCenter  = "SEC-WAF-9911"
    }
  )
}
