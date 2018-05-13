---
title: 使用Robo自动生成Nginx虚拟主机配置
date: 2017-11-21 19:21:44
tags:
---

在开发过程中，我们有时候是基于一个框架的脚手架来开发。先clone下来项目，然后配置Nginx或Apache服务器里面的虚拟主机，映射到当前项目。这个虚拟主机的配置可以由程序自动生成。

流程如下：
1. composer create-project tink/slim-skeleton:dev-master blog // 使用slim-skeleton创建blog项目
2. cd blog // 切换到blog目录
3. ngto park // 执行命令，配置虚拟主机。blog.local域名自动配置到当前blog项目。

<!-- more-->

现提供一个基于[Robo](http://robo.li/)写的一个脚本,适用于linux环境。window环境的可自行更改。对于域名解析问题可以搭建本地dns服务，所有local后缀的域名全部解析到本地。或者直接blog.local写入hosts文件中。Mac系统的可以使用[Valet](https://d.laravel-china.org/docs/5.4/valet)，功能更全，使用更方便

```php
#!/usr/bin/env robo
/**
 * Robo script for auto generate nginx virtual host configuration
 * 
 * the script save as ngto with x mode
 * useage:
 * ./ngto start // 启动nginx服务
 * ./ngto park test // 将test.local指向当前目录里面的项目
 * ./ngto forget test // 删除test.local的指向配置
 * ./ngto stop // 停止nginx服务
 * ./ngto restart // 重启nginx服务
 */
<?php

class Ngto extends \Robo\Tasks
{
    private $phpfpm = '127.0.0.1:9000';
    private $domainSuffix = '.local';
    private $virtualHostConfigPath = '/usr/local/etc/nginx/conf.d';
    private $nginxConfigPath = '/usr/local/etc/nginx/nginx.conf';

    /**
     * start nginx
     * @return void
     */
    public function start()
    {
        $nginxBin = $this->findNginxBinary();
        if (!$nginxBin) {
            return $this->say("can't find nginx, please install nginx first!");
        }
        $this->say("start nginx...");
        if ($this->taskExec("$nginxBin -c $this->nginxConfigPath")) {
            $this->say("success!");
        } else {
            $this->say("failure!");
        }
    }

    /**
     * restart nginx
     * @return void
     */
    public function restart()
    {
        $this->stop();
        $this->start();
    }

    /**
     * generate virtual host configuration
     * @param  mixed $domain
     */
    public function park($domain = null)
    {
        $cwd = getcwd();
        if (file_exists($cwd . DIRECTORY_SEPARATOR . 'public' . DIRECTORY_SEPARATOR . 'index.php')) {
            $documentRoot = $cwd . DIRECTORY_SEPARATOR . 'public';
        } elseif (file_exists($cwd . DIRECTORY_SEPARATOR . 'index.php')) {
            $documentRoot = $cwd;
        } else {
            $this->say('entry file not exists!');
            return;
        }

        $serverName = $this->getSubdomainFromCwd($domain, $cwd) . $this->domainSuffix;

        $block =<<<EOD
server {
    listen $serverName;
    root "$documentRoot";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$serverName-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass $this->phpfpm;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOD;
        $this->say("start write virtual host configruation");
        file_put_contents($this->virtualHostConfigPath . DIRECTORY_SEPARATOR . $serverName . '.conf' , $block);
        $this->reload();
    }

    /**
     * get subdomain by current working directory
     * @param  [type] $domain
     * @param  [type] $cwd
     * @return string
     */
    protected function getSubdomainFromCwd($domain, $cwd)
    {
        if ($domain) {
            $domain = preg_match('/[^A-Za-z_]/', '', $domain);
        }
        if (!$domain) {
            $domain = basename($cwd);
        }

        return $domain;
    }

    /**
     * find nginx path
     */
    protected function findNginxBinary()
    {
        if ($result = @exec('which nginx')) {
            return $result;
        }

        return null;
    }

    /**
     * delete virtual host configruation
     * @param  $domain
     */
    public function forget($domain = null)
    {
        $serverName = $this->getSubdomainFromCwd($domain, getcwd()) . $this->domainSuffix;
        $this->say("delete virtual host configuration");
        $this->_remove($this->virtualHostConfigPath . DIRECTORY_SEPARATOR . $serverName . ".conf");
        $this->say("success!");

        $this->reload();
    }

    /**
     * stop nginx
     */
    public function stop()
    {
        $nginxBin = $this->findNginxBinary();
        if (!$nginxBin) {
            return $this->say("can't find nginx, please install nginx first!");
        }

        $this->say("stop nginx...");
        if ($this->taskExec("$nginxBin -s stop")->run()->wasSuccessful()) {
            $this->say('success!');
        } else {
            $this->say('failure');
        }
    }

    /**
     * reload nginx configruation
     */
    public function reload()
    {
        $nginxBin = $this->findNginxBinary();
        if (!$nginxBin) {
            return $this->say("can't find nginx, please install nginx first!");
        }

        $this->say("reload nginx...");
        if ($this->taskExec("$nginxBin -s reload")->run()->wasSuccessful()) {
            $this->say('success!');
        } else {
            $this->say('failure!');
        }
    }
}
```





