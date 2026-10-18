dependency "POLICY" {
  config_path = "../iam-POLICY"
}

ä dev-developers = NAME_POLICY
# "alice", "bob" = PERSONS
  
inputs = {
  name = "NAME_POLICY"
  group_users = [PERSONS]
  
  custom_group_policy_arns = [
    dependency.POLICY.outputs.arn
  ]
}
