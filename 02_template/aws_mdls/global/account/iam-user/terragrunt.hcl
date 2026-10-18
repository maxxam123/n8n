include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # Standard community module to build out secure IAM user frameworks
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-group-with-policies?version=5.30.0"
}

inputs = {
  name = "legacy-application-group"

  # Create the user entities
  group_users = [
    "service-account-jenkins", "service-account-siem-collector"]

  # Attach strictly scoped API policies to the group rather than individual users
  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}
