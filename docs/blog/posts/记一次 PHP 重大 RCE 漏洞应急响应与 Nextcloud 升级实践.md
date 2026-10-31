---
title: 记一次 PHP 重大 RCE 漏洞应急响应与 Nextcloud 升级实践
authors:
  - Tinker
tags:
  - RCE 漏洞
  - Nextcloud
categories:
  - 工程实践与运维
date: 2026-10-31 14:52:00
---

> 2026 年 10 月，PHP 官方紧急披露了两个可导致未认证远程代码执行（RCE）的严重漏洞。本文记录了笔者在一台运行 Nextcloud 的生产服务器上，从漏洞发现、风险评估，到 PHP 升级、Nextcloud 跨大版本迁移，再到数据落盘的完整过程。



## 背景：两个「9.2 分」的致命漏洞

### 漏洞披露

2026 年 10 月 21 日，PHP 官方发布紧急安全公告，披露了两个 **CVSS v4.0 评分 9.2**（Critical）的远程代码执行漏洞：

| CVE 编号 | 漏洞类型 | 危害 |
|----------|----------|------|
| **CVE-2026-109618** | Use-After-Free（OOM 处理内存未完全初始化）| 未认证 RCE |
| **CVE-2026-109619** | Use-After-Free（陈旧全局状态）| 未认证 RCE |

这两个漏洞的共同特点是：**攻击者无需任何身份认证**，只需构造恶意 HTTP 请求即可在受影响服务器上执行任意代码。更严峻的是，多个国家级安全机构（CNVD、JPCERT、TWCERT、GovCERT.HK）几乎同时发出警报，并确认**漏洞 PoC 已公开且被野外积极利用**。

!!! danger "风险等级"

    两个漏洞均为 **Critical（严重）** 级别，CVSS v4.0 评分 9.2 分，且已被野外利用。**所有通过 Web 提供服务的 PHP 部署均受影响。**

<!-- more -->

### 受影响范围

几乎所有通过 Web 提供服务的 PHP 部署方式均受影响：

- PHP-FPM（FastCGI）
- Apache + mod_php
- php-cgi
- FrankenPHP、LiteSpeed 等

官方修复版本为：

| 分支 | 修复版本 |
|------|---------|
| PHP 8.2 | **8.2.35** |
| PHP 8.3 | **8.3.36** |
| PHP 8.4 | **8.4.27** |
| PHP 8.5 | **8.5.12** |

### 本文服务器的现状

| 项目 | 版本 | 风险 |
|------|------|------|
| 操作系统 | Ubuntu 22.04.2 LTS | - |
| PHP | **8.1.2**（EOL，官方已停止支持）| 🔴 高危 |
| Nextcloud | **26.0.0**（2023 年 3 月发布）| 🔴 严重落后 |
| Web 服务器 | nginx 1.18.0 | - |
| 数据库 | MySQL 8.0.46 | - |

!!! warning "关键问题"

    PHP 8.1 已经 **EOL（End of Life）**，官方明确表示「不再为 8.1 发布修复版本」。虽然 Ubuntu 作为 LTS 发行版会提供 backport 补丁，但多个权威机构仍建议**升级到受支持的 PHP 版本**以彻底消除风险。


## 应急响应：立即停服

在确认漏洞的严重性后，第一步是**立即停止 PHP 服务**，阻断潜在的攻击面：

```bash
systemctl stop php8.1-fpm
```

这一步虽然会导致 Nextcloud 暂时不可用，但在「可用性」与「安全性」之间，面对正在被野外利用的 RCE 漏洞，**安全永远优先**。


## 备份：升级前的安全网

在动任何东西之前，完整的备份是必须的。本次备份了三类数据：

```bash
# 1. 备份数据库
mysqldump -u root -p'***' nextcloud > /data/nextcloud-backup/nextcloud-db-$(date +%F).sql

# 2. 备份配置文件
cp /var/www/nextcloud/config/config.php /data/nextcloud-backup/config.php.bak

# 3. 备份数据目录（用户文件，1.7G，压缩后 1.4G）
tar czf /data/nextcloud-backup/nextcloud-data-$(date +%F).tar.gz \
    -C /var/www/nextcloud data
```

!!! tip "经验"

    备份一定要放在**不同的物理磁盘**上。本次系统盘只剩 2.7G，而数据目录就有 1.7G，得益于外挂了一块 40G 的数据盘 `/data`，备份才得以安全存放。



## PHP 升级：8.1 → 8.5

### 为什么要升级到 8.5 而非 8.2

