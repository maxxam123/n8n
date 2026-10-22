include "root" {
  path = find_in_parent_folders()
}

  # Dynamic Map of Organizational Units (OUs) to provision
  organizational_units = {
  {{- range .OrganizationalUnits }}
  {{ .ID }} = { name = "{{ .Name }}" }
  {{- end }}
}

  # Dynamic Map of AWS Accounts map to create and assign to OUs
aws_accounts = {
  {{- range $key, $account := .AwsAccounts }}
  {{ $key }} = {
    name      = "{{ $account.Name }}"
    email     = "{{ $account.Email }}"
    role_name = "{{ $account.RoleName }}"
    ou_key    = "{{ $account.OuKey }}"
  }
  {{- end }}
}

  # Service principals delegated to the security account
  delegated_administrators = [
    "://amazonaws.com",
    "://amazonaws.com"
  ]

  # Dynamic Service Control Policies map
  service_control_policies = {
    deny_leave_org = {
      name        = "deny-leave-organization"
      description = "Prevents any member account from leaving or altering the organization setup."
      ou_target   = "workloads_ou" # Key referencing the target OU
      policy_json = {
        Version = "2012-10-17"
        Statement = [
          {
            Sid      = "DenyLeave"
            Effect   = "Deny"
            Action   = ["organizations:LeaveOrganization"]
            Resource = "*"
          }
        ]
      }
    }
  }
}
