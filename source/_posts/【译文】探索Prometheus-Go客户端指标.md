title: 【译文】探索Prometheus Go客户端指标
author: tinker
tags:
  - Prometheus
  - 翻译
categories: []
date: 2021-11-06 13:32:00
---
原文是 [Exploring Prometheus Go client metrics](https://povilasv.me/prometheus-go-metrics)，有删改。

在这篇文章中，我将探索下Prometheus Go 客户端指标，这些指标由`client_go`通过`promhttp.Handler()`暴露出来的。通过这些指标能帮助你更好的理解 Go 是如何工作的。

想对Prometheus了解更多吗？你可以去学习下[Monitoring Systems and Services with Prometheus](https://povilasv.me/out/prometheus)，这是一门很棒的课程，可以让你快速上手。

让我们从一个简单的程序开始，它注册`prom handler`并且监听8080端口：

```go

package main

import (
    "log"
    "net/http"

    "github.com/prometheus/client_golang/prometheus/promhttp"
)

func main() {
    http.Handle("/metrics", promhttp.Handler())
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

<!--more-->


当你请求`metric`端点时候，你将看到类似下面内容：

```
# HELP go_gc_duration_seconds A summary of the GC invocation durations.
# TYPE go_gc_duration_seconds summary
go_gc_duration_seconds{quantile="0"} 3.5101e-05
# HELP go_goroutines Number of goroutines that currently exist.
# TYPE go_goroutines gauge
go_goroutines 6
...
process_open_fds 12
# HELP process_resident_memory_bytes Resident memory size in bytes.
# TYPE process_resident_memory_bytes gauge
process_resident_memory_bytes 1.1272192e+07
# HELP process_virtual_memory_bytes Virtual memory size in bytes.
# TYPE process_virtual_memory_bytes gauge
process_virtual_memory_bytes 4.74484736e+08
```


在初始化时，`client_golang`注册了 2 个 `Prometheu` 收集器：

- **进程收集器** —— 用于收集基本的 Linux 进程信息，比如 CPU、内存、文件描述符使用情况，以及启动时间等。



- **Go 收集器** —— 用于收集有关 Go 运行时的信息，比如 GC、gouroutine 和 OS 线程的数量的信息。


## 进程收集器


这个收集器的作用是读取`proc`文件系统。`proc`文件系统暴露内核内部数据结构，用于获取系统信息。

比如`Prometheus` 客户端读取 `/proc/PID/stat` 文件，得到如下所示内容：

```
1 (sh) S 0 1 1 34816 8 4194560 674 43 9 1 5 0 0 0 20 0 1 0 89724 1581056 209 18446744073709551615 94672542621696 94672543427732 140730737801568 0 0 0 0 2637828 65538 1 0 0 17 3 0 0 0 0 0 94672545527192 94672545542787 94672557428736 140730737807231 140730737807234 140730737807234 140730737807344 0
```

你可以通过`cat /proc/PID/status`获取上面信息的可读版本。

**process_cpu_seconds_total** – 该指标计算使用到`utime`(Go 进程执行在用户态模式下的滴答数)和`stime`(Go 进程执行在内核态时候的滴答数，比如系统调用时），它们的单位`jiffies`，[jiffy](https://elinux.org/Kernel_Timer_Systems) 描述了两次系统定时器中断之间的滴答时间。**process_cpu_seconds_total** 等于 `utime` 和 `stime` 之和除以`USER_HZ`。这样计算是有道理的，因为将程序滴答总数除以 Hz（每秒滴答数）得到就是操作系统运行该进程的总时间（以秒为单位）

**process_virtual_memory_bytes** - 即vss(Virtual Set Size)，vss指的虚拟内存集，它是全部分配的内存，包括分配但未使用的内存、共享内存、换出的内存。

**process_resident_memory_bytes** - 即rss(Resident Set Size)，rss指的是常驻内存集，是进程实际使用的内存，它不包括分配但未使用的内存，也不包括换出的内存页面，但包含共享内存。

**process_start_time_seconds** – 它使用到`start_time`，`start_time`描述了进程启动时的时间，单位是jiffies，数据来自`/proc/stat`。最后将`start_time` 除以 `USER_HZ`得到以秒为单位的值。

**process_open_fds** - 通过计算`/proc/PID/fd`目录下的文件总数得来。它显示了 Go 进程当前打开的常规文件、套接字、伪终端总数。

**process_max_fds** - 读取 `/proc/{PID}/limits`文件中,`Max Open Files`所在行的值获得，该值是软限制(soft limit)。**软限制(soft limit)是内核为相应资源强制执行的值，而硬限制(hard limit)充当软限制的上限**。

在 Go 中你可以通过`err = syscall.Setrlimit(syscall.RLIMIT_NOFILE, &syscall.Rlimit{Cur: 9, Max: 10})`来设置最大文件打开数限制。


## Go 收集器

Go Collector 的大部分指标来自`runtime`、`runtime/debug`这两个包。

**go_goroutines** – 通过`runtime.NumGoroutine()`调用获取，它基于调度器结构`sched`和全局`allglen`变量计算得来。由于`sched`结构体的所有字段可能并发的更改，因此最后会检查计算的值是否小于1，如果小于1，那么返回1。

**go_threads** – 通过`runtime.CreateThreadProfile()`调用获取，它读取的是全局 `allm` 变量。如果你还不知道什么是 M 或 G，你可以阅读我的[博文](https://povilasv.me/go-scheduler/)。

**go_gc_duration_seconds** – 数据来自调用 `debug.ReadGCStats()`，调用该函数时候，会将传入参数GCStats结构体的PauseQuantile字段设置为5，这样函数将会返回最小、25%、50%、75% 和最大这5个GC暂停时间百分位数。然后prometheus go客户端根据返回的GC暂停时间百分位数、以及`NumGC`和`PauseTotal`变量创建摘要类型指标。

**go_info** – 该指标为我们提供了 Go 版本信息。该指标数据来自`runtime.Version()`。


### 内存

Go 收集器提供一系列关于内存和GC的指标。所有内存指标都来自`runtime.ReadMemStats()`，它为我们提供了 [MemStats](https://golang.org/pkg/runtime/#MemStats) 结构体的指标信息。

让我担忧的是`runtime.ReadMemStats()`会`STW`(stop-the-world)。所以我想知道该暂停会带来多少实际成本？在 stop-the-world 暂停期间，所有 `goroutine` 都会暂停，以便 GC 可以运行。我可能会在以后的文章中对有没有使用Prometheus Go客户端的应用程序进行对比。

从上面我们已经看到 Linux 为我们提供了内存统计的 `rss/vss` 指标，所以很自然地好奇，我们究竟该使用`MemStats`中提供的指标还是 `rss/vss`提供的指标？

使用rss和vss的好处在于它基于 Linux 原语并且与编程语言无关。理论上你可以检测任何程序获知它消耗了多少内存，你可以保证指标命名的一致性，比如Prometheus Go客户端中`process_virtual_memory_bytes` 和 `process_resident_memory_bytes`指标。


但是在实际中，Go 进程启动时会预先占用大量虚拟内存，就像上面那样的简单程序在我的机器（x86_64 Ubuntu）上占用了 544MiB 的 vss，这有点令人困惑，而rss在7Mib左右，这是更接近实际使用情况。

使用基于 Go 运行时的指标可以提供正在运行的应用程序中所发生事情的更细粒度的信息。这样你能够更轻松地找出你的程序是否存在内存泄漏、GC花费了多长时间、内存回收了多少。此外当你优化程序的内存分配时，它为你指明了正确的方向。

我没有详细研究 Go的GC 和内存模型是如何工作的，它们是并发模型的一部分。这部分对我来说还是新知。接下来让我们来看看这些指标：

**go_memstats_alloc_bytes** – 该指标展示了在 [堆](https://en.wikipedia.org/wiki/Memory_management#HEAP) 上为对象分配了多少字节的内存。该值与 **go_memstats_heap_alloc_bytes** 相同。该指标包括所有可达（reachable）堆对象和不可达(unreachable)对象(GC尚未释放的）占用的内存大小。

**go_memstats_alloc_bytes_total** - 该指标随着对象在堆中分配而增加，但在释放对象时并不会减少。我认为它非常有用，因为它的只会增加，类似[Prometheus的计数器](https://povilasv.me/prometheus-tracking-request-duration/)类型，对该指标我们可以使用`rate()`来获取内存消耗速度。

**go_memstats_sys_bytes** – 该指标用于衡量 Go 从系统中总共获取了多少字节的内存。

**go_memstats_lookups_total** – 它是一个计数器值，用于计算有多少指针解引用。我们可以使用`rate()`函数来计算指针解引用速率。

**go_memstats_mallocs_total** – 它是一个计数器值，用于显示有多少堆对象进行分配了。我们可以使用`rate()`函数来计算堆对象分配速率。

**go_memstats_frees_total** – 它是一个计数器值，用于显示有多个堆对象被释放。我们可以使用`rate()`函数计算堆对象释放速率。我们可以通过`go_memstats_mallocs_total – go_memstats_frees_total`得到存活的堆对象数量。

Go 以`span`形式管理内存，`span`是8K大小或更大的连续内存空间。有 3 种类型的`span`：

1. 空闲span – 该span没有存放任何对象可以释放回操作系统，也可重用于堆分配，或重用于栈内存。

2. 正在使用span - 该span上最少有一个堆对象。

3. 栈span – 该span用于`goroutine`栈。这类型span，既可以用于堆，也可以栈，但不会同时用于堆和栈分配。



#### 堆内存指标

**go_memstats_heap_alloc_bytes** – 类似**go_memstats_alloc_bytes**指标.

**go_memstats_heap_sys_bytes** – 该指标显示从操作系统中为堆分配的内存字节数。它包括已保留但尚未使用的 [虚拟地址空间](https://en.wikipedia.org/wiki/Virtual_address_space) 。


**go_memstats_heap_idle_bytes** – 显示空闲span占用的内存字节数。

通过`go_memstats_heap_idle_bytes` 减去 `go_memstats_heap_released_bytes`可以估计出可以是否释放出的内存大小，但这部分内存由Go runtime维持，并不一定会归还OS，以便可以快速用于在堆上分配对象。

**go_memstats_heap_inuse_bytes** – 显示正在使用的span占用字节数。

通过 **go_memstats_heap_alloc_bytes** 减去 **go_memstats_heap_inuse_bytes**可以估算出已分配的堆内存中有多少未被使用

**go_memstats_heap_released_bytes** – 显示有多少空闲span已归还OS.

**go_memstats_heap_objects** – 显示有多少对象是堆上在分配的，它会随着 GC和新对象的分配而改变。


#### 栈内存指标

**go_memstats_stack_inuse_bytes** – 显示栈内存span上已使用的内存大小，该span上面至少分配了一个栈对象。

**go_memstats_stack_sys_bytes** – 显示从 OS 中获得多少字节的栈内存。它是 **go_memstats_stack_inuse_bytes** 加上OS线程栈得到。

Prometheus Go客户端没有提供**go_memstats_stack_idle_bytes**，因为未使用的栈span计入到 **go_memstats_heap_idle_bytes**。


#### 堆外内存指标

堆外内存指标是为Go 运行时内部结构分配的内存大小的指标，这些内部结构没有在堆上分配，因为它们实现了堆。

**go_memstats_mspan_inuse_bytes** - 显示mspan结构体使用的内存大小。

**go_memstats_mspan_sys_bytes** – 显示从操作系统中分配的，用于mspan结构体的内存大小。

**go_memstats_mcache_inuse_bytes** – 显示mcache结构体使用的内存大小。

**go_memstats_mcache_sys_bytes** – 显示从操作系统分配的，用于mcache结构体的内存大小。

**go_memstats_buck_hash_sys_bytes** – 显示用于profiling的哈希表占用的内存大小。


**go_memstats_gc_sys_bytes** – 显示垃圾收集元数据占用内存大小。

**go_memstats_other_sys_bytes** – 显示用于其他运行时分配占用内存大小。

**go_memstats_next_gc_bytes** – 显示下个GC循环时候，堆占用内存大小。GC的目标是保证**go_memstats_heap_alloc_bytes**小于此值。


**go_memstats_last_gc_time_seconds** – 上一次GC完成时的时间戳。

**go_memstats_last_gc_cpu_fraction** – 显示自程序启动以来，GC 所占用CPU时间的比例。该指标也可在设置环境变量`GODEBUG=gctrace=1`时查看到。

## 基于数据进行分析

Prometheus Go客户端提供了很多指标，我认为学习这些指标的最好方法就是使用它，所以我将使用文章开头相同的程序，并获取`/metrics`端点数据，部分数据如下所示：

```
process_resident_memory_bytes 1.09568e+07

process_virtual_memory_bytes 6.46668288e+08

go_memstats_heap_alloc_bytes 2.24344e+06

go_memstats_heap_idle_bytes 6.3643648e+07

go_memstats_heap_inuse_bytes 3.039232e+06

go_memstats_heap_objects 6498

go_memstats_heap_released_bytes 0

go_memstats_heap_sys_bytes 6.668288e+07

go_memstats_lookups_total 0

go_memstats_frees_total 12209

go_memstats_mallocs_total 18707

go_memstats_buck_hash_sys_bytes 1.443899e+06

go_memstats_mcache_inuse_bytes 6912

go_memstats_mcache_sys_bytes 16384

go_memstats_mspan_inuse_bytes 25840

go_memstats_mspan_sys_bytes 32768

go_memstats_other_sys_bytes 1.310909e+06

go_memstats_stack_inuse_bytes 425984

go_memstats_stack_sys_bytes 425984

go_memstats_sys_bytes 7.2284408e+07

go_memstats_next_gc_bytes 4.194304e+06

go_memstats_gc_cpu_fraction 1.421928536233557e-06

go_memstats_gc_sys_bytes 2.371584e+06

go_memstats_last_gc_time_seconds 1.5235057190167596e+09
```

根据上面指标，我们转换得到可读性更好的数据：

```
rss = 1.09568e+07 = 10956800 bytes = 10700 KiB = 10.4 MiB

vss = 6.46668288e+08 = 646668288 bytes = 631512 KiB = 616.7 MiB

heap_alloc_bytes = 2.24344e+06 = 2243440 = 2190 KiB = 2.1 MiB

heap_inuse_bytes = 3.039232e+06 = 3039232 = 2968 KiB = 2,9 MiB

heap_idle_bytes = 6.3643648e+07 = 63643648 = 62152 KiB = 60.6 MiB

heap_released_bytes = 0

heap_sys_bytes = 6.668288e+07 = 66682880 = 65120 KiB = 63.6 MiB

frees_total = 12209

mallocs_total = 18707

mspan_inuse_bytes = 25840 = 25.2 KiB

mspan_sys_bytes = 32768 = 32 KiB

mcache_inuse_bytes = 6912 = 6.8 KiB

mcache_sys_bytes = 16384 = 12 KiB

buck_hash_sys_bytes = 1.443899e+06 = 1443899 = 1410 KiB = 1.4 MiB

gc_sys_bytes = 2.371584e+06 = 2371584 = 2316 KiB = 2.3 MiB

other_sys_bytes = 1.310909e+06 = 1310909 = 1280,2 KiB = 1.3MiB

stack_inuse_bytes = 425984 = 416 KiB

stack_sys_bytes = 425984 = 416 KiB

sys_bytes = 7.2284408e+07 = 72284408 = 70590.2 KiB = 68.9 MiB

next_gc_bytes = 4.194304e+06 = 4194304 = 4096 KiB = 4 MiB

gc_cpu_fraction = 1.421928536233557e-06 = 0.000001
```

有趣的是`heap_inuse_bytes 比 heap_alloc_bytes`多。我个人认为 `heap_alloc_bytes`显示是对象的字节数， `heap_inuse_bytes`显示是span的内存字节数。将`heap_inuse_bytes`除以`span`的大小得出：3039232 / 8192 = 371 个span。

`heap_inuse_bytes`减去`heap_alloc_bytes`，显示的是在使用中的span的可用内存空间大小，即2.9 MiB – 2.1 MiB = 0.8 MiB。这意味着我们可以在不使用新span的情况下，可以在堆上分配 0.8 MiB 的对象。需要注意的是内存碎片的存在。想象一下，如果要创建10K字节的切片时，内存中可能没有10K字节的连续内存块，那么它需要创建新的span，而不是复用。


将`heap_idle_bytes`减去`heap_released_byte`表明我们有大约 60.6 MiB 的未使用span，它们是从操作系统中保留的，可以返回给操作系统。它有 63643648/8192 = 7769 个span。

`heap_sys_bytes`大小是63.6MiB，它是堆的最大大小，拥有66682880/8192 = 8140 个span。

`mallocs_total`显示我们分配了18707 个对象并释放了 12209 个（`go_memstats_frees_total`)。所以目前我们有 18707-12209 = 6498 个对象。我们可以将 `heap_alloc_bytes`除以6498，可以得到对象的平均内存大小是2243440 / 6498 = 345.3 个字节。

sys_bytes大小应该是所有*sys指标的总和，即

> sys_bytes == mspan_sys_bytes + mcache_sys_bytes + buck_hash_sys_bytes + gc_sys_bytes + other_sys_bytes + stack_sys_bytes + heap_sys_bytes

使用上面数字验证：
72284408 == 32768 + 16384 + 1443899 + 2371584 + 1310909 + 425984 + 66682880, which is 72284408 == 72284408，我们发现完全匹配。

关于`sys_bytes`的一个有趣的细节是它的大小是68.9 MiB，而操作系统的`vss`是616.7MiB, `rss`是10.4 MiB。这说明这些数字并不是匹配的。按照我的理解，我们的内存的一部分可能位于 OS 的内存页面中，这些页面位于交换或文件系统中（不在 RAM 中），这也就解释了为什么`rss` 小于 `sys_bytes`了。并且`vss` 包含很多东西，例如映射的 libc、pthreads 库等。你可以从`/proc/PID/maps` 和 `/proc/PID/smaps` 文件中，查看到当前正在映射的内容。

`gc_cpu_fraction` 运行得非常低，只有0.000001 的 CPU 时间用于 GC。这真的很酷。

`next_gc_bytes` 显示 GC 的目标是将 `heap_alloc_bytes` 保持在 4 MiB 以下，因为`heap_alloc_bytes` 目前为 2.1 MiB，说明GC 目标已达成。



## 进一步阅读

- http://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/proc.html 
- https://www.kernel.org/doc/Documentation/filesystems/proc.txt
- http://man7.org/linux/man-pages/man2/getpagesize.2.html
- https://linux.die.net/man/2/setrlimit
- https://golang.org/ref/mem