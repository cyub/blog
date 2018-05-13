# Blog
Stuff you should know, stuff I should remember

## Installation

1. Hexo 

2. Caddy

## Configuration

Caddy vhost Config

```
http://www.cyub.vip:80 http://cyub.vip:80 {
	proxy / blog.local
	prometheus
	git {
	  repo https://github.com/cyub/blog
	  path /wwwroot/blog/source/_posts
	  interval 3600
	}
}
```