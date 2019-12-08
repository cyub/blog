title: 在Redis中使用Lua脚本
author: tinker
tags:
  - Redis
  - Lua
categories: []
date: 2019-12-01 17:35:00
---
### 简介

Lua诞生于1993年，是一种脚本语言，用C语言编写，其设计目的是为了快捷、高效嵌入到程序应用，比如Nginx服务器脚本。Redis从2.6.0版本开始内置Lua解释器，支持使用Eval命令运行Lua脚本。

在Redis中使用Lua脚本有两大特性：

1. 原子性

    Redis使用单个Lua解释器去运行所有脚本，当其在运行时，其他脚本或命令执行只能等待，这保证脚本已原子性方式运行。
    
2. 高性能

    Lua脚本一次可以执行多个redis命令，可以减少网络开销。对于较大脚本可以先使用`SCRIPT LOAD` 命令将其加载缓存中，然后使用`EVALSHA`运行近一步减少网络开销
    
<!--more-->


### 键和参数

在Redis中使用Lua脚本一个重要命令是EVAL，格式如下：

```
EVAL script numkeys key [key...] arg [arg...]
```

命令参数说明：

1. script参数是lua脚本程序
2. numkeys参数指明键名参数个数
3. key [key...]参数代表Redis键，在Lua脚本中通过KEYS数组访问，第一个键值是KEYS[1],依此类推
4. arg [arg...]参数是附加参数，在Lua脚本中通过全局变量ARGV数组访问，第一个参数值是ARGV[1]，以此类推

**例子1. 不带键和参数的例子：**

```
127.0.0.1:6379> EVAL 'local val="Hello World" return val' 0
"Hello World"
```

其中0代表0个键，后面也没有参数

**例子2. 带键和参数的例子：**

```
127.0.0.1:6379> eval "return {KEYS[1], KEYS[2], ARGV[1], ARGV[2]}" 2 key1 key2 hello world
1) "key1"
2) "key2"
3) "hello"
4) "world"
```

KEYS和ARGV是Lua的两个表(table)。在Lua中表是关联数组，是
Lua中数据结构唯一方法：

1. Lua表的索引(index)，是从1开始的，即mytable[1]是表mytable第一个元素
2. Lua表不能包含nil值。如果某个操作产生的表为[1，nil，3，4]，则结果将为[1]，因为该表在第一个nil值处被截断


在脚本中，我们可以通过`redis.call()`和`redis.pcall()`来执行redis命令。两者除了错误处理方式不一样，其他都一样。

**例子3. 假设构建一个短域名系统**

需求是存储URL，并返回一个唯一数字ID，用于访问URL。我们可以使用INCR从Redis获取唯一ID，然后立即将URL存储在以唯一ID为键的哈希中：

```
// incrset.lua
local link_id = redis.call("INCR", KEYS[1])
redis.call("HSET", KEYS[2], link_id, ARGV[1])
return link_id
```

我们把上面脚本保存在insert.lua文件中，我们redis-cli客户端来测试下：

```
redis-cli --eval incrset.lua links:counter links:urls , http://malcolmgladwellbookgenerator.com/
```

注意：redis-cli的--eval选项支持加载lua脚本

此外Redis提供的Lua脚本相关命令还有：

命令 | 说明
---- | ----
EVALSHA sha1 numkeys key [key ...] arg [arg ...] | 运行sha1对应的Lua脚本
SCRIPT FLUSH | 删除所有脚本缓存
SCRIP EXISTS sha1 [sha1...] | 检查指定的脚本缓存是否存在
SCRIPT LOAD script | 将脚本载入缓存中，并返回脚本sha1
SCRIPT KILL | 杀死正在运行的脚本


### Lua数据类型和Redis数据类型转换

Redis命令执行后返回值类型有5大类型：

类型 |  说明
---- | ----
状态回复（status reply）| 状态回复直接显示状态信息。比如向redis发送set命令设置某个键的值时，redis会回复状态ok表示设置成功，ping命令返回pong。
错误回复（error reply) | 当出现命令不存在或命令格式有错误等情况时，redis会返回错误回复（error reply）。错误回复以error开头，并在后面跟上错误信息。
整数回复（integer reply) | redis虽然没有整数类型，但是却提供了一些用于整数操作的命令，如递增键值的incr命令会以整数形式返回递增后的增值。除此之外，一些其他命令也会返回整数，如可以获取当前数据库中的键的数量的dbsize命令等。
字符串回复（bulk reply）| 当请求一个字符串类型键的键值或者一个其他类型键中的某个元素时，就会得到一个字符串回复，字符串回复以双引号包裹。
多行字符串回复（multi-bulk reply）| 当请求一个非字符串类型键的元素列表时，就会收到多行字符串回复，多行字符串回复中的每行字符串都以一个序号开头
Nil回复(nil reply) | 当请求一个键，不存在时候就会返回nil回复

返回值情况示例：

