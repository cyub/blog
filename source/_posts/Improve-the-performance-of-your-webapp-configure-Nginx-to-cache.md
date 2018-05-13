---
title: 'Improve the performance of your webapp: configure Nginx to cache'
date: 2017-06-16 17:19:34
tags:
    - Nginx
    - HTTP 
    - HTTP Cache
---

![Nginx](https://www.theodo.fr/uploads/blog//2016/06/800px-Nginx_logo.svg_.png)

原文链接：[https://www.theodo.fr/blog/2016/06/improve-the-performance-of-your-webapp-configure-nginx-to-cache/](https://www.theodo.fr/blog/2016/06/improve-the-performance-of-your-webapp-configure-nginx-to-cache/)
Sometimes, [improving the user’s loading experience](https://www.theodo.fr/blog/2015/12/how-to-quickly-improve-users-loading-experience/) is not enough, and you need real changes to make your application load faster.
So you try CSS and JS [minification](https://en.wikipedia.org/wiki/Minification_(programming)) or [image compression](https://en.wikipedia.org/wiki/Portable_Network_Graphics#Optimizing_tools) but your app is only a bit faster to load. These tricks reduce the size of resources that need to be downloaded, but what if your users didn’t have to download anything at all? That’s what [caching](https://en.wikipedia.org/wiki/Cache_(computing)) is for!


In this article, I will explain how you can configure Nginx to enable the browser cache, thus avoiding painfully slow downloads. If you are not familiar with Nginx, I recommend reading [this article](https://www.theodo.fr/blog/2014/08/learn-the-basics-of-nginx/).

<!--more-->

## How HTTP caching works

Cache configuration is done on the server side. Basically, it is the server’s role to specify to the client any of these (with HTTP headers):
* if the resource may be cached
* by which type of cache the resource may be cached
when the cached resource should expire
* when the resource was last modified

But it is worth keeping in mind that it is the client’s responsibility to take the appropriate decision according to what the server replies. In particular, if you disable the cache in your browser or if you force the refresh of the page, the server’s answer will not be taken into account and you will download the resources, no matter what.

If you’re interested in knowing how the headers can be set to achieve the desired caching policy, I recommend [this article](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching?hl=en). In the following part I will focus on how Nginx can be configured to send the proper headers.


### On the client’s side
The browser (without you noticing) automatically generates headers based on the resource already cached. The goal of these headers is to check if the cached resource is still fresh. There are two ways of doing that:

* check if the resource has been modified since it was cached
* check if the identifier of the resource (usually a digest) has changed

| HEADER |MEANING | 
|------------|-----------|
| If-Modified-Since: Thu, 26 May 2016 00:00:00 GMT |The server is allowed to return a status 304 (not modified) if the resource has not been modified since that date.|
| If-None-Match: "56c62238977a31353ce7716e759a7edb" | The server is allowed to return a status 304 (not modified) if the resource identifier is the same. |

Based on the server’s response (see headers below) the browser will choose to use the cached version or will make a request to download the resource.

### On the server’s side

| HEADER | MEANING |
|--------| --------|
|Cache-Control: max-age=3600 | The resource may be cached for 3600 seconds |
|Expires: Thu, 26 May 2016 00:00:00 GMT | The resource must be considered as outdated after this date |
| Last-Modified: Thu, 26 May 2016 00:00:00 GMT | The resource was last modified on this date |
| ETag: "56c62238977a31353ce7716e759a7edb"| Identifier for the version of the resource |

The server can define the cache policy with the `Cache-Control` header.

The `max-age` directive and the `Expires` header can both be used to achieve the same goal. The former uses a duration whereas the second one uses a date. That’s how the client knows the expiration date.

If the `Cache-Control` header contains `public`, the client should not try to revalidate the resource. It will naively use the resource in the cache until the expiration date is reached.

However, if the `Cache-Control` header contains `must-revalidate`, then the client should check if the resource is fresh everytime the resource is needed (`even if the expiration date has not been reached`). This might still be a performance boost in most cases because if the resource has not been modified, the server will return a 304 (not modified), which is arguably very lightweight compared to your original resource.

`Last-Modified` and `ETag` are stored along with the resource so that the client can check later if the resource has changed (when using `must-revalidate`).

**If the HTTP Response contains the etag entry, the conditional request will always be made. ETag is a cache validator tag. The client will always send the etag to the server to see if the element has been modified.**

## How to configure Nginx to enable caching

Let’s assume that we want to cache the resources that are located in the `/static/` folder:

* /static/js/ for javascript files
* /static/css/ for CSS files
* /static/images/ for images

For this purpose, create a dedicated Nginx configuration file: `/etc/nginx/conf/cache.conf`, responsible for defining the cache policy. In your main configuration file (`/etc/nginx/nginx.conf`), add:

```
server {
    # ...
    include conf/cache.conf; # Add this line to your main config to include the cache configuration
}
```

Now, let’s see how the cache configuration can be set! This is an example of `/etc/nginx/conf/cache.conf`:

```
# JS
location ~* ^/static/js/$ {
    add_header Cache-Control public; # Indicate that the resource may be cached by public caches like web caches for instance, if set to 'private' the resource may only be cached by client's browser.

    expires     24h; # Indicate that the resource can be cached for 24 hours
}

# CSS
location ~* ^/static/css/$ {
    add_header Cache-Control public;

    # Equivalent to above:
    expires     86400; # Indicate that the resource can be cached for 86400 seconds (24 hours)

    etag on; # Add an ETag header with an identifier that can be stored by the client
}

# Images
location ~* ^/static/images/$ {
    add_header Cache-Control must-revalidate; # Indicate that the resource must be revalidated at each access

    etag on;
}
```

It is not aimed at a production use, it is merely an excuse to show the different ways cache can be configured.

Note:

* A negative value for expires automatically sends a `Cache-Control: no-cache` in the response, thus deactivating the cache.
* There is no need to manually add a `Last-Modified` header in the config as Nginx automatically sets it with the last modification date of the resource on the file system.

Reminders:

* The `Last-Modified` date and the `ETag` identifier are stored by the client to avoid requests in the future.
* The client may or may not check the freshness of the resource (with `If-Modified-Since` or `If-None-Match`), depending on the directives in Cache-Control.

## Conclusion

Which strategy you should use is up to you: it is a tradeoff between the size of the resource, how often it changes and how important it is for your users to see the changes immediately.

For example, if you have a logo (and logos do not usually change very often!), it makes sense to cache it and to not try to revalidate it for 7 days.

For critical resources, you might want to revalidate every time. The most important use case is arguably the security update: if you patch your javascript code to fix a vulnerability, you want the user to get it as soon as possible, and you don’t want them to use a harmful version in their browser cache.

Finally, there are some cases where you might want to tell the browser not to cache the resource: if it contains sensitive information or if you know that the resource changes too often to hope gain something from caching.

