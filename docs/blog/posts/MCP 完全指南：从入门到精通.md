---
title: MCP 完全指南：从入门到精通
date: 2026-03-22 23:30:00
authors: 
  - Tinker
tags:
  - MCP
categories:
  - 人工智能
  - 编码与协议
---

## 入门篇：什么是 MCP？

### MCP 的定义与价值

**MCP（Model Context Protocol，模型上下文协议）** 是一个开源标准协议，用于连接 AI 应用程序与外部系统。它就像 **USB-C 接口** 一样，为 AI 应用提供了一种标准化的方式来连接数据源、工具和工作流。

![](https://static.cyub.vip/images/202603/mcp-simple-diagram.png)

**MCP 能做什么？**

- 让 AI 助手访问你的 Google Calendar 和 Notion，成为个性化助理
- 让 Claude Code 根据 Figma 设计生成完整 Web 应用
- 让企业聊天机器人连接多个数据库，通过对话分析数据
- 让 AI 模型创建 3D 设计并通过 3D 打印机输出

### 为什么 MCP 很重要？

| 角色 | 收益 |
|------|------|
| **开发者** | 减少开发时间和复杂度，无需为每个集成重复造轮子 |
| **AI 应用** | 接入丰富的数据源和工具生态，增强能力 |
| **终端用户** | 获得更强大的 AI 应用，能访问个人数据并执行操作 |

<!-- more -->

## 架构篇：理解核心设计

MCP 采用客户端-服务器架构，其中 MCP 宿主（Host）——即像 [Claude Code](https://www.anthropic.com/claude-code) 或 [Claude Desktop](https://www.claude.ai/download) 这样的 AI 应用程序——负责与一个或多个 MCP 服务器建立连接。

宿主通过为每个 MCP 服务器创建一个 MCP 客户端来实现这一点，每个 MCP 客户端与其对应的 MCP 服务器保持专用连接。

使用 STDIO 传输机制的本地 MCP 服务器通常仅服务于单个 MCP 客户端，它通常称为 **"本地"MCP 服务器**，而使用 Streamable HTTP 传输机制的远程 MCP 服务器则可以同时服务于多个 MCP 客户端，它通常称为 **"远程"MCP 服务器**。

### 架构参与者

```mermaid
graph TB
    subgraph Host["MCP 宿主 (AI 应用程序)"]
        Client1["MCP 客户端1"]
        Client2["MCP 客户端2"]
        Client3["MCP 客户端3"]
        Client4["MCP 客户端4"]
    end

    ServerA["MCP 服务器A - 本地<br/>(比如 文件系统)"]
    ServerB["MCP 服务器B - 本地<br/>(比如数据库)"]
    ServerC["MCP 服务器C - 远程<br/>(比如Sentry应用监控平台)"]

    Client1 ---|"专有连接"| ServerA
    Client2 ---|"专有连接"| ServerB
    Client3 ---|"专有连接"| ServerC
    Client4 ---|"专有连接"| ServerC

    style Host fill:#e3f2fd,stroke:#1565c0,stroke-width:2px
    style Client1 fill:#bbdefb,stroke:#1565c0
    style Client2 fill:#bbdefb,stroke:#1565c0
    style Client3 fill:#bbdefb,stroke:#1565c0
    style Client4 fill:#bbdefb,stroke:#1565c0
    style ServerA fill:#ffe0b2,stroke:#ef6c00
    style ServerB fill:#ffe0b2,stroke:#ef6c00
    style ServerC fill:#c8e6c9,stroke:#2e7d32
```

MCP 采用 **客户端-服务器架构**，包含三个核心角色：

- **MCP Host（宿主）**：协调并管理一个或多个 MCP 客户端的 AI 应用程序
- **MCP Client（客户端）**：负责与 MCP 服务器保持连接，并为 MCP 宿主获取上下文的组件
- **MCP Server（服务器）**：向 MCP 客户端提供上下文的程序

### 双层架构设计

MCP 由两个逻辑层组成：

- **数据层（Data layer）**：定义基于 JSON-RPC 的客户端-服务器通信协议，包括生命周期管理以及核心原语（如 tools、resources、prompts 和 notifications）。
- **传输层（Transport layer）**：定义支持客户端与服务器之间数据交换的通信机制和通道，包括传输层特定的连接建立、消息帧封装（message framing）和授权机制。

从概念上讲，数据层是内层，而传输层是外层。

```mermaid
graph TB
    Client[Client] <-->|数据层消息| DL
    DL <-->|传输层封装| TL
    TL <-->|网络/进程通信| Server[Server]
    
    subgraph "Data Layer (协议语义)"
        DL[JSON-RPC 2.0<br/>Lifecycle/Primitives/Notifications]
    end
    
    subgraph "Transport Layer (通信机制)"
        TL[STDIO / Streamable HTTP<br/>连接/帧/认证]
    end
    
    style DL fill:#e3f2fd,stroke:#1565c0,stroke-width:3px
    style TL fill:#fff8e1,stroke:#ff8f00,stroke-width:3px
    style Client fill:#f3e5f5,stroke:#6a1b9a
    style Server fill:#f3e5f5,stroke:#6a1b9a
```

#### 数据层

数据层实现了基于 [JSON-RPC 2.0](https://www.jsonrpc.org/) 的交换协议，定义了消息结构和语义。该层包括：

- **生命周期管理（Lifecycle management）**：处理客户端与服务器之间的连接初始化、能力协商（capability negotiation）和连接终止
- **服务器功能（Server features）**：使服务器能够提供核心功能，包括用于 AI 操作的 tools、用于上下文数据的 resources，以及用于与客户端交互模板的 prompts
- **客户端功能（Client features）**：使服务器能够请求客户端从宿主 LLM 进行采样（sampling）、向用户获取输入（elicitation），以及向客户端发送日志消息
- **实用功能（Utility features）**：支持额外的能力，如实时更新的通知（notifications）和长时运行操作的进度跟踪（progress tracking）

#### 传输层

传输层管理客户端与服务器之间的通信通道和身份认证。它负责处理连接建立、消息帧封装以及 MCP 参与者之间的安全通信。MCP 支持两种传输机制：

- Stdio 传输（Stdio transport）：使用标准输入/输出流进行同一机器上本地进程之间的直接进程通信，提供最佳性能且无需网络开销。它只能一对一连接（单服务器服务单客户端）。
- Streamable HTTP 传输（Streamable HTTP transport）：使用 HTTP POST 进行客户端到服务器的消息传输，并可选使用 Server-Sent Events（SSE）实现流式传输能力。该传输机制支持远程服务器通信，并支持标准 HTTP 认证方法，包括 bearer tokens、API keys 和自定义请求头。MCP 推荐使用 OAuth 来获取认证令牌。它支持一对多连接（单服务器服务多客户端）。

传输层将通信细节从协议层抽象出来，使得在所有传输机制中都可以使用相同的 JSON-RPC 2.0 消息格式。

### 能力协商

MCP 采用**一种基于能力的协商机制（Capability Negotiation）**，客户端与服务端在初始化阶段会显式声明各自支持的功能。这些能力决定了在会话期间可用的协议特性与原语（primitives）。

- 服务端会声明其能力，例如：资源订阅、工具支持、提示模板等
- 客户端会声明其能力，例如：采样（sampling）支持、通知处理等
- 双方在整个会话过程中必须遵守已声明的能力范围
- 可以通过协议扩展机制协商额外的能力

```mermaid
sequenceDiagram
    participant Host
    participant Client
    participant Server

    Host->>+Client: 初始化客户端
    Client->>+Server: 使用能力信息初始化会话
    Server-->>Client: 返回支持的能力

    Note over Host,Server: 已协商能力的活动会话

    loop 客户端请求
        Host->>Client: 用户或模型触发操作
        Client->>Server: 发起请求（工具/资源）
        Server-->>Client: 返回响应
        Client-->>Host: 更新 UI 或返回给模型
    end

    loop 服务端请求
        Server->>Client: 发起请求（采样）
        Client->>Host: 转发给 AI
        Host-->>Client: AI 响应
        Client-->>Server: 返回响应
    end

    loop 通知
        Server--)Client: 资源更新
        Client--)Server: 状态变化
    end

    Host->>Client: 终止
    Client->>-Server: 结束会话
    deactivate Server
```

每一项能力都会解锁在会话期间可使用的特定协议功能。例如：

- 已实现的服务端功能必须在服务端能力声明中进行公布
- 若服务端需要发送资源订阅通知，则必须声明支持订阅能力
- 调用工具（Tool）需要服务端声明工具能力
- 采样（Sampling）功能需要客户端在其能力中声明支持

这种能力协商机制确保客户端与服务端对可用功能有清晰一致的理解，同时也保证了协议具备良好的可扩展性。

## 服务器篇：三大核心原语

MCP 服务器通过 **三大原语** 提供功能：

| 原语 | 控制权 | 用途 | 示例 |
|------|--------|------|------|
| **Tools** | 模型控制 | 可执行函数，AI 主动调用 | 搜索航班、发送邮件、创建日程 |
| **Resources** | 应用控制 | 只读数据源，提供上下文 | 文档内容、数据库 Schema、日历 |
| **Prompts** | 用户控制 | 结构化模板，指导工作流 | 规划假期、总结会议、起草邮件 |

### Tools（工具）

Tools 是让 AI 模型执行动作的**可执行函数**。

**协议操作：**

- `tools/list`: 发现可用工具（返回工具定义和 JSON Schema）
- `tools/call`: 执行特定工具

**生命周期时序图：**
                    

```mermaid
sequenceDiagram
    actor U as 用户
    participant H as MCP Host
    participant C as MCP Client
    participant S as MCP Server
    
    U->>H: 帮我订去巴塞罗那的票
    
    rect rgb(230, 245, 255)
        Note over H,S: 1. 初始化与能力协商
        H->>C: initialize
        C->>S: 建立连接
        S-->>C: 返回能力信息
        C-->>H: 协商完成
    end
    
    rect rgb(255, 248, 225)
        Note over H,S: 2. 工具发现
        H->>C: 发现工具
        C->>S: tools/list
        S-->>C: 返回工具定义(含JSON Schema)
        C-->>H: 工具列表
    end
    
    rect rgb(232, 245, 233)
        Note over H,S: 3. AI决策与工具调用
        H->>H: AI决策调用searchFlights
        H->>C: tools/call
        C->>S: 执行searchFlights
        S-->>C: 返回航班数据
        C-->>H: 执行结果
        H-->>U: 找到3个航班选项
    end
    
    rect rgb(243, 229, 245)
        Note over H,S: 4. 后续操作
        H->>H: AI决策下一步
        H->>C: tools/call (bookHotel等)
        C->>S: 执行预订
        S-->>C: 确认信息
        C-->>H: 完成
        H-->>U: 已为您预订酒店
    end
```

**示例 Tool 定义：**

```json
{
  "name": "searchFlights",
  "description": "搜索可用航班",
  "inputSchema": {
    "type": "object",
    "properties": {
      "origin": { "type": "string", "description": "出发城市" },
      "destination": { "type": "string", "description": "目的城市" },
      "date": { "type": "string", "format": "date" }
    },
    "required": ["origin", "destination", "date"]
  }
}
```

**信任与安全机制：**

- UI 显示可用工具，用户可控制是否启用
- 每次执行前可要求确认对话框
- 预授权安全操作（如只读查询）
- 完整的活动日志审计

### Resources（资源）

Resources 提供**结构化只读数据**，为 AI 提供上下文。

**两种发现模式：**

**直接资源**（固定 URI）：

- `calendar://events/2026` → 返回 2026 年日历
- `file:///path/to/doc.md` → 返回文档内容

**资源模板**（动态 URI）：

- `weather://forecast/{city}/{date}` → 任意城市天气
- `travel://activities/{city}/{category}` → 按类别筛选活动

**资源读取时序图：**

```mermaid
sequenceDiagram
    actor U as 用户
    participant A as AI应用
    participant C as MCP Client
    participant S as MCP Server
    participant D as 数据源
    
    rect rgb(255, 243, 224)
        Note over A,S: 1. 发现资源模板
        A->>C: 发现资源模板
        C->>S: resources/templates/list
        S-->>C: 返回模板列表(weather://{city})
        C-->>A: 可用模板
    end
    
    U->>A: 输入"巴塞罗那"
    
    rect rgb(227, 242, 253)
        Note over A,D: 2. 读取资源
        A->>C: resources/read<br/>(weather://barcelona)
        C->>S: 获取天气数据
        S->>D: 查询数据库/API
        D-->>S: 返回原始数据
        S-->>C: 格式化数据
        C-->>A: 天气信息
    end
    
    Note over A: 提供给AI模型作为上下文
```

**资源订阅机制：**

- `resources/subscribe`: 订阅资源变更通知
- 服务器推送实时更新（如日历变动、文件修改）

### Prompts（提示词）

Prompts 是**用户控制的结构化模板**，用于标准化交互。

**与 Tools 的区别：**

- Tools 是模型自主决定的（Agentic 行为）
- Prompts 需要用户显式调用（如 `/plan-vacation`）

**示例 Prompt 定义：**

```json
{
  "name": "plan-vacation",
  "title": "规划假期",
  "description": "指导完成假期规划流程",
  "arguments": [
    { "name": "destination", "type": "string", "required": true },
    { "name": "duration", "type": "number", "description": "天数" },
    { "name": "budget", "type": "number" },
    { "name": "interests", "type": "array", "items": { "type": "string" } }
  ]
}
```

**典型 UI 模式：**

- `/` 斜杠命令（如 `/plan-vacation`）
- 命令面板搜索
- 上下文菜单推荐
- 专用 UI 按钮

## 客户端篇：增强交互能力

MCP 客户端不仅消费服务器提供的上下文，还能向服务器提供**三大核心功能**：

| 功能 | 说明 | 应用场景 |
|------|------|----------|
| **Sampling** | 服务器通过客户端请求 LLM 补全 | 旅行服务器分析 47 个航班选项，请求 AI 推荐最佳方案 |
| **Elicitation** | 服务器请求用户提供额外信息 | 预订确认时询问座位偏好、房间类型 |
| **Roots** | 客户端指定文件系统边界 | 限制服务器只能访问特定工作目录 |

### Sampling（采样）

允许服务器**通过客户端请求 LLM 能力**，实现"无模型依赖的 AI 服务"。

**完整交互流程：**

```mermaid
sequenceDiagram
    participant S as MCP Server<br/>(旅行服务)
    participant C as MCP Client
    actor U as 用户
    participant H as AI Host<br/>(Claude)
    
    rect rgb(255, 243, 224)
        Note over S: 1. 查询航班API<br/>获取47个航班选项
    end
    
    S->>C: sampling/complete<br/>(请求分析航班)
    
    rect rgb(232, 245, 233)
        Note over C,U: 2. 透明度与审查
        C->>U: 显示完整提示词<br/>"分析这些航班并推荐最佳..."
        U->>C: 用户批准请求
    end
    
    rect rgb(227, 242, 253)
        Note over C,H: 3. 客户端控制AI调用
        C->>H: 调用LLM分析
        H-->>C: 返回分析结果
    end
    
    rect rgb(255, 249, 229)
        Note over C,U: 4. 结果审查
        C->>U: 展示AI分析结果<br/>(可修改后发送)
        U->>C: 确认发送
    end
    
    C-->>S: 返回航班推荐列表
    
    Note over S: 继续执行预订流程
```

**设计优势：**

- 服务器无需集成 LLM SDK 或支付 API 费用
- 客户端完全控制权限和安全策略
- 支持 Human-in-the-loop（用户审查请求和响应）

### Elicitation（信息获取）

服务器可**动态请求用户输入**，避免前期收集所有信息。

**典型场景：预订确认流程**

```mermaid
sequenceDiagram
    actor U as 用户
    participant C as MCP Client
    participant S as MCP Server

    Note over S: 服务器执行到需要用户确认的步骤
    
    rect rgb(255, 243, 224)
        Note over S,C: 第一轮：预订确认
        S->>C: elicitation/requestInput
        Note right of S: 请求确认预订详情<br/>含JSON Schema定义表单结构
        
        C->>U: 显示交互式表单
        Note right of C: [确认预订: boolean]<br/>[座位偏好: enum(靠窗/过道)]<br/>[房间类型: enum(海景/市景/花园)]<br/>[旅行保险: boolean]
        
        U->>U: 填写表单数据<br/>(确认=是, 座位=靠窗<br/>房间=海景房, 保险=是)
        
        U->>C: 提交表单
        
        C->>C: 验证数据符合Schema
        
        C-->>S: 返回用户输入对象
    end
    
    Note over S: 服务器处理预订...
    
    S-->>C: 预订中间结果
    
    C->>U: 显示"已为您预订海景房，靠窗座位"
    
    rect rgb(227, 242, 253)
        Note over S,C: 第二轮：补充信息（联系人）
        S->>C: elicitation/requestInput
        Note right of S: 请求联系人信息<br/>完成预订流程
        
        C->>U: 显示新表单
        Note right of C: [姓名: string]<br/>[电话: string]<br/>[紧急联系人: string]
        
        U->>C: 填写并提交联系人信息
        
        C-->>S: 返回联系人数据
    end
    
    rect rgb(232, 245, 233)
        Note over S,C: 继续执行
        S->>S: 处理完整预订信息
        
        S-->>C: 最终预订确认
        
        C->>U: 显示"预订完成！确认邮件已发送"
    end
```


**关键交互点说明：**

1. **Schema 驱动表单**：服务器通过 JSON Schema 定义表单字段类型（boolean、enum、string），客户端自动渲染对应 UI 控件（复选框、下拉框、文本框）

2. **验证环节**：客户端在返回数据前会验证用户输入是否符合 Schema，如果不符合会提示用户修正，减少服务器端验证负担

3. **多轮对话**：一个业务流程中可以包含多次 Elicitation 调用，按需分步收集信息（如先确认预订详情，再收集联系人信息）

4. **用户控制权**：用户可以选择拒绝提供信息或取消整个操作，客户端会处理这些异常流程并通知服务器

**隐私保护原则：**

- 绝不索要密码或 API Key
- 客户端警告可疑请求
- 用户可拒绝提供信息并取消操作

### Roots（根目录）

客户端指定**文件系统边界**，指导服务器工作范围。

**Roots 结构：**

```json
[
  { "uri": "file:///Users/agent/travel-planning", "name": "旅行规划工作区" },
  { "uri": "file:///Users/agent/travel-templates", "name": "模板库" },
  { "uri": "file:///Users/agent/client-documents", "name": "客户文档" }
]
```

**动态更新机制：**

- 用户打开新文件夹时自动添加 Root
- `roots/list_changed` 通知服务器更新边界
- 服务器"应该"尊重边界（协调机制，非强制安全边界）


## 实战篇：多服务器协作案例

### 场景：智能旅行规划助手

**系统架构：**

```mermaid
graph TB
    subgraph Host["旅行规划 MCP Host (Claude Desktop)"]
        direction LR
        TC[Travel<br/>MCP Client]
        WC[Weather<br/>MCP Client]
        CC[Calendar/Email<br/>MCP Client]
    end
    
    TS[Travel<br/>MCP Server<br/>航班/酒店]
    WS[Weather<br/>MCP Server<br/>天气预报]
    CS[Calendar<br/>MCP Server<br/>日程/邮件]
    
    TC <-->|Tools/Resources| TS
    WC <-->|Tools/Resources| WS
    CC <-->|Tools/Resources| CS
    
    style Host fill:#e8eaf6,stroke:#3f51b5,stroke-width:2px
    style TC fill:#c5cae9,stroke:#3f51b5
    style WC fill:#c5cae9,stroke:#3f51b5
    style CC fill:#c5cae9,stroke:#3f51b5
    style TS fill:#dcedc8,stroke:#689f38
    style WS fill:#fff9c4,stroke:#fbc02d
    style CS fill:#ffccbc,stroke:#e64a19
```

### 完整业务流程时序图
 
```mermaid
sequenceDiagram
    actor U as 用户
    participant H as Claude Desktop<br/>(MCP Host)
    participant TC as Travel Client
    participant WC as Weather Client
    participant CC as Calendar Client
    participant TS as Travel Server
    participant WS as Weather Server
    participant CS as Calendar Server
    
    U->>H: 帮我规划巴塞罗那之旅
    
    rect rgb(255, 249, 229)
        Note over H,TS: 步骤1: 调用规划提示词
        H->>TC: prompts/get: plan-vacation<br/>(目的地=巴塞罗那, 预算=3000)
        TC->>TS: 获取提示词模板
        TS-->>TC: 返回模板
        TC-->>H: 结构化参数输入UI
    end
    
    rect rgb(232, 245, 233)
        Note over H,CS: 步骤2: 发现与读取资源
        par 并行读取资源
            H->>CC: resources/read<br/>calendar://my-calendar
            CC->>CS: 查询日历可用性
            CS-->>CC: 返回日程数据
            CC-->>H: 六月空闲时间
        and
            H->>TC: resources/read<br/>travel://preferences
            TC->>TS: 获取旅行偏好
            TS-->>TC: 返回偏好数据
            TC-->>H: 用户喜好
        end
    end
    
    rect rgb(227, 242, 253)
        Note over H,WS: 步骤3: 工具调用 - 查询航班和天气
        H->>TC: tools/call: searchFlights()
        TC->>TS: 查询航班API
        TS-->>TC: 返回47个航班选项
        TC-->>H: 航班列表
        
        H->>WC: tools/call: checkWeather()
        WC->>WS: 查询天气API
        WS-->>WC: 返回巴塞罗那天气预报
        WC-->>H: 天气信息
    end
    
    rect rgb(243, 229, 245)
        Note over H,TC: 步骤4: 采样分析
        H->>TC: sampling/complete<br/>(分析47个航班推荐最佳)
        Note right of TC: 客户端控制AI调用
        TC-->>H: 分析结果: 推荐3个航班
        H-->>U: 展示推荐选项
    end
    
    U->>H: 选择第2个航班
    
    rect rgb(255, 235, 238)
        Note over H,TS: 步骤5: 信息获取与确认
        H->>TC: elicitation/requestInput<br/>(座位偏好? 房间类型?)
        TC-->>H: 显示表单
        H-->>U: 请确认预订详情
        U->>H: 靠窗座位+海景房+保险
        H->>TC: 返回用户选择
    end
    
    rect rgb(255, 241, 224)
        Note over H,CS: 步骤6: 执行预订与同步
        par 并行执行
            H->>TC: tools/call: bookHotel()
            TC->>TS: 预订酒店
            TS-->>TC: 确认号
        and
            H->>CC: tools/call: createCalendarEvent()
            CC->>CS: 创建日程
            CS-->>CC: 确认
        and
            H->>CC: tools/call: sendEmail()
            CC->>CS: 发送确认邮件
            CS-->>CC: 发送成功
        end
    end
    
    H-->>U: 预订完成！已发送确认邮件
```

## 开发篇：工具链与最佳实践

### MCP 生态系统组件

| 组件 | 说明 |
|------|------|
| **MCP Specification** | 协议规范，定义客户端和服务器的实现要求 |
| **MCP SDKs** | 多语言 SDK（TypeScript、Python、Java、C# 等） |
| **MCP Inspector** | 开发和调试工具，用于测试服务器实现 |
| **Reference Servers** | 官方参考实现（文件系统、SQLite、Git 等） |

### 开发工作流

```
1. 设计阶段
   └── 确定服务器职责（工具/资源/提示词划分）
   
2. 实现阶段
   ├── 选择 SDK（TypeScript/Python）
   ├── 实现 Server Capabilities
   └── 定义 Primitives (Tools/Resources/Prompts)

3. 调试阶段
   ├── 使用 MCP Inspector 测试
   ├── 验证 JSON Schema 兼容性
   └── 测试生命周期管理

4. 部署阶段
   ├── 本地服务器（STDIO）：随客户端启动
   └── 远程服务器（HTTP）：独立部署，多租户支持
```

### 设计原则与最佳实践

**1. 单一职责原则**

- 每个服务器专注于特定领域（如：Travel Server 只处理旅行相关）

**2. 安全边界**

- Tools 执行前要求用户确认（尤其是写操作）
- Resources 保持只读，避免暴露敏感路径
- Prompts 透明展示模板内容，避免隐藏指令

**3. 渐进式发现**

- 支持动态列表（`*/list` 可实时变化）
- 利用 Notifications 通知客户端资源/工具更新
- 提供参数补全（如城市名自动建议）

**4. 错误处理**

- 使用 JSON-RPC 2.0 错误对象
- 长任务提供 Progress Token 和取消机制
- 采样请求处理超时和速率限制

### 快速开始示例（Python SDK）

```python
from mcp.server import Server
from mcp.types import Tool, TextContent

app = Server("travel-server")

@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="searchFlights",
            description="搜索可用航班",
            inputSchema={
                "type": "object",
                "properties": {
                    "origin": {"type": "string"},
                    "destination": {"type": "string"},
                    "date": {"type": "string", "format": "date"}
                },
                "required": ["origin", "destination", "date"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "searchFlights":
        # 实现航班查询逻辑
        return [TextContent(type="text", text="航班列表...")]

# 启动 STDIO 传输
if __name__ == "__main__":
    app.run(transport="stdio")
```


## 总结

MCP 正在重新定义 AI 应用与外部世界的连接方式。通过标准化的协议层：

- **对开发者**：告别重复造轮子，一次开发处处集成
- **对 AI 应用**：无缝接入丰富的工具和数据生态
- **对用户**：获得真正个性化、能执行操作的 AI 助手

**关键记忆点：**

1. **三大原语**：Tools（模型控制）、Resources（应用控制）、Prompts（用户控制）
2. **双向能力**：服务器提供上下文，客户端提供采样/交互/根目录能力
3. **传输无关**：STDIO 用于本地，HTTP 用于远程，数据层完全一致
4. **人机协同**：所有敏感操作都可配置 Human-in-the-loop 审查

随着 Claude、VS Code、Cursor 等主流工具的支持，MCP 正成为 AI 集成的**事实标准**。现在正是加入 MCP 生态的最佳时机。


**参考资料：**

-  [MCP 官方介绍](https://modelcontextprotocol.io/docs/getting-started/intro)
-  [MCP 架构概览](https://modelcontextprotocol.io/docs/learn/architecture)
-  [MCP 服务器概念](https://modelcontextprotocol.io/docs/learn/server-concepts)
-  [MCP 客户端概念](https://modelcontextprotocol.io/docs/learn/client-concepts)
- [MCP 架构](https://modelcontextprotocol.io/specification/2025-11-25/architecture)