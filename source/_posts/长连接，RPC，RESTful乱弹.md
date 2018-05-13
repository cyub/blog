---
title: 长连接，RPC，RESTful乱弹
date: 2017-12-07 23:03:07
tags:
---

今天学习到很多知识，混混沌沌的大脑有时候就得需要轻敲一下，才能醍醐灌顶。

之前的对技术思考深度不够，涉及到东西浮于表面，蜻蜓点水而过。对于注意到不寻常现象，往往没有分析它的本质，思考现象本身原因就放过了。比如今天学习到RPC和Restful一个区别是RPC支持长连接，这对我之前对RPC的了解停留在客户端调用是无感知，无差别更深入本质了。

# 长连接

长连接(HTTP persistent connection)指的是在一个连接上可以持续不断的发送多个数据包，在TCP连接保持期间，如果没有数据包发送，需 要双方发检测包以维持此连接。

在`keep-alive`机制出现之前，每次http请求都会打开一个tcp socket连接，请求完成之后就断开这个tcp连接。`keep-alive`机制，能够保持TCP连接不断开(不发RST包、不四次握手)，减少了tcp连接次数，提交了传输速率。但是长时间不释放tcp连接数，也会极大的造成资源浪费。实现成千上万人同时在线的话，也就得保持住同样数量的tcp连接数。`keep-alive`的timeout时间设置非常重要，能够及时的释放不需要的tcp连接。
<!--more-->

在web服务器上截获一次http请求，请求响应的内容是12345。客户端10.211.55.2

下面是抓包截图：
![tcpdump抓包截图](http://static.cyub.vip/images/201712/tcpdump-output.jpg)

头三行是3次握手过程，最后面6行是4次挥手过程(注意客户端和服务端相继发出挥手请求)。在html文件内容传输完成之后，tcp 连接并没有立即释放，而是等到服务器tcp timeout之后才释放。观察捕获过程中能够明显感觉到

**附注tcpdump Flags含义：**
>S  (SYN),  F(FIN), P (PUSH), R (RST), U (URG),W (ECN CWR), E (ECN-Echo) or `.(ACK), or none if no flags are set

# RPC
RPC是指远程过程调用，像调用本地的函数一样去调远程函数。RPC的主要功能目标是让构建分布式计算（应用）更容易，在提供强大的远程调用能力时不损失本地调用的语义简洁性。为实现该目标，RPC 框架需提供一种透明调用机制让使用者不必显式的区分本地调用和远程调用。

google推出的gRPC是基于HTTP/2协议，复用TCP连接。thrift是构建在TCP协议上的RPC协议。xml-rpc是构建在http协议上的

下面是python版本xml-rpc的服务端、客户端示例：

### 服务端
```python
# -*- coding: utf-8 -*-

from xmlrpc.server import SimpleXMLRPCServer
from xmlrpc.server import SimpleXMLRPCRequestHandler


class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2', )

class Handlers:
    def add(self, x, y):
        return x + y

    def mul(self, x, y):
        return x * y

    def pow(self, x, y):
        return pow(x, y)

# create server
server = SimpleXMLRPCServer(("localhost", 8000), RequestHandler)
server.register_instance(Handlers())
server.serve_forever()
```

### 客户端
```python
# -*- coding:utf-8 -*-

import xmlrpc.client

s = xmlrpc.client.ServerProxy('http://localhost:8000')
print(s.pow(2,4))
print(s.add(1,5))
print(s.mul(5, 5))
```

### 抓包命令
```bash
sudo tcpdump -i lo port 8000
```


# RESTful

RESTful架构，把一切看成资源，通过http verb来表明资源的操作类型。由于它是基于http,http属于无状态的协议，所以不适合状态的维护。不支持长连接，不支持callback

[谁能用通俗的语言解释一下什么是 RPC 框架？](https://www.zhihu.com/question/25536695)
[深入浅出 RPC-深入篇](http://blog.csdn.net/mindfloating/article/details/39474123)
[你应该知道的RPC原理](https://www.cnblogs.com/LBSer/p/4853234.html)

