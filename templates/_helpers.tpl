{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "nightingale.name" -}}
{{- default "n9e" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nightingale.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "nightingale" .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Helm required labels */}}
{{- define "nightingale.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ template "nightingale.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "nightingale.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ template "nightingale.name" . }}"
{{- end -}}

{{- define "nightingale.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (eq .Values.expose.tls.certSource "auto") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.autoGenCertForIngress" -}}
  {{- if and (eq (include "nightingale.autoGenCert" .) "true") (eq .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.autoGenCertForNginx" -}}
  {{- if and (eq (include "nightingale.autoGenCert" .) "true") (ne .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- template "nightingale.database" . }}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "3306" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "root" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.escapedRawPassword" -}}
  {{- include "nightingale.database.rawPassword" . | urlquery | replace "+" "%20" -}}
{{- end -}}

{{- define "nightingale.database.encryptedPassword" -}}
  {{- include "nightingale.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "nightingale.database.coreDatabase" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "registry" -}}
  {{- else -}}
    {{- .Values.database.external.coreDatabase -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.sslmode" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.database.external.sslmode -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.nwebapi.host" -}}
  {{- if eq .Values.nwebapi.type "internal" -}}
    {{- template "nightingale.nwebapi" . }}
  {{- else -}}
    {{- .Values.nwebapi.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.nwebapi.port" -}}
  {{- if eq .Values.nwebapi.type "internal" -}}
    {{- printf "%s" "18000" -}}
  {{- else -}}
    {{- .Values.nwebapi.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.nserver.host" -}}
  {{- if eq .Values.nserver.type "internal" -}}
    {{- template "nightingale.nserver" . }}
  {{- else -}}
    {{- .Values.nserver.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.nserver.port" -}}
  {{- if eq .Values.nserver.type "internal" -}}
    {{- printf "%s" "19000" -}}
  {{- else -}}
    {{- .Values.nserver.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.redis.scheme" -}}
  {{- with .Values.redis }}
    {{- ternary "redis+sentinel" "redis"  (and (eq .type "external" ) (not (not .external.sentinelMasterSet))) }}
  {{- end }}
{{- end -}}

/*host:port*/
{{- define "nightingale.redis.addr" -}}
  {{- with .Values.redis }}
    {{- ternary (printf "%s:6379" (include "nightingale.redis" $ )) .external.addr (eq .type "internal") }}
  {{- end }}
{{- end -}}

{{- define "nightingale.redis.masterSet" -}}
  {{- with .Values.redis }}
    {{- ternary .external.sentinelMasterSet "" (eq "redis+sentinel" (include "nightingale.redis.scheme" $)) }}
  {{- end }}
{{- end -}}

{{- define "nightingale.redis.password" -}}
  {{- with .Values.redis }}
    {{- ternary "" .external.password (eq .type "internal") }}
  {{- end }}
{{- end -}}

/*scheme://[redis:password@]host:port[/master_set]*/
{{- define "nightingale.redis.url" -}}
  {{- with .Values.redis }}
    {{- $path := ternary "" (printf "/%s" (include "nightingale.redis.masterSet" $)) (not (include "nightingale.redis.masterSet" $)) }}
    {{- $cred := ternary (printf "redis:%s@" (.external.password | urlquery)) "" (and (eq .type "external" ) (not (not .external.password))) }}
    {{- printf "%s://%s%s%s" (include "nightingale.redis.scheme" $) $cred (include "nightingale.redis.addr" $) $path -}}
  {{- end }}
{{- end -}}

{{- define "nightingale.redis" -}}
  {{- printf "%s-redis" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.database" -}}
  {{- printf "%s-database" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.prometheus" -}}
  {{- printf "%s-prometheus" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.telegraf" -}}
  {{- printf "%s-telegraf" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.nwebapi" -}}
  {{- printf "%s-nwebapi" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.nserver" -}}
  {{- printf "%s-nserver" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.nginx" -}}
  {{- printf "%s-nginx" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.exporter" -}}
  {{- printf "%s-exporter" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.ingress" -}}
  {{- printf "%s-ingress" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.caBundleVolume" -}}
- name: ca-bundle-certs
  secret:
    secretName: {{ .Values.caBundleSecretName }}
{{- end -}}

{{- define "nightingale.caBundleVolumeMount" -}}
- name: ca-bundle-certs
  mountPath: /nightingale_cust_cert/custom-ca.crt
  subPath: ca.crt
{{- end -}}

{{/* scheme for all components except notary because it only support http mode */}}
{{- define "nightingale.component.scheme" -}}
  {{- if .Values.internalTLS.enabled -}}
    {{- printf "https" -}}
  {{- else -}}
    {{- printf "http" -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "nightingale.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}
