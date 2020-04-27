title: 使用Consul作为配置中心的一种解决方案
author: tinker
tags:
  - Consul
  - 配置中心
categories: []
date: 2020-04-26 23:05:00
---
最近上线了go语言写的一个接口服务，由于接口服务是分布式部署的，服务的配置就需要使用分布式配置中心来管理。在调研了其他配置中心工具方案后，最终采用了Consul作为配置工具。一方面其学习成本较低，二来Consul本身作为服务注册和发现工具，可以一次学习多次适用。

<!--more-->

Consul是go语言实现的服务注册与发现工具，支持多数据中心多节点部署，支持键值存储。Consul作为配置中心就是基于键值存储来是实现的。通过对Key的设计，配置中心支持应用和环境环两个维度来支持不同应用或同一应用不同环境配置的管理。每个应用不同环境的Key格式为`{application_name}/{application_env}/config`，比如应用app1的开发环境的配置，配置key是`app1/dev/config`。

配置中心的一个重要功能是当配置更新，需要及时通知客户端。Consul不支持主动通知客户端，需要客户端实现Watch功能，来监察配置Key内容的变化。除了通过客户端代码来实现Watch功能，我们可以使用consul的配置工具consul-template来监察配置变化，并进行相关响应操作。

在实际go接口项目中，并未通过客户端代码实现监听配置变化，动态应用配置功能。主要是因为更改的配置可能是redis,mysql等连接配置，这就需要重置旧的连接池，并根据新的配置建立新的连接配置池，代码工作量大。最终采用consul-tempalte来监听配置变化，若变化，则使用supervisor重启该应用(go应用使用supervisor管理的）。其中consul-template管理的模板文件内容：

```
{{ tree "app1/dev/config" | explode | toYAML }}
```

consul-template启动命令：

```
consul-template --template \
    /home/vagrant/app.config.tpl:/home/vagrant/app.config.yaml
```