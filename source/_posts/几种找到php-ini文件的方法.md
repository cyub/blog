---
title: 几种找到php.ini文件的方法
date: 2018-03-04 21:34:40
tags:
    PHP
---
查找`php.ini`文件所在路径几种方法：
## 1. 内置函数

### phpinfo
phpinfo输出`PHP`当前状态的大量信息，包含了编译选项、启用的扩展、PHP 版本、服务器信息和环境变量（如果编译为一个模块的话）、PHP环境变量、操作系统版本信息、path 变量、配置选项的本地值和主值、HTTP 头和PHP授权信息(License)。包含所有 EGPCS(Environment, GET, POST, Cookie, Server) 数据
<!--more-->

```php
<?php
 phpinfo();
?>
```
### php_ini_loaded_file 
php_ini_loaded_file输出已加载的`php.ini`文件的路径
```php
<?php
 echo php_ini_loaded_file();
 ?>
```

## 2. php命令行
```bash
php --ini
```

或者
```bash
php --i | grep 'php.ini'
```

## 3. strace命令
`strace`是跟踪程序执行的命令
```bash
strace -e open php 2>&1 | grep php.ini
```

## 附.PHP命令行参数
<pre>
-a               以交互式shell模式运行
-c | 指定php.ini文件所在的目录
-n               指定不使用php.ini文件
-d foo[=bar]     定义一个INI实体，key为foo，value为'bar'
-e               为调试和分析生成扩展信息
-f         解释和执行文件.
-h               打印帮助
-i               显示PHP的基本信息
-l               进行语法检查 (lint)
-m               显示编译到内核的模块
-r         运行PHP代码，不需要使用标签 ..?>
-B   在处理输入之前先执行PHP代码
-R         对输入的没一行作为PHP代码运行
-F         Parse and execute  for every input line
-E     Run PHP  after processing all input lines
-H               Hide any passed arguments from external tools.
-S : 运行内建的web服务器.
-t      指定用于内建web服务器的文档根目录
-s               输出HTML语法高亮的源码
-v               输出PHP的版本号
-w               输出去掉注释和空格的源码
-z         载入Zend扩展文件 .

args...          传递给要运行的脚本的参数. 当第一个参数以-开始或者是脚本是从标准输入读取的时候，使用--参数

--ini            显示PHP的配置文件名

--rf       显示关于函数  的信息.
--rc       显示关于类  的信息.
--re       显示关于扩展  的信息.
--rz       显示关于Zend扩展  的信息.
--ri       显示扩展  的配置信息.
</pre>