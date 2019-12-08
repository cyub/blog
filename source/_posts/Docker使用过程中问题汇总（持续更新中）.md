title: Docker使用过程中问题汇总（持续更新中）
tags:
  - Docker
  - 问题汇总
categories: []
date: 2018-12-06 22:21:00
---
下面是我在在使用docker过程中遇到的一些问题以及解答，现记录下来备查。

## 1. 为什么有很多`<none>:</none>`镜像，有的删除不掉，有些却删除不掉？
 
我们执行命令`docker images -a`有时候会发现不少<none>:</none>镜像，使用`docker rmi image_name`删除这些none镜像时候，有时候能够成功，有时候却不能成功。这究竟为什么？

我们知道镜像是分层的，上面一层依赖下一层，下一层是上一次的父镜像层。就像下面这样：

![](http://static.cyub.vip/images/201812/docker-image-layer.png)

我们可以通过`docker inspect`查看镜像ID 和父层镜像ID
<!-- more-->

![](http://static.cyub.vip/images/201812/docker-inspect.jpg)

上图中镜像ip-scout的ID是`28ee11309524`，它的父镜像层ID是`a8e836f776fa`, 接着我们看看上图父镜像层信息：

![](http://static.cyub.vip/images/201812/docker-parent-layer.jpg)

我们发现ip-scout镜像的父镜像层就是<none>:<none>，这就是一部分<none>:</none>镜像的来源--在`docker build`或`docker pull`过程中产生的中间层镜像，这些none镜像是无法删除的。最上层镜像由于我们命名了所以不再是你none,就好比`28ee11309524`的名称就是`ip-scout:latest`

我们可以通过`docker history`查看所有层：

![](http://static.cyub.vip/images/201812/docker-history.jpg)

<none>:</none>另一个来源是悬空镜像(dangling)，这种一般发生在build或者pull过程。其中一个情况就是重新构建镜像时候，如果依赖的父镜像已经更新了，我们新构建的新镜像指向了新的父镜像，而我们之前构建的镜像指向的还是旧的父镜像，那么之前镜像就变成`untagged`和`dangling`，这类镜像占用空间，可以使用下面命令进行删除的：

```bash
docker rmi $(docker images -f "dangling=true" -q)
```

## 如何删除已退出的容器的镜像?

我们可以使用下面命令
```bash
docker stop $(docker ps -a | grep "Exited" | awk '{print $1 }')
docker rm $(docker ps -a | grep "Exited" | awk '{print $1 }') 
```


## 如何查看容器完整ID?

我们使用docker ps命令查看到的容器ID是短ID，我们可以使用以下命令查看完整ID:

```bash
docker inspect --format="{{.Id}}" container_name
```

## 如何查看容器运行的命令？

有时候我们忘记当时是怎么运行容器的，可以通过以下命令查看：

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock  assaflavie/runlike container_id
```


## docker stack不支持加载.env文件，怎么解决？

`docker compose`支持.env文件来设置环境变量，但是docker swarm集群部署模式下不支持.env环境，有时候我们确实很需要，可以这样：

```bash
 export $(cat .env) && docker stack deploy -c docker-stack.yml web
```

## 生成环境怎么使用docker部署nodejs应用？

生产推荐使用[pm2](http://pm2.keymetrics.io/docs/usage/docker-pm2-nodejs/)部署nodejs应用，支持自动重启，集群部署。

下面是构建nodejs应用镜像Dockerfile
```
FROM node
WORKDIR /app
COPY . /app
RUN npm install pm2 -g
RUN npm install --only=production
EXPOSE 8989
CMD ["pm2-runtime", "/app/server.js", "--name", "your-app-name"]
```

后续步骤略

## docker swarm模式下使用traefik做负载均衡时候无法获取到客户端IP?

问题原因是docker swarm模式本身问题[moby/moby#25526](https://github.com/moby/moby/issues/25526)。

通过配置traefik服务对外暴露端口可以解决此问题：
```
traefik:
    image: traefik
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
      - target: 443
        published: 443
        protocol: tcp
        mode: host
      - target: 8080
        published: 8080
        protocol: tcp
        mode: host
```

## docker swarm模式下一个容器有多个端口，使用traefik做复制该如何配置？

我们可以配置traefik的段标签(segment labels)来解决此问题，格式如下:

```
traefik.<segment_name>.backend=BACKEND
traefik.<segment_name>.port=PORT
traefik.<segment_name>.domain=DOMAIN
traefik.<segment_name>.frontend.auth.basic=EXPR
```

更多查看[traefik On containers with Multiple Ports (segment labels)](https://docs.traefik.io/configuration/backends/docker/#on-containers-with-multiple-ports-segment-labels)

## 当我们构建nodejs应用镜像，全局安装某依赖时候，有时候出现权限拒绝该怎么解决？

我们一般使用官方镜像作为父镜像构建我们应用的镜像，有时候在运行`npm install xxx -g`命令时候会提示类似如下的权限问题：

```
{ Error: EACCES: permission denied xxxx }
```

这是由于镜像默认用户是root，我们全局安装某些依赖时候，限制使用root安装。这时候可以更改镜像用户和依赖安装目录：

```
USER node
RUN mkdir /home/node/.npm-global && mkdir /home/node/app
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin
```

## docker部署mysql时候，日志目录不可写问题？

使用docker-compose进行编排：
```
# docker-compose.yml
version: '3.3'

services:
   mysql-master:
     image: mysql:5.7
     container_name: mysql-master
     restart: always
     ports:
       - "3306:3306"
     environment:
      - "MYSQL_ROOT_PASSWORD=123456"
     volumes:
       - /opt/mysql-master-slave/data/master:/var/lib/mysql # data目录
       - /opt/mysql-master-slave/log/master:/var/log/mysql # 日志目录
       - /opt/mysql-master-slave/mysqld-master.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf # 配置
```

容器启动时候，提示日志目录写入失败：

```
sudo chown 999:999 /opt/mysql-master-slave/log/master
```

附：[Nodejs应用dockerize最佳时间](https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md#global-npm-dependencies)