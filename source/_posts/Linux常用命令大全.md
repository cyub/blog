---
title: Linux常用命令大全
date: 2016-11-03 19:07:15
tags:
    - Linux命令大全
    - Linux命令
---
## 1. 文件与目录操作
### touch - 创建文件

若文件不存在则创建文件，若存在则修改文件的时间(存取时间和更改时间)
```
touch a.txt // 创建a.txt
touch -r a.txt b.txt // 设置a.txt,b.txt时间一致
```
<!--more-->
### mv - 移动/重命名文件和目录
```
mv a.txt b.txt // 重命名a.txt为b.txt
mv a.txt dir1/  // 将a.txt 移动到dir1目录下
```

### mkdir - 创建目录
```
mkdir dir1 // 创建目录dir1
mkdir dir1 dir2 dir3 // 创建目录dir1,dir2,dir3
mkdir -p a/b/ //若父目录不存在则先创建父目录
```

### cp - 复制文件和目录
```
cp a.txt b.txt // 复制a.txt到b.txt，如果b.txt不存在，则创建，存在则覆盖
cp -i a.txt b.txt // 如果b.txt存在，覆盖b.txt之前，会询问用户
cp a.txt b.txt dir1/ // 复制a.txt, b.txt 到dir1目录
cp *.txt dir1/ // 复制txt文件到dir1目录
cp -r dir1/*.txt dir2/ // 递归地复制dir1目录下的txt文件到dir2目录下
cp -u a.txt b.txt // 当b.txt不存在，或者a.txt新于b.txt时候才会复制
```

### rm - 删除文件和目录
```
rm file1 // 删除file1
rm -i file1 // 删除文件file1，询问用户确认
rm -r dir1/ // 递归删除dir1以及目录下所有文件
rm -rf dir1/ dir2/ // 递归删除dir1,dir2目录，即使目录dir2不存在也不会终止
```

### ln - 创建链接
```
ln -s source_link target_link // 创建软连接target_link
```


## 2. I/O重定向
标准输入，输出和错误，在shell内部它们为文件描述符0，1和2
```
ls -l dir1/ >> ls-output.txt // 重定向ls命令输出的内容到ls-output.txt文件,>等同于1>
ls -l /usr/bintmp 2>ls-error.txt // 重定向标准错误输出到ls-error.txt
ls -l /bin/usr > ls-output.txt 2>&1 // 重定向标准输出和错误到同一个文件
ls -l /usr /usr/bintmp 2>ls-error.txt 1>ls-output.txt // 错误重定向到ls-error.txt 输出重定向到ls-output.txt
ls /usr/bin | tee ls.txt | grep zip //tee 从stdin读取数据，并同时输出到stdout和文件。tee命令相当于管道的一个T型接头
```

## 3. 包管理
不同的 Linux 发行版使用不同的打包系统，一般而言，大多数发行版分别属于两大包管理技术阵营： Debian 的”.deb”，和红帽的”.rpm”。也有一些重要的例外，比方说 Gentoo， Slackware，和 Foresight，但大多数会使用这两个基本系统中的一个。

软件包管理系统通常由两种工具类型组成：底层工具用来处理这些任务，比方说安装和删除软件包文件， 和上层工具，完成元数据搜索和依赖解析。

表3.1主要的包管理系统家族

| 包管理系统 | 发行版 (部分列表) | 上层工具 | 底层工具 |
| :------ | :------ | :------ | :------ |
| Debian Style (.deb) | Debian, Ubuntu, Xandros, Linspire | apt-get, aptitude | dpkg | 
| Red Hat Style (.rpm) | Fedora, CentOS, Red Hat Enterprise Linux, OpenSUSE, Mandriva, PCLinuxOS | yum | rpm |


## 4. 权限与进程
### id – 显示用户身份号
```
id
uid=500(me) gid=500(me) groups=500(me)
```

### chmod - 改变文件模式

