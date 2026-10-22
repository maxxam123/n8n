# Automatically inherit remote state, provider, and account configurations from root
include "root" {
  path = find_in_parent_folders()
}

# Pull the core module logic from the common directory
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/security/github-oidc-provider.hcl"
  expose = true
}

# Override or supply specific inputs for this environment
inputs = {
  role_name = "{{ .RoleName }}"
  
  # Limit authentication to exact GitHub repositories and branches
  repositories = [
  #  "my-organization/my-application-repo:ref:refs/heads/main",
  #  "my-organization/infrastructure-live-repo:*"
  #  "{{ .Org }}/{{ .RepoDev }}:ref:refs/heads/main",
    "{{ .Org }}/{{ .RepoLive }}:*"
  ]

  # Attach explicit roles needed by the GitHub workspace
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/{{ .ExpRole }}"
  ]
}
