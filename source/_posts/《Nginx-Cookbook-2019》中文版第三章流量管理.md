title: 《Nginx Cookbook 2019》中文版第三章流量管理
author: tinker
tags:
  - Nginx
categories: []
date: 2019-10-02 21:43:00
---
## 3.0 Introduction

NGINX and NGINX Plus are also classified as web traffic control‐ lers. You can use NGINX to intellengently route traffic and control flow based on many attributes. This chapter covers NGINX’s ability to split client requests based on percentages, utilize geographical location of the clients, and control the flow of traffic in the form of rate, connection, and bandwidth limiting. As you read through this chapter, keep in mind that you can mix and match these features to enable countless possibilities.

<!--more-->

## 3.1 A/B Testing

### Problem
You need to split clients between two or more versions of a file or application to test acceptance.

### Solution
Use the split_clients module to direct a percentage of your clients to a different upstream pool:

	split_clients "${remote_addr}AAA" $variant {
        20.0%    "backendv2";
        *        "backendv1";
	}
    
The split_clients directive hashes the string provided by you as the first parameter and divides that hash by the percentages pro‐ vided to map the value of a variable provided as the second parame‐ ter. The third parameter is an object containing key-value pairs where the key is the percentage weight and the value is the value to be assigned. The key can be either a percentage or an asterisk. The asterisk denotes the rest of the whole after all percentages are taken. The value of the $variant variable will be backendv2 for 20% of cli‐ ent IP addresses and backendv1 for the remaining 80%.

In this example, backendv1 and backendv2 represent upstream server pools and can be used with the proxy_pass directive as such:

    location / {
        proxy_pass http://$variant
	}
 
Using the variable $variant, our traffic will split between two different application server pools.

### Discussion

This type of A/B testing is useful when testing different types of marketing and frontend features for conversion rates on ecommerce sites. It’s common for applications to use a type of deployment called canary release. In this type of deployment, traffic is slowly switched over to the new version. Splitting your clients between different ver‐ sions of your application can be useful when rolling out new ver‐ sions of code, to limit the blast radius in case of an error. Whatever the reason for splitting clients between two different application sets, NGINX makes this simple through the use of this split_cli ents module.

### Also See

