---
title: Python 泛型与型变完全指南：从宠物医院看类型安全
authors:
  - Tinker
tags:
  - 编程语言/Python
  - 泛型
categories:
  - 编程语言
date: 2026-04-06 10:40:00
---

## 引言：兽医科室的类型危机

假设你经营一家宠物医院。你有一个 **"犬科专科住院部"**，只收治狗狗。某天，由于"动物住院部"床位紧张，护士打算把一只刚送来的哈士奇安排进"犬科专科住院部"——毕竟狗也是动物，对吧？

问题出现了：如果允许这样做，其他医生可能基于"这是普通动物住院部"的认知，往里面收治一只猫。结果当你去查房时，期待看到一只狗，却发现笼子里是一只猫——**类型契约被破坏了**。

```python
class Animal: pass
class Dog(Animal): pass  
class Cat(Animal): pass

class Ward(Generic[T]):  # 住院部
    def admit(self, patient: T) -> None: ...      # 收治（写入）
    def discharge(self) -> T: ...                 # 出院（读取）

def general_ward(ward: Ward[Animal]) -> None:
    ward.admit(Cat())  # 对于普通动物病房，收治猫很合理！

dog_ward = Ward[Dog]()  # 犬科专科
general_ward(dog_ward)  # ❌ 类型检查器阻止了这一步！
# 如果允许：下一行会在运行时出问题
dog: Dog = dog_ward.discharge()  # 期望得到狗，结果可能是猫！
```

这个"猫住进犬科病房"的问题，引出了泛型编程中最核心的概念：**型变（Variance）**。

<!-- more -->

## 第一部分：泛型基础——类型系统的抽象能力

### 什么是泛型

泛型的本质是**让类型成为参数**，实现类型层面的抽象与复用：

```python
from typing import TypeVar, Generic

T = TypeVar("T")

class Cage(Generic[T]):  # 笼子
    def __init__(self, inhabitant: T):
        self.inhabitant = inhabitant
    
    def get(self) -> T:
        return self.inhabitant

# 使用
dog_cage = Cage[Dog](Dog())      # Cage[Dog]
cat_cage = Cage[Cat](Cat())      # Cage[Cat]
```

关键点：`Cage[Dog]` 和 `Cage[Cat]` 是**不同类型**，类型系统会严格区分。

### 为什么需要泛型

核心是：类型复用 + 类型约束。

没有泛型时，类型信息丢失：

```python
def get_first(animals: list) -> object:  # 返回 object，丢失类型
    return animals[0]

result = get_first([Dog(), Dog()])  # result 是 object，不是 Dog
```

使用泛型后：

```python
T = TypeVar("T")

def get_first(animals: list[T]) -> T:
    return animals[0]

result = get_first([Dog(), Dog()])  # 类型推导：result 是 Dog
```

## 第二部分：型变（Variance）——泛型的核心难题

型变回答的关键问题是：**不同泛型类型之间，能否互相赋值？**

### 三种型变关系

在泛型 `Generic[T]` 中，设 `Dog` 是 `Animal` 的子类：

| 型变类型 | 数学表达 | 类型兼容方向 | TypeVar 参数 | 适用场景 | 标准库示例
|---------|---------|---------|------------|------------|------------|
| **协变** (Covariant, +T) | `Dog <: Animal` ⇒ `Container[Dog] <: Container[Animal]` | 子类→父类（只读安全） | `TypeVar('T', covariant=True)` | 只读、返回值、生产者 | `Sequence[T]`、`Iterator[T]`
| **逆变** (Contravariant, -T) | `Dog <: Animal` ⇒ `Container[Animal] <: Container[Dog]` | 父类→子类（只处理安全） | `TypeVar('T', contravariant=True)` | `Callable[[T], None]`
| **不变** (Invariant) | 无继承关系 | 必须完全匹配 | `TypeVar('T')`（默认） | 只写、参数、消费者、回调 | `list[T]`、`dict[K, V]`

### 协变：只读的"病历档案"（Covariant）

**协变适用于生产者（Producers）**——只返回数据，不接收数据。

想象**宠物病历档案室**：医生只能查阅病历，不能修改。

