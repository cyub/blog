title: 《Nginx Cookbook 2019》中文版第二章高性能负载均衡
author: tinker
tags:
  - Nginx
  - 翻译
categories: []
date: 2019-09-07 23:11:00
---
## 2.0 Introduction-简介

Today’s internet user experience demands performance and uptime. To achieve this, multiple copies of the same system are run, and the load is distributed over them. As the load increases, another copy of the system can be brought online. This architecture technique is called horizontal scaling. Software-based infrastructure is increasing in popularity because of its flexibility, opening up a vast world of possibilities. Whether the use case is as small as a set of two for high availability or as large as thousands around the globe, there’s a need for a load-balancing solution that is as dynamic as the infrastructure. NGINX fills this need in a number of ways, such as HTTP, TCP, and UDP load balancing, which we cover in this chapter.

当今的互联网用户体验要求性能和时时在线。为了达到这个目的，同一个系统的多个副本需同时运行，并且将负载分布在这些副本上。随着负载的增加，系统的另一个副本可以联机。这种架构技术被称为水平拓展。基于软件的基础设施因其灵活性而越来越受欢迎，开辟了一个广阔的无限可能的世界。对于高可用性而言，用例小到两个，还是在全球范围内成千上万个，都需要一个与基础架构一样动态的负载均衡解决方案。NGINX以多种方式满足这一需求，我们在本章中将讨论超文本传输协议(HTTP)、TCP和UDP的负载平衡。

<!--more-->

When balancing load, it’s important that the impact to the client is only a positive one. Many modern web architectures employ stateless application tiers, storing state in shared memory or databases. However, this is not the reality for all. Session state is immensely valuable and vast in interactive applications. This state might be stored locally to the application server for a number of reasons; for example, in applications for which the data being worked is so large that network overhead is too expensive in performance. When state is stored locally to an application server, it is extremely important to the user experience that the subsequent requests continue to be delivered to the same server. Another facet of the situation is that servers should not be released until the session has finished. Working with stateful applications at scale requires an intelligent load balancer. NGINX Plus offers multiple ways to solve this problem by tracking cookies or routing. This chapter covers session persistence as it pertains to load balancing with NGINX and NGINX Plus.

当负载均衡时，对客户端的压力必须是积极的一面，这是至关重要的。许多现代web架构采用无状态应用层，将状态存储在共享内存或数据库中。然后并不是所有按照如此实现的。会话状态对交互型应用具有非常广泛价值。因为一些原因，会话状态存储在应用所在的服务器。比如例如，在数据处理量很大的应用中，网络开销在性能上过于昂贵。当状态存储在应用服务器本地时，后续请求继续传递到同一服务器对用户体验来说极其重要。这种情况的另一个方面是在会话完成之前不应该释放服务器。工作在大规模有状态应用程序时需要智能负载均衡器。NGINX Plus提供了通过跟踪cookies或路由来解决这个问题的多种方式。本章包含会话持久化，因为它与NGINX和NGINX Plus负载均衡有关

Ensuring that the application NGINX is serving is healthy is also important. For a number of reasons, applications fail. It could be because of network connectivity, server failure, or application failure, to name a few. Proxies and load balancers must be smart enough to detect failure of upstream servers and stop passing traffic to them; otherwise, the client will be waiting, only to be delivered a timeout. A way to mitigate service degradation when a server fails is to have the proxy check the health of the upstream servers. NGINX offers two different types of health checks: passive, available in the open source version; and active, available only in NGINX Plus. Active health checks at regular intervals will make a connection or request to the upstream server and can verify that the response is correct. Passive health checks monitor the connection or responses of the upstream server as clients make the request or connection. You might want to use passive health checks to reduce the load of your upstream servers, and you might want to use active health checks to determine failure of an upstream server before a client is served a failure. The tail end of this chapter examines monitoring the health of the upstream application servers for which you’re load balancing.