表4.1 chmod 命令符号表示法

| 符号 | 说明 |
| :------ | :------ |
| u  | "user"的简写，意思是文件或目录的所有者|
| g  | 用户组 |
| o  | "others"的简写，意思是其他所有的人 |
| a  | "all"的简写，是"u", "g"和“o”三者的联合 |

如果没有指定字符，则假定使用”all”。执行的操作可能是一个“＋”字符，表示加上一个权限， 一个“－”，表示删掉一个权限，或者是一个“＝”，表示只有指定的权限可用，其它所有的权限被删除
```
chmod 755 a.txt // 将文件权限设置成755
chmod a+x a.txt // 所用组都赋予x权限
chmod u+x,go=rw a.txt //给文件拥有者执行权限并给组和其他人读和执行的权限。多种设定可以用逗号分开
```

### umask - 设置默认权限
### su - 切换用户
```
su // 切换成root用户，默认root用户
su - // 切换成用户，并切换环境
su - tinker // 切换成tinker用户，并切换环境
```

### sudo - 使用其他身份执行命令
```
sudo su - // 切换到root用户
sudo nginx -s reload // 以root用户身份执行nginx重启命令
```

### chown - 更改文件所有者和用户组
```
chown tinker a.txt // 将a.txt文件所有者改为tinker,文件用户组不变
chown tinker:tony a.txt // 将a.txt文件所有者改为tinker,文件用户组改为tony
chown :tony a.txt //将a.txt文件的用户组改为tony,所有者不变
chown tinker: a.txt // 将a.txt文件所有者改成tinker，用户组改为tinker登录系统时候，所属的用户组
```

### password - 更改用户密码
```
passwd // 修改当前登录用户密码
passwd tinker // 修改tinker账户密码
```

### ps - 报告当前进程快照
```
ps aux // 查看当前允许进程
ps -ef | more // 查看当前运行的所有进程
```

### top - 动态查看进程
```
top // 查看进程，默认以CPU占有率排序
top u tinker // 查看特定用户tinker的进程
```

### jobs – 列出任务
```
ps aux & // 将ps命令后台执行
jobs -l // 列出进程的PID以及作业号
jobs -r // 只列出运行中的作业
jobs -s // 只列出已停止的作业
```

### bg – 把任务放到后台执行
```
bg 2 后台模式重启一个作业
```

### fg – 把任务放到前台执行
```
fg 2 前台重启一个作业
```

### kill - 给进程发送信号
> kill [-signal] PID...

如果在命令行中没有指定信号，那么默认情况下，发送 TERM（终止）信号。

表4.2 常用信号

| 编号 | 名字 | 含义 |
| :------ | :------ | :------ |
| 1 | HUP | 挂起。这是美好往昔的痕迹，那时候终端机通过电话线和调制解调器连接到 远端的计算机。这个信号被用来告诉程序，控制的终端机已经“挂起”。 通过关闭一个终端会话，可以说明这个信号的作用。发送这个信号到终端机上的前台程序，程序会终止。许多守护进程也使用这个信号，来重新初始化。这意味着，当发送这个信号到一个守护进程后， 这个进程会重新启动，并且重新读取它的配置文件。Apache 网络服务器守护进程就是一个例子。|
| 2 | INT | 中断。实现和 Ctrl-c 一样的功能，由终端发送。通常，它会终止一个程序。 |
| 3 | QUIT | 退出 |
| 9 | KILL | 杀死。这个信号很特别。鉴于进程可能会选择不同的方式，来处理发送给它的 信号，其中也包含忽略信号，这样呢，从不发送 Kill 信号到目标进程。而是内核立即终止 这个进程。当一个进程以这种方式终止的时候，它没有机会去做些“清理”工作，或者是保存劳动成果。 因为这个原因，把 KILL 信号看作杀手锏，当其它终止信号失败后，再使用它。 |
| 11 | SEGV | 段错误。如果一个程序非法使用内存，就会发送这个信号。也就是说， 程序试图写入内存，而这个内存空间是不允许此程序写入的。 |
| 15 | TERM | 终止。这是 kill 命令发送的默认信号。如果程序仍然“活着”，可以接受信号，那么 这个信号终止。 |
| 18 | CONT | 继续。在停止一段时间后，进程恢复运行。 |
| 19 | STOP | 停止。这个信号导致进程停止运行，而没有终止。像 KILL 信号，它不被 发送到目标进程，因此它不能被忽略。 |
| 20 | TSTP | 终端停止。当按下 Ctrl-z 组合键后，终端发送这个信号。不像 STOP 信号， TSTP 信号由目标进程接收，且可能被忽略。 |
| 28 | WINCH | 改变窗口大小。当改变窗口大小时，系统会发送这个信号。 一些程序，像 top 和 less 程序会响应这个信号，按照新窗口的尺寸，刷新显示的内容。 |

