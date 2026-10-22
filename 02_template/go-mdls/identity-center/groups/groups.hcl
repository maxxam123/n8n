# _envcommon/identity-center.hcl

inputs = {
  # 1. Blueprint definitions for groups to ensure they exist in the identity store
  identity_groups = {
    {{- range $key, $group := .IdentityGroups }}
    {{ $key }} = {
      display_name = "{{ $group.DisplayName }}"
      description  = "{{ $group.Description }}"
    }
    {{- end }}
  }
}



inputs = {
  # 1. Blueprint definitions for groups to ensure they exist in the identity store
  identity_groups = {
    platform_eng = {
      display_name = "AWS-Platform-Engineering"
      description  = "Cloud platform architects and systems administrators."
    }
    security_ops = {
      display_name = "AWS-Security-Operations"
      description  = "Security compliance officers and incident response teams."
    }
    developers = {
      display_name = "AWS-Application-Developers"
      description  = "Product engineering teams with access to non-prod workloads."
    }
    finops = {
      display_name = "AWS-Finance-Operations"
      description  = "Billing administrators and cost management teams."
    }
  }

  group_account_assignments = [
    {{- range .GroupAccountAssignments }}
    {
      group_key       = "{{ .GroupKey }}"
      account_id      = "{{ .AccountId }}"
      permission_sets = [{{ range $i, $perm := .PermissionSets }}{{ if $i }}, {{ end }}"{{ $perm }}"{{ end }}]
    },
    {{- end }}
  ]
}

  # 2. Multi-Account Permission Assignment Matrix for Groups
  # Maps your logical group keys to target AWS accounts and their respective permission sets
  group_account_assignments = [
    # Management/Root Account Permissions
    {
      group_key       = "platform_eng"
      account_id      = "111122223333" # Management Account ID
      permission_sets = ["AdministratorAccess"]
    },
    {
      group_key       = "finops"
      account_id      = "111122223333"
      permission_sets = ["Billing"]
    },

    # Core Security Account Permissions
    {
      group_key       = "security_ops"
      account_id      = "444455556666" # Security Account ID
      permission_sets = ["AdministratorAccess", "SecurityAudit"]
    },
    {
      group_key       = "platform_eng"
      account_id      = "444455556666"
      permission_sets = ["ReadOnlyAccess"]
    },

    # Workloads / Application Account Permissions
    {
      group_key       = "developers"
      account_id      = "777788889999" # Development Account ID
      permission_sets = ["PowerUserAccess"]
    },
    {
      group_key       = "platform_eng"
      account_id      = "777788889999"
      permission_sets = ["AdministratorAccess"]
    }
  ]
}
