---
title: CentOS下安装Redis以及主从复制测试
date: 2016-10-20 18:08:44
tags:
    - Redis
    - Redis主从复制
    - Redis系统服务
    - Systemd
---
Redis是一个高性能的key-value数据库，它支持丰富的数据类型，包括字符串(String), 哈希(Hash), 列表(list), 集合(sets)和有序集合(sorted sets)。本文将从源码安装Redis并配置成系统服务，最后进行主从复制测试，这个流程展开

# 1. 下载Redis并解压
Redis最新稳定版本是4.0

```
wget http://download.redis.io/releases/redis-4.0.2.tar.gz
tar -xzvf redis-4.0.2.tar.gz
```
<!--more-->
# 2. 编译安装
切换至Redis源码目录，执行`make`命令编译和安装

```
cd redis-4.0.2
yum install tcl // redis依赖tcl
make && make install
```

安装完成之后，我们会在`/usr/local/bin`目录下看见Redis相关的程序：

```
ls -al /usr/local/bin | grep -i redis
```

| 程序名 | 作用 | 常用用法 |
| :------ | :------ | :------ |
| redis-server | redis服务端 | redis-server /etc/redis.conf |
| redis-cli | redis客户端 |  redis-cli -h host -p port [command]  |
| redis-benchmark | redis基准测试工具 | redis-benchmark -h host -p port -c 并发数 -n 请求数   |
| redis-check-aof | 修复AOF文件工具 | -- |
| redis-check-rdb | 修复dump.rdb工具 | -- |
| redis-sentinel | 集群管理工具 | -- | 

编译安装成功后，我们来配置Redis服务端，并启动它。首先将源码的里面的redis.conf拷贝到/etc目录下，然后编辑`vi /etc/redis.conf`， 关键几项配置如下:

```
# /etc/redis.conf
pidfile "/var/run/redis/redis.pid" // 设置redis进程pid文件

logfile "/var/log/redis/redis.log" // 设置redis日志文件

dbfilename redis.rdb  // 设置redis数据文件

dir /usr/local/redis // 设置redis程序目录，redis数据文件以及cluster的nodes.conf文件存放目录

daemonize yes // yes表示redis以守护进程形式运行
```

配置修改完成之后，运行命令`/usr/local/bin/redis-server /etc/redis.conf`来启动redis服务。

redis后台服务启动后，我们就可以`/usr/local/bin/redis-cli -p`进入redis客户端交互界面，进行相关redis操作了

# 3. 将Redis配置成系统服务

这里如何将Redis配置成Systemd服务，然后通过systemctl来管理redis。

创建redis服务文件`vi /usr/lib/systemd/system/redis.service`，写入以下内容
```
# /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
User=redis // 设置启动redis进程的用户名
Group=redis // 设置启动redis进程的用户组名
Type=forking
PIDFile=/var/run/redis/redis.pid // 必须与/etc/redis.conf里面pidfile保持一致
ExecStart=/usr/local/bin/redis-server /etc/redis.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
**注意上面User配置，需要保证该用户有redis.conf配置里面pidfile，dir对应的读写权限**。**Tips**：Systemd service如何编写，可参见[openSUSE:How to write a systemd service](https://zh.opensuse.org/openSUSE:How_to_write_a_systemd_service)

redis服务配置文件弄好之后，重启systemd服务

```
systemctl daemon-reload
```

至此，我们可以通过systemctl管理redis服务了

```
systemctl start redis // 启动redis服务
systemctl stop redis // 关闭redis服务
systemctl status redis -l // 查看redis服务状态
```

# 4. Redis主从复制测试

Redis支持主从同步，可以从主服务器向任意数量的从服务器同步数据，而从服务器之下可以继续关联其他从服务器，进而组成Redis服务器级联架构。**Redis不支持主主同步**，这就意味着我们不能同时向多台Master服务器写数据时候，通过他们之间相互同步来保证数据一致性。

Redis主从复制，一台主库可以拥有多个从库，但一个从库只能隶属于一个主库。通过主从复制，实现**读写分离**，**提高了系统的负载能力**。由于数据同步到其他从库，如果主库发生单点故障，可以快速到从库进行修复。

下面我们将测试主从复制。这里将测试一主一从，即一台Redis服务器（192.168.0.103）作为主库, 另外一台（10.211.55.3）作为从库的情况。配置Redis主从复制非常简单，只需要从库的redis配置文件中加上如下命令即可，主库不需要修改任何配置：

```
slaveof 主服务器地址  主服务器端口
masterauth 主服务器密码 // 如果主服务器设置了密码，才需设置这项
```

### 实验1. 主从复制

```
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 get k1
(nil)
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 get k1
(nil)
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 set k1 hello
OK
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 get k1
"hello"
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 get k1
"hello"
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 info replication | grep -A 3 'Replication'
# Replication
role:master
connected_slaves:1
slave0:ip=192.168.0.103,port=6379,state=online,offset=1068,lag=1
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 info replication | grep -A 3 'Replication'
# Replication
role:slave
master_host:192.168.0.103
master_port:6379
```

通过实验1.我们可以看到主服务器的数据同步到从服务器上面了。`info replication`命令可以查看服务器类型(master还是slave)，主从关系信息（master_host或slave信息)

### 实验2. 将从服务器动态设置成主服务器，主服务器保持不变

```
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 SLAVEOF NO ONE
OK
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 set k1 123
OK
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 set  k1 456
OK
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 get k1
"123"
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 get k1
"456"
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 info replication | grep -A 3 'Replication'
# Replication
role:master
connected_slaves:0
master_repl_offset:2204
[tinker@centos-linux ~]$ redis-cli -h 10.211.55.3 -p 6379  -a 123 info replication | grep -A 3 'Replication'
# Replication
role:master
connected_slaves:0
master_replid:c627111a1d7734a1f796b63ed715e06d39a3357f
```

通过实验2.我们使用命令`SLAVEOF NO ONE`将从服务器改变通过主服务器（从服务器配置文件里面的主从配置没有改变）。原先主从服务器之间不会再同步数据了。

### 实验3. 主从关系互换

```
[tinker@centos-linux ~]$ redis-cli -h 192.168.0.103 -p 6379 -a 123 SLAVEOF 10.211.55.3 6379
```

在实验2的基础知识上，通过实验3.我们使用命令`SLAVEOF 10.211.55.3 6379`将原先的主服务器设置成原先的从服务器的从服务器，实现主从关系互换。

**注意: **如果非本地连接redis服务器，需要配置redis设置绑定ip，允许特定ip才能访问

```
# 10.211.55.3 /etc/redis.conf
bind 192.168.0.103
```

或者设置redis密码

```
# 10.211.55.3 /etc/redis.conf
requirepass 123
```