```
kill -9 12345 // 终止进程12345
kill -l // 查看信号列表
```

### killall - 给多个进程发送信号
>killall [-u user] [-signal] name...

给匹配特定程序或用户名的多个进程发送信号

```
killall xlogo
```

### pstree - 显示树形结构进程列表
```
pstree
```

### pgrep - 查看进程id
```
pgrep nginx // 查看nginx进程id
```

### htop

### iotop

### vmstat - 显示资源使用快照

显示资源快照,包括内存，交换分区和磁盘 I/O
```
vmstat 5 // 5秒内的资源快照
```


## 5. 文件查找

### locate - 通过名字来查找文件

`locate`命令其实是“find -name”的另一种写法，但是要比后者快得多，**原因在于它不搜索具体目录，而是搜索一个数据库（/var/lib/locatedb）**，这个数据库中含有本地所有文件信息。Linux系统自动创建这个数据库，并且每天自动更新一次，所以使用locate命令查不到最新变动过的文件。为了避免这种情况，可以在使用locate之前，**先使用updatedb命令，手动更新数据库**。

```
locate /etc/sh // 搜索etc目录下所有以sh开头的文件
```

### whereis - 搜索程序名

whereis命令只能用于程序名的搜索，而且只搜索二进制文件（参数-b）、man说明文件（参数-m）和源代码文件（参数-s）。如果省略参数，则返回所有信息。

### which - 查命令

which命令的作用是，在PATH变量指定的路径中，搜索某个系统命令的位置，并且返回第一个搜索结果。也就是说，使用which命令，就可以看到某个系统命令是否存在，以及执行的到底是哪一个位置的命令。

### find – 强大的查找命令

```
find ~ | wc -l // 统计家目录文件数
find ~ -type d | wc -l // 统计家目录目录数量
find ~ -type f | wc -l // 统计家目录下文件数量
find ~ -type f -name "\*.JPG" -size +1M | wc -l // 查找所有文件名匹配 通配符模式“*.JPG”和文件大小大于1M 的文件
find ~ -type f -name '*.BAK' -delete // 删除扩展名为“.BAK”（这通常用来指定备份文件） 的文件
find ~ -type f -name '*.BAK' -print // 查看找到的文件
find ~ -type f -name 'foo*' -exec ls -l '{}' ';' // {}是当前路径名的符号表示，分号是要求的界定符 表明命令结束。
find ~ -type f -name 'foo*' -ok ls -l '{}' ';' // 使用 -ok 行为来代替 -exec，在执行每个指定的命令之前，会提示用户
find ~ -type f -name 'foo*' -exec ls -l '{}' +  // 把末尾的分号改为加号，就激活了 find 命令的一个功能，
// 把搜索结果结合为一个参数列表， 然后执行一次所期望的命令
find playground -type f -name 'file-A' | wc -l // 查找名字为file-A的文件
find playground \( -type f -not -perm 0600 \) -or \( -type d -not -perm 0700 \)
find playground \( -type f -not -perm 0600 -exec chmod 0600 '{}' ';' \) 
-or \( -type d -not -perm 0711 -exec chmod 0700 '{}' ';' \)
find ~ -empty // 查找home目录下的所有空文件
find ~ -type f -size 0 // 跟上面一条命令功能一样
find ~ -iname "hello.php" // 查找hello.php文件
```

