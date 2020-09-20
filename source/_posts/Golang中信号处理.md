title: Golang中信号处理
author: tinker
tags: []
categories: []
date: 2020-09-20 18:40:00
---
信号(signal)是进程间通讯的一种方式，用来提醒进程某个事件已经发生。它属于一种异步通知进制。一个进程不必通过任何操作来等待信号的到达，事实上进程也不知道信号到底什么时候到达。

在Linux系统中，我们可以通过`kill -l`查看系统支持的信号。如果应用程序注册了某个信号处理的函数，那么当信号达到时候，则该函数会被调用，否则缺省的动作（action）被调用。

<!--more-->

信号分为非实时信号(不可靠信号)和实时信号（可靠信号）两种类型，对应于 Linux 的信号值为 1-31 和 34-64。我们可以通过`man 7 signal`命令查看信号默认处置动作，如何发送信号、以及信号列表等信息。

### 信号处理默认动作（ Signal disposition action)

当应用程序收到信号时候，进程会根据信号类型来做出相应的处置动作来进行响应。信号处置动作有以下几种：

动作 | 功能
---|---
Term | Default action is to <b>terminate</b> the process
Ign  | Default action is to <b>ignore</b> the signal
Core | Default action is to terminate the process and <b>dump core</b> 
Stop | Default action is to <b>stop</b> the process
Cont | Default action is to <b>continue</b> the process if it is currently stopped

### 发送信号

我们可以通过系统调用或库函数来发送信号：

系统调用/库函数 | 功能
---|---
raise | Sends a signal to the calling thread.
kill | Sends a signal to a specified process, to all members of  a  specified  process group, or to all processes on the system.
killpg | Sends a signal to all of the members of a specified process group.
pthread_kill | Sends a signal to a specified POSIX thread in the same process as the caller

我们也可以直接通过`kill`或`pkill`命令发送信号给某个进程：

```bash
kill process_id // 默认发送SIGTERM信号，用来终止进程
kill -1 process_id // 发送SIGHUP信号，等效于kill HUP process_id 
kill -9 process_id // 强制终止进程，等效于kill KILL process_id
pkill process_name // 发送SIGTERM信号
```

当进程运作在终端时候，我们可以通过特定组合键发送信号给该进程：

- **Ctrl-C** 发送 INT signal (SIGINT)，通常导致进程结束
- **Ctrl-Z** 发送 TSTP signal (SIGTSTP); 通常导致进程挂起(suspend)
- **Ctrl-\\** 发送 QUIT signal (SIGQUIT); 通常导致进程结束 和 dump core.
- **Ctrl-T** (不是所有的UNIX都支持) 发送INFO signal (SIGINFO); 导致操作系统显示此运行命令的信息


### 信号类型

POSIX.1-1990标准信号列表如下：

信号 | 值 | 动作 | 说明
---|---|---|--
SIGHUP | 1 |  Term  | 终端控制进程结束(终端连接断开)
SIGINT |  2   |  Term   | 用户发送INTR字符(Ctrl+C)触发
SIGQUIT | 3  |      Core   | 用户发送QUIT字符(Ctrl+\)触发
SIGILL  | 4   | Core    | 	非法指令(程序错误、试图执行数据段、栈溢出等)
SIGABRT   | 6  |     Core |   	调用abort函数触发
SIGFPE      |  8    |   Core   | 算术运行错误(浮点运算错误、除数为零等)
SIGKILL | 9  | Term  | 	无条件结束程序(不能被捕获、阻塞或忽略)，用于强制杀死进程
SIGSEGV  | 11  | Core | 无效内存引用(试图访问不属于自己的内存空间、对只读内存空间进行写操作)
SIGPIPE  | 13  | Term | 消息管道损坏(FIFO/Socket通信时，管道未打开而进行写操作)
SIGALRM  | 14  | Term | 时钟定时信号
SIGTERM  | 15   | Term | 	结束程序(可以被捕获、阻塞或忽略)，用于优雅终止进程
SIGUSR1  | 30,10,16  | Term  | 用户定义信号1
SIGUSR2  | 31,12,17  |  Term  |  用户定义信号2
SIGCHLD   | 20,17,18   | Ign   |  	子进程结束(由父进程接收)
SIGCONT  | 19,18,25   | Cont  | 继续执行已经停止的进程(不能被阻塞)
SIGSTOP  | 17,19,23   | Stop  |  	停止进程(不能被捕获、阻塞或忽略)
SIGTSTP  | 18,20,24   | Stop   | 	停止进程(可以被捕获、阻塞或忽略)
SIGTTIN   | 21,21,26   | Stop   | 	后台程序从终端中读取数据时触发
SIGTTOU   | 22,22,27   | Stop    | 后台程序向终端中写数据时触发


注意：

1. `SIGKILL`和`SIGSTOP`信号是不能被捕获，阻塞和忽略的
2. Window系统是不支持`SIGUSR1`和`SIGUSR2`信号的



通过信号接收和处理，Nginx服务器能够完成配置重新加载，优雅退出等功能。在程序中我们也可以根据Nginx信号设计机制来完成我们的功能。下面列出Nginx(Master进程)处理的信号，以及对应的功能。

- **ERM/INT** 快速退出，当前的请求不执⾏完成就退出
- **QUIT** 优雅退出，执⾏完当前的请求后退出
- **HUP** 重新加载配置⽂件，⽤新的配置⽂件启动新worker进程，并优雅的关闭旧的worker进
程
- **USR1** 重新打开⽇志⽂件
- **USR2** 平滑的升级nginx⼆进制⽂件
- **WINCH** 优雅的关闭worker进程



