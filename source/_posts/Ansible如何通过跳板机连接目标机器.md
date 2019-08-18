title: Ansible如何通过跳板机连接目标机器
tags:
  - Ansible
  - 配置管理
  - 自动化部署
categories: []
date: 2019-08-01 21:12:00
---
[Ansible](https://docs.ansible.com)是配置管理工具，能够自动化部署，管理服务器。在实际工作中，我会用ansible来进行项目依赖的服务部署，比如nginx服务器，redis等部署。

在生产环境下，多台服务器往往部署在一个局域网内，没有公网ip，也不会对外暴露端口，这就导致本地不能通过ssh直接连接生产服务器。它需要连接到跳板机后然后再进行生产服务器操作。通过跳板机操作一来更安全，二来可以更好的监控和权限控制，但如果想要本地使用ansible对服务器进行操作，就被限制住了。此时我们可以更改ssh配置进行处理，已达到本地机器"直接"连接远程生产机器的目的。

<!--more-->
假定我本地local的ip是`113.110.142.48`，跳板机bastion的ip是`192.255.235.63`，生产服务器prod1是`172.16.105.45`,prod2的ip是`172.16.105.46`，prod3的ip是`172.16.105.47`。连接的网络结构图是：

![ansible-bastion-ssh-connect](http://static.cyub.vip/images/201908/ansible-bastion-ssh-connect.jpg)


修改本地机器ssh的配置文件`~/.ssh/config`, 加入以下内容：

```js
Host bastion
    HostName 192.255.235.63
    BatchMode yes
    User ubuntu
Host prod1
    HostName 172.16.105.45
    ServerAliveInterval 60
    TCPKeepAlive        yes
    IdentityFile ~/.ssh/keys/bastion_id_rsa
    ProxyCommand ssh bastion 'nc -w 14400 %h %p'
    User ubuntu
    Port 22
Host prod2
    HostName 172.16.105.46
    ServerAliveInterval 60
    TCPKeepAlive        yes
    IdentityFile ~/.ssh/keys/bastion_id_rsa
    ProxyCommand ssh bastion 'nc -w 14400 %h %p'
    User ubuntu
    Port 22
Host prod3
    HostName 172.16.105.47
    ServerAliveInterval 60
    TCPKeepAlive        yes
    IdentityFile ~/.ssh/keys/bastion_id_rsa
    ProxyCommand ssh bastion 'nc -w 14400 %h %p'
    User ubuntu
    Port 22
```

配置完成之后，我们可以进行测试。首先测试本地能不能连接上跳板机
```
ssh bastion
```

成功之后，测试我们本地能不能连接上生产服务器
```
ssh prod1
ssh prod2
ssh prod3
```

本地连接远程内网服务器，是通过ssh的proxyCommand来实现的，注意配置中的IdentityFile，是跳板机连接生产机器的**私钥**。


最后配置ansible的hosts文件`/etc/ansible/hosts`

```
[prod]
prod1 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
prod2 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
prod3 ansible_ssh_user=ubuntu ansible_python_interpreter=/usr/bin/python3
```

配置完成之后测试ansible是否能连接到机器
```
ansible prod -m ping
```