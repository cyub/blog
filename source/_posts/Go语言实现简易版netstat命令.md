title: Go语言实现简易版netstat命令
author: tinker
tags:
  - netstat
categories:
  - Golang
date: 2020-11-22 20:22:00
---
## netstat工作原理

netstat命令是linux系统中查看网络情况的一个命令。比如我们可以通过`netstat -ntlp | grep 8080`查看监听8080端口的进程。

![](https://static.cyub.vip/images/202012/netstat-example.jpg)

netstat工作原理如下：

1. 通过读取/proc/net/tcp 、/proc/net/tcp6文件，获取socket本地地址，本地端口，远程地址，远程端口，状态，inode等信息
2. 接着扫描所有/proc/[pid]/fd目录下的的socket文件描述符，建立inode到进程pid映射
3. 根据pid读取/proc/[pid]/cmdline文件，获取进程命令和启动参数
4. 根据2,3步骤，即可以获得1中对应socket的相关进程信息

<!--more-->
我们可以做个测试验证整个流程。先使用nc命令监听8090端口:

```bash
nc -l 8090
```

找到上面nc进程的pid，查看该进程所有打开的文件描述符:

```bash
vagrant@vagrant:/proc/25556/fd$ ls -alh
total 0
dr-x------ 2 vagrant vagrant  0 Nov 18 12:21 .
dr-xr-xr-x 9 vagrant vagrant  0 Nov 18 12:20 ..
lrwx------ 1 vagrant vagrant 64 Nov 18 12:21 0 -> /dev/pts/1
lrwx------ 1 vagrant vagrant 64 Nov 18 12:21 1 -> /dev/pts/1
lrwx------ 1 vagrant vagrant 64 Nov 18 12:21 2 -> /dev/pts/1
lrwx------ 1 vagrant vagrant 64 Nov 18 12:21 3 -> socket:[2226056]
```

上面列出的所有文件描述中，`socket:[2226056]`为nc命令监听8090端口所创建的socket。其中`2226056`为该socket的inode。

根据该inode号，我们查看`/proc/net/tcp`对应的记录信息，其中`1F9A`为本地端口号，转换成十进制恰好为8090：

```bash
vagrant@vagrant:/proc/25556/fd$ cat /proc/net/tcp | grep 2226056
   1: 00000000:1F9A 00000000:0000 0A 00000000:00000000 00:00000000 00000000  1000        0 2226056 1 0000000000000000 100 0 0 10 0
```

根据进程id，我们查看进程名称和启动参数：

```bash
vagrant@vagrant:/proc/25556/fd$ cat /proc/25556/cmdline
nc-l8090
```

下面我们看下`/proc/net/tcp`文件格式。

## /proc/net/tcp文件格式

`/proc/net/tcp`文件首先会列出所有监听状态的TCP套接字，然后列出所有已建立的TCP套接字。我们通过`head -n 5 /proc/net/tcp`命令查看该文件头五行：

```
sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   0: 0100007F:0019 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 22279 1 0000000000000000 100 0 0 10 0
   1: 00000000:1FBB 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 21205 1 0000000000000000 100 0 0 10 0
   2: 00000000:26FB 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 21203 1 0000000000000000 100 0 0 10 0
   3: 00000000:26FD 00000000:0000 0A 00000000:00000000 00:00000000 00000000     0        0 21201 1 0000000000000000 100 0 0 10 0
```

每一行各个字段解释说明如下，由于太长分为三部分说明：

第一部分：

```
   46: 010310AC:9C4C 030310AC:1770 01 
   |      |      |      |      |   |--> 连接状态，16进制表示，具体值见下面说明
   |      |      |      |      |------> 远程TCP端口号，主机字节序，16进制表示
   |      |      |      |-------------> 远程IPv4地址，网络字节序，16进制表示
   |      |      |--------------------> 本地TCP端口号，主机字节序，16进制表示
   |      |---------------------------> 本地IPv4地址，网络字节序，16进制表示
   |----------------------------------> 条目编号，从0开始
```

上面连接状态所有值如下，具体参见linux源码[tcp_states.h](https://github.com/torvalds/linux/blob/b3298500b23f0b53a8d81e0d5ad98a29db71f4f0/include/net/tcp_states.h#L12)：

```c
enum {
	TCP_ESTABLISHED = 1,
	TCP_SYN_SENT,
	TCP_SYN_RECV,
	TCP_FIN_WAIT1,
	TCP_FIN_WAIT2,
	TCP_TIME_WAIT,
	TCP_CLOSE,
	TCP_CLOSE_WAIT,
	TCP_LAST_ACK,
	TCP_LISTEN,
	TCP_CLOSING,	/* Now a valid state */
	TCP_NEW_SYN_RECV,

	TCP_MAX_STATES	/* Leave at the end! */
};
```

第二部分：

```
00000150:00000000 01:00000019 00000000  
      |        |     |     |       |--> number of unrecovered RTO timeouts
      |        |     |     |----------> number of jiffies until timer expires
      |        |     |----------------> timer_active，具体值见下面说明
      |        |----------------------> receive-queue，当状态是ESTABLISHED，表示接收队列中数据长度；状态是LISTEN，表示已经完成连接队列的长度
      |-------------------------------> transmit-queue，发送队列中数据长度
```

timer_active所有值与说明如下:
  
- 0  no timer is pending
- 1  retransmit-timer is pending
- 2  another timer (e.g. delayed ack or keepalive) is pending
- 3  this is a socket in TIME_WAIT state. Not all fields will contain data (or even exist)
- 4  zero window probe timer is pending

第三部分：

```
 1000        0 54165785 4 cd1e6040 25 4 27 3 -1
    |          |    |     |    |     |  | |  | |--> slow start size threshold, 
    |          |    |     |    |     |  | |  |      or -1 if the threshold
    |          |    |     |    |     |  | |  |      is >= 0xFFFF
    |          |    |     |    |     |  | |  |----> sending congestion window
    |          |    |     |    |     |  | |-------> (ack.quick<<1)|ack.pingpong
    |          |    |     |    |     |  |---------> Predicted tick of soft clock
    |          |    |     |    |     |              (delayed ACK control data)
    |          |    |     |    |     |------------> retransmit timeout
    |          |    |     |    |------------------> location of socket in memory
    |          |    |     |-----------------------> socket reference count
    |          |    |-----------------------------> socket的inode号
    |          |----------------------------------> unanswered 0-window probes
    |---------------------------------------------> socket所属用户的uid
```


## Go实现简易版本netstat命令

netstat工作原理和`/proc/net/tcp`文件结构，我们都已经了解了，现在可以使用据此使用Go实现一个简单版本的netstat命令。

![](https://static.cyub.vip/images/202012/go-netstat.jpg)


核心代码如下，完整代码参加[go-netstat](https://github.com/cyub/code-examples/tree/master/go/go-netstat)：
```go
// 状态码值
const (
	TCP_ESTABLISHED = iota + 1
	TCP_SYN_SENT
	TCP_SYN_RECV
	TCP_FIN_WAIT1
	TCP_FIN_WAIT2
	TCP_TIME_WAIT
	TCP_CLOSE
	TCP_CLOSE_WAIT
	TCP_LAST_ACK
	TCP_LISTEN
	TCP_CLOSING
	//TCP_NEW_SYN_RECV
	//TCP_MAX_STATES
)

// 状态码
var states = map[int]string{
	TCP_ESTABLISHED: "ESTABLISHED",
	TCP_SYN_SENT:    "SYN_SENT",
	TCP_SYN_RECV:    "SYN_RECV",
	TCP_FIN_WAIT1:   "FIN_WAIT1",
	TCP_FIN_WAIT2:   "FIN_WAIT2",
	TCP_TIME_WAIT:   "TIME_WAIT",
	TCP_CLOSE:       "CLOSE",
	TCP_CLOSE_WAIT:  "CLOSE_WAIT",
	TCP_LAST_ACK:    "LAST_ACK",
	TCP_LISTEN:      "LISTEN",
	TCP_CLOSING:     "CLOSING",
	//TCP_NEW_SYN_RECV: "NEW_SYN_RECV",
	//TCP_MAX_STATES:   "MAX_STATES",
}

// socketEntry结构体，用来存储/proc/net/tcp每一行解析后数据信息
type socketEntry struct {
	id      int
	srcIP   net.IP
	srcPort int
	dstIP   net.IP
	dstPort int
	state   string

	txQueue       int
	rxQueue       int
	timer         int8
	timerDuration time.Duration
	rto           time.Duration // retransmission timeout
	uid           int
	uname         string
	timeout       time.Duration
	inode         string
}

// 解析/proc/net/tcp行记录
func parseRawSocketEntry(entry string) (*socketEntry, error) {
	se := &socketEntry{}
	entrys := strings.Split(strings.TrimSpace(entry), " ")
	entryItems := make([]string, 0, 17)
	for _, ent := range entrys {
		if ent == "" {
			continue
		}
		entryItems = append(entryItems, ent)
	}

	id, err := strconv.Atoi(string(entryItems[0][:len(entryItems[0])-1]))
	if err != nil {
		return nil, err
	}
	se.id = id                                     // sockect entry id
	localAddr := strings.Split(entryItems[1], ":") // 本地ip
	se.srcIP = parseHexBigEndianIPStr(localAddr[0])
	port, err := strconv.ParseInt(localAddr[1], 16, 32) // 本地port
	if err != nil {
		return nil, err
	}
	se.srcPort = int(port)

	remoteAddr := strings.Split(entryItems[2], ":") // 远程ip
	se.dstIP = parseHexBigEndianIPStr(remoteAddr[0])
	port, err = strconv.ParseInt(remoteAddr[1], 16, 32) // 远程port
	if err != nil {
		return nil, err
	}
	se.dstPort = int(port)

	state, _ := strconv.ParseInt(entryItems[3], 16, 32) // socket 状态
	se.state = states[int(state)]

	tcpQueue := strings.Split(entryItems[4], ":")
	tQueue, err := strconv.ParseInt(tcpQueue[0], 16, 32) // 发送队列数据长度
	if err != nil {
		return nil, err
	}
	se.txQueue = int(tQueue)
	sQueue, err := strconv.ParseInt(tcpQueue[1], 16, 32) // 接收队列数据长度
	if err != nil {
		return nil, err
	}
	se.rxQueue = int(sQueue)

	se.uid, err = strconv.Atoi(entryItems[7]) // socket uid
	if err != nil {
		return nil, err
	}
	se.uname = systemUsers[entryItems[7]] // socket user name
	se.inode = entryItems[9]              // socket inode
	return se, nil
}

// hexIP是网络字节序/大端法转换成的16进制的字符串
func parseHexBigEndianIPStr(hexIP string) net.IP {
	b := []byte(hexIP)
	for i, j := 1, len(b)-2; i < j; i, j = i+2, j-2 { // 反转字节，转换成小端法
		b[i], b[i-1], b[j], b[j+1] = b[j+1], b[j], b[i-1], b[i]
	}
	l, _ := strconv.ParseInt(string(b), 16, 64)
	return net.IPv4(byte(l>>24), byte(l>>16), byte(l>>8), byte(l))
}
```

## 参考

- [/proc/net/tcp官方文档](https://github.com/torvalds/linux/blob/v5.9/Documentation/networking/proc_net_tcp.rst)