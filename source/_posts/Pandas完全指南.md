title: Pandas完全指南
author: tinker
tags:
  - Pandas
categories: []
date: 2020-01-22 10:54:00
---
## 前言

Pandas 是一个Python语言实现的，开源，易于使用的数据架构以及数据分析工具。在Pandas中主要有两种数据类型，可以简单的理解为：

- Series：一维数组(列表)
- DateFrame：二维数组（矩阵）

## 导入pandas


```python
import pandas as pd
import numpy as np
from IPython.display import Image
```

## 创建列表

### 创建普通列表


```python
s = pd.Series([1, 3, 6, np.nan, 23, 3]) # type(s) === 'pandas.core.series.Series'
```

<!--more-->

### 创建时间列表


```python
dates = pd.date_range('20200101', periods=6)
```

## 创建矩阵

### 根据列表（Series）创建矩阵


```python
df = pd.DataFrame(np.random.randn(6, 4), index=dates, columns=['a', 'b', 'c', 'd'])
```


```python
df
```

<table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-01-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr><tr><th>2020-01-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-01-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-01-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-01-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-01-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr></tbody></table>




```python
df2 = pd.DataFrame({
  'a':pd.Series([1, 2, 3, 4]),
  'b':pd.Timestamp('20180708'),
  'c':pd.Categorical(['cate1', 'cate2', 'cate3', 'cate4'])
})
```


```python
df2
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th></tr></thead><tbody><tr><th>0</th><td>1</td><td>2018-07-08</td><td>cate1</td></tr><tr><th>1</th><td>2</td><td>2018-07-08</td><td>cate2</td></tr><tr><th>2</th><td>3</td><td>2018-07-08</td><td>cate3</td></tr><tr><th>3</th><td>4</td><td>2018-07-08</td><td>cate4</td></tr></tbody></table></div>



### 根据字典创建矩阵


```python
data = {'name': ['Jason', 'Molly', 'Tina', 'Jake', 'Amy', 'Jack', 'Tim'], 
        'age': [20, 32, 36, 24, 23, 18, 27], 
        'gender': np.random.choice(['M','F'],size=7),
        'score': [25, 94, 57, 62, 70, 88, 67],
        'country': np.random.choice(['US','CN'],size=7),
        }
df3 = pd.DataFrame(data, columns = ['name', 'age', 'gender', 'score', 'country'])
```


```python
df3
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr></tbody></table></div>



## 矩阵属性、检视数据

### 行数列数


```python
df.shape
```

    (6, 4)



### 索引


```python
df.index
```




    DatetimeIndex(['2020-01-01', '2020-01-02', '2020-01-03', '2020-01-04',
                   '2020-01-05', '2020-01-06'],
                  dtype='datetime64[ns]', freq='D')



### 列名


```python
df.columns
```




    Index(['a', 'b', 'c', 'd'], dtype='object')



### 值


```python
df.values
```




    array([[-1.36577441,  1.16989918,  0.60759059, -2.02968684],
           [-0.96768326, -0.80044798,  0.12367311,  0.70033731],
           [ 1.79060939,  0.56066552,  0.34405077,  0.79952019],
           [ 2.06866329,  0.32060998, -1.6606308 ,  0.41663058],
           [-0.95635134, -0.65704975,  1.24143335, -0.65249624],
           [-1.1358703 ,  1.88809265,  0.53336403,  0.08085195]])



### 矩阵信息


```python
df.info()
```

    <class 'pandas.core.frame.DataFrame'>
    DatetimeIndex: 6 entries, 2020-01-01 to 2020-01-06
    Freq: D
    Data columns (total 4 columns):
     #   Column  Non-Null Count  Dtype  
    ---  ------  --------------  -----  
     0   a       6 non-null      float64
     1   b       6 non-null      float64
     2   c       6 non-null      float64
     3   d       6 non-null      float64
    dtypes: float64(4)
    memory usage: 240.0 bytes


### 矩阵描述信息


```python
df.describe()
```



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>count</th><td>6.000000</td><td>6.000000</td><td>6.000000</td><td>6.000000</td></tr><tr><th>mean</th><td>-0.094401</td><td>0.413628</td><td>0.198247</td><td>-0.114141</td></tr><tr><th>std</th><td>1.577260</td><td>1.038903</td><td>0.984921</td><td>1.074899</td></tr><tr><th>min</th><td>-1.365774</td><td>-0.800448</td><td>-1.660631</td><td>-2.029687</td></tr><tr><th>25%</th><td>-1.093824</td><td>-0.412635</td><td>0.178768</td><td>-0.469159</td></tr><tr><th>50%</th><td>-0.962017</td><td>0.440638</td><td>0.438707</td><td>0.248741</td></tr><tr><th>75%</th><td>1.103869</td><td>1.017591</td><td>0.589034</td><td>0.629411</td></tr><tr><th>max</th><td>2.068663</td><td>1.888093</td><td>1.241433</td><td>0.799520</td></tr></tbody></table></div>



```python
### 更改索引
df.index = pd.date_range('2020/06/01', periods=df.shape[0])

df
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr></tbody></table></div>



### top5 数据


```python
df.head(1)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr></tbody></table></div>



### tail5 数据


