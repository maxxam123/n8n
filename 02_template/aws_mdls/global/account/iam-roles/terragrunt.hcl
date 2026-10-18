include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Pull down the shared inputs from the environment common baseline file
include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../../_envcommon/iam-roles.hcl"
  expose = true
}

inputs = {
  name = "user-matrix"

  # Define the trust relationship: Who can assume these roles?
  # In an enterprise, this maps to an Identity Account, Okta/SAML, or IAM Identity Center
  principals = {
    AWS = [
      "arn:aws:iam::111122223333:root" # Trust your central corporate identity account boundary
    ]
  }
  # admin-user = SVC
  # Define the 5 standard enterprise user personas via an input matrix map
  # The underlying module loops over this structure using for_each
  role_definitions = {
    "SVC" = {
       description        = "Full administrative access for the lead platform engineer"
       policy_arn_attachments = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}
