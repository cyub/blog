---
title: 使用Xdebug和Webgrind优化PHP代码
date: 2017-07-03 19:29:16
tags:
    - 性能优化
    - PHP优化
    - Xdebug
    - Webgrind
---
在PHP开发过程中找到并修复性能瓶颈（performance bottlenecks）往往是非常困难和耗时的。为了定位问题，我们可能会在疑似影响性能的代码的开始和结束之间打上标记点，计算时间差，来定位问题，CI框架提供的基准测试类就是这样工作，这种方式对小型项目起到方便快捷的作用，但对大项目往往吃力不讨好，好比在工业时代，却是用石器时代的工具。这时候我们可以借助Xdebug，webgrind这样的工具来定位到和可视化php代码中的性能瓶颈。

Xdebug是PHP拓展，可以用来跟踪，调试和分析PHP程序的运行状况。而Webgrind是Web应用，提供一个可视化工具，来分析、查看Xdebug性能日志功能。在Linux KDE环境下可以用`KChaceGrind`，windows 下可以用`winChaceGrind`来替换Webgrind查看分析Xdebug日志。
<!--more--> 

## 安装
1. 源码编译安装xdebug
```
wget https://xdebug.org/files/xdebug-2.5.5.tgz
tar -xzvf xdebug-2.5.5.tgz
phpize 
./configure --enable-xdebug
make
make install
```
2. 配置php.ini
可以通过`php -i | grep 'php.ini'`快速找到php.ini文件位置。在php.ini文件最后添加如下：
```
[xdebug]
zend_extension=/you-php-extension-dir/xdebug.so //可通过命令`php -i | grep 'extension_dir'`查看拓展安装的目录
xdebug.profiler_enable         = 1
xdebug.profiler_enable_trigger = 1
xdebug.profiler_output_name    = cachegrind.out.%p
xdebug.profiler_output_dir     =/var/tmp/xdebug_profilers/
xdebug.trace_output_dir        =/var/tmp/xdebug_traces/
xdebug.auto_trace              = 0
xdebug.collect_params          = 4
xdebug.collect_return          = 1
xdebug.show_mem_delta          = 1
```
3. 重启PHP-FPM
如果PHP-FPM管理php fastcgi则需要重启php-fpm使其生效
```
kill -USR2 `cat php-fpm.pid`
```

4. 安装webgrind
```
git clone https://github.com/jokkedk/webgrind
cd webgrind
找到config.php文件，修改$profilerDir，将其设置成xdebug.profiler_output_dir配置项值
```

## 配置
下面是xdebug配置参数一些说明
* xdebug.profiler_enable
此配置项开启Xdebug内置的性能优化器，1或者on开启，0或者off关闭

* xdebug.profiler_enable_trigger
当这个选项设置开启时候，Xdebug内置的性能优化器，只有在GET/POST或者Cookie带有XDEBUG_PROFILE时候，比如[http://www.cyub.vip/script.php?XDEBUG_PROFILE](http://www.cyub.vip/script.php?XDEBUG_PROFILE)，才会记录性能日志。此时的xdebug.profiler_enable必须是关闭状态

* xdebug.profiler_output_dir
xdebug性能优化器信息输入目录路径，默认是/tmp

* xdebug.profiler_output_name
这个选项设置了Xdebug输入信息日志文件的名称格式。默认格式是cachegrind.out.%p，其中%p是进程id。其他重要占位参数有：
```
    %p 当前进程id
    %r 随机数字
    %u 时间戳（微秒格式） 
    %H $_SERVER['HTTP_HOST']的值
    %R $_SERVER['REQUEST_URI']的值
    %s url路径，路径分割符会转化成下划线
```

* xdebug.profiler_append
默认情况下，Xdebug会覆盖输入文件，设置此选项开启后会追加日志信息到文件









