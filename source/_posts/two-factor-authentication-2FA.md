---
title: 什么是双因素身份认证(2FA)?
date: 2017-09-16 08:13:30
tags:
    - 2FA
    - tow-factor authentication
    - 双因素认证
---

英文原文:[two-factor authentication (2FA)](http://searchsecurity.techtarget.com/definition/two-factor-authentication)

Two-factor authentication (2FA), often referred to as two-step verification, is a security process in which the user provides two authentication factors to verify they are who they say they are.  2FA can be contrasted with single-factor authentication (SFA), a security process in which the user provides only one factor -- typically a password.

双因素身份认证(2FA)，经常被认为是两步骤认证(two-step verification)。它是一个安全处理措施，用户需要提供2个认证因素来证明他们的身份。2FA可以和单因素认证（single-factor authentication)进行一个对比，单因素认证只需要提供一个认证因素，典例的是密码认证
<!--more-->

Two-factor authentication provides an additional layer of security and makes it harder for attackers to gain access to a person's devices and online accounts, because knowing the victim's password alone is not enough to pass the authentication check. Two-factor authentication has long been used to control access to sensitive systems and data, and online services are increasingly introducing 2FA to prevent their users' data from being accessed by hackers who have stolen a password database or used phishing campaigns to obtain users' passwords.

双因素身份认证提供了一个额外的安全层，使得攻击者难以访问个人设备和在线帐户，因为仅知道受害者的密码不足以通过身份验证检查。双因素认证一直被用来控制访问敏感的系统和数据，越来越多地的在线服务使用2FA防止用户数据被存储了密码数据库或者通过钓鱼手段获取了用户密码的黑客访问

## What are authentication factors?
## 什么是认证因素？
The ways in which someone can be authenticated usually fall into three categories known as the factors of authentication, which include:

认证的方法通常分为三类，即认证因素，其中包括：

1. **Knowledge factors** -- something the user knows, such as a password, PIN or shared secret.

    **所知道的内容**——用户知道的东西，比如密码、PIN或共享秘钥。

2. **Possession factors** -- something the user has, such as an ID card, security token or a smartphone.

    **所拥有的物品**——用户拥有的东西，比如身份证、安全令牌或智能手机。

3. **Inherence factors**, more commonly called biometrics -- something the user is. These may be personal attributes mapped from physical characteristics, such as fingerprints, face and voice. It also includes behavioral biometrics, such as keystroke dynamics, gait or speech patterns.

    **所具备的特征**，通常称为生物识别技术。这些可能是从物理特征映射出来的个人属性，如指纹、面部和声音。它还包括行为生物识别，如击键动力学，步态或语音模式。

Systems with more demanding requirements for security may use location and time as fourth and fifth factors. For example, users may be required to authenticate from specific locations, or during specific time windows.

对安全要求更高的系统可能使用位置和时间作为第四和第五因素。例如，用户可能需要从特定位置或特定时间窗口进行身份验证

Multifactor authentication involves two or more independent credentials for more secure transactions.

多因素身份验证涉及两个或多个独立凭据，用于更安全的事务。

## Single-factor authentication vs. two-factor authentication
## 单因素身份认证与双因素身份认证比较
Using two factors from the same category doesn't constitute 2FA; for example, requiring a password and a shared secret is still considered single-factor authentication, as they both belong to the same authentication factor -- knowledge.

同一类别下的两个因素不构成2FA；例如，一个需要密码和共享秘钥的认证依然是单因素身份认证，因为他们都属于同一类认证要素——知识认证

As far as SFA services go, user ID and password are not the most secure. One problem with password-based authentication is it requires knowledge and diligence to create and remember strong passwords. Passwords require protection from many inside threats, like carelessly stored sticky notes with login credentials, old hard drives and social-engineering exploits. Passwords are also prey to external threats, such as hackers using brute-force, dictionary or rainbow table attacks.