```python
T_co = TypeVar('T_co', covariant=True)

class MedicalRecord(Generic[T_co]):
    """病历档案：只读，不能修改"""
    def __init__(self, patient: T_co):
        self._patient = patient
    
    def get_patient(self) -> T_co:
        return self._patient
    # 注意：没有 update_patient() 方法！

def review_animal_record(record: MedicalRecord[Animal]) -> None:
    print(f"Reviewing record of {type(record.get_patient()).__name__}")

# ✅ 安全：MedicalRecord[Dog] 可以当作 MedicalRecord[Animal] 使用
dog_record = MedicalRecord[Dog](Dog())
review_animal_record(dog_record)  # 输出：Reviewing record of Dog
```

**原理**：因为只能读取，从狗的病历里读出来的必然是狗，狗又是动物，所以符合"需要动物病历"的契约。类型关系保持：**Dog → Animal**。

### 逆变：只处理的"治疗能力"（Contravariant）

**逆变适用于消费者（Consumers）**——只接收数据进行处理，不返回该类型数据。

想象**兽医的治疗资质**：一个能治疗所有动物的兽医，当然可以胜任治疗狗的工作。

```python
T_contra = TypeVar('T_contra', contravariant=True)

class Veterinarian(Generic[T_contra]):
    """兽医：只负责治疗（消费）病人"""
    def treat(self, patient: T_contra) -> None:
        print(f"Treating {type(patient).__name__}")

def hire_dog_doctor(doc: Veterinarian[Dog]) -> None:
    dog = Dog()
    doc.treat(dog)

# ✅ 安全：Veterinarian[Animal] 可以当作 Veterinarian[Dog] 使用
general_vet = Veterinarian[Animal]()
hire_dog_doctor(general_vet)  # 输出：Treating Dog
```

**原理**：能治所有动物的兽医，当然能治狗。能力越"宽"（泛），兼容性越强。类型关系反转：**Animal → Dog**。

### 不变：可读可写的"住院部"（Invariant）

当容器既可读又可写时，**型变关系被禁止**：

```python
T = TypeVar('T')  # 默认不变

class Ward(Generic[T]):  # 住院部
    def admit(self, patient: T) -> None: ...      # 参数 T（逆变期望）
    def discharge(self) -> T: ...                 # 返回 T（协变期望）

# ❌ 以下两种替换都不安全：
# Ward[Dog] → Ward[Animal] (会导致犬科病房收治猫)
# Ward[Animal] → Ward[Dog] (可能出院的不是狗)
```

**关键结论**：只要泛型类对类型参数**既读又写**，就必须是**不变的**。这是 `list`、`dict` 等可变容器默认为不变的原因。

### 为什么 List 是不变的？

```python
dogs: list[Dog] = [Dog()]
animals: list[Animal] = dogs  # 假设这是合法的
animals.append(Cat())         # 合法操作：list[Animal] 可以添加任何动物
# 现在 dogs = [Dog(), Cat()] —— 破坏了 list[Dog] 的约束！
```

如果允许 `list[Dog]` 当作 `list[Animal]` 使用，那么通过父类型接口写入非 Dog 对象，会破坏原始列表的类型安全。

## 第三部分：Protocol——Python 的静态鸭子类型

### Protocol 解决的核心问题

传统继承强耦合，而 Protocol 提供**无侵入的接口定义**：

```python
from typing import Protocol

class Treatable(Protocol):
    def treat(self) -> None: ...

class Dog:
    def treat(self) -> None:  # 不需要继承 Treatable
        print("Dog treated")

def heal(patient: Treatable) -> None:
    patient.treat()

heal(Dog())  # ✅ 静态检查通过，无需继承
```

再看一个例子：

```python
from typing import Protocol

class Speaker(Protocol):
    def speak(self) -> str: ...

class Dog:
    def speak(self) -> str:  # 不需要继承 Speaker
        return "woof"

def make_sound(s: Speaker) -> None:
    print(s.speak())

make_sound(Dog())  # ✅ 静态检查通过，无需继承
```

### Protocol + 泛型：强大的抽象组合

