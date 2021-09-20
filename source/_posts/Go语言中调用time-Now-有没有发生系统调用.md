title: Go语言中调用time.Now()时有没有发生系统调用?
author: tinker
tags: []
categories: []
date: 2021-09-19 03:11:00
---
在探究“Go语言中调用time.Now()时有没有发生系统调用?”这个问题之前，我们先复习下什么是系统调用。

## 什么是系统调用？

系统调用(system call)指的是运行在用户空间的程序向操作系统内核请求具有更高权限的服务。究竟是哪些服务呢?这些服务指的是由操作系统内核进行管理的服务，比如进程管理，存储，内存，网络等。以打开文件为例子，用户程序需要调用`open`和`read`这两个系统调用，在c语言中要么使用libc库实现（底层也是系统调用），要么直接使用系统调用实现。

Linux系统中为什么一定要经过系统调用才能访问特资源呢，难道就不能在用户空间完成调用访问功能吗？之所以这么设计是考虑到系统隔离性，提高系统安全性和容错性，避免恶意攻击。操作系统把CPU访问资源的安全级别分为4个级别，这些级别称为特权级别（privilege level），也称为CPU环（CPU Rings）。在任一时刻，CPU都是在一个特定的特权级下运行的，从而决定了什么可以做，什么不可以做。这些级别可以形象的考虑成一个个圆环，里面是最高特权的Ring0，向外依次是Ring1，Ring2，最后是最低特权的Ring3。当发生系统调用时候，应用程序将会从应用空间进入内核空间，此时特权级别会由Ring3提升到Ring0，应用程序代码也会跳到相关系统调用代码处执行。

<!--more-->

