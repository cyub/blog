title: PHP反射API初探
tags:
  - PHP
categories:
  - 开发语言
date: 2017-08-21 22:44:00
---

## 1. 什么是反射
反射在百度百科里面的解释是“反射是一种计算机处理方式。有程序可以访问、检测和修改它本身状态或行为的这种能力。能提供封装程序集、类型的对象”。

PHP提供了对类、函数、方法以及拓展进行反射的能力。通过反射我们可以在动态运行程序时候，获取类的名字，参数，方法、注释等信息以及动态调用对象方法，通过这些可以实现自动生成文档、自动注入依赖，插件管理。

反射的优点：
1. 反射提高了程序的灵活性和扩展性。
2. 降低耦合性，提高自适应能力。
3. 它允许程序创建和控制任何类的对象，无需提前硬编码目标类。
<!-- more -->

## 2. PHP反射API
PHP虽然提供了诸如class_exists(),method_exists(),get_class(),get_calss_methods()等`Introspection Functions`，来获取类/对象信息，但获取的信息有限，而反射API提供了丰富的功能来获取对象信息，以及操作对象

PHP反射API常用部分：

| 类 | 说明 |
| :--- | :--- |
| ReflectionClass | 反射类信息 |
| ReflectionMethod | 反射类方法信息 |
| ReflectionFunction | 反射函数信息 |
| ReflectionExtension | PHP拓展信息 |
| ReflectionException | 反射异常信息 |

### 2.1. 反射类/对象
反射类或者对象的信息使用ReflectionClass这个类，常用的操作如下：
#### 2.1.1. 实例化对象
```php
$class = new ReflectionClass('mysqli');
$args = ['localhost', 'root', '', 'forge'];
$mysqli = $class->newInstanceArgs($args);
if ($mysqli->connect_error) {
    die('Connect error:' . $mysqli->connect_errno . ' ' . $mysqli->connect_error);
}

$result = $mysqli->query('show tables', MYSQLI_USE_RESULT);
while ($row = $result->fetch_row()) {
    printf("%s\n", $row[0]);
}

```
#### 2.1.2. 获取常量
```php
$class = new ReflectionClass('mysqli');
$constants = $class->getConstants(); // 获取所有常量，以数组形式返回
$constant = $class->getConstant('CONSTANT_NAME'); // 根据常量名称获取常量值
$isDefined = $class->hasConstant('CONSTANT_NAME'); // 判断常量是否定义过
```

#### 2.1.3. 获取属性
```php
$props = $class->getProperties(ReflectionProperty::IS_STATIC | ReflectionProperty::IS_PUBLIC); //返回ReflectionProperty对象数组
foreach ($props as $prop) {
    echo $prop->getName() . '=' . $prop->getValue($mysqli) . "\n";
}

// 根据属性名获取属性
$prop = $class->getProperty('host_info');
echo $prop->getName() . '=' . $prop->getValue($mysqli);
```
getProperties方法部分参数如下：
* ReflectionProperty::IS_STATIC
* ReflectionProperty::IS_PUBLIC
* ReflectionProperty::IS_PROTECTED
* ReflectionProperty::IS_PRIVATE

#### 2.1.4. 获取方法
```php
// 只返回public和静态方法，ReflectionMethod对象数组
$methods = $class->getMethods(ReflectionMethod::IS_PUBLIC | ReflectionMethod::IS_STATIC);
foreach ($methods as $method) {
    echo $method->getName() . "\n";
}

$method = $class->getMethod('stat'); // 通过方法名称返回方法
print_r($method->invoke($mysqli)); // 调用方法
```
getMethods部分可用参数如下：
* ReflectionMethod::IS_STATIC
* ReflectionMethod::IS_PUBLIC
* ReflectionMethod::IS_PROTECTED
* ReflectionMethod::IS_FINAL

