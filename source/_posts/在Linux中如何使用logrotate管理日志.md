title: 在Linux中如何使用logrotate管理日志
author: tinker
tags:
  - 日志管理
  - Logrotate
categories:
  - 翻译
date: 2019-11-17 20:28:00
---
原文：[How To Manage Log Files Using Logrotate In Linux](https://www.ostechnix.com/manage-log-files-using-logrotate-linux/)

几天前，我们发布了一份指南，介绍了如何在CentOS系统上设置[集中式Rsyslog服务](https://www.ostechnix.com/setup-centralized-rsyslog-server-centos-7/)。今天，在本指南中，我们将了解如何在Linux上使用日志轮换来管理日志文件。该实用程序简化了日志文件的管理，尤其适用于每天生成大量日志文件的系统。顾名思义，LogRotate以固定的时间间隔将日志完全从系统中轮转出来。它还允许日志文件的自动轮转、压缩、删除和传输。每个日志文件可以每天、每周、每月或在变得太大时处理。

<!--more-->

## 使用Logrotate管理日志文件

### 安装Logrotate

- 基于RPM的系统，比如RHEL, CentOS：
> sudo yum install logrotate

- Debian, Ubuntu系统：
> sudo apt-get install logrotate

### 配置Logrotate

LogRotate的主要配置文件是/etc/logrotate.conf

下面这是Arch系统中该文件的默认内容。这个文件内容在其他Linux发行版上可能看起来有点不同。

> cat /etc/logrotate.conf

示例输出：

```
# see "man logrotate" for details
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# restrict maximum size of log files
#size 20M

# create new (empty) log files after rotating old ones
create

# uncomment this if you want your log files compressed
#compress

# Logs are moved into directory for rotation
# olddir /var/log/archive

# Ignore pacman saved files
tabooext + .pacorig .pacnew .pacsave

# Arch packages drop log rotation information into this directory
include /etc/logrotate.d

/var/log/wtmp {
 monthly
 create 0664 root utmp
 minsize 1M
 rotate 1
}

/var/log/btmp {
 missingok
 monthly
 create 0600 root utmp
 rotate 1
}
```

让我们看看上述配置文件中每个选项的作用。

- weekly - 它每周轮换日志
- rotate 4 - 默认情况下，LogRotate保留四周(显然是一个月)的日志文件。因为，它会在一段特定时间后循环所有日志文件，所以如果不想丢失重要日志文件，你可能需要保留它们的备份。
- size 20M - 如果日志文件达到20MB大小，则旋转日志文件。默认情况下，此选项被禁用。要启用它，只需取消注释即可。
- create - 旋转旧日志文件后，创建一次新日志文件。默认情况下，此选项处于启用状态
- compress - 压缩日志文件。此外，默认情况下，它不会压缩日志。如果要压缩日志，请取消对该行的注释。
- /etc/logrotate.d/ - 此目录包含应用程序的特定日志规则文件。
- missing ok -  如果日志文件丢失，Logrotate将继续处理下一个，而不会发出错误消息。

Logrotat分割日志文件，根据/etc/logrotate.d/目录下指定的规则分割压缩日志。

让我们看看这个目录的内容。

> ls /etc/logrotate.d/

示例输出：

> lirc  samba

正如你在上面的输出中看到的，它包含由LogRotate管理的所有日志的各种规则文件。要查看特定的应用程序日志规则，例如samba，请运行:

> cat /etc/logrotate.d/samba

示例输出：

```
/var/log/samba/log.smbd /var/log/samba/log.nmbd /var/log/samba/*.log {
 notifempty
 missingok
 sharedscripts
 copytruncate
 postrotate
 /bin/kill -HUP `cat /var/run/samba/*.pid 2>/dev/null` 2>/dev/null || true
 endscript
}
```

配置说明：

- notifempty - 指示日志文件如果为空，将不会旋转
- copytruncate - 创建副本后，将原始日志文件截断
- postrotate/endscript - 日志文件轮转后，会执行postrotate和endscript之间的行。
- sharedscript - 脚本只运行一次，不管有多少日志匹配通配符模式。


你还可以在/etc/logrotate.d/目录中创建自己的日志规则文件，并定义自己的规则。

Cron每天运行logroate，搜索要循环的日志文件。你可以在/etc/cron.daily/logrotate文件中指定自动日志轮转规则，以避免手动用户干预。它将每天在特定时间执行日志轮转。