```python
df.tail(5)
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr></tbody></table></div>



### 某一列值统计


```python
df['a'].value_counts(dropna=False)
```




     1.790609    1
    -1.135870    1
     2.068663    1
    -0.967683    1
    -1.365774    1
    -0.956351    1
    Name: a, dtype: int64



### 查看每一列唯一值统计


```python
df.apply(pd.Series.value_counts)
```




<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>-2.029687</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>-1.660631</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>-1.365774</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>-1.135870</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>-0.967683</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>-0.956351</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>-0.800448</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>-0.657050</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>-0.652496</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>0.080852</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>0.123673</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>0.320610</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>0.344051</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>0.416631</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>0.533364</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>0.560666</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>0.607591</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>0.700337</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>0.799520</th><td>NaN</td><td>NaN</td><td>NaN</td><td>1.0</td></tr><tr><th>1.169899</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>1.241433</th><td>NaN</td><td>NaN</td><td>1.0</td><td>NaN</td></tr><tr><th>1.790609</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>1.888093</th><td>NaN</td><td>1.0</td><td>NaN</td><td>NaN</td></tr><tr><th>2.068663</th><td>1.0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr></tbody></table></div>



## 排序

### 根据索引(index)排序


```python
# sort_index(axis=, ascending=)
# axis：0-行排序，1-列排序; ascending：True-升序，False-降序
df.sort_index(axis=0, ascending=False)
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr></tbody></table></div>




```python
df.sort_index(axis=1, ascending=False)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>d</th><th>c</th><th>b</th><th>a</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-2.029687</td><td>0.607591</td><td>1.169899</td><td>-1.365774</td></tr><tr><th>2020-06-02</th><td>0.700337</td><td>0.123673</td><td>-0.800448</td><td>-0.967683</td></tr><tr><th>2020-06-03</th><td>0.799520</td><td>0.344051</td><td>0.560666</td><td>1.790609</td></tr><tr><th>2020-06-04</th><td>0.416631</td><td>-1.660631</td><td>0.320610</td><td>2.068663</td></tr><tr><th>2020-06-05</th><td>-0.652496</td><td>1.241433</td><td>-0.657050</td><td>-0.956351</td></tr><tr><th>2020-06-06</th><td>0.080852</td><td>0.533364</td><td>1.888093</td><td>-1.135870</td></tr></tbody></table></div>


### 根据值排序


```python
df.sort_values(by='a', ascending=False)
```
<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr></tbody></table></div>


```python
df.sort_values(by=['a','b'], ascending=True)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.533364</td><td>0.080852</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr></tbody></table></div>


## 选取数据

### 选取某一列


```python
df['a'] # 等效于df.a
```




    2020-06-01   -1.365774
    2020-06-02   -0.967683
    2020-06-03    1.790609
    2020-06-04    2.068663
    2020-06-05   -0.956351
    2020-06-06   -1.135870
    Freq: D, Name: a, dtype: float64



### 根据索引选取某几行数据


```python
df['2020-06-01':'2020-06-02'] # 选取索引以2020-06-01开始，到2020-06-02结束的数据
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr></tbody></table></div>



### 根据列名选择某几列数据


```python
df[['c', 'b']]
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>c</th><th>b</th></tr></thead><tbody><tr><th>2020-06-01</th><td>0.607591</td><td>1.169899</td></tr><tr><th>2020-06-02</th><td>0.123673</td><td>-0.800448</td></tr><tr><th>2020-06-03</th><td>0.344051</td><td>0.560666</td></tr><tr><th>2020-06-04</th><td>-1.660631</td><td>0.320610</td></tr><tr><th>2020-06-05</th><td>1.241433</td><td>-0.657050</td></tr><tr><th>2020-06-06</th><td>0.533364</td><td>1.888093</td></tr></tbody></table></div>


### 根据索引和列名选择数据

loc[行名选择, 列名选择]，未指定行名或列名，或者指定为:则表示选择当前所有行，或列


```python
df.loc['2020-06-01']
```




    a   -1.365774
    b    1.169899
    c    0.607591
    d   -2.029687
    Name: 2020-06-01 00:00:00, dtype: float64




```python
df.loc['2020-06-01', 'b']
```




    1.1698991845802456




```python
df.loc[:, 'b'] # type(df.loc[:, 'b']) === 'pandas.core.series.Series'，而type(df.loc[:, ['b']]) === ’pandas.core.frame.DataFrame‘
```




    2020-06-01    1.169899
    2020-06-02   -0.800448
    2020-06-03    0.560666
    2020-06-04    0.320610
    2020-06-05   -0.657050
    2020-06-06    1.888093
    Freq: D, Name: b, dtype: float64




```python
df.loc[:, ['a', 'b']]
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th></tr></thead><tbody><tr><th>2020-06-01</th><td>-1.365774</td><td>1.169899</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td></tr></tbody></table></div>


### 根据行索引和列索引取数据


```python
df.iloc[0,0] # === df.loc['2020-06-01', 'a']
```




    -1.3657744117360429




```python
df.iloc[0, :] # ==== df.loc['2020-06-01', :]
```




    a   -1.365774
    b    1.169899
    c    0.607591
    d   -2.029687
    Name: 2020-06-01 00:00:00, dtype: float64



### 根据布尔表达式表达式取数据

只有当布尔表达式为真时的数据才会被选择


```python
df[df.a > 1]
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr></tbody></table></div>


```python
df[(df['a'] > 1) & (df['d'] <0)]
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody></tbody></table></div>



## 添加/删除列、更新、替换数据

### 设置某矩阵项值


```python
df.loc['2020-06-01', 'a'] = np.nan
df.loc['2020-06-06', 'c'] = np.nan
```


```python
df
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td></tr></tbody></table></div>



### 根据条件创建新列


```python
df['e'] = np.where((df['a'] > 1) & (df['d']<0), 1, 0)
```