### grep - 根据文件内容查找文件
```
grep -i "hello" hello.php // 在hello.php里面不区分大小写的查找hello
grep -A 3 -i "hello" // 输出成功匹配的行，以及该行之后的三行，-B选项之之前
grep -r "hello" dir1/ // 递归查找dir1目录下文件的匹配行
```

## 6. 归档与备份

### gzip – 压缩或者展开文件

执行gzip命令时，则原始文件的压缩版会替代原始文件。相对应的gunzip程序被用来把压缩文件复原为没有被压缩的版本。

表6.1 giz选项

| 选项 | 说明 |
| :------ | :------ |
| -c   | 把输出写入到标准输出，并且保留原始文件。也有可能用--stdout 和--to-stdout 选项来指定|
| -d   | 解压缩。正如 gunzip 命令一样。也可以用--decompress 或者--uncompress 选项来指定|
| -r   | 若命令的一个或多个参数是目录，则递归地压缩目录中的文件。也可用--recursive 选项来指定|
| -t   | 测试压缩文件的完整性。也可用--test 选项来指定|
| -v   | 显示压缩过程中的信息。也可用--verbose 选项来指定|


```
gzip foo.txt // 压缩foo.txt
ls -l /etc | gzip > foo.txt.gz // 创建了一个目录列表的压缩文件
gzip -d foot.txt.gz // 解压*.gz文件
gzip -tv foo.txt.gz // 测试文件的完整性
gunzip -c foo.txt | less // 不必指定gz拓展名，默认就是
```

### bzip2 - 压缩文件

由 Julian Seward 开发，与 gzip 程序相似，但是使用了不同的压缩算法， 舍弃了压缩速度，而实现了更高的压缩级别。在大多数情况下，它的工作模式等同于 gzip。 由 bzip2 压缩的文件，用扩展名 .bz2 来表示

### tar - 打包文件

在类 Unix 的软件世界中，这个 tar 程序是用来归档文件的经典工具。它的名字，是 tape archive 的简称，揭示了它的根源，它是一款制作磁带备份的工具。而它仍然被用来完成传统任务， 它也同样适用于其它的存储设备。我们经常看到扩展名为 .tar 或者 .tgz 的文件，它们各自表示“普通” 的 tar 包和被 gzip 程序压缩过的 tar 包。一个tar包可以由一组独立的文件，一个或者多个目录，或者 两者混合体组成

表6.2 tar操作模式

| 操作模式 | 说明 |
| :------ | :------ |
| c | 为文件和／或目录列表创建归档文件 |
| x | 抽取归档文件 |
| r | 追加具体的路径到归档文件的末尾 |
| t | 列出归档文件的内容 |

```
tar -cvf /path/to/foo.tar /path/to/foo/ // 创建一个包
tar -xvf foo.tar // 抽取一个包
tar -czvf /path/to/foo.tgz /path/to/foo/ // 创建.gz归档文件
tar -xzvf /path/to/foo.tgz // 抽取.gz归档文件
tar -ztvf /path/to/foo.tgz // 查看.gz文档文件的文件列表
tar -cjvf /path/to/foo.tgz /path/to/foo/ // 创建.bz2归档文件
tar -xjvf /path/to/foo.tgz // 抽取.bz2归档文件
tar -jtvf /path/to/foo.tgz // 查看.bz2归档文件的文件列表
```

### rsync - 同步目录和文件

>rsync options source destination

