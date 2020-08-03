title: Golang设计模式系列开篇
author: tinker
tags:
  - 设计模式
categories: []
date: 2020-05-23 18:04:00
---
<blockquote class="blockquote-center">抽象是用来处理复杂性的主要工具。一个问题越复杂，就越需要抽象来解决</blockquote>

## 概念

设计模式这个术语是由Erich Gamma等人在1990年代从建筑设计领域引入到计算机科学的。在《Domain-Driven Terms》一书中，设计模式被描述为：

> 设计模式是命名、抽象和识别对可重用的面向对象设计有用的的通用设计结构。设计模式确定类和他们的实体、他们的角色和协作、还有他们的责任分配

> 每一个设计模式都聚焦于一个面向对象的设计难题或问题。它描述了在其它设计的约束下它能否使用，使用它后的后果和得失

<!--more-->

使用设计模式根本原因是**为了代码复用，增强代码的可维护性**，使用设计模式有以下好处：

1. **模式是行之有效的解决方法**。它提供固定的解决方法来解决在软件开发中出现的问题，这些都是久经考验的。

2. **模式可以很容易地重用**。一个模式通常反映了一个可以适应自己需要的开箱即用的解决方案。这个特性让它们很健壮。

3. **模式善于表达**。当我们看到一个提供某种解决方案的模式时，一般有一组结构和词汇可以非常优雅地帮助表达相当大的解决方案。


## 设计原则

评价一个设计模式的好坏，是评估其是遵守设计原则。设计原则定义规范，是不存在二义性的。好的设计模式计就是实现了这些原则，从而达到了代码复用、增强可维护性的目的

### 单一职责原则-Single Responsibility Principle (SRP)

关于单一职责原则，其核心的思想是：**一个类，应该只有一个引起它变化的原因**。它是最简单又是最难运用的原则。
 
单一职责原则可以看作是低耦合、高内聚在面向对象原则上的引申，将职责定义为引起变化的原因，以提高内聚性来减少引起变化的原因。职责过多，可能引起它变化的原因就越多，这将导致职责依赖，相互之间就产生影响，从而极大的损伤其内聚性和耦合度。

  
 ### 开闭原则-Open/Closed Principle (OCP)
 
 开发封闭原则其核心的思想是：**模块是可扩展的，而不可修改的。也就是说，对扩展是开放的，而对修改是封闭的**。
 
对扩展开放，意味着有新的需求或变化时，可以对现有代码进行扩展，以适应新的情况。
 
对修改封闭，意味着类一旦设计完成，就可以独立完成其工作，而不要对类进行任何修改。换句话说，别人可以基于你的代码进行拓展编写，但却不能修改你的代码。
 
抽象化是开闭原则的关键。开闭原则是判断设计是否具备良好的灵活性和可拓展性的一个评价依据

开闭原则具有理想主义的色彩，它是面向对象设计的终极目标。其他设计原则则可以看做是开闭原则的实现方法


### 里氏代换原则-Liskov substitution principle (LSP)

软件工程大师Robert C. Martin把里氏代换原则最终简化为一句话：“Subtypes must be substitutable for their base types”。也就是**所有引用基类的地方必须能透明的使用其子类的对象**。里氏替换原则LSP是使代码符合开闭原则的一个重要保证。

### 依赖倒转原则-Dependency Inversion Principle(DIP)

抽象不应该依赖于细节，细节应当依赖于抽象。**要针对接口编程，而不是针对实现编程**。

传递参数，或者在组合聚合关系中，尽量引用层次高的类。高层模块不应该依赖于低层模块的实现，而是依赖于高层抽象。


### 接口隔离原则-Interface Segregation Principle (ISP)

使用多个专门的接口，而不使用单一的总接口，即**客户端不应该依赖那些它不需要的接口**。


### 合成/聚合复用原则-Composite/Aggregate Reuse Principle(CARP)

又叫做合成复用原则。合成/聚合复用原则就是在一个新的对象里面使用一些已有的对象，使之成为新对象的一部分；新的对象通过向这些对象的 委派达到复用已有功能的目的，即**要尽量使用对象组合，而不是继承来达到复用的目的**。

### 最小知识原则-Principle of Least Knowledge(PLK)

也叫迪米特法则。其定义是**一个软件实体应当尽可能少地与其他实体发生相互作用**。不要和陌生人说话，只与你的直接朋友通信。



## 设计模式分类

设计模式分为创建型模式，行为型模式以及结构性模式。

### Creational Design Patterns

- Abstract Factory
- Builder
- Factory/Factory Method Pattern
- [Simple Factory Pattern/Static Factory Method](/2020/06/22/Golang设计模式系列之简单工厂模式/)
- Object Pool
- Prototype
- Singleton

### Behavioural Design Patterns

- Chain of Responsiblity
- Command
- Iterator
- Mediator
- Memento
- Null Object
- Observer
-  State
- Strategy
- Template Method
- Visitor

### Structural Design Patterns

- Adapter
- Bridge
- Composite
- Facade
- Flyweight
- Proxy