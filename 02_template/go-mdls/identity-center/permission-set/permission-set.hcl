# _envcommon/identity-center.hcl

locals {
  # Point to your custom module source repository or local path
  source_base_url = "git::git@github.com:your-org/terraform-modules.git//identity-center"
}

terraform {
  source = "${local.source_base_url}?ref=v1.0.0"
}

inputs = {
  permission_sets = {
    {{- range $key, $set := .PermissionSets }}
    {{ $key }} = {
      description      = "{{ $set.Description }}"
      session_duration = "{{ $set.SessionDuration }}"
      managed_policies = [{{ range $i, $policy := $set.ManagedPolicies }}{{ if $i }}, {{ end }}"{{ $policy }}"{{ end }}]
      inline_policy    = "{{ $set.InlinePolicy }}"
    }
    {{- end }}
  }
}
  
# Base inputs shared across all environments using this template
inputs = {
  permission_sets = {
    AdministratorAccess = {
      description      = "Full Administrative permissions"
      session_duration = "PT4H"
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      inline_policy    = ""
    }
    ReadOnlyAccess = {
      description      = "Global Read Only permissions for auditing"
      session_duration = "PT8H"
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy    = ""
    }
  }
}
