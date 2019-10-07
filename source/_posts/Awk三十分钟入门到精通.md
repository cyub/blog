title: Awk三十分钟入门到精通
author: tinker
tags:
  - Awk
categories: []
date: 2019-10-04 22:17:00
---
## 简介

Awk是Linux系统中强大的文本处理命令工具。它名字来源于它的创始人 Alfred Aho 、Peter Weinberger 和 Brian Kernighan 姓氏的首个字母。Awk是一个工具，也是一种程序语言，类似c语言，但无需提前进行变量声明定义。一个Awk程序由一系列的模式（pattern)和动作（action)组成, 模式用于描述在输入的文本中搜索哪些数据, 当某一行文本搜索到（即匹配某个模式）之后，动作定义了如何操作该行文本。


## 程序格式
一个awk程序格式如下：

	pattern { action }

awk的操作逻辑是扫描文本每一行, 搜索可以被模式(pattern)匹配的行， 若行能够匹配模式，则接着进行执行动作（action)。

在扫描每一行过程中，awk会自动把当前行分解为一个个的字段，默认是空格进行分割，$0表示当前行内容，$1为当前行的第一段，$2为当前行的第二段，以此类推。

<!--more-->

## 简单输入实验

下面我们进行实例说明，假定有如下职工信息文件emp.data，每一列分别代表是年龄 性别 工作天数 日薪：

    张三    20  M 20 100
    李四    30  M 15 120
    王大锤  22  M 18 150
    张爱花   24 F 22 130
    李丽    22 F  21 160
    李甜甜  21  F 20 122
  
我们想打印每位男性职工姓名和月薪，只需要下面一行：

	awk '$3 == "M" {print $1, $4 * $5}' emp.data
    
将输入一下内容：

	张三 2000
    李四 1800
    王大锤 2700
    
其中`$3=="M"` 是pattern， `print $1, $4* 5`是action，两者通过大括号分开。`print`用于打印数据，且以换行符结束。在`print`语句中由逗号分隔的表达式, 在输出时默认用一个空格符分隔。

正如上面展示那样我们运行一个awk程序需要如下这样：

```
awk awk程序 文本文件
```

当然awk也支持同时处理多个文件：

```
awk awk程序 文本文件1 文本文件2
```

如果awk程序内容较长，我们可以把程序放在一个独立的文件中：

```
awk -f awk程序文件 文本文件
```

在详解讲解模式和动作之前，我们来进行一些简单的练习：

1. 打印所有行

> awk '{print $0}' emp.data

**如果一个动作没有模式, 对于每一个输入行, 该动作都会被执行**。此处的$0可以省略。等效于

>  awk '{print}' emp.data

2. 打印某些字段，这里是姓名和年龄

> awk '{print $1,$2}' emp.data



3. 打印月薪超过2000的员工

> awk '$4 * $5 >2000 {print $1, $4*$5}' emp.data


## 模式

awk模式大致可以分5大类，上面我们使用的都是常规表达式模式，此外还有正则表达式模式，BEGIN/END模式，组合模式，范围模式。

名称 | 语法 | 说明
---- | ---- | ----
BEGIN/END模式 | BEGIN{ statements}或 END{ statements} | BEGIN将在输入被读取之前, statements 执行一次， END会当所有输入被读取完毕之后, statements执行一次
常规表达式模式 | expression { statements} | 每碰到一个使 expression 为真的输入行, statements 就执行. expression 为真指的是其值非零或非空
正则表达式模式 | /regular expression/ { statements} | 当碰到这样一个输入行时, statements 就执行: 输入行含有一段字符串, 而该字符串可以被 regular expression 匹配
组合模式 | compound pattern { statements} | 一个复合模式将表达式用 &&(AND), (OR), !(NOT), 以及括号组合起来; 当 compound pattern 为真时, statements 执行
范围模式 | pattern1, pattern2 { statements} | 一个范围模式匹配多个输入行, 这些输入行从匹配 pattern1 的行开始, 到匹配的行结束 (包括这两行), 对这其中的每一行执行 statements

### BEGIN/END模式

BEGIN/END是唯一不能省略动作的模式。

1. 在打印所有行之前，先打印一个信息头：

> awk 'BEGIN{print "员工基本信息与薪资情况表:"; print ""}{print}' emp.data

上面命令将输出一下内容：

    员工基本信息与薪资情况表:

    张三    20  M 20 100
    李四    30  M 15 120
    王大锤  22  M 18 150
    张爱花   24 F 22 130
    李丽    22 F  21 160
    李甜甜  21  F 20 122
    
    
2. 统计月工作时间超过20天的员工数：

> awk '$4>20 {num++} END{print num"个人月工作时间超过20天"}' emp.data

上面命令输出：

> 2个人月工作时间超过20天

num是awk自定义变量，print打印内容时候，字符串会自动拼接起来。


### 表达式模式

