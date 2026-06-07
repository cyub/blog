---
title: LangGraph Interrupt 从入门到深入
authors:
  - Tinker
tags:
  - 编程语言/Python
  - LangGraph
categories:
  - 人工智能
  - 软件架构与设计
date: 2026-06-06 11:20:00
---

# LangGraph Interrupt 从入门到深入

在构建 AI Agent 应用时，一个常见的需求是 **人在回路（Human-in-the-Loop，简写HITL）**——让 Agent 在关键节点停下来，等人工审核/确认后再继续。LangGraph 提供了 `interrupt` 机制来实现这一功能。

本文将带你从零开始理解 interrupt，先讲清楚概念，再用代码一步步深入，最后总结踩坑经验。


## 什么是 interrupt？

`interrupt` 是 LangGraph 提供的一个函数，调用它可以让当前正在执行的图在某个节点 **暂停（暂停整个图，不是只暂停当前节点）**，等待外部通过 `Command(resume=...)` 恢复执行。

它的典型工作流程：

```
用户输入 → LLM 推理 → 调用工具 → 工具内 interrupt()
                                     ↓
                              图暂停，等待 resume
                                     ↓
                        外部调用 Command(resume=data)
                                     ↓
                              工具继续执行 → 返回结果给 LLM → 输出
```

关键特性：

1. **暂停是整个图级别的** — 不只是退出当前节点，整个 `graph.stream()` 调用都会返回
2. **需要 checkpointer** — 没有 checkpoint，interrupt 无法保存状态
3. **恢复需要 resume** — 使用 `Command(resume=...)` 从暂停点恢复

<!-- more -->

## 从最简单的例子开始

我们先不看 AI Agent，写一个最简单的例子理解 interrupt 的基本行为。

```python
from langgraph.graph import StateGraph, START
from langgraph.types import interrupt, Command
from langgraph.checkpoint.memory import InMemorySaver
from langchain_core.runnables import RunnableConfig
from typing import TypedDict


class State(TypedDict):
    value: str


def my_node(state: State):
    print(f"[my_node] 开始执行，state = {state}")

    # 暂停，等待人工输入
    result = interrupt("这是一个中断点")

    print(f"[my_node] 恢复执行，收到 result = {result}")
    return {"value": result}


graph = (
    StateGraph(State)
    .add_node("my_node", my_node)
    .add_edge(START, "my_node")
    .compile(checkpointer=InMemorySaver())
)

config: RunnableConfig = {"configurable": {"thread_id": "1"}}

# 第一轮：执行到 interrupt 就暂停
print("=== 第一轮 stream ===")
events = graph.stream({"value": "初始值"}, config)
for event in events:
    print(event)

# 查看中断状态
snapshot = graph.get_state(config)
print(f"\n下一节点: {snapshot.next}")
print(f"中断信息: {snapshot.tasks[0].interrupts}\n")

# 第二轮：resume 恢复执行
print("=== 第二轮 stream（resume）===")
events = graph.stream(Command(resume="人工输入数据"), config)
for event in events:
    print(event)
```

执行结果：

```
=== 第一轮 stream ===
[my_node] 开始执行，state = {'value': '初始值'}
=== stream 结束 ===
下一节点: ('my_node',)
中断信息: (Interrupt(value='这是一个中断点', resumable=True, ...),)

=== 第二轮 stream（resume）===
[my_node] 开始执行，state = {'value': '初始值'}
[my_node] 恢复执行，收到 result = 人工输入数据
=== stream 结束 ===
```

### 需要注意的关键细节

观察上面的输出——**`my_node` 函数在 resume 时又从头执行了一遍**。这是 interrupt 最重要的行为：

- **第一次**：执行到 `interrupt()`，抛异常暂停
- **恢复后**：节点函数**从头重新执行**，但这次 `interrupt()` 不抛异常，直接返回 `resume` 的值

这意味着：**`interrupt()` 之前的代码会在每次执行 + 每次恢复时都跑一次**，必须保证它没有副作用，或者副作用是幂等的。


## interrupt 放在工具里：AI Agent 场景

理解了基本机制后，我们把它用在实际的 AI Agent 场景中。最常见的做法是把 `interrupt` 放在一个工具函数里，让 LLM 自主决定何时需要人工介入。

### 完整代码

