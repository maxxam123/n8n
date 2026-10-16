# _envcommon/billing-and-budgets/budgets.hcl

# 1. Source a verified standalone community AWS Budgets module
# (Alternatively, you can write a raw HCL module wrapping the aws_budgets_budget resource)
terraform {
  source = "TAG"
}

# 2. Corporate safety baselines and default thresholds for cost governance
inputs = {
  budget_type  = "COST"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Standard corporate alerting tiers
  notifications = {
    warning = {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["finops-alerts@mycompany.com"]
    },
    critical = {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 100
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED" # Alerts BEFORE you overspend based on usage trends
      subscriber_email_addresses = ["finops-alerts@mycompany.com", "devops-leads@mycompany.com"]
    }
  }
}