```python
from typing import Protocol, TypeVar, Generic

T = TypeVar("T")

class Serializer(Protocol[T]):
    def serialize(self, obj: T) -> str: ...

class User:
    def __init__(self, name: str):
        self.name = name

class UserSerializer:
    def serialize(self, obj: User) -> str:
        return f"User({obj.name})"

def save_to_db(serializer: Serializer[User], user: User) -> None:
    data = serializer.serialize(user)
    print(f"Saving: {data}")

# 使用
save_to_db(UserSerializer(), User("Tom"))  # ✅
```

### Protocol + 逆变：回调系统的类型安全

在事件处理和回调系统中，逆变 Protocol 极其重要：

```python
T_contra = TypeVar("T_contra", contravariant=True)

class Handler(Protocol[T_contra]):
    def handle(self, event: T_contra) -> None: ...

class Animal: pass
class Dog(Animal): pass

class AnimalHandler:
    def handle(self, event: Animal) -> None:
        print(f"Handling {type(event).__name__}")

def register_dog_handler(h: Handler[Dog]) -> None:
    dog = Dog()
    h.handle(dog)

# ✅ AnimalHandler 可以处理 Animal，当然也能处理 Dog（逆变）
register_dog_handler(AnimalHandler())
```

这实现了里氏替换原则在类型层面的精确表达：能接受父类型的处理器，一定能处理子类型。

## 第四部分：工程实践与设计模式

### 型变决策树

设计泛型类时，使用以下流程：

```
这个类型参数用于？
├── 仅作为返回值（生产者）→ 协变 (covariant=True)
├── 仅作为函数参数（消费者）→ 逆变 (contravariant=True)
└── 既读又写 → 不变（默认）
```

### 标准库中的型变实例

- 不变：list[T]、set[T]、dict[K, V] —— 可增删改，必须精确匹配。
- 协变：Sequence[T]、Iterable[T]、Iterator[T]、Mapping[K, V] —— 只读，子类容器可替代。
- 逆变：Callable[[Arg1, Arg2], Return] 的参数部分是逆变的（允许更宽松的父类参数）。
- typing.Protocol + 协变/逆变：现代最佳实践，可实现“只读接口”与“只写接口”分离。

```python
from typing import Callable, Iterator, Sequence

# 协变：可以用具体类型替代抽象类型
def review_records(records: Iterator[Animal]) -> None: ...
dog_records: Iterator[Dog] = iter([Dog()])
review_records(dog_records)  # ✅ Iterator是协变的

# 逆变：参数位置
def hire_vet(vet: Callable[[Dog], None]) -> None: ...
general_vet: Callable[[Animal], None] = lambda a: print(a)
hire_vet(general_vet)  # ✅ Callable参数是逆变的

# 不变：必须完全匹配
def transfer_ward(ward: list[Animal]) -> None: ...
dog_ward: list[Dog] = [Dog()]
# transfer_ward(dog_ward)  # ❌ list是不变的
```

**关键记忆点**：`Callable[[T], R]` 中，**参数 T 是逆变，返回值 R 是协变**。

### API 设计最佳实践

在编写函数接口时，**参数类型应尽可能宽松（使用抽象基类）**，而**返回值类型应尽可能精确（使用具体类型）**。  
这样能极大提升代码的灵活性、复用性和类型安全性，同时避免不必要的类型兼容问题。

#### 不要过度使用具体可变容器作为参数

**不要这样写**（常见反例）：

```python
def process_patients(wards: list[Animal]) -> None: ...
def update_scores(scores: dict[str, int]) -> None: ...
def process_stream(lines: list[str]) -> None: ...
```

**问题**：

- `list`、`dict` 等内置可变容器是**不变（Invariant）** 的，无法利用协变优势。
- 限制了调用方：必须精确传入 `list`，而不能传入 `tuple`、自定义序列、生成器等。
- 如果传入子类容器（如 `list[Dog]` 给期望 `list[Animal]` 的函数），静态检查器（如 mypy）会报类型不匹配。

#### 推荐使用抽象只读类型（支持协变）

**应该这样写**（推荐写法）：

