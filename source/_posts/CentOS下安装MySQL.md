---
title: CentOS下安装MySQL
date: 2017-03-28 22:49:21
tags:
---

# 配置yum源

### 下载mysql源安装包
```
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
```

<!--more-->

### 安装mysql源
```
yum localinstall mysql57-community-release-el7-8.noarch.rpm
```

检查mysql源是否安装成功
```
yum repolist enabled | grep "mysql.*-community.*"
```

# 安装Mysql
 ```
yum install mysql-community-server
```

# 启动Mysql服务
```
systemctl start mysqld
```

查看mysql启动状态
```
systemctl status mysqld
```

# 开机启动
```
systemctl enable mysqld
systemctl daemon-reload
```

# 修改默认密码和编码

### 修改密码

mysql安装完成之后，在/var/log/mysqld.log文件中给root生成了一个默认密码。通过下面的方式找到root默认密码，然后登录mysql进行修改：
```
grep 'temporary password' /var/log/mysqld.log
mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!'; 
```

或者

```
set password for 'root'@'localhost'=password('MyNewPass4!'); 
```

### 修改默认编码
修改/etc/my.cnf配置文件，在[mysqld]下添加编码配置，如下所示：
```
[mysqld]
character_set_server=utf8
init_connect='SET NAMES utf8'
```
修改完成重启mysql服务，通过如下命令查看mysql默认编码
```
show variables like '%character%'
```