[split_client Documentation](http://bit.ly/2jsdkw4)

## 3.2 Using the GeoIP Module and Database 

### Problem
You need to install the GeoIP database and enable its embedded variables within NGINX to log and specify to your application the location of your clients.


### Solution
The official NGINX Open Source package repository, configured in Chapter 1 when installing NGINX, provides a package named nginx-module-geoip. When using the NGINX Plus package repository, this package is named nginx-plus-module- geoip. These packages install the dynamic version of the GeoIP module.

RHEL/CentOS NGINX Open Source:
    # yum install nginx-module-geoip
Debian/Ubuntu NGINX Open Source:
    # apt-get install nginx-module-geoip
RHEL/CentOS NGINX Plus:
    # yum install nginx-plus-module-geoip
Debian/Ubuntu NGINX Plus:
    # apt-get install nginx-plus-module-geoip
Download the GeoIP country and city databases and unzip them:
    # mkdir /etc/nginx/geoip
    # cd /etc/nginx/geoip
    # wget "http://geolite.maxmind.com/\
    download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
    # gunzip GeoIP.dat.gz
    # wget "http://geolite.maxmind.com/\
    download/geoip/database/GeoLiteCity.dat.gz"
    # gunzip GeoLiteCity.dat.gz

This set of commands creates a geoip directory in the /etc/nginx directory, moves to this new directory, and downloads and unzips the packages.

With the GeoIP database for countries and cities on the local disk, you can now instruct the NGINX GeoIP module to use them to expose embedded variables based on the client IP address:

    load_module "/usr/lib64/nginx/modules/ngx_http_geoip_module.so";
    http {
        geoip_country /etc/nginx/geoip/GeoIP.dat;
        geoip_city /etc/nginx/geoip/GeoLiteCity.dat;
	... }

The load_module directive dynamically loads the module from its path on the filesystem. The load_module directive is only valid in the main context. The geoip_country directive takes a path to the GeoIP.dat file containing the database mapping IP addresses to country codes and is valid only in the HTTP context.

### Discussion

The geoip_country and geoip_city directives expose a number of embedded variables available in this module. The geoip_country directive enables variables that allow you to distinguish the country of origin of your client. These variables include $geoip_coun try_code, $geoip_country_code3, and $geoip_country_name. The country code variable returns the two-letter country code, and the variable with a 3 at the end returns the three-letter country code. The country name variable returns the full name of the country.


The geoip_city directive enables quite a few variables. The geoip_city directive enables all the same variables as the geoip_country directive, just with different names, such as $geoip_city_country_code, $geoip_city_country_code3, and $geoip_city_country_name. Other variables include $geoip_city, $geoip_city_continent_code, $geoip_latitude, $geoip_longi tude, and $geoip_postal_code, all of which are descriptive of the value they return. $geoip_region and $geoip_region_name describe the region, territory, state, province, federal land, and the like. Region is the two-letter code, where region name is the full name. $geoip_area_code, only valid in the US, returns the three- digit telephone area code.


With these variables, you’re able to log information about your cli‐ ent. You could optionally pass this information to your application as a header or variable, or use NGINX to route your traffic in partic‐ ular ways.

### Also See

[GeoIP Update](https://github.com/maxmind/geoipupdate)

## 3.3 Restricting Access Based on Country 

### Problem
You need to restrict access from particular countries for contractual or application requirements.

### Solution
Map the country codes you want to block or allow to a variable:

    load_module
      "/usr/lib64/nginx/modules/ngx_http_geoip_module.so";
    http {
        map $geoip_country_code $country_access {
            "US"    0;
            "RU"    0;
            default 1;
  	}
  	... }
    
This mapping will set a new variable $country_access to a 1 or a 0. If the client IP address originates from the US or Russia, the variable will be set to a 0. For any other country, the variable will be set to a 1.

Now, within our server block, we’ll use an if statement to deny access to anyone not originating from the US or Russia:

    server {
            if ($country_access = '1') {
    return 403; }
    ... }
    

This if statement will evaluate True if the $country_access variable is set to 1. When True, the server will return a 403 unauthorized. Otherwise the server operates as normal. So this if block is only there to deny people who are not from the US or Russia.
Discussion
This is a short but simple example of how to only allow access from a couple of countries. This example can be expounded upon to fit your needs. You can utilize this same practice to allow or block based on any of the embedded variables made available from the GeoIP module.


## 3.4 Finding the Original Client 

### Problem
You need to find the original client IP address because there are proxies in front of the NGINX server.

### Solution
Use the geoip_proxy directive to define your proxy IP address range and the geoip_proxy_recursive directive to look for the original IP:

    load_module "/usr/lib64/nginx/modules/ngx_http_geoip_module.so";
    http {
        geoip_country /etc/nginx/geoip/GeoIP.dat;
        geoip_city /etc/nginx/geoip/GeoLiteCity.dat;
        geoip_proxy 10.0.16.0/26;
        geoip_proxy_recursive on;
	... }

The geoip_proxy directive defines a CIDR range in which our proxy servers live and instructs NGINX to utilize the X-Forwarded- For header to find the client IP address. The geoip_proxy_recursive directive instructs NGINX to recursively look through the X-Forwarded-For header for the last client IP known.

### Discussion

You may find that if you’re using a proxy in front of NGINX, NGINX will pick up the proxy’s IP address rather than the client’s. For this you can use the geoip_proxy directive to instruct NGINX to use the X-Forwarded-For header when connections are opened from a given range. The geoip_proxy directive takes an address or a CIDR range. When there are multiple proxies passing traffic in front of NGINX, you can use the geoip_proxy_recursive directive to recursively search through X-Forwarded-For addresses to find the originating client. You will want to use something like this when uti‐ lizing load balancers such as AWS ELB, Google’s load balancer, or Azure’s load balancer in front of NGINX.

## 3.5 Limiting Connections 

### Problem
You need to limit the number of connections based on a predefined key, such as the client’s IP address.
Solution
Construct a shared memory zone to hold connection metrics, and use the limit_conn directive to limit open connections:

    http {
        limit_conn_zone $binary_remote_addr zone=limitbyaddr:10m;
        limit_conn_status 429;
        ...
        server {
            ...
                limit_conn limitbyaddr 40;
    ... }
    }
    
This configuration creates a shared memory zone named limit byaddr. The predefined key used is the client’s IP address in binary form. The size of the shared memory zone is set to 10 mega‐ bytes. The limit_conn directive takes two parameters: a limit_conn_zone name, and the number of connections allowed. The limit_conn_status sets the response when the connections are limited to a status of 429, indicating too many requests. The limit_conn and limit_conn_status directives are valid in the HTTP, server, and location context.


### Discussion

Limiting the number of connections based on a key can be used to defend against abuse and share your resources fairly across all your clients. It is important to be cautious with your predefined key. Using an IP address, as we are in the previous example, could be dangerous if many users are on the same network that originates from the same IP, such as when behind a Network Address Translation (NAT). The entire group of clients will be limited. The limit_conn_zone directive is only valid in the HTTP context. You can utilize any number of variables available to NGINX within the HTTP context in order to build a string on which to limit by. Utiliz‐ ing a variable that can identify the user at the application level, such as a session cookie, may be a cleaner solution depending on the use case. The limit_conn_status defaults to 503, service unavailable. You may find it preferable to use a 429, as the service is available, and 500-level responses indicate server error whereas 400-level responses indicate client error.

## 3.6 Limiting Rate

### Problem
You need to limit the rate of requests by a predefined key, such as the client’s IP address.
Solution
Utilize the rate-limiting module to limit the rate of requests:

    http {
       limit_req_zone $binary_remote_addr
           zone=limitbyaddr:10m rate=1r/s;
       limit_req_status 429;
       ...
       server {
           ...
               limit_req zone=limitbyaddr burst=10 nodelay;
    ... }
    }
    
This example configuration creates a shared memory zone named limitbyaddr. The predefined key used is the client’s IP address in binary form. The size of the shared memory zone is set to 10 mega‐ bytes. The zone sets the rate with a keyword argument. The limit_req directive takes two optional keyword arguments: zone and burst. zone is required to instruct the directive on which shared memory request limit zone to use. When the request rate for a given zone is exceeded, requests are delayed until their maximum burst size is reached, denoted by the burst keyword argument. The burst keyword argument defaults to zero. limit_req also takes a third optional parameter, nodelay. This parameter enables the client to use its burst without delay before being limited. limit_req_status sets the status returned to the client to a particular HTTP status code; the default is 503. limit_req_status and limit_req are valid in the context of HTTP, server, and location. limit_req_zone is only valid in the HTTP context. Rate limiting is cluster-aware in NGINX Plus, new in version R16.

### Discussion

The rate-limiting module is very powerful for protecting against abusive rapid requests while still providing a quality service to everyone. There are many reasons to limit rate of request, one being security. You can deny a brute-force attack by putting a very strict limit on your login page. You can set a sane limit on all requests, thereby disabling the plans of malicious users who might try to deny service to your application or to waste resources. The configuration of the rate-limit module is much like the preceding connection- limiting module described in Recipe 3.5, and much of the same con‐ cerns apply. You can specify the rate at which requests are limited in requests per second or requests per minute. When the rate limit is reached, the incident is logged. There’s also a directive not in the example, limit_req_log_level, which defaults to error, but can be set to info, notice, or warn. New in NGINX Plus, version R16 rate limiting is now cluster-aware (see Recipe 12.5 for a zone sync exam‐ ple).


## 3.7 Limiting Bandwidth 

### Problem
You need to limit download bandwidth per client for your assets.


### Solution
Utilize NGINX’s limit_rate and limit_rate_after directives to limit the rate of response to a client:

    location /download/ {
        limit_rate_after 10m;
        limit_rate 1m;
	}
    
 
 The configuration of this location block specifies that for URIs with the prefix download, the rate at which the response will be served to the client will be limited after 10 megabytes to a rate of 1 megabyte per second. The bandwidth limit is per connection, so you may want to institute a connection limit as well as a bandwidth limit where applicable.
 
### Discussion

Limiting the bandwidth for particular connections enables NGINX to share its upload bandwidth across all of the clients in a manner you specify. These two directives do it all: limit_rate_after and limit_rate. The limit_rate_after directive can be set in almost any context: HTTP, server, location, and if when the if is within a location. The limit_rate directive is applicable in the same con‐ texts as limit_rate_after; however, it can alternatively be set by setting a variable named $limit_rate. The limit_rate_after directive specifies that the connection should not be rate limited until after a specified amount of data has been transferred. The limit_rate directive specifies the rate limit for a given context in bytes per second by default. However, you can specify m for mega‐ bytes or g for gigabytes. Both directives default to a value of 0. The value 0 means not to limit download rates at all. This module allows you to programmatically change the rate limit of clients.