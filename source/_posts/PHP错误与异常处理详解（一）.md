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

### 错误处理函数

`error_reporting`只是设置错误是否报告，但如果想在发生错误时进行进一步处理，这时候就需要使用内置的错误处理函数了。

常用的错误处理函数如下：更见[错误处理和日志记录](http://php.net/manual/zh/book.errorfunc.php)


| 函数名 | 说明 |
| :------ | :------ | 
| debug_backtrace | 产生一条回溯跟踪信息 |
| error_get_last | 获取最后发生的错误 |
| set_error_handler | 设置用户自定的错误处理函数，会屏蔽系统默认处理程序 |
| restore_error_handler | 恢复之前的错误处理程序 |
| register_shutdown_function | 程序执行完毕时候的回调 |

下面让我们分析每个函数具体使用场景和案例