# infrastructure-live-03/dev/security/waf-alb/terragrunt.hcl

# 1. Mount provider blocks and remote backend tracking mechanics from your root
include "root" {
  path = find_in_parent_folders()
}

# 2. Extract shared core firewall parameters from common templates
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/waf_alb.hcl"
  expose = true
}

# 3. Dynamic dependency mapping—forces the ALB stack to stand up first
dependency "alb" {
  config_path = "../../network/alb"
}

# 4. Supply context variables and runtime overrides
inputs = {
  environment = "dev"
  
  # Extracts the live, newly provisioned ALB ARN dynamically from upstream outputs
  target_alb_arn = dependency.alb.outputs.alb_arn

  global_tags = merge(
    include.envcommon.inputs.global_tags,
    {
      Environment = "dev"
      CostCenter  = "SEC-REGIONAL-WAF-11"
    }
  )
}
