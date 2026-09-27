{{- define "platform.name" -}}
{{- printf "%s-platform" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "platform.labels" -}}
app.kubernetes.io/name: orzyon-platform
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: orzyon-ai-platform
{{- end -}}
