title: PHP项目中安全风险与防范
tags:
  - XSS
  - SQL注入
  - CSRF
categories:
  - 开发语言
date: 2018-06-28 20:54:00
---
在PHP开发中，由于编码bug或者配置不正确，如果被恶意利用往往会导致严重安全问题。根据[OWASP Top 10 2017](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project)里面的10大安全风险，现归纳总结了PHP项目中几种常见安全风险，攻击场景和防范措施。

## 1. 注入-Injection

- 一般指不受信任的数据被伪装成命令或者查询语句的一部分，发送至解析器后发生了执行的过程。
- 攻击者的恶意数据能够欺骗解释器在未被授权的情况下执行非预期代码或者访问数据。
- 常见注入类型有SQL、NoSQL、OS命令、XML等注入

### 案例场景

**例1.** 用户输入的数据直接用于SQL查询语句中
```sql
$sql = 'select * from news where id="' . $_GET['id']  . '"'
```
攻击方式：
```js
http://example.com/news?id=" or 1='1
```
<!--more-->
**例2.** OS命令注入

```php
exec("ping -c 4 " . $_GET['host'], $output);
echo "<pre>";m
print_r($output);
echo "</pre>";
```

攻击方式：
```php
www.google.com;ls -al
```

### 防范措施：
- 验证、消毒、转义任何用户输入的数据
```php
filter_var($address, FILTER_VALIDATE_EMAIL);
filter_var($dirtyAddress, FILTER_SANITIZE_EMAIL);
htmlspecialchars($goodName);
```
- 使用白名单机制
```php
$adminWhiteList = [
  'tink'
]
// 注意in_array第三个参数，设置为true
if (!in_array($_GET['uname'], $adminWhiteList, true)) {
  exit('forbidden')
}
```

- 使用escapeshellarg转义命令行参数
```php
// 当exec(), shell_exec(), passthru() ,system()接收参数时候使用escapeshellarg() and escapeshellcmd()进行转义处理
exec(escapeshellcmd("ping -c 4 " . $_GET['host']), $output);
exec(escapeshellcmd("ping -c 4 " . escapeshellarg($_GET['host'])), $output);
```
- 使用PDO预处理语句
```js
$sth = $dbh->prepare('SELECT name, colour, calories FROM fruit
    WHERE calories < ? AND colour = ?');
$sth->execute(array(150, 'red'));
// tip.使用预处理语句的另外一个好处?
```
- 查询语句中使用LIMIT，防止大面积泄露数据（手动更新数据库时候特别需要）
```sql
update user set amount = 100 where username='tink' limit 1
```

## 2. 敏感数据泄露-Sensitive-Data-Exposure

- 许多Web应用和API接口不重视敏感数据的保护，比如资金数据、健康数据和个人身份数据

- 攻击者可能窃取或者修改这些不设防的数据，用作信用卡诈骗、身份盗用或者其他犯罪行为

- 未特别保护的敏感数据容易遭到破坏，这些数据包括传输中的数据、存储的数据以及浏览器中的交互数据

### 案例场景

**例1.** 资金日历浏览器缓存信息

使用Http etag缓存机制缓存用户每日投资金额信息，由于没有区分用户导致信息泄露

