# Blog
Stuff you should know, stuff I should remember

## Installation

1. Nodejs

Ubuntu系统下安装Node.js v18.x：

```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
```

其他版本的安装方式见：https://github.com/nodesource/distributions

2. Hexo

```
npm install -g hexo
```

3. Nginx

```
apt install nginx
```

## Configuration

Nginx vhost Config

```
server {
    listen 80;
    server_name www.cyub.vip cyub.vip;
    root /var/www/blog/public;
}
```

## Generate static files

```bash
cd /var/www/blog
npm run build
```