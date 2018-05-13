---
title: 使用Consul，Bind和Nginx实现服务端服务发现
date: 2017-11-18 19:35:13
tags:
    - Consul
    - 服务发现
---

在微服务架构实践中，一个难点是服务发现。每一个服务采用分布式部署，保证了拓展性和容错性，但带来了一个难点是如何监控这些服务，如何找到这些服务。

服务发现的种类有两种：客户端发现和服务端发现

**客服端发现**-客户端或者API网关查询注册中心获取服务的位置信息。支持服务注册的软件有`Etcd`，`Zookeeper`，`Consul`等
<!--more-->
![客户端发现](http://static.cyub.vip/images/201711/client_side_discovery.png)


**服务端发现**-客户端或API网关通过路由(比如负载均衡器)来代理到服务

![服务端发现](http://static.cyub.vip/images/201711/server_side_discovery.png)

本文将配置简单的服务端服务发现系统。其中涉及软件有：
1. Consul
    一个服务注册和配置共享的软件，支持服务健康检查，支持Dns和Http两种形式调用

2. Bind
   用于搭建本地Dns服务器，这里用来将service.local域名指向Nginx

3. Nginx
    Web服务器，作为负载均衡，代理到各个微服务

4. Consul-Template
   Consul的一个拓展工具，通过监听Consul中数据来动态修改一些配置数据。这里用来动态生成Nginx虚拟主机配置

架构图如下：
![服务端发现架构图](http://static.cyub.vip/images/201711/server-side-discovery-arch.png)

### Consul

配置两个微服务，地址都是本地地址，端口分别是4000和4300

{% codeblock 配置文档： lang:json https://www.consul.io/docs/agent/services.html#multiple-service-definitions Multiple Service Definitions %}
{
    "services":[
        {
            "id" : "1", // 服务id，唯一
            "name":"blog", // 服务名称
            "tags":["production","micro service"], // 服务的标签
            "address":"127.0.0.1", // 服务地址
            "port":4000, // 服务端口
            "checks":[ // 检查服务状态配置
                {
                    "http":"http://localhost:4000/",
                    "interval":"10s"
                }
            ]
        },
        {
            "id" : "2",
            "name":"blog",
            "tags":["production","micro service"],
            "address":"127.0.0.1",
            "port":4300,
            "checks":[
                {
                    "http":"http://localhost:4300/",
                    "interval":"10s"
                }
            ]
        }
    ]
}
{% endcodeblock %}

启动Consul
```shell
consul agent -server -bootstrap-expect 1 -bind=10.211.55.3  -data-dir /tmp/consul -node=centos1 -config-dir /etc/consul.d  -client 0.0.0.0 -ui
```

consul ui界面地址：http://localhost:8500
![Consul UI](http://static.cyub.vip/images/201711/consul-ui.jpg)

## Bind

编辑`/etc/named.rfc1912.zones`，添加:
```
zone "service.local" IN {
    type master;
    file "service.local.zone";
    allow-update { none; };
};
```

在`/var/named`目录下添加`service.local.zone`文件 
内容如下：
```
$TTL 1D
@   IN SOA  service.local.  admin.com. (
                    0   ; serial
                    1D  ; refresh
                    1H  ; retry
                    1W  ; expire
                    3H )    ; minimum
    NS  ns.service.local.
ns  IN A 127.0.0.1
blog IN A 127.0.0.1
```

启动Dns服务器
```
/usr/sbin/named -u named -c /etc/named.conf
```

通过命令`dig @localhost blog.service.local`查看其A记录地址是否指向了本地

## Consul-Template

添加模板配置文件`/etc/consul-template/nginx.ctmpl`
内容如下：
```
{{range services}}
{{ if .Tags | contains "production"}}
{{ if .Tags | contains "micro service"}}
upstream {{.Name}}_gw {
    ip_hash;
    {{range service .Name}}
    server {{.Address}}:{{.Port}};
    {{else}}server 127.0.0.1:11111;
    {{end}}
    keepalive 64;
}
server {
    listen 80;
    server_name {{.Name}}.dev;
    location / {
        client_max_body_size    0;
        proxy_connect_timeout 300s;
        proxy_send_timeout   900;
        proxy_read_timeout   900;
        proxy_buffer_size    32k;
        proxy_buffers      32k;
        proxy_busy_buffers_size 64k;
        proxy_redirect     off;
        proxy_hide_header  Vary;
        proxy_set_header   Accept-Encoding '';
        proxy_set_header   Host   $host;
        proxy_set_header   Referer $http_referer;
        proxy_set_header   Cookie $http_cookie;
        proxy_set_header   X-Real-IP  $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   Host $host;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_headers_hash_max_size 51200;
        proxy_headers_hash_bucket_size 6400;
        proxy_pass          http://{{.Name}}_gw;
    }
}
{{ end }}
{{ end }}
{{ end }}
```

启动Consul-Template之后，查看`/usr/local/nginx/conf.d/micro_services.conf`是否生成成功
```
consul-template -template /etc/consul-template/nginx.ctmpl:/usr/local/nginx/conf.d/micro_services.conf:"/usr/local/nginx/sbin/nginx -s reload"
```













