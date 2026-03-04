---
title: Python 类型注解完全指南
authors: 
  - Tinker
tags:
  - 编程语言/Python
  - 入门指南
categories:
  - 编程语言
date: 2026-03-04 23:26:00
---

## 为什么要用类型注解？

Python 是一门**动态类型语言**，变量类型在运行时才确定。这种灵活性带来了快速开发的优势，但也埋下了隐患：

```python
# 没有类型注解时，这个 bug 可能在生产环境才暴露
def calculate_total(price, quantity):
    return price * quantity

# 调用者可能传入错误类型，而 Python 不会提前报错
result = calculate_total("100", "5")  # 结果是 "100100100100100"，而非 500
```

**类型注解（Type Hints）** 在 **PEP 484**（Python 3.5）中引入，它解决了以下核心痛点：

| 痛点 | 解决方案 |
|------|---------|
| **IDE 智能提示弱** | PyCharm/VSCode 能基于类型提供精准的自动补全和跳转 |
| **代码可读性差** | 函数签名即文档，无需阅读实现即可了解接口 |
| **重构风险高** | 修改函数参数时，类型检查器能发现所有调用点 |
| **团队协作难** | 接口契约显性化，减少沟通成本 |
| **文档不同步** | 类型注解即实时文档，不会过时 |

<!-- more -->

!!! warning "关键观念：类型注解 ≠ 类型检查"

    ```python
    def greet(name: str) -> str:
        return f"Hello, {name}"

    # 类型注解不会阻止运行时错误！
    greet(123)  # 完全合法，运行时会得到 "Hello, 123"
    ```

    Python 解释器**完全忽略**类型注解。要获得类型检查能力，必须使用 **mypy**、**pyright** 等静态类型检查工具。

## 基础语法

### 变量注解

```python
# 基础类型
age: int = 25
name: str = "Alice"
pi: float = 3.14159
is_valid: bool = True

# 无需立即赋值（Python 3.6+）
items: list[str]  # 声明类型，稍后赋值
items = ["apple", "banana"]
```

### 函数注解

```python
def add(a: int, b: int) -> int:
    """返回两个整数的和"""
    return a + b

# 无返回值
def log_message(msg: str) -> None:
    print(f"[LOG] {msg}")

# 多返回值（实际上是返回 tuple）
def get_user() -> tuple[int, str]:
    return 1, "Alice"
```

### 常用内置类型

```python
from typing import List, Dict, Tuple, Set, Optional, Union

# Python 3.9+ 推荐使用内置类型的泛型语法（小写）
numbers: list[int] = [1, 2, 3]
config: dict[str, float] = {"learning_rate": 0.01}
point: tuple[int, int] = (10, 20)
unique_ids: set[str] = {"a", "b", "c"}

# Python 3.8 及以下需要使用 typing 模块（大写）
numbers_legacy: List[int] = [1, 2, 3]
config_legacy: Dict[str, float] = {"learning_rate": 0.01}
```

## typing 模块核心类型（兼容旧版本）

在 Python 3.9 之前，内置类型（`list`, `dict` 等）不支持下标操作，必须使用 `typing` 模块。

### 容器类型

```python
from typing import List, Dict, Tuple, Set, FrozenSet

# 列表
scores: List[int] = [85, 90, 78]

# 字典
user_map: Dict[str, int] = {"alice": 1, "bob": 2}

# 元组（固定长度）
coordinate: Tuple[float, float] = (120.5, 30.2)

# 元组（变长，同类型）
values: Tuple[int, ...] = (1, 2, 3, 4, 5)

# 集合
tags: Set[str] = {"python", "typing"}
```

### Optional 与 Union

```python
from typing import Optional, Union

# Optional[X] 等价于 Union[X, None]
def find_user(user_id: int) -> Optional[str]:
    """可能返回用户名，也可能返回 None"""
    if user_id == 1:
        return "Alice"
    return None

# Union 表示"或"关系
def parse_value(value: str) -> Union[int, float, str]:
    """可能返回 int、float 或 str"""
    try:
        return int(value)
    except ValueError:
        try:
            return float(value)
        except ValueError:
            return value
```

### 特殊类型

