title: Elasticsearch小技巧之版本号比较过滤筛选
author: tinker
tags:
  - Elasticsearch
  - Elasiticsearch小技巧
categories: []
date: 2019-11-10 16:36:00
---
安卓应用的版本信息分为版本名和版本号两部分。版本名是语义性版本，一般格式是`主版本号.次版本号.修订版本号`；版本号格式是数字，应用新版本的版本号一定要旧版本要大，因为安卓系统在安装升级应用时候，会检查应用的版本号是否大于手机内已安装的该应用的版本号，若小于则直接拒绝升级此应用。

在开发需求中，有时候会需要根据应用的版本名进行筛选应用，比如筛选版本名大于`7.33.1`的Netflix应用，此时若直接把每个应用的版本名索引到es里面，然后根据版本名字段range范围查询，这是有问题的。比如`12.8.1`版本是高于`7.31.1`版本的，因为在es里面是按照字符串逐字比较的，导致出现相反结果。

<!--more-->

下面测试直接版本号搜索情况：

1. 创建索引

```
PUT app
```
2. 创建映射

```
POST app/_mappings/_doc
{
  "properties": {
    "name": {
      "type": "keyword"
    },
    "version": {
      "type": "keyword"
    }
  }
}
```

3. 添加三个测试文档

```
POST app/_doc/1
{
  "name":"Netflix",
  "version":"7.33.1"
}

POST app/_doc/2
{
  "name":"Youtube",
  "version":"4.1.32"
}

POST app/_doc/3
{
  "name":"Netflix",
  "version":"12.8.1"
}
```

4. 搜索名字为Netflix的，版本大于7.33.1的应用

```
GET /app/_search
{
  "query": {
    "bool": {
      "must": {
        "match": {
          "name": "Netflix"
        }
      },
      "filter": {
        "range": {
          "version": {
            "gt": "7.33.1"
          }
        }
      }
    }
  }
}
```

此时未能搜到任何应用，其实文档3是符合要求的


对于这种问题，可以在创建索引时候，将版本名转换一个数值类型存在es里面。版本名转换成可比较的数字，一定要确保高版本对应的数值一定要大于低版本的数值，这时候我们可以将版本名的主版本号、次版本号、修订版本号分别乘以不同级别的放大系数来实现，比如：

```
版本名数值 = 主版本号 * 10 ^ 6 + 次版本号 * 10 ^ 3 + 修订版本号 * 10 ^ 1
```

下面是PHP简单实现示例：

```php
// 版本名转换成一个可比较的数字
function SemanticVersionToNumber($version) {
     $segments = explode('.', $version);
     $major = $segments[0] ?? 0;
     $minor = $segments[1] ?? 0;
     $patch = $segments[2] ?? 0;
     return intval($major) * 1000000 + intval($minor) * 1000 + intval($patch);
 }
```

此后筛选版本名大于`7.33.1`的Netflix应用时候，需要先将`7.33.1`版本名转换数字(7033001 = SemanticVersionToNumber('7.33.1'))，然后进行range查询

下面测试修改后情况：


1. 创建索引

```
PUT app
```

2. 创建映射，注意此时version类型为数值类型

```
POST app/_mappings/_doc
{
  "properties": {
    "name": {
      "type": "keyword"
    },
    "version": {
      "type": "long"
    }
  }
}
```

3. 添加三个测试文档，注意此时索引中version使用`SemanticVersionToNumber`函数转换成数字了

```
POST app/_doc/1
{
  "name":"Netflix",
  "version":7033001
}

POST app/_doc/2
{
  "name":"Youtube",
  "version":4001032
}

POST app/_doc/3
{
  "name":"Netflix",
  "version":12008001
}
```

4. 搜索名字为Netflix的，版本大于7.33.1的应用，此时把搜索条件中的版本名转换成数值

```
GET /app/_search
{
  "query": {
    "bool": {
      "must": {
        "match": {
          "name": "Netflix"
        }
      },
      "filter": {
        "range": {
          "version": {
            "gt": 7033001
          }
        }
      }
    }
  }
}
```