![](https://static.cyub.vip/images/202109/cpu-rings.jpeg)

早期时候，系统调用是通过软中断`int 0x80`实现的。由于软中断实现方式需要扫描中断描述表找到系统调用对应入口地址，性能较差，为此Linux系统引入了专有的系统调用指令来完成系统调用，在64位系统下相关指令是SYSCALL/SYSRET指令。我们需要知道的是系统调用时候需要由用户态切换内核态，这会造成一定的性能损失。

## time.Now()调用分析

复习完系统调用的概念，我们接下来使用strace命令来看下下面代码中`time.Now()`有没有使用到系统调用。

```go
package main

import "time"

func main() {
	time.Now()
}
```

执行下面命令，先构建出二进制可执行文件test，然后使用strace查看test执行过程中所有的系统调用，看看有没有使用到任何与时间相关的系统调用:

```
go build -gcflags="-N -l" -v -o test

strace ./test 2>&1 | grep time
```

结果我们发现在调用time.Now()时候，并没有使用到任何与时间相关的系统调用。我们可以初步得出调用time.Now()时候没有发生系统调用。但这个结论与上面介绍的系统调用概念相冲突，因为获取时间需要读取系统时钟信息，它属于Ring0特权，需要使用系统调用的。

接下来我们来分析time.Now()的实现，查看调用它时候发生了什么？

分析源码有两个途径，第一种是直接去查看源码，在查看源码过程中由于源码内容繁多，且存在汇编代码以及多系统支持，代码编辑器并不能支持很好支持提示和跳转，有时候就需要我们使用全局搜索相关关键字才能找到函数或变量位置。第二种是使用gdb或者dlv等调试工具，通过打断点形式来追踪查看执行过程的源码。这两种方式一般都是混合使用的。这次我们将使用gdb来分析。笔者系统环境如下：

```
vagrant@vagrant:~$ go version
go version go1.14.15 linux/amd64

vagrant@vagrant:~$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=20.04
DISTRIB_CODENAME=focal
DISTRIB_DESCRIPTION="Ubuntu 20.04.2 LTS"

vagrant@vagrant:~$ gdb --version
GNU gdb (Ubuntu 9.2-0ubuntu1~20.04) 9.2
```

首先我们启动gdb，接着在main函数处设置断点并运行程序：
![](https://static.cyub.vip/images/202109/gdb-time-01.png)

接下来我们在time.Now()处（即行6处）设置断点，并执行continue和step命令来查看time.Now()内部实现：
![](https://static.cyub.vip/images/202109/gdb-time-02.png)

从上图我们可以看到time.Now()源码位于在time/time.go文件中第1121行。time.Now()函数会调用now()函数获取当前秒数和纳秒数。接下来我们看下now()函数的实现：

![](https://static.cyub.vip/images/202109/gdb-time-03.png)

从上图可以看到当我们查看now()函数时候，它跳到time_now()处。这是因为编译指令`go:linkname`的缘故，`go:linkname`指令用于将当前源文件中私有函数或者变量在编译时链接到指定的方法或变量。比如`//go:linkname time_now time.now`意思是将time_now链接到time.now中，所以time包的now函数实现是由time_now完成的，它的位置是runtime/timestub.go的第15行处。

接下来我们查看time_now中walltime的实现。从下图中可以看到walltime位于`runtime/time_nofake.go`文件中第23行，它调用walltime1函数。walltime1是由汇编程序实现的，源码位于`runtime/sys_linux_amd64.s`第209处。

![](https://static.cyub.vip/images/202109/gdb-time-04.png)


接下里我们来看看汇编代码，我们只关心其中`runtime·walltime1`函数部分，具体就是sys_linux_amd64.s文件中的209到210之间的汇编代码，核心部分已用箭头标示出来了：
![](https://static.cyub.vip/images/202109/gdb-time-05.png)

上图中汇编代码主要完成两个功能，首先完成将goroutine栈切换到g0栈。

```go
get_tls(CX) // 将tls加载到CX寄存器上
MOVQ	g(CX), AX // tls中的存储g信息保存到AX寄存器中
MOVQ	g_m(AX), BX // BX unchanged by C code.

// Set vdsoPC and vdsoSP for SIGPROF traceback.
LEAQ	sec+0(FP), DX
MOVQ	-8(DX), CX
MOVQ	CX, m_vdsoPC(BX)
MOVQ	DX, m_vdsoSP(BX)

CMPQ	AX, m_curg(BX)	// 将tls中保存的g与m.curg进行比较，如果不相等说明已在g0栈上了，那就不用切换，直接跳到noswith分支上面
JNE	noswitch
// 下面代码完成g栈切换g0栈操作
MOVQ	m_g0(BX), DX 
MOVQ	(g_sched+gobuf_sp)(DX), SP	// Set SP to g0 stack
```

根据GMP模型，M执行的栈可能是系统栈（即g0栈）或者signal栈上，也有可能用户线程栈（即gorountine栈）上。通过`getg()`可以返回正在执行的g，这个g可能是M的g0，或者gsignal，也可能是和M关联的goroutine，而`getg().m.curg`返回的永远是M关联的goroutine，那么我们可以通过两者比较`getg() == getg().m.curg`判断当前M执行的栈是不是系统栈。上面汇编代码切换到系统栈之前进行栈类型判断就是基于此实现的。

第二功能就是调用`runtime·vdsoClockgettimeSym`变量指向的函数，来获取当前秒数和毫秒数。这个也是time.Now()实现的核心。

```go
noswitch:
	SUBQ	$16, SP		// Space for results
	ANDQ	$~15, SP	// Align for C code

	MOVQ	runtime·vdsoClockgettimeSym(SB), AX // 将vdsoClockgettimeSym变量保存的函数地址保存到AX寄存器中
	CMPQ	AX, $0 // 将vdsoClockgettimeSym保存的函数地址和0比较，如果相等，则跳到fallback分支
	JEQ	fallback
	MOVL	$0, DI // CLOCK_REALTIME
	LEAQ	0(SP), SI
	CALL	AX // 调用vdsoClockgettimeSym指向的函数
	MOVQ	0(SP), AX	// sec
	MOVQ	8(SP), DX	// nsec
	MOVQ	BP, SP		// Restore real SP
	MOVQ	$0, m_vdsoSP(BX)
	MOVQ	AX, sec+0(FP)
	MOVL	DX, nsec+8(FP)
```

从上面可以看到time.Now()最终调用的是`runtime·vdsoClockgettimeSym`这个变量指向的函数，函数入口地址是`0x7ffff7ffe8e0`。为什么要用一个变量来指向函数地址，而不是正常情况下通过函数符号来获取地址？我们先推测是该函数地址不是固定的，它会随着应用不同而变化的，它需要在运行时动态的获取地址。

接下来我们看下入口地址为`0x7ffff7ffe8e0`函数的汇编代码：
![](https://static.cyub.vip/images/202109/gdb-time-06.png)

我们可以看到地址`0x7ffff7ffe8e0`对应的函数名称`clock_gettime`。

一路gdb调试过来，最后我们发现必须去了解`runtime·vdsoClockgettimeSym`这个变量是怎么赋值成clock_gettime函数入口地址的。

我们知道在Go应用启动时候，Go运行时会完成ncpu，g0，schet等全局变量的初始化的，这里面的`runtime·vdsoClockgettimeSym`也不例外，他们在执行main函数之前已经完成初始化了。所以我们使用watch命令观察`vdsoClockgettimeSym`变量变化时候，必须在应用启动时候。

![](https://static.cyub.vip/images/202109/gdb-time-07.png)

观察变量`vdsoClockgettimeSym`变化时候，我们可以看到是函数`vdsoParseSymbols`更改了其值，它将`0x7ffff7ffe8e0`赋值给`vdsoClockgettimeSym`这个变量，`0x7ffff7ffe8e0`是函数clock_gettime的入口地址。



需要注意的是在gdb中访问`vdsoClockgettimeSym`这个变量是`runtime.vdsoClockgettimeSym`，runtime和vdsoClockgettimeSym之间的点号(.)和汇编里面的点号(·)是不一样的。

接下来我们使用bt命令，我们可以看到整个函数栈帧，后面我们可以打开代码编辑器依图索骥：

![](https://static.cyub.vip/images/202109/gdb-time-08.png)

至此我们使用gdb分析追踪time.Now()结束了。我们用代码编辑器查看vdsoParseSymbols这个函数，它位于`runtime/vdso_linux.go`文件中。在这个文件开头注释有这么一句话：`Look up symbols in the Linux vDSO.`。结合函数名称，可以知道vdsoParseSymbols用来完成vDSO的符号解析。这就引入了vDSO概念。

## 什么vDSO?

vDSO是Virtual Dynamic Shared Object的缩写，中文名称是虚拟动态共享对象，是Linux内核对用户空间暴露内核函数的一种机制。vDSO实现方式是将内核中某些不涉及安全的系统调用代码直接映射到用户空间里面，那么用户代码不再使用系统调用，也能完成相关功能。由于避免了系统调用时候需要用户空间到内核空间的切换，vDSO机制可以减少性能上面的消耗。vDSO支持的系统调用有`clock_gettime`,`time`,`getcpu`等。

我们可以通过查看进程的内存映射，可以找到vDSO模块：

![](https://static.cyub.vip/images/202109/proc-map.png)

从上面可以发现vDSO地址是从`0x7ffff7ffe000`到`0x7ffff7fff000`。

为了安全性，防止被恶意程序替换，vDSO的起始地址不是固定的，每个二进制应用的vDSO都是不一样的。我们可以使用下面命令测试验证，可以看到每次执行的vdso起始地址都不一样：

```bash
vagrant@vagrant:~$ LD_SHOW_AUXV=1 cat /proc/self/maps | egrep '\[vdso|AT_SYSINFO'
AT_SYSINFO_EHDR:      0x7fff3d725000
7fff3d725000-7fff3d726000 r-xp 00000000 00:00 0                          [vdso]
```

接下我们尝试把内存中vDSO的信息保存到文件中，查看它具体是什么格式？这里面介绍两种方法。

第一种使用gdb的dump命令，把进程的内存中vdso部分保存下来。首先我们使用`info proc mappings`找到应用进程内存中vdso的起始地址，然后使用dump memory命令把对应起始地址的内存数据保存到vdso.so文件中。

![](https://static.cyub.vip/images/202109/gdb-dump-memory.png)


第二种方式是自己编写代码实现，[点击查看完整源码](https://github.com/cyub/code-examples/tree/master/go/vdso-dump)。

```go
	outputFile, err := os.Create(*output)
	if err != nil {
		log.Fatal(err)
	}
	defer outputFile.Close()

	mapFile := "/proc/self/maps"
	memFile := "/proc/self/mem"
	if *pid > 0 {
		mapFile = fmt.Sprintf("/proc/%d/maps", *pid)
		memFile = fmt.Sprintf("/proc/%d/mem", *pid)
	}

	mapFileH, err := os.Open(mapFile)
	if err != nil {
		log.Fatal(err)
	}

	bufReader := bufio.NewReader(mapFileH)
	var vdsoSectionLine string
	for {
		line, err := bufReader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			log.Fatal(err)
		}
		line = strings.Trim(line, "\n")
		if strings.HasSuffix(line, "[vdso]") {
			vdsoSectionLine = line
			break
		}
	}
	if len(vdsoSectionLine) == 0 {
		log.Fatal("can't find vdso module")
	}

	addrs := strings.Split(strings.SplitN(vdsoSectionLine, " ", 2)[0], "-")
	vdsoStartAddr, _ := strconv.ParseInt(addrs[0], 16, 64)
	vdsoEndAddr, _ := strconv.ParseInt(addrs[1], 16, 64)

	memFileH, err := os.Open(memFile)
	if err != nil {
		log.Fatal(err)
	}

	if _, err = memFileH.Seek(vdsoStartAddr, 0); err != nil {
		log.Fatal(err)
	}

	buf := make([]byte, vdsoEndAddr-vdsoStartAddr)
	if _, err = io.ReadFull(memFileH, buf); err != nil {
		log.Fatal(err)
	}

	if _, err = outputFile.Write(buf); err != nil {
		log.Fatal(err)
	}
```

通过上面介绍的方法得到vdso文件之后，我们可以使用`file`命令查看文件类型，以及`objdump -T`命令查看其`Dynamic symbols`信息。

![](https://static.cyub.vip/images/202109/vdso.png)

从上图中我们再次看到了`clock_gettime`。

### Go语言中是如何使用vDSO的？

从上面介绍中，我们知道了Go语言中调用time.Now()时候，没有发生系统调用，是因为它使用vDSO技术，将系统调用clock_gettime映射到应用空间，Go语言调用应用空间相应代码，避免了系统调用。

上面介绍中也提到了vDSO的入口地址不是固定的，那么Go语言是如何找到这个入口地址的，并找到`clock_gettime`函数地址的？

Go语言是通过读取辅助向量（Auxiliary Vectors）信息来获取vDSO开始地址的，然后读取vDSO信息，解析出`clock_gettime`地址。Auxiliary Vectors是内核ELF二进制加载器提供给用户空间的一些信息的集合，包括了可执行的入口地址、线程的gid、线程uid、vdso入口地址等信息。

Auxiliary Vectors包含一系列的键值对，每一个键对应一个值。vDSO入口地址对应的键是AT_SYSINFO_EHDR。具体信息可以查看系统调用[getauxval](https://man7.org/linux/man-pages/man3/getauxval.3.html)的手册。Go runtime中相关源码如下，具体细节就不在赘述了：

```go
func vdsoauxv(tag, val uintptr) {
	switch tag {
	case _AT_SYSINFO_EHDR:
		if val == 0 {
			// Something went wrong
			return
		}
		var info vdsoInfo
		// TODO(rsc): I don't understand why the compiler thinks info escapes
		// when passed to the three functions below.
		info1 := (*vdsoInfo)(noescape(unsafe.Pointer(&info)))
		vdsoInitFromSysinfoEhdr(info1, (*elfEhdr)(unsafe.Pointer(val)))
		vdsoParseSymbols(info1, vdsoFindVersion(info1, &vdsoLinuxVersion))
	}
}
```

文末留一个思考题：Go语言中调用time.Sleep()时候会不会发生系统调用？


## 进一步阅读

- [Creating a vDSO: the Colonel's Other Chicken](https://www.linuxjournal.com/content/creating-vdso-colonels-other-chicken)
- [man: VDSO](https://man7.org/linux/man-pages/man7/vdso.7.html)
- [stackexchange: Are system calls the only way to interact with the Linux kernel from user land?](https://unix.stackexchange.com/questions/124928/are-system-calls-the-only-way-to-interact-with-the-linux-kernel-from-user-land)
- [Sysenter Based System Call Mechanism in Linux 2.6](http://articles.manugarg.com/systemcallinlinux2_6.html)
- [Linux syscall, vsyscall, and vDSO... Oh My! ](http://davisdoesdownunder.blogspot.com/2011/02/linux-syscall-vsyscall-and-vdso-oh-my.html)
- [About ELF Auxiliary Vectors](http://articles.manugarg.com/aboutelfauxiliaryvectors.html)
- [Atp's external memory
linux syscalls on x86_64](http://blog.tinola.com/?e=5)