```python
df
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td></tr></tbody></table></div>


### 根据已有列创建新列


```python
tmp = df.copy()
df.loc[:,'f'] = tmp.apply(lambda row: row['b']+ row['d'], axis=1)
```


```python
df
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>


### 替换数据


```python
# 将所有等于1的值替换成20
df.replace(1,20)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>




```python
# 使用one替换1，three替换3
df.replace([1,3],['one','three'])
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>



### 列名重命名


```python
df.rename(columns={'c':'cc'})
```



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>cc</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>NaN</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>





### 重设索引


```python
# 将a设置为索引
df.set_index('a')
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr><tr><th>a</th><th></th><th></th><th></th><th></th><th></th></tr></thead><tbody><tr><th>NaN</th><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>-0.967683</th><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>1.790609</th><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2.068663</th><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>-0.956351</th><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>-1.135870</th><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>



### 删除列


```python
df.drop(columns=['a', 'f'])
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>b</th><th>c</th><th>d</th><th>e</th></tr></thead><tbody><tr><th>2020-06-01</th><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td></tr><tr><th>2020-06-02</th><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td></tr><tr><th>2020-06-03</th><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td></tr><tr><th>2020-06-04</th><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td></tr><tr><th>2020-06-05</th><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td></tr><tr><th>2020-06-06</th><td>1.888093</td><td>NaN</td><td>0.080852</td><td>0</td></tr></tbody></table></div>



### 处理Nan数据

#### 检查是否Nan值


```python
df.isnull()
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>True</td><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td></tr><tr><th>2020-06-02</th><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td></tr><tr><th>2020-06-03</th><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td></tr><tr><th>2020-06-04</th><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td></tr><tr><th>2020-06-05</th><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td><td>False</td></tr><tr><th>2020-06-06</th><td>False</td><td>False</td><td>True</td><td>False</td><td>False</td><td>False</td></tr></tbody></table></div>


```python
df.notnull() # df.isnull()反操作
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>False</td><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td></tr><tr><th>2020-06-02</th><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td></tr><tr><th>2020-06-03</th><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td></tr><tr><th>2020-06-04</th><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td></tr><tr><th>2020-06-05</th><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td><td>True</td></tr><tr><th>2020-06-06</th><td>True</td><td>True</td><td>False</td><td>True</td><td>True</td><td>True</td></tr></tbody></table></div>



#### 删除掉包含null值的行


```python
### dropna(axis=, how=)：丢弃NaN数据，
# axis：0-按行丢弃)，1-按列丢弃; how：'any'-只要含有NaN数据就丢弃，'all'-所有数据都为NaN时丢弃

df.dropna(axis=0)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr></tbody></table></div>



#### 替换Nan


```python
#### 使用1000替换Nan
df.fillna(1000)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>1000.000000</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>1000.000000</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>



```python
# 使用平均值替换所有null值
df.fillna(df.mean())
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>2020-06-01</th><td>0.159874</td><td>1.169899</td><td>0.607591</td><td>-2.029687</td><td>0</td><td>-0.859788</td></tr><tr><th>2020-06-02</th><td>-0.967683</td><td>-0.800448</td><td>0.123673</td><td>0.700337</td><td>0</td><td>-0.100111</td></tr><tr><th>2020-06-03</th><td>1.790609</td><td>0.560666</td><td>0.344051</td><td>0.799520</td><td>0</td><td>1.360186</td></tr><tr><th>2020-06-04</th><td>2.068663</td><td>0.320610</td><td>-1.660631</td><td>0.416631</td><td>0</td><td>0.737241</td></tr><tr><th>2020-06-05</th><td>-0.956351</td><td>-0.657050</td><td>1.241433</td><td>-0.652496</td><td>0</td><td>-1.309546</td></tr><tr><th>2020-06-06</th><td>-1.135870</td><td>1.888093</td><td>0.131223</td><td>0.080852</td><td>0</td><td>1.968945</td></tr></tbody></table></div>


## 聚合、分组、统计

### 返回每一列的平均数


```python
df.mean()
```




    a    0.159874
    b    0.413628
    c    0.131223
    d   -0.114141
    e    0.000000
    f    0.299488
    dtype: float64



### 返回列之间的相关性


```python
df.corr()
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>a</th><th>b</th><th>c</th><th>d</th><th>e</th><th>f</th></tr></thead><tbody><tr><th>a</th><td>1.000000</td><td>0.101781</td><td>-0.680085</td><td>0.508954</td><td>NaN</td><td>0.318586</td></tr><tr><th>b</th><td>0.101781</td><td>1.000000</td><td>-0.171353</td><td>-0.266608</td><td>NaN</td><td>0.587598</td></tr><tr><th>c</th><td>-0.680085</td><td>-0.171353</td><td>1.000000</td><td>-0.437212</td><td>NaN</td><td>-0.605077</td></tr><tr><th>d</th><td>0.508954</td><td>-0.266608</td><td>-0.437212</td><td>1.000000</td><td>NaN</td><td>0.623208</td></tr><tr><th>e</th><td>NaN</td><td>NaN</td><td>NaN</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>f</th><td>0.318586</td><td>0.587598</td><td>-0.605077</td><td>0.623208</td><td>NaN</td><td>1.000000</td></tr></tbody></table></div>



### 返回每一列中非null值数量


```python
df.count()
```




    a    5
    b    6
    c    5
    d    6
    e    6
    f    6
    dtype: int64



### 返回每一列中最大值


```python
df.max()
```




    a    2.068663
    b    1.888093
    c    1.241433
    d    0.799520
    e    0.000000
    f    1.968945
    dtype: float64



### 返回每一列中最小值


