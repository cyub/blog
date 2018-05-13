#!/usr/bin/env bash

docker run --rm  -v /var/deploy/web/www/blog/source:/app/source -v /var/deploy/web/www/blog/public:/app/public yubing/blog:0.2 hexo generate