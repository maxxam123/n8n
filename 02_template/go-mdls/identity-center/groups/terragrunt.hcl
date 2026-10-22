# accounts/management-account/global/identity-center/groups/terragrunt.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/identity-center-groups.hcl"
  expose = true
}

# 1. Fetch dynamic outputs (user_ids) from the sibling users stack
dependency "users" {
  config_path = "../users"
}


inputs = {
  groups = include.envcommon.inputs.groups

  # 2. Map users dynamically into their corporate groups
  memberships = [
    {{- range .Memberships }}
    {
      group_name = "{{ .GroupName }}"
      user_id    = dependency.users.outputs.user_ids[{{ range $i, $key := .UserKeys }}{{ if $i }}, {{ end }}"{{ $key }}"{{ end }}]
    },
    {{- end }}
  ]
}

inputs = {
  groups = include.envcommon.inputs.groups

  # 2. Map users dynamically into their corporate groups
  memberships = [
    {
      group_name = "AWS-Platform-Engineering"
      user_id    = dependency.users.outputs.user_ids["breakglass_admin", "breakglass_admin_02"]
    },
    {
      group_name = "AWS-Platform-Engineering"
      user_id    = dependency.users.outputs.user_ids["john_doe", "breakglass_admin_03"]
    },
    {
      group_name = "AWS-Security-Operations"
      user_id    = dependency.users.outputs.user_ids["jane_smith", "breakglass_admin_04"]
    }
  ]
}
