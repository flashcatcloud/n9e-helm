# Helm Chart for Nightingale

English | [中文](README-CN.md)

## Introduction

This [Helm](https://github.com/flashcatcloud/n9e-helm) chart installs [Nightingale](https://github.com/didi/nightingale) in a Kubernetes cluster. Welcome to contribute to Helm Chart for Nightingale.

This repository, including the issues, focus on deploying Nightingale chart via helm. So for the functionality issues or questions of Nightingale, please open issues on [didi/nightingale](https://github.com/didi/nightingale)


## Prerequisites

- Kubernetes cluster 1.20+
- Helm v3.2.0+

## Installation

### Get Helm repository

```bash
git clone https://github.com/flashcatcloud/n9e-helm.git
```

### Configure the chart
The following items can be set via `--set` flag during installation or configured by editing the `values.yaml` directly(need to download the chart first).

#### Configure the way how to expose nightingale service

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

#### Configure the service over TLS

- **enabled**: Enable TLS or not. Delete the ssl-redirect annotations in `expose.ingress.annotations` when TLS is disabled and `expose.type` is `ingress`.
- **certSource**: The source of the TLS certificate. Set as `auto`, `secret` or `none` and fill the information in the corresponding section:
  - auto: generate the TLS certificate automatically
    - commonName: The common name used to generate the certificate, it's necessary when the type isn't `ingress`
  - secret: read the TLS certificate from the specified secret. The TLS certificate can be generated manually or by cert manager.
    - secretName: The name of secret which contains keys named:
      - tls.crt: the certificate
      - tls.key: the private key
  - none: configure no TLS certificate for the `ingress`. **If** the default TLS certificate is configured in the ingress controller, choose this option

#### Configure the external URL

The external URL for nightingale web service is used to visit web service of nightingale 

Format: `protocol://domain[:port]`. Usually:

- if expose the service via `Ingress`, the `domain` should be the value of `expose.ingress.hosts.web`
- if expose the service via `ClusterIP`, the `domain` should be the value of `expose.clusterIP.name`
- if expose the service via `NodePort`, the `domain` should be the IP address of one Kubernetes node
- if expose the service via `LoadBalancer`, set the `domain` as your own domain name and add a CNAME record to map the domain name to the one you got from the cloud provider

> NOTICE:

- If nightingale is deployed behind the proxy, set it as the URL of proxy.
- The default login user is `root`, default password is `root.2020` .

#### Configure the way how to persistent data

- **Disable**: The data does not survive the termination of a pod.
- **Persistent Volume Claim(default)**: A default `StorageClass` is needed in the Kubernetes cluster to dynamic provision the volumes. Specify another StorageClass in the `storageClass` or set `existingClaim` if you have already existing persistent volumes to use.


### Install the chart

Install the nightingale helm chart with a release name `nightingale`:
```bash
helm install nightingale ./n9e-helm -n n9e --create-namespace
```

## Uninstallation

To uninstall/delete the `nightingale` deployment:
```
helm uninstall  nightingale -n n9e
```

## Contributing
- Create and issue in [Issue List](https://github.com/flashcatcloud/n9e-helm/issues)
- If necessary, contact and discuss with maintainer
- Follow the [chart template developer's guide](https://helm.sh/docs/chart_template_guide/)