确保NGINX程序健康运行也是很重要的。由于多种原因，NGINX程序运行会失败，可能原因比如网络连接，服务器故障，应用程序故障。代理和负载均衡器必须足够聪明，能够检测上游服务器的故障，并停止向它们传输流量；否则客户端将只有等待超时了。A way to mitigate service degradation when a server fails is to have the proxy check the health of the upstream servers。NGINX提供两种不同类型的健康检查：被动模式在开源版NGINX可用，主动模式仅可以在NGINX Plus版本可以用。主动健康检查以固定周期的连接或者请求上游服务器，并验证响应是否正确。被动模式健康检查监控客户端发出的请求或连接时候，上游的响应。你可能希望使用被动模式检查来减少上游服务器的负载，也可能希望在客户端出现故障之前使用主动模式健康检查来确定上游服务器的故障。本章的结尾检查了监控你正在为其进行负载平衡的上游应用服务器的运行状况。

## 2.1 HTTP Load Balancing-HTTP负载均衡

### Problem-问题

You need to distribute load between two or more HTTP servers.

你需要分布式负载均衡在两个或者多个HTTP服务之间

### Solution-解决方案

Use NGINX’s HTTP module to load balance over HTTP servers using the upstream block:

使用HTTP模块中upstream块指令来在HTTP服务上负载均衡

 	upstream backend {
        server 10.10.12.45:80      weight=1;
        server app.example.com:80  weight=2;
	}
	server {
    	location / {
            proxy_pass http://backend;
		} 
    }
    
This configuration balances load across two HTTP servers on port 80. The weight parameter instructs NGINX to pass twice as many connections to the second server, and the weight parameter defaults to 1.

上面配置负载在两个80端口的HTTP服务。`weight`参数指示NGINX分发两倍的连接给第二个服务器（相比于第一个服务器)，`weight`参数值默认是1

### Discussion-讨论

The HTTP upstream module controls the load balancing for HTTP. This module defines a pool of destinations—any combination of Unix sockets, IP addresses, and DNS records, or a mix. The upstream module also defines how any individual request is assigned to any of the upstream servers.

HTTP upstream模块控制HTTP的负载均衡。这个模块定义了一个任意Unix sockets,IP地址，DNS记录组合的地址池，也定义了定义了如何将任何单个请求分配给任意上游服务器。

Each upstream destination is defined in the upstream pool by the server directive. The server directive is provided a Unix socket, IP address, or an FQDN, along with a number of optional parameters. The optional parameters give more control over the routing of requests. These parameters include the weight of the server in the balancing algorithm; whether the server is in standby mode, available, or unavailable; and how to determine if the server is unavailable. NGINX Plus provides a number of other convenient parameters like connection limits to the server, advanced DNS resolution control, and the ability to slowly ramp up connections to a server after it starts.

server指令在上游地址池(upstream pool)中定义每一个上游服务的地址。需要给server指令提供Unix socket，IP地址，或者FQDN和一些选项参数。可选参数提供了对请求路由的更多控制， 可选参数包含负载均衡的权重参数，上游服务是否是standby模式，可用或不可用状态，以及证明判断服务是否可用。Nginx Plus版额外提供了很多方便的参数，如限制服务器连接数、高级域名解析控制、当上游服务重启时候，缓存提升连接数


## 2.2 TCP Load Balancing-HTTP负载均衡

### Problem-问题
You need to distribute load between two or more TCP servers.

你需要分布式负载在两个或多个TCP服务之间

### Solution-解决方案
Use NGINX’s stream module to load balance over TCP servers using the upstream block:

在NGINX的stream模块中使用upstream指令进行TCP服务负载均衡

	stream {
        upstream mysql_read {
            server read1.example.com:3306  weight=5;
            server read2.example.com:3306;
        	server 10.10.12.34:3306 backup;
    	}
    	server {
        	listen 3306;
        	proxy_pass mysql_read;
    	}
	}
    
The server block in this example instructs NGINX to listen on TCP port 3306 and balance load between two MySQL database read replicas, and lists another as a backup that will be passed traffic if the primaries are down. This configuration is not to be added to the conf.d folder as that folder is included within an http block; instead, you should create another folder named stream.conf.d, open the stream block in the nginx.conf file, and include the new folder for stream configurations.