虽然官方修复版本覆盖 8.2~8.5，但考虑到：

1. **PHP 8.5 是最新的稳定版**，获得最长的官方支持周期
2. **Nextcloud 35 明确推荐 PHP 8.5**
3. 避免「刚升级完又接近 EOL」的尴尬

因此目标定为 **PHP 8.5.12**。

### Ubuntu 官方源没有 PHP 8.5

Ubuntu 22.04 官方源只提供 PHP 8.1，要安装 8.5 必须引入第三方 PPA。这里采用了社区广泛使用的 **ondrej/php** PPA：

```bash
# 添加 PPA
add-apt-repository -y ppa:ondrej/php
apt-get update

# 安装 PHP 8.5 及 Nextcloud 所需扩展
apt-get install -y \
  php8.5-fpm php8.5-cli php8.5-common \
  php8.5-mysql php8.5-gd php8.5-xml php8.5-curl \
  php8.5-mbstring php8.5-zip php8.5-intl \
  php8.5-bz2 php8.5-bcmath php8.5-gmp \
  php8.5-apcu php8.5-imagick php8.5-redis \
  php8.5-ldap php8.5-smbclient php8.5-xmlreader
```

!!! note "注意"

    PHP 8.5 中 `opcache` 和 `fileinfo` 已内置，无需单独安装。

### 切换 nginx 到 PHP 8.5

修改 nginx 站点配置中的 FastCGI 转发目标：

```nginx
# 修改 /etc/nginx/sites-available/cloud.example.com
fastcgi_pass unix:/run/php/php8.5-fpm.sock;  # 原为 php8.1-fpm.sock
```

然后重启服务：

```bash
systemctl start php8.5-fpm
systemctl stop php8.1-fpm
systemctl disable php8.1-fpm
systemctl restart nginx
```


## Nextcloud 升级：26 → 35（跨 9 个大版本）

### 升级策略：重新安装 vs 逐版本升级

面对 Nextcloud 26 → 35 的巨大跨度，有两条路：

1. **逐版本升级**：26→27→28→...→35，每个大版本跑一次 `occ upgrade`
2. **重新安装**：下载最新版代码，指向原数据库和数据目录

最初尝试「重新安装」——但执行 `occ upgrade` 时，Nextcloud 直接拒绝：

```
Exception: Updates between multiple major versions and downgrades are unsupported.
```

!!! failure "结论"

    **Nextcloud 强制要求逐版本升级，不能跨多个大版本。** 因此只能采用策略 1。

### 升级路径规划

Nextcloud 官方规则：**每次最多升一个大版本**，且必须升到该大版本的最新补丁版。

规划的完整路径：

```text
26.0.13 → 27.1.11 → 28.0.14 → 29.0.16 → 30.0.17
        → 31.0.14 → 32.0.15 → 33.0.10 → 34.0.5 → 35.0.2
```

### 关键坑点：PHP 版本兼容性

这是本次升级中**最隐蔽的坑**。不同版本的 Nextcloud 对 PHP 版本有硬性限制：

| Nextcloud 版本 | 支持的 PHP 版本上限 |
|---------------|-------------------|
| 27 | < 8.3 |
| 28 | 8.0 - 8.3 |
| 29 | 8.1 - 8.3 |
| 30 | 8.1 - 8.4 |
| 31 | 8.1 - 8.4（**不支持 8.5**）|
| 32 | 8.1 - 8.4（**不支持 8.5**）|
| 33 | 8.2 - 8.5 ✅ |
| 34 | 8.2 - 8.5 ✅ |
| 35 | 8.3 - 8.5 ✅ |

!!! bug "矛盾点"

    我们已升级到 PHP 8.5，但 Nextcloud 27~32 的 `occ` 命令在 PHP 8.5 下会直接报错：

    ```
    This version of Nextcloud is not compatible with PHP>=8.5.
    You are currently running 8.5.12.
    ```

**解决方案**：同时安装 PHP 8.2（仅 CLI，无需 fpm），升级中间版本时用 `php8.2` 执行 `occ`：

```bash
# 升级 27~32 时
sudo -u www-data php8.2 occ upgrade

# 升级 33~35 时（已支持 8.5）
sudo -u www-data php8.5 occ upgrade
```

这保证了网站全程使用 PHP 8.5 的 fpm，而 CLI 升级过程根据版本灵活切换。

### 自动化升级脚本

为了减少重复操作，编写了自动化脚本。完整脚本如下，**请根据实际情况修改版本号和 PHP 路径**：

