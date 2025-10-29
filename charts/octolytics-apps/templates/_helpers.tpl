{{/*
Define common labels.
*/}}
{{- define "octolytics-app.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ .Values.application.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Define selector labels.
*/}}
{{- define "octolytics-app.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.application.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}