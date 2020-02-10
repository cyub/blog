title: 使用雪花算法生成分布式ID
author: tinker
tags:
  - 分布式
  - 分布式ID
categories: []
date: 2020-02-01 17:26:00
---
Snowflake算法(雪花算法)是由Twitter提出的一个分布式全局唯一ID生成算法，该算法生成一个64bit大小的长整数。64bit位ID结构如下：

![Snowflake-64bit](https://static.cyub.vip/images/202001/snowflake-64bit.jpeg)
<!--more-->


各bit位说明：

- 1 位 不用

	生成的ID都是正整数，所以这个最高位即符号位固定是0。

- 41 位 用来记录毫秒级别时间戳

	- 此时间戳是从某一刻算起的时间戳，单位是毫秒级
	- 41位可以表示2^41 - 1个数字（0除外)， 支持约(2^41 - 1) / (1000 * 60 * 60 * 24 * 365)=69年
    - 时间戳保证了ID按时间趋势递增

- 10 位 用来记录工作机器 ID

	- 10位包括5位DatacenterId和5位WorkId，一共可以部署2^10-1个节点， 由于DatacenterId和workId区分保证了整个分布式系统内不会产生重复


- 12 位 用来序列号
	- 用来记录同一毫秒内产生的不同序号。最大支持2^12 - 1 = 4095个数字，来表示同一毫秒时间戳内产生的4095个ID序号
    
    
    
  此算法关键需要记录上次生成ID的时间戳和序号，若当前时间戳和上次时间戳一至，则在当前毫秒内生成序号，否则重置序号为0：
  
```php
<?php

class SnowflakeIdWorker
{
    public function nextId()
    {
        $timestamp = $this->timeGen();
        // 如果当前时间小于上一次ID生成的时间戳，说明系统时钟回退过这个时候应当抛出异常
        if ($timestamp < $this->lastTimestamp) {
            throw new RuntimeException(
                sprintf("Clock moved backwards.  Refusing to generate id for %d milliseconds", $this->lastTimestamp - $timestamp));
        }

        // 如果是同一时间生成的，则进行毫秒内序列
        if ($this->lastTimestamp == $timestamp) {
            $this->sequence = ($this->sequence + 1) & $this->sequenceMask;
            // 毫秒内序列溢出
            if ($this->sequence == 0) {
                // 阻塞到下一个毫秒,获得新的时间戳
                $timestamp = $this->tilNextMillis($this->lastTimestamp);
            }
        } else { // 时间戳改变，毫秒内序列重置
            $this->sequence = 0;
        }

         // 记录上次生成ID的时间截
         $this->lastTimestamp = $timestamp;
         
         ....
}
```

完整代码参考：[SnowflakeIdWorker](https://gist.github.com/cyub/841871d4889f80b0ac506f4b608fe194)


## 更多

- [twitter snowflake](https://github.com/twitter-archive/snowflake)
- [美团leaf ID生成系统](https://github.com/Meituan-Dianping/Leaf/blob/master/README_CN.md)
- [百度UidGenerator](https://github.com/baidu/uid-generator/blob/master/README.zh_cn.md)