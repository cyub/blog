title: Architecting on AWS笔记
author: tinker
tags: []
categories: []
date: 2020-02-20 09:46:00
---
春节期间，公司组织远程培训，请Aws讲师培训`Architecting on aws`，属于aws架构培训中级课程。以下内容是个人做的笔记。

## Aws简介

### 什么是云，什么是AWS

- 可编程资源
	- IAC(基础设施作为代码)
    - PAY as you go
- 动态能力
- 按使用量付费

<!--more-->

#### 云优势

- 将资本支出变成可变支出
- 规模效益
- 停止猜测容量
- 提高速度和敏捷性
- 专注于重要工作
- 数分钟内实现全球化部署


### WAF

AWS Well Architected简称架构完善的框架

架构完善的框架设计原则的目标：

- 安全性
	
	安全性涉及保护信息并减少可能的损坏。采取一些基本的安全措施,您的架构 就会处于更好的安全状态。这些措施包括采用强大的身份机制、实现可追踪性、 在所有层确保安全性、自动应用安全性最佳实践以及保护传输中的数据和静态 数据

- 可靠性

	在传统环境中确保可靠性可能会很困难。单点故障、缺乏自动化和缺乏弹性都 会引起问题。应用可靠性支柱的理念,您就能够避免许多此类问题。在高可用 性、容错能力和整体冗余方面正确设计架构对您和您的客户都会有所帮助。
    
- 成本优化

	成本优化是所有良好架构设计的长期要求。这一过程重复进行,应该在您的整 个生产生命周期内完善和改进。了解当前的架构相对于目标的效率,最终可以 帮助您消除不必要的费用。考虑使用托管服务,因为其以云的规模运行,并且 可以实现更低的事务处理成本或服务成本
- 性能效率
	
    在创建设计或架构时,您必须了解其如何部署、更新和运作。您必须致力于缺 陷消除和安全修复工作,并通过日志记录工具进行观察。
	在AWS 中,您可以将整个工作负载(应用程序、基础设施、策略、管理和操作) 视为代码。工作负载可以在代码中定义,并使用代码来更新。这意味着您可以 将用于应用程序代码的设计规范应用到堆栈中的每个元素。


- 卓越运维

	在考虑性能时,您需要有效使用计算资源并在需求变化时保持资源效率,从而 尽可能提高性能。

	普及先进技术也同样重要。在自己难以实施技术的情况下,请考虑使用供应商。 在为您的实施技术时,供应商可以处理复杂问题并投入知识,让您的团队专注 于附加价值更高的工作。
	了解技术:使用最符合您的目标的技术。例如,在选择数据库或存储方法时考 虑数据访问模式。
   
 


## Region 区域

![](https://static.cyub.vip/images/202010/aws_is.jpg)

一共分3个管理区域：

- 美国政府
- 中国
- global

某些服务（比如EKS)需要Region里面2个或3个AZ，也就是需要部署2个3个可用区里面。
    
## 边缘站点

性能:
- Cloudfront(CDN)
- R53(DNS)

安全性
- shield(DDOS)
- WAF

## S3

s3是全球性的，不需要选择区域。每个桶需要放在确定一个区域。

对象是最小存储单位，不能更新，只能完全覆盖。创建对象默认是私有不公开的。若要公开需要确保桶公开，然后设置对象公开。s3具有以下两个特性：


- 持久性- 11个9（决定数据丢失可能）

- 可用性 4个9 （数据可用 访问性)


**s3适用性**
- 适合非结构化数据（图片，日志，视频等)
- 适合WORM(Write Once Read Many), 一次写入多次读取

**s3限制**

- 最大文件不能超过5TB
- 一个账户最多100个buckets

**s3访问控制**

桶- bucket:
- public
- acl
- polices(策略)
- cors
    
存储对象-object:
- acl
  
 bucket可以使用police可以防止盗链


**s3版本**

多版本管理：收费有多少个版本就收取多少个版本费用

**s3访问**

默认是backbone network

**s3上云和下云**