在awk中，任意一个表达式都可以当作模式来使用。**如果一个作为模式使用的表达式, 对当前输入行的求值结果非零或不为空, 那么该模式就匹配该行**。典型的表达式模式是那些涉及到数值或字符串比较的表达式。 一个比较表达式包含 6 种关系运算符中的一种, 或者包含两种字符串匹配运算符中的一种: ~ 与 !~

关系运算符列如下表：

运算符 | 意义
--- | ---
<  | 小于
<= | 小于或等于
== | 等于
!= | 不等于
>= |  大于或等于
> | 大于
~ | 匹配
!~ | 不匹配


在一个关系比较中, 如果两个操作数都是数值, 关系比较将会按照数值比较进行; 否则的话,数值操作数会被转换成字符串, 再将操作数按字符串的形式进行比较. 两个字符串间的比较以自然排序的方式进行比较。

查看员工王大锤的信息，我们可以使用表达式模式

> awk '$1=="王大锤" {print $0}' emp.data

输入以下内容：

	王大锤  22  M 18 150

除了常规的表达式之外，awk还支持正则表达式模式，来测试一个字符串是否包含一段可以被正则表达式匹配的子字符串。当然严格的来讲正则表达式模式是表达式模式的一种。正则表达式模式常用于字符串比较，也称为字符串匹配模式。

有三种字符串匹配模式：

语法 | 说明
---- | ----
/regexpr/ | 当当前输入行包含一段能够被 regexpr 匹配的子字符串时, 该模式被匹配
expression ~ /regexpr/ | 如果 expression 的字符串值包含一段能够被 regexpr 匹配的子字符时, 该模式被匹配
expression !~ /regexpr/ | 如果 expression 的字符串值不包含能够被 regexpr 匹配的子字符串, 该模式被匹配。在 ~ 与 !~ 的语境中, 任意一个表达式都可以用来替换 /regexpr/

下面是几个匹配的例子：

1. 获取输入行里面包含20的信息

> awk '/20/ {print $0}' emp.data

输出内容如下：

    张三    20  M 20 100
    李四    30  M 15 120
    李甜甜  21  F 20 122
    
上面awk程序本质上是`awk '$0 ~ /20/ {print $0}' emp.data`的缩写

2. 获取所有李姓职工的信息

> awk '$1 ~ /李/ {print $0}' emp.data

输出一下内容：

    李四    30  M 15 120
    李丽    22 F  21 160
    李甜甜  21  F 20 122
    
    
3. 获取月工作21或22天的职工信息

> awk '$4 ~/^2[12]$/ {print $0}' emp.data

上面程序将会输出以下内容：

    张爱花   24 F 22 130
    李丽    22 F  21 160
    
由于正则表达式内容比较多，这就不在详细介绍正则表达式了。可以自行去[《正则表达式30分钟入门教程》](https://deerchao.cn/tutorials/regex/regex.htm)学习。

### 组合模式

模式通过括号, 逻辑运算符 ||(OR), &&(AND),!(NOT) 进行组合，就构成一个组合模式。**运算符 || 优先级最低, 再往高是 &&, 最高的是 !。 && 与 || 从左至右计算操作数的值, 一旦已经知道整个表达式的值, 计算便停止**。

比如我们想统计李姓女性员工信息：

> awk '$1 ~ /李/ && $3 == "F" {print $0}' emp.data

上面程序将会输出：

    李丽    22 F  21 160
    李甜甜  21  F 20 122
    
 
### 范围模式

一个范围模式由两个被逗号分开的模式组成, 正如

		pattern1, pattern2
        
一个范围模式匹配多个输入行, 这些输入行从匹配 pattern1 的行开始, 到匹配 pattern2 的行结束(包括这两行);如果范围模式的第二个模式一直都没有匹配到某个输入行, 那么范围模式会一直匹配到输入结束。pattern2可以与 pattern1可以匹配到同一行。


我们拿下面的例子做说明，我们想王大锤到李丽的员工信息：

> awk '$1 == "王大锤", $1 == "李丽" {print $0}' emp.data

上面程序将输出以下内容：

    王大锤  22  M 18 150
    张爱花   24 F 22 130
    李丽    22 F  21 160
    
    
## 动作

动作描述了输入行被搜索匹配到之后，接下来该如何操作。构成动作的语句可以是表达式或者流程控制语句，比如if/where/for等语句。

表达式语句可以简单到只有一个`print`,也可以是变量，赋值，函数调用。

### 变量

awk里面变量可以分三类：用户自定义变量（user defined variables)、内置变量（Built-In Variables）、字段变量（Field Variables）。一个未初始化的变量的值是 "" (空字符串) 与 0。

下面是使用自定义变量统计职工总数的例子：

> awk '{emp =emp+1} END{print "总共人数:"emp}' emp.data

#### 内置变量

下面内置变量列表：