```python
from typing import Any, NoReturn, Callable

# Any：表示任意类型（尽可能避免使用）
def legacy_function(data: Any) -> Any:
    return data

# NoReturn：表示函数永不正常返回（总是抛出异常或无限循环）
def raise_error(msg: str) -> NoReturn:
    raise ValueError(msg)

# Callable：函数类型
# Callable[[参数类型列表], 返回值类型]
def execute_callback(
    callback: Callable[[int, int], int],
    a: int,
    b: int
) -> int:
    return callback(a, b)

# 使用
def add(x: int, y: int) -> int:
    return x + y

result = execute_callback(add, 3, 4)  # 7
```

### 泛型基础

```python
from typing import TypeVar, Generic, List

# 定义类型变量
T = TypeVar('T')

# 泛型函数
def first(items: List[T]) -> T:
    return items[0]

# 泛型类
class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: List[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()

# 使用
int_stack: Stack[int] = Stack()
int_stack.push(1)
int_stack.push(2)
# int_stack.push("hello")  # 类型检查器会报错
```


## 现代 Python 类型语法（3.9+）

Python 3.9 引入了 **PEP 585**，允许使用内置类型的**小写形式**作为泛型，代码更简洁且性能更好。

### 原生泛型

```python
# ✅ Python 3.9+ 推荐写法
def process_data(
    items: list[int],
    mapping: dict[str, list[float]],
    flags: set[str]
) -> tuple[int, str]:
    total = sum(items)
    return total, "done"

# 集合抽象基类（collections.abc）
from collections.abc import Sequence, Mapping, Iterable, Callable

def process_sequence(data: Sequence[int]) -> int:
    return sum(data)

def process_mapping(data: Mapping[str, int]) -> list[str]:
    return list(data.keys())

def apply_func(
    items: Iterable[int],
    func: Callable[[int], bool]
) -> list[int]:
    return [x for x in items if func(x)]
```

**迁移建议**：

- 新项目直接使用 `list[int]`, `dict[str, int]`
- 旧项目使用 `from __future__ import annotations`（Python 3.7+）提前使用新语法

### `|` 运算符表示 Union（3.10+）

```python
# ✅ Python 3.10+ 推荐写法
def find_user(user_id: int) -> str | None:
    ...

def parse_value(value: str) -> int | float | str:
    ...

# 替代 Optional
def maybe_int(x: str) -> int | None:  # 替代 Optional[int]
    ...
```

**优势**：

- 更简洁，无需从 `typing` 导入
- 可读性更强：`int | str | None` 直观表示"或"关系


## 最新版本重要更新（3.11+）

### Self 类型（3.11+，PEP 673）

解决"返回当前类实例"的类型注解难题：

```python
from typing import Self

class Shape:
    def set_color(self, color: str) -> Self:
        self.color = color
        return self
    
    def scale(self, factor: float) -> Self:
        self.factor = factor
        return self

class Circle(Shape):
    def set_radius(self, r: float) -> Self:
        self.radius = r
        return self

# 链式调用保持正确类型
circle = Circle().set_color("red").set_radius(5.0)  # 类型推断为 Circle，不是 Shape
```

### reveal_type() 调试神器

```python
def process(x: int | str) -> None:
    if isinstance(x, int):
        reveal_type(x)  # 类型检查器会输出：Revealed type is "int"
    else:
        reveal_type(x)  # Revealed type is "str"
```

### Never 类型（3.11+）

```python
from typing import Never

def handle_impossible_case(value: Never) -> None:
    """这个函数不应该被调用，因为 Never 表示不可能存在的类型"""
    pass

def exhaustive_check(x: int | str) -> None:
    if isinstance(x, int):
        print(f"Integer: {x}")
    elif isinstance(x, str):
        print(f"String: {x}")
    else:
        # 如果上面覆盖了所有情况，这里的 x 类型是 Never
        handle_impossible_case(x)  # 类型检查器会验证穷尽性
```

### TypeIs（3.13+，PEP 742）

比 `TypeGuard` 更严格的类型收窄：

```python
from typing import TypeIs

def is_str_list(val: list[object]) -> TypeIs[list[str]]:
    """如果返回 True，类型检查器确定 val 是 list[str]"""
    return all(isinstance(x, str) for x in val)

def process(items: list[object]) -> None:
    if is_str_list(items):
        # items 被收窄为 list[str]
        print(", ".join(items))
```


## 泛型编程核心技巧

### TypeVar 高级用法

