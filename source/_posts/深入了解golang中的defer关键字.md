title: 深入了解golang中的defer关键字
author: tinker
tags:
  - golang
  - golang defer
categories:
  - 开发语言
date: 2020-05-30 19:53:00
---
golang中的defer关键字用来声明一个延迟函数，该函数会放在一个列表中，在defer语句的外层函数返回之前系统会执行该延迟函数。defer特点有：

- 函数返回之前执行
- 可以放在函数中任意位置
- 可以同时设置多个defer函数，多个defer函数执行遵循FILO顺序
- defer函数的传入参数在定义时就已经明确
- 可以修改函数中的命名返回值
- 用于文件资源，锁资源、数据库连接等释放和关闭
- 和recover一起处理panic

### defer会在函数返回之前执行

当程序执行一个函数时候，会将函数的上下文（输入参数，返回值，输出参数等信息）作为栈帧放在程序内存的栈中，当函数执行完成之后，设置返回值并返回，此时栈帧退出栈，函数才真正完成执行。

defer语句函数会在函数返回之前执行，下面程序将会依次输出B A：

```go
func main() {
    defer fmt.Println("A")
    fmt.Println("B")
}
```

<!--more-->

### defer可以放在函数中任意位置

```go
func main() {
    fmt.Println("A")
    defer fmt.Println("B")
    fmt.Println("C")
}
```

上面程序将会依次输出A C B

**注意：**

1. defer语句一定要在函数return语句之前，这样才能生效。下面程序将会只输出A

```go
func main() {
    fmt.Println("A")
    return 
    fmt.Println("B")
}
```

2. 在调用os.Exit时候，defer不会执行。下面程序只会输出B

```go
func main() {
    defer fmt.Println("A")
    fmt.Println("B")
    os.Exit(0)
}
```

### 可以同时设置多个defer函数

可以设置多个defer函数，多个defer函数执行遵循FILO顺序，下面程序将依次输出B D C A

```go
func main() {
    defer fmt.Println("A")
    fmt.Println("B")
    defer fmt.Println("C")
    fmt.Println("D")
}
```

我们来看下多个defer嵌套情况：

```go
func main() {
    fmt.Println("A")
    defer func() {
       fmt.Println("B")
       defer fmt.Println("C")
       fmt.Println("D")
    }()
    
    defer fmt.Println("E")
    fmt.Println("F")
}
```

上面程序将依次输出： A F E B D C


defer语句内部实现形式是一个结构体:

```go
# 位于/usr/lib/go/src/runtime/runtime2.go#784
type _defer struct {
    ...
	sp      uintptr // 函数栈指针,sp是stack pointor单词首字母缩写
	pc      uintptr //程序计数器, pc是program counter单词首字母缩写
	fn      *funcval // 函数地址，执行defer函数
	_panic  *_panic // 指向最近一次panic
	link    *_defer // 指向下一个_defer结构
	...
}
```

defer内部实现是一个链表，链表元素类型是`_defer`结构体，其中的`link`字段指向下一个`_defer`地址，当定义一个defer语句时候，系统内部会将defer函数转换成_defer结构体，并放在链表头部，最后执行时候，系统会从链表头部开始依次执行，这也就是多个defer的执行顺序是First In Last out的原因。



### defer函数的传入参数在定义时就已经明确

1. defer函数的传入参数在定义时就已经明确，不论传入的参数是变量、表达式、函数语句，都会先计算出计算出实参结果，再随defer语句入栈

```go
func main() {
  i := 1
  defer fmt.Println(i)
  i++
  return
}
```

上面程序输出1，而不是2

**注意：**

当defer类似闭包使用时候，访问的总是循环中最后一个值

```go
func main() {
    for i:=0; i<5; i++ {
        defer func() {
           fmt.Println(i) 
        }()
    }
}
```

上面程序连续输出5个5

解决办法可将值传入闭包函数中，此时defer函数入栈时候，不光入栈地址，还会记录传入参数，等到执行的时候也就打印输出入栈时候的值

```go
func main() {
    for i:=0; i<5; i++ {
        defer func(i int) {
           fmt.Println(i) 
        }(i)
    }
}
```
此时依次输出4 3 2 10


### 可以修改函数中的命名返回值

下面程序输出101，执行`return 100`时候，会将100复制返回变量i，之后执行defer函数,i值会加1，此时i值变成101，最后函数test才会真正执行完成，所以打印输出为101

```go
func main() {
    fmt.Println(test())
}

func test() (i int) {
    defer func() {
        i++
    }()
    return 100
}
```

**注意**匿名返回值的情况, 下面程序输出的1，而不是101。

当执行test函数时候，系统会生成一个临时变量作为返回值变量，当执行到`return ret`时候，会将ret值复制给这个临时变量，此后defer函数对ret变量进行任何都和这个变量无关了，所以test函数最后返回值是1

```go
func main() {
    fmt.Println(test())
}

func test() int {
    ret := 1                         
    defer func() {
        ret += 100           
    }()               
    return ret                  
} 
```

我们来看下返回值是匿名指针类型的情况：

```go
func main() {
    fmt.Println(*(test()))
}

func test() *int {
    ret := 1                         
    defer func() {                        
        ret += 100           
    }()               
    return &ret                  
} 
```

上面程序将输出101，原因跟上面一样。

### 多用于文件资源关闭，数据库等连接关闭

**处理资源释放回收**

通过defer我们可以简洁优雅处理资源回收问题，避免复杂的代码逻辑情况下，遗漏忽视相关的资源回收问题。

我们看下下面的代码，目的是复制文件内容到一个新文件

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }

    written, err = io.Copy(dst, src)
    dst.Close()
    src.Close()
    return
}
```

上面代码是存在bug的。当文件创建失败的时候，直接返回了，却没有对打开的文件资源关闭回收。

通过defer我们可以保证始终能够正确的关闭资源, 并且处理逻辑简单优雅。

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    return io.Copy(dst, src)
}
```

### 和recover一起处理panic

recover用户捕获panic异常，panic用于抛出异常。recover需要放在defer语句中，否则无法捕获到一次

下面这个例子将会捕获到panic， 并且输出panic信息

```go
func main() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println(r)
        }
    }()
    panic("it is panic")
}
```

多个恐慌同时发生时候，只会捕获第一个恐慌

```go
func main() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println(r)
        }
    }()
    panic("it is panic")
    panic("it is another panic")
}
```

### 参考资料

- [Defer, Panic, and Recover](https://blog.golang.org/defer-panic-and-recover)

- [5 More Gotchas of Defer in Go](https://blog.learngoprogramming.com/5-gotchas-of-defer-in-go-golang-part-iii-36a1ab3d6ef1)
- [深入了解defer](https://studygolang.com/resources/15395)