```bash
#!/bin/bash
# Nextcloud 逐版本升级脚本：26 -> 35（自动切换 PHP 版本）
# 27-32 用 PHP 8.2，33-35 用 PHP 8.5
# 用法：bash upgrade-nextcloud.sh
set -euo pipefail

NC_DIR="/var/www/nextcloud"
BACKUP_DIR="/data/nextcloud-backup"
DOWNLOAD_BASE="https://download.nextcloud.com/server/releases"

# 升级路径：版本 及 对应的 PHP 二进制
# 注意：27-32 不支持 PHP 8.5，需用 8.2
UPGRADES=(
  "27.1.11|php8.2"
  "28.0.14|php8.2"
  "29.0.16|php8.2"
  "30.0.17|php8.2"
  "31.0.14|php8.2"
  "32.0.15|php8.2"
  "33.0.10|php8.5"
  "34.0.5|php8.5"
  "35.0.2|php8.5"
)

echo "=============================================="
echo "Nextcloud 逐版本升级：26 -> 35"
echo "=============================================="

for entry in "${UPGRADES[@]}"; do
  ver="${entry%%|*}"
  phpbin="${entry##*|}"
  echo ""
  echo "########## 升级到 Nextcloud $ver (使用 $phpbin) ##########"

  # 下载
  ZIP="/data/nextcloud-backup/nextcloud-${ver}.zip"
  if [ ! -f "$ZIP" ]; then
    echo "[$ver] 下载..."
    curl -sL --max-time 300 "${DOWNLOAD_BASE}/nextcloud-${ver}.zip" -o "$ZIP"
    echo "[$ver] 下载完成: $(du -h "$ZIP" | cut -f1)"
  else
    echo "[$ver] 已存在，跳过下载"
  fi

  # 解压到临时目录
  TMP="/tmp/nc-upgrade-${ver}"
  rm -rf "$TMP"
  mkdir -p "$TMP"
  echo "[$ver] 解压..."
  unzip -q "$ZIP" -d "$TMP"

  # 临时移出 config 和 data（这是最干净的方式，避免残留）
  echo "[$ver] 移出 config 和 data..."
  mv "$NC_DIR/config" "/tmp/nc-config-${ver}"
  mv "$NC_DIR/data" "/tmp/nc-data-${ver}"

  # 删除旧代码，放入新代码
  echo "[$ver] 替换代码目录..."
  rm -rf "$NC_DIR"
  mv "$TMP/nextcloud" "$NC_DIR"

  # 恢复 config 和 data
  echo "[$ver] 恢复 config 和 data..."
  rm -rf "$NC_DIR/config"
  mv "/tmp/nc-config-${ver}" "$NC_DIR/config"
  mv "/tmp/nc-data-${ver}" "$NC_DIR/data"

  # 权限
  chown -R www-data:www-data "$NC_DIR"

  # 确认版本
  VER_IN_CODE=$(grep -oP "OC_VersionString = '\K[^']+" "$NC_DIR/version.php")
  echo "[$ver] 代码版本：$VER_IN_CODE（PHP: $($phpbin -v | head -1 | grep -oP 'PHP \K[0-9.]+')）"

  # 执行升级
  echo "[$ver] 执行 occ upgrade..."
  cd "$NC_DIR"
  sudo -u www-data $phpbin occ maintenance:mode --off 2>&1 | tail -2 || true
  sudo -u www-data $phpbin occ upgrade --no-interaction 2>&1 | tail -30 || {
    echo "[$ver] ❌ 升级失败！"
    echo "config.php 和 data 已保留在 $NC_DIR"
    echo "请检查日志后重试。"
    exit 1
  }

  echo "[$ver] ✅ 升级成功"
  rm -rf "$TMP"
done

echo ""
echo "=============================================="
echo "全部升级完成！当前版本："
cd "$NC_DIR"
sudo -u www-data php8.5 occ status 2>&1 | grep -E "version|versionstring"
echo "=============================================="
```

!!! note "脚本要点"

    1. **先备份**：脚本假设你已经完成了 `config/` 和 `data/` 的备份
    2. **移出而非覆盖**：通过 `mv` 临时移出 `config/` 和 `data/`，再整目录替换代码，避免 `rsync --delete` 导致的残留文件问题
    3. **自动切换 PHP**：`UPGRADES` 数组里每项标注了对应的 PHP 二进制，脚本自动选择

### 升级后的 schema 修复

升级到 35 后，`occ db:schema:check` 报告一个差异：

```
oc_share_external: column 'id' differs in: autoincrement
```

这是因为 Nextcloud 33 引入了一个迁移，要**移除** `share_external.id` 的 auto-increment 属性，但跨版本升级时该迁移未正确执行。手动修复：