变量 | 意义 | 默认值
---- | --- | ---
ARGC | 命令行参数的个数 | -
ARGV | 命令行参数数组 | -
FILENAME | 当前输入文件名 | -
FNR | 当前输入文件的记录个数 | -
FS | 控制着输入行的字段分割符 |  " "
NF | 当前记录的字段个数 | -
NR | 到目前为止读的记录数量 | -
OFMT | 数值的输出格式 | "%.6g"
OFS | 输出字段分割符 | " "
ORS | 输出的记录的分割符 | "\n"
RLENGTH | 被函数 match 匹配的字符串的长度 | -
RS | 控制着输入行的记录分割符 | "\n"
RSTART | 被函数 match 匹配的字符串的开始 |
SUBSEP | 下标分割符 | "\034"

打印`/etc/passwd`文件中的用户

> awk 'BEGIN{FS=":"} {print $1}' /etc/passwd

通过更改内置变量`FS`来改变文本分隔符。awk也支持选项`-F`来改变文本分隔符。

> awk -F: '{print $1}' /etc/passwd


#### 字段变量

字段变量 (Field Variables). 当前输入行的字段从 $1, $2, 一直到 $NF; $0 表示整行. 字段变量与其他变量相比没什么不同 — 它们也可以用在算术或字符串运算中, 也可以被赋值。

下面语句将打印每一行内容，并加上行号：

> awk '{ print NR ":" $0 }' emp.data

打印出内容如下：

    1:张三    20  M 20 100
    2:李四    30  M 15 120
    3:王大锤  22  M 18 150
    4:张爱花   24 F 22 130
    5:李丽    22 F  21 160
    6:李甜甜  21  F 20 122
    

### 函数
awk变量类型分为两类，数字和字符串。awk内置的函数有算术函数（(Built-In Arithmetic Functions）和字符串函数（

#### 算术函数

算术函数列表有：

函数 | 返回值
--- | ---
atan2(y,x) | y/x 的反正切值, 定义域在 −π 到 π 之间
cos(x) | x 的余弦值, x 以弧度为单位
exp(x) | x 的指数函数, e^x
int(x) | x 的整数部分; 当 x 大于 0 时, 向 0 取整
log(x) | x 的自然对数 (以 e 为底)
rand() | 返回一个随机数 r, 0 ≤ r < 1
sin(x) | x 的正弦值, x 以弧度为单位.
sqrt(x) | x 的方根
srand(x) | x 是 rand() 的新的随机数种子


#### 字符串函数

字符串函数列表：

函数 | 描述
--- | ---
gsub(r,s) | 将 $0 中所有出现的 r 替换为 s, 返回替换发生的次数.
gsub(r,s,t ) | 将字符串 t 中所有出现的 r 替换为 s, 返回替换发生的次数
index(s,t) | 返回字符串 t 在 s 中第一次出现的位置, 如果 t 没有出现的话, 返回0
length(s) | 返回 s 包含的字符个数
match(s,r) | 测试 s 是否包含能被 r 匹配的子串, 返回子串的起始位置或 0; 设置 RSTART 与 RLENGTH
split(s,a) | 用 FS 将 s 分割到数组 a 中, 返回字段的个数
split(s,a,fs) | 用 fs 分割 s 到数组 a 中, 返回字段的个数
sprintf(fmt,expr-list) | 根据格式字符串 fmt 返回格式化后的 expr-list
sub(r,s) | 将 $0 的最左最长的, 能被 r 匹配的子字符串替换为 s, 返回替换发生的次数.
sub(r,s,t) | 把 t 的最左最长的, 能被 r 匹配的子字符串替换为 s, 返回替换发生的次数.
substr(s,p) | 返回 s 中从位置 p 开始的后缀.
substr(s,p,n) | 返回 s 中从位置 p 开始的, 长度为 n 的子字符串.


下面例子是将性别简写M替换成男,F替换成女

> awk '{gsub("M", "男");gsub("F", "女")} {print $0}' emp.data

上面程序输出以下内容：

    张三    20  男 20 100
    李四    30  男 15 120
    王大锤  22  男 18 150
    张爱花   24 女 22 130
    李丽    22 女  21 160
    李甜甜  21  女 20 122


### 流程控制语句

awk的动作支持多种流程控制语句，比如IF-Else, while, do-while等。

1. if (expression)statements
如果 expression 为真, 执行 statements
2. if (expression) statements1 else statements2
如果 expression 为真, 执行 statements1, 否则执行 statements2

3. while (expression) statements
如果 expression 为真, 执行 statements; 然后重复前面的过程

4. for (expression1;expression2;expression3 ) statements
等价于 expression1; while (expression2) { statements; expression3}

5. for (variable in array) statements
轮流地将 variable 设置为 array 的每一个下标, 并执行 statements

6. do statements while (expression)
执行 statements; 如果 expression 为真就重复


下面分别使用while和for来打印每个字段信息：

while:

    { i = 1
    while (i <= NF) {
            print $i
            i++
    }
    }
    

if:

    { for (i = 1; i <= NF; i++)
        print $i
    }


do-while:

    {
    i = 1
    do {
            print $i
    } while (i++ < NF)
    }



## 参考

- AWK 程序设计语言
