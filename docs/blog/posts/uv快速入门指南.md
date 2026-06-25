---
title: uv 快速入门指南
authors:
  - Tinker
tags:
  - 构建工具/uv
  - 入门指南
  - 编程语言/Python
categories:
  - 工程实践与运维
date: 2025-11-29 11:05:00
---

uv 是一款由 Astral 团队（创始人 Charlie Marsh）使用 Rust 语言开发的高性能 Python 包管理器。它旨在解决传统工具如 pip 和 venv 在依赖解析、安装速度和整体效率上的瓶颈。

作为 Python 生态的现代化核心组件，uv 不仅提供数倍于 pip 的安装速度，还支持无缝兼容现有工具（如 pip、poetry 和 setuptools），让开发者能轻松过渡到高效的工作流。

无论你是初学者还是资深开发者，uv 都能简化项目管理、减少环境冲突，并加速开发迭代。

## 安装 uv

uv 的安装过程简单快捷，支持多种方式。推荐使用脚本安装，以获取最新版本和自动配置。

### 通过安装脚本

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

此命令会下载并执行安装脚本，将 uv 添加到你的 PATH 中。安装后，重启终端或运行 `source ~/.bashrc`（或对应 shell 配置）以生效。

<!-- more -->

### 通过 pip 或 pipx 安装

```bash
# 使用 pip（需已安装 Python）
pip install uv

# 或使用 pipx（隔离安装，避免冲突）
pipx install uv
```
pipx 是理想选择，因为它将 uv 安装到独立环境中，防止与系统包干扰。

### 自更新

保持 uv 最新：

```bash
uv self update
```

这会自动拉取并应用最新版本，类似于 `pip install --upgrade uv`，但更快。

### 验证安装

```bash
uv --version
```
输出类似 `uv 0.x.x`，确认安装成功。

## 管理虚拟环境

uv 内置 venv 支持，能在毫秒级创建隔离环境，避免全局污染。默认情况下，它会在当前目录生成 `.venv` 文件夹，使用项目根目录的 Python 解释器。

### 创建虚拟环境

```bash
# 默认创建 .venv
uv venv

# 指定自定义路径
uv venv --prefix ./myenv

# 指定 Python 版本（需预安装）
uv venv --python 3.11

# 指定完整路径
uv venv --python 3.11 /path/to/.venv

# 创建轻量级环境（不复制标准库，节省空间）
uv venv --seed
```

`--seed` 选项特别适合大型项目，能显著减少磁盘占用，同时保持兼容性。

### 清理与激活

```bash
# 清除 uv 缓存（释放空间）
uv clean

# 激活环境（Debian/Ubuntu 等）
source /path/to/.venv/bin/activate

# 退出环境
deactivate
```

激活后，你的 shell 会切换到该环境，提示符通常会显示 `(myenv)` 前缀。

## 安装与管理依赖包

uv 的包管理命令以 `uv pip` 开头，是 pip 的高速替代品。它支持所有 pip 功能，但解析依赖时更快（通常快 10-100 倍）。对于项目级管理，优先使用 `uv add` 等命令，以自动维护 `pyproject.toml` 和锁文件。

### 基本安装与操作

```bash
# 安装单个包
uv pip install flask

# 查看包详情
uv pip show fastapi

# 升级包
uv pip install --upgrade uvicorn

# 从 requirements.txt 批量安装
uv pip install -r requirements.txt

# 列出已安装包
uv pip list

# 卸载包
uv pip uninstall requests

# 导出依赖列表
uv pip freeze > requirements.txt

# 优先最高版本安装（跳过部分冲突检查，加速过程）
uv pip install --resolution=highest pandas

# 安装到指定环境（非当前激活环境）
uv pip install -p /path/to/.venv flask
```

`--resolution=highest` 适用于快速原型开发，但生产环境建议使用默认的严格模式以确保稳定性。

## 管理 Python 版本

uv 内置 Python 版本管理器，能自动下载、安装和切换版本，支持从 3.8 到最新版。所有版本存储在统一目录，便于跨项目复用。

### 列出与安装版本

