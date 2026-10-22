# accounts/management-account/global/identity-center/users/terragrunt.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/identity-center-users.hcl"
  expose = true
}

inputs = {
  users = merge(
    include.envcommon.inputs.users,
    {
      john_doe = {
        user_name   = "jdoe"
        given_name  = "John"
        family_name = "Doe"
        email       = "john.doe@company.com"
      },
      jane_smith = {
        user_name   = "jsmith"
        given_name  = "Jane"
        family_name = "Smith"
        email       = "jane.smith@company.com"
      }
    }
  )
}
