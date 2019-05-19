title: PHP7各个版本新增特性
date: 2019-05-19 19:38:12
tags:
---
PHP从5.6 跳过6直接来到7，带来新的语言特性，更带来性能很大飞越。根据w3techs统计截止截止2019年5月18月有79%网站使用PHP做为服务端开发语言，这些网站使用的PHP版本统计如下：

<iframe src="https://export.cyub.vip/i?all=%7B%22chart%22%3A%7B%22plotBackgroundColor%22%3Anull%2C%22plotBorderWidth%22%3Anull%2C%22plotShadow%22%3Afalse%2C%22type%22%3A%22pie%22%7D%2C%22title%22%3A%7B%22text%22%3A%22PHP%E7%89%88%E6%9C%AC%E4%BD%BF%E7%94%A8%E5%88%86%E5%B8%83%22%7D%2C%22tooltip%22%3A%7B%22pointFormat%22%3A%22%7Bseries.name%7D%3A%20%3Cb%3E%7Bpoint.percentage%3A.1f%7D%25%3C%2Fb%3E%22%7D%2C%22plotOptions%22%3A%7B%22pie%22%3A%7B%22allowPointSelect%22%3Atrue%2C%22cursor%22%3A%22pointer%22%2C%22dataLabels%22%3A%7B%22enabled%22%3Atrue%2C%22format%22%3A%22%3Cb%3E%7Bpoint.name%7D%3C%2Fb%3E%3A%20%7Bpoint.percentage%3A.1f%7D%20%25%22%7D%7D%7D%2C%22series%22%3A%5B%7B%22name%22%3A%22Version%22%2C%22colorByPoint%22%3Atrue%2C%22data%22%3A%5B%7B%22name%22%3A%22PHP%205.x%22%2C%22y%22%3A66.9%7D%2C%7B%22name%22%3A%22PHP%207.x%22%2C%22y%22%3A32.5%2C%22color%22%3A%22%23e4d354%22%7D%2C%7B%22name%22%3A%22PHP%204.x%22%2C%22y%22%3A0.6%7D%2C%7B%22name%22%3A%22PHP%203.x%22%2C%22y%22%3A0.1%7D%5D%7D%5D%7D&width=490&height=360" width="490" height="370" overflow="hide" frameborder="0">
 
 <!--more-->

