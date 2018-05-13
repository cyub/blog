---
title: Debounce vs Throttle
date: 2018-01-27 21:41:52
tags:
    - Debounce
    - Throttle
---

`Debounce` 和 `Throttle`是javascript中两种手段来控制函数的执行，特别是事件的处理。

当处理`scroll`,`resize`, `keyup`等事件时候，由于每秒触发的时间频次太多，不断的通过绑定回调函数来处理，会对浏览器造成巨大压力。这时候Debounce和Throttle就派上用场了。

## Debounce
debounce强制函数某段时间只会执行一次，会把大量事件聚合在一次执行，哪怕它本来会被调用多次。

而throttle好比每隔15分钟一趟的电梯，过点不侯，debounce也每隔15分钟一趟，但当它看见有人要进来时候，它会允许进来，并从进来那一刻算起在等15分钟，如果15分钟内没有人进来了，就会开走。
<!--more-->

下面两个场景适用debounce:
1. 当用户设置浏览器宽度，页面重新布局时候
2. 当用户输入内容，向服务器发起ajax查询，返回搜索建议时候。通过监听用户keyup事件，当停止输入时候，发起ajax查询

debounce一个简单实现：
```javascript
function debounce (fn, delay) {
    var timer;
    return function () {
        var context = this,
            args = arguments; 
        clearTimeout(timer);
        timer = setTimeout(function () {
                fn.apply(context, args);
        }, delay);
    }
}
```

如果debounce的电梯一直有人来，那么就会值等待下去，如果我们想超过一定时间就要开走，可以加个最大等待时间来处理，实现如下：

```javascript
function debounce (fn, delay, maxWait) {
    var timeout, first, args, context, 
        later = function() {
            fn.apply(context, args);
            timeout = first = args = context = null;
        };
    return function() {
        context = this;
        args = arguments;
        if (!first) {
            first = Date.now();
        }

        clearTimeout(timeout);

        if (maxWait < (Date.now() - first)) {
            later();
        } else {
            timeout = setTimeout(later, delay);
        }
    };
}
```
## Throttle
throttle会以固定的频率执行函数，好比水龙头固定速率流水。

throttle适用一定频率执行回调的场景。比如瀑布流，如果采用debounce方式，那么只有用户停止滚动屏幕时候才加载更多内容，这非常不友好。这时候可以固定频率来判断用户是否到屏幕底部，然后加载更多内容

throttle一个简单实现：
```javascript
function throttle(fn, threshhold) {
    var last, timer;
    threshhold || (threshhold = 250);

    return function () {
        var context = this,
            args = arguments,
            now = +new Date();
        //如果距离上次执行fn函数的时间小于threshhold，那么就放弃执行fn，并重新计时
        if (last && now < last + threshhold) {
            clearTimeout(timer)
            timer = setTimeout(function () {
                last = fn.apply(context, args);
            }, threshhold)
        } else {
            last = now;
            fn.apply(context, args);
        }
    }
}
```

## 参考
[debounce与throttle区别](http://blog.csdn.net/ligang2585116/article/details/75003436)
[Debounce 和 Throttle 的原理及实现](http://blog.csdn.net/redtopic/article/details/69396722)
[Debouncing and Throttling Explained Through Examples](https://css-tricks.com/debouncing-throttling-explained-examples/)