上面例子中server块级指令控制NGINX监听TCP 3306端口，并且在两个MYSQL读副本实例之间进行负载均衡，此外还设置了一个备份服务，当主服务不可用时候启用。stream模块的配置不能放在`conf.d`目录，因为此目录下配置是在http块指令之下的。相反，你应该创建目录`stream.conf.d`后，接着在nginx.conf文件添加stream块指令，并引入此目录下的文件



### Discussion-讨论

TCP load balancing is defined by the NGINX stream module. The stream module, like the HTTP module, allows you to define upstream pools of servers and configure a listening server. When configuring a server to listen on a given port, you must define the port it’s to listen on, or optionally, an address and a port. From there, a destination must be configured, whether it be a direct reverse proxy to another address or an upstream pool of resources.

NGINX stream模块定义了TCP负载均衡。就像HTTP模块一样，stream模块允许定义上游服务器池和配置监听的服务器。当配置一个服务器监听一个给定的端口时候，你必须明确指定哪个端口或者地址需要监听。此外不论负载均衡目的地址是直接反向代理过去，还是上游服务器池也必须配置

The upstream for TCP load balancing is much like the upstream for HTTP, in that it defines upstream resources as servers, configured with Unix socket, IP, or fully qualified domain name (FQDN), as well as server weight, max number of connections, DNS resolvers, and connection ramp-up periods; and if the server is active, down, or in backup mode.

TCP负载均衡的上游(upstream)很想Http负载均衡上游(upstream)。因为他们都将上游资源定义成服务，这些服务配置Unix socket 或者完全域名(FQDN)，也设置服务权重，连接数量，DNS解析器，以及ramp-up周期，以及服务是否活动，关闭还是备份状态


NGINX Plus offers even more features for TCP load balancing. These advanced features offered in NGINX Plus can be found throughout this book. Health checks for all load balancing will be covered later in this chapter.

NGINX Plus版本支持TCP负载均衡更多特性。在这本书里，我们可以找到NGINX Plus提供的这些高级特性。本章后面将介绍所有负载平衡的运行状况检查。

## 2.3 UDP Load Balancing-UDP负载均衡

### Problem-问题

You need to distribute load between two or more UDP servers.

你需要在两个或多个UDP服务器之间进行分布式负载。


### Solution-解决方案
Use NGINX’s stream module to load balance over UDP servers using the upstream block defined as udp:

在NGINX的stream模块使用upstream块指令进行UDP服务负载均衡

    stream {
        upstream ntp {
            server ntp1.example.com:123  weight=2;
            server ntp2.example.com:123;
        }
        server {
            listen 123 udp;
            proxy_pass ntp;
        }
	}

This section of configuration balances load between two upstream Network Time Protocol (NTP) servers using the UDP protocol. Specifying UDP load balancing is as simple as using the udp parameter on the listen directive.

上面的配置目的是两个基于UDP协议的网络时间协议(NTP)服务器做为上游进行负载均衡。指定UDP负载均衡简单到在listen指令中使用udp参数即可。

If the service you’re load balancing over requires multiple packets to be sent back and forth between client and server, you can specify the reuseport parameter. Examples of these types of services are OpenVPN, Voice over Internet Protocol (VoIP), virtual desktop solutions, and Datagram Transport Layer Security (DTLS). The follow‐ ing is an example of using NGINX to handle OpenVPN connections and proxy them to the OpenVPN service running locally:

如果你正在进行负载平衡的服务需要在客户端和服务器之间来回发送多个数据包，你可以指定reuseport参数。这类服务的例子有开放虚拟专用网(OpenVPN)、互联网协议语音(VoIP)、虚拟桌面解决方案和数据报传输层安全性(DTLS)。下面是一个使用NGINX处理OpenVPN连接并将它们代理到本地运行的OpenVPN服务的例子:

    stream {
            server {
                listen 1195 udp reuseport;
                proxy_pass 127.0.0.1:1194;
            }
    }
    
### Discussion-讨论

You might ask, “Why do I need a load balancer when I can have multiple hosts in a DNS A or SRV record?” The answer is that not only are there alternative balancing algorithms with which we can balance, but we can load balance over the DNS servers themselves. UDP services make up a lot of the services that we depend on in networked systems, such as DNS, NTP, and VoIP. UDP load balancing might be less common to some but just as useful in the world of scale.