{% iframe https://export.cyub.vip/i?all=%7B%22chart%22%3A%7B%22plotBackgroundColor%22%3Anull%2C%22plotBorderWidth%22%3Anull%2C%22plotShadow%22%3Afalse%2C%22type%22%3A%22pie%22%7D%2C%22title%22%3A%7B%22text%22%3A%22PHP%E7%89%88%E6%9C%AC%E4%BD%BF%E7%94%A8%E5%88%86%E5%B8%83%22%7D%2C%22tooltip%22%3A%7B%22pointFormat%22%3A%22%7Bseries.name%7D%3A%20%3Cb%3E%7Bpoint.percentage%3A.1f%7D%25%3C%2Fb%3E%22%7D%2C%22plotOptions%22%3A%7B%22pie%22%3A%7B%22allowPointSelect%22%3Atrue%2C%22cursor%22%3A%22pointer%22%2C%22dataLabels%22%3A%7B%22enabled%22%3Atrue%2C%22format%22%3A%22%3Cb%3E%7Bpoint.name%7D%3C%2Fb%3E%3A%20%7Bpoint.percentage%3A.1f%7D%20%25%22%7D%7D%7D%2C%22series%22%3A%5B%7B%22name%22%3A%22Version%22%2C%22colorByPoint%22%3Atrue%2C%22data%22%3A%5B%7B%22name%22%3A%22Version%205%22%2C%22y%22%3A66.9%7D%2C%7B%22name%22%3A%22Version%207%22%2C%22y%22%3A32.5%2C%22color%22%3A%22%23e4d354%22%7D%2C%7B%22name%22%3A%22Version%204%22%2C%22y%22%3A0.6%7D%2C%7B%22name%22%3A%22Version%203%22%2C%22y%22%3A0.1%7D%5D%7D%5D%7D&width=490&height=360 %}

其中PHP 5 和 PHP 7细化分布下：


<iframe src="https://export.cyub.vip/i?all=%7B%22chart%22%3A%7B%22plotBackgroundColor%22%3Anull%2C%22plotBorderWidth%22%3Anull%2C%22plotShadow%22%3Afalse%2C%22type%22%3A%22pie%22%7D%2C%22title%22%3A%7B%22text%22%3A%22PHP7%20%E7%89%88%E6%9C%AC%E4%BD%BF%E7%94%A8%E5%88%86%E5%B8%83%22%7D%2C%22tooltip%22%3A%7B%22pointFormat%22%3A%22%7Bseries.name%7D%3A%20%3Cb%3E%7Bpoint.percentage%3A.1f%7D%25%3C%2Fb%3E%22%7D%2C%22plotOptions%22%3A%7B%22pie%22%3A%7B%22allowPointSelect%22%3Atrue%2C%22cursor%22%3A%22pointer%22%2C%22dataLabels%22%3A%7B%22enabled%22%3Atrue%2C%22format%22%3A%22%3Cb%3E%7Bpoint.name%7D%3C%2Fb%3E%3A%20%7Bpoint.percentage%3A.1f%7D%20%25%22%7D%7D%7D%2C%22series%22%3A%5B%7B%22name%22%3A%22Version%22%2C%22colorByPoint%22%3Atrue%2C%22data%22%3A%5B%7B%22name%22%3A%22PHP%207.2%22%2C%22y%22%3A34.3%7D%2C%7B%22name%22%3A%22PHP%207.0%22%2C%22y%22%3A33.6%2C%22color%22%3A%22%23e4d354%22%7D%2C%7B%22name%22%3A%22PHP%207.1%22%2C%22y%22%3A26.9%7D%2C%7B%22name%22%3A%22PHP%207.3%22%2C%22y%22%3A5.2%7D%2C%7B%22name%22%3A%22PHP%207.4%22%2C%22y%22%3A0.1%7D%5D%7D%5D%7D&width=490&height=360" width="490" height="370" overflow="hide" frameborder="0">
 
{% iframe https://export.cyub.vip/i %}

<iframe src="https://export.cyub.vip/i?all=%7B%22chart%22%3A%7B%22plotBackgroundColor%22%3Anull%2C%22plotBorderWidth%22%3Anull%2C%22plotShadow%22%3Afalse%2C%22type%22%3A%22pie%22%7D%2C%22title%22%3A%7B%22text%22%3A%22PHP5%20%E7%89%88%E6%9C%AC%E4%BD%BF%E7%94%A8%E5%88%86%E5%B8%83%22%7D%2C%22tooltip%22%3A%7B%22pointFormat%22%3A%22%7Bseries.name%7D%3A%20%3Cb%3E%7Bpoint.percentage%3A.1f%7D%25%3C%2Fb%3E%22%7D%2C%22plotOptions%22%3A%7B%22pie%22%3A%7B%22allowPointSelect%22%3Atrue%2C%22cursor%22%3A%22pointer%22%2C%22dataLabels%22%3A%7B%22enabled%22%3Atrue%2C%22format%22%3A%22%3Cb%3E%7Bpoint.name%7D%3C%2Fb%3E%3A%20%7Bpoint.percentage%3A.1f%7D%20%25%22%7D%7D%7D%2C%22series%22%3A%5B%7B%22name%22%3A%22Version%22%2C%22colorByPoint%22%3Atrue%2C%22data%22%3A%5B%7B%22name%22%3A%22PHP%205.6%22%2C%22y%22%3A45.5%7D%2C%7B%22name%22%3A%22PHP%205.4%22%2C%22y%22%3A19.1%2C%22color%22%3A%22%23e4d354%22%7D%2C%7B%22name%22%3A%22PHP%205.3%22%2C%22y%22%3A15.6%7D%2C%7B%22name%22%3A%22PHP%205.5%22%2C%22y%22%3A12.9%7D%2C%7B%22name%22%3A%22PHP%205.2%22%2C%22y%22%3A6.5%7D%2C%7B%22name%22%3A%22PHP%205.1%22%2C%22y%22%3A0.4%7D%2C%7B%22name%22%3A%22PHP%205.0%22%2C%22y%22%3A0.1%7D%2C%7B%22name%22%3A%22PHP%205.7%22%2C%22y%22%3A0.1%7D%5D%7D%5D%7D&width=490&height=360" width="490" height="370" overflow="hide" frameborder="0">


{% iframe https://export.cyub.vip/i %}


这里我们不探讨性能提升方面，只是看看PHP7带来了哪些语言上的新特性。下面是PHP7各个版本新增特性详细说明：


## 7.0.x

### 新特性

#### null合并运算符

PHP 5中我们常使用isset和三目运算符来判断变量是否存在，PHP 7开始可以使null合并运算符(??)，如果变量存在且值不为NULL，则返回自身的值，否则返回它的第二个操作数。

```
<?php

$x = NULL;
$y = NULL;
$z = 3;
var_dump($x ?? $y ?? $z); // int(3)
 
$x = ["c" => "meaningful_value"];
var_dump($x["a"] ?? $x["b"] ?? $x["c"]); //  string(16) "meaningful_value"
```

#### 太空船操作符

太空船操作符(<=>),用于两个表达式，当$a小于、等于或者大于$b时，分别返回-1、0、1

```
$array = [1, 2, 3, 4, 6];
// PHP 5
usort($array, function ($a, $b) {
    return ($a < $b) ? -1 : ($a = $b ? 0 : 1);
});

// PHP 7
usort($array, function ($a, $b) {
    return $a <=> $b;  
});
```

#### 新增整数除法函数intdiv()

intdiv用于整数的除法运算

```
<?php

var_dump(intdiv(10, 3)); // int(3)
```

#### 标量参数类型声明

PHP 5也支持参数类型声明，但它只支持复合变量类型声明，比如类或数组声明。PHP 7 开始之后支持int,bool等标量类型声明了。具体支持支持类型如下：


类型 | 描述 | 最低 PHP版本
---|--- | ----
class/interface name | 参数必须是类或者接口的一个实例 | PHP 5.0.0
self | 参数必须是当前类的实例 | PHP 5.0.0
array | 参数必须是一个数组 | PHP 5.1.0
callable | 参数必须是一个[可回调类型](https://www.php.net/manual/zh/language.types.callable.php) | PHP 5.4.0
bool | 参数必须布尔类型 | PHP 7.0.0
float | 参数必须是浮点类型 | PHP 7.0.0
int | 参数必须是整数类型 | PHP 7.0.0
string | 参数必须是字符串类型 | PHP 7.0.0

#### 返回值类型声明

返回类型声明指明了函数返回值的类型。可用的类型与参数声明中可用的类型相同, 见上表


```
<?php

interface A {
    static function make(): A;
}
class B implements A {
    static function make(): A {
        return new B();
    }
}

```


#### 通过define()定义常量数组

PHP 5.6中只能通过const定义数组常量，现在可以通过define()来定以

```
<?php
define('ANIMALS', [
    'dog',
    'cat',
    'bird'
]);

echo ANIMALS[1]; // 输出 "cat"
```

#### 匿名类

PHP 7 开始支持同 new class 来实例化一个匿名类，

```
<?php

$di = new DI();

$di->setLogger(new class {
    public function log(string $msg) {
        echo $msg;
    }
    }
})
```

#### Closure::call()

Closure::call() 用于绑定一个方法到对象上闭包并调用它，并有着更好的性能

```
<?php


```

### 变更

#### 错误和异常处理

PHP 7 起大部分错误可以被作为Error异常抛出。PHP 5 使用错误报告等来处理错误， 可参看[PHP错误与异常处理详解（一）](https://www.cyub.vip/2018/05/17/PHP%E9%94%99%E8%AF%AF%E4%B8%8E%E5%BC%82%E5%B8%B8%E5%A4%84%E7%90%86%E8%AF%A6%E8%A7%A3%EF%BC%88%E4%B8%80%EF%BC%89/)。

PHP 7 抛出的Error 可以通过catch(Error $e) {}来捕获或注册异常处理函数set_exception_handler来捕获。所有异常和错误类都实现了Throwalble接口。

Error的层次接口结构：

- Throwable
    - Error
        - ArithmeticError
            - DivisionByZeroError
        - DivisionByZeroError
        - AssertionError
        - ParseError
        - TypeError
            - ArgumentCountError
    - Exception
        - ClosedGeneratorException
        - DOMException
        - ErrorException
        - IntlException
        - LogicException
            - BadFunctionCallException
                - BadMethodCallException
            - DomainException
            - InvalidArgumentException
            - LengthException
            - OutOfRangeException
        - PharException
        - ReflectionException
        - RuntimeException
            - OutOfBoundsException
            - OverflowException
            - PDOException
            - RangeException
            - UnderflowException
            - UnexpectedValueException


`set_exception_handler()`接收的对象不一定是Exception对象，有可能是Error对象

```
// PHP 5 时代代码
func handler(Excetion $e) { ... } // 如果此时接受到Error对象，将会导致fatal error
set_exception_handler('handler')

// 兼容PHP 5 和 7
function handler($e) {...}

// 仅支持 PHP 7
function handler(Throwalbe $e) { ... }
```

#### foreach变化

##### 循环时候不在改变内部数组指针

PHP 7之前，当数组通过foreach 迭代时候，数组指针会移动。

```
<?php
$array = [0, 1, 2];
foreach ($array as &$val) {
}

var_dump(current($array); // php 5 输出 bool(false); php 7 输出int(1)
```

##### 通过引用遍历时候，能够动态更该遍历

```
<?php
$array = [0];
foreach ($array as &$val) { // 注意此处一定是引用遍历，否则没有效果
    var_dump($val);
    $array[1] = 1;
}
```

PHP 5 输出：

```
int(0)
```

PHP 7 输出：

```
int(0)
int(1)
```

注意PHP 5 和 PHP 7最后的数组$array都会多一个元素1

```
<?php

$array = [0, 1];
```

更多PHP 7.0.x 变更与新特性见[从PHP 5.6.x 移植到 PHP 7.0.x](https://www.php.net/manual/zh/migration70.php)


#### 性能的提升与内存使用减少

PHP 7速度相比 5.6提升了2倍

![php7_improved_performance](https://static.cyub.vip/images/201905/php7_improved_performance.png)

内存使用显著下降

![php7_reduced_memory_usage](https://static.cyub.vip/images/201905/php7_reduced_memory_usage.png)

## 7.1.x

### 新特性

#### 可为空(Nullable)类型

参数类型和返回值类型支持可为空类型。当在类型前面加一个问，传入的参数或函数返回值要么是该类型，要么是null

```
<?php

function answer(): ?int  {
    return null; //ok
}

function answer(): ?int  {
    return 42; // ok
}

function answer(): ?int {
    return new stdclass(); // error
}
function say(?string $msg) {
    if ($msg) {
        echo $msg;
    }
}

say('hello'); // ok -- prints hello
say(null); // ok -- does not print
say(); // error -- missing parameter
say(new stdclass); //error -- bad type
```

#### void类型返回值类型

一个新的返回值类型void被引入。 返回值声明为 void 类型的方法要么干脆省去 return 语句，要么使用一个空的 return 语句。 对于 void 函数来说，NULL 不是一个合法的返回值，试图去获取void方法的返回值会得到NULL

```
<?php
function swap(&$left, &$right) : void
{
    if ($left === $right) {
        return;
    }

    $tmp = $left;
    $left = $right;
    $right = $tmp;
}

$a = 1;
$b = 2;
var_dump(swap($a, $b), $a, $b);
```

上面程序会输出：

```
null
int(2)
int(1)
```

#### iterable类型

iterable类型可用于参数类型提示，或者返回值类型提示，表明参数或返回值是一个数组或者实现了`Traversable`接口的对象。

iterable类型可用于foreach循环。

```
<?php
function foo(iterable $iterable) {
    foreach ($iterable as $value) {
        // ...
    }
}
```

#### 数组解构赋值

结构赋值实现list()类似功能

```
<?php
$array = [1, 2, 3];
[$a, $b, $c] = $array; 
// 效果跟list($a, $b, $c) = $array; 一样

// 支持键名
$array = ['a' => 1, 'b' => 2, 'c' => 3];
["a" => $a, "b" => $b, "c" => $c] = $array;

$data = [
    [1, 'Tom'],
    [2, 'Fred'],
];
foreach ($data as list($id, $name)) {
}

foreach ($data as [$id, $name]) {
}
```

#### list()增强支持键名

```
<?php
$array = ['a' => 1, 'b' => 2, 'c' => 3];
list("a" => $a, "b" => $b, "c" => $c) = $array;
```

#### 支持捕获多个类型

```
<?php

try {
   // Some code...
} catch (ExceptionType1 | ExceptionType2 $e) {
   // Code to handle the exception
} catch (\Exception $e) {
   // ...
}
```

#### 支持负的字符串偏移量

一个负数的偏移量表明从字符串结尾开始的偏移量
```
<?php
var_dump("abcdef"[-2]);
var_dump(strpos("aabbcc", "b", -3));
```

上面程序将会输出

```
string (1) "e"
int(3)
```

#### is_iterable()验证变量是否是可迭代类型

is_iterable用来验证变量是否是iterable伪类类型

```
<?php
var_dump(is_iterable([1, 2, 3]));  // bool(true)
var_dump(is_iterable(new ArrayIterator([1, 2, 3])));  // bool(true)
var_dump(is_iterable((function () { yield 1; })()));  // bool(true)
var_dump(is_iterable(1));  // bool(false)
var_dump(is_iterable(new stdClass()));  // bool(false)
```

## 7.2.x

### 对象类型

对象类型用于输入参数和函数返回值都是任何对象乐西

```
<?php

function test(object $obj) : object
{
    return new SplQueue();
}

test(new StdClass());
```

### 参数类型拓展

重写方法和接口实现的参数类型可以使任意类型，即使父类方法指定一个固定的参数类型

```
<?php

interface A
{
    public function Test(array $input);
}

class B implements A
{
    public function Test($input){} // type omitted for $input
}
```

更多新特性与变更见[从PHP 7.1.x 移植到 PHP 7.2.x ](https://www.php.net/manual/zh/migration72.php)

## 7.3.x

### json_decode()抛出异常

json_decode()第二个参数传入`JSON_THROW_ON_ERROR`,那么当json解析失败是，会抛出`JsonException`异常

7.2之前（含7.2）的获取json解析错误使用如下方法：

```
<?php

json_decode("{");
json_last_error() === JSON_ERROR_NONE // 结果是false
echo json_last_error_msg() // 输出 "Syntax error"
```

7.3起我们可以捕获json处理异常了：
```
<?php

use JsonException;
 
try {
    $json = json_encode("{", JSON_THROW_ON_ERROR);
    return base64_encode($json);
} catch (JsonException $e) {
    echo $e->getMessage(); // 类似json_last_error_msg()
    echo $e->getCode(); // 类似 json_last_error()
}
```

### is_countable()验证变量是否可以计数类型

```
<?php

// 7.3之前
if (is_array($foo) || $foo instanceof Countable) {
    // $foo is countable
}
// 7.3开始
if (is_countable($foo)) {
    // $foo is countable
}
```

### array_key_first(), array_key_last()获取数组第一个和最后一个key

```
<?php

$firstKey = array_key_first($array);
$lastKey = array_key_last($array);
```

### list支持引用赋值

```
<?php

$array = [1, 2];
list($a, &$b) = $array;
```

等效于：

```
<?php

$array = [1, 2];
$a = $array[0];
$b =& $array[1];
```

## 参考

- [PHP 官方文档之各版本迁移](https://www.php.net/manual/zh/appendices.php)
- [Evolution of PHP — v5.6 to v8.0](https://medium.com/@meskis/evolution-of-php-v5-6-to-v8-0-c3514ebb7f28)
- [Usage statistics and market share of PHP for websites](https://w3techs.com/technologies/details/pl-php/all/all)
- [The PHP Benchmark](https://phpbench.com/)
- [How Fast is WordPress with PHP-FPM 7 Compare to 5?](https://geekflare.com/wordpress-php-fpm7/)