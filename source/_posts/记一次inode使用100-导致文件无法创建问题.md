title: 记一次inode使用100%导致文件无法创建问题
date: 2019-03-02 23:16:06
tags:
---
## 问题描述
前几日个人网站无法打开，自搭科学上网工具也无法使用。原本以为是服务器ip被封，后来查看服务器能正常登陆，cpu和内存等负载正常范围，但按tab键命令提示和创建文件时候，提示`No space left on device`。

<!--more-->

## 原因分析

由于没有多余可用空间，自然web服务器等也就不能正常工作了。至于没有可用空间，原以为磁盘使用满了，查看磁盘使用情况，使用了大概72%， 磁盘空间充足。想着是不是inode使用满了，接着查看inode空间使用情况：100%。由于inode为文件提供索引信息，如果inode空间使用完了，那自然就无法创建文件。磁盘空间没用使用完，inode却已使用100%，说明系统里面有大量小文件，占满了inode空间， 问题原因找到。

磁盘和inode查看命令截图如下：

![df命令使用](//static.cyub.vip/images/201903/df.jpeg)

## 问题处理

知道问题原因后，我在会话存储等目录查看有没有大量文件，一无所获。后来在网上找到一个"笨方法"：列出目录和其中的文件数量，一旦你看到一个文件数量异常多的目录(或者命令暂停计算很长时间)，重复该目录的命令，看看小文件到底在哪里。具体流程如下：

先在根目录下面，查找到文件最多的那个目录：

```js
for i in /*; do echo $i; find $i |wc -l; done
```

假如查到/var目录下面文件数量异常，接着定位此目录，以后一次类推。

```js
for i in /var/*; do echo $i; find $i |wc -l; done
```

我最后定位到`/var/lib/docker/network/files/`目录下有百万个文件。停止docker服务，删除定位到的目录下面的文件，再重启docker服务一切都OK，问题解决。

### 总结

#### `No space left on device`问题解决的2步走：

1. 查看磁盘空间使用情况

```js
df -h
```

若磁盘空间使用100%，查看各个目录空间占用情况

```js
du -sh /*
```

接口在占用空间最大的目录下查找大于一定大小的文件：

```js
find /tmp -type f -size +800M 
```

**注意：**若在查看目录占用空间远小于物理磁盘空间时候，这时候需要查看那些标记删除的文件占用空间是否异常。标记删除文件指的是文件删除时候，还被其他进程占用，此时系统不会真正的删除，而是使用Delete标记处理。

```js
lsof | grep deleted
```


2. 查看inode空间使用情况

```js
df -i
```

若磁盘空间未使用满，inode使用100%情况，使用前面"笨方法"定位小文件位置


#### 标记删除文件过大解决方案：

1. 首先找到所有标记删除的文件

 ```
 vagrant@vagrant:~$ sudo lsof -wnP | grep deleted

  nginx     391271                              root    4w      REG              253,0         0    2490625 /var/log/nginx/access.log (deleted)
 ```


从上面可以access.log被标记删除了，如果它占用空间过大，我们就需要删除掉，或者truncate其文件内容。

lsof命令中-w选项用于屏蔽warning错误提示，-n用于禁止网络号转换成主机名，-P用于禁止端口号转换成端口名，使用-nP选项可以加速lsof速度

2. 删除标记删除文件

要想删除掉标记删除的文件，我们只需要关闭打开该文件的进程

3. truncate标记删除文件

有时候我们不能停掉该文件的进程，这时候就需要我们truncate该文件，从上面我们可以看进程391271打开access.log文件。我们在该进程打开的fd中找到该文件：

```
vagrant@vagrant:~$ sudo ls -alh /proc/391271/fd
total 0
dr-x------ 2 root root  0 Sep 27 02:35 .
dr-xr-xr-x 9 root root  0 Sep 27 02:34 ..
lrwx------ 1 root root 64 Sep 27 02:35 0 -> /dev/null
lrwx------ 1 root root 64 Sep 27 02:35 1 -> /dev/null
l-wx------ 1 root root 64 Sep 27 02:35 2 -> /var/log/nginx/error.log
lrwx------ 1 root root 64 Sep 27 02:35 3 -> 'socket:[8224736]'
l-wx------ 1 root root 64 Sep 27 02:35 4 -> '/var/log/nginx/access.log (deleted)'
l-wx------ 1 root root 64 Sep 27 02:35 5 -> /var/log/nginx/error.log
lrwx------ 1 root root 64 Sep 27 02:35 6 -> 'socket:[8224737]'
lrwx------ 1 root root 64 Sep 27 02:35 7 -> 'socket:[8224738]'
lrwx------ 1 root root 64 Sep 27 02:35 8 -> 'socket:[8224739]'
```

从上面可以看到access.log在该目录下fd是4。我们可以使用下面操作truncate文件：

```
:>/proc/391271/fd/4 # truncate文件
```

如果提示`-bash: /proc/391271/fd/4: Permission denied`没有权限，我们可以：

```
sudo sh -c ":>/proc/391271/fd/4"
或者
truncate -s 0 /proc/391271/fd/4
```

更多清空文件内容的操作方法可以参考[Linux 下清空或删除大文件内容的 5 种方法](https://linux.cn/article-8024-1.html)




