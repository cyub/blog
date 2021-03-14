title: 服务网格和API网关在微服务架构中的作用
author: tinker
tags:
  - 服务网格
  - API网格
  - 东西流量
  - 南北流量
categories:
  - 翻译
date: 2021-03-13 18:42:00
---
![](https://static.cyub.vip/images/202103/service_mesh.png)

如果你对微服务感兴趣，那么你可能多次听说过这两个术语。人们常常把这两者混为一谈。在本文中，我将详细讨论服务网格和API网关，并讨论何时使用什么。

<!--more-->

## 网络协议复习回顾


在深入研究服务网格和API网关之前，让我们先回顾复习一下网络层。下面是OSI的网络层模型:

![](https://static.cyub.vip/images/202103/osi_l7.png)

之所以进行网络协议复习的原因是我们将在下一节中讨论中使用到这些OSI网络层。

## 服务网格


**服务网格（Service Mesh）是一种在分布式软件系统中管理服务对服务（service-to-service）通信的技术**。服务网格管理东西向类型的网络通信（East-west traffic）。东西向流量表示数据中心、Kubernetes集群或分布式系统内部的流量。

服务网格由两个重要组件组成：

- 控制层(Control plane)
- 数据层(Data plane)

驻留在应用程序旁边的代理称为数据层，而协调代理行为的管理组件称为控制层。

![](https://static.cyub.vip/images/202103/service_mesh_arch.png)

服务网格允许你将应用程序的业务逻辑从网络、可靠性、安全性和可观察性中分离出来。

### 网络和流量管理

服务网格可以进行服务动态发现（service discovery）。边车代理(Sidecar proxy)可以支持负载均衡和限流，它也可以帮助你进行流量拆分，执行A/B测试，这对于金丝雀发布很有帮助。

### 可观察性和可靠性

服务网格支持分布式跟踪，这可以帮助你进行高级监控(比如请求数量、成功率和响应延迟)和调试。它甚至能够利用服务对服务的通信来更好地理解通信。

由于服务网格提供了健康检查，重试，超时和熔断功能，因此它可以提高应用程序的基线可靠性(baseline reliability)。

### 安全性

服务网格允许服务之间相互使用TLS进行通信，这有助于提高服务对服务通信的安全性。还可以实现acl(access-control list)作为安全策略。

一个真正的服务网格以及边车代理能够支持广泛的服务，并且能够实现对L4和L7层的流量控制。


市场上有许多可用的服务网格。以下是其中的一些：

- [Istio](https://istio.io/)
- [Linkerd](https://linkerd.io/)
- [Kuma](https://kuma.io/)
- [Consul](https://www.consul.io/)

## API 网关

API网关一般是群集，数据中心或一组分布式服务的单个入口点。在网络拓扑中，通常被称为南北向流量。移动客户端属于这种类型的网络流量。

**API网关充当进入集群、数据中心或一组分布式服务的单一入口点。在网络拓扑结构中，它通常被称为南北通信**。通常，移动客户端属于这种类型的网络流量。

人们很有可能最终使用API网关在部署在同一数据中心的两个产品之间进行通信。在这种情况下，流量类型可以是东西向。

API网关接收来自客户端的调用请求，并将其路由到适当的服务。与此同时它也可以进行协议转换。

![](https://static.cyub.vip/images/202103/api_gateway.png)

使用API网关有多种好处：

- 抽象化

	API网关可以抽象出底层微服务的复杂性，并为客户端创建统一的体验
    
- 身份认证

	API网关可以负责身份验证，并将令牌信息传递给服务
    
- 流量控制

	API网关可以限制入站和出站流量
    
- 监控与赢利

	如果你计划将API货币化，API网关可以通过提供监控客户端API请求/响应的功能来帮助你做到这一点

- 协议转换

	API网关可以帮助你转换API请求/响应。它还可以进行协议转换。
    
API网关通常只关注L7策略。

### API网关类型

API网关的类型有以下两种：

从部署的角度来看，API网关有两种使用方式：

- 内部API网关（Internal API gateway）

	充当一组服务的网关或产品范围的网关
    
- 边缘API网关（Edge API gateway）

	充当外部组织的消费者或移动客户端的网关
    
市场上有许多可用的API网关。以下是其中的一些：
 
- [Apigee](https://cloud.google.com/apigee)
- [Kong Gateway](https://konghq.com/kong/)
- [NGINX’s API gateway](https://www.nginx.com/solutions/api-management-gateway/)
- [Software AG’s API gateway](https://www.softwareag.com/en_corporate/platform/integration-apis/api-management.html)


## 什么时候用什么

既然你已经知道了什么是服务网格和API网关，那么让我们尝试理解什么时候使用什么。

### 何时使用服务网格


- 当你需要在同一产品范围内实现L4/L7层服务通信与安全监控时
- 当你可以为每个服务实例及其副本部署sidecar代理时
- 当服务可以通过共享相同的CA证书以建立安全通信时

### 何时使用API网关

- 当你需要实现L7层服务通信与跨各种产品的安全性和监视时
- 当你想要将API作为一种产品来呈现时
- 当你想为开发人员提供API全生命周期管理时
- 当你需要转换服务通信协议时

## 服务网格和API网关共存

服务网格和API网关很有可能共存。下图展示了服务网格和API网关共存的场景：

![](https://static.cyub.vip/images/202103/service_mesh_api_gateway.png)

通过上面图表我们可以知道，在一个产品范围内，你可以实现一个服务网格(东西流量east-west traffic)。当需要跨产品通信时，可以使用内部API网关(东西流量east-west traffic)。当处于边缘的客户端需要与服务通信时，可以使用边缘API网关(南北流量east-west traffic)。

## 原文信息

- 原文地址：[The Roles of Service Mesh and API Gateways in Microservice Architecture](https://betterprogramming.pub/the-roles-of-service-mesh-and-api-gateways-in-microservice-architecture-f6e7dfd61043)
