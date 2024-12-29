title: 【翻译】SSL和SSL证书初学者指南
author: tink
tags:
  - SSL
  - SSL证书
  - CA
  - TLS
categories:
  - 翻译
date: 2024-01-04 21:42:00
---
**原文：** [SSL and SSL Certificates Explained For Beginners](www.steves-internet-guide.com/ssl-certificaates-explained/)

**安全套接字层 (SSL，全称Secure Sockets Layer)** 和**传输层安全 (TLS，全称Transport Layer security)** 是通过计算机网络或链接提供安全通信的协议。它们通常用于网页浏览和电子邮件。在本教程中，我们将了解学习到：
- TLS 和 SSL
- 公钥和私钥
- 为什么我们需要证书以及它们的作用
- 如何获取数字证书并了解不同的常见证书类型

## 什么是 TLS?

TLS 基于 SSL，并作为替代方案而开发以应对 SSLv3 中的已知漏洞。SSL 是常用术语，我们说的 SSL 通常指的就是 TLS。

## SSL/TLS 提供安全保障

SSL/TLS 提供数据加密、数据完整性和身份验证功能。这意味着当使用 SSL/TLS 时，你可以确保：

- 没有人读过你的消息
- 没有人篡改过你的消息
- 你正在与预期的人（服务器）通信

在两方之间发送消息时，你需要解决两个问题。
- 你怎么知道没有人读过这条消息？
- 你怎么知道没有人篡改过该消息？

这些问题的解决办法是：
- **对其进行加密(Encrypt it)** ： 这会使内容无法读取，因此对于查看该消息的任何人来说，它只是乱码。
- **签名(Sign it)** ： 这可以让收件人确信是你发送的邮件，并且邮件未被篡改。

这两个过程都需要使用密钥。这些密钥只是数字（常见的是 128 位），然后使用特定方法（通常称为算法）与消息组合，例如RSA，对消息进行加密或签名。

<!--more-->

## 对称密钥以及公钥私钥

当今使用的几乎所有加密方法都使用公钥和私钥。这些被认为比旧的对称密钥布置安全得多。

使用对称密钥时，使用一个密钥对消息进行加密或签名，并使用同一密钥对消息进行解密这和我们日常生活中接触到的钥匙（门、车钥匙）是一样的。这种钥匙布置的问题是，如果你丢失了钥匙，任何找到它的人都可以打开你的门。

对于公钥和私钥，使用两个在数学上相关的密钥（它们属于密钥对），但又不同。
这意味着用公钥加密的消息不能用相同的公钥解密。

要解密消息，你需要私钥。如果你的汽车使用了这种类型的钥匙布置。然后你可以锁车，并将钥匙留在锁中，因为同一把钥匙无法解锁汽车。

这种类型的密钥排列非常安全，并且用于所有现代加密/签名系统。

## 密钥和 SSL 证书

SSL/TLS 使用公钥和私钥系统进行数据加密和数据完整性。公钥可以提供给任何人，因此称为“公钥”。

正应为公钥提供给任何人，因此存在信任问题，具体来说：你如何知道特定的公钥属于它声称的个人/实体。例如，你收到一把声称属于你的银行的钥匙。

你怎么知道它确实属于你的银行？答案是使用**数字证书(digital certificate)**。

证书的用途与日常生活中的护照相同。护照在照片和个人之间建立了链接，并且该链接已由受信任的机构（护照办公室）验证。

数字证书提供公钥和实体（企业、域名等）之间的链接，该实体已由受信任的第三方（证书颁发机构）验证（签名）。数字证书提供了一种分发可信公共加密密钥的便捷方法。

## 如何获取数字证书？

你从公认的 **证书颁发机构 (CA，全称 Certificate authority)** 获得数字证书。就像你从护照办公室领取护照一样，事实上，两者过程非常相似。

首先你需要填写适当的表格，添加你的公钥（它们只是数字）并将其发送给 **证书颁发机构(Issuing Certificate authority)** 。 这个过程叫做**证书请求(certificate Request)**。

接着证书颁发机构会进行一些检查（取决于颁发机构），然后将证书中包含的密钥发回给你。

由于证书是由颁发证书的机构进行了签名，这保证了密钥安全性。现在，当有人想要你的公钥时，你向他们发送证书，他们验证证书上的签名，如果验证通过，那么他们就可以信任你的密钥。

