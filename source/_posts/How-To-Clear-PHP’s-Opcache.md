---
title: How-To-Clear-PHP’s-Opcache
date: 2017-04-05 22:36:33
tags: 
    - Opcache
---

原文链接：https://ma.ttias.be/how-to-clear-php-opcache/

> PHP can be configured to store precompiled bytecode in shared memory, called **Opcache**. It prevents the loading and parsing of PHP scripts on every request. This guide will tell you how to flush that bytecode Opcache, should you need it.

You may want to [flush the APC (PHP < 5.5)](https://ma.ttias.be/clear-apc-cache-php/) or Opcache (PHP >= 5.5) in PHP when it has cached code you want to refresh. As of PHP 5.5, the APC cache has been replaced by Opcache and APC only exists as a user key/value cache, no longer a bytecode cache.

<!--more-->

## Determine your PHP method
You can run PHP in multiple ways. The last few years, PHP has evolved into new methods, [ranging from CGI to FastCGI to mod_php and PHP-FPM](https://ma.ttias.be/why-were-still-seeing-php-5-3-in-the-wild-or-php-versions-a-history/). Flushing your Opcache depends on how you run PHP.

If you want a uniform way of flushing your Opcache, you can create a PHP file called **flush_cache.php** in your docroot with content like this.
```
<?php
opcache_reset();
?>
```

Every time you want to flush your Opcache, you can browse to that file and it'll call **opcache_reset()**; for your entire Opcache. The next PHP request to your site will populate the cache again.

It's important that you call that URL in the same way you would reach your website, either via a HTTP:// or HTTPS:// URL. Running `php flush_cache.php` at the command line won't flush the cache of your running processes.

This can be part of your deployment process, where after each deploy you curl that particular URL.

If you want a server-side solution, check further.

## PHP running as CGI or FastCGI
Flushing the Opcache on CGI or FastCGI PHP is super simple: it can't be done.

Not because you can't flush the cache, but because the cache is flushed on every request anyway. FastCGI starts a new php-cgi process on every request and does not have a parent PHP process to store the Opcache results in.

In fact, **having Opcache running in a CGI or FastCGI model would hurt performance**: on every request the Opcache is stored in the FastCGI process (default behaviour if the Opcache extension activated), but that cache is destroyed as soon as that process dies after finishing the request.

Storing the Opcache takes a few CPU cycles and is an effort that cannot be benefited from again later.

CGI or FastCGI is about the worst possible way to run your PHP code.

## PHP running at the CLI
All PHP you run at the command line has no Opcache. It can be enabled, and PHP can attempt to store its Opcache in memory, but as soon as your CLI command ends, the cache is gone as well.

To clear the Opcache on CLI, just restart your PHP command. It's usually as simple as `CTRL+C` to abort the command and start it again.

For the same reason as running PHP as CGI or FastCGI above, having Opcache enabled for CLI requests would hurt performance more than you would gain benefits from it.

## Apache running as mod_php
If you run Apache, you can run PHP by embedding a module inside your Apache webserver. By default, PHP is executed as the same user your Apache webserver is running.

To flush the Opcache in a mod_php scenarion, you can either reload or restart your Apache webserver.

```
$ service httpd reload
$ apachectl graceful
```
A reload should be sufficient as it will clear the Opcache in PHP. A restart will also work, but is more invasive as it kills all active HTTP connections.

## PHP running as PHP-FPM
If you run your PHP as PHP-FPM, you can send a reload to your PHP-FPM daemon. The reload will flush the Opcache and force it to be rebuilt on the first incoming request.
```
$ service php-fpm reload
```
If you are running multiple PHP master, you can reload a single master to only reset that masters' Opcache. By default, it will flush the entire cache, no matter how many websites you have running.

If you want more control at the command line, you can use a tool like cachetool that can connect to your PHP-FPM socket and send it commands, the same way a webserver would.

First, download the phar that you can use to manipulate the cache.
```
$ curl -sO http://gordalina.github.io/cachetool/downloads/cachetool.phar
```
Next, use that phar to send commands to your PHP-FPM daemon.
```
$ php cachetool.phar opcache:reset --fcgi=127.0.0.1:9000
$ php cachetool.phar opcache:reset --fcgi=/var/run/php5-fpm.sock
```

Using something like cachetool can also be easily integrated in your automated deploy process.
