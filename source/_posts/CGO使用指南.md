title: CGO使用指南
author: tinker
date: 2022-05-09 03:04:24
tags:
---
Go 提供一个名为`C`的伪包(pseudo-package)用来与 C/C++ 语言进行交互操作，这种Go语言与C语言交互的机制叫做 **CGO**。通过 CGO 我们可以在 Go 语言中调用 C/C++ 代码，也可以在 C/C++ 代码中调用Go语言。CGO 本质就是 Go 实现的 [FFI](https://en.wikipedia.org/wiki/Foreign_function_interface)（全称为Foreign function interface，用来描述一种编程语言编写的程序可以调用另一种编程语言编写的服务的机制）解决方案。

当 Go 代码中加入`import C`语句来导入`C`这个不存在的包时候，会启动 CGO 特性。此后在 Go 代码中我们可以使用`C.`前缀来引用C语言中的变量、类型，函数等。启动 CGO 特性时候，需要确保环境变量 `CGO_ENABLED` 值是1，我们可以通过`go env CGO_ENABLED`查看该环境变量的值，通过`go env -w CGO_ENABLED=1`用来设置该环境变量值。


## 序言

我们可以给`import C`语句添加注释，在注释中可以引入C的头文件，以及定义和声明函数和变量，此后我们可以在 Go 代码中引用这些函数和变量。这种注释称为 **序言(preamble)** 。需要注意的是 **序言和`import C`语句之间不能有换行**，序言中的静态变量是不能被Go代码引用的，而静态函数是可以的。

```go
package main

/*
#include <stdio.h>
#include <stdlib.h>

static void myprint(char* s) {
  printf("%s\n", s);
}
*/
import "C"
import "unsafe"

func main() {
	cs := C.CString("hello world")
	C.myprint(cs)
	C.free(unsafe.Pointer(cs))
}
```

<!--more-->

如果Go 代码中存在`import C`，那么编译时候Go 编译器会寻找代码目录中其他非Go文件，对于后缀为`.c`、`.s`、`.S`的文件，会使用C编译器进行编译。后缀为`.cc`、`.cpp` 或 `.cxx` 文件使用C++编译器编译。对于`.h`、`.hh`、`.hpp` 或 `.hxx`后缀的文件，它们是C/C++的头文件，不会单独编译，如果更改了这些头文件，包括非Go代码都会重新编译。

执行`go build`命令时候，我们可以使用`-n`(`-x`也可以，只不过它会执行相关编译命令）选项查看所有要执行的命令：

```bash
vagrant@vagrant:/tmp/cgo$ go build -n

#
# _/tmp/cgo
#

mkdir -p $WORK/b001/
cd /tmp/cgo
TERM='dumb' CGO_LDFLAGS='"-g" "-O2"' /usr/local/go1.14/pkg/tool/linux_amd64/cgo -objdir $WORK/b001/ -importpath _/tmp/cgo -- -I $WORK/b001/ -g -O2 ./main.go
cd $WORK
gcc -fno-caret-diagnostics -c -x c - -o /dev/null || true
gcc -Qunused-arguments -c -x c - -o /dev/null || true
gcc -fdebug-prefix-map=a=b -c -x c - -o /dev/null || true
gcc -gno-record-gcc-switches -c -x c - -o /dev/null || true
cd $WORK/b001
TERM='dumb' gcc -I /tmp/cgo -fPIC -m64 -pthread -fmessage-length=0 -I ./ -g -O2 -o /tmp/cgo/$WORK/b001/_x001.o -c _cgo_export.c
cd $WORK
gcc -fno-caret-diagnostics -c -x c - -o /dev/null || true
gcc -Qunused-arguments -c -x c - -o /dev/null || true
gcc -fdebug-prefix-map=a=b -c -x c - -o /dev/null || true
gcc -gno-record-gcc-switches -c -x c - -o /dev/null || true
cd $WORK/b001
...
```

从上面可以看到在CGO模式下，gcc参加了编译工作。需要注意同Go包一样，C 语言编译后也会缓存起来，下次编译时候直接使用，如果我们之前构建过应用，在代码没有变动情况下，使用`go build -n`就看不见gcc命令了。这时候我们可以使用`-a`选项强制重新构建包。

另外借助`go tool cgo`工具，我们可以生成绑定的代码：

```shell
go tool cgo main.go
```

上面命令会在当前目录下面生`_obj`目录，该目录存放着一系列生成的文件：

- _cgo_gotypes.go：定义 C 函数和类型的 Go 封装。
- _cgo_main.c：主要用于初始化 C 和 Go 的运行时。
- _cgo_export.c：包含 Go 导出到 C 的接口实现。



### #cgo指令

在序言中我们可以使用`#cgo`指令来设置在构建 `C` 编译器参数 `CFLAGS` 和链接器参数 `LDFLAGS`。

```go
// #cgo CFLAGS: -g -Wall -I./include
// #cgo CFLAGS: -DPNG_DEBUG=1
// #cgo LDFLAGS: -L/usr/local/lib -lpng
// #include <png.h>
import "C"
```

上面 `CFLAGS` 中 `-g` 选项用于开启`debug symbols`， `-Wall` 用于开启`all warning`，`-I` 用于设置头文件目录，`-DPNG_DEBUG=1` 用于设置宏`PNG_DEBUG`值为1。

在设置 `LDFLAGS` 时候，可以使用 `${SRCDIR}` 来替换源码的路径，比如：

```go
// #cgo LDFLAGS: -L${SRCDIR}/libs -lfoo
```

将会拓展为

```go
// #cgo LDFLAGS: -L/go/src/foo/libs -lfoo
```

CGO编译时候，总是隐式包含`-I${SRCDIR}`这个链接选项，并且优先级是高于系统include目录，或者-I指定的目录。这意味着如果`foo/bar.h`这个文件既存在于代码目录中，也存在系统目录中，`#include <foo/bar.h>`始终优先使用本地代码目录的版本。

此外`#cgo`指令还支持条件选择，只有满足特定系统或者CPU架构时候编译或者连接选项才会生效：

```go
// #cgo amd64 386 CFLAGS: -DX86=1 // amd64 368 平台才设置该编译选项
// #cgo !amd64 CFLAGS: -DX86=1 // 非amd64平台才设置编译该编译选项
```

当然我们也可以使用`#cgo pkg-config`指令来获取设置CFLAGS和LDFLAGS参数。`#cgo pkg-config`指令依赖`pkg-config`命令，`pkg-config`可以帮助我们编译时候插入正确的编译器参数，而不必硬编码，例如我们可以使用 **gcc -o test test.c $(pkg-config --libs --cflags glib-2.0)** 来找到glib库。你可以查看[这篇文章](https://wiki.cyub.vip/cheatsheet/pkg-config/)来获取有关 `pkg-config` 更多信息。`pkg-config`在CGO中使用方法如下：

```go
// #cgo pkg-config: png cairo
// #include <png.h>
import "C"
```

## 数据类型


### Go 语言中引用 C 语言类型



#### float

```go
type C.float
```

#### double

```go
type C.double
```

#### struct

```go
type C.struct_<name_of_C_Struct>
```

#### union

```go
C.union_<name_of_C_Union>
```

#### enum

```go
C.enum_<name_of_C_Enum>
```

#### void*

C语言中的`void *`对应Go语言中的`unsafe.Pointer`。

```go
cs := C.CString("Hello from stdio")
C.free(unsafe.Pointer(cs)) // free函数接收void *类型参数
```

### C-Go 类型转换

#### 基本数值类型转换

Go 和 C 的基本数值类型转换对照表如下：

C语言类型 | CGO类型 | Go类型
--- | --- | ---
char |  C.char |  byte
singed char |  C.schar |  int8
unsigned char |  C.uchar |  uint8/byte
short |  C.short |  int16
unsigned short |  C.ushort |  uint16
int |  C.int |  int32
unsigned int |  C.uint |  uint32
long |  C.long |  int32
unsigned long |  C.ulong |  uint32
long long int |  C.longlong |  int64
unsigned long long int |  C.ulonglong |  uint64
float |  C.float |  float32
double |  C.double |  float64
size_t |  C.size_t |  uint

C 中的整形 int 在标准中是没有定义具体字长的，但一般默认认为是 4 字节，对应 CGO 类型中 C.int 则明确定义了字长是 4 ，但 golang 中的 int 字长则是 8 ，因此对应的 Go 类型不是 int 而是 int32 。为了避免误用，C 代码最好使用 C99 标准的数值类型(引入`<stdint.h>`头），对应的转换关系如下：

C语言类型 | CGO类型 | Go类型
--- | --- | ---
int8_t | C.int8_t | int8
uint8_t | C.uint8_t | uint8
int16_t | C.int16_t | int16
uint16_t | C.uint16_t | uint16
int32_t | C.int32_t | int32
uint32_t | C.uint32_t | uint32
int64_t | C.int64_t | int64
uint64_t | C.uint64_t | uint64



#### Go 类型字符串转换成C 类型

由于C语言和Go语言中字符串底层内存模型不一样，且 Go 是gc型语言，Go类型字符串需要转换成C类型字符串，才能作为参数传递给C函数，反过来也是一样。

```go
// The C string is allocated in the C heap using malloc.
// It is the caller's responsibility to arrange for it to be
// freed, such as by calling C.free (be sure to include stdlib.h)
func C.CString(string) *C.char

// Go []byte slice to C array
// The C array is allocated in the C heap using malloc.
// It is the caller's responsibility to arrange for it to be
// freed, such as by calling C.free (be sure to include stdlib.h)
func C.CBytes([]byte) unsafe.Pointer
```

需要注意得是 Go 类型字符串转换成 C 类型字符串之后，以及 Go类型字节切片 转换成C类型字节数组时候，需要手动进行回收：

```go
cs := C.CString("hello, world") // C.CString底层使用到C语言malloc进行内存分配，所以需要调用C语言free函数进行释放
defer C.free(unsafe.Pointer(cs)) // C语言中字符串本质是char类型数组，free的参数是指向char数组的指针，所以需要使用unsafe.Pointer获取cs指针

cBytes := C.CBytes(goBytes) // go字节切片转换成C类型字节数字
defer C.free(cBytes) // 释放内存
```

#### C 类型字符串转换成Go 类型

```go
// C string to Go string
func C.GoString(*C.char) string

// C data with explicit length to Go string
func C.GoStringN(*C.char, C.int) string

// C data with explicit length (in bytes) to Go []byte
func C.GoBytes(unsafe.Pointer, C.int) []byte
```


#### Go 字节切片转换成 C 数组

```go
package main
 
/*
#include <stdint.h>
 
static void fill_255(char* buf, int32_t len) {
    int32_t i;
    for (i = 0; i < len; i++) {
        buf[i] = 255;
    }
}
*/
import "C"
import (
    "fmt"
    "unsafe"
)
 
func main() {
    b := make([]byte, 5)
    fmt.Println(b) // [0 0 0 0 0]
    C.fill_255((*C.char)(unsafe.Pointer(&b[0])), C.int32_t(len(b)))
    fmt.Println(b) // [255 255 255 255 255]
}
```


## 函数

### Go 语言调用 C 语言函数

只要我们在序言中设置好`#include`之后，我们就可以在Go 语言可以直接调用标准库里面的函数，或者其他库里面的函数：

```go
package main

//#include <stdio.h>  // 在序言中引入标准io库
import "C"

func main() {
	C.puts(C.CString("Hello, world\n"))
}
```

我们也可以调用序言中定义的函数：

```go
package main
/*
#cgo CFLAGS: -g -Wall
#include <stdio.h>
#include <stdlib.h>
int greet(const char *name, int year, char *out) {
    int n;
    n = sprintf(out, "Greetings, %s from %d! We come in peace :)", name, year);
    return n;
}
*/
import "C"
import (
    "unsafe"
    "fmt"
)

func main() {
	name := C.CString("Gopher")
	defer C.free(unsafe.Pointer(name))

	year := C.int(2022)

	ptr := C.malloc(C.sizeof_char * 1024)
	defer C.free(unsafe.Pointer(ptr))

	size := C.greet(name, year, (*C.char)(ptr))

	b := C.GoBytes(ptr, size)
	fmt.Println(string(b))
}
```

当然我们也可以调用外部C文件中定义的函数：

`greeter.h`文件内容如下：

```c
#ifndef _GREETER_H
#define _GREETER_H

struct Greetee {
    const char *name;
    int year;
};

int greet(const char *name, int year, char *out);
int greet2(struct Greetee *g, char *out);
#endif
```

`greeter.c`文件内容如下：

```c
#include "greeter.h"
#include <stdio.h>

int greet(const char *name, int year, char *out) {
	int n;
	n = sprintf(out, "Greetings, %s from %d! We come in peace :)", name, year);
	return n;
}

int greet2(struct Greetee *g, char *out) {
    int n;
    n = sprintf(out, "Greetings, %s from %d! We come in peace :)", g->name, g->year);
    return n;
}
```

go文件内容如下：
```go
package main

// #cgo CFLAGS: -g -Wall
// #include <stdlib.h>
// #include "greeter.h"
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	name := C.CString("Gopher")
	defer C.free(unsafe.Pointer(name))

	year := C.int(2022)

	ptr := C.malloc(C.sizeof_char * 1024)
	defer C.free(unsafe.Pointer(ptr))

	size := C.greet(name, year, (*C.char)(ptr))

	b := C.GoBytes(ptr, size)
	fmt.Println(string(b))

	g := C.struct_Greetee{
		name: name,
		year: year,
    }
	ptr := C.malloc(C.sizeof_char * 1024)
	defer C.free(unsafe.Pointer(ptr))
	size := C.greet2(&g, (*C.char)(ptr))
	b := C.GoBytes(ptr, size)
	fmt.Println(string(b))
}
```

Go语言也只调用C对象文件中的函数，但是相应头文件一定要指定。上面例子中我们可以使用` gcc -c greeter.c`生成对象文件`greeter.o`，然后删除调用`greeter.c`文件，接着在main.go文件中添加以下LDFLAGS参数，也是OK的：

```
// #cgo LDFLAGS: ./greeter.o
```

如果调用C函数时，如果有两个返回值，那么第二个返回值对应的是<errno.h>标准库errno宏，它用于记录错误状态：

```go
/*
#include <errno.h>

static int div(int a, int b) {
    if(b == 0) {
        errno = EINVAL;
        return 0;
    }
    return a/b;
}
*/
import "C"
import "fmt"

func main() {
    v0, err0 := C.div(2, 1)
    fmt.Println(v0, err0)

    v1, err1 := C.div(1, 0)
    fmt.Println(v1, err1)
}
```

上面代码将会输出：

```
2 <nil>
0 invalid argument
```

### C 语言调用 Go 语言函数

Go语言中函数要能被C语言调用，需要使用 `export` 指令进行导出。

`greet.go`文件内容如下：

```go
package main

import "C"
import "fmt"

//export greet
func greet() {
	fmt.Printf("hello, world")
}

func main(){}
```

我们使用`go build -buildmode=c-archive greet.go`，将greet.go构建成C存档文件，此时会生成`greet.a`和`greet.h`文件。需要注意的是go文件中一定要导入`C`伪包，以及存在main包。

对应的C文件是main.c，内容如下：

```c
#include <stdio.h>
#include "greet.h"

void main() {
    greet();
}
```

最后使用`gcc -pthread main.c greet.a -o main`构建C二进制应用，`-pthread`选项是必须的，因为Go runtime使用到线程。我们也可以使用`go build -buildmode=c-shared`将Go代码编译成C共享文件，然后在C语言中调用。

## 进一步阅读

- [C? Go? Cgo!](https://go.dev/blog/cgo)
- [cgo documentation](https://golang.org/cmd/cgo/)
- [CGo – Referencing C library in Go](https://blog.marlin.org/cgo-referencing-c-library-in-go)
- [golang-cgo-slides](https://akrennmair.github.io/golang-cgo-slides/)
- [Calling C code from go](https://karthikkaranth.me/blog/calling-c-code-from-go/)
- [Go语言高级编程-CGO编程](https://chai2010.cn/advanced-go-programming-book/ch2-cgo/readme.html)
- [Calling Go Functions from Other Languages](https://medium.com/learning-the-go-programming-language/calling-go-functions-from-other-languages-4c7d8bcc69bf)
- [Call Go function from C function](https://dev.to/mattn/call-go-function-from-c-function-1n3)
- [Setting up and using gccgo](https://golang.org/doc/install/gccgo)
- [Calling between Go and C](https://pkg.go.dev/cmd/go#hdr-Calling_between_Go_and_C)