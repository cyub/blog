title: Jupyter Notebook部署
tags:
  - Jupyter notebook
  - Devops
categories: []
date: 2018-12-31 11:57:00
---
[Jupyter Notebook](https://jupyter.org/) 是科学计算必备工具之一，它是一个开源的web应用程序，允许你创建和共享实时代码，可以用来进行数据清理和转换、统计建模、数据可视化、机器学习等等工作。

![](http://static.cyub.vip/images/201812/jupyterpreview.png)

下面是使用supervisour和nginx来部署公开jupyter notebook服务过程。

## 安装jupyter notebook

推荐python3环境下安装jupyter。我系统是`Ubuntu 18.04`里面内置了python3，所以直接安装jupyter，如果系统python版本是python2.7，可以使用`virtualenvwrapper`进行多版本python管理。

下面使用pip来安装jupyter notebook

```js
sudo apt-get install python3-pip // 安装pip3
sudo pip3 install jupyter // 安装jupyter
```
<!--more-->

**注意：**jupyter是单用户服务，如果想使用多用户服务可以使用[jupyterhub](https://jupyterhub.readthedocs.io/)

## 配置jupyter notebook

### 生成配置文件

下面命令将在`~/.jupyter`目录下面生成`jupyter notebook`配置文件`jupyter_notebook_config.py`

```js
sudo jupyter notebook --generate-config
```

修改`jupyter_notebook_config.py`文件中以下配置：

```js
c.NotebookApp.ip = 'localhost' // jupyter监控地址
c.NotebookApp.port = 8888 // jupyter监听端口
c.NotebookApp.allow_remote_access = True // 运行以非localhost/127.0.0.1访问
```

### 配置登录密码

jupyter启动服务时候，默认是使用一次性token进行登录验证的。我们需要使用以下命令来给jupyter服务配置登录密码：

```js
sudo jupyter notebook password
```

按照提示输入密码，再次确认密码就可以了。这条命令需要jupyter notebook版本不小于5.0才支持。若不支持可以按照下面方式来配置，详细见[官方文档](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#preparing-a-hashed-password)：

在python交互模式下,输入以下命令

```js
>>> from notebook.auth import passwd
>>> passwd()
Enter password:
Verify password:
'sha1:5952f1c3c7ec:16852a1f8ee36f7cb716b74d3e0127efee106c1c'
```

然后复制上面的hash处理之后的字符串到`~/jupyter_notebook_config.py`

```js
c.NotebookApp.password = u'sha1:5952f1c3c7ec:16852a1f8ee36f7cb716b74d3e0127efee106c1c'
```

### 启动服务并验证

配置完成之后我们可以使用`jupyter notebook`来启动服务

```js
cd /home/vagrant/jupyter // 假定jupyter工作目录在~/jupyter
jupyter notebook
```

由于jupyter是在远程服务器上面启动，监听的是127.0.0.1地址，外面无法访问，这时候我们可以使用ssh本地转发功能，将远程内网服务转发至本地端口。下面我们在本地执行以下命令(若window下面没有ssh命令，可使用xshell)：

```js
ssh -N -f -L 9999:localhost:8888 remote_user@remote_host
```

其中-N表示仅做端口转发，不执行任何命令。-f表示在后台运行。-L表示本地转发，其选项值代表ssh客户端和服务端转发的端口，9999为本地监听端口， localhost和8888为远程jupyter服务地址和端口。remote_user@remote_host代表远程主机用户和地址。

完成上面操作，打开浏览器，地址栏输入`localhost:9999`，即访问的是远程的jupyter。

ssh端口转发只是来测试jupyter服务功能，接下来继续部署公开jupyter服务。


## 配置Supervisor

Supervisor是python语言写的进程服务管理工具。为了保证jupyter notebook在不可用时候自动重启，使用supervisor来监控jupyter服务。

下面命令用来安装supervisor

```js
 sudo apt-get install supervisor
```

然后复制到以下配置到`/etc/supervisor/conf.d/jupyter.conf`

```js
[program:jupyter]
command = jupyter notebook --no-browser --config=/home/vagrant/.jupyter/jupyter_notebook_config.py
directory = /home/vagrant/jupyter
user = vagrant
autostart = true
autorestart = true
stdout_logfile=/var/log/supervisor/jupyter.out.log
stderr_logfile=/var/log/supervisor/jupyter.err.log
```

加载上面配置到`supervisord`

```js
sudo supervisorctl reread // 重新读取配置
sudo supervisorctl update // 使用新配置启动程序
```

使用下面命令来查看jupyter状态

```js
sudo supervisorctl status
```


## 配置Nginx

nginx安装过程略。nginx配置如下：

```js
server {
    listen     80;
    server_name  jupyter.example.com;
    location / {
        proxy_pass http://localhost:8888;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_http_version 1.1;
        proxy_redirect off;
        proxy_buffering off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```

上面配置简单说明：由于jupyter客户端执行命令时候，是使用webscokets来和服务端进行通信，为了让Nginx可以将来自客户端的Upgrade请求发送到后端jupyter，Upgrade和Connection的头信息必须被显式的设置。


重新加载nginx配置文件

```js
sudo nginx -t // 测试nginx配置语法是否ok
sudo nginx -s reload // 重新加载配置到nginx
```

最后打开浏览器访问`jupyter.example.com`就可以使用jupyter了。

## 参考

- [Deploying Jupyter in Ubuntu with Nginx and Supervisor](http://www.albertauyeung.com/post/setup-jupyter-nginx-supervisor/)
- [Jupyter官方文档之Running a notebook server](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html)
- [实战 SSH 端口转发](https://www.ibm.com/developerworks/cn/linux/l-cn-sshforward/index.html)
- [Jupyter Lab: Evolution of the Jupyter Notebook](https://towardsdatascience.com/jupyter-lab-evolution-of-the-jupyter-notebook-5297cacde6b)