这里 source 和 destination 是下列选项之一：
* 一个本地文件或目录
* 一个远端文件或目录，以[user@]host:path 的形式存在
* 一个远端 rsync 服务器，由 rsync://[user@]host[:port]/path 指定

注意 source 和 destination 两者之一必须是本地文件。rsync 不支持远端到远端的复制
```
rsync -av --delete /etc /home /usr/local /media/BigDisk/backup 
// 备份文件到backup目录。--delete来删除可能在备份设备中已经存在但却不再存在于源设备中的文件
rsync -av --delete --rsh=ssh /etc /home /usr/local remote-sys:/backup
// --rsh=ssh 选项，其指示rsync使用ssh程序作为它的远程 shell。
rsync -avzP --progress ~/Documents/static_resource/static/* tinker@10.255.1.174:/wwwroot/static
```

## 7. 文本处理
### cat - 连接文件并输出到标准输出
```
cat a.txt // 输出a.txt内容
cat -ns a.txt // -n:给文本行添加行号，-s:禁止输出多个空白行
```

### sort - 文本排序

表7.1 sort常见选项

| 选项 | 描述 |
| :------ | :------ |
| -b | 默认情况下，对整行进行排序，从每行的第一个字符开始。这个选项导致sort程序忽略 每行开头的空格，从第一个非空白字符开始排序 |
| -f  | 让排序不区分大小写 |
| -n  | 基于数字值大小进行排序，而不是字母值 |
| -r | 按相反顺序排序。结果按照降序排列，而不是升序 |
| -k | -k=field1[,field2],对从field1到field2之间的字符排序，而不是整个文本行。看下面的讨论 |
| -m | 把每个参数看作是一个预先排好序的文件。把多个文件合并成一个排好序的文件，而没有执行额外的排序 |
| -o | 把排好序的输出结果发送到文件，而不是标准输出 |
| -t | 定义域分隔字符。默认情况下，域由空格或制表符分隔 | 

```
sort > foo.txt // 将标准输入内容排序好后存入到foo.txt文件
ls -l /usr/bin | sort -nr -k 5 | head // 将/usr/bin目录下文件按大小排序
sort file1.txt file2.txt file3.txt > final_sorted_list.txt // 合并有序文件
sort -k 1,1 -k 2n -k 3.7n foo.txt 
// 多字段排序，对第一个字段执行字母排序，第二个字段执行数值排序，第三个字段的第七个字符按数值排序
sort -t ':' -k 7 /etc/passwd | head // passwd文件的分隔符是:, 按照第七个字段分割
```
### uniq - 显示或省略重复行
uniq 只会删除相邻的重复行，常常配合sort使用，排序后然后处理重复行

表7.2 uniq常用选项

| 选项 | 说明 |
| :------ | :------ |
| -c | 输出所有的重复行，并且每行开头显示重复的次数 |
| -d | 只输出重复行，而不是特有的文本行 |
| -f  n |  忽略每行开头的 n 个字段，字段之间由空格分隔。不同于sort 程序，uniq 没有选项来设置备用的字段分隔符 |
| -i | 在比较文本行的时候忽略大小写 |
| -s n | 跳过（忽略）每行开头的 n 个字符 |
| -u | 只是输出独有的文本行。这是默认的 |

### cut - 从每行中删除文本区域
表7.3 cut常用选项

| 选项 | 说明 |
| :------ | :------: |
| -c char_list | 从文本行中抽取由 char_list 定义的文本。这个列表可能由一个或多个逗号 分隔开的数值区间组成 |
| -f field_list | 从文本行中抽取一个或多个由 field_list 定义的字段。这个列表可能 包括一个或多个字段，或由逗号分隔开的字段区间 |
| -d delim_char | 当指定-f 选项之后，使用 delim_char 做为字段分隔符。默认情况下， 字段之间必须由单个 tab 字符分隔开 |
| --complement | 抽取整个文本行，除了那些由-c 和／或-f 选项指定的文本 |

