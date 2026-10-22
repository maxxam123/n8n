# _envcommon/identity-center-users.hcl

locals {
  source_base_url = "git::git@github.com:your-org/terraform-modules.git//identity-center-users"
}

terraform {
  source = "${local.source_base_url}?ref=v1.3.0"
}

inputs = {
  users = {
    {{- range $key, $user := .Users }}
    {{ $key }} = {
      user_name   = "{{ $user.UserName }}"
      given_name  = "{{ $user.GivenName }}"
      family_name = "{{ $user.FamilyName }}"
      email       = "{{ $user.Email }}"
    },
    {{- end }}
  }
}
  
inputs = {
  users = {
    breakglass_admin = {
      user_name   = "breakglass.admin"
      given_name  = "BreakGlass"
      family_name = "Admin"
      email       = "security-ops@company.com"
    },
    breakglass_admin_01 = {
      user_name   = "breakglass_01.admin_01"
      given_name  = "BreakGlass_01"
      family_name = "Admin_01"
      email       = "security-ops_01@company.com"
    },
  }
}