```
127.0.0.1:6379> SET day 20191201
OK

127.0.0.1:6379> GET day
"20191201"

127.0.0.1:6379> INCR day
(integer) 20191202

127.0.0.1:6379> SADD day 20191205
(error) WRONGTYPE Operation against a key holding the wrong kind of value

127.0.0.1:6379> SADD days 20191201 20191202
(integer) 2

127.0.0.1:6379> SMEMBERS days
1) "20191201"
2) "20191202"

127.0.0.1:6379> GET key_not_exists
(nil)
```


Lua脚本中调用redis命令时候需要把Redis返回值类型转换成Lua类型，脚本最后的执行结果需要转换Redis返回值类型。Lua类型和Redis返回值类型之间存在着一一对应的转换关系：

Lua类型 |	Redis返回类型	| 适用范围
------- | -------- | ------
number	| integer	| <=>
string	| bulk	 | <=>
table（array）| multi bulk | <=>
boolean false	| nil | <=>
boolean true | integer | Lua => redis

**例子4. Lua类型转Redis返回类型测试**
```
27.0.0.1:6379> EVAL "return 3.14" 0
(integer) 3

127.0.0.1:6379> EVAL "return 'hello world'" 0
"hello world"

127.0.0.1:6379> EVAL "return {'hello', 'world'}" 0
1) "hello"
2) "world"

127.0.0.1:6379> EVAL "return false" 0
(nil)

127.0.0.1:6379> EVAL "return true" 0
(integer) 1
```

从上面例子可以看出，Lua浮点数返回之前应该转换成字符串类型，否则出现精度丢失问题。我们可以：

```
local pi = 3.14
redis.call("SET", "pi", pi)
return redis.call("GET", "pi")
```

说明：Redis没有专用的数字类型。当我们SET该值时，Redis将其另存为字符串类型。


### Redis内置库

Redis 内置的 Lua 解释器加载了以下 Lua 库：
1. base
2. table
3. string
4. math
5. debug
6. cjson
7. cmsgpack

**例子5. 使用Redis存储和读取json**

```
// json-get.lua
if redis.call("EXISTS", KEYS[1]) == 1 then
  local payload = redis.call("GET", KEYS[1])
  return cjson.decode(payload)[ARGV[1]]
else
  return nil
end
```

测试：

```
redis-cli set apple '{ "color": "red", "type": "fruit" }'

redis-cli --eval json-get.lua apple , type
# "fruit"
```


### 更多案例

**例子6. 简易速率限制器**

```lua
# 用法 evalsha 089ccf077629d371793d5e928a3f06e9e483eb08 1 ratelimit:192.168.1.1 5 10000
local cnt = redis.call('INCR', KEYS[1])
if cnt > tonumber(ARGV[1])
then
  return 1
end
if cnt == 1
then
  redis.call('PEXPIRE', KEYS[1], ARGV[2])
end
return 0
```

**例子7. 记录一系列值的并均值**

```
# 用法 evalsha 399fddde578fd9cb924edce746c783e8340d8251 2 score:avg score:count 80
local currentval = tonumber(redis.call('get', KEYS[1])) or 0
local count = redis.call('incr', KEYS[2])

currentval = tostring(currentval * (count - 1)/count + (ARGV[1]/count))

redis.call('set', KEYS[1], currentval)
return currentval
```

### 总结

在使用Lua脚本时候需要注意以下几方面：

1. 使用`EVAL/EVALSHA`命令时候，**脚本里使用的所有键都应该由KEYS 数组来传递**。主要是确保Redis集群可以将请求发送到正确的集群节点，毕竟集群是根据key来进行shard的
2. **请确保Lua脚本是纯函数脚本**。涉及随机数，时间戳之类参数，一定要通过ARGV来传递过来，因为Redis每次都会检查脚本缓存是否存在，不存在先缓存起来，若脚本存在可变参数就会就会导致每次脚本都不一样，会大量消耗内存
3. **应该防止执行很慢的Lua脚本**。因为Redis执行脚本是原子性的，执行很慢的脚本这会造成其他客户端被阻塞住。
4. 为了防止不必要的数据泄漏进Lua环境，**Lua脚本只能使用局部变量**，即变量前加local前缀
5. `EVAL`命令中数字参数在Lua中会转换成字符串，**如果需要数字逻辑判断，则需要使用tonumber()方法对字符类型转换数字类型**
6. Lua脚本缓存在redis重启时候会清空。所以**使用`EVALSHA`命令时候一定要注意保证lua脚本缓存一定存在**。一个好的处理逻辑就是先使用`SCRIPT EXISTS sha1`命令检查脚本是否已保存在缓冲中，若保存在缓存中则
直接可使用`EVALSHA`命令，否则则先使用`SCRIPT LOAD script`加载进缓存中，然后再执行`EVALSHA`


### 参考来源

- [Lua: A Guide for Redis Users](https://www.redisgreen.net/blog/intro-to-lua-for-redis-programmers/)
- [A Speed Guide To Redis Lua Scripting](https://www.compose.com/articles/a-quick-guide-to-redis-lua-scripting/)
- [Lua在Redis的应用](https://www.fanhaobai.com/2017/09/lua-in-redis.html)