### Golang中的信号

#### Go程序对信号的默认行为

Go 语言实现了自己的运行时，对信号的默认处理方式会与标准Unix C应用有一些不太一样：

- **SIGBUS**（总线错误）, **SIGFPE**（算术错误）和 **SIGSEGV**（段错误）称为同步信号，它们在程序执行错误时触发，而不是通过 os.Process.Kill 之类的触发。当捕获到此类信号时候，Go程序会产生runtime panic
- **SIGHUP**（挂起）, **SIGINT**（中断）或 **SIGTERM**（终止）默认会使得程序终止退出
- **SIGQUIT**, **SIGILL**, **SIGTRAP**, **SIGABRT**, **SIGSTKFLT**, **SIGEMT**, **SIGSYS** 默认会使程序退出，并打印出每个Goroutine的栈跟踪(stack trace)信息
- **SIGTSTP**, **SIGTTIN** 或 **SIGTTOU**，这是 shell 使用的作业控制的信号，会执行系统默认的行为
- **SIGPROF** Go运行时使用该信号实现 runtime.CPUProfile（性能分析定时器，记录 CPU 时间，包括用户态和内核态）

对于`SIGPIPE`信号，如果 Go 程序往一个 `broken pipe` 写数据，内核会产生一个`SIGPIPE`信号。如果Go 程序没有为`SIGPIPE`信号调用`Notify`，对于写入对象是标准输出或标准错误，该信号会使得程序退出；但其他文件描述符（比如网络连接）对该信号是啥也不做，write会返回错误 `EPIPE`。

如果 Go 程序为`SIGPIPE` 调用了`Notify`，不论什么文件描述符，`SIGPIPE` 信号都会传递给 Notify channel，write 依然会返回 EPIPE。这也就是说Go的命令行程序跟传统的 Unix 命令行程序行为一致；但当往一个关闭的网络连接写数据时，传统 Unix 程序会crash，但 Go 程序不会。


#### signal包中的API

Golang中`os/signal`包实现了信号发送、接收、忽略等功能。`os/signal`包中API有以下几个：

#####  Ignore 函数

用来忽略一个、多个或全部（不提供任何信号）信号。函数签名如下：

> func Ignore(sig ...os.Signal)

对一个信号，如果先调用 Notify，再调用 Ignore，Notify 的效果会被取消；如果先调用 Ignore，在调用 Notify，接着调用 Reset/Stop 的话，会起到Ingore 的效果


##### Notify 函数

通过通道实现类似给信号绑定信号处理函数的功能。

> func Notify(c chan<- os.Signal, sig ...os.Signal)


将输入信号转发到 chan c，若sig为空，则会把所有输入信号都传递到c。如果c阻塞了，`siganl`包会直接放弃该信号，所有调用者应该保证c有足够的缓存的空间。对于使用单一信号通知的channel，缓存为1就足够了。

##### Stop 函数

用来让`signal`包停止向通道转发信号。


> func Stop(c chan<- os.Signal)

它会取消之前使用 c 调用的所有 Notify 的效果。当 Stop 返回后，会保证 c 不再接收到任何信号。

##### Reset 函数

用来重置信号的处理程序；若sig为空， 则所有信号处理都被重置。

> func Reset(sig ...os.Signal)



#### 使用示例

##### 监听所有信号

```go
func main()  {
    c := make(chan os.Signal)
    signal.Notify(c)
    s := <-c
    fmt.Println("退出信息", s)
}
```

注意：在实际使用中，一定要指定使用的信号，不要监听所有信号。在实际项目中，就遇到胡乱使用信号导致的问题：

```go
srv := &http.Server{
		Addr:    app.Addr,
		Handler: app.Gin,
	}
go func() {
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("http listen fatal error %s\n", err)
	}
}()
    
c := make(chan os.Signal, 1)
signal.Notity(c) // 监听所有信号，当接收到信号时候，应用进程会退出
<-c
```

上面http服务程序想当然的认为信号都是由人为发送的（比如手动退出程序时候，kill命令），其实当server向已断开的客户端写入数据时候，系统会产生SIGPIPE信号。或者客户端向Go Http应用发送带外数据时候，系统内核会传递SIGURG信号给Go应用。这两种情况都会导致Go应用非常退出。



##### 守护进程优雅退出

通过监听`SIGQUIT`, `SIGINT`等信号，我们可以实现http服务优雅退出功能：

```go
WaitGracefulExit(srv *http.Server) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT)
	for {
		s := <-c
		switch s {
		case syscall.SIGQUIT, syscall.SIGTERM, syscall.SIGINT:
			logger.Debug("server will exit")
			srv.Close()
			logger.Debug("server exited")
			return
		default:
		}
	}
}
```


##### 打印stack trace信息

根据上面Go程序对信号的默认行为中的描述，Go应用程序在收到`SIGQUIT`、`SIGABRT`等信号时候会打印出所有Goroutine的栈跟踪信息，但会退出应用。如果我们想实现不退出也能打印出栈信息，可以监听信息`SIGUSER1`信号并打印stack trace信息。

```go
c := make(chan os.Signal, 1)
signal.Notify(c, syscall.SIGUSR1)
go func() {
	for range c {
		DumpStacks()
	}
}()
    
func DumpStacks() {
	buf := make([]byte, 16384)
	buf = buf[:runtime.Stack(buf, true)]
	fmt.Printf("=== BEGIN goroutine stack dump ===\n%s\n=== END goroutine stack dump ===", buf)
}
```

注意：window系统是不支持`SIGUSER1`信号，如果要支持window系统，我们可以换成`SIGHUP`信号。