```python
from typing import Annotated, TypedDict
from typing_extensions import NotRequired

from langgraph.graph import StateGraph, START
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.checkpoint.memory import InMemorySaver
from langgraph.types import interrupt, Command
from langchain.chat_models import init_chat_model
from langchain_core.tools import tool
from langchain_core.messages import HumanMessage, ToolMessage
from langchain_core.tools import InjectedToolCallId
from langchain_tavily import TavilySearch


class State(TypedDict):
    """图的状态。name 和 birthday 是可选的，初始时可能没有。"""

    messages: Annotated[list, add_messages]
    name: NotRequired[str]
    birthday: NotRequired[str]


# ====================
# 工具定义：human_assistance
# ====================
@tool
def human_assistance(
    name: str,
    birthday: str,
    tool_call_id: Annotated[str, InjectedToolCallId],
) -> Command:
    """当需要人工确认或补充信息时，调用此工具。"""
    # 暂停图，向外部展示当前信息并等待人工反馈
    human_response = interrupt({
        "question": "请确认以下信息是否正确？",
        "name": name,
        "birthday": birthday,
    })

    if human_response.get("correct", "").lower().startswith("y"):
        verified_name = name
        verified_birthday = birthday
        response = "信息已确认正确"
    else:
        verified_name = human_response.get("name", name)
        verified_birthday = human_response.get("birthday", birthday)
        response = f"已根据人工反馈修正: {human_response}"

    # 使用 Command(update=...) 更新 state
    return Command(
        update={
            "name": verified_name,
            "birthday": verified_birthday,
            "messages": [ToolMessage(content=response, tool_call_id=tool_call_id)],
        }
    )


# ====================
# 组装图
# ====================
llm = init_chat_model("gpt-4o")
tavily = TavilySearch(max_results=2)
tools = [tavily, human_assistance]
llm_with_tools = llm.bind_tools(tools)


def chatbot(state: State):
    response = llm_with_tools.invoke(state["messages"])
    return {"messages": [response]}


graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)
graph_builder.add_node("tools", ToolNode(tools=tools))
graph_builder.add_conditional_edges("chatbot", tools_condition)
graph_builder.add_edge("tools", "chatbot")
graph_builder.add_edge(START, "chatbot")

graph = graph_builder.compile(checkpointer=InMemorySaver())
```

### 使用方式

```python
config: RunnableConfig = {"configurable": {"thread_id": "1"}}

# 第一轮：触发 LLM 调用 human_assistance
events = graph.stream(
    {
        "messages": [
            HumanMessage(
                content="查一下 AI Agent 是什么时候提出的概念，然后用 human_assistance 让我确认"
            )
        ]
    },
    config,
    stream_mode="values",
)
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()

# 查看中断状态
snapshot = graph.get_state(config)
print(f"当前中断: {snapshot.tasks[0].interrupts}")

# 第二轮：resume 恢复
events = graph.stream(
    Command(resume={"correct": "y", "name": "AI Agent", "birthday": "1950s"}),
    config,
    stream_mode="values",
)
for event in events:
    if "messages" in event:
        event["messages"][-1].pretty_print()

# 最终 state 中已经保存了 name 和 birthday
final = graph.get_state(config)
print(f"name = {final.values.get('name')}")
print(f"birthday = {final.values.get('birthday')}")
```

## Node 直接使用 interrupt

interrupt **不限于放在工具里**。一个常见的场景是：在某个业务节点中需要人工审批，而不是让 LLM 决定。

```python
import json
from typing import TypedDict


class ApprovalState(TypedDict):
    draft: str  # 待审核的草稿
    approved: bool  # 是否通过
    feedback: str  # 审核反馈


def draft_generator(state: ApprovalState):
    """生成草稿内容（模拟）"""
    draft = "这是系统自动生成的报告草稿..."
    return {"draft": draft}


def human_review(state: ApprovalState):
    """人工审核节点：暂停等待审批"""
    result = interrupt({
        "type": "approval",
        "draft": state["draft"],
        "message": "请审核以上草稿，通过或修改？",
    })
    return {
        "approved": result.get("approved", False),
        "feedback": result.get("feedback", ""),
    }


def finalize(state: ApprovalState):
    """根据审核结果做后续处理"""
    if state["approved"]:
        return {"draft": f"{state['draft']}\n\n[已审核通过]"}
    else:
        return {"draft": f"{state['draft']}\n\n[需修改: {state['feedback']}]"}


graph = (
    StateGraph(ApprovalState)
    .add_node("generate", draft_generator)
    .add_node("review", human_review)
    .add_node("finalize", finalize)
    .add_edge(START, "generate")
    .add_edge("generate", "review")
    .add_edge("review", "finalize")
    .compile(checkpointer=InMemorySaver())
)
```

