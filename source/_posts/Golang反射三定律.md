title: 【译文】Go 反射三定律
author: tinker
tags:
  - 反射
  - 反射三定律
categories:
  - Golang
date: 2020-11-22 20:32:00
---
原文地址：https://blog.golang.org/laws-of-reflection

## 简介

**Reflection（反射）** 在计算机中表示程序能够检查自身结构的能力，特别指通过类型进行处理。它是元编程的一种形式，也是最容易让人迷惑的一部分。

## 类型和接口

因为反射建立在类型系统之上，所以让我们先回顾一下 `Go` 中的类型。`Go` 是静态类型语言。每个变量都有一个静态类型，即只有一种类型，并且在编译时就已经确定了。比如`int`, `float32`, `*MyType`, `[]byte`等。比如我们进行如下声明：

```go
type MyInt int

var i int
var j MyInt
```

<!--more-->

上面代码中变量 `i` 的类型是 `int`，`j` 的类型是 `MyInt`。 尽管变量 `i` 和 `j` 具有共同的**底层类型(underlying type)**，但如果不经过类型转换，它们不能相互赋值。

类型的一个重要类别是接口类型，它是固定的方法集合。**接口变量可以存储任何类型的具体（非接口）值，只要该值实现接口的所有方法即可**。一个典型示例是 `io.Reader` 和 `io.Writer`，它们来自 [io包](https://golang.org/pkg/io/) 中的 `Reader` 和 `Writer` 类型：

```go
// Reader is the interface that wraps the basic Read method.
type Reader interface {
 Read(p []byte) (n int, err error)
}

// Writer is the interface that wraps the basic Write method.
type Writer interface {
 Write(p []byte) (n int, err error)
}
```

任何实现了 `Read` 或 `Write` 方法的类型，我们都可以说它实现了 `io.Reader` 或 `io.Writer` 接口。这意味着 `io.Reader` 类型的变量可以保存(也可称为指向)具有 `Read` 方法的任何值：

```go
var r io.Reader
r = os.Stdin
r = bufio.NewReader(r)
r = new(bytes.Buffer)
// and so on
```

需要明确的是，无论 `r` 持有什么具体值，`r` 的类型始终是 `io.Reader`：`Go` 是静态类型，`r` 的静态类型是 `io.Reader`。

一个特别重要的接口类型是空接口：

```go
interface{}
```

它的等效别名是：

```go
any
```

**空接口代表空方法集合，因为任何类型的值都具有零个或多个方法，所以类型为interface{} 的变量能够存储任何值**。

有人说 `Go` 的接口是动态类型的。这个说法是错的！接口变量也是静态类型的，它永远只有一个相同的静态类型。如果在运行时它存储的值发生了变化，这个值也必须实现该接口类型的所有方法集合。

我们需要正确的地看待这一切，因为反射和接口密切相关。

## 接口的表示

Russ Cox 撰写了一篇关于 Go 中接口值表示的[博客文章](https://research.swtch.com/2009/12/go-data-structures-interfaces.html)。这里没有必要重复整个内容，但可以做一个简单的总结。

> 接口类型的变量存储一对值：分配给该变量的具体值以及该值的类型描述符。更准确地说，该具体值指的是实现接口的底层数据，而类型描述符是该底层数据类型的描述

举个例子:

```go
var r io.Reader
tty, err := os.OpenFile("/dev/tty", os.O_RDWR, 0)
if err != nil {
    return nil, err
}
r = tty
```

上面例子中 `r` 包含一个**值-类型对(value, type)**：`(tty，*os.File)`。注意：`*os.File` 类型不光实现了 `Read` 的方法；即使该接口变量仅提供对 `Read` 方法的访问，但由于底层的值包含有关该值的所有类型信息。所以我们能够做如下的类型转换操作：

```go
var w io.Writer
w = r.(io.Writer)
```

上面代码的第二行是一个类型断言：它断言变量 `r` 内部的实际值也实现了 `io.Writer` 接口，所以才能被赋值给 `w`。赋值之后，`w` 就指向了 `(tty, *os.File)` 对，它和变量 `r` 指向的是同一个**值-类型对(value, type)**。**即使底层具体值拥有的方法再多，由于接口的静态类型限制，接口变量只能调用属于该接口的法**。

我们继续往下看：

```go
var empty interface{}
empty = w
```

空接口变量 `empty` 也包含 `(tty, *os.File)` 对。这一点很容易理解：空接口变量可以存储任何具体值以及该值的所有描述信息。

这里我们没有使用类型断言，因为变量 `w` 满足空接口的所有方法。而在前一个例子中，我们把一个具体值从 `io.Reader` 转换为 `io.Writer` 时，需要显式的类型断言，是因为 `io.Writer` 的方法集合并不是 `io.Reader` 的子集。

一个重要的细节是 **值-类型对(value, type)中的 类型(type) 必须是具体的类型（struct或基本类型），不能是接口类型。接口类型不能存储接口变量**。

## 反射三定律

### 反射第一定律

> Reflection goes from interface value to reflection object
> 反射可以将**接口类型变量**转换为**反射类型对象**

从本质上来说，反射只是一种检查存储在接口变量内部的**值-类型对(value, type)**。首先，我们需要了解一下 [reflect](https://go.dev/pkg/reflect/) 包的两种类型：[Type](https://go.dev/pkg/reflect/#Type) 和 [Value](https://go.dev/pkg/reflect/#Value)。这两种类型可以访问接口变量的内容，我们可以通过函数`reflect.TypeOf` 和 `reflect.ValueOf` 用来读取接口变量的 `reflect.Type` 和 `reflect.Value` 部分。当然，从 `reflect.Value` 也很容易获取到 `reflect.Type`。

让我们从 `reflect.TypeOf`开始：

```go
package main

import (
    "fmt"
    "reflect"
)

func main() {
    var x float64 = 3.4
    fmt.Println("type:", reflect.TypeOf(x))
}
```

这段代码会打印出：

```go
type: float64
```


你可能想知道接口在哪儿？ 因为程序看起来像是将 `float64` 变量 `x`（而不是接口值）传递给 `reflect.TypeOf`。事实上，接口就在那里。查阅一下[TypeOf的文档](https://golang.org/pkg/reflect/#TypeOf)，你会发现 `reflect.TypeOf` 的函数签名里包含一个空接口：

```go
// TypeOf returns the reflection Type of the value in the interface{}.
func TypeOf(i interface{}) Type
```

我们调用 `reflect.TypeOf(x)` 时，`x` 首先被存储在一个空接口变量中，然后将其作为参数传递过去； 然后 `reflect.TypeOf` 对该空接口变量进行拆解，恢复其类型信息。

当然 `reflect.ValueOf` 函数可以恢复底层的值：

```go
var x float64 = 3.4
fmt.Println("value:", reflect.ValueOf(x).String())
```

上面代码打印出：

```go
value: <float64 Value>
```

上面代码中之所以明确地调用 `String` 方法，是因为默认情况下，`fmt` 包会深入 `reflect.Value` 以显示其中的具体值。而 `String` 方法则不会，它返回字符串类型。

`reflect.Type` 和 `reflect.Value` 都有很多方法可以让我们检查和操作它们。一个重要的例子是类型 `reflect.Value` 有一个方法 `Type()`，它会返回一个 `reflect.Type` 类型的对象。`Type` 和 `Value` 都有一个名为 `Kind` 的方法，它会返回一个常量，表示底层数据的类型，常见值有：`Uint`、`Float64`、`Slice`等。`Value` 类型也有一些类似于`Int`、`Float`的方法，用来提取底层的数据。比如 `Int` 方法可以用来提取 `int64`, `Float` 方法可以用来提取 `float64`。

```go
var x float64 = 3.4
v := reflect.ValueOf(x)
fmt.Println("type:", v.Type())
fmt.Println("kind is float64:", v.Kind() == reflect.Float64)
fmt.Println("value:", v.Float())
```

上面代码打印出：

```go
type: float64
kind is float64: true
value: 3.4
```

还有一些用来修改数据的方法，比如`SetInt`、`SetFloat`，在讨论它们之前，我们要先理解**可修改性（settability）**，这一特性会在“反射第三定律”中进行详细说明。

反射库有几个值得特别指出的属性。首先是介绍下 `Value` 的 `getter` 和 `setter` 方法。为了保证 API 的简洁，这两个方法操作的是该值的最大类型。例如，处理任何含符号整型数，都使用 `int64`。也就是说 `Value` 类型的 `Int` 方法返回值为 `int64` 类型，`SetInt` 方法接收的参数类型也是 `int64` 类型。在使用时，可能需要转化为实际的类型：

```go
var x uint8 = 'x'
v := reflect.ValueOf(x)
fmt.Println("type:", v.Type())                            // uint8.
fmt.Println("kind is uint8: ", v.Kind() == reflect.Uint8) // true.
x = uint8(v.Uint())                                       // v.Uint returns a uint64.
```

第二个属性是反射对象的 `Kind` 描述的是基础类型，而不是静态类型。如果一个反射类型对象包含一个用户定义的整型数：

```go
type MyInt int
var x MyInt = 7
v := reflect.ValueOf(x)
```

上面的代码中，虽然变量 `v` 的静态类型是 `MyInt`，不是 `int`，`Kind` 方法仍然返回 `reflect.Int`。换句话说，`Kind` 方法不会像 `Type` 方法一样区分 `MyInt` 和 `int`。

### 反射第二定律

> Reflection goes from reflection object to interface value
> 反射可以将**反射对象**转换为**接口类型变量**

像物理反射一样，`Go` 中的反射也会产生自己的逆。

给定 `reflect.Value` 类型的变量，我们可以使用 `Interface` 方法恢复其接口类型的值。实际上，这个方法会把 `type` 和 `value` 信息打包并填充到一个接口变量中，然后返回。

```go
// Interface returns v's value as an interface{}.
func (v Value) Interface() interface{}
```

接着可以通过断言，恢复底层的具体值：

```go
y := v.Interface().(float64) // y will have type float64.
fmt.Println(y)
```

上面这段代码会打印出一个 `float64` 类型的值，也就是 反射类型变量 `v` 所代表的值。

事实上，我们可以更好地利用这一特性。标准库中的 `fmt.Println` 和 `fmt.Printf` 等函数都接收空接口变量作为参数，`fmt` 包内部会对接口变量进行拆包（前面的例子中，我们也做过类似的操作）。因此，`fmt` 包的打印函数在打印 `reflect.Value` 类型变量的数据时，只需要把 `Interface` 方法的结果传给格式化打印程序：

```go
fmt.Println(v.Interface())
```

<del>为什么不直接打印 `v` ，比如 `fmt.Println(v)`？ 答案是 `v` 的类型是 `reflect.Value`，我们需要的是它存储的具体值</del>(注意：新版本`fmt` 包进行了更改，他它会自动解压处理 `refelct.Value`, 所以两者是一样的)。

由于底层的值是一个 `float64`，我们可以格式化打印：

```go
fmt.Printf("value is %7.1e\n", v.Interface())
```

上面代码的打印出：

```go
value is 3.4e+00
```

同样这次也不需要对 `v.Interface()` 的结果进行类型断言。空接口值内部包含了具体值的类型信息，Printf 函数会恢复类型信息。

简而言之，`Interface` 方法是 `ValueOf` 函数的逆函数，只不过它的结果始终是静态类型 `interface{}`。

再次重申一下：`Go` 的反射机制可以将 **接口类型的变量** 转换为 **反射类型的对象**，然后可以再将 **反射类型对象** 转换回去。

### 反射第三定律

> To modify a reflection object, the value must be settable
> 如果要修改“反射类型对象”，其值必须是**可写的**

第三定律是最微妙和令人困惑的，但是如果我们从第一条原则开始，就很容易理解。

下面这段代码不能正常工作，但是非常值得研究：

```go
var x float64 = 3.4
v := reflect.ValueOf(x)
v.SetFloat(7.1) // Error: will panic.
```

如果你运行这段代码，它会抛出抛出一个奇怪的异常：

```go
panic: reflect.Value.SetFloat using unaddressable value
```

这里问题不在于值 `7.1` 不能被寻址，而是因为变量 `v` 是不可写的。**可写性**是反射类型变量的一个属性，但不是所有的反射类型变量都拥有这个属性。

我们可以通过 `CanSet` 方法检查一个 `reflect.Value` 类型变量的可写性:

```go
var x float64 = 3.4
v := reflect.ValueOf(x)
fmt.Println("settability of v:", v.CanSet())
```

上面这段代码打印出：

```go
settability of v: false
```

对于一个不具有可写性的 `Value` 类型变量，调用 `Set` 方法会报出错误。首先，我们要弄清楚什么可写性。

**可写性**有些类似于寻址能力，但是更严格。它是反射类型变量的一种属性，赋予该变量修改底层存储数据的能力。**可写性**最终是由一个事实决定的：反射对象是否存储了原始值。我们看下下面这个例子：

```go
var x float64 = 3.4
v := reflect.ValueOf(x)
```

我们将 `x` 的副本传递给 `reflect.ValueOf`，因此，作为 `reflect.ValueOf` 的参数创建的接口值是 `x` 的副本，而不是 `x` 本身。

```go
v.SetFloat(7.1)
```

如果上面操作能够操作成功，它不会更新 `x` ，虽然看起来变量 `v` 是根据 `x` 创建的。相反，它会更新 `x` 存在于反射对象 `v` 内部的一个拷贝，而变量 `x` 本身完全不受影响。这会造成迷惑并且没有任何意义，所以是不合法的。可写性就是为了避免这个问题而设计的。

这看起来很奇怪，事实上并非如此，而且类似的情况很常见。考虑下面这行代码：

```go
f(x)
```

上面的代码中，我们把变量 `x` 的一个拷贝传递给函数，因此不期望它会改变 `x` 的值。如果期望函数 `f` 能够修改变量 `x`，我们必须传递 `x` 的地址（即指向 `x` 的指针）给函数 `f`，如下：

```go
f(&x)
```

跟上面代码一样。如果你想通过反射修改变量 `x`，你需要把修改的变量的指针传递给反射库。

首先，像往常一样初始化变量 `x`，然后创建一个指向它的反射对象，名字为 p：

```go
var x float64 = 3.4
p := reflect.ValueOf(&x) // Note: take the address of x.
fmt.Println("type of p:", p.Type())
fmt.Println("settability of p:", p.CanSet())
```

上面代码输出：

```go
type of p: *float64
settability of p: false
```

反射对象 `p` 是不可写的，但是我们也不想修改 `p`，事实上我们要修改的是 `*p`。为了得到 `p` 指向的数据，可以调用 `Value` 类型的 `Elem` 方法。`Elem` 方法能够对指针进行“解引用”，然后将结果存储到 `Value` 类型对象 `v` 中：

```go
v := p.Elem()
fmt.Println("settability of v:", v.CanSet())
```

现在变量 `v` 是一个可写的反射对象，上面代码的输出结果也验证了这一点:

```go
settability of v: true
```

由于变量 `v` 代表 `x`， 因此我们可以使用 `v.SetFloat` 修改 `x` 的值:

```go
v.SetFloat(7.1)
fmt.Println(v.Interface())
fmt.Println(x)
```

上面代码将输出：

```go
7.1
7.1
```

你只需要记住只要反射对象要修改它们表示的对象，就必须获取它们表示的对象的地址

#### 结构体

在前面的例子中，变量 `v` 本身并不是指针，它只是从指针衍生而来。把反射应用到结构体时，常用的方式是使用反射修改一个结构体的某些字段。只要拥有结构体的地址，我们就可以修改它的字段。

下面通过一个简单的例子对结构体类型变量 `t` 进行分析。我们使用结构体的地址创建反射对象，因为我们稍后想要修改它。然后我们将 `typeOfT` 设置为它的类型，并使用简单的方法调用迭代该结构体的所有字段。请注意，我们从结构类型中提取字段的名称，但字段本身是常规的 `Reflect.Value` 对象。

```go
type T struct {
    A int
    B string
}
t := T{23, "skidoo"}
s := reflect.ValueOf(&t).Elem()
typeOfT := s.Type()
for i := 0; i < s.NumField(); i++ {
    f := s.Field(i)
    fmt.Printf("%d: %s %s = %v\n", i,
        typeOfT.Field(i).Name, f.Type(), f.Interface())
}
```

上面代码将会输出：

```go
0: A int = 23
1: B string = skidoo
```

有一点需要指出来：**变量 `T` 的字段都是首字母大写的（可导出的），因为 `struct` 中只有可导出的字段才是可写的**。

由于变量 `s` 包含一个可写的反射对象，我们可以修改结构体的字段：

```go
s.Field(0).SetInt(77)
s.Field(1).SetString("Sunset Strip")
fmt.Println("t is now", t)
```

上面代码输出：

```go
t is now {77 Sunset Strip}
```

如果我们修改程序以便从 `t` 而不是 `&t` 创建 `s`，则对 `SetInt` 和 `SetString` 的调用将失败，因为 `t` 的字段不可写的。


## 总结

Go 反射三定律：

1. 反射可以将**接口类型变量**转换为**反射类型对象**。
2. 反射可以将**反射类型对象**转换为**接口类型变量**。
3. 如果要修改反射类型对象，其值必须是**可写的**。