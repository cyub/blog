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

| 型变类型 | 数学表达 | 通俗含义 | Python 语法 |
|---------|---------|---------|------------|
| **协变** (Covariant, +T) | `Dog <: Animal` ⇒ `Container[Dog] <: Container[Animal]` | 子类→父类（只读安全） | `TypeVar('T', covariant=True)` |
| **逆变** (Contravariant, -T) | `Dog <: Animal` ⇒ `Container[Animal] <: Container[Dog]` | 父类→子类（只处理安全） | `TypeVar('T', contravariant=True)` |
| **不变** (Invariant) | 无继承关系 | 必须完全匹配 | `TypeVar('T')`（默认） |

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

#### 不要这样写：
```python
def process_patients(wards: list[Animal]) -> None: ...
```
问题：限制了输入类型（必须是 list），且 list 是不变的。

#### 应该这样写：
```python
from typing import Sequence

def process_patients(wards: Sequence[Animal]) -> None: ...
```
优势：
- 支持 list、tuple、自定义容器
- `Sequence` 是协变的，灵活性更高

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