```bash
# 列出已安装和当前版本
uv python list

# 显示所有可用补丁版本
uv python list --all-versions

# 只显示已安装版本
uv python list --only-installed

# 安装最新稳定版
uv python install

# 安装特定版本
uv python install 3.11.5

# 安装系列最新版（如 3.10.x）
uv python install 3.10
```

安装过程会从官方源下载二进制分发包，无需编译。

### 目录与项目固定
```bash
# 查看 Python 安装目录（受 UV_PYTHON_INSTALL_DIR 环境变量影响）
uv python dir

# 为项目固定版本（创建 .python-version 文件）
uv python pin 3.11
```
固定后，`uv venv`、`uv run` 等命令会优先使用该版本，确保团队一致性。

### 卸载版本

```bash
# 卸载特定版本
uv python uninstall 3.10.8

# 卸载整个系列
uv python uninstall 3.11
```

## 项目级依赖管理

uv 的项目管理命令（如 `uv add`）专注于 `pyproject.toml` 文件，能自动生成锁文件 `uv.lock`，锁定确切版本以实现可重现构建。相比 `uv pip`，这些命令会修改项目配置文件，并默认使用 `.venv` 环境。

### 添加与移除依赖

```bash
# 添加包（自动更新 pyproject.toml 和 uv.lock）
uv add numpy
uv add "requests>=2.28.0"  # 支持版本约束

# 移除包
uv remove numpy
uv remove requests pandas

# 如果已使用 uv pip install 装了一堆包，可以如下操作
uv pip freeze > requirements.txt # 先导出到requirements.txt
uv add -r requirements.txt # 然后写回到requirements.txt
```

### 同步与锁定

```bash
# 根据 pyproject.toml 或 requirements.txt 同步环境（移除多余包）
uv sync
uv sync -r requirements.txt

# 生成/更新锁文件
uv lock
uv lock -r requirements.txt -o requirements.lock
```

`uv sync` 是核心命令，该命令会读取 uv.lock 并在 .venv 目录中安装确切版本的依赖，确保本地环境与锁文件精确匹配，防止“在我的机器上能跑”问题。

### 运行与开发工具

```bash
# 在项目环境中运行脚本（无需手动激活）
uv run python script.py
uv run pytest

# 安装项目自身（editable 模式）
uv pip install -e .

# 添加开发依赖（如 linter）
uv add --dev ruff  # 写入 [dependency-groups.dev]

# 运行格式化工具
uv run ruff format .

# 检查而不修改
uv run ruff format --check .
```

`--dev` 标志将包归入开发组，便于 CI/CD 区分运行时与测试依赖。

## 启动你的第一个 uv 项目

以下是快速创建一个简单项目的示例，展示 uv 的端到端工作流：

```bash
# 初始化项目
uv init example
# 输出：Initialized project `example` at `/path/to/example`

cd example

# 添加开发工具
uv add ruff
# 输出示例：
# Using CPython 3.12.3 interpreter at: /usr/bin/python3.12
# Creating virtual environment at: .venv
# Resolved 2 packages in 1.57s
# Prepared 1 package in 26.07s
# Installed 1 package in 50ms
# + ruff==0.14.7

# 运行检查
uv run ruff check
# 输出：All checks passed!

# 锁定依赖
uv lock
# 输出：Resolved 2 packages in 48ms

# 同步环境
uv sync
# 输出：Resolved 2 packages in 36ms
# Audited 1 package in 3ms
```

这个流程从零到运行只需几秒钟，uv 会自动处理环境创建和依赖解析。

## 生产环境部署

uv 不仅适合本地开发，其高效、确定性的依赖管理使其在生产部署中同样出色。以下是容器化和 CI/CD 场景中的最佳实践。

### 容器化部署（Docker）

uv 提供了官方精简镜像 `ghcr.io/astral-sh/uv`，可用于多阶段构建，显著减小最终镜像体积并提升构建速度。