这种用法更贴近传统的工作流引擎中的"人工任务节点"，**不需要 LLM 参与决策**，纯粹由业务流程驱动。

## 多个 interrupt 在同一节点

一个节点里可以有多个 `interrupt` 调用，实现多轮对话式的人工交互：

```python
def multi_step_review(state):
    # 第一轮审核
    approval_1 = interrupt({"step": 1, "content": state["draft"]})

    # ... 根据第一轮反馈修改 draft ...

    # 第二轮审核
    approval_2 = interrupt({"step": 2, "content": state["updated_draft"]})

    return {"draft": approval_2.get("final_version", state["updated_draft"])}
```

每次恢复时节点从头执行，但依次经过每个 `interrupt`。注意这里的幂等性问题——如果中间有副作用（比如修改外部系统），重新执行时会重复执行。

## 底层实现原理

前面我们讲了"怎么用"，现在打开 LangGraph 源码看看"怎么实现"。理解了底层机制，前面所有看似"反直觉"的行为（节点重跑、必须 checkpointer、多个 interrupt 按顺序匹配 resume）就都顺理成章了。

> 以下源码来自 `langgraph/types.py` 和 `langgraph/errors.py`（langgraph v1.x 系列）。

### 1. interrupt 函数本体：就 30 行代码

`interrupt()` 函数本身非常简短，去掉注释后核心逻辑如下：

```python
def interrupt(value: Any) -> Any:
    from langgraph._internal._constants import (
        CONFIG_KEY_CHECKPOINT_NS,
        CONFIG_KEY_SCRATCHPAD,
        CONFIG_KEY_SEND,
        RESUME,
    )
    from langgraph.config import get_config
    from langgraph.errors import GraphInterrupt

    conf = get_config()["configurable"]
    # 1. 取出本次任务的 scratchpad（草稿本）
    scratchpad = conf[CONFIG_KEY_SCRATCHPAD]
    # 2. 当前是节点内第几个 interrupt（从 0 计数）
    idx = scratchpad.interrupt_counter()

    # 3. 如果 scratchpad 里已有该位置的 resume 值，直接返回
    if scratchpad.resume:
        if idx < len(scratchpad.resume):
            conf[CONFIG_KEY_SEND]([(RESUME, scratchpad.resume)])
            return scratchpad.resume[idx]

    # 4. 否则看看是否有"待消费"的 null resume 值
    v = scratchpad.get_null_resume(True)
    if v is not None:
        assert len(scratchpad.resume) == idx
        scratchpad.resume.append(v)
        conf[CONFIG_KEY_SEND]([(RESUME, scratchpad.resume)])
        return v

    # 5. 都没有 → 抛 GraphInterrupt 异常暂停
    raise GraphInterrupt((
        Interrupt.from_ns(value=value, ns=conf[CONFIG_KEY_CHECKPOINT_NS]),
    ))
```

里面有几个关键概念：

| 概念 | 作用 |
|------|------|
| `scratchpad` | 当前任务（一次节点执行）的临时存储，记录已收集的 resume 值列表 |
| `interrupt_counter()` | 同一节点内第几次调用 `interrupt`（0, 1, 2 ...），用来区分多个 interrupt |
| `scratchpad.resume` | 本次任务已知的 resume 值列表（按 interrupt 出现顺序排列） |
| `GraphInterrupt` | LangGraph 内部用于"暂停"的异常类 |

### 2. GraphInterrupt：暂停的"信号"

```python
# langgraph/errors.py
class GraphInterrupt(GraphBubbleUp):
    """Raised when a subgraph is interrupted, suppressed by the root graph."""

    def __init__(self, interrupts: Sequence[Interrupt] = ()) -> None:
        super().__init__(interrupts)
```

注意它继承自 `GraphBubbleUp`——这是一类"会从子图一路冒泡到根图"的特殊异常。LangGraph 的执行引擎（Pregel runner）会专门捕获这类异常，把它当作"中断信号"而非"错误"。

### 3. 一次完整的中断与恢复，发生了什么？

把 `interrupt` 函数和 Pregel 执行引擎结合起来看，完整流程是这样的：

#### 阶段 A：第一次执行（暂停）

