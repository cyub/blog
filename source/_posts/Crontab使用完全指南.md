title: Crontab使用完全指南
date: 2018-11-14 23:22:24
tags:
---
最近看了《[Better PHP Development](https://www.sitepoint.com/premium/books/better-php-development)》一书，里面第6章专门讲了`crontab`使用指南，事无巨细，几乎涉及到`crontab`用法的方方面面。一直以为以为自己对`crontab`用法非常熟悉了，看完之后才发现有些地方之前确实不知道。现把书中重要内容记录到博客中，以便后续查阅。


## Cron简介

`cron`是类Unix操作系统中基于时间的作业调度器，它会在未来某个时刻触发某些任务。这个名字源于希腊语“χρόνος”( chronos )，意思是时间。由于`crontab`命令是使用`cron`时候最常用的命令，所以我们通常会说`crontab`，其实也就是`cron`。

如果我们查看`/etc`目录，我们可以看到`cron.hourly`, `cron.daily`, `cron.weekly` 和`cron.monthly`这样的目录，每个目录都对应于特定的执行频率。比如`cron.hourly`目录下面的脚本会按照每小时来执行。**安排任务的一种方式是将脚本放在相对应的目录中**。例如，为了每天运行`db_backup.php`，我们将它放在`cron.daily`中。若没有这个目录，我们需要手动创建`cron.daily`。

<!--more-->

在`cron.daily`目录下面我们可以看见`logrotate`,它用来切割日志；`sendmail`,用来发送邮件。

## crontab文件

`cron`使用名为`crontab`文件的特殊配置文件，其中包含要完成的作业列表。Crontab代表Cron表。crontab文件中的每一行都称为cron作业（也可以称为cron任务），类似于一组由空格字符分隔的列。每行指定某个命令或脚本的执行时间和频率。 **在crontab文件中，以#开头的行被视为注释，空行或以#、空格或制表符开头的行将被忽略。**

下面是一个crontab文件的列子：
```
0 0 * * *  /var/www/sites/db_backup.sh
```

第一部分`0 0 * * *`是cron表达式，它指定了执行的频率。上面的cron作业将每天运行一次。

crontab文件的编辑命令如下：

```
crontab -e
```

如果第一次使用时候没有crontab文件，这条命令会先创建crontab文件。

crontab文件在`Ubuntu`系统中默认存放在`/var/spool/cron/crontabs`,文件名是当前用户名称。比如执行`crontab -e`的命令的用户`vagrant`,则crontab文件是`/var/spool/cron/crontabs/vagrant`。在`Centos`系统默认存放目录是`/var/spool/cron`。


查看当前用户cron作业命令如下：
```
crontab -l
```

**如果想查看非当前用户的cron作业，需要以root身份或者`sudo`提权**，比如用户`user1`
```
sudo crontab -u user1 -l
```
若是`root`用户的`-u`选项可不要

编辑其它用户的crontab文件，跟查看命令类似，需要`-u`选项来指定用户
```
sudo crontab -u user1 -e
```



### crontab语法分析

crontab文件每一个条目的说明如下：


```
 # ┌───────────── 分钟 (0 - 59) 
 # │ ┌────────────── 小时 (0 - 23)
 # │ │ ┌───────────────一个月中第几天 (1 - 31)
 # │ │ │ ┌──────────────── 月份 (1 - 12)
 # │ │ │ │ ┌───────────────── 星期几 (0 - 6) (1到6是星期一到星期六, 星期天是0)
 # │ │ │ │ │
 # │ │ │ │ │
 # * * * * *  待执行的命令
```

`crontab`条目的前两个字段指定任务运行的时间(分钟和小时)，接下来的两个字段指定每月几号和月份，第五个字段指定星期几，最后字段是待执行的命令。

**注意：**<u>当每月几号和星期几字段有具体值，而不是星号（*）时候，将创建或条件，这意味这两天都匹配</u>。

比如下面的命令将会在每月5号和星期二时候都会执行`crontab`任务。

```
0 0 5 * 2 /path/to/command
```

### Crontab标准值和非标准值

crontab字段值除了数字外，还可以是其他非标准值。


#### 范围

通过`起始数字-结束数字`的形式我们可以指定范围（范围包含起始和结束数字）

```
0 6-18 1-15 * * /path/to/command
```

上面cron作业将在每月1号至15号的6点到18点执行。

`*`号是一种特殊范围。

#### 列表

列表是一组用逗号分隔的值。我们可以将列表作为字段值:

```
0 1,4,5,7 * * * /path/to/command
```

上面cron作业将在每天的1点，4点，5点，7点执行。

#### 步长

步骤可以用于范围或星号字符( * )。当它们与范围一起使用时，用来指定要跳过的值。请考虑以下语法:

```
0 6-18/2 * * * /path/to/command
```

上述cron作业将从6点到18点每两小时执行一次。

当使用带有星号(*)时候，它们只需指定该特定字段的频率。例如，如果我们将分钟字段设置为`*/5`，这仅仅意味着每五分钟一次。从某种意义上看星号(*)是一种特殊的步长，代表每一分钟，每一小时...(根据它所在字段来指定区间）

考虑下面列表、范围和步长组合的例子：

```
0 0-10/5,14,15,18-23/3 1 1 * /path/to/command
```

上述crontab作业将于1月1号的0点到10点、14点、15点以及18点到23点每三小时分别执行一次。

#### 日期单词

对于每月几号和星期几字段，我们可以使用月份和星期几英文单词的前三个字符，比如`Sat`,`sun`,`Feb`,`Sep`等等。

```
* * * Feb,mar sat,sun /path/to/command
```

上述的cron作业将在2月和3月的周六和周日执行。

#### 预定义字符串

cron支持使用一些预定义字符串代替前五个字段，来指定作业运行频率:

- **@yearly**, **@annually**  每年的1月1号凌晨0点0分运行，相当于`0 0 1 1 *`
- **@monthly** 每月1号凌晨0点0分运行，相当于`0 0 1 * *`
- **@weekly** 每周星期天的凌晨0点0分运行，相当于`0 0 * * 0`
- **@daily** 每天的凌晨0点0分运行，相当于`0 0 * * *`
- **@hourly** 每小时开始时候运行，相当于`0 * * * *`
- **@reboot** 每次开机时候运行一次


### 在同一个cron作业执行多个命令

通过分号(;)我们在一个cron作业中执行多个命令， 如下：

```
* * * * * /path/to/command-1; /path/to/command-2
```

如果运行的命令相互依赖，我们可以在它们之间使用`&&`号。如果第一个命令失败，第二个命令将不会被执行。

```
* * * * * /path/to/command-1 && /path/to/command-2
```

### 环境变量

crontab文件支持设置环境变量，形式是`VARIABLE_NAME = VALUE`。通过设置`SHELL`,我们可以改变默认的shell:`/bin/sh`。我们也可以设置`PATH`变量来改变，找到命令的路径，参见下面例子：

```
PATH = /usr/bin;/usr/local/bin
```
**注意**：当值中有空格时，应该用引号将值括起来。值都会被视为普通字符串，不以任何方式解析。

### 处理不同时区

如果你的cron作业需要设置特定时区，我们可以设置环境变量`CRON_TZ`来达到目的，所有crontab条目都将根据指定时区进行解析。


## Cron怎么解析Crontab文件的？

当Cron启动之后，它将搜索缓冲池(spool area)目录（比如`Ubuntu`系统就是`/var/spool/cron/crontabs`目录）加载`crontab`文件到内存，除此之外，也会加载`/etc/crontab`和`/etc/cron.d`目录下面的系统`crontab`文件。

将`crontab`文件加载到内存后，Cron每分钟检查加载的crontab，然后运行到期的cron作业，也就是命令。

Cron会定期检查缓冲池（spool)目录的修改时间，如果发生改变，Cron将会加载目录下面已经改变的crontab文件。这也是为什么我们配置一个新的cron作业，不需要重启Cron的原因。

## Cron权限

我们可以通过`/etc/cron.allow` 和 `/etc/cron.deny` 这两个文件来设置哪些用户可以使用Cron，哪些用户不能。**如果`/etc/cron.allow`文件存在，那么只有这个文件中列出的用户可以使用cron， 同时`/etc/cron.deny`文件被忽略； 如果`/etc/cron.allow`文件不存在，那么文件`/etc/cron.deny`中列出的用户将不能用使用cron任务调度**。


## 重定向输出


### 重定向文件或标准输入输出文件

我们可以将cron任务的输出重定向到一个文件：

```
* * * * * /path/to/php /path/to/the/command >> /var/log/cron.log
```

我们也可以将标准输出重定向`/dev/null`：

```
* * * * * /path/to/php /path/to/the/command > /dev/null
```

下面是将标准输出和标准错误输出重定向`/dev/null`：

```
* * * * * /path/to/php /path/to/the/command > /dev/null 2>&1
```

### 重定向输出到邮件

如果标准输出或标准错误没有进行上面的重定向的话，cron将输出发送到当前crontab的拥有者的邮箱(如果有的话）或者环境变量`MAILTO`指定的邮箱。

设置环境变量`MAILTO`时候，多个邮箱一冒号隔开，如果设置为空，则不发送邮件：

```
MAILTO=admin@example.com,dev@example.com
* * * * * /path/to/command
```

## Cron任务防止重叠

如果某些cron任务耗时较长，这将有可能导致同一时间任务同时运行。在某些情况下会导致问题。

下面有两种选择来防止任务重叠运行：

### 使用Flock

Flock使用锁文件来控制命令或脚本运行。当cron使用flock时候，如果相应锁文件存在，则cron则不会运行。

Ubuntu系统安装：

```shell
apt-get install flock
```

Centos系统安装：

```shell
yum install flock
```

crontab条目使用方法如下：

```
* * * * * /usr/bin/flock --timeout=1 /path/to/cron.lock /usr/bin/php /path/to/scripts.php
```

上面配置说明：flock查找`/path/to/cron`锁。如果在一秒钟内获得了锁，它将运行脚本，否则它将失败并退出，退出代码为1。

### 在脚本中使用锁定机制(Locking Mechanism)

考虑下面的PHP例子：

```php
<?php
$lockfile = sys_get_temp_dir() . '/' md5(__FILE__) . '.lock';
$pid      = file_exists($lockfile) ? trim(file_get_contents($lockfile)) : null;

if (is_null($pid) || posix_getsid($pid) === false) {

    // Do something here
    
    // And then create/update the lock file
    file_put_contents($lockfile, getmypid());

} else {
    exit('Another instance of the script is already running.');
}
```

上面脚本首先会检查锁文件是否存在，存在的话取得它的内容，这是脚本最后一个运行实例的进程ID。然后将PID传递给`posix_getsid`函数，该函数返回进程的会话ID。如果`posix_getsid`返回false，这意味着进程不再运行，那么就可以安全地启动一个新实例。


## 故障快速排除


### 命令应使用绝对路径

crontab文件中所有可执行文件使用绝对路径是一个好习惯。

```
* * * * * /usr/local/bin/php /absolute/path/to/the/command
```

### 确保Cron守护进程正在运行

```
ps aux | grep crond
```

### 检查`/etc/cron.allow`和`/etc/cron.deny`文件

如果cron任务没有运行，如果`/etc/cron.allow`存在，请确保crontab文件的用户在其中，如果`/etc/cron.deny`不存在，请确保crontab文件的用户不在其中。

### 脚本应有执行的权限

需要确保crontab的所有者拥有crontab文件中所有命令和脚本的执行权限。否则cron将不起作用。

### crontab文件最后至少要有一个空行

crontab中的每个条目都应该以新行结束。这意味着在**最后一个crontab条目之后必须有一个空行**，否则最后一个cron作业将永远不会运行。