就SFA服务而言，用户ID和密码不是最安全的。基于密码的身份认证的一个问题是它需要一定记忆力和技巧来创建一个强密码，并记住它。密码需要保护以免受许多内部威胁，例如不小心存储的带有登录凭据的便签，旧硬盘驱动器和社会工程漏洞。密码也是外部威胁的牺牲品，例如黑客使用暴力、字典或彩虹表攻击。

Given enough time and resources, an attacker can usually breach password-based security systems. Passwords have remained the most common form of SFA because of their low cost, ease of implementation and familiarity. Multiple challenge-response questions can provide more security, depending on how they are implemented, and stand-alone biometric verification methods can also provide a more secure method of single-factor authentication.

如果有足够的时间和资源，一名攻击者通常会攻破基于密码的安全系统。由于成本低、易于实现和足够了解，密码仍然是SPA(Single-factor authentication)最常用的形式。多个挑战响应问题可以提供更多的安全性，这取决于它们是如何实现的，而独立的生物身份验证方法也可以提供更安全的单因素身份验证方法。

## Types of two-factor authentication products
## 双因素身份认证产品的类型
There are many different devices and services for implementing 2FA -- from tokens, to RFID cards, to smartphone apps.

从令牌到RFID卡，再到智能手机应用，有许多种设备和服务实现了2FA

Two-factor authentication products can be divided into two parts: tokens that are given to users to use when logging in, and infrastructure or software that recognizes and authenticates access for users who are using their tokens correctly.

双因素认证产品可以分为两部分：登录时给用户使用的令牌，以及能正确识别和验证使用令牌的用户的基础架构或软件。

The authentication tokens may be physical devices, such as key fobs or smart cards, or they may exist in software as mobile or desktop apps that generate PIN codes for authentication.

认证令牌可以是诸如密钥卡或智能卡的物理设备，或者是可以生成用于认证的PIN码的移动或桌面应用的软件。


On the other side, organizations need to have some system in place to accept, process and allow -- or deny -- access to users authenticating with their tokens. This may be server software, a dedicated hardware server or provided as a service by a third-party vendor.

另一方面，组织需要有一些系统来接受，处理和授权或拒绝访问用他们的令牌进行身份验证的用户。这可以是服务器软件，专用硬件服务器，或由第三方供应商作为服务提供。

An important part of 2FA is being sure the authenticated user is given access to all resources the user is approved for -- and only those resources -- so one important function of 2FA is linking the authentication system with an organization's authentication data. Microsoft provides some of the infrastructure necessary for organizations to support 2FA in Windows 10 through Windows Hello, which can operate with Microsoft accounts, as well as authenticating users through Microsoft Active Directory (AD), Azure AD or with FIDO 2.0.

2FA的一个重要部分是确保用户只能访问被授权访问的的资源。因此2FA的一个重要功能是将身份验证系统与组织的身份验证数据相连接。Microsoft提供了一些组织所需的一些基础架构，可以通过Windows Hello（可以与Microsoft帐户一起运行）以及通过Microsoft Active Directory（AD），Azure AD或FIDO 2.0对用户进行身份验证来支持Windows 10中的2FA。

## How a typical 2FA hardware token works
## 典型的2FA令牌是怎么进行身份认证的？
There are all sorts of hardware tokens supporting various methods of authentication. One popular hardware token, YubiKey, is a small USB device that supports one-time passwords (OTP), public key encryption and authentication, and the Universal 2nd Factor protocol developed by the FIDO Alliance.

有各种各样的令牌硬件支持各种认证方式。YubiKey是一个流行的令牌硬件，它是支持一次性密码（OTP），公钥加密和认证以及FIDO联盟开发的the Universal 2nd Factor protocol。

When a user with a YubiKey wants to log into an online service that supports OTP, such as Gmail, GitHub or WordPress, they first insert their YubiKey into the USB port of their device, enter their password, click in the YubiKey field and touch the YubiKey button. The YubiKey generates an OTP and enters it in the field.