```
graph.stream(input, config)
  │
  ├─► Pregel runner 从 checkpoint 读取 state
  ├─► 把节点函数作为一个 "task" 调度执行
  │     │
  │     ├─► 为该 task 创建 scratchpad（resume=[], counter=0）
  │     ├─► 进入节点函数
  │     │     │
  │     │     ├─► 执行到 interrupt(value)
  │     │     │     ├─► idx = 0
  │     │     │     ├─► scratchpad.resume 为空
  │     │     │     ├─► 没有 null resume
  │     │     │     └─► raise GraphInterrupt(Interrupt(value=...))
  │     │     └─► 异常向上抛出
  │     │
  │     └─► runner 捕获 GraphInterrupt
  │           ├─► 把 Interrupt 写入 checkpoint 的 pending tasks
  │           └─► 把 task 标记为"未完成，等待 resume"
  │
  └─► 当前 super-step 结束，stream() 把 __interrupt__ 事件吐给客户端，generator 退出
```

关键点：**异常被 runner 吃掉了**，所以你的代码看不到异常，只会看到 `stream()` 提前返回。

#### 阶段 B：第二次执行（恢复）

```
graph.stream(Command(resume=X), config)
  │
  ├─► Pregel runner 从 checkpoint 读取 state（包含 pending interrupts）
  ├─► 看到入参是 Command(resume=X)，把 X 注入到对应 task 的 scratchpad
  ├─► 重新调度该 task —— 注意是从节点函数入口重新调度
  │     │
  │     ├─► 创建新 scratchpad（resume=[], counter=0）
  │     │   但 runner 会把 Command 里的 X 作为 "null resume" 注入进来
  │     ├─► 进入节点函数（从头开始）
  │     │     │
  │     │     ├─► （interrupt 之前的所有代码再跑一次）
  │     │     │
  │     │     ├─► 执行到 interrupt(value)
  │     │     │     ├─► idx = 0
  │     │     │     ├─► get_null_resume() → 返回 X
  │     │     │     ├─► scratchpad.resume = [X]
  │     │     │     └─► return X       ← 不抛异常！
  │     │     │
  │     │     └─► 继续执行 interrupt 之后的代码 → 正常 return
  │     │
  │     └─► runner 拿到节点返回值，写回 checkpoint
  │
  └─► 图沿边继续执行后续节点 → stream() 正常吐出更多事件 → 结束
```

### 4. 为什么多个 interrupt 要靠"顺序"匹配？

回到源码这两行：

```python
idx = scratchpad.interrupt_counter()  # 当前是第几个 interrupt
if idx < len(scratchpad.resume):
    return scratchpad.resume[idx]  # 按下标取对应 resume 值
```

如果一个节点里有 3 个 `interrupt`，那么三次 resume 后，`scratchpad.resume` 会是一个长度为 3 的列表：`[v0, v1, v2]`。第 N 次进入节点重跑时：

- 第 0 个 interrupt → 返回 `resume[0]`
- 第 1 个 interrupt → 返回 `resume[1]`
- 第 2 个 interrupt → 还没有，抛 GraphInterrupt

这就是为什么官方文档说"按 interrupt 在节点中出现的顺序匹配 resume 值"——本质是按 counter 下标匹配。

也正因如此，**在节点中加入有条件的 interrupt 是危险的**：如果第一次执行走了 if 分支调用了 `interrupt`，恢复时走了 else 分支跳过了 `interrupt`，counter 会错位，导致后续 interrupt 拿到错误的 resume 值。**结构性原则：interrupt 的调用顺序在节点的多次执行中必须保持一致。**

### 5. 为什么必须要 checkpointer？

到这里答案就一目了然了：

- 抛出 `GraphInterrupt` 时，runner 要把 `Interrupt` 对象写入 checkpoint
- 第二次 `graph.stream(Command(resume=X), ...)` 时，runner 要从 checkpoint 读出 pending task、读出当时的 state，才能"接着上次的地方"重新调度
- 如果没有 checkpointer，这些状态根本无处存放，调用 `interrupt` 时框架会直接报错

### 6. 串起来：所有"奇怪"行为的根本解释

| 现象 | 根本原因 |
|------|----------|
| 节点函数 resume 时从头重跑 | 因为 Pregel runner 的执行单元是"task"，task 失败/中断后只能重跑整个 task，不能恢复 Python 调用栈 |
| `interrupt()` 第一次抛异常、之后正常返回 | scratchpad 里有没有匹配下标的 resume 值决定了走哪条分支 |
| 多个 interrupt 按顺序匹配 | 用 counter 作为下标取 resume 列表 |
| 必须有 checkpointer | Interrupt 和 task 状态要落盘才能跨调用恢复 |
| 中断不闭合不能换话题 | pending interrupt 占着 checkpoint 中的 task 槽位，且 message 序列里有未配对的 tool_call |
| 同一节点的副作用会重复 | 节点重跑机制使然，框架无法判断哪些代码是副作用 |