```python
from collections.abc import Sequence, Mapping, Iterable, Iterator

# 只读序列（推荐替代 list）
def process_patients(wards: Sequence[Animal]) -> None: ...

# 只读映射（推荐替代 dict）
def update_scores(scores: Mapping[str, int]) -> None: ...

# 只需迭代（最宽松，推荐用于 for 循环场景）
def process_stream(lines: Iterable[str]) -> None: ...

# 需要迭代器（消耗型场景）
def consume_iterator(it: Iterator[str]) -> None: ...
```

**优势**：

- **支持更多输入类型**：

  - `Sequence[Animal]` 支持 `list[Animal]`、`tuple[Animal]`、自定义序列类，甚至 `str`（如果是字符序列时需注意）。
  - `Mapping[str, int]` 支持 `dict[str, int]`、`collections.OrderedDict`、`types.MappingProxyType` 等所有只读映射。
  - `Iterable[T]` 支持列表、元组、集合、生成器、文件对象等几乎所有可迭代对象。
  - `Iterator[T]` 专门用于“一次性消耗”的迭代器场景（如 `iter()` 返回的对象）。

- **利用协变（Covariant）提升灵活性**：

  - `Sequence[T]`、`Iterable[T]`、`Mapping[K, V]` 在类型系统中被声明为**协变**。
  - 因此 `Sequence[Dog]` 可以安全地传递给 `Sequence[Animal]`（子类容器可替代父类容器）。
  - 这符合“只读”场景：函数只读取数据，不修改容器内容，类型替换是安全的。

- **Python 3.9+ 推荐写法**（内置泛型支持）：
  ```python
  # Python 3.9+ 可以直接用 collections.abc，无需从 typing 导入
  from collections.abc import Sequence, Mapping, Iterable

  def process_patients(wards: Sequence[Animal]) -> None: ...
  ```

#### 更多实用示例对比

**读取/处理数据场景（推荐 Sequence / Iterable）**：

```python
# 好：支持 list、tuple、range 等
def calculate_total(prices: Sequence[float]) -> float:
    return sum(prices)

# 更好：如果只需要遍历，不需要索引和长度，用 Iterable 更宽松
def log_all_items(items: Iterable[str]) -> None:
    for item in items:
        print(item)
```

**键值对处理场景（推荐 Mapping）**：

```python
# 好：支持 dict 和其他映射
def apply_config(config: Mapping[str, str]) -> None:
    for key, value in config.items():
        ...

# 注意：如果函数需要修改映射，应使用 MutableMapping（不变型变类型）
from collections.abc import MutableMapping

def update_config(config: MutableMapping[str, str]) -> None: ...
```

**迭代器专用场景（Iterator）**：

```python
def process_large_file(lines: Iterator[str]) -> None:
    for line in lines:      # 消耗迭代器
        if "error" in line:
            break
    # 迭代器已被消耗，后续无法再次遍历
```

**返回值场景（相反原则）**：

- 返回值建议用具体类型（如 `list`、`dict`），因为调用方通常需要可写或精确行为。
  ```python
  def get_all_patients() -> list[Animal]: ...   # 返回具体 list，便于调用方 append
  ```

#### 为什么抽象类型更好？（结合型变）

- **不变（list、dict）**：读 + 写都支持，必须类型精确匹配。适合内部实现或需要修改的场景。
- **协变（Sequence、Iterable、Mapping）**：只读场景，允许子类替代父类，更灵活。
- **不变的 Mutable 版本**（MutableSequence、MutableMapping）：需要修改时使用，但仍比内置 list/dict 更抽象。MutableMapping是字典的抽象接口，且由于可读可写，在泛型中表现为**不变型变**。

**Python 官方与 mypy 推荐**：

- 函数**参数**优先使用 `Iterable`、`Sequence`、`Mapping` 等抽象集合（只描述“需要什么能力”）。
- 这体现了 Python 的“鸭子类型”哲学：关注对象能做什么，而不是它是什么。

#### 避坑建议

1. **字符串陷阱**：`str` 也是 `Iterable[str]` 和 `Sequence[str]`，如果不想接受单个字符串，可用 `Sequence[str]` 并在运行时检查 `not isinstance(lines, (str, bytes))`，或使用自定义 `Protocol`。
2. **性能敏感场景**：`Iterable` 非常宽松，但可能隐藏多次迭代的问题（生成器只能迭代一次）。
3. **需要长度/索引时**：用 `Sequence` 而非 `Iterable`。
4. **需要修改时**：明确使用 `MutableSequence` 或 `MutableMapping`，避免意外。
5. **类型检查器行为**：在 mypy / Pyright 中，使用抽象类型通常能获得更好的错误提示和更少的假阳性。

