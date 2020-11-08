title: 多网卡模式下Golang应用的流量从指定网卡流入流出方案
author: tinker
tags:
  - Golang
  - docker
  - iptables
  - nat
categories:
  - Golang
  - 项目总结
date: 2020-11-07 18:17:00
---
最近因业务需要，需要在多网卡模式下实现Go应用的流量从指定网卡流入，请求外网服务时候流量需要从该网卡流出功能。从指定网卡流入很容易实现，只要go应用listen对应网卡即可，但请求外网服务时候就相对麻烦些了。在实践中总结出有三种方案可行。各有优劣。

假定服务器网卡情况如下：

|  网卡  | 网卡IP  | 对应的公网IP
|  ----  | ----  | --- |
| eth0 | 172.31.0.8 | 109.25.48.65
| eth1 | 172.31.0.14 | 119.26.38.75

实际上我们的服务器使用云服务器，网卡是弹性网卡(eni)，绑定的是弹性ip(eip)。三种方案对普通服务器也是能达到目的的。

<!--more-->

Go应用示例代码:

```go
package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

var addr = flag.String("addr", ":8080", "the http server address")

func init() {
	flag.Parse()
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		splits := strings.Split(*addr, ":")
		localIP := ""
		if len(splits) == 2 {
			localIP = splits[0]
		}
		res, err := HTTPGet("http://haoip.cn")
		if err != nil {
			panic(err)
		}
		defer res.Body.Close()

		body, err := ioutil.ReadAll(res.Body)
		if err != nil {
			panic(err)
		}
		fmt.Fprintf(w, "网卡的IP: %s\n\n", localIP)
		fmt.Fprintf(w, "出口的IP:\n\n %s", body)
	})

	err := http.ListenAndServe(*addr, nil)
	if err != nil {
		panic(err)
	}
}

// HTTPGet func
func HTTPGet(url string) (*http.Response, error) {
	req, _ := http.NewRequest("GET", url, nil)
	client := &http.Client{}
	req.Header.Set("User-Agent", "curl/7.47.0")
	return client.Do(req)
}
```


### 方案一 应用流量出口绑定网卡

当请求外网服务时候，程序需要在每一处http client的地方指定源IP为特定网卡的IP。该方案原理简单，不依赖外部其他服务，缺点就是对应用有侵入性。

示例程序中HTTPGet方法需要进行如下改动：

```go
// localIP是网卡IP
func HTTPGet(url, localIP string) (*http.Response, error) {
	req, _ := http.NewRequest("GET", url, nil)
	client := &http.Client{
		Transport: &http.Transport{
			Dial: func(netw, addr string) (net.Conn, error) {
				// localIP 网卡IP，":0" 表示端口自动选择
				lAddr, err := net.ResolveTCPAddr(netw, localIP+":0")
				if err != nil {
					return nil, err
				}

				rAddr, err := net.ResolveTCPAddr(netw, addr)
				if err != nil {
					return nil, err
				}
				conn, err := net.DialTCP(netw, lAddr, rAddr)
				if err != nil {
					return nil, err
				}
				return conn, nil
			},
		},
	}
	return client.Do(req)
}
```

运行程序时候分别要监听指定网卡的ip：

```
go run main.go --addr=172.31.0.8:8090
go run main.go --addr=172.31.0.14:8090
```

这样当我们访问109.25.48.65:8090时候，流量从eth0流入到go应用，当go请求haoip.cn地址，使用eth0这个网卡流出的。访问119.26.38.75:8090时候，流出从eth1流入go应用，当go请求haoip.cn地址，流量从eth1这个网卡流出。



### 方案二 基于Docker容器技术

Docker容器基于namespace实现网络、进程、挂载等资源隔离功能。如果将go应用打包成镜像，绑定指定网卡，以容器形式运行不就可以实现流量流出控制了。

创建Dockerfile，并写入以下内容：

```
FROM golang:1.14

LABEL maintainer="tink tink@example.com"

WORKDIR /app

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
```

Dockerfile文件和go应用示例代码放在同一个目录下，然后执行以下命令构成go应用的镜像：

```
docker build -t eip .
```

#### 创建docker bridge网络

我们创建一个专门用于go应用的bridge网络: eip_bridge。子网范围是`172.19.0.0/16`

```
docker network create --subnet=172.19.0.0/16 --opt "com.docker.network.bridge.name"="eip_bridge"  eip_bridge
```

#### 运行go应用容器

```
// 绑定网卡eth0
docker run --network=eip_bridge -p 172.31.0.8:8090:8080 --ip=172.19.0.100 -d eip:latest

// 绑定网卡eth1
docker run --network=eip_bridge -p 172.31.0.14:8090:8080  --ip=172.18.0.101 -d eip:latest
```

上面命令说明：

- -p 172.31.0.8:8090:8090 给该容器端口映射，主机端口8090映射到容器端口8080，由于指定ip为172.31.0.8，这样我们就可以109.25.48.65:8090访问这个容器了。
- --ip=172.19.0.100。为该容器指定一个固定ip

通过上面命令运行容器，这样每个容器的流量流入是从指定网卡流入。但容器内请求外网服务时候并没有从各自指定网卡流出。实际上走的都是一个同一个网卡，要么eth0，要么eth1。这是因为容器流出的都会经过eip_bridge这个网桥，而这个网桥流出流量的目的地址要么是eth0,要么是eth1。

这时候我们可以通过SNAT技术，将容器的源地址分别改成对应绑定的网卡地址就可以了。

```
sudo iptables -t nat -I POSTROUTING -p all -s 172.19.0.100 -j SNAT --to-source 172.31.0.8

sudo iptables -t nat -I POSTROUTING -p all -s 172.19.0.101 -j SNAT --to-source 172.31.0.14
```

注意：网桥的流量流出也是通过iptables的snat进行实现的。针对特定容器的iptables规则一定要在该网桥的规则前面。



### 方案三 DNAT/SNAT技术实现

方案思路是创建两个虚拟网卡或网桥br-eip1（172.19.0.100）和br-eip2（172.19.0.101）。go应用分别监听网卡br-eip1和网卡br-eip2。通过DNAT技术将来eth0的流量导向br-eip1，将来自eth1的流程导向br-eip2。同过SNAT技术将从br-eip1流出的外部流量导向eth0，br-eip2流出的流量导向eth1

#### 创建虚拟网卡

```
apt-get install bridge-utils // 安装brctl

sudo brctl addbr br-eip1 // 添加网桥
sudo ip link set br-eip1 up // 激活网桥
sudo ifconfig  br-eip1 172.19.0.100 // 指定br-eip1网桥的ip

sudo brctl addbr br-eip2 // 添加网桥
sudo ip link set br-eip2 up // 激活网桥
sudo ifconfig  br-eip2 172.19.0.101 // 指定br-eip2网桥的ip
```

#### DNAT配置流量流入

```
sudo iptables -t nat -I PREROUTING -d 172.31.0.8/32 ! -i br-eip1 -p tcp -m tcp --dport 8090 -j DNAT --to-destination 172.19.0.100:8090

sudo iptables -t nat -I PREROUTING -d 172.31.0.14/32 ! -i br-eip2 -p tcp -m tcp --dport 8090 -j DNAT --to-destination 172.19.0.101:8090
```

#### SNAT配置流量流出

```
sudo iptables -t nat -I POSTROUTING -p all -s 172.19.0.100 -j SNAT --to-source 172.31.0.8

sudo iptables -t nat -I POSTROUTING -p all -s 172.19.0.101 -j SNAT --to-source 172.31.0.14
```
