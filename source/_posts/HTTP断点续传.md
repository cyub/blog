---
title: HTTP断点续传
date: 2017-06-12 14:11:56
tags:
	- HTTP协议
---

## 断点续传简介
断点续传是HTTP/1.1协议支持的特性。实现断点续传的功能，需要客户端记录下当前的下载进度，并在需要续传的时候通知服务端本次需要下载的内容片段。
<!--more-->

## 断点续传流程

一个最简单的断点续传流程如下：
1. 客户端开始下载一个1024K的文件，服务端发送Accept-Ranges: bytes来告诉客户端，其支持带Range的请求
2. 假如客户端下载了其中512K时候网络突然断开了，过了一会网络可以了，客户端再下载时候，需要在HTTP头中申明本次需要续传的片段： `Range:bytes=512000-`这个头通知服务端从文件的512K位置开始传输文件，直到文件内容结束
3. 服务端收到断点续传请求，从文件的512K位置开始传输，并且在HTTP头中增加： `Content-Range:bytes 512000-/1024000`,`Content-Length: 512000`。并且此时服务端返回的HTTP状态码应该是206 Partial Content。如果客户端传递过来的Range超过资源的大小,则响应416 Requested Range Not Satisfiable

通过上面流程可以看出：断点续传中4个HTTP头不可少的，分别是Range头、Content-Range头、Accept-Ranges头、Content-Length头。其中第一个Range头是客户端发过来的，后面3个头需要服务端发送给客户端。下面是它们的说明：
**Accept-Ranges: bytes**
这个值声明了可被接受的每一个范围请求, 大多数情况下是字节数 bytes
**Range: bytes=开始位置-结束位置**
Range是浏览器告知服务器所需分部分内容范围的消息头。0表示第一个字节，也就是Range计算字节数是从0开始的，开始/结束位置含义如下：
1. 如果结束位置被去掉了，服务器会返回从声明的开始位置到整个内容的结束位置内容的最后一个可用字节.
2. 如果开始位置被去掉了，结束位置参数可以被描述成从最后一个可用的字节算起可以被服务器返回的字节数

一些示例：
表示头100个字节：bytes=0-99
表示第二个100字节：bytes=100-199
表示最后100个字节：bytes=-100
表示100字节以后的范围：bytes=100-
第一个和最后一个字节：bytes=0-0,-1
同时指定几个范围：bytes=100-200,201-300
**Content-Range: bytes 开始位置-结束位置/文件总字节数**
计算字节数也是从0开始的
**Content-Length: 响应内容长度**
响应内容大小

我们可以使用CURL命令来测试服务端响应情况，下面我们测试百度logo，使用断点请求
```
curl -I  -H 'Range: bytes=0-100' https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png

HTTP/1.1 206 Partial Content
Server: bfe/1.0.8.13-sslpool-patch
Date: Mon, 12 Jun 2017 07:32:39 GMT
Content-Type: image/png
Content-Length: 101
Connection: keep-alive
ETag: "5913ffa0-e7a"
Last-Modified: Thu, 11 May 2017 06:07:28 GMT
Expires: Thu, 22 Jun 2017 18:00:49 GMT
Age: 1690309
Cache-Control: max-age=2592000
Content-Range: bytes 0-100/3706
Accept-Ranges: bytes
Ohc-Response-Time: 1 0 0 0 0 0
```

在实际场景中，会出现一种情况，即在终端发起续传请求时，URL对应的文件内容在服务端已经发生变化，此时续传的数据肯定是错误的。如何解决这个问题了？显然此时我们需要有一个标识文件唯一性的方法。在RFC2616中也有相应的定义，比如实现Last-Modified来标识文件的最后修改时间，这样即可判断出续传文件时是否已经发生过改动。同时RFC2616中还定义有一个ETag的头，可以使用ETag头来放置文件的唯一标识，比如文件的MD5值。终端在发起续传请求时应该在HTTP头中申明If-Match 或者If-Modified-Since 字段，帮助服务端判别文件变化。 

另外RFC2616中同时定义有一个If-Range头，终端如果在续传是使用If-Range。If-Range中的内容可以为最初收到的ETag头或者是Last-Modfied中的最后修改时候。服务端在收到续传请求时，通过If-Range中的内容进行校验，校验一致时返回206的续传回应，不一致时服务端则返回200回应，回应的内容为新的文件的全部数据。

## 简单实现

PHP语言实现 
```php
$file = '/tmp/a.txt';
if (!file_exists($file)) {
    exit("file not exist!");
}
$filesize = filesize($file);
$filename = basename($file);
header('Last-Modified: '.gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');
header('Content-Encoding: none');
header('Content-Disposition: attachment; filename='.$filename);
header('Content-Type: application/octet-stream');
header('Content-Length: '.$filesize);
header('Accept-Ranges: bytes');
$range = 0;
if(!empty($_SERVER['HTTP_RANGE'])) {
	list($range) = explode('-',(str_replace('bytes=', '', $_SERVER['HTTP_RANGE'])));
    $rangesize = ($filesize - $range) > 0 ?  ($filesize - $range) : 0;
    header('Content-Length: '.$rangesize);
    if ($rangesize <= 0) {
    	header('HTTP/1.1 416 Requested Range Not Satisfiable');
    	exit;
	}
    header('HTTP/1.1 206 Partial Content');
    header('Content-Range: bytes='.$range.'-'.($filesize-1).'/'.($filesize));
}
if($fp = fopen($file, 'rb')) {
    fseek($fp, $range);
    if(function_exists('fpassthru')) {
        fpassthru($fp);
    } else {
        echo fread($fp, filesize($filename));
    }

    while (ob_get_level() > 0) {
        ob_end_flush();
    }
    flush();
}
```


## 参考资源
[Node.js 中实现 HTTP 206 内容分片](https://www.oschina.net/translate/http-partial-content-in-node-js?lang=chs&page=1#)
[HTTP协议--断点续传](http://blog.csdn.net/xifeijian/article/details/8712439)