```
/* 例如文件a.txt内容格式如下：
tinker:12/07/2017:complete task a
jack:25/09/2017:complete task b
*/
cut -d: -f 2 a.txt | cut -c 7-10 // 输出年份
```

### diff - 逐行比较文件
```
diff -Naur file1 file2 // 比较file2与file2
```
### tr - 翻译或删除字符
```
echo "lowercase letters" | tr a-z A-Z // 小写转大写
echo "lowercase letters" | tr [:lower:] [:upper:] // 小写转大写
```

### sed - 文本的流编辑器
```
echo "front" | sed 's/front/back/' // 输出back
sed -n '5,10p' /etc/passwd  // 查看文件5到10行
```
### awk - 文本分析工具
```
awk '{print $2,$5;}' a.txt // 打印指定的2，5字段
ps aux | grep mysql | grep -v grep |awk '{print $2}' |xargs kill -9 // 杀掉mysql进程 
```
### head - 显示开头文字行
```
head -n 5 a.txt // 显示头5行文字
head -n -5 a.txt // 显示末尾5行文字
head -c 100 a.txt 显示最开始100个字符
```
### tail
```
tail -n 10 a.txt // 查看文件最后10行
tail -f /var/log/messages // 不停去读取最新内容
```

### vim
```
vim +10 file1.txt // 打开文件并调到第10行
vim +/search_term file2.txt // 打开文件并调到第一个匹配的行
vim -R /etc/passwd // 只读模式打开文件
```

## 8. 网络管理
### ping - 发送 ICMP ECHO_REQUEST 软件包到网络主机
ping 命令发送一个特殊的网络数据包，叫做 IMCP ECHO_REQUEST，到 一台指定的主机。大多数接收这个包的网络设备将会回复它，来允许网络连接验证。

注意：大多数网络设备（包括 Linux 主机）都可以被配置为忽略这些数据包。通常，这样做是出于网络安全 原因，部分地遮蔽一台主机免受一个潜在攻击者地侵袭。配置防火墙来阻塞 IMCP 流量也很普遍。

```
ping www.cyub.vip // 测试cyub.vip网站
```
### traceroute - 打印到一台网络主机的路由数据包
 traceroute程序（一些系统使用相似的 tracepath 程序来代替）会显示从本地到指定主机 要经过的所有“跳数”的网络流量列表

### netstat - 网络查看工具
```
netstat -ie // 查看系统网络接口
netstat -r // 内核的网络路由表
```
### ftp - 因特网文件传输程序
### wget - 非交互式网络下载器
```
wget http://www.cyub.vip 
wget http://www.cyub.vip -O a.html
```

### ssh - OpenSSH SSH 客户端
```
ssh test@baidu.com // 以test用户身份登录baidu.com主机
```

### nslookup - 查看dns解析
```
nslookup www.cyub.vip
```

### dig - 查看dns解析
```
dig www.cyub.vip // 查询域名的A记录
dig www.cyub.vip mx // 查询域名的mx记录，其他类型的记录有MX，CNAME，NS，PTR等，默认a记录
dig @10.255.1.174 www.cyub.vip // 指定dns服务器
dig www.cyub.vip a +tcp // dig默认使用udp协议进行查询，+tcp参数则指定tcp方式查询
dig www.cyub.vip a +trace // +trace参数将显示从根域逐级查询的过程
```

### curl

### tcpdump

### ifconfig

### sftp

### scp

## 9. 系统相关

### ulimit

### sysctl

### nice

### lsof

### uname
```
uname -a // 查看系统信息
```

### ssh-keygen

### openssl

### free

### df

### date

### shutdown - 系统关机
```
shutdown -h now // 系统立即关机
shutdown -h +10 // 10分钟后关机
shutdown -r now // 重启
```

### watch - 定时监控命令
```
watch -n 10 'cat /proc/loadavg' // 每隔10s输出系统平均负载
```