当用于YubiKey的用户想要登录支持OTP的在线服务（如Gmail，GitHub或WordPress）时，首先将其YubiKey插入设备的USB端口，输入密码，点击YubiKey字段，然后触摸YubiKey按钮。YubiKey将生成生成一个OTP并将其输入到相应表单里面。

The OTP is a 44-character, single-use password; the first 12 characters are a unique ID that identifies the security key registered with the account. The remaining 32 characters contain information that is encrypted using a key known only to the device and Yubico's servers, established during the initial account registration.

OTP是44位字符的一次性密码;前12个字符是唯一的ID，用于标识帐户中注册的安全密钥。其余32个字符包含使用仅在初始帐户注册期间建立的设备和Yubico服务器已知密钥进行加密的信息。

The OTP is sent from the online service to Yubico for authentication checking. Once the OTP is validated, the Yubico authentication server sends back a message confirming this is the right token for this user. The 2FA is complete. The user has provided two factors of authentication: Their password is the knowledge factor, and their YubiKey is the possession factor.

OTP从在线服务发送到Yubico进行认证检查。一旦OTP被验证，Yubico认证服务器发回一个消息，确认这是该用户的正确标记。 然后2FA验证完成。在这个人在过程中用户提供了两个认证因素：他们的密码是知识因素，他们的YubiKey是占有因素。

## Two-factor authentication for mobile authentication
## 双因素身份认证用于手机认证
Smartphones offer a variety of possibilities for 2FA, allowing companies to use what works best for them. Some devices have screens capable of recognizing fingerprints; a built-in camera can be used for facial recognition or iris scanning and the microphone can be used for voice recognition. Smartphones equipped with GPS can verify location as an additional factor. Voice or Short Message Service (SMS) may also be used as a channel for out-of-band authentication.

智能手机为2FA提供了多种可能性，允许公司使用最适合他们的功能。一些设备具有能识别指纹的屏幕;或内置相机可用于面部识别或虹膜扫描，或者麦克风可用于语音识别。配备GPS的智能手机可以将位置验证作为附加因素。语音或短消息服务（SMS）也可以用作带外认证的信道。

Apple iOS, Google Android, Windows 10 and BlackBerry OS 10 all have apps which support 2FA, allowing the phone itself to serve as the physical device to satisfy the possession factor.

Apple iOS，Google Android，Windows 10和BlackBerry OS 10都有支持2FA的应用程序，从而允许手机本身作为物理设备来充当占有因素。

Authenticator apps replace the need to obtain a verification code via text, voice call or email. For example, to access a website or web-based service that supports Google Authenticator, the user types in their username and password -- a knowledge factor. The user is then prompted to enter a six-digit number. Instead of having to wait a few seconds to receive a text message, Authenticator generates the number for them. These numbers change every 30 seconds and are different for every login. By entering the correct number, the user completes the user-verification process and proves possession of the correct device -- an ownership factor.

身份验证器应用程序可以替换通过文本，语音电话或电子邮件获取验证码的需要。例如，当用户访问支持Google Authenticator(Google身份验证器)的网站或基于web的服务时候，用户键入用户名和密码后——知识因素，然后提示用户输入六位数字验证码。 数字验证妈不需要通过等待几秒钟收到短信获得，而是Google Authenticator直接生成。这些数字每隔30秒更改一次，每次登录都不同。通过输入正确的验证码，用户完成用户验证过程并证明拥有正确的设备 - 所有权因素。

## Is two-factor authentication secure?
## 双因素身份认证是否安全
While two-factor authentication does improve security -- because the right to access no longer relies solely on the strength of a password -- two-factor authentication schemes are only as secure as their weakest component. For example, hardware tokens depend on the security of the issuer or manufacturer, and one of the most high-profile cases of a compromised two-factor system occurred in 2011, when security company RSA Security reported its SecurID authentication tokens had been hacked.

