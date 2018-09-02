title: SSH使用代理连接
tags:
  - SSH
  - 代理
date: 2018-08-28 21:42:17
---
使用ssh连接服务器，有时候我们需要使用代理来连接目标服务器。这时候有两个方法可以达到这个目的：
1. 使用ssh的ProxyCommand选项
2. 配置xshell代理

# 1. 配置ProxyCommand选项

ssh可以通过使用`ProxyCommand`设置代理
```js
ssh root@192.168.33.10 -o "ProxyCommand=nc -X connect -x 127.0.0.1:10080 %h %p"
```
其中`192.168.33.10`是目的服务器ip，`%h`表示目标地址即`192.168.33.10`，`%p`表示目标地址端口,默认`22`
<!--more-->
`ProxyCommand`本质上使用的是`nc`这个命令来设置代理。下面使用代理服务10.2.3.4的8080来访问目标服务host.example.com的80端口
```
nc -x10.2.3.4:8080 -Xconnect host.example.com 80
```


我们可以把上面配置写在`~/.ssh/config`文件中，那么每次`ssh`连接服务器时候，都会使用`config`配置中的代理:
```
Host 192.168.33.10
    ProxyCommand    nc -X connect -x 127.0.0.1:10080 %h %p
```

然后使用下面命令连接服务器
```
ssh root@192.168.33.10
```

最后我们在目标服务器运行`last`命令来检查代理连接是否OK。

# 2. 使用xshell配置代理

[xshell](https://www.netsarang.com/download/free_license.html)是一个很好用的`ssh客户端`。它支持代理连接。如果我们使用`xshell`来连接服务器，那么就可以设置【连接->代理】来使用代理

![xshell使用代理](http://static.cyub.vip/images/201808/xshell_proxy_setting.jpg)