snowball 只适用于本地云传到s3。或者s3下载到本地数据中心。不支持跨区域s3到s3(北京region => snowball => 宁夏region）

**s3收费方式：**

- storage
- out of region
- API

**s3 Glacier**

用于复制S3到多个可用区和每个可用区中的多个设备

**s3复制**

![](http://static.cyub.vip/images/202010/s3_copy.jpg)



## EC2

配置EC2流程:

1. 选择Region
2. AMI - Amazon Machine Image
    - x86/arm
    - 32/64位
    - pv/HVM 虚拟化技术
    - OS类型（不同os类型存在不同计费方式）
3. Instance type (示例类型）
4. Configure (网络配置等）


### instance类型

隐藏选择选项:

- ECU
    
EC2 stop之后，会释放cpu,memory,network资源（ip)。硬盘资源还存在。

#### t系列实例

cpu在负载20%以下会积攒积分，当cpu负载高时候消耗积分。1积分 = 1* 100%cpu负载 1分钟

EBS = Elastic block storage

#### nitro colud

能够实现虚拟机99.9%性能，去掉了虚拟机消耗功能

#### 使用Auto Scaling提供EC2的弹性

![](https://static.cyub.vip/images/202010/ec2_auto_scale.jpg)



## 数据库

### RDS需要关注点

1. DB Instance
2. HA
3. Backup
	1. 自动备份
    2. 快照
4. Patching（升级，打补丁)
5. RR(read-only repeat) 读副本
	1. RR创建在另外一个Region时候需注意IO传输费用
6. Mysql最大支持64TB



## VPC

**CIDR(无类别域间路由)**

0.0.0.0/0 即 所有IP,也称inernet

10.22.33.44/32 即 10.22.33.44主机IP


**vpc注意点**

- VPC 千万不要有IP overlap状况出现，不然vpc間的路由會出問題。(overlap指的是CIDR重合)

- 一个子网不能cross az(跨可用区)

- aws 将保留每个子网的5个IP地址。
	- 去掉0（比如10.1.10.0这个ID地址)
	- .255是广播地址
	- .1 (加)DHCP, Gateway
	- .2 DNS relay(dns中继)
	- .3 reserve(保留ip地址）

- 每个子网都必须要有个路由表。每个VPC有一个主(默认)路由表，但强烈不建议子网使用此路由表（出于安全考虑)。而应该针对每个子网使用自定义路由表。

- 主路由表不能包含除默认路由表任何其他路由。

- 同一个vpc里面的子网是可以路由可通的。

- 绝大部分aws服务不是在你建立的vpc的（比如s3)，vpc用于ec2和rds等

### 安全组 - Security Group

![](https://static.cyub.vip/images/202010/security_group.png)



## EIP

EIP 即 Elasitc IP, 弹性IP

收费策略：

- 使用时候不收费，未使用却收费
- 多个公有IP接口，除了第一个不收费，其他收费


## 负载均衡

负载均衡三剑客

- clb
	- 检查 ping
    - x-Forward-For 获取客户端ip
    - 只支持上游EC2
    - SSL-Offload
    
- alb
 
   - 自定义目标组（类型nginx location功能）
   - 支持ec2/docker,k8s
    
- nlb
 
 - 性能更强劲，百万级别
 
![](https://static.cyub.vip/images/202010/load-balancing.png)
 
    
## cloudwatch

CloudWatch是监控服务中的一项，是弹性三剑客的一员。之后还会介绍监控类服务中的另两个服务CloudTrail和VPC flow log

弹性三剑客是 ElasticLoadBalancer， CloudWatch和Auto Scaling。

IaC = 基础设施即代码

## 基于API Gateway实现无服务架构


**常见无服务架构**


![](https://static.cyub.vip/images/202010/serverless_arch.jpg)

**无服务移动后端架构**

![](https://static.cyub.vip/images/202010/serverless_backend.jpg)




## 大规模网络架构图

![](https://static.cyub.vip/images/202010/large_scale_architecting.jpg)

## 结业证书

培训完成之后，还需要花费3天亲自完成4个实验，全部完成之后会发一下线上结业证书：

![](https://static.cyub.vip/images/202010/aws_architecting.jpg)


## 链接

[aws基础设施](https://infrastructure.aws/)