## 数字证书用法示例

为了说明这一点，我们将查看使用SSL（https）的典型Web浏览器和Web服务器之间的连接。此连接用于在互联网上通过 Gmail 等发送电子邮件以及进行网上银行、购物等。

- 浏览器使用 SSL (https) 连接到服务器
- 服务器使用包含 Web 服务器公钥的服务器证书进行响应。
- 浏览器通过检查 CA 的签名来验证证书。为此，CA 证书需要位于浏览器的受信任存储中（请参阅下文）
- 浏览器使用此公钥与服务器商定会话密钥。
- Web 浏览器和服务器使用会话密钥通过连接加密数据。

这是一个视频，更详细地介绍了上述内容：

<iframe width="794" height="608" src="https://www.youtube.com/embed/iQsKdtjwtYI" title="How SSL works tutorial - with HTTPS example" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## 数字证书类型

如果你尝试为网站购买证书或用于加密 MQTT，你将遇到两种主要类型：
- 域验证证书 (DVC，全称Domain Validated Certificates)
- 扩展验证证书 (EVC，全称Extended validation Certificates)

两种类型的区别在于对证书的信任程度，EVC它具有更严格的验证，不过他们提供的加密级别是相同的。

域验证证书（DV）是X.509数字证书，通常用于传输层安全性（TLS），其中通过证明对DNS域的某些控制来验证申请人的身份。

DV验证过程通常是完全自动化的，这使得它们成为最便宜的证书形式。它们非常适合在像本网站这样提供内容的网站上使用，而不是用于敏感数据。

扩展验证证书 (EV) 是用于 HTTPS 网站和软件的证书，用于证明控制网站或软件包的法人实体。获取 EV 证书需要证书颁发机构 (CA) 验证请求实体的身份。它们通常比域验证证书更昂贵，因为它们涉及手动验证。

## 数字证书使用限制 - 通配符和 SAN

通常，证书可在单个 **完全限定域名 (FQDN)** 上使用。也就是说，为在 www.mydomain.com 上使用而购买的证书不能在 mail.mydomain.com 或 www.otherdomain.com 上使用。但是，如果你需要保护多个子域以及主域名，那么你可以购买通配符证书。通配符证书涵盖特定域名下的所有子域。

例如，*.mydomain.com 的通配符证书可用于：
- mail.mydomain.com
- www.mydomain.com
- ftp.mydomain.com
- 等等

它不能用于保护 mydomain.com 和 myotherdomain.com。

要在单个证书中涵盖多个不同的域名，你必须购买具有 **SAN（Subject Alternative Name）** 的证书。
除了主域名之外，这些域名通常允许你获得 4 个额外的域名。例如，你可以在以下位置使用相同的证书：

- www.mydomain.com
- www.mydomain.org
- www.mydomain.net
- www.mydomain.co
- www.mydomain.co.uk

你还可以更改所涵盖的域名，但需要重新颁发证书。

## 为什么要使用商业证书？

使用免费软件工具可以非常轻松地创建你自己的 SSL 证书和加密密钥。这些密钥和证书与商业密钥和证书一样安全，并且在大多数情况下可以被认为更安全。

当你的证书需要广泛支持时，商业证书是必要的。这是因为大多数 Web 浏览器和操作系统都内置了对主要商业证书颁发机构的支持。

如果你访问此站点时我在该站点上安装了自己生成的证书，你将看到一条类似下面的消息，告诉你该站点不受信任。

