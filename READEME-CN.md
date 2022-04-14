# Helm Chart for Nightingale

中文 | [English](README.md)

## 简介

[n9e-helm](https://github.com/flashcatcloud/n9e-helm) 在k8s 集群中安装[Nightingale](https://github.com/didi/nightingale)。 欢迎贡献。

本仓库主要关注夜莺的chart。关于夜莺功能性的issue 请移步 [didi/nightingale](https://github.com/didi/nightingale)


## 前置依赖

- Kubernetes cluster 1.20+
- Helm v3.2.0+

##  安装

### 获取 Helm repo

```bash
git clone https://github.com/flashcatcloud/n9e-helm.git
```

### 配置chart
以下配置项也可以在安装时通过 `--set`传入 或者 直接编辑 `values.yaml` 

#### 配置暴露夜莺服务的方式

- **Ingress**: k8s集群中必须已经安装了ingress controller
- **ClusterIP**: 通过 cluster ip暴露服务。 此选项只能在集群内访问服务。
- **NodePort**: 通过 Node Port 方式暴露服务。 这样可以通过`NodeIP:NodePort` 访问夜莺服务。
- **LoadBalancer**: 通过云提供商的负载均衡器，将服务暴露到集群外。

#### 配置external URL

夜莺web服务的external URL主要用于集群内外部访问夜莺服务

格式: `protocol://domain[:port]`。 通常:

- 如果通过 `Ingress` 暴露服务, `domain` 值应该配置为 `expose.ingress.hosts.web`
- 如果通过 `ClusterIP` 暴露服务, `domain` 值应该配置为 `expose.clusterIP.name`
- 如果通过 `NodePort` 暴露服务, `domain` 值应该配置为 k8s 集群内node的IP 
- 如果通过 `LoadBalancer` 暴露服务, `domain` 值应该配置为从云提供商那里获取到的域名的CNAME(自有域名作为提供商域名的cname)

如果夜莺部署在proxy之后，那设置为proxy的URL

#### 配置持久化存储

- **Disable**: 关闭持久存储，pod生命周期结束后，数据消失。
- **Persistent Volume Claim(default)**:  需要设置`StorageClass`以便k8s提供动态卷支持。 如果已有持久卷, 就设置 `existingClaim`


### 安装chart

使用 `nightingale` 名称安装:
```bash
helm install nightingale ./n9e-helm -n n9e --create-namespace
```

## 卸载

卸载/删除 `nightingale`:
```
helm uninstall  nightingale -n n9e
```

## 参与贡献
- 请首先在[issue列表](https://github.com/flashcatcloud/n9e-helm/issues)中创建一个issue
- 如有必要, 请联系项目维护者/负责人进一步讨论
- 请遵循[chart 模板开发规范](https://helm.sh/zh/docs/chart_template_guide/)