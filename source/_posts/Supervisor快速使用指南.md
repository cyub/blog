title: Supervisor快速使用指南
author: tinker
date: 2019-06-01 19:57:43
tags:
---
## 简介

Supervisor是用于监控和管理类UNIX操作下进程的C/S系统。Supervisor不是作为进程id为1的`init`的替代，它只是用来控制应用程序的进程，它会跟其他进程开机启动时候一样，通过pid为1的进程启动。为了高可用，它本身也需要监控。

Supervisor的构成有4部分：

- **supervisord**

    supervisord是Supervisor的守护进程，是C/S中S端，它响应客户端的命令，监控，重启奔溃异常退出的子进程，以及记录子进程的`stdout`和`stderr`等。supervisord默认配置文件是`/etc/supervisord.conf`

- **supervisorctl**

    supervisorctl是Supervisor的命令行客户端，supervisorctl工作原理是发送命令给supervisord，来对其他进程的启动，关闭等操作

- **Web Server**

    Supervisor也支持web形式客户端

- **XML-RPC Interface**

    Supervisor提供了XML-RPC接口，通过此接口，我们可以询问和控制supervisor

<!--more-->

Supervisor特点有：

- **简单**

    Supervisor使用INI风格的配置文件，它提供了很多预制选项，比如重启失败的进程，自动日志分割

- **中心化**

    Supervisor提供统一的进程启动，停止，监控服务。每个进程可以独立的，也可以分组监控。除了本地操作外，Supervisor还支持远程命令和web界面操作

- **更高效**

    Supervisor通过fork/exec启动进程，当进程终止时，操作系统会立即向Supervisor发出信号，这不同于某些依赖麻烦的PID文件和定期轮询来重新启动失败进程的解决方案。

- **兼容可靠**

    Supervisor是使用Python语言编写的，支持在Linux, Mac OS X等系统。它存在多年，并实际运行在很多生产服务器上。


## 安装

Supervisor是Python编写的，可以直接用pip进行安装 :

```bash
sudo pip install supervisor
```

如果是 Ubuntu 系统，还可以使用apt安装:

```
apt install supervisor
```

## Supervisord配置

通过pip安装完supervisor之后，运行echo_supervisord_conf 命令输出默认的配置重定向到一个配置文件里：

```bash
echo_supervisord_conf > /etc/supervisord.conf
```
**注意：** 通过系统包命令安装的supervisor，一般默认都是配置好配置文件，这里面说的都是通过pip安装的情况

下面是配置的部分内容：
```
[unix_http_server]
file=/tmp/supervisor.sock   ; Unix Domain Socket，用于客户与服务端通信
;chmod=0700                 ; socket文件默认权限是0700
;chown=nobody:nogroup       ; socker文件的所属用户与用户组
;username=user              ; 用户名
;password=123               ; 用户密码

;[inet_http_server]         ; web管理，默认是关闭状态
;port=127.0.0.1:9001        ; web管理的后台的IP和端口
;username=user              ; web管理的后台用户名
;password=123               ; web管理的后台密码

[supervisord]
logfile=/tmp/supervisord.log ; 日志文件 $CWD/supervisord.log
logfile_maxbytes=50MB        ; 轮转日志的最大大小是50M
logfile_backups=10           ; 最大默认备份日志是10
loglevel=info                ; 日志级别，默认是info，其他的日志级别有debu,warn,tracelog level;
pidfile=/tmp/supervisord.pid ; supervisord的pid文件
nodaemon=false               ; 是否在前台启动，false表示以守护进程的形式运行
minfds=1024                  ; 可打开的最小文件描述符的个数是1024
minprocs=200                 ; 可打开的最小进程个数是200
;umask=022                   ; 进程创建的默认掩码是022
;user=supervisord            ; 设置supervisord启动用户是supervisord

; supervisorctl的配置
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; supervisorctl连接的supervisord的socket文件地址
;serverurl=http://127.0.0.1:9001 ; 也支持inet socket
;username=chris              ; 跟[*_http_server]用户名一致
;password=123                ; 跟[*_http_server]密码一致


; 管理的应用进程配置示例
;[program:theprogramname]      ; 格式[program:x]
;command=/bin/cat              ; 进程启动命令
;process_name=%(program_name)s ; 进程名称 默认是%(program_name)s
;numprocs=1                    ; 进程启动fork/exec的个数
;directory=/tmp                ; 进程exec之前切换的目录
;umask=022                     ; 进程的掩码，默认是None
;priority=999                  ; 进程的优先级，默认是999
;autostart=true                ; true代表supervisord启动时候也启动，默认是true
;startsecs=1                   ; 进程必须保持运行的秒数，默认是1
;startretries=3                ; 进程失败重启的最大次数，默认是3
;autorestart=unexpected        ; 什么时候重启进程，默认是unexpected
;exitcodes=0                   ; 自动重启时候的异常退出码，默认是0
;stopsignal=QUIT               ; 杀死进程的信号，默认是TERM
;stopwaitsecs=10               ; 等待SIGKILL信号的最大时间，默认是10秒
;stopasgroup=false             ; 是否发送停止信号给Unix进程组，默认是falsesend stop signal to the UNIX process group (default false)
;killasgroup=false             ; 是否发送SIGKILL给unix进程组，默认是false
;user=chrism                   ; 指定进程启动的用户
;redirect_stderr=true          ; 是否把进程的错误重定向到标准输出，默认是false
;stdout_logfile=/a/path        ; 标准输出日志路径, NONE是不输出; 默认是AUTO
;stdout_logfile_maxbytes=1MB   ; 最大日志轮询大小，默认是50M
;stdout_logfile_backups=10     ; 最大标准输出日志文件备份数，默认是0，0表示不备份
;stdout_syslog=false           ; 是否把标准输出输出到syslog，默认是false
;stderr_logfile=/a/path        ; 标准错误输出日志路径，NONE是不输出; 默认是AUTO
;stderr_logfile_maxbytes=1MB   ; 最大日志轮询大小，默认是50M
;stderr_logfile_backups=10     ; 最大标准错误输出日志文件备份数，默认是0，0表示不备份
;stderr_syslog=false           ; 是否把错误输出到syslog，默认是false
;environment=A="1",B="2"       ; 进程启动的环境变量


; 进程组的配置
;[group:thegroupname]
;programs=progname1,progname2  ; progname1是进程配置中[program:x]的'x'
;priority=999                  ; 优先级，默认是999


;[include]                     ; 加载更多配置，推荐关于应用的配置都放在此目录下
;files = relative/directory/*.ini
```


