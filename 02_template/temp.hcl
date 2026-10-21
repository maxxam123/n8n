# This file will be populated dynamically
cluster_name = "my-cluster-{{.environment}}"
aws_region   = "{{.region}}"

organizational_units = {
  {{- range $key, $value := .organizationalUnits }}
  {{ $key }} = { name = "{{ $value.name }}" }
  {{- end }}
}