```dockerfile
# 阶段一：使用 uv 镜像准备依赖
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# 利用 Docker 缓存：仅当依赖文件变化时才重新解析
COPY pyproject.toml uv.lock ./

# 生产环境同步：--no-dev 排除开发依赖，--frozen 确保严格使用 uv.lock
RUN uv sync --no-dev --frozen

# 阶段二：最小化运行镜像
FROM python:3.12-slim-bookworm

WORKDIR /app

# 从 builder 阶段复制已安装好的依赖
COPY --from=builder /app/.venv /app/.venv

# 将虚拟环境的 bin 目录加入 PATH
ENV PATH="/app/.venv/bin:$PATH"

COPY . .

CMD ["python", "-m", "myapp"]
```

关键说明：

- `--no-dev`：仅安装运行时依赖，排除 ruff、pytest 等开发工具，减少攻击面和镜像体积。
- `--frozen`：禁止更新 `uv.lock`，若锁文件与 `pyproject.toml` 不一致则直接报错，防止生产环境出现非预期依赖变更。
- 多阶段构建：最终镜像无需包含 uv 工具本身，只需 Python 运行时和 `.venv` 内容。

若追求极致精简，也可在单阶段容器内使用系统级 Python，省去虚拟环境层：

```dockerfile
FROM python:3.12-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv pip install --system --no-dev -r pyproject.toml

COPY . .
CMD ["python", "-m", "myapp"]
```

这里 `--system` 将包直接安装到系统 Python，`--no-dev` 同样排除开发依赖。适合对镜像分层不敏感、希望 Dockerfile 更简洁的场景。

### CI/CD 优化

在 GitHub Actions 等流水线中，可结合 uv 的高速缓存机制大幅缩短依赖安装时间。

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup uv
        uses: astral-sh/setup-uv@v5
        with:
          version: "latest"
          enable-cache: true

      - name: Sync dependencies
        run: uv sync --frozen

      - name: Run tests
        run: uv run pytest
```

`astral-sh/setup-uv` 官方 Action 会自动处理 uv 二进制下载和缓存目录配置。`enable-cache: true` 将依赖包缓存到 GitHub Actions 缓存服务，后续构建可直接复用，通常能将安装时间从分钟级降至秒级。

对于需要区分运行和测试依赖的流水线，可以分步执行：

```yaml
      - name: Install production dependencies
        run: uv sync --no-dev --frozen

      - name: Install all dependencies for testing
        run: uv sync --frozen
```

### 环境变量调优

uv 支持一系列环境变量，用于在生产环境中精细控制行为：

| 变量 | 说明 | 生产建议 |
|---|---|---|
| `UV_COMPILE_BYTECODE=1` | 安装时预编译 `.pyc` 文件 | 启用，可显著缩短容器启动时间 |
| `UV_NO_INSTALLER_METADATA=1` | 不记录 uv 作为安装器元数据 | 若需与 pip 混用或审计时保持整洁，可启用 |
| `UV_LINK_MODE=copy` | 强制复制而非符号链接/硬链接包文件 | 在 Docker 或只读文件系统中使用，避免跨设备链接错误 |
| `UV_CACHE_DIR` | 自定义全局缓存目录 | CI 中设置为持久化路径，实现跨构建缓存复用 |

示例：在 Dockerfile 中启用字节码编译以加速冷启动

```dockerfile
ENV UV_COMPILE_BYTECODE=1
RUN uv sync --no-dev --frozen
```

### 可复现构建保障

`uv.lock` 是 uv 实现可复现构建的核心。它锁定了所有直接和传递依赖的确切版本、哈希值及平台信息，确保任何人在任何时间执行 `uv sync` 都得到完全一致的依赖树。

在生产环境中务必遵循以下原则：

- **提交锁文件**：`uv.lock` 必须纳入版本控制，与 `pyproject.toml` 一同提交。
- **使用 `--frozen`**：生产构建、CI 测试、容器镜像构建中均使用 `uv sync --frozen`，拒绝隐式更新。
- **分离开发依赖**：通过 `dependency-groups` 或 `--dev` 标记区分运行时与测试/格式化工具，生产部署时始终携带 `--no-dev`。

## 参考资料

- [Python 包管理器 uv：原理简介与使用指南](https://juejin.cn/post/7507207338686169107)
- [uv 完全指南：Python 包管理的现代化解决方案](https://juejin.cn/post/7563860666349010994)