![](https://static.cyub.vip/images/202401/ssl-own-cert-error-browser.jpg)


## 数字证书的编码与扩展名

证书可以编码为：
- 二进制文件 (.DER)
- base64格式文本文件 (.PEM)

数字证书使用的常见文件扩展名是：
- DER
- PEM（隐私增强型电子邮件）
- CRT
- CERT

**注意：** 文件扩展名和编码之间没有真正的关联。这意味着 .crt 文件可以是 .der 编码文件或 .pem 编码文件。

我如何知道你是否有 .der 或 .pem 编码文件？

你可以使用 openssl 工具查找编码类型并在编码之间进行转换。请参阅本教程 – [DER 与 CRT 与 CER 与 PEM 证书](https://www.rickyadams.com/wp/index.php/2017/10/10/der-vs-crt-vs-cer-vs-pem-certificates-and-how-to-convert-them/)。你还可以打开该文件，如果它是 ASCII 文本，那么它是 .PEM 编码的证书

## 数字证书内容示例

由于 .pem 编码的证书是 ASCII 文件，因此可以使用简单的文本编辑器读取它们。

![](https://static.cyub.vip/images/202401/pem-certificate-example.jpg)

需要注意的重要一点是，它们以“Begin Certificate”和“ End Certificate ”行开始和结束。证书可以存储在自己的文件中，也可以一起存储在称为捆绑(bundle)包的单个文件中。

## 根 CA 捆绑包和哈希证书

尽管根证书作为单个文件存在，但它们也可以组合成一个包(bundle)。
在基于 Debian 的 Linux 系统上，这些根证书与名为 **ca-certificates.crt** 的文件一起存储在 **/etc/ssl/certs** 文件夹中。该文件是系统上所有根证书的捆绑包。它由系统创建，如果使用 [update-ca-certificates](http://manpages.ubuntu.com/manpages/bionic/man8/update-ca-certificates.8.html) 命令添加新证书，则可以更新它。

**ca-certifcates.crt** 文件内容格式如下所示:

![](https://static.cyub.vip/images/202401/combined-cert-file.jpg)

certs 文件夹还包含每个单独的证书或证书的符号链接以及哈希值。
哈希文件由 [c_rehash](https://www.openssl.org/docs/man1.0.2/apps/c_rehash.html) 命令创建，并在指定目录而不是文件时使用。例如，[mosquitto_pub](http://www.steves-internet-guide.com/mosquitto_pub-sub-clients/) 工具可以运行为：

```shell
mosquitto_pub --cafile /etc/ssl/certs/ca-certificates.crt

or

mosquitto_pub --capath /etc/ssl/certs/
```

## 根证书、中间证书以及证书链和捆绑包

证书颁发机构可以创建负责向客户端颁发证书的从属证书颁发机构。

![](https://static.cyub.vip/images/202401/certificate-chain.jpg)

对于要验证证书真实性的客户端，它需要能够验证链中所有 CA 的签名，这意味着客户端需要访问链中所有 CA 的证书。客户端可能已经安装了根证书，但可能还没有安装中间 CA 的证书。

![](https://static.cyub.vip/images/202401/cetificate-bundle-rfc.jpg)

因此，证书通常作为 **证书包(certificate bundle)** 的一部分提供。该捆绑包将包含单个文件中链中的所有 CA 证书，通常称为 **CA-Bundle.crt**。如果你的证书是单独发送的，你可以创建自己的捆绑包。

## 相关视频

- 这是[我的视频](https://youtu.be/cLnMr2OuXFI)，涵盖了上述几点。
- 这是我找到的一个[微软视频](https://youtu.be/LRMBZhdFjDI)，解释了上述内容。

## 故障排除

如果你遇到证书链问题，那么[此站点](https://whatsmychaincert.com/)有一个测试工具，并提供有关如何解决问题的详细信息

## 常见问题及解答

**Q**: 什么是值得信赖的商店？

**A**: 这是你信任的 CA 证书的列表。所有网络浏览器都带有受信任的 CA 列表。

**Q**: 我可以将自己的 CA 添加到浏览器信任存储中吗？

**A**: 是的，在 Windows 上，如果右键单击证书，你应该会看到一个安装选项
![](https://static.cyub.vip/images/202401/install-certificate-windows.jpg)

**Q**: 什么是**自签名证书(self signed certificate)**？

**A**: 自签名证书是由证书验证的同一实体签署的证书。这就像你批准自己的护照申请一样。参见[维基百科](https://en.wikipedia.org/wiki/Self-signed_certificate)。

**Q**: 什么是**证书指纹(certificate fingerprint)**？

**A**: 它是实际证书的哈希值，可用于验证证书，而无需安装 CA 证书。这对于没有大量内存来存储 CA 文件的小型设备非常有用。手动验证证书时也会使用它。请参阅[此处](https://www.ghacks.net/2013/07/27/use-fingerprints-to-determine-the-authenticity-of-an-internet-website/)了解更多详情。

**Q**: 如果服务器证书被盗，会发生什么情况？

**A**: 可以撤销。客户端（浏览器）可以通过多种方式检查证书是否被吊销，请参阅[此处](https://medium.com/@alexeysamoshkin/how-ssl-certificate-revocation-is-broken-in-practice-af3b63b9cb3)。