你可能会问，“当一个DNS A记录或SRV记录可以有多个主机时候，为什么我还需要负载均衡器？”。答案是负载均衡器不光提供多种负载均衡算法，还可以给域名服务器提供负载均衡。UDP服务提供了网络系统所依赖的许多服务，比如DNS,NTP，和VoIP。UDP负载均衡对某些人来说可能并不常见，但在真实世界中广泛存在。


You can find UDP load balancing in the stream module, just like TCP, and configure it mostly in the same way. The main difference is that the listen directive specifies that the open socket is for working with datagrams. When working with datagrams, there are some other directives that might apply where they would not in TCP, such as the proxy_response directive, which specifies to NGINX how many expected responses can be sent from the upstream server. By default, this is unlimited until the proxy_time out limit is reached.

你可以在stream模块中找到UDP负载平衡，就像TCP一样，并且大多数情况下两者的配置是相同的。主要区别在于listen指令需额外指定UDP参数。当处理数据报时，有些指令可能会在TCP中并不适用，例如proxy_response指令，该指令指定NGINX从上游服务器获取预期响应。默认情况下，这是无限制的，直到达到代理超时限制。


The reuseport parameter instructs NGINX to create an individual listening socket for each worker process. This allows the kernel to distibute incoming connections between worker processes to handle multiple packets being sent between client and server. The reuse port feature works only on Linux kernels 3.9 and higher, DragonFly BSD, and FreeBSD 12 and higher.

reuseport参数指示NGINX为每个工作进程创建一个单独的监听套接字。这允许内核在工作进程之间分配传入连接以处理客户端和服务器之间发送的多个数据包。重用端口功能仅适用于Linux内核3.9及更高版本、DragonFly BSD和FreeBSD 12及更高版本。



## 2.4 Load-Balancing Methods-负载均衡方法

### Problem
Round-robin load balancing doesn’t fit your use case because you have heterogeneous workloads or server pools.

Round-robin负载均衡不一定满足你的需要，比如你可能使用异构的工作负载或服务地址池

### Solution
Use one of NGINX’s load-balancing methods such as least connections, least time, generic hash, IP hash, or random:

使用最少连接数，最少响应时间，通用哈希，IP哈希或者随机的NGINX负载均衡方法

	upstream backend {
        least_conn;
        server backend.example.com;
        server backend1.example.com;
    }
    
    
This example sets the load-balancing algorithm for the backend upstream pool to be least connections. All load-balancing algorithms, with the exception of generic hash, random, and least-time, are standalone directives, such as the preceding example. The parameters to these directives are explained in the following discussion.

上面示例是将后端上游池的负载平衡算法设置为最少连接。正如上面的示例中，除了hash、随机和最短连接时间外，所有负载平衡算法都是独立的指令。下面的讨论将解释这些指令的参数。

### Discussion-讨论

Not all requests or packets carry equal weight. Given this, round robin, or even the weighted round robin used in previous examples, will not fit the need of all applications or traffic flow. NGINX pro‐ vides a number of load-balancing algorithms that you can use to fit particular use cases. In addition to being able to choose these load- balancing algorithms or methods, you can also configure them. The following load-balancing methods are available for upstream HTTP, TCP, and UDP pools.

- Round robin
 
 This is the default load-balancing method, which distributes requests in the order of the list of servers in the upstream pool. You can also take weight into consideration for a weighted round robin, which you can use if the capacity of the upstream servers varies. The higher the integer value for the weight, the more favored the server will be in the round robin. The algo‐ rithm behind weight is simply statistical probability of a weigh‐ ted average.

- Least connections

 This method balances load by proxying the current request to the upstream server with the least number of open connections. Least connections, like round robin, also takes weights into account when deciding to which server to send the connection. The directive name is least_conn.