```python
from typing import TypeVar, Generic

# 基本 TypeVar
T = TypeVar('T')

# 限定类型范围（bound）
Number = TypeVar('Number', int, float, complex)

def add_numbers(x: Number, y: Number) -> Number:
    return x + y

# 上界约束（可以是该类型或其子类）
from collections.abc import Sequence
SeqT = TypeVar('SeqT', bound=Sequence[int])

def first_item(seq: SeqT) -> int:
    return seq[0]

# 协变（covariant）与逆变（contravariant）
# 协变：子类型关系保持不变（常用于返回值）
T_co = TypeVar('T_co', covariant=True)

# 逆变：子类型关系反转（常用于参数）
T_contra = TypeVar('T_contra', contravariant=True)

class Container(Generic[T_co]):
    """协变：Container[Dog] 是 Container[Animal] 的子类型"""
    def __init__(self, item: T_co) -> None:
        self._item = item
    
    def get(self) -> T_co:
        return self._item

class Handler(Generic[T_contra]):
    """逆变：Handler[Animal] 是 Handler[Dog] 的子类型"""
    def handle(self, item: T_contra) -> None:
        ...
```

### TypeAlias 与 type 语句（3.12+）

```python
from typing import TypeAlias

# Python 3.10+
Vector: TypeAlias = list[float]
Matrix: TypeAlias = list[Vector]
JsonValue: TypeAlias = dict[str, "JsonValue"] | list["JsonValue"] | str | int | float | bool | None

# Python 3.12+ 更简洁的语法
type Vector = list[float]
type Matrix = list[Vector]
type JsonValue = dict[str, JsonValue] | list[JsonValue] | str | int | float | bool | None

def scale_vector(v: Vector, factor: float) -> Vector:
    return [x * factor for x in v]
```


## Protocol：结构型鸭子类型

Protocol 是 Python 类型系统中最具生产力的特性之一，它支持**结构化子类型**（鸭子类型）。

```python
from typing import Protocol, runtime_checkable
from collections.abc import Iterable

# 定义协议（接口）
class Drawable(Protocol):
    def draw(self) -> None:
        ...

class Resizable(Protocol):
    def resize(self, scale: float) -> None:
        ...

# 组合协议
class InteractiveWidget(Drawable, Resizable, Protocol):
    def handle_click(self, x: int, y: int) -> None:
        ...

# 无需显式继承，只要实现方法即可
class Button:
    def draw(self) -> None:
        print("Drawing button")
    
    def resize(self, scale: float) -> None:
        print(f"Resizing by {scale}")
    
    def handle_click(self, x: int, y: int) -> None:
        print(f"Clicked at ({x}, {y})")

# 类型检查通过：Button 实现了 InteractiveWidget 的所有方法
def render_widget(widget: InteractiveWidget) -> None:
    widget.draw()
    widget.resize(1.5)

render_widget(Button())  # ✅ 合法

# @runtime_checkable 允许运行时检查（有性能开销）
@runtime_checkable
class Sized(Protocol):
    def __len__(self) -> int:
        ...

def count_items(obj: Sized) -> int:
    return len(obj)

print(isinstance([1, 2, 3], Sized))  # True
print(isinstance("hello", Sized))    # True
```

**与 Pydantic 结合**：

```python
from pydantic import BaseModel
from typing import Protocol

class HasId(Protocol):
    id: int

class User(BaseModel):
    id: int
    name: str

class Product(BaseModel):
    id: int
    price: float

def get_id(obj: HasId) -> int:
    return obj.id

# 两者都兼容 HasId 协议
user = User(id=1, name="Alice")
product = Product(id=2, price=9.99)
print(get_id(user), get_id(product))
```


## TypedDict：结构化字典

为字典提供精确的类型描述，常用于 JSON 数据。

```python
from typing import TypedDict, NotRequired, Required

# 基础用法（Python 3.8+）
class Movie(TypedDict):
    name: str
    year: int
    rating: float

movie: Movie = {
    "name": "Inception",
    "year": 2010,
    "rating": 8.8
}

# 可选字段（Python 3.11+ 使用 NotRequired）
class User(TypedDict):
    name: str
    age: NotRequired[int]  # 可选
    email: Required[str]   # 显式标记为必需（3.11+）

# Python 3.10 及以下使用 total=False
class PartialUser(TypedDict, total=False):
    name: str
    age: int

class FullUser(PartialUser):
    id: int  # 继承后，id 是必需的，name 和 age 仍是可选的

# 实际应用：API 响应
class APIResponse(TypedDict):
    status: str
    data: list[dict[str, object]]
    error: NotRequired[str]
```