虽然双因素身份验证确实提高了安全性 - 因为访问权不再仅仅依靠密码的强度 - 双因素身份验证方案与其最弱的组件一样安全。例如，硬件令牌取决于发行者或制造商的安全性，而2011年安全公司RSA的安全报告指出其SecurID身份验证令牌已被黑客入侵时，这是双因素身份认证系统受损最严重的案例之一。

The account-recovery process itself can also be subverted when it is used to defeat two-factor authentication, because it often resets a user's current password and emails a temporary password to allow the user to log in again, bypassing the 2FA process. The business Gmail accounts of the chief executive of Cloudflare were hacked in this way.

帐户恢复过程本身也可以被用来破坏双因素身份验证，因为它经常重置用户的当前密码，并发送临时密码以允许用户重新登录，来绕过2FA进程。 Cloudflare首席执行官的Gmail帐户曾遭到此类黑客入侵。

Although SMS-based 2FA is inexpensive, easy to implement and considered user-friendly, it is vulnerable to numerous attacks. In fact, the National Institute of Standards and Technology (NIST) deprecated use of SMS in 2FA services, in Special Publication 800-63-3: Digital Authentication Guidelines. NIST concluded one-time passwords sent via SMS are too vulnerable due to mobile phone number portability, attacks like the Signaling System 7 hack against the mobile phone network, and malware like Eurograbber that can intercept or redirect text messages.

虽然基于SMS的2FA价格便宜，易于实施且用户体验好，但它容易受到许多攻击。事实上，美国国家标准与技术研究所（NIST）在特别出版物800-63-3：数字认证指南中，弃用了2FA服务中的SMS。 NIST最终得出结论：通过短信发送的一次性密码的安全性太脆弱。这是由于一方面手机号码变更太不可靠，还有就是Signaling System 7等对手机网络的攻击，以及像Eurograbber等恶意软件可能拦截或重定向SMS消息。

## Higher levels of authentication for more secure communications
## 更高级别的身份验证，以提高安全性
Most attacks originate from remote internet connections, so 2FA makes these attacks less threatening, because obtaining passwords is not sufficient for access, and it is unlikely an attacker would also be able to obtain the second authentication factor associated with a user account.

大多数攻击来自远程互联网连接，所以2FA使这些攻击的威胁更小，因为单靠密码不足以拥有访问权，攻击者也不可能获得与用户帐户相关的第二个身份验证因素。

However, attackers sometimes break an authentication factor in the physical world. A persistent search of the target premises, for example, might yield an employee ID and password in the trash, or in carelessly discarded storage devices containing password databases. If additional factors are required for authentication, however, the attacker would face at least one more obstacle. Because the factors are independent, compromise of one should not lead to the compromise of others.

然而攻击者有时会破坏物理世界中的认证因素。例如，对目标场所的持续搜索可能会在垃圾篓中或者粗心丢弃的包含密码数据库的存储设备发现员工账号和密码。但是如果需要额外的身份验证，则攻击者至少会面临另外一重障碍，因为这些因素是相互独立的，一方面妥协不意味着其他方面的妥协。


This is why some high-security environments require three-factor authentication, which typically involves possession of a physical token and a password used in conjunction with biometric data, such as fingerprint scans or voiceprints. Factors such as geolocation, type of device and time of day are also being used to help determine whether a user should be authenticated or blocked. Additionally, behavioral biometric identifiers, like a user's keystroke length, typing speed and mouse movements, can be discreetly monitored in real time to provide continuous authentication, instead of a single one-off authentication check during login.

这就是为什么一些高安全性环境需要三因素身份验证，这通常涉及拥有物理令牌和与生物特征数据（如指纹扫描或声纹纹理）结合使用的密码。位置信息，设备类型和时间等因素也被用于帮助决定用户是否应该认证通过或锁住账号。此外可以实时谨慎地监视生物特征行为，比如用户的按键长度，打字速度和鼠标移动，以提供连续的身份验证，而不是登录期间的一次性身份验证检查。