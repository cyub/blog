title: PHP错误与异常处理详解（一）
tags:
  - PHP
  - 错误与异常
categories:
  - 开发语言
date: 2018-05-17 22:36:00
---
在PHP开发过程中，错误和异常的处理是必不可少的，但由于两者比较相似，容易让人混淆。错误往往是自身问题，比如语法错误，使用未定的变量等，而异常是在程序运行过程中存在逻辑问题时候主动抛出的。

<!--more-->

## 错误

错误可以设置不同的报告级别，来决定是否报告错误。PHP的错误级别分为3类，由一般到严重如下：

1. **注意（notice）:**这不会阻止脚本的执行，并且可能不一定是一个问题；

2. **警告（warning）:**这指示一个问题，但是不会阻止脚本的执行；

3. **错误（error）:**这会阻止脚本继续执行（包括常见的解析错误，它从根本上阻止脚本运行）。

### 错误级别

下面是错误报告常量，我们可以执行`get_defined_constant`函数来查看


| 值 | 常量 | 描述 |
| :------ | :------ | :------ |
| 1 | <font color="Red">E_ERROR</font> | 致命的运行时错误。错误无法恢复。脚本的执行被中断，比如内存分配问题 |
| 2 | <font color="Peru">E_WARNING</font> | 非致命的运行时错误。脚本的执行不会中断 |
| 4 | <font color="Red">E_PARSE</font> | 编译时语法解析错误 |
| 8 | <font color="LightGreen">E_NOTICE</font> | 运行时提示 |
| 16 | <font color="Red">E_CORE_ERROR</font> | PHP内部生成的错误 |
| 32 |  <font color="Peru">E_CORE_WARNING</font> | 警告，非致命错误 |
| 64 | <font color="Peru">E_CORE_WARNING</font> | 由Zend脚本引擎内部生成的错误 |
| 128 | <font color="Peru">E_COMPILE_WARNING</font> | 由Zend脚本引擎内部生成的警告 |
| 256 | <font color="Red">E_USER_ERROR</font> | 调用trigger_error函数生成的运行时错误 |
| 512 | <font color="Peru">E_USER_WARNING</font> | 调用trigger_error函数生成的运行时警告 |
| 1024 | <font color="LightGreen">E_USER_NOTICE</font> | 调用trigger_error函数生成的运行时提示 |
| 2048 | <font color="LightGreen">E_STRICT</font>| 运行时提示 |
| 4096 | E_RECOVERABLE_ERROR | 可捕获的致命错误|
| 8192 | <font color="LightGreen">E_DEPRECATE</font> | 运行时提示。提示代码在新版本中废弃 |
| 16384 | <font color="LightGreen">E_USER_DEPRECATE</font> | 调用trigger_error函数生成的运行时提示 |
| 32767 | E_ALL | 所有错误。PHP5.4之前不包含E_STRICT，不同PHP版本的值不一样 |

### 错误级别设置

错误级别本质是位字段，我们可以通过与或非操作来组合成不同的错误级别

比如我们想报告除了`E_NOTICE`之外的所有错误

```php
error_report(E_ALL ^ E_NOTICE)
```

下面这个和上面是等效的：
```php
error_reporting(E_ALL & ~E_NOTICE)
```

`error_reporting`几种常见用法：
```
error_reporting(-1); 报告所有错误，报告所有错误推荐这个
error_reporting(0); 关闭所有PHP错误报告
error_reporting(E_ALL || E_NOTICE); 相当于E_ERROR
error_reporting(); 返回设置的错误级别
```

除了使用`error_reporting`这函数来设置报告级别外，我们也可通过配置`php.ini`来设置
```
# php.ini
error_reporting = E_ALL // 这和ini_set('error_reporting', E_ALL)是一样的
```

记住只是设置好错误报告是不够的，我们还需要设置错误报告，这就需要配置下面的2个PHP运行时配置。

1. display_errors
该配置决定是否在页面里面显示错误信息，这个只在php-fpm模式下才有效，cli是无效的

2. log_errors
该配置决定是否记录错误信息，记录信息的文件由`error_log`配置决定

在生成环境下面我们可以配置成这样
```php
ini_set('display_errors', 'Off'); // 不在页面中显示错误信息

ini_set('log_errors', 'On');// 开启错误日志记录

ini_set('error_log', '/tmp/php_error');// 设置日志记录位置

```

### 错误处理函数

上面的`error_reporting`和`display_errors`只是设置错误是否报告已经十分显示，但如果想对错误处理具有更大可控性，这时候就需要使用内置的错误处理函数了。

常用的错误处理函数如下：更见[错误处理和日志记录](http://php.net/manual/zh/book.errorfunc.php)


| 函数名 | 说明 |
| :------ | :------ | 
| error_log | 发送错误信息到某个地方 |
| set_error_handler | 设置用户自定的错误处理函数，会屏蔽系统默认处理程序 |
| restore_error_handler | 恢复之前的错误处理程序 |
| error_get_last | 获取最后发生的错误 |
| register_shutdown_function | 程序执行完毕时候的回调 |

下面让我们分析每个函数具体使用场景和案例

***error_log 需要手动来记录错误信息***
```php
if (is_file($file)) {
	error_log($file . "is not a file");
}
```
error_log 发送日志到哪儿由第二参数决定，可能如下：

 - 0 - 默认。根据在 php.ini 文件中的 error_log 配置，错误被发送到服务器日志系统或文件。

 - 1 - 错误被发送到 destination 参数中的地址。只有该类型使用 headers 参数。

 - 2 - 通过 PHP debugging 连接来发送错误。该选项只在 PHP 3 中可用。

 - 3 - 错误发送到文件目标字符串。

比如我们可以发送错误到邮箱里面
```php
error_log("some error info", 1, "my@example.com","From: webmaster@example.com");
```

***set_error_handler 设置自定义处理函数***

set_error_handler能够处理的错误级别，由其第二个参数决定，error_reporting设置的错误报告级别不会对其错误的级别有任何影响，因为它由第二参数决定

以下级别的错误不能由用户定义的函数来处理： **E_ERROR**、**E_PARSE**,、**E_CORE_ERROR**、**E_CORE_WARNING**、**E_COMPILE_ERROR**、**E_COMPILE_WARNING**

下面我们来看一个例子：
```php
function myErrorHandler($errno,$errstr){
    echo 'code:['.$errno.']',' description:'.$errstr;
}

$oldErrorHandler=set_error_handler('myErrorHandler');

echo $a;// 使用了未定义变量，此时会调用错误处理函数myErrorHanlder，输出code:[8] description:Undefined variable: a

restore_error_handler();// 恢复成标准处理函数,会提示Undefined variable: a

echo $a;
```

我们把上面个例子中set_error_handler处理的级别改成E_ALL ^ E_NOTICE
```php
$oldErrorHandler=set_error_handler('myErrorHandler', E_ALL ^ E_NOTICE);
```
这时候页面会有2条提示：Undefined variable: a。此时的错误处理又内置处理函数来处理。
