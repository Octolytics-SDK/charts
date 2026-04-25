{{/*
Expand the chart or application name.
*/}}
{{- define "octo-apps.name" -}}
{{- $application := default dict .Values.application -}}
{{- default (default .Chart.Name .Values.nameOverride) $application.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the default resource name. For this chart, application.name is the
default resource name so releases can keep stable Kubernetes object names.
*/}}
{{- define "octo-apps.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "octo-apps.name" . -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "octo-apps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "octo-apps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "octo-apps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "octo-apps.labels" -}}
{{- $application := default dict .Values.application -}}
helm.sh/chart: {{ include "octo-apps.chart" . }}
{{ include "octo-apps.selectorLabels" . }}
{{- with .Chart.AppVersion }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with $application.environment }}
app.kubernetes.io/environment: {{ . | quote }}
{{- end }}
{{- with $application.partOf }}
app.kubernetes.io/part-of: {{ . | quote }}
{{- end }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Create the service account name to use.
*/}}
{{- define "octo-apps.serviceAccountName" -}}
{{- $serviceAccount := default dict .Values.serviceAccount -}}
{{- if $serviceAccount.create -}}
{{- default (include "octo-apps.fullname" .) $serviceAccount.name -}}
{{- else -}}
{{- default "default" $serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Return a stable service name for a container.
*/}}
{{- define "octo-apps.containerServiceName" -}}
{{- $root := .root -}}
{{- $container := .container -}}
{{- $service := default dict $container.service -}}
{{- default (printf "%s-%s" (include "octo-apps.fullname" $root) $container.name) $service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the global Secret name.
*/}}
{{- define "octo-apps.globalSecretName" -}}
{{- include "octo-apps.fullname" . -}}
{{- end -}}

{{/*
Return a stable Secret name for a container.
*/}}
{{- define "octo-apps.containerSecretName" -}}
{{- printf "%s-%s" (include "octo-apps.fullname" .root) .container.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Secret/env entries may use name or env. name is preferred.
*/}}
{{- define "octo-apps.itemName" -}}
{{- required "envs and secrets entries require either name or env" (default .env .name) -}}
{{- end -}}

{{/*
Render an image reference from repository/tag or repository/digest.
*/}}
{{- define "octo-apps.image" -}}
{{- $root := .root -}}
{{- $image := .image -}}
{{- $repository := required "containers[].image.repository is required" $image.repository -}}
{{- if $image.digest -}}
{{- printf "%s@%s" $repository $image.digest -}}
{{- else -}}
{{- printf "%s:%s" $repository (default $root.Chart.AppVersion $image.tag) -}}
{{- end -}}
{{- end -}}

{{/*
Render ExternalSecret data rows.
*/}}
{{- define "octo-apps.externalSecretData" -}}
{{- range $secret := .secrets }}
{{- $remoteRef := dict -}}
{{- if $secret.remoteRef -}}
{{- $remoteRef = $secret.remoteRef -}}
{{- else -}}
{{- $_ := set $remoteRef "key" (required "secrets[].key or secrets[].remoteRef is required" $secret.key) -}}
{{- with $secret.property -}}{{- $_ := set $remoteRef "property" . -}}{{- end -}}
{{- with $secret.version -}}{{- $_ := set $remoteRef "version" . -}}{{- end -}}
{{- with $secret.conversionStrategy -}}{{- $_ := set $remoteRef "conversionStrategy" . -}}{{- end -}}
{{- with $secret.decodingStrategy -}}{{- $_ := set $remoteRef "decodingStrategy" . -}}{{- end -}}
{{- end }}
- secretKey: {{ include "octo-apps.itemName" $secret | quote }}
  remoteRef:
{{ toYaml $remoteRef | trim | indent 4 }}{{ end }}
{{- end -}}
{{/*
Render an Ingress backend port as either a name or number.
*/}}
{{- define "octo-apps.ingressBackendPort" -}}
{{- if kindIs "string" . -}}
name: {{ . }}
{{- else -}}
number: {{ . }}
{{- end -}}
{{- end -}}