- Least time
 
 Available only in NGINX Plus, least time is akin to least con‐ nections in that it proxies to the upstream server with the least number of current connections but favors the servers with the lowest average response times. This method is one of the most sophisticated load-balancing algorithms and fits the needs of highly performant web applications. This algorithm is a value- add over least connections because a small number of connec‐ tions does not necessarily mean the quickest response. A parameter of header or last_byte must be specified for this directive. When header is specified, the time to receive the response header is used. When last_byte is specified, the time to receive the full response is used. The directive name is least_time.
 
- Generic hash
 
 The administrator defines a hash with the given text, variables of the request or runtime, or both. NGINX distributes the load among the servers by producing a hash for the current request and placing it against the upstream servers. This method is very useful when you need more control over where requests are sent or for determining which upstream server most likely will have the data cached. Note that when a server is added or removed from the pool, the hashed requests will be redistributed. This algorithm has an optional parameter, consistent, to minimize the effect of redistribution. The directive name is hash.

- Random

 This method is used to instruct NGINX to select a random server from the group, taking server weights into consideration. The optional two [method] parameter directs NGINX to ran‐ domly select two servers and then use the provided load- balancing method to balance between those two. By default the least_conn method is used if two is passed without a method. The directive name for random load balancing is random.

- IP hash

 This method works only for HTTP. IP hash uses the client IP address as the hash. Slightly different from using the remote variable in a generic hash, this algorithm uses the first three octets of an IPv4 address or the entire IPv6 address. This method ensures that clients are proxied to the same upstream server as long as that server is available, which is extremely helpful when the session state is of concern and not handled by shared memory of the application. This method also takes the weight parameter into consideration when distributing the hash. The directive name is ip_hash.


## 2.5 Sticky Cookie 

### Problem
You need to bind a downstream client to an upstream server using NGINX Plus.

### Solution
Use the sticky cookie directive to instruct NGINX Plus to create and track a cookie:

    upstream backend {
        server backend1.example.com;
        server backend2.example.com;
        sticky cookie
               affinity
               expires=1h
               domain=.example.com
               httponly
               secure
               path=/;
	}

This configuration creates and tracks a cookie that ties a down‐ stream client to an upstream server. In this example, the cookie is named affinity, is set for example.com, expires in an hour, cannot be consumed client-side, can be sent only over HTTPS, and is valid for all paths.

### Discussion
Using the cookie parameter on the sticky directive creates a cookie on the first request that contains information about the upstream server. NGINX Plus tracks this cookie, enabling it to continue directing subsequent requests to the same server. The first positional parameter to the cookie parameter is the name of the cookie to be created and tracked. Other parameters offer additional control informing the browser of the appropriate usage, like the expiry time, domain, path, and whether the cookie can be consumed client side or whether it can be passed over unsecure protocols.

## 2.6 Sticky Learn

### Problem
You need to bind a downstream client to an upstream server by using an existing cookie with NGINX Plus.

### Solution
Use the sticky learn directive to discover and track cookies that are created by the upstream application:

    upstream backend {
       server backend1.example.com:8080;
       server backend2.example.com:8081;
       sticky learn
              create=$upstream_cookie_cookiename
              lookup=$cookie_cookiename
              zone=client_sessions:2m;
	}
This example instructs NGINX to look for and track sessions by looking for a cookie named COOKIENAME in response headers, and looking up existing sessions by looking for the same cookie on request headers. This session affinity is stored in a shared memory zone of 2 MB that can track approximately 16,000 sessions. The name of the cookie will always be application specific. Commonly used cookie names, such as jsessionid or phpsessionid, are typi‐ cally defaults set within the application or the application server configuration.


### Discussion

When applications create their own session-state cookies, NGINX Plus can discover them in request responses and track them. This type of cookie tracking is performed when the sticky directive is provided the learn parameter. Shared memory for tracking cookies is specified with the zone parameter, with a name and size. NGINX Plus is directed to look for cookies in the response from the upstream server via specification of the create parameter, and searches for prior registered server affinity using the lookup parameter. The value of these parameters are variables exposed by the HTTP module.


## 2.7 Sticky Routing 

### Problem
You need granular control over how your persistent sessions are routed to the upstream server with NGINX Plus.


### Solution

