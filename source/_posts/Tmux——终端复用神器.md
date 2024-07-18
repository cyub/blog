title: Tmux——终端复用神器
tags:
  - tmux
  - 终端复用
  - 效率神器
categories: []
date: 2019-07-22 21:39:00
---
Tmux是终端复用器（terminal multiplexer）的缩写。通过启动Tmux会话，然后在该会话中打开多个窗口，并且分屏形成矩形窗格，执行不同操作，能极大提高终端操作效率。tmux支持的特性有：

1. 支持创建任意数量的窗口(window)
2. 支持同一个窗口创建任意数量的窗格(panel)
3. 支持垂直或水平分割窗口，并可以任意调整窗格大小
4. 支持会话分离和重连
5. 允许用户之间进行会话分享

<!--more-->

下图是tmux操作动态图，可以直观感受下：

![tmux操作](http://static.cyub.vip/images/201907/tmux.gif)

## 安装

大部分linux发行版本，默认安装了Tmux，若没有则按照下面步骤安装

Deiban和ubuntu系统：

```
sudo apt install tmux
```

Redhat和centos系统：

```
sudo yum install -y tmux
```

window系统cygwin终端：

```
apt-cyg install tmux
```

mac系统：

```
brew install tmux
```

## 使用

Tmux管理是窗口和窗格：

- 窗口(window)是一个单一的视图 - 也就是终端中显示的各种东西。
- 窗格pane是该视图的一部分，通常是一个终端会话


在终端执行下面命令，即创建一个会话，呈现我们面前的是一个窗口。创建会话(session)是相当于开启了一个终端，窗口(window)相当于终端中的tab，而(窗格)panel就是每个tab中的分屏功能。

```
tmux
```

`Ctrl+b`是tmux中的默认命令前缀，要在tmux中执行任何操作，你必须先输入该前缀然后输入所需的选项。

比如我们可以使用下面快捷键来垂直分割窗口

```
ctrl+b % // 垂直分割窗格
```

水平分割窗口的快捷键是：

```
ctrl+b " // 水平分割窗格
```

tmux默认的命令前缀使用起来不方便。我们可以更改tmux配置文件，将命令前缀改成`ctrl`+`a`键。tmux默认配置文件在`~/tmux.conf`

```
unbind C-b 
set -g prefix C-a
```

tmux操作一共分为三类：

1. 会话操作(session operation)
2. 窗口操作(window operation)
3. 窗格操作(panel operation)

下面列出三类操作常见操作命令，注意`prefix`是tmux命令前缀的简写。


#### 会话操作

操作名	| 命令/快捷键 |	说明
------- | ---------- | ------
新建会话	| tmux new -s sessionName |	s代表session
分离会话	| prefix d	| d代表detach，表示分离当前会话
查看会话列表 | tmux ls |	会列出所有tmux创建的会话
查看会话列表|	prefix s |	列出会话列表，并且可以使用方向键进行选择，然后按Enter键，进行切换不同的会话
重新进入会话	| tmux a -t sessionName |	a代表attach，-t为指定已经存在的会话
销毁会话	| tmux kill-session -t sessionName |	销毁已经存在的会话，-t后指定会话名
重命名会话	| tmux rename -t old_session_name  new_session_name	| 重命名会话
重命名会话 | prefix $ |	在会话环境下，重命名当前会话

关闭全部会话：

```
tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1)}' | xargs kill
```

### 窗口操作

操作名	| 命令/快捷键	| 说明
------- | ----------- |   -------
创建窗口 |	prefix c |	创建一个新的window,创建出来的窗口由窗口序号+窗口名字*显示，其中*表示当前操作的窗口
重命名window	|  prefix ,	| 为当前所在的window重命名
查看窗口列表 | prefix w | 显示窗口列表
切换window	| prefix n/p/w/0 |	n(next):切换到下一个window;<br/> p(previous):切换到上一个window; <br/>0(number):切换到0号窗口; <br/>w(windows):列出当前会话的所有的窗口，这时候可以使用上下键进行切换。<br> f(find)：通过窗口名称查找窗口
关闭window	| prefix & |	关闭当前window，会提示是否要关闭，输入即可。
实现鼠标滚动历史输出 |	prefix \[ |	默认情况输出不能往上翻滚，使用ctrl+b \[即可往上翻了，退出用ctrl+c即可。


### 窗格操作

操作名 |	命令/快捷键	 | 说明
------- | ------------ | --------
垂直分屏	| prefix %	| 把当前window垂直分为两个
水平分屏 |	prefix " |	把当前window水平分为两个
切换窗格 |	prefix o/Up/Down/Left/Right |	o是循环切换窗格，UP,Down,Left,Right代表上下左右箭头
删除窗格 |	prefix  x |  关闭当前使用的窗格，关闭之前会提示，输入y即可
打开时钟  | prefix t | 在panel显示时钟
最大化 | prefix z | 当前panel最大化
显示窗格 | prefix q | 显示窗格号, ctrl+b 窗格号：跳到指定窗格
与上一个窗格交换位置 | prefix {  | 与上一个窗格交换位置
与下一个窗格交换位置 | prefix } | 与下一个窗格交换位置
显示数字时钟 | prefix t  | 窗口中央显示一个数字时钟
列出所有快捷键 | prefix ?  | 列出所有快捷键
进入命令模式 | prefix :  | 进入命令模式，比如进入命令模式之后，可以输入new-window -n console，创建名为console的窗口


## 持久保存Tmux会话

Tmux Resurrect能够备份Tmux 会话的各种细节，包括所有会话、窗口、窗格以及它们的顺序，每个窗格的当前工作目录，精确的窗格布局，活动及替代的会话和窗口，窗口聚焦，活动窗格，窗格中运行的程序等等，非常贴心。


安装 Tmux Resurrect，可执行：

```
mkdir ~/.tmux
cd ~/.tmux
git clone https://github.com/tmux-plugins/tmux-resurrect.git
```

然后在~/.tmux.conf 中添加下列内容：

```
run-shell ~/.tmux/tmux-resurrect/resurrect.tmux
```

要保存Tmux会话，我们只要按prefix + Ctrl-s就可以了。此时，Tmux状态栏会显示“Saving ...”字样，完毕后会提示 Tmux 环境已保存。

Tmux Resurrect会将Tmux 会话的详细信息以文本文件形式保存到 ~/.tmux/resurrect 目录。

还原则按prefix + Ctrl-r即可。

## 文本复制

我们可以配置vi模式的复制方式

```
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
```

`prefix` + `[` 开启复制模式，然后按下`v`键开始复制，按方向键选择要复制的文本，按下`y`键或`enter`键把文本复制到tmux buffer里面。最后`prefix` + `]`黏贴

当window下PuTTY或者Cygwin终端中使用tmux时候，可以配置`setw -g mode-mouse on`，当需要从tmux中复制内容到系统剪切板时候，先按住`shift`键，然后通过鼠标选择文本。反之，先按住`shift`键，然后点击鼠标右键，再进行复制。



## 会话共享

### 1. 方式1

要在一台机器上共享会话，你必然需要把会话周期里要用到的的Unix端口号的路径给tmux：

```
tmux -S /tmp/our_socket
```

然后要给其他用户新建文件的入口：

```
chmod 777 /tmp/our_socket
```

当一个新用户想要加入会话，那就必须要经过端口路径，所以tmux知道哪个会话会被用到：

```
tmux -S /tmp/our_socket attach
```

### 2. 方式2

使用tmate
```
sudo apt-get install tmate // 安装
tmate // 新建一个会话
tmate show-messages // 显示ssh会话id和可以分享的url
```

tmate的工作原理如下图：

![tmate架构图](https://static.cyub.vip/images/201904/tmate-architecture.jpg)

## 启动shell时自动启动tmux

只需要将下面命令添加到自己家目录下的.bashrc。配置会尝试只启动一个会话, 当你登录时, 如果之前启动过会话, 那么它会直接attach, 而不是新开一个. 想要新开一个session要么是因为之前没有会话, 要么是你手动启动一个新的会话.


```js
# TMUX
if which tmux >/dev/null 2>&1; then
    #if not inside a tmux session, and if no session is started, start a new session
    test -z "$TMUX" && (tmux attach || tmux new-session)
fi
```

    
附一份tmux配置文件:

```yaml
# 基础设置
set -g display-time 3000
# 设置 tmux 等待前缀键和命令键之间的时间间隔为0
set -g escape-time 0
set -g history-limit 65535

# 设置窗口和面板索引从1开始
set -g base-index 1
set -g pane-base-index 1

# 前缀改成Ctrl+a
set -g prefix ^a
unbind ^b
bind a send-prefix

# 支持|-分割窗口
unbind '"'
bind - splitw -v
unbind %
bind | splitw -h

# 支持通过h，j，k 和 l选中窗口
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 支持通过prefix + H/J/K/L来调整窗口大小
# -r使用快捷键变成可重复的（repeatable）的，这意味着只需要按下前缀键一次，
# 然后就可以在最大重复限制范围内持续地按下定义的命令键
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# copy-mode 将快捷键设置为 vi 模式
setw -g mode-keys vi

# 启用鼠标(Tmux v2.1)
set -g mouse on

bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

# 更新配置文件
bind r source-file ~/.tmux.conf \; display "已更新"

# 鼠标支持 - 设置为on来启用鼠标
setw -g mode-mouse off
set -g mouse-select-pane off
set -g mouse-resize-pane off
set -g mouse-select-window off

# 设置默认终端模式为 256color
set -g default-terminal "screen-256color"

# 启用活动警告
setw -g monitor-activity on
set -g visual-activity on

# 居中窗口列表
set -g status-interval 60 # 状态栏每隔60s
set -g status-justify center # 状态栏居中显示

# 设置状态栏颜色
set -g status-fg white
set -g status-bg black

# 设置状态栏信息，依次显示会话，窗口，窗格id信息
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"

```    
    
## 参考

[tmux：适用于重度命令行 Linux 用户的终端复用器](https://linux.cn/article-10480-1.html?utm_source=index&utm_medium=moremore)

[Tmux使用手册](http://louiszhai.github.io/2017/09/30/tmux/#%E4%BC%9A%E8%AF%9D%E5%85%B1%E4%BA%AB)

[tmux: Productive Mouse-Free Development](https://www.kancloud.cn/kancloud/tmux/62466)