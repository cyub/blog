---
title: 如何正确选择一个HTTP状态码
date: 2017-09-02 00:12:25
tags:
    - HTTP状态码
    - RESTful 

---

HTTP状态码(HTTP Status Code)是3位数字代码，用来表示服务器HTTP响应状态，它由`RFC2616` 规范定义的。所有状态码第一个数字代表其所属的状态分类。服务端返回响应数据时候，HTTP协议号和状态码作为`Response line`返回给客户端

在开发过程中，特别是基于`RESTful架构`，一个语义正确的HTTP状态码，显得十分有必要，它能够帮助客户端接受者能够从状态码快速甄别资源的状态。作为服务提供者，需要在客户端请求和服务的状态下选择一个正确的状态往往不是那么容易的事情。比如客户端访问一个受限的资源，返回401还是403就得细细考虑了。
<!-- more -->
近日看到一篇文章[Choosing an HTTP Status Code — Stop Making It Hard](http://racksburg.com/choosing-an-http-status-code/)，文章里面使用几张流程图来帮助选择一个正确的状态码，也正如文章的标题那样，借助几张图表确实能够将选择HTTP状态码这件事情 **Stop Marking It Hard**。现在把那几张图表摘录下来。

## 1XX
![start](http://static.cyub.vip/images//http_status_flowchart/start.png)

## 2XX_3XX
![2XX](http://static.cyub.vip/images//http_status_flowchart/2xx_3xx.png)

## 4XX
![4XX](http://static.cyub.vip/images//http_status_flowchart/4xx.png)

## 5XX
![5XX](http://static.cyub.vip/images//http_status_flowchart/5xx.png)