Use the sticky directive with the route parameter to use variables about the request to route:

    map $cookie_jsessionid $route_cookie {
        ~.+\.(?P<route>\w+)$ $route;
	}
    map $request_uri $route_uri {
        ~jsessionid=.+\.(?P<route>\w+)$ $route;
	}
    upstream backend {
        server backend1.example.com route=a;
        server backend2.example.com route=b;
        sticky route $route_cookie $route_uri;
    }
    
 
This example attempts to extract a Java session ID, first from a cookie by mapping the value of the Java session ID cookie to a vari‐ able with the first map block, and second by looking into the request URI for a parameter called jsessionid, mapping the value to a vari‐ able using the second map block. The sticky directive with the route parameter is passed any number of variables. The first non‐ zero or nonempty value is used for the route. If a jsessionid cookie is used, the request is routed to backend1; if a URI parameter is used, the request is routed to backend2. Although this example is based on the Java common session ID, the same applies for other session technology like phpsessionid, or any guaranteed unique identifier your application generates for the session ID.

### Discussion

Sometimes, you might want to direct traffic to a particular server with a bit more granular control. The route parameter to the sticky directive is built to achieve this goal. Sticky route gives you better control, actual tracking, and stickiness, as opposed to the generic hash load-balancing algorithm. The client is first routed to an upstream server based on the route specified, and then subse‐ quent requests will carry the routing information in a cookie or the URI. Sticky route takes a number of positional parameters that are evaluated. The first nonempty variable is used to route to a server. Map blocks can be used to selectively parse variables and save them as other variables to be used in the routing. Essentially, the sticky route directive creates a session within the NGINX Plus shared memory zone for tracking any client session identifier you specify to the upstream server, consistently delivering requests with this ses‐ sion identifier to the same upstream server as its original request.


## 2.8 Connection Draining 

### Problem
You need to gracefully remove servers for maintenance or other rea‐ sons while still serving sessions with NGINX Plus.
Solution
Use the drain parameter through the NGINX Plus API, described in more detail in Chapter 5, to instruct NGINX to stop sending new connections that are not already tracked:

    $ curl -X POST -d '{"drain":true}' \
      'http://nginx.local/api/3/http/upstreams/backend/servers/0'
    { "id":0,
    "server":"172.17.0.3:80", "weight":1, "max_conns":0, "max_fails":1, "fail_timeout": "10s","slow_start": "0s",
    "route":"",
 	"backup":false, "down":false, "drain":true
    }

### Discussion

When session state is stored locally to a server, connections and per‐ sistent sessions must be drained before it’s removed from the pool. Draining connections is the process of letting sessions to a server expire natively before removing the server from the upstream pool. You can configure draining for a particular server by adding the drain parameter to the server directive. When the drain parameter is set, NGINX Plus stops sending new sessions to this server but allows current sessions to continue being served for the length of their session. You can also toggle this configuration by adding the drain parameter to an upstream server directive.

## 2.9 Passive Health Checks 

### Problem
You need to passively check the health of upstream servers.

### Solution
Use NGINX health checks with load balancing to ensure that only healthy upstream servers are utilized:

    upstream backend {
        server backend1.example.com:1234 max_fails=3 fail_timeout=3s;
        server backend2.example.com:1234 max_fails=3 fail_timeout=3s;
 	}
    
This configuration passively monitors the upstream health, setting the max_fails directive to three, and fail_timeout to three sec‐ onds. These directive parameters work the same way in both stream and HTTP servers.


### Discussion
Passive health checking is available in the Open Source version of NGINX. Passive monitoring watches for failed or timed-out connec‐ tions as they pass through NGINX as requested by a client. Passive health checks are enabled by default; the parameters mentioned here allow you to tweak their behavior. Monitoring for health is impor‐ tant on all types of load balancing, not only from a user experience standpoint, but also for business continuity. NGINX passively moni‐ tors upstream HTTP, TCP, and UDP servers to ensure that they’re healthy and performing.


## 2.10 Active Health Checks Problem
You need to actively check your upstream servers for health with NGINX Plus.

