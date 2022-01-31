title: k8s环境下部署grpc的几种方案
author: tinker
tags:
  - grpc
  - k8s
categories: []
date: 2021-11-09 17:23:00
---
笔者前段时间负责所在广告部门的ssp系统核心的几个grpc服务由虚拟机部署迁移到k8s环境下的技术方案设计与实施。本篇博文就专门介绍下k8s环境的部署grpc几个方案。这里面不涉及具体实施细节。我们k8s环境是采用华为云的k8s集群服务，我们ssp系统都是go语言开发的，这里面的grpc专指grpc-go。

容器是微服务的基石，可以做到每个服务快速autoscale，但随之带来的是服务的消亡是任意不定的，服务如何能够被调用方找到的难题。为了解决这个问题，就需要系统支持服务的注册和服务的发现。对于grpc来说，就是服务提供者grpc server会部署到多个k8s的Pod上，Pod的创建和消亡是任意时刻，不可预测，那就需要有一套机制能够发现grpc server所有Pod的端点信息，保证调用方(grpc client)能够及时准确获取服务提供方信息。所以grpc部署在k8s的方案也必要解决服务的注册和服务的发现。

此外调用方(grpc client)会维持grpc长连接，以及grpc底层使用http/2协议，负载均衡不同与http和tcp，这一点在设计方案时候，也需要特别关注。

## k8s service直连

[K8s service](https://kubernetes.io/docs/concepts/services-networking/service/)是一个命名负载均衡器，它可以将流量代理到一个或多个Pod。grpc-go可以通过拨号直连到service，让service进行服务发现和负载均衡处理。

![](https://static.cyub.vip/images/202111/passthrough-service.png)

k8s service直连方案部署和开发简单，Pod扩容和缩容都可以及时感知。但是由于service负载均衡工作在4层，无法识别7层的http/2协议，会导致负载均衡不均匀的问题。

## k8s headless service

k8s service支持[headless模式](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)，创建service时，设置clusterip=none时，k8s将不再为servcie分配clusterip，即开启headless模式。headless service会将对应的每个 Pod IP 以 A 记录的形式存储。通过dsn lookup访问headless service时候，可以获取到所有Pod的IP信息。

![](https://static.cyub.vip/images/202111/k8s-headless-service.png)

如上图所示，基于k8s headless service方案，需要做下面两个步骤：

1. grpc client需要通过dns查询headless service，获取所有Pod的IP
  
2. 获取所有Pod IP后，grpc client需要实现客户端负载均衡，将请求均衡到所有Pod
  

对于步骤1，grpc-go原生支持dns解析，只需在服务名称前面加上`dns://`，grpc-go内置dsn resover会解析该headless service的A记录，得到所有pod地址。

```go
conn, err := grpc.DialContext(ctx, "dns:///"+headlessSvc+":8080",
    grpc.WithInsecure(),
)
```

对于步骤2，go-grpc原生支持多种负载均衡策略，通过设置rr策略，可以保证后端grpc负载的均衡：

```go
grpc.WithDefaultServiceConfig(`{"loadBalancingPolicy":"round_robin"}`)
```

由于grpc具有探活机制，Pod消亡之后，会自动把其摘除。Pod扩容之后，由DNS查询缓存的原因，新加入Pod会等待一定时候才能加入grpc长连接池中。

需要注意的grpc-go内置dns resolver默认解析缓存时间[30分钟](https://github.com/grpc/grpc-go/blob/v1.24.x/resolver/dns/dns_resolver.go#L47)，这意味着新加入的节点需要在30分钟后才会生效

## 基于Etcd/consul 等外部服务注册中心

etcd/consul等支持服务注册和发现的组件，可以运用在grpc-go部署在k8s环境方案中。架构图如下图所示：

![](https://static.cyub.vip/images/202111/etcd-service.png)

从上图可以看到分为三个阶段：

- **注册阶段**
  
  当svc B的grpc server的Pod启动时候，将其信息注册到etcd中
  
- **监听阶段**
  
  这阶段是发现阶段。当svc A的grpc client的Pod启动后，第一次会去etcd中查询获取svc B的所有Pod端点信息，获取到svc B的节点信息后缓存起来，一方面避免每次都去查询etcd，能够提升性能，另一方面防止etcd发生故障，导致查询不到任何节点信息。此外为了能够及时获取svc A需要支持监听etcd的功能，及时获取到svc B节点的变动信息，比如新加入的Pod节点或者消亡的Pod节点，并更新缓存
  
- **负载均衡阶段**
  
  当svc A的grpc client获取到svc B中所有的Pod地址信息之后，可以采用内置的`round_robin`负载均衡策略进行负载均衡
  

## k8s endpoints

k8s提供了Endpoints API可以查询service下面的所有Pod信息。k8s Endpoints底层使用etcd存储的，当Pod创建时候，会将信息写入到Endpoints中，当Pod消亡时候会将其摘掉。该方案同etcd外部方案类似，只不过其服务端点信息是从k8s集群中查询，避免维护etcd集群。

![](https://static.cyub.vip/images/202111/k8s-endponts-service.png)

## 进一步阅读

- [grpc-go issue: Allow configuration of dns resolution polling interval](https://github.com/grpc/grpc-go/issues/3170)
  
- [grpc-go issue: Need more intelligent re-resolution of names](https://github.com/grpc/grpc/issues/12295)