```sql
ALTER TABLE oc_share_external MODIFY COLUMN id bigint NOT NULL;
```

修复后再次检查：

```bash
sudo -u www-data php8.5 occ db:schema:check
# The live database schema matches the expected schema.
```

### 遗留问题：`.mjs` 文件 404

升级后浏览器控制台大量报 404 错误：

```text
circles/js/teams-dashboard.mjs: 404
dist/dashboard-main.mjs: 404
```

**根因**：Nextcloud 新版使用 ES modules（`.mjs` 文件），但旧 nginx 配置不识别 `.mjs` 扩展名，导致这些文件被错误地重写到 `index.php`。

修复方法：

```nginx
# 1. /etc/nginx/mime.types 添加 .mjs
application/javascript  js mjs;

# 2. 站点配置的 location 规则补充 .mjs 和 .wasm
location ~* \.(?:css|js|mjs|wasm)$ {
    try_files $uri /index.php$uri$is_args$args;
    add_header Cache-Control "public, max-age=7200";
    add_header X-Content-Type-Options nosniff;
    # ... 其它安全头 ...
    access_log off;
}
```

重载后验证：

```bash
nginx -t && systemctl reload nginx
```

## 数据迁移：外挂硬盘

升级完成后，发现系统盘（24G）已用 91%，而外挂数据盘（40G）仅用 27%。于是将 Nextcloud 数据目录迁移到外挂盘：

```bash
# 1. 进入维护模式
sudo -u www-data php8.5 occ maintenance:mode --on

# 2. rsync 迁移（保留权限和时间戳）
rsync -a /var/www/nextcloud/data/ /data/nextcloud-data/

# 3. 验证文件数一致
find /var/www/nextcloud/data -type f | wc -l   # 源
find /data/nextcloud-data -type f | wc -l      # 目标（应一致）

# 4. 设置权限
chown -R www-data:www-data /data/nextcloud-data

# 5. 修改 config.php
# 'datadirectory' => '/data/nextcloud-data'

# 6. 退出维护模式并验证
sudo -u www-data php8.5 occ maintenance:mode --off
sudo -u www-data php8.5 occ files:scan --all

# 7. 确认无误后删除旧目录
rm -rf /var/www/nextcloud/data
```

!!! success "迁移结果"

    数据目录从系统盘迁移到外挂盘后，系统盘占用从 91% 降至 84%，释放了 1.7G 空间。用户文件（1.7G、8577 个文件）完整无损。


## 最终结果

| 项目 | 升级前 | 升级后 |
|------|--------|--------|
| PHP | 8.1.2（EOL，有 RCE 漏洞）| **8.5.12**（最新安全版）|
| Nextcloud | 26.0.0 | **35.0.2**（2026 最新）|
| 数据完整性 | - | ✅ 128 张表、1.7G 用户文件完整迁移 |
| 系统盘占用 | 88% | 71%（释放 3.5G+）|


## 经验总结

### 教训

1. **EOL 版本是最大的风险**：PHP 8.1 已 EOL，面对重大漏洞时「无路可退」，只能硬升级。**生产环境的运行时和框架应保持在受支持版本内**。

2. **跨大版本升级没有捷径**：Nextcloud 强制逐版本升级，且中间版本对 PHP 版本有硬限制，必须提前规划好「版本 × PHP」的兼容矩阵。

3. **备份要放在不同磁盘**：本次系统盘空间紧张，幸好在另一块盘上有备份空间，否则备份都成问题。

### 做得好的地方

1. **第一时间停服**：面对正在被野外利用的 RCE，果断停止服务是正确的。
2. **完整备份先行**：数据库 + 配置 + 数据目录三份备份，让后续所有操作有了安全网。
3. **自动化脚本**：9 个版本的升级用脚本批量处理，减少人为失误。

### 给读者的建议

!!! tip "行动清单"

    1. ⚠️ 如果你还在用 **PHP 8.1 或更早版本**，立即检查并规划升级到 8.2.35+ / 8.3.36+ / 8.4.27+ / 8.5.12+
    2. Nextcloud 用户请关注官方系统要求，规划好升级路径
    3. 重要数据定期备份，且备份不要与源数据在同一块磁盘
    4. 升级前务必在测试环境验证完整流程

> **本文涉及的所有配置和命令均在 Ubuntu 22.04 + nginx + PHP-FPM + MySQL 环境下验证通过。**
>
> 升级操作请务必先在测试环境验证，并在生产环境做好完整备份后再执行。