配置好supervisourd的配置后，启动守护进程：

```
supervisord -c /etc/supervisord.conf
```

`supervisord`和`supervisorctl`按照以下顺序来寻找`supervisord.conf`文件，直到找到为止。

- $CWD/supervisord.conf
- $CWD/etc/supervisord.conf
- /etc/supervisord.conf
- /etc/supervisor/supervisord.conf (since Supervisor 3.3.0)
- ../etc/supervisord.conf (Relative to the executable)
- ../supervisord.conf (Relative to the executable)

我们可以通过发送信号来管理supervisord，比如我们修改了`/etc/supervisord.conf`之后，可以通过发送HUP信号来重新加载配置`kill -HUP supervisord进程id`：

- SIGTERM
- SIGINT
- SIGQUIT
    上面三个信号都能达到同一个目的：supervisord及其所管理的进程都将关闭
- SIGHUP
    supervisord将关闭所有进程，然后重新加载配置之后启动所有进程
- SIGUSR2
    supervisord将关闭和重新打开主要活动日志和所有子日志文件


supervisord有可能死掉，为了在supervisord死掉时候，我们可以配置systemctld来管理supervisord进程:


```
# /usr/lib/systemd/system/supervisor.service
[Unit]
Description=Supervisor process control system for UNIX
Documentation=http://supervisord.org
After=network.target

[Service]
ExecStart=/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/bin/supervisorctl -c /etc/supervisor/supervisord.conf $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=50s

[Install]
WantedBy=multi-user.target
```

之后我们可以通过`systemdctl`来管理`supervisord`进程了

## 应用程序的配置

下面以php-fpm配置为例：

```
[program:php-fpm]
command=/usr/local/php-7.1.5/sbin/php-fpm -y /usr/local/php-7.1.5/etc/php-fpm.conf -c /usr/local/php-7.1.5/lib/php.ini
autostart=true
autorestart=true
startretries=3
stderr_logfile=/var/log/supervisor/php-fpm.err.log
stdout_logfile=/var/log/supervisor/php-fpm.out.log
```

## Supervisorctl使用

Supervisorctl是Supervisor客户端，启动时需要指定与supervisord 使用同一份配置文件，否则与supervisord一样按照顺序查找配置文件:

```
supervisorctl -c /etc/supervisord.conf
```

supervisorctl常见用法：

```bash
supervisorctl reread // 读取新配置
supervisorctl update   // 更新新的配置到supervisord
supervisorctl reload // 重新启动配置中的所有程序
supervisorctl start program_name // 启动某个程序
supervisorctl restart program_name // 重启某个程序
supervisorctl stop program_name // 停止某个程序
supervisorctl stop all // 停止所有程序
supervisorctl status // 查看程序状态
```

**注意：** reread只是读取新配置，接着使用restart应用程序的启动并不会使用新的配置，而应该使用update

## Supervisor与Systemd比较

Supervisor和Systemd都能对应用进程监控和管理，他们相比的优缺点：

Supervisor的优点有：

- 操作方式灵活，既可以通过命令操作，也可以通过web界面来操作
- 可以控制生成进程数量
- 单个配合文件可以控制多个程序
- 日志配置灵活

Supervisor缺点有：

- 本身需要监控
- 不能跨主机操作


Systemd优点有：

- 可使用模板文件
- 附带定时器、路径监控器、数据监控器等功能
- 开机可以自启
- 大多数发行版的标准配置 
- 限制特定服务可用的系统资源量例如CPU、程序堆栈、文件句柄数量、子进程数量

Systemd缺点有：

- 配置相对复杂
- 多配置文件才能配置多个程序


## 参考

- [supervisor官方文档](http://supervisord.org/index.html)
- [systemd 和 supervisor 相比各有哪些优缺点？以及各自的适用场景是什么？](https://www.zhihu.com/question/48833333/answer/302719973)