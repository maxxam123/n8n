# This file will be populated dynamically
cluster_name = "my-cluster-{{ .Values.environment }}"
aws_region   = "{{ .Values.region }}"

# templates/temp-02.hcl
organizational_units = {
  {{- $total := len .Values.organizationalUnits }}
  {{- $i := 0 }}
  {{- range $key, $value := .Values.organizationalUnits }}
  {{- $i = add1 $i }}
  {{ $key }} = { name = "{{ $value.name }}" }{{ if lt $i $total }},{{ end }}
  {{- end }}
}