```python
df.min()
```




    a   -1.135870
    b   -0.800448
    c   -1.660631
    d   -2.029687
    e    0.000000
    f   -1.309546
    dtype: float64



### 返回每一列的中值


```python
df.median()
```




    a   -0.956351
    b    0.440638
    c    0.344051
    d    0.248741
    e    0.000000
    f    0.318565
    dtype: float64



### 返回每一列的标准偏差


```python
df.std()
```




    a    1.620114
    b    1.038903
    c    1.085770
    d    1.074899
    e    0.000000
    f    1.280342
    dtype: float64



### 分组后取TopN


```python
### 取每个国家下，分值前二的记录

# 先排序
df4 = df3.sort_values(['country','score'],ascending=[1, 0],inplace=False)
df4
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td></tr><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td></tr></tbody></table></div>




```python
# 取值
df4.groupby(['country']).head(2)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr></tbody></table></div>



### 多重分组后取TopN


```python
### 取每个国家下，分值前二的记录

# 先排序
df5 = df3.sort_values(['country','gender', 'score'],ascending=[1, 0, 0],inplace=False)
df5
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td></tr><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td></tr></tbody></table></div>



```python
df5 = df5.groupby(['country', 'gender']).head(1) # 注意此处取1
df5
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr></tbody></table></div>


```python
df5.groupby(['country']).head(2)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr></tbody></table></div>



### 分组之后取平均值


```python
scoreMean = df3.groupby(['gender'])['score'].mean()
scoreMean = pd.DataFrame(scoreMean) # 等效于socreMean = scoreMean.to_frame()
scoreMean
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>score</th></tr><tr><th>gender</th><th></th></tr></thead><tbody><tr><th>F</th><td>62.6</td></tr><tr><th>M</th><td>75.0</td></tr></tbody></table></div>


```python
#### 合并
df3.merge(scoreMean,left_on='gender',right_index=True)
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score_x</th><th>country</th><th>score_y</th></tr></thead><tbody><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td><td>62.6</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td><td>62.6</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td><td>62.6</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td><td>62.6</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td><td>62.6</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td><td>75.0</td></tr><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td><td>75.0</td></tr></tbody></table></div>




```python
df3
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr></tbody></table></div>



### 分组之后计数


```python
df3.groupby(['country'])['gender'].count().to_frame()
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>gender</th></tr><tr><th>country</th><th></th></tr></thead><tbody><tr><th>CN</th><td>3</td></tr><tr><th>US</th><td>4</td></tr></tbody></table></div>


```python
### 按性别统计每个国家的人数

df3.groupby(['country', 'gender'])['gender'].count().to_frame()
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th></th><th>gender</th></tr><tr><th>country</th><th>gender</th><th></th></tr></thead><tbody><tr><th rowspan="2" valign="top">CN</th><th>F</th><td>1</td></tr><tr><th>M</th><td>2</td></tr><tr><th>US</th><th>F</th><td>4</td></tr></tbody></table></div>



### 分组后唯一值统计


```python
df3.groupby(['country'])['gender'].nunique().to_frame()
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>gender</th></tr><tr><th>country</th><th></th></tr></thead><tbody><tr><th>CN</th><td>2</td></tr><tr><th>US</th><td>1</td></tr></tbody></table></div>


### 分组后求和


```python
# 默认是所有数值类型列求和
df3.groupby('country').sum() 
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>age</th><th>score</th></tr><tr><th>country</th><th></th><th></th></tr></thead><tbody><tr><th>CN</th><td>69</td><td>217</td></tr><tr><th>US</th><td>111</td><td>246</td></tr></tbody></table></div>




```python
# 指定列求和
df3.groupby('country')['score'].sum() # 等效于df3.groupby(['country'])['score'].apply(np.sum)
```




    country
    CN    217
    US    246
    Name: score, dtype: int64




```python
import matplotlib.pyplot as plt
```


```python
plt.clf()
df3.groupby('country').sum().plot(kind='bar')
plt.show()
```


    <Figure size 432x288 with 0 Axes>



