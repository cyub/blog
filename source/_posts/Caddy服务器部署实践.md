---
title: Caddy服务器部署实践
date: 2017-03-12 11:03:08
tags:
---

Caddy是go语言编写的一款跨平台web服务器，支持window，linux，andorid等操作系统。

它配置简单易用，原生支持 HTTP/2，支持Markdown自动渲染，反向代理，FastCGI，自动创建 [Let’s Encrypt](https://letsencrypt.org/) 证书等特性，非常适合开发环境使用。更多特性可见[官方介绍](https://caddyserver.com/)
<!--more-->
本文会从以下几个方面简单介绍Caddy

1. 安装与运行

2. 常用配置

3. 线上部署

# 安装与运行
从Caddy官方选择所需要的功能模块后，下载一个含二进制的压缩包。下载解压后，切入目录。执行./caddy然后浏览器访问localhost:2015，页面出现提示404 Not Found，说明运行ok。

安装和运行就是这么简单!

# 常用配置

Caddy默认从当前目录下面的Caddyfile文件中读取配置。当然你也可在启动Caddy时候使用-conf选项指明配置文件
```javascript
./caddy -conf="path/to/Caddyfile"
```

Caddy配置都是由一系列指令构成，需要什么功能，就配置什么指令。下面列出几种常见情况的Caddyfile配置

### 单一站点

```javascript
localhost:2017
gzip // 使用gzip压缩
browse // 支持目录浏览
ext    .html // 文件拓展名html
log    /var/log/access.log // 日志存放
proxy  /api 127.0.0.1:4000 // 反向代理到服务
header /api Access-Control-Allow-Origin * // 自定义头，允许跨域
```

### 多个站点

```javascript
movie.yskankan.com.com:80 {
    gzip
    log /var/log/movie.yskankan.com.access.log
}

blog.yskankan.com:80 {
    gzip
    log /var/blog.yskankan.com.access.log
}
```

### Basic Auth 

```jascript
localhost {
    basicauth / admin 123456 // 账号admin 密码123456
}
 
```

### CORS
CORS(Cross-Origin Resource Sharing） 跨域资源共享是一种机制（或者说手段)让Web应用服务器能够支持跨站访问控制。从而使用安全地进行跨站数据传输成为可能，更多详细内容可见[MDN HTTP访问控制](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Access_control_CORS)

```javascript
cors / {
    origin            http://yskankan.com // 允许向服务器提交请求的URI
    methods           GET,POST,PUT,HEAD // 允许请求的方式
    allow_credentials false // 是否credentials校验
    max_age           3600 // 预请求校验结果有效期为3600秒
    allowed_headers   X-Custom-Header //指明一次请求中可以自定义的请求头，多个逗号隔开
    exposed_headers   X-My-Custom-Header // 允许浏览器访问的头,多个逗号隔开
}
```

### IP过滤

```javascript
ipfilter / {
    rule       block
    ip         192.168.0.0/16 2E80::20:F8FF:FE31:77CF/16 5.23.4.24
    blockpage  /local/data/default.html
}
```

### 反向代理

```javascript
http://www.yskankan.com {
    log /var/log/access.log
    proxy /movie localhost:4001
    proxy /blog localhost:4002
}
```

### 负载均衡

Caddy支持三种负载均衡算法：支持三种负载均衡算法：random（随机），least_conn（最少连接），round_robin(轮询调度)

```javascript
localhost {
    log /var/log/access.log

    proxy / localhost:4001 localhost:4002 {
        policy random
    }
    proxy /jobs localhost:4003 localhost:4004 {
        policy least_conn
    }
}
```

### FastCGI

FastCGI是CGI的升级，在服务开始后预先多启动个进程。caddy服务器，将用户的请求转发给实现FastCGI的服务，然后将服务响应的内容返回给用户。下面是配置PHP-CGI：
```javascript
localhost {
    fastcgi / 127.0.0.1:9000 php
    log /var/log/access.log
}
```
上面的`fastcig / 127.0.0.1:9000 php`意思是将所要请求转发9000端口的服务。其中php是一个preset（预配置集合），相当于：

ext   .php
split .php
index index.php

### 文件管理

caddy文件管理是caddy的一个拓展指令，需要在下载时候选择相应的模块
```
localhost {
    basicauth  /  admin  123456
    filemanager  / {
        show /user/share/nginx/html/documents
        allow_new true
        allow_edit true
        allow_commands false
        block dotfiles
    }
}

```

### git自动更新

```javascript
localhost {
    gzip
    git {
        repo  https://github.com/cyub/blog // 代码仓库地址
        path  /path/wwwroot/app/ // 代码拉取下来后存放路径
        interval 3600 // 每隔3600秒拉取一次
    }
}
```

### 一个复杂的例子
```javascript
http://www.yskankan.com {
        gzip
        log /var/log/access.log
        proxy /blogs http://127.0.0.1:4001, http://127.0.0.1:4002 {
            without /blogs
            header_upstream Host {host}
            header_upstream X-Real-IP {remote}
            header_upstream X-Forwarded-For {remote}
            header_upstream X-Forwarded-Proto {scheme}
        }
        errors { // 错误日志和自定义错误页面
            log /var/www/log/error.log {
                size 50   // 50M以后，自动分割
                age  30   // 文件最多保留30天
                keep 5    // 最多保留5个文件
            }
            404 /path/app/404.html
            500 /path/app/500.html
        }       
}
```

# 线上部署
可使用[PM2](http://pm2.keymetrics.io/)进行管理，或参见[这里](https://github.com/mholt/caddy/tree/master/dist/init)