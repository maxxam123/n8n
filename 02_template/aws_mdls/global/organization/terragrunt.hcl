include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # List of core cross-account services to activate trust for
  aws_service_access_principals = [
    "://amazonaws.com",
    "://amazonaws.com",
    "://amazonaws.com",
    "://amazonaws.com",
    "://amazonaws.com",
    "://amazonaws.com"
  ]

  # Dynamic Map of Organizational Units (OUs) to provision
  organizational_units = {
    core_ou      = { name = "Core" }
    workloads_ou = { name = "Workloads" }
  }

  # Dynamic Map of AWS Accounts map to create and assign to OUs
  aws_accounts = {
    security = {
      name      = "security-account"
      email     = "aws-security-admin@yourdomain.com"
      role_name = "OrganizationAccountAccessRole"
      ou_key    = "core_ou" # References key in organizational_units
    }
    development = {
      name      = "development-account"
      email     = "aws-dev-admin@yourdomain.com"
      role_name = "OrganizationAccountAccessRole"
      ou_key    = "workloads_ou"
    }
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