理解了这个执行模型，你不仅能用好 interrupt，还能在出问题时知道往哪儿查——比如卡住时去 `get_state()` 看 pending tasks，把整个执行过程当作"一系列可重放的 task"来思考，问题就清晰多了。


## 6 个核心疑问（FAQ）

### Q1: interrupt 暂停后，不 resume 直接喂新输入会怎样？

**会出问题。** 同一个 thread_id 下，如果中断没被 resume，直接 `graph.stream({"messages": [新消息]})` 会导致：

1. LLM 上一轮发出的 `AIMessage(tool_calls=[...])` 没有配对的 `ToolMessage`
2. 下一轮 LLM 调用时，因为消息序列中 tool_call 缺少对应响应，LLM API 会报 `400 BadRequestError`
3. 即使不报错，state 里也会留下脏数据

**正确做法：**

- 换一个 `thread_id`（开新会话）
- 或者先 `Command(resume=...)` 让中断闭合，再问新问题
- 或者手动 `update_state` 注入 ToolMessage

### Q2: resume 时节点为什么从头执行？

这是 LangGraph 的设计选择。图的执行单元是"节点"，不是"节点里的某一行"。中断时节点执行被 `GraphInterrupt` 异常中断，恢复时运行时重新调用该节点函数。因为 `interrupt()` 的实现原理是——第一次调用时抛出 `GraphInterrupt`，恢复时不再抛出而直接返回 resume 的值。

### Q3: 怎么保证 interrupt 之前的代码是幂等的？

- 不要把非幂等操作放在 `interrupt` 之前
- 如果需要发邮件、写数据库，放在 `interrupt` 之后
- 或者用一个 flag 控制：

```python
def safe_node(state):
    if "already_done" not in state:
        send_email()  # 只在第一次执行
        state["already_done"] = True
    result = interrupt(...)
    ...
```

### Q4: 多个节点都有 interrupt，怎么区分是哪个？

`get_state(config)` 返回的 `snapshot.tasks` 里有完整的 `interrupts` 信息，包含节点名、payload 等。可以根据 `tasks[0].name` 来判断当前停在哪个节点。

### Q5: 可以不用 Command(resume=...) 而用其他方式恢复吗？

可以用 `graph.update_state(...)` 配合 `Command(resume=...)` 来实现更复杂的恢复逻辑。但最直接的方式始终是 `graph.stream(Command(resume=data), config)`。

### Q6: 怎么取消一个中断（用户说算了）？

有两种"取消"语义：

- **普通取消**：`Command(resume={"action": "cancel"})`，在函数中根据 `action` 做清理，然后返回正常的 ToolMessage 闭合调用
- **彻底丢弃线程**：`graph.delete_state(config)` 删除整个 checkpoint（部分 backends 支持）


## 原理速览

```
graph.stream(input, config)
  └─→ checkpoint 读取当前状态
      └─→ 执行节点函数
          └─→ 遇到 interrupt(...)
              ├─→ 抛出 GraphInterrupt
              ├─→ 运行时捕获异常
              ├─→ payload 写入 checkpoint
              └─→ stream() 返回，generator 耗尽

... 外部代码拿到控制权 ...

graph.stream(Command(resume=X), config)
  └─→ checkpoint 读取中断状态
      └─→ 重新调用节点函数
          └─→ 再次遇到 interrupt(...)
              ├─→ 检查 checkpoint 中有 resume 值
              └─→ 直接返回 X，不抛异常
          └─→ 节点继续往下执行
          └─→ 返回结果
      └─→ 图继续执行后续节点
      └─→ stream() 正常结束
```

核心就是 **GraphInterrupt 异常** + **checkpoint 状态持久化** + **scratchpad 顺序匹配 resume 值** 三件套。

## 总结

| 特性 | 说明 |
|------|------|
| 本质 | 基于异常的暂停机制，暂停整个图的执行 |
| 位置 | 任何节点函数（普通节点 / 工具节点） |
| 前提 | 必须有 checkpoint 保存中断状态 |
| 恢复 | `Command(resume=...)` |
| 幂等 | `interrupt` 之前的代码会重跑，需保证幂等 |
| 生命周期 | 一个 thread_id 下的中断必须被 resume，否则不能在同一线程中继续 |

理解了 interrupt，你就掌握了 LangGraph 中人在回路的核心能力。结合 checkpoint 的持久化（如 `SqliteSaver`、`PostgresSaver`），还可以实现跨进程、跨服务器的持久化暂停与恢复——这才是生产级 Agent 系统的关键基础设施。