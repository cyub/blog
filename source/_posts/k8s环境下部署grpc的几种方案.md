title: k8s环境下部署grpc的几种方案
author: tinker
tags:
  - grpc
  - k8s
categories: []
date: 2021-11-09 17:23:00
---
# k8s环境下部署grpc方案

笔者前段时间负责所在广告部门的ssp系统核心的几个grpc服务由虚拟机部署迁移到k8s环境下的技术方案设计与实施。本篇博文就专门介绍下k8s环境的部署grpc几个方案。这里面不涉及具体实施细节。我们k8s环境是采用华为云的k8s集群服务，我们ssp系统都是go语言开发的，这里面的grpc专指grpc-go。

容器是微服务的基石，可以做到每个服务快速autoscale，但随之带来的是服务的消亡是任意不定的，服务如何能够被调用方找到的难题。为了解决这个问题，就需要系统支持服务的注册和服务的发现。对于grpc来说，就是服务提供者grpc server会部署到多个k8s的Pod上，Pod的创建和消亡是任意时刻，不可预测，那就需要有一套机制能够发现grpc server所有Pod的端点信息，保证调用方(grpc client)能够及时准确获取服务提供方信息。所以grpc部署在k8s的方案也必要解决服务的注册和服务的发现。

此外调用方(grpc client)会维持grpc长连接，以及grpc底层使用HTTP/2协议，负载均衡不同与http和tcp，这一点在设计方案时候，也需要特别关注。

## k8s service直连

