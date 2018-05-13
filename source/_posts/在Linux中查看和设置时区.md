---
title: 在Linux中查看和设置时区
date: 2018-01-17 23:47:00
tags:
    - Linux配置
    - 时区
---

在设置Linux时间时候，时区是一个很重要的部分。让我们来看如何查看和设置Linux系统的时区

## 查看Linux当前时区

## 使用date命令查看时区

```bash
date -R // 查看当前具体时区
```
<!--more-->
## 使用timedatectl命令查看时区
timedatectl是查看设置时间命令，会显示当前系统时间，UTC时间，timezone,是否开启NTP等信息

```bash
timedatectl | grep 'Time zone'
```

## 设置Linux时区

### 使用timedatectl设置时区

```bash
timedatectl set-timezone 'Asia/Shanghai'
```

### 手动设置时区
`/etc/localtime`里面记录当前时区信息，通过更改此文件可以更改系统时区信息

```bash
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 设置当前用户时区
添加下面配置到当前用户.profile文件里面。系统支持的具体时区可以通过`tzselect`命令来查看。注意这只能改变当前这个用户时区

```
TZ='Asia/Shanghai'; export TZ 
```
