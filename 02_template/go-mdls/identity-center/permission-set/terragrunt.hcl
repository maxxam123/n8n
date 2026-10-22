# global/identity-center/terragrunt.hcl

# 1. Inherit backend/provider configurations from root.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# 2. Pull the code source and base configurations from _envcommon
include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/identity-center.hcl"
  expose = true
}

# 3. Inject active configurations unique to this deployment layer
inputs = merge(
  include.envcommon.inputs,
  {
    # We add a brand new security auditor layer unique to this deployment footprint
    permission_sets = merge(
      include.envcommon.inputs.permission_sets,
      {
        SecurityAuditorCustom = {
          description      = "Custom Security Auditor footprint with strict S3 visibility limits"
          session_duration = "PT2H"
          managed_policies = ["arn:aws:iam::aws:policy/SecurityAudit"]
          inline_policy    = jsonencode({
            Version = "2012-10-17"
            Statement = [
              {
                Effect   = "Allow"
                Action   = ["s3:GetBucketLogging", "s3:GetBucketWebsite"]
                Resource = "*"
              }
            ]
          })
        }
      }
    )
  }
)