![png](https://static.cyub.vip/images/202001/pandas.group.sum.png)



```python
df3.groupby('country')['score'].sum().plot(kind='bar')
```




    <matplotlib.axes._subplots.AxesSubplot at 0x7f040a967a90>




![png](https://static.cyub.vip/images/202001/pandas.group.column.sum.png)


### 分组后求平均值，最大值，最小值


```python
df3.groupby('country').agg({'score':['min','max','mean']})
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead tr th {        text-align: left;    }    .dataframe thead tr:last-of-type th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr><th></th><th colspan="3" halign="left">score</th></tr><tr><th></th><th>min</th><th>max</th><th>mean</th></tr><tr><th>country</th><th></th><th></th><th></th></tr></thead><tbody><tr><th>CN</th><td>62</td><td>88</td><td>72.333333</td></tr><tr><th>US</th><td>25</td><td>94</td><td>61.500000</td></tr></tbody></table></div>


```python
# 跟上面效果一致
df3.groupby('country')['score'].agg([np.min, np.max, np.mean])
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>amin</th><th>amax</th><th>mean</th></tr><tr><th>country</th><th></th><th></th><th></th></tr></thead><tbody><tr><th>CN</th><td>62</td><td>88</td><td>72.333333</td></tr><tr><th>US</th><td>25</td><td>94</td><td>61.500000</td></tr></tbody></table></div>



### 分组后不同列使用不同求值函数


```python
df3.groupby('country').agg({'score': ['max','min', 'std'],
                        'age': ['sum', 'count', 'max']})
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead tr th {        text-align: left;    }    .dataframe thead tr:last-of-type th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr><th></th><th colspan="3" halign="left">score</th><th colspan="3" halign="left">age</th></tr><tr><th></th><th>max</th><th>min</th><th>std</th><th>sum</th><th>count</th><th>max</th></tr><tr><th>country</th><th></th><th></th><th></th><th></th><th></th><th></th></tr></thead><tbody><tr><th>CN</th><td>88</td><td>62</td><td>13.796135</td><td>69</td><td>3</td><td>27</td></tr><tr><th>US</th><td>94</td><td>25</td><td>28.757608</td><td>111</td><td>4</td><td>36</td></tr></tbody></table></div>



### 多个分组结果拼接


```python
t1=df3.groupby('country')['score'].mean().to_frame()
t2 = df3.groupby('country')['age'].sum().to_frame()

t1.merge(t2,left_index=True,right_index=True)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>score</th><th>age</th></tr><tr><th>country</th><th></th><th></th></tr></thead><tbody><tr><th>CN</th><td>72.333333</td><td>69</td></tr><tr><th>US</th><td>61.500000</td><td>111</td></tr></tbody></table></div>



### 遍历分组


```python
grouped = df3.groupby('country')
for name,group in grouped:
    print(name)
    print(group)
```

    CN
       name  age gender  score country
    3  Jake   24      M     62      CN
    5  Jack   18      M     88      CN
    6   Tim   27      F     67      CN
    US
        name  age gender  score country
    0  Jason   20      F     25      US
    1  Molly   32      F     94      US
    2   Tina   36      F     57      US
    4    Amy   23      F     70      US



```python
grouped = df3.groupby(['country', 'gender'])
for name,group in grouped:
    print(name)
    print(group)
```

    ('CN', 'F')
      name  age gender  score country
    6  Tim   27      F     67      CN
    ('CN', 'M')
       name  age gender  score country
    3  Jake   24      M     62      CN
    5  Jack   18      M     88      CN
    ('US', 'F')
        name  age gender  score country
    0  Jason   20      F     25      US
    1  Molly   32      F     94      US
    2   Tina   36      F     57      US
    4    Amy   23      F     70      US


### 获取分组信息


```python
df3.groupby('country').groups
```




    {'CN': Int64Index([3, 5, 6], dtype='int64'),
     'US': Int64Index([0, 1, 2, 4], dtype='int64')}



### 取分组后的某一组


```python
df3.groupby('country').get_group('CN')
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr></tbody></table></div>



### 分组后过滤


```python
df3.groupby('name').filter(lambda x: len(x) >= 3)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody></tbody></table></div>


## 数据透视


```python
# 数据透视的值项只能是数值类型
# pivot(index =,columns=,values=)：透视数据
# index：透视的列（作为索引, 且值都是唯一的）; columns-用于进一步细分index；values查看具体值

df3.pivot(index ='name',columns='gender',values=['score','age'])
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead tr th {        text-align: left;    }    .dataframe thead tr:last-of-type th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr><th></th><th colspan="2" halign="left">score</th><th colspan="2" halign="left">age</th></tr><tr><th>gender</th><th>F</th><th>M</th><th>F</th><th>M</th></tr><tr><th>name</th><th></th><th></th><th></th><th></th></tr></thead><tbody><tr><th>Amy</th><td>70.0</td><td>NaN</td><td>23.0</td><td>NaN</td></tr><tr><th>Jack</th><td>NaN</td><td>88.0</td><td>NaN</td><td>18.0</td></tr><tr><th>Jake</th><td>NaN</td><td>62.0</td><td>NaN</td><td>24.0</td></tr><tr><th>Jason</th><td>25.0</td><td>NaN</td><td>20.0</td><td>NaN</td></tr><tr><th>Molly</th><td>94.0</td><td>NaN</td><td>32.0</td><td>NaN</td></tr><tr><th>Tim</th><td>67.0</td><td>NaN</td><td>27.0</td><td>NaN</td></tr><tr><th>Tina</th><td>57.0</td><td>NaN</td><td>36.0</td><td>NaN</td></tr></tbody></table></div>



```python
# pivot_table(index =,columns=,values=)：透视数据
# index：透视的列（作为索引, 且值都是唯一的）; columns-用于进一步细分index；values查看具体值；fill_value:0-用0替换Nan; margins:True-汇总

pd.pivot_table(df3,index=['country', 'gender'], values=['score'],aggfunc=np.sum)
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th></th><th>score</th></tr><tr><th>country</th><th>gender</th><th></th></tr></thead><tbody><tr><th rowspan="2" valign="top">CN</th><th>F</th><td>67</td></tr><tr><th>M</th><td>150</td></tr><tr><th>US</th><th>F</th><td>246</td></tr></tbody></table></div>




```python
pd.pivot_table(df3,index=['country', 'gender'], values=['score', 'age'],aggfunc=[np.sum, np.mean],fill_value=0,margins=True)
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead tr th {        text-align: left;    }    .dataframe thead tr:last-of-type th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr><th></th><th></th><th colspan="2" halign="left">sum</th><th colspan="2" halign="left">mean</th></tr><tr><th></th><th></th><th>age</th><th>score</th><th>age</th><th>score</th></tr><tr><th>country</th><th>gender</th><th></th><th></th><th></th><th></th></tr></thead><tbody><tr><th rowspan="2" valign="top">CN</th><th>F</th><td>27</td><td>67</td><td>27.000000</td><td>67.000000</td></tr><tr><th>M</th><td>42</td><td>150</td><td>21.000000</td><td>75.000000</td></tr><tr><th>US</th><th>F</th><td>111</td><td>246</td><td>27.750000</td><td>61.500000</td></tr><tr><th>All</th><th></th><td>180</td><td>463</td><td>25.714286</td><td>66.142857</td></tr></tbody></table></div>


```python
df3
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>name</th><th>age</th><th>gender</th><th>score</th><th>country</th></tr></thead><tbody><tr><th>0</th><td>Jason</td><td>20</td><td>F</td><td>25</td><td>US</td></tr><tr><th>1</th><td>Molly</td><td>32</td><td>F</td><td>94</td><td>US</td></tr><tr><th>2</th><td>Tina</td><td>36</td><td>F</td><td>57</td><td>US</td></tr><tr><th>3</th><td>Jake</td><td>24</td><td>M</td><td>62</td><td>CN</td></tr><tr><th>4</th><td>Amy</td><td>23</td><td>F</td><td>70</td><td>US</td></tr><tr><th>5</th><td>Jack</td><td>18</td><td>M</td><td>88</td><td>CN</td></tr><tr><th>6</th><td>Tim</td><td>27</td><td>F</td><td>67</td><td>CN</td></tr></tbody></table></div>



## 合并、连接、拼接（Merge, join, and concatenate）

### 拼接(concatenate)


```python
t1 = pd.DataFrame({'A': ['A0', 'A1', 'A2', 'A3'],
    'B': ['B0', 'B1', 'B2', 'B3'],
    'C': ['C0', 'C1', 'C2', 'C3'],
    'D': ['D0', 'D1', 'D2', 'D3']},
    index=[0, 1, 2, 3])
print('-----t1----')
print(t1)

t2 = pd.DataFrame({'A': ['A4', 'A5', 'A6', 'A7'],
    'B': ['B4', 'B5', 'B6', 'B7'],
    'C': ['C4', 'C5', 'C6', 'C7'],
    'D': ['D4', 'D5', 'D6', 'D7']},
    index=[4, 5, 6, 7])

print('----t2-----')
print(t2)

t3 = pd.DataFrame({'A': ['A8', 'A9', 'A10', 'A11'],
    'B': ['B8', 'B9', 'B10', 'B11'],
    'C': ['C8', 'C9', 'C10', 'C11'],
    'D': ['D8', 'D9', 'D10', 'D11']},
    index=[8, 9, 10, 11])

print('-----t3----')
print(t2)
frames = [t1, t2, t3]

pd.concat(frames)
```

    -----t1----
        A   B   C   D
    0  A0  B0  C0  D0
    1  A1  B1  C1  D1
    2  A2  B2  C2  D2
    3  A3  B3  C3  D3
    ----t2-----
        A   B   C   D
    4  A4  B4  C4  D4
    5  A5  B5  C5  D5
    6  A6  B6  C6  D6
    7  A7  B7  C7  D7
    -----t3----
        A   B   C   D
    4  A4  B4  C4  D4
    5  A5  B5  C5  D5
    6  A6  B6  C6  D6
    7  A7  B7  C7  D7



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td></tr><tr><th>1</th><td>A1</td><td>B1</td><td>C1</td><td>D1</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>C3</td><td>D3</td></tr><tr><th>4</th><td>A4</td><td>B4</td><td>C4</td><td>D4</td></tr><tr><th>5</th><td>A5</td><td>B5</td><td>C5</td><td>D5</td></tr><tr><th>6</th><td>A6</td><td>B6</td><td>C6</td><td>D6</td></tr><tr><th>7</th><td>A7</td><td>B7</td><td>C7</td><td>D7</td></tr><tr><th>8</th><td>A8</td><td>B8</td><td>C8</td><td>D8</td></tr><tr><th>9</th><td>A9</td><td>B9</td><td>C9</td><td>D9</td></tr><tr><th>10</th><td>A10</td><td>B10</td><td>C10</td><td>D10</td></tr><tr><th>11</th><td>A11</td><td>B11</td><td>C11</td><td>D11</td></tr></tbody></table></div>



```python
# concat类似：linux的split命令把文件分成多个，然后在拼接成一个完成文件

Image(url="http://static.cyub.vip/images/202001/pandas.concat.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.concat.png"/>




```python
t4 = pd.DataFrame({'B': ['B2', 'B3', 'B6', 'B7'],
    'D': ['D2', 'D3', 'D6', 'D7'],
    'F': ['F2', 'F3', 'F6', 'F7']},
    index=[2, 3, 6, 7])

print('-----t4----')

pd.concat([t1, t4], axis=1, sort=False) # 此时相当于out joiner
```

    -----t4----




<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th><th>B</th><th>D</th><th>F</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>1</th><td>A1</td><td>B1</td><td>C1</td><td>D1</td><td>NaN</td><td>NaN</td><td>NaN</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td><td>B2</td><td>D2</td><td>F2</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>C3</td><td>D3</td><td>B3</td><td>D3</td><td>F3</td></tr><tr><th>6</th><td>NaN</td><td>NaN</td><td>NaN</td><td>NaN</td><td>B6</td><td>D6</td><td>F6</td></tr><tr><th>7</th><td>NaN</td><td>NaN</td><td>NaN</td><td>NaN</td><td>B7</td><td>D7</td><td>F7</td></tr></tbody></table></div>




```python
Image(url="http://static.cyub.vip/images/202001/pandas.concat.outer_join.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.concat.outer_join.png"/>




```python
pd.concat([t1, t4], axis=1, join='inner')
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th><th>B</th><th>D</th><th>F</th></tr></thead><tbody><tr><th>2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td><td>B2</td><td>D2</td><td>F2</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>C3</td><td>D3</td><td>B3</td><td>D3</td><td>F3</td></tr></tbody></table></div>


```python
Image(url="http://static.cyub.vip/images/202001/pandas.concat.inner_join.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.concat.inner_join.png"/>




```python
t1.append([t2,t3]) # 相当于pd.concat([t1, t2, t3])
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td></tr><tr><th>1</th><td>A1</td><td>B1</td><td>C1</td><td>D1</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>C3</td><td>D3</td></tr><tr><th>4</th><td>A4</td><td>B4</td><td>C4</td><td>D4</td></tr><tr><th>5</th><td>A5</td><td>B5</td><td>C5</td><td>D5</td></tr><tr><th>6</th><td>A6</td><td>B6</td><td>C6</td><td>D6</td></tr><tr><th>7</th><td>A7</td><td>B7</td><td>C7</td><td>D7</td></tr><tr><th>8</th><td>A8</td><td>B8</td><td>C8</td><td>D8</td></tr><tr><th>9</th><td>A9</td><td>B9</td><td>C9</td><td>D9</td></tr><tr><th>10</th><td>A10</td><td>B10</td><td>C10</td><td>D10</td></tr><tr><th>11</th><td>A11</td><td>B11</td><td>C11</td><td>D11</td></tr></tbody></table></div>



### 连接（Join）

join(on=None, how='left', lsuffix='', rsuffix='', sort=False)

on:join的键，默认是矩阵的index, how:join方式，left-相当于左连接,outer,inner

更多查看[Database-style DataFrame or named Series joining/merging](https://pandas.pydata.org/pandas-docs/stable/user_guide/merging.html#database-style-dataframe-or-named-series-joining-merging)


```python
left = pd.DataFrame({'A': ['A0', 'A1', 'A2'],
   'B': ['B0', 'B1', 'B2']},
   index=['K0', 'K1', 'K2'])

print('----left----')
print(left)

right = pd.DataFrame({'C': ['C0', 'C2', 'C3'],
   'D': ['D0', 'D2', 'D3']},
   index=['K0', 'K2', 'K3'])
print('---right----')
print(right)

left.join(right) # 相当于 pd.merge(left, right, left_index=True, right_index=True, how='left')
```

    ----left----
         A   B
    K0  A0  B0
    K1  A1  B1
    K2  A2  B2
    ---right----
         C   D
    K0  C0  D0
    K2  C2  D2
    K3  C3  D3



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>K0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td></tr><tr><th>K1</th><td>A1</td><td>B1</td><td>NaN</td><td>NaN</td></tr><tr><th>K2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td></tr></tbody></table></div>




```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.left.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.join.left.png"/>




```python
left.join(right, how='outer') # 相当于pd.merge(left, right, left_index=True, right_index=True, how='outer')
```

<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>K0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td></tr><tr><th>K1</th><td>A1</td><td>B1</td><td>NaN</td><td>NaN</td></tr><tr><th>K2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td></tr><tr><th>K3</th><td>NaN</td><td>NaN</td><td>C3</td><td>D3</td></tr></tbody></table></div>


```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.outer.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.join.outer.png"/>




```python
left.join(right, how='inner') #相当于pd.merge(left, right, left_index=True, right_index=True, how='inner')
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>K0</th><td>A0</td><td>B0</td><td>C0</td><td>D0</td></tr><tr><th>K2</th><td>A2</td><td>B2</td><td>C2</td><td>D2</td></tr></tbody></table></div>




```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.inner.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.join.inner.png"/>



### 根据某一列进行join

left.join(right, on=key_or_keys)= pd.merge(left, right, left_on=key_or_keys, right_index=True,
      how='left', sort=False) // 使用left矩阵的key_or_keys列与right矩阵的index进行join


```python
left = pd.DataFrame({'A': ['A0', 'A1', 'A2', 'A3'],
    'B': ['B0', 'B1', 'B2', 'B3'],
     'key': ['K0', 'K1', 'K0', 'K1']})

print('----left----')
print(left)

right = pd.DataFrame({'C': ['C0', 'C1'],
    'D': ['D0', 'D1']},
    index=['K0', 'K1'])

print('----right----')
print(right)


left.join(right, on='key') # 相当于pd.merge(left, right, left_on='key', right_index=True,how='left', sort=False);
```

    ----left----
        A   B key
    0  A0  B0  K0
    1  A1  B1  K1
    2  A2  B2  K0
    3  A3  B3  K1
    ----right----
         C   D
    K0  C0  D0
    K1  C1  D1



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>key</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>K0</td><td>C0</td><td>D0</td></tr><tr><th>1</th><td>A1</td><td>B1</td><td>K1</td><td>C1</td><td>D1</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>K0</td><td>C0</td><td>D0</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>K1</td><td>C1</td><td>D1</td></tr></tbody></table></div>


```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.key.left.png")
```



<img src="http://static.cyub.vip/images/202001/pandas.join.key.left.png"/>




```python
#### 多列的join

left = pd.DataFrame({'A': ['A0', 'A1', 'A2', 'A3'],
    'B': ['B0', 'B1', 'B2', 'B3'],
   'key1': ['K0', 'K0', 'K1', 'K2'],
   'key2': ['K0', 'K1', 'K0', 'K1']})

print('----left----')
print(left)

index = pd.MultiIndex.from_tuples([('K0', 'K0'), ('K1', 'K0'),
    ('K2', 'K0'), ('K3', 'K11')])


right = pd.DataFrame({'C': ['C0', 'C1', 'C2', 'C3'],
    'D': ['D0', 'D1', 'D2', 'D3']},
    index=index)

print('----right----')
print(right)

left.join(right, on=['key1', 'key2'])
```

    ----left----
        A   B key1 key2
    0  A0  B0   K0   K0
    1  A1  B1   K0   K1
    2  A2  B2   K1   K0
    3  A3  B3   K2   K1
    ----right----
             C   D
    K0 K0   C0  D0
    K1 K0   C1  D1
    K2 K0   C2  D2
    K3 K11  C3  D3



<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>key1</th><th>key2</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>K0</td><td>K0</td><td>C0</td><td>D0</td></tr><tr><th>1</th><td>A1</td><td>B1</td><td>K0</td><td>K1</td><td>NaN</td><td>NaN</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>K1</td><td>K0</td><td>C1</td><td>D1</td></tr><tr><th>3</th><td>A3</td><td>B3</td><td>K2</td><td>K1</td><td>NaN</td><td>NaN</td></tr></tbody></table></div>



```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.keys.left.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.join.keys.left.png"/>




```python
left.join(right, on=['key1', 'key2'], how='inner')
```


<div><style scoped>    .dataframe tbody tr th:only-of-type {        vertical-align: middle;    }    .dataframe tbody tr th {        vertical-align: top;    }    .dataframe thead th {        text-align: right;    }</style><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>A</th><th>B</th><th>key1</th><th>key2</th><th>C</th><th>D</th></tr></thead><tbody><tr><th>0</th><td>A0</td><td>B0</td><td>K0</td><td>K0</td><td>C0</td><td>D0</td></tr><tr><th>2</th><td>A2</td><td>B2</td><td>K1</td><td>K0</td><td>C1</td><td>D1</td></tr></tbody></table></div>




```python
Image(url="http://static.cyub.vip/images/202001/pandas.join.keys.inner.png")
```




<img src="http://static.cyub.vip/images/202001/pandas.join.keys.inner.png"/>



## 数据导入导出

### 从csv中导入数据


```python
pd.read_csv('../dataset/game_daily_stats_20200127_20200202.csv', names=['id', '日期', '游戏id', '游戏名称', '国家', '国家码', '下载数', '下载用户数', '成功下载数', '成功下载用户数','安装数', '安装用户数'],na_filter = False)
```

<div><table border="1" class="dataframe"><thead><tr style="text-align: right;"><th></th><th>id</th><th>日期</th><th>游戏id</th><th>游戏名称</th><th>国家</th><th>国家码</th><th>下载数</th><th>下载用户数</th><th>成功下载数</th><th>成功下载用户数</th><th>安装数</th><th>安装用户数</th></tr></thead><tbody><tr><th>0</th><td>7564316</td><td>2020-01-27</td><td>1</td><td>Uphill Rush Water Park Racing</td><td>俄罗斯</td><td>RU</td><td>1</td><td>1</td><td>1</td><td>1</td><td>1</td><td>1</td></tr><tr><th>1</th><td>7564317</td><td>2020-01-27</td><td>1</td><td>Uphill Rush Water Park Racing</td><td>肯尼亚</td><td>KE</td><td>2</td><td>2</td><td>2</td><td>2</td><td>0</td><td>0</td></tr><tr><th>2</th><td>7564318</td><td>2020-01-27</td><td>1</td><td>Uphill Rush Water Park Racing</td><td>刚果金</td><td>CD</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td></tr><tr><th>3</th><td>7564319</td><td>2020-01-27</td><td>1</td><td>Uphill Rush Water Park Racing</td><td>尼泊尔</td><td>NP</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td></tr><tr><th>4</th><td>7564320</td><td>2020-01-27</td><td>1</td><td>Uphill Rush Water Park Racing</td><td>索马里</td><td>SO</td><td>1</td><td>1</td><td>1</td><td>1</td><td>1</td><td>1</td></tr><tr><th>...</th><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td><td>...</td></tr><tr><th>179886</th><td>8010481</td><td>2020-02-02</td><td>175</td><td>Soccer Star 2022 World Legend: Football game</td><td>赞比亚</td><td>ZM</td><td>2</td><td>2</td><td>0</td><td>0</td><td>0</td><td>0</td></tr><tr><th>179887</th><td>8010482</td><td>2020-02-02</td><td>175</td><td>Soccer Star 2022 World Legend: Football game</td><td>尼日利亚</td><td>NG</td><td>1</td><td>1</td><td>2</td><td>2</td><td>2</td><td>2</td></tr><tr><th>179888</th><td>8010483</td><td>2020-02-02</td><td>175</td><td>Soccer Star 2022 World Legend: Football game</td><td>埃及</td><td>EG</td><td>2</td><td>2</td><td>0</td><td>0</td><td>0</td><td>0</td></tr><tr><th>179889</th><td>8010484</td><td>2020-02-02</td><td>175</td><td>Soccer Star 2022 World Legend: Football game</td><td>科特迪瓦</td><td>CI</td><td>3</td><td>3</td><td>2</td><td>2</td><td>2</td><td>2</td></tr><tr><th>179890</th><td>8010485</td><td>2020-02-02</td><td>175</td><td>Soccer Star 2022 World Legend: Football game</td><td>约旦</td><td>JO</td><td>1</td><td>1</td><td>0</td><td>0</td><td>0</td><td>0</td></tr></tbody></table><p>179891 rows × 12 columns</p></div>



### 导出数据到csv


```python
df.to_csv('/tmp/pandas.csv', encoding="utf_8_sig")
```
