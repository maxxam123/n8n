# _envcommon/cdn/cloudfront.hcl

# 1. Source the verified community AWS CloudFront module
terraform {
  source = "TAG"
}

# 2. Corporate security policies and baseline configurations for all distributions
inputs = {
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100" # Uses NA and Europe edges (Cost-effective default)
  http_version        = "http2and3"

  # Corporate Edge Security Baseline
  viewer_certificate = {
    cloudfront_default_certificate = true
    minimum_protocol_version     = "TLSv1.2_2021" # Enforces high-grade modern ciphers
  }

  # Default Cache Behavior Policies (Enforces Security Headers & Redirects)
  default_cache_behavior = {
    target_origin_id       = "primary-backend"
    viewer_protocol_policy = "redirect-to-https" # Strictly drops unencrypted HTTP traffic
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    
    # Use managed AWS optimization policies (Saves custom cache HCL management)
    cache_policy_id          = "658327ef-4474-4787-8c74-a6560644313d" # CachingOptimized
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d5" # AllViewerExceptHostHeader
  }

  tags = {
    InfrastructureLayer = "edge-cdn"
    ProvisionedBy       = "Terragrunt"
  }
}