[K8s service](https://kubernetes.io/docs/concepts/services-networking/service/)是一个命名负载均衡器，它可以将流量代理到一个或多个Pod（这里面的service指的是`ClusterIP`类型的service)。grpc-go可以通过拨号直连到service，让service进行服务发现和负载均衡处理。

![](https://static.cyub.vip/images/202111/passthrough-service.png)

k8s service直连方案部署和开发简单，Pod扩容和缩容都可以及时感知。但是由于service负载均衡工作在4层，无法识别7层的HTTP/2协议，会导致负载均衡不均匀的问题。
<!--more-->

为什么常规的4层负载均衡器无法对7层的HTTP/2协议进行负载均衡?

> gRPC uses the performance boosted [HTTP/2 protocol](https://developers.google.com/web/fundamentals/performance/http2/). One of the many ways HTTP/2 achieves lower latency than its predecessor is by leveraging a [single long-lived TCP connection](https://http2.github.io/faq/#why-just-one-tcp-connection) and to multiplex request/responses across it. This causes a problem for [layer 4](https://en.wikipedia.org/wiki/OSI_model#Layer_4:_Transport_Layer) (L4) load balancers as they operate at too low a level to be able to 
> make routing decisions based on the type of traffic received. As such, 
> an L4 load balancer, attempting to load balance HTTP/2 traffic, will 
> open a single TCP connection and route all successive traffic to that 
> same long-lived connection, in effect cancelling out the load balancing.

上面架构图中说明：svc A是grpc client应用，svc B是grpc server应用，svc A作为服务调用方会调用svc B的服务，图中只画出svc A的一个Pod调用svc B的服务的流程，其他Pod略去。

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
  

服务注册时候需要获取自身所在Pod的IP信息，我们可以把Pod相关信息设置成环境变量：

```yaml
env:
  - name: POD_NAME # pod name信息
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: POD_IP # pod ip信息
    valueFrom:
      fieldRef:
        fieldPath: status.podIP
```

如果使用etcd作为服务注册中心，其官方提供了grpc服务发现支持，具体可以查看官方文档[gRPC naming and discovery](https://etcd.io/docs/v3.5/dev-guide/grpc_naming/)。

## k8s endpoints

k8s提供了[Endpoints API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#read-endpoints-v1-core)可以查询service下面的所有Pod信息。k8s Endpoints底层使用etcd存储的，当Pod创建时候，会将信息写入到Endpoints中，当Pod消亡时候会将其摘掉。该方案同etcd外部方案类似，只不过其服务端点信息是从k8s集群中查询，避免维护etcd集群。我们可以使用[sercand/kuberesolver](https://github.com/sercand/kuberesolver)这个包，或者使用[go-zero](https://github.com/zeromicro/go-zero/tree/master/zrpc/resolver/internal/kube)框架，其里面内置k8s endpoints解析处理。

![](https://static.cyub.vip/images/202111/k8s-endpoints-service.png)

该方案需要我们在部署k8s时候，创建具有读取特定命名空间endpoints的service Account,并在Deployment配置文件指定该server Account。k8s部署可以参考[k8s endpoints API 模式](https://github.com/cyub/grpc-examples/tree/main/lb#k8s-endpoints-api-%E6%A8%A1%E5%BC%8F)。

## Envoy proxy

上面几种方案都属于客户端负载均衡，需要代码实现负载均衡功能，尽管grpc客户端[原生支持负载均衡](https://github.com/grpc/grpc/blob/master/doc/load-balancing.md)功能，但还是不建议使用客户端负载均衡，因为胖客户端缺乏弹性，需要大量自定义代码支持metric，日志记录等功能，且需要针对不同语言重复开发。

Envoy 是一款由 Lyft 开源的 L7 代理和通信总线，是 CNCF 旗下的开源项目，由 C++ 语言实现，通过Filter机制实现强大的定制化能力。我们可以使用Envoy(当然也可以使用其他支持HTTP/2协议的负载均衡组件)来进行集中式代理，服务调用方不必关心后端服务的部署情况，只需要和集中式代理器打交道即可。如下图所示就是k8s环境下使用envoy proxy的架构图：

![](https://static.cyub.vip/images/202111/envoy-proxy.png)

上面架构图中需要将envoy的服务发现类型设置为`STRICT_DNS`,并指向grpc server的headless service，具体k8s部署可以参考：[envoy proxy 模式](https://github.com/cyub/grpc-examples/tree/main/lb#envoy-proxy-%E6%A8%A1%E5%BC%8F)。服务调用方svc A通过clusterIP service转发连接到envoy，envoy做负载均衡，将流量最终流向svc B中Pod中。

此外我们还可以将envoy作为服务调用方的svc A的Pod的sidecar，每一个svv A的Pod内部部署两个容器，一个是grpc-client容器，一个是envoy容器，grpc-client直接与其同Pod内的envoy连接，这就是Envoy proxy as sidecar方案。

## Envoy proxy as sidecar

![](https://static.cyub.vip/images/202111/envoy-proxy-as-sidecar.png)

从上面架构图可以看到每一个调用方Pod中都一个envoy作为边车，流出流量会经过envoy代理。envoy的配置同上面Envoy proxy方案一样。具体k8s部署可以参考[envoy proxy as sidecar 模式](https://github.com/cyub/grpc-examples/tree/main/lb#envoy-proxy-as-sidecar-%E6%A8%A1%E5%BC%8F)。

## Service Mesh

服务网格（Service Mesh)跟上面的`Envoy proxy as sidecar`有点类似，在Service Mesh下，svc A和svc B 中所有Pod中都会有一个流量代理组件作为sidecar,它们构成了data plane，所有流入(ingress)/流出(egress)的流量都会经过sidecar。市场上常见的实现了Service Mesh的工具是istio和linkered。本方案采用istio实现service mesh。具体k8s部署可以参考[service mesh 模式](https://github.com/cyub/grpc-examples/tree/main/lb#service-mesh-%E6%A8%A1%E5%BC%8F)。

![](https://static.cyub.vip/images/202111/service-mesh-grpc.png)

## 总结

| 方案  | 负载均衡类型 | 优点  | 缺点  |
| --- | --- | --- | --- |
| k8s service直连 | Proxy Model | 部署和使用最简单 | 未实现HTTP/2协议的负载均衡 |
| 基于Etcd/consul 等外部服务注册中心 | Balancing-aware Client | 使用相对简单，服务信息方便查看 | 1. 需要维护Etcd等服务注册中心<br/>2.服务提供者需要实现注册机制，服务调用方需要实现发现机制 |
| k8s endpoints | Balancing-aware Client | 部署和使用相对简单 | 需要配置Pod支持serviceAccount，在权限要求很严系统中，比较麻烦 |
| Envoy proxy | Proxy Model | 部署和使用相对简单 | 由于需要走k8s service代理和envoy代理，性能相比有一定损失 |
| Envoy proxy as sidecar | External Load Balancing Service | 部署和使用相对简单，可以通过度量envoy指标，获取服务质量 | 部署相对复杂 |
| Service Mesh | External Load Balancing Service | 功能强大，支持熔断器，灰度发布等功能 | 部署相对复杂，链路长，有性能损耗，内部机制复杂，出问题定位难 |

上面表格中负载均衡类型的介绍，可以查看[gRPC服务发现&负载均衡](https://segmentfault.com/a/1190000008672912)，其中介绍到Proxy Model指的是集中式LB，Balancing-aware Client指的是进程内LB，External Load Balancing Service 是独立LB进程，一般就是sidecar代理。

## 进一步阅读

- [grpc-go issue: Allow configuration of dns resolution polling interval](https://github.com/grpc/grpc-go/issues/3170)
  
- [grpc-go issue: Need more intelligent re-resolution of names](https://github.com/grpc/grpc/issues/12295)
  
- [Using Envoy to Load Balance gRPC Traffic](https://www.bugsnag.com/blog/envoy)