## Callable 与函数类型高级用法

### 基础 Callable

```python
from collections.abc import Callable

# 函数作为参数
def apply_operation(
    numbers: list[int],
    operation: Callable[[int], int]
) -> list[int]:
    return [operation(n) for n in numbers]

# 函数作为返回值
def create_multiplier(factor: int) -> Callable[[int], int]:
    def multiply(x: int) -> int:
        return x * factor
    return multiply
```

### ParamSpec 与 Concatenate（3.10+）

实现保留原函数签名的装饰器：

```python
from typing import ParamSpec, TypeVar, Callable, Concatenate
from functools import wraps

P = ParamSpec('P')  # 捕获参数规格
R = TypeVar('R')    # 返回值类型

def with_logging(
    func: Callable[P, R]
) -> Callable[P, R]:
    @wraps(func)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Finished {func.__name__}")
        return result
    return wrapper

@with_logging
def add(a: int, b: int) -> int:
    return a + b

# 类型检查器知道 add 仍然接受 (int, int) -> int
result = add(1, 2)  # 正确推断

# Concatenate：在参数前添加固定参数
def with_prefix(
    func: Callable[Concatenate[str, P], R]
) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        return func("[PREFIX]", *args, **kwargs)
    return wrapper

@with_prefix
def greet(prefix: str, name: str, times: int) -> str:
    return f"{prefix} Hello, {name}! " * times

print(greet("Alice", 3))  # 只需传入 name 和 times，prefix 由装饰器添加
```


## 常用第三方类型库

### typing_extensions

**必须安装**的向后兼容库：

```bash
pip install typing_extensions
```

```python
# 在 Python < 3.11 中使用 3.11+ 的特性
from typing_extensions import Self, TypeVarTuple, Unpack, LiteralString

class Builder:
    def chain(self) -> Self:  # 3.8 也能用 Self
        return self
```

### Pydantic v2 类型系统

```python
from pydantic import BaseModel, Field, TypeAdapter, computed_field
from datetime import datetime
from typing import Literal

class Address(BaseModel):
    street: str
    city: str
    country: Literal["CN", "US", "UK"]  # 限制取值

class User(BaseModel):
    id: int
    name: str = Field(min_length=2, max_length=50)
    email: str = Field(pattern=r'^\S+@\S+\.\S+$')
    address: Address | None = None
    created_at: datetime = Field(default_factory=datetime.now)
    tags: set[str] = set()
    
    @computed_field
    @property
    def display_name(self) -> str:
        return f"{self.name} <{self.email}>"

# 运行时类型转换与验证
user = User(id=1, name="Alice", email="alice@example.com")
print(user.model_dump_json(indent=2))

# TypeAdapter：为任意类型创建验证器
IntList = TypeAdapter(list[int])
data = IntList.validate_python(["1", "2", "3"])  # [1, 2, 3]
```

### NumPy/Pandas 类型

```python
import numpy as np
import numpy.typing as npt

# NumPy 数组类型
Array2D = npt.NDArray[np.float64]

def matrix_multiply(a: Array2D, b: Array2D) -> Array2D:
    return np.dot(a, b)

# Pandas（需要 pandas-stubs）
import pandas as pd
from pandas import DataFrame, Series

def process_df(df: DataFrame) -> Series[float]:
    return df["value"].astype(float)
```


## 静态类型检查工具对比

| 工具 | 速度 | 严格度 | 生态支持 | 推荐场景 |
|------|------|--------|----------|----------|
| **mypy** | 中等 | ★★★★☆ | ★★★★★ | 大多数项目主力 |
| **pyright** | 很快 | ★★★★★ | ★★★★☆ | VSCode 用户、追求严格 |
| **pyre** | 快 | ★★★★☆ | ★★★☆☆ | Meta 风格项目 |
| **pytype** | 中等 | ★★★☆☆ | ★★★☆☆ | Google 风格、inference 强 |
| **Ruff** | 极快 | ★★★☆☆ | ★★★★★ | lint + 部分类型检查（2025+） |

**配置示例（pyproject.toml）**：

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
ignore_missing_imports = true

# 按文件配置
[[tool.mypy.overrides]]
module = "tests.*"
ignore_errors = true

