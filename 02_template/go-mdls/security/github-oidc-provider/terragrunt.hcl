# Automatically inherit remote state, provider, and account configurations from root
include "root" {
  path = find_in_parent_folders()
}

# Pull the core module logic from the common directory
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/github-oidc-provider.hcl"
  expose = true
}

# Override or supply specific inputs for this environment
inputs = {
  role_name = "{{ .Region }}"
  
  # Limit authentication to exact GitHub repositories and branches
  repositories = [
  #  "my-organization/my-application-repo:ref:refs/heads/main",
  #  "my-organization/infrastructure-live-repo:*"
    "{{ .Region }}/APP_REPO:ref:refs/heads/main",
    "{{ .Region }}/{{ .Environment }}:*"
  ]

  # Attach explicit roles needed by the GitHub workspace
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/{{ .Region }}"
  ]
}
