title: Wireshark抓包分析的几个小技巧
author: tinker
tags:
  - Wireshark
categories: []
date: 2020-12-06 17:59:00
---
[Wireshark](https://www.wireshark.org/)是一款强大的抓包分析工具。它支持抓取分析TCP数据段、UDP数据包，应用层协议比如Http、Http2、Https(但不支持Https解密)、gRPC等。这里面列几个我使用过程中的用到的小技巧。
<!--more-->


## 显示TCP报文段的绝对序号

当Tcp连接建立时，会随机生成一个32位的ISN号(Initial Sequence Number)对应报文段第一个字节数据，以后每传输一个字节该ISN都会加1。Wireshark默认显示报文的序号和确认序号都是相对值。如果我们希望显示绝对值序号，可以按照以下步骤操作。

> Wireshark菜单栏 => Edit => Preferences => protocols => TCP

然后去掉`Relative sequence number`的选中状态。

## 查看Http2/gRPC协议

Wireshark默认不会解析Http2协议的，我们需要手动指定端口按照Http2协议解析。

我们首选需要启动Http2协议，操作位置如下：

> Wireshark菜单栏 => 分析 => 启动的协议

搜索Http2，找到之后将http2_tcp和http2_tls都勾选中

![](https://static.cyub.vip/images/202012/wireshark_http2.jpg)

接下来设置端口与协议映射：

> Wireshark菜单栏 => 分析 => 解码为

将Http2协议的端口映射为http2协议解码。下图显示的是将8080端口映射为http2协议解码：

![Wireshare解码设置](https://static.cyub.vip/images/202012/wireshark_decode_as.jpg)

gRPC协议同理操作。



## 保存过滤条件

Wireshark主界面由5部分组成。
1. 过滤器栏，用于过滤筛选
2. 封包列表栏，用于显示捕获到的封包
3. 封包详细信息栏，用于显示封包的详细信息，从上到下依次为：
	1. Frame: 物理层-数据帧概况
	2. Ethernet II: 数据链路层-以太网帧头部信息
	3. Internet Protocol Version 4: IP包头部信息
	4. Transmission Control Protocol:  TCP数据段头部信息
    5. 应用层信息，若wireshark不支持该应用层协议解析，则这部分内容块名称显示为Data，否则显示对应协议名称
4. 16进制数据栏, 以16进制格式显示封包信息
5. 地址栏，用于显示杂项信息

对于常用的过滤的条件，可以保存到过滤器栏最右侧，方便下次使用:

![Wireshark过滤](https://static.cyub.vip/images/202012/wireshark_filter.jpg)

![Wireshark过滤条件保存](https://static.cyub.vip/images/202012/wireshark_filter2.jpg)

## 分析远程服务器上封包信息

有时候我们希望能够使用wireshark分析远程服务器上面的封包信息。尽管tcpdump抓包命令能够抓取分析服务器上面的信息，但是其分析起来不够直观。解决这个问题有两个办法，第一个办法是使用tcpdump命令的`-w`选项将抓包的原始信息保存到文件中，然后将文件拉取下来使用wireshark分析。另一个办法是使用ssh连接，实时的将tcpdump抓包数据传递给wireshark进行分析。

```bash
// window系统，注意需要切换Wireshark.exe所在目录
ssh vagrant@192.168.33.10 'sudo tcpdump -i enp0s8 -e -XX -w - port 8080 -U' | ./Wireshark.exe -k -i -

// mac系统
ssh vagrant@192.168.33.10 'sudo tcpdump -i enp0s8 -e -XX -w - port 8080 -U' | /Applications/Wireshark.app/Contents/MacOS/Wireshark -k -i -
```

注意：

1. window系统里面没有ssh命令的，可以通过安装[Cygwin](http://cygwin.com/)来安装ssh等相关命令。

2. tcpdump命令的`-U`选项需指定，否则tcpdump抓取的包数据并不会实时的显示到wireshark里面。