[tool.pyright]
include = ["src"]
exclude = ["**/__pycache__"]
strict = ["src/core"]
pythonVersion = "3.11"
typeCheckingMode = "strict"
```


## 渐进式类型化策略

大型项目应采用**渐进式类型化**：

```ini
# mypy.ini：逐步开启严格模式
[mypy]
python_version = 3.11
ignore_missing_imports = True

# 先开启基础检查
disallow_untyped_defs = False
check_untyped_defs = False

# 核心模块逐步开启严格模式
[mypy-src/core/*]
disallow_untyped_defs = True
disallow_any_generics = True
no_implicit_optional = True
check_untyped_defs = True
```

**# type: ignore 的正确用法**：

```python
# ❌ 不要这样：忽略所有错误
result = some_untyped_function()  # type: ignore

# ✅ 明确指定错误代码（mypy --show-error-codes 查看）
result = some_untyped_function()  # type: ignore[no-untyped-call]

# ✅ 或者使用更窄的忽略范围
from typing import cast
result = cast(str, some_untyped_function())  # 显式类型断言
```

**Stub 文件（.pyi）**：

为无类型第三方库或 C 扩展编写类型存根：

```python
# mylibrary.pyi - 类型存根文件
def process_data(data: bytes) -> dict[str, object]: ...
class Client:
    def __init__(self, api_key: str) -> None: ...
    def get_user(self, user_id: int) -> User | None: ...
```


## 运行时类型检查与转换

```python
from typing import cast, assert_type

# cast：告诉类型检查器"相信我"
def process(data: object) -> str:
    # 我们知道这里一定是 str，但类型检查器不知道
    return cast(str, data).upper()

# assert_type（3.11+）：验证类型推断是否符合预期
x = [1, 2, 3]
assert_type(x, list[int])  # 如果推断不符会报错

# Pydantic TypeAdapter 运行时验证
from pydantic import TypeAdapter, ValidationError

validator = TypeAdapter(list[int])
try:
    result = validator.validate_python(["1", "2", "not_a_number"])
except ValidationError as e:
    print(e)
```


## 类型系统的边界与哲学

### 协变/逆变/不变

```python
from typing import TypeVar, Generic

# 协变（Covariant）：子类型关系保持不变
# 适用场景：只读容器、返回值
T_co = TypeVar('T_co', covariant=True)

class ImmutableList(Generic[T_co]):
    def __init__(self, items: list[T_co]) -> None:
        self._items = items
    
    def get(self, index: int) -> T_co:
        return self._items[index]

# Animal -> Dog 的子类型关系
# ImmutableList[Animal] 是 ImmutableList[Dog] 的父类型（因为可以安全地读取 Animal）

# 逆变（Contravariant）：子类型关系反转
# 适用场景：只写容器、参数
T_contra = TypeVar('T_contra', contravariant=True)

class Consumer(Generic[T_contra]):
    def consume(self, item: T_contra) -> None:
        ...

# 如果 Consumer[Animal] 能消费 Animal，它一定能消费 Dog
# 所以 Consumer[Animal] 是 Consumer[Dog] 的子类型

# 不变（Invariant）：默认行为，无修饰符
# 适用场景：可读写的容器
T = TypeVar('T')

class Box(Generic[T]):
    def get(self) -> T: ...
    def set(self, item: T) -> None: ...
# Box[Dog] 和 Box[Animal] 无子类型关系（防止把 Cat 放入 Dog 的盒子）
```


## 类型注解与性能

**mypyc**：将类型注解编译为 C 扩展，显著提升性能：

```bash
# 安装 mypyc
pip install mypy

# 编译带类型注解的模块
mypyc my_module.py

# 生成的 .so 文件可直接导入使用，性能接近原生 C
```

**PEP 695 新泛型语法（3.12+）的性能优势**：

```python
# 旧语法（运行时创建 TypeVar 对象）
from typing import TypeVar, Generic
T = TypeVar('T')
class Stack(Generic[T]): ...

# 新语法（编译时处理，零运行时开销）
class Stack[T]:
    def push(self, item: T) -> None: ...
    def pop(self) -> T: ...
```

## 生态现状与未来方向

- **PEP 695**（3.12+）：新泛型语法已成为主流
- **PEP 742**（Default type parameters）：简化泛型默认值
- **完全类型化迁移**：SQLAlchemy 2.0、httpx、aiohttp 等主流库已实现完整类型支持
- **Ruff 类型检查**：2025 年后 Ruff 的类型检查能力持续增强，可能成为一站式工具