**总结口诀**：

- **只读 + 遍历** → `Iterable[T]`（最宽松）
- **只读 + 需要索引/长度** → `Sequence[T]`
- **只读键值对** → `Mapping[K, V]`
- **可修改键值对** → `MutableMapping[K, V]`
- **参数宽松，返回精确** → API 设计的黄金法则


### 泛型装饰器的型变处理

```python
from typing import TypeVar, Callable, Any

R_co = TypeVar('R_co', covariant=True)

def log_treatment(func: Callable[..., R_co]) -> Callable[..., R_co]:
    def wrapper(*args: Any, **kwargs: Any) -> R_co:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_treatment
def get_dog() -> Dog:
    return Dog()

animal: Animal = get_dog()  # ✅ 协变保持子类型关系
```

## 第五部分：现代框架中的应用（FastAPI）

### 泛型响应模型

```python
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar("T")

class Response(BaseModel, Generic[T]):
    data: T
    code: int = 0

class Pet(BaseModel):
    name: str
    species: str

@app.get("/pet", response_model=Response[Pet])
def get_pet() -> Response[Pet]:
    return Response(data=Pet(name="Buddy", species="dog"))
```

### Protocol 在宠物医疗 SDK 中的应用

设计可插拔的第三方医疗设备接口：

```python
class XRayMachine(Protocol):
    """X光设备接口"""
    def scan(self, patient: Animal) -> bytes: ...
    def calibrate(self) -> None: ...

class SiemensXRay:
    def scan(self, patient: Animal) -> bytes:
        # 西门子设备实现
        pass
    def calibrate(self) -> None: ...

class GEXRay:
    def scan(self, patient: Animal) -> bytes:
        # GE设备实现  
        pass
    def calibrate(self) -> None: ...

# 使用
def perform_scan(machine: XRayMachine, patient: Animal) -> bytes:
    machine.calibrate()
    return machine.scan(patient)

# 可以无缝切换设备厂商
perform_scan(SiemensXRay(), Dog())
perform_scan(GEXRay(), Cat())
```

## 总结：型变的直觉法则

| 概念 | 宠物医院类比 | 语法 | 使用场景 |
|------|------------|------|---------|
| **协变** | "我只负责查看病历，所以可以查看狗的档案" | `covariant=True` | 返回值、迭代器、只读容器 |
| **逆变** | "我只负责治疗，所以能治所有动物的医生可以来治疗狗" | `contravariant=True` | 函数参数、回调、处理器 |
| **不变** | "我既收治又出院，必须严格匹配专科" | 默认 | 可变容器（list, dict, set）|

### 最终实践建议

1. **默认使用不变型变**（最安全）
2. **API 参数使用抽象类型**：`Sequence` 替代 `list`，`Mapping` 替代 `dict`
3. **设计时区分 Producer/Consumer**：只读就协变，只处理就逆变
4. **使用 Protocol 定义能力**：比 ABC 更轻量，支持静态鸭子类型
5. **记住 Callable 的型变**：参数逆变，返回值协变

下次当 mypy 对你的"完美代码"提出异议时，请记住：**它可能正在阻止一只猫住进你的犬科专科病房**。类型系统的严格不是束缚，而是保护——在编译期捕获那些可能在深夜生产环境中炸响的 runtime 错误。

**参考资源**：

- [PEP 484 – Type Hints](https://peps.python.org/pep-0484/)
- [PEP 544 – Protocols](https://peps.python.org/pep-0544/)
- [Mypy 文档 - Variance of Generic Types](https://mypy.readthedocs.io/en/stable/generics.html#variance-of-generic-types)
- [Python的泛型(Generic)与协变(Covariant)](https://zhuanlan.zhihu.com/p/703748124)
- [为什么 Python 阻止我把雪碧倒进可乐罐](https://shanechang.com/zh-cn/p/python-generics-sprite-in-coke-can/)