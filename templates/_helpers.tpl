{{/*
# Copyright 2022 flashcat.cloud | 快猫星云
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
*/}}
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

{{- define "nightingale.database.servicePort" -}}
    {{- template "nightingale.database.port" . }}
{{- end -}}

{{- define "nightingale.database.username" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.username -}}
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

{{- define "nightingale.database.name" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "n9e_v6" -}}
  {{- else -}}
    {{- .Values.database.external.name -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.database.escapedRawPassword" -}}
  {{- include "nightingale.database.rawPassword" . | urlquery | replace "+" "%20" -}}
{{- end -}}

{{- define "nightingale.database.encryptedPassword" -}}
  {{- include "nightingale.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "nightingale.database.sslmode" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "disable" -}}
  {{- else -}}
    {{- .Values.database.external.sslmode -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.n9e.host" -}}
  {{- if eq .Values.n9e.type "internal" -}}
    {{- template "nightingale.n9e" . }}
  {{- else -}}
    {{- .Values.n9e.external.host -}}
  {{- end -}}
{{- end -}}


{{- define "nightingale.n9e.port" -}}
  {{- if eq .Values.n9e.type "internal" -}}
    {{- printf "%s" "17000" -}}
  {{- else -}}
    {{- .Values.n9e.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.n9e.servicePort" -}}
    {{- printf "80" -}}
{{- end -}}

{{- define "nightingale.n9e.ibexEnable" -}}
  {{- if eq .Values.n9e.type "internal" -}}
    {{- .Values.n9e.internal.ibexEnable -}}
  {{- else -}}
    {{- .Values.n9e.external.ibexEnable -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.n9e.ibexPort" -}}
  {{- if eq .Values.n9e.type "internal" -}}
    {{- .Values.n9e.internal.ibexPort -}}
  {{- else -}}
    {{- .Values.n9e.external.ibexPort -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.n9e.ibexServicePort" -}}
    {{- printf "20090" -}}
{{- end -}}

{{- define "nightingale.prometheus.host" -}}
  {{- if eq .Values.prometheus.type "internal" -}}
    {{- template "nightingale.prometheus" . }}
  {{- else -}}
    {{- .Values.prometheus.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.prometheus.port" -}}
  {{- if eq .Values.prometheus.type "internal" -}}
    {{- printf "%s" "9090" -}}
  {{- else -}}
    {{- .Values.prometheus.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.prometheus.servicePort" -}}
  {{- template "nightingale.prometheus.port" . }}
{{- end -}}

{{- define "nightingale.prometheus.username" -}}
  {{- if eq .Values.prometheus.type "internal" -}}
    {{- .Values.prometheus.internal.username -}}
  {{- else -}}
    {{- .Values.prometheus.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.prometheus.rawPassword" -}}
  {{- if eq .Values.prometheus.type "internal" -}}
    {{- .Values.prometheus.internal.password -}}
  {{- else -}}
    {{- .Values.prometheus.external.password -}}
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

{{- define "nightingale.redis.username" -}}
  {{- with .Values.redis }}
    {{- ternary "" .external.username (eq .type "internal") }}
  {{- end }}
{{- end -}}

{{- define "nightingale.redis.password" -}}
  {{- with .Values.redis }}
    {{- ternary "" .external.password (eq .type "internal") }}
  {{- end }}
{{- end -}}

{{- define "nightingale.redis.mode" -}}
  {{- with .Values.redis }}
    {{- ternary "standalone" .external.mode (eq .type "internal") }}
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

{{- define "nightingale.categraf" -}}
  {{- printf "%s-categraf-v6" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.n9e" -}}
  {{- printf "%s-center" (include "nightingale.fullname" .) -}}
{{- end -}}

{{- define "nightingale.nginx" -}}
  {{- printf "%s-nginx" (include "nightingale.fullname" .) -}}
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

{{/* now it only support http mode */}}
{{- define "nightingale.component.scheme" -}}
    {{- printf "http" -}}
{{- end -}}


{{- define "nightingale.tlsSecretForIngress" -}}
  {{- if eq .Values.expose.tls.certSource "none" -}}
    {{- printf "" -}}
  {{- else if eq .Values.expose.tls.certSource "secret" -}}
    {{- .Values.expose.tls.secret.secretName -}}
  {{- else -}}
    {{- include "nightingale.ingress" . -}}
  {{- end -}}
{{- end -}}

{{- define "nightingale.tlsSecretForNginx" -}}
  {{- if eq .Values.expose.tls.certSource "secret" -}}
    {{- .Values.expose.tls.secret.secretName -}}
  {{- else -}}
    {{- include "nightingale.nginx" . -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "nightingale.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}
