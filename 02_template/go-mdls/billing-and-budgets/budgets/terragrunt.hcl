# _global/billing-and-budgets/cost-alerts/terragrunt.hcl

# 1. Inherit dynamic state backends and provider engines from the root file
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit the standard corporate core properties from _envcommon
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../../../_envcommon/billing-and-budgets/budgets.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT OVERRIDES & COST TARGETS
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  name         = "{{ .Budget.Name }}"
  limit_amount = "{{ .Budget.LimitAmount }}" # Enforce a hard ${{ .Budget.LimitAmount }}/month threshold target for this account

  # Add custom notifications or expand subscribers for this specific instance if necessary
  notifications = {
    {{- range $key, $notif := .Budget.Notifications }}
    {{ $key }} = {
      comparison_operator        = "{{ $notif.ComparisonOperator }}"
      threshold                  = {{ $notif.Threshold }}
      threshold_type             = "{{ $notif.ThresholdType }}"
      notification_type          = "{{ $notif.NotificationType }}"
      subscriber_email_addresses = [{{ range $i, $email := $notif.SubscriberEmailAddresses }}{{ if $i }}, {{ end }}"{{ $email }}"{{ end }}]
    }
    {{- end }}
  }
}


inputs = {
  name       = "BUDGETS_ACCOUNT"
  limit_amount = "5000.0" # Enforce a hard $5,000/month threshold target for this account

  # Add custom notifications or expand subscribers for this specific instance if necessary
  notifications = {
    warning = {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["finops-alerts@mycompany.com", "staging-owner@mycompany.com"]
    }
  }

  tags = {
    Environment = "global"
    CostCenter  = "corporate-governance"
  }
}
