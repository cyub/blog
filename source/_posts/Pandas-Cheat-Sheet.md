title: Pandas Cheat Sheet
tags:
  - Pandas
  - Data Science
  - Cheat Sheet
  - ''
categories: []
date: 2018-10-09 00:13:00
---
Pandas作为python的库，包含易于使用的数据结构，是一个强大数据分析的工具

Pandas的主要数据结构有Series和DataFrame。Series是一种类似于一维数组的对象，它由一组数据以及一组与之相关的一组标签组成。DataFrame是一个表格型数据结构，它含有一组有序的列，每列可以是不同的值类型。

```python
import pandas as pd
import numpy as np
from pandas import Series, DataFrame
```
<!--more-->

## 导入数据
方法 | 说明
---|---
pd.read_csv(filename) | 从CSV文件导入
pd.read_table(filename) | 从文本分割文件 (比如 TSV)导入
pd.read_excel(filename) | 从Excel文件导入
pd.read_sql(query, connection_object) | 从SQL表中导入
pd.read_json(json_string) | 从json字符串中导入
pd.read_html(url) | 从url地址中导入
pd.read_clipboard() | 从剪切板中导入
pd.DataFrame(dict) | 从字典中导入

## 导出数据
方法 | 说明
---|---
df.to_csv(filename) | 导出到CSV文件
df.to_excel(filename) | 导出到excel文件中
df.to_sql(table_name, connection_object) | 写入到SQL表中
df.to_json(filename) | 以json格式导出到文件中

## 创建测试集合

方法 | 说明
---|---
pd.DataFrame(np.random.rand(20,5)) | 创建20行，5列的值为浮点数的DataFrame
pd.Series(my_list) | 使用列表my_list创建series
df.index = pd.date_range('1900/1/30', periods=df.shape[0]) | 创建日期索引

## 查看/检视数据

方法 | 说明
---|---
df.head(n) | 查看DataFrame前n行数据
df.tail(n) | 查看DataFrame后n行数据
df.shape() | 查看DataFrame的行数和列数
df.info() | 查看DataFrame索引(Index), 数据类型(Datatype) 和内存信息(Memory information)
df.describe() | DataFrame的摘要信息
s.value_counts(dropna=False) | 查看series中唯一值和总数
df.apply(pd.Series.value_counts) | 查看DataFrame中每一列的唯一值和总数

## 数据选取

方法 | 说明
---|---
df[col] | 选取标签为col的数据，并以series形式返回
df[[col1, col2]] | 返回一个新的DataFrame，包含原df中的标签col1,col2的数据
s.iloc[0] | 按位置进行选取
s.loc['index_one'] | 按标签进行选取
df.iloc[0,:] | 选取第一行
df.iloc[0,0] | 选取第一行第一列数据

## 数据清理
方法 | 说明
---|---
df.columns = ['a','b','c'] | 重命名列名
pd.isnull() | 检查是否是null值，以数组形式返回
pd.notnull() | pd.isnull()的相反操作
df.dropna() | 删除掉包含null值的行
df.dropna(axis=1) | 删除包含null的列
df.dropna(axis=1,thresh=n) | 删除掉非null值少于n的列
df.fillna(x) | 使用x替换所有null值
s.fillna(s.mean()) | 使用平均值替换所有null值
s.astype(float) | 将series数据类型转换成float类型
s.replace(1,'one') | 将所有等于1的值替换成one
s.replace([1,3],['one','three']) | 使用one替换1，three替换3
df.rename(columns=lambda x: x + 1) | 使用lambda重命名全部的列名
df.rename(columns={'old_name': 'new_ name'}) | 部分列名进行重命名
df.set_index('column_one') | 将column_one设置为索引
df.rename(index=lambda x: x + 1) | 使用lambda重置索引

## 过滤，排序，分组

方法 | 说明
---|---
df[df[col] > 0.5] | 返回标签为col的列中所有大于0.5的
df[(df[col] > 0.5) & (df[col] < 0.7)] | 返回标签为col的列中所有大于0.5的小与0.7的数据
df.sort_values(col1) | 按照标签col1进行升序排序
df.sort_values(col2,ascending=False) |  按照标签col2进行降序排序
df.sort_values([col1,col2],ascending=[True,False]) | 按照col1圣墟，col2降序进行排序
df.groupby(col) | 返回按列col分组后的数据
df.groupby([col1,col2]) | 返回按列col1,col2分组后的数据
df.groupby(col1)[col2] | Returns the mean of the values in col2, grouped by the values in col1 (mean can be replaced with almost any function from the statistics section)
df.pivot_table(index=col1,values=[col2,col3],aggfunc=mean) | 创建按照col1聚合，并计算col2和col3平均数的透视表
df.groupby(col1).agg(np.mean) | 使用col1分组后，计算每一个列的平均数
df.apply(np.mean) | 计算每一列的平均数
nf.apply(np.max,axis=1) | 计算每一行的最大值

## 连接/组合

方法 | 说明
---|---
df1.append(df2) | 将df1每一行追加到df2中 (df1和df2每一列应该相同)
pd.concat([df1, df2],axis=1) | 将df1中的每一列追加到df2中 (df1和df2行应该相同)
df1.join(df2,on=col1,how='inner') | SQL-style连接

## 统计

方法 | 说明
---|---
df.describe() | DataFrame每一列的汇总统计信息
df.mean() | 返回每一列的平均数
df.corr() | 返回列之间的相关性
df.count() | 返回每一列中非null值数量
df.max() | 返回每一列中最大值
df.min() | 返回每一列中最小值
df.median() | 返回每一列的中值
df.std() | 返回每一列的标准偏差

## 来源
[Pandas Cheat Sheet — Python for Data Science](https://www.dataquest.io/blog/pandas-cheat-sheet/)