# This file will be populated dynamically
cluster_name = "my-cluster-{{ .Values.environment }}"
aws_region   = "{{ .Values.region }}"

# templates/temp-02.hcl
organizational_units = {
  {{- range $key, $value := .Values.organizationalUnits }}
  {{ $key }} = { name = "{{ $value.name }}" },
  {{- end }}
}