**例2.** [电子发烧友敏感信息泄露导致139万用户信息危急(可进入任意用户)](http://wooyun.fbisb.com/bug_detail.php?wybug_id=wooyun-2013-043555)
 
### 防范措施
- 使用https进行数据传输
- 确保加密敏感数据
    - 不要使用base64加密
    - 不要使用mcrypt拓展，应该使用openssl拓展(具体原因参加后面拓展阅读)
- 使用加盐来处理密码
  ```php
  $salt = rand_string(6);
  $encryptedPwd = md5(md5($pwd) . $salt);
  或者
  $encryptedPwd = password_hash($pwd, PASSWORD_DEFAULT);
  ```

- 日志信息中的敏感信息需要脱敏
- 登录或者权限改变时候需要重新生成会话ID，在会话中中记录用户ip，当ip改变之后，让用户二次认证下
  ```php
  session_regenerate_id();
  ```
- 使用蜜罐策略防止恶意爬虫抓取
- 注意PHP弱类型特性


## 3. 安全配置错误-Security-Misconfiguration

- 一般是由于不安全的默认配置、不完全或临时的配置、开放的云存储、错误配置的 HTTP 头部以及多余的错误信息包含了敏感信息

### 案例场景
- 应用服务附带了未从服务中移除的应用程序样例。这些样例应用程序具有已知的安全漏洞，攻击者利用这些漏洞来攻击服务器。如果其中一个是管理员控制台，并且默认账户没有被更改，攻击者可以通过默认密码登录以及劫持服务。
- 服务器没有禁用目录列表。攻击者发现他们可以列出所有目录
- 应用程序服务器端的配置允许把详细的错误信息（例如堆栈跟踪）返回给用户。这可能会暴露敏感信息或者潜在的漏洞，例如已知含有漏洞组件的版本信息。

### 防范措施
- 项目的入口目录放在public目录下，且只有public才能够访问
- php.ini安全配置
  - 禁止暴露PHP版本信息
  ```ini
  expose_php = off
  ```
  - 禁止包含远程文件
  ```ini
  allow_url_include = 0
  ```
  - 禁止通过url传递会话ID
  ```ini
  session.use_trans_sid = 0
  ```
  - 设置会话cookie httponly flag
  ```ini
  session.cookie_httponly = On 
  // 只对会话cookie起作用，其他cookie不起作用
  ```
  - 禁止页面中显示错误信息
  ```ini
  display_errors = Off
  ```


## 4. 跨站脚本攻击-XSS

- Cross site scripting简称XSS
- 当在新的页面打开应用程序，如果包含了没有经过适当的验证或编码的不可信数据，或者使用可以创建 HTML 或 JavaScript 的浏览器 API更新现有的网页时，就可能会发生跨站脚本攻击。 XSS让攻击者能够在受害者的浏览器中执行脚本，并劫持用户会话、破坏网站或者将用户重定向至恶意站点。


### 案例场景

1. 应用程序使用不可信的数据，在没有验证和转义的情况下，渲染到页面中
```php
$content = "<img src='http://example.php/getcookie.php'/>"
```
2. 利用$_SERVER['PHP_SELF']特点攻击
```php
// a.php
echo '<a href="' . $_SERVER['PHP_SELF'] . '">表单提交地址</a>';

// 此时访问a.php+urlencode('/"><script>alert(\'c\')</script>"')

// 应该用$_SERVER['REQUEST_URI'],PHP_SELF会将url进行urldecode处理
```
  
3. [XSS姿势——文件上传XSS - XDANS' - 博客园](https://www.cnblogs.com/xdans/p/5412563.html)


### 防范措施
1. 转义处理
```php
htmlspecialchars($search, ENT_QUOTES, 'UTF-8');
strip_tags($search);
htmlentities($search, ENT_QUOTES, 'UTF-8');
```
2. 使用HTMLPurifier库处理
3. 禁止使用富媒体编辑器，改用markdown编辑器
4. 设置http安全响应头
    - X-Frame-Options - 不允许嵌入到其他网站
    - X-XSS-Protection - 防范XSS的
5. 正确处理文件上传时候，文件类型判断
```php
if ($_FILES['some_name']['type'] == 'image/jpeg') {  
  // 不可靠，可以伪造
}

// 可靠的方式
$finfo = new finfo(FILEINFO_MIME_TYPE);
$fileContents = file_get_contents($_FILES['some_name']['tmp_name']);
$mimeType = $finfo->buffer($fileContents);
```

## 5. 跨站请求伪造-CSRF

1. Cross-Site Request Forgery简称CSRF
2. 是一种通过伪装授权用户的请求来利用授信网站的恶意漏洞

### 案例场景

**例1** 某系统里面的文章点赞功能的是访问某个url,比如`http://bbs.elecfans.com/?act=click&articleid=100`
   1. 把这个链接发送被攻击的用户
   2. 第三方页面里面嵌套`<img src=url />`
   3. 第三方页面防止一个表单，表单action指向点赞url,模拟提交

### 防范措施
1. 验证Http Referer头
2. 表单令牌
```php
// laravel框架表单页面
{{ csrf_field() }}
```
3. cookie令牌，参见[网易云音乐](http://music.163.com/)



## 拓展阅读
- [浅谈PHP弱类型安全 | WooYun知识库](http://wooyun.jozxing.cc/static/drops/tips-4483.html)
- [PHP Security Cheat Sheet - OWASP](https://www.owasp.org/index.php/PHP_Security_Cheat_Sheet)
- [系统运维|一些安全相关的 HTTP 响应头](https://linux.cn/article-5847-1.html)
- [If You're Typing the Word MCRYPT Into Your PHP Code, You're Doing It Wrong - Paragon Initiative Enterprises Blog](https://paragonie.com/blog/2015/05/if-you-re-typing-word-mcrypt-into-your-code-you-re-doing-it-wrong)
