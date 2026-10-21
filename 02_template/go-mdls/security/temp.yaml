# prod/github-oidc-provider/terragrunt.hcl

# 1. Inherit root terragrunt.hcl configuration (remote state tracking, AWS provider generation)
include "root" {
  path = find_in_parent_folders()
}

# 2. Inherit common component specifications 
include "envcommon" {
  path = "${get_terragrunt_dir()}/../../_envcommon/github-oidc-provider.hcl"
}

# 3. Supply environment specific variables overrides
inputs = {
  # Limit token access strictly to your GitHub organization and repositories
  # Supports classic formats and post-2026 immutable subject claim formats (owner@id/repo@id)
  repositories = [
    "{{ .Repo }}",
    "{{ .Repo }}"
  ]
}


cluster_name = "my-cluster-{{ .Environment }}"
aws_region   = "{{ .Region }}"
cluster_name = "my-cluster-{{ .Environment }}"
aws_region   = "{{ .Region }}"
cluster_name = "my-cluster-{{ .Environment }}"
aws_region   = "{{ .Region }}"

organizational_units = {
  {{- range .OrganizationalUnits }}
  {{ .ID }} = { name = "{{ .Name }}" },
  {{- end }}
}

organizational_units = {
{{- range $index, $element := .OrganizationalUnits }}
  {{- if $index }},{{ end }}
  {{ $element.ID }}_ou = { name = "{{ $element.Name }}" }
{{- end }}
}

organizational_units = {
{{- range .OrganizationalUnits }}
  {{ .ID }}_ou = { name = "{{ .Name }}" }
{{- end }}
}

aws_accounts = {
{{- range $index, $account := .AwsAccounts }}
  {{- if $index }}
{{ end }}
  {{- $account.Key }} = {
    name      = "{{ $account.Name }}"
    email     = "{{ $account.Email }}"
    role_name = "{{ $account.RoleName }}"
    ou_key    = "{{ $account.OuKey }}"{{ if eq $account.Key "security" }} # References key in organizational_units{{ end }}
  }
{{- end }}
}

aws_accounts = {
{{- range .AwsAccounts }}
  {{ .Key }} = {
    name      = "{{ .Name }}"
    email     = "{{ .Email }}"
    role_name = "{{ .RoleName }}"
    ou_key    = "{{ .OuKey }}"
  }
{{- end }}
}