### Solution
For HTTP, use the health_check directive in a location block:

    http {
        server {
            ...
            location / {
                proxy_pass http://backend;
                health_check interval=2s
                    fails=2
                    passes=5
                    uri=/
                    match=welcome;
	} }
        # status is 200, content type is "text/html",
        # and body contains "Welcome to nginx!"
        match welcome {
            status 200;
            header Content-Type = text/html;
            body ~ "Welcome to nginx!";
	} }

This health check configuration for HTTP servers checks the health of the upstream servers by making an HTTP request to the URI '/' every two seconds. The upstream servers must pass five consecutive health checks to be considered healthy. They are considered unheal‐ thy if they fail two consecutive checks. The response from the upstream server must match the defined match block, which defines the status code as 200, the header Content-Type value as 'text/html', and the string "Welcome to nginx!" in the response body. The HTTP match block has three directives: status, header, and body. All three of these directives have comparison flags, as well.
Stream health checks for TCP/UDP services are very similar:

    stream { ...
            server {
                listen 1234;
                proxy_pass stream_backend;
                health_check interval=10s
    passes=2 fails=3;
                health_check_timeout 5s;
    		}
    		... 
    }
In this example, a TCP server is configured to listen on port 1234, and to proxy to an upstream set of servers, for which it actively checks for health. The stream health_check directive takes all the same parameters as in HTTP with the exception of uri, and the stream version has a parameter to switch the check protocol to udp. In this example, the interval is set to 10 seconds, requires two passes to be considered healthy, and three fails to be considered unhealthy. The active-stream health check is also able to verify the response from the upstream server. The match block for stream servers, how‐ ever, has just two directives: send and expect. The send directive is raw data to be sent, and expect is an exact response or a regular expression to match.

### Discussion

Active health checks in NGINX Plus continually make requests to the source servers to check their health. These health checks can measure more than just the response code. In NGINX Plus, active HTTP health checks monitor based on a number of acceptance cri‐ teria of the response from the upstream server. You can configure active health-check monitoring for how often upstream servers are checked, how many times a server must pass this check to be con‐ sidered healthy, how many times it can fail before being deemed unhealthy, and what the expected result should be. The match parameter points to a match block that defines the acceptance crite‐ ria for the response. The match block also defines the data to send to the upstream server when used in the stream context for TCP/UPD. These features enable NGINX to ensure that upstream servers are healthy at all times.

## 2.11 Slow Start 

### Problem
Your application needs to ramp up before taking on full production load.

### Solution
Use the slow_start parameter on the server directive to gradually increase the number of connections over a specified time as a server is reintroduced to the upstream load-balancing pool:

    upstream {
        zone backend 64k;
        server server1.example.com slow_start=20s;
        server server2.example.com slow_start=15s;
    }
    
The server directive configurations will slowly ramp up traffic to the upstream servers after they’re reintroduced to the pool. server1 will slowly ramp up its number of connections over 20 seconds, and server2 over 15 seconds.

### Discussion
Slow start is the concept of slowly ramping up the number of requests proxied to a server over a period of time. Slow start allows the application to warm up by populating caches, initiating database connections without being overwhelmed by connections as soon as it starts. This feature takes effect when a server that has failed health checks begins to pass again and re-enters the load-balancing pool.

## 2.12 TCP Health Checks 

### Problem
You need to check your upstream TCP server for health and remove unhealthy servers from the pool.

### Solution
Use the health_check directive in the server block for an active health check:

    stream {
        server {
            listen       3306;
            proxy_pass   read_backend;
            health_check interval=10 passes=2 fails=3;
	} }
The example monitors the upstream servers actively. The upstream server will be considered unhealthy if it fails to respond to three or more TCP connections initiated by NGINX. NGINX performs the check every 10 seconds. The server will only be considered healthy after passing two health checks.

### Discussion

TCP health can be verified by NGINX Plus either passively or actively. Passive health monitoring is done by noting the communi‐ cation between the client and the upstream server. If the upstream server is timing out or rejecting connections, a passive health check will deem that server unhealthy. Active health checks will initiate their own configurable checks to determine health. Active health checks not only test a connection to the upstream server, but can expect a given response.