#### 2.1.5. 获取类文件名称、行数等信息
```php
class Cat
{
    private $name = 'tom';
}
$class = new ReflectionClass('Cat');
echo $class->getFileName();//输出Cat
$file = file('./cat.php');
$offset = $class->getStartLine() - 1;
$length = $class->getEndLine() - $class->getStartLine() + 1); 
echo implode('', array_slice($file, $offset, $length); // 输出类定义代码
```

* getFileName 获取类被定义的文件的文件名，内置或拓展类返回false
* getStartLine 获取类定义文件起始行号，内置或拓展类返回false
* getEndLine 获取类定义的结束行号，内置或拓展类返回false

### 2.2. 反射类方法

#### 2.2.1. 判断方法可见性
* isPublic 
* isPrivate
* isProtected

```php
$method = new ReflectionMethod('mysqli', 'stat');
$isPublic = $method->isPublic(); // true
```

#### 2.2.2. 获取方法参数
```php
$method = new ReflectionMethod('mysqli', 'query');
echo $method->getNumberOfParameters(); // 方法参数数量
echo $method->getNumberOfRequiredParameters(); // 必须传递参数值的参数数量

$params =  $method->getParameters(); // 返回ReflectionParameter对象数组
foreach ($params as $param) {
    $name = $param->getName();
    if ($param->isDefaultValueAvailable()) {
       echo "$name=" . $param->getDefaultValue();
    } else {
        echo "$name don't have default value";
    }
}
```

## 3. 反射应用示例

### 3.1. 控制器层的方法动态调用
这里只是简单演示，所以路由只是简单处理的，控制器文件直接写在一起了，而不是独立文件并自动载入，

```php
// index.php?m=Home&a=hello
// 简单的路由
define('CONTROLLER', ucfirst(isset($_REQUEST['m']) ? $_REQUEST['m'] : 'Home') . 'Controller');
define('ACTION', isset($_REQUEST['a']) ? $_REQUEST['a'] : 'index');

class HomeController
{
    public function __construct()
    {
        echo __METHOD__ . "\n";
    }

    public function index()
    {
        echo __METHOD__ . "\n";
    }

    public function __beforeHello()
    {
        echo __METHOD__ . "\n";
    }

    public function __afterHello()
    {
        echo __METHOD__ . "\n";
    }

    public function hello()
    {
        echo __METHOD__ . "\n";
        echo "==>hello world!\n";
    }
}

$method = new ReflectionMethod(CONTROLLER, ACTION);
if ($method->isPublic()) {
    $class = new ReflectionClass(CONTROLLER);
    $classObj = $class->newInstance();
    if ($class->hasMethod('__before' . ucfirst(ACTION))) { // 前置操作
        $beforeMethod = new ReflectionMethod(CONTROLLER, '__before' . ucfirst(ACTION));
        if ($beforeMethod->isPublic()) {
            $beforeMethod->invoke($classObj);
        }
    }
    $method->invoke($classObj); // 当前Action
    if ($class->hasMethod('__after' . ucfirst(ACTION))) { // 后置操作
        $afterMethod = new ReflectionMethod(CONTROLLER, '__after' . ucfirst(ACTION));
        if ($afterMethod->isPublic()) {
            $afterMethod->invoke($classObj);
        }
    }
} else {
    throw new ReflectionException("Action is not public");
}
```

### 3.2. 类属性根据配置自动设置
根据配置文件动态set类属性

```php
class Upload
{
    ...
    public function initialize(array $config = array(), $reset = TRUE)
    {
        $reflection = new ReflectionClass($this);
        ...
        foreach ($config as $key => &$value)
        {
            if ($key[0] !== '_' && $reflection->hasProperty($key))
            {
                if ($reflection->hasMethod('set_'.$key))
                {
                    $this->{'set_'.$key}($value);
                }
                else
                {
                    $this->$key = $value;
                }
            }
        }
    }
    ...
}

$uploader = new Upload();
$config = include('./upload.config.php');
$uploader->initialize($config);
....
```

### 3.3. 插件管理
