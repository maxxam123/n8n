# infrastructure-live-03/dev/application-routing/cloudfront/terragrunt.hcl

# 1. Inherit root provider configurations, state buckets, and locks
include "root" {
  path = find_in_parent_folders()
}

# 2. Pull base structural logic and source pointers from your _envcommon
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/cloudfront.hcl"
  expose = true
}

# 3. Dynamic dependency mapping to fetch the global WAF ARN securely
dependency "waf" {
  config_path = "{{ .PathWaf }}/waf-global"
}

dependency "alb" {
  config_path = "{{ .PathAlb }}/alb"
}

# 4. Inject development-specific routing and origin endpoints
inputs = {
  environment = "{{ .Env }}"

  # Link the Edge WAF Web ACL ARN directly out of upstream state outputs
  web_acl_id = dependency.waf.outputs.web_acl_arn

  # Define the target origin endpoint (e.g., your public or private application load balancer)
  origin_domain_name = dependency.alb.outputs.alb_dns_name
  origin_id          = "App-ALB-Origin"

  # Domain names attached to this distribution
  aliases = ["app-dev.${include.root.inputs.prefix}.internal"]

  # Merge local metadata context over the base global_tags defined in _envcommon
  global_tags = merge(
    include.envcommon.inputs.global_tags,
    {
      Environment = "dev"
      CostCenter  = "APP-ROUTING-4455"
    }
  )
}
