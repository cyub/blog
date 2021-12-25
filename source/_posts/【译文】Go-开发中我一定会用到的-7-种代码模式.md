title: 【译文】Go 开发中我一定会用到的 7 种代码模式
author: tinker
tags:
  - 代码模式
  - 函数选项
  - nil通道
categories:
  - 翻译
date: 2021-12-25 02:32:00
---
原文：[7 Code Patterns in Go I Can’t Live Without](https://betterprogramming.pub/7-code-patterns-in-go-i-cant-live-without-f46f72f58c4b)

> 代码模式使你的程序更可靠、更高效，并使你的工作和生活更轻松

我已经为开发EDR解决方案工作了7年。这意味着我必须编写具有弹性和高效性的长时间运行的系统软件。我在这项工作中大量使用 Go，我想分享一些最重要的代码模式，你可以依靠这些模式你的程序更加可靠(reliable)和高效(efficient)。

## 使用Map实现Set

我们经常需要检查某些对象是否存在。例如，我们可能想检查之前是否访问过某个文件或者URL。在这些情况下，我们可以使用`map[string]struct{}`。如下所示：
![](https://static.cyub.vip/images/202112/code_pattern1.png)

使用空结构 `struct{}` 意味着我们不希望Map的值占用任何空间。有些人会使用 `map[string]bool`，但基准测试表明 `map[string]struct{}` 在内存和时间上都表现得更好。相关基准测试可以[查看这里](https://itnext.io/set-in-go-map-bool-and-map-struct-performance-comparison-5315b4b107b)。

<!--more-->

我们需要特别注意的 map 操作通常被认为具有 O(1) 的时间复杂度（[StackOverflow](https://stackoverflow.com/questions/29677670/what-is-the-big-o-performance-of-maps-in-golang），但是 go runtime 没有提供这样的保证。


## 使用 chan struct{} 在多个Goroutine之间同步 

通道可以用来存放数据，但有时候我们使用它们只用于同步目的。在下面的例子中， 通道携带struct{}类型的数据，它是一个不占空间的空结构体。这与上面的 map 示例中的技巧相同：

![](https://static.cyub.vip/images/202112/code_pattern2.png)

## 使用Close进行广播通知

继续上面例子，如果我们运行多个`go hello(quit)`，那么我们可以通过关闭`quit`通道来广播信号，而不是发送多个 `struct{}{}` 退出：

![](https://static.cyub.vip/images/202112/code_pattern3.png)


需要注意的是通过关闭通道进行广播通知，适用于任意数量的 goroutine，因此 `close(quit)` 也适用于之前的那个示例。

## 使用Nil Channel来阻塞Select语句

有时我们需要在 select 语句中禁用某些case语句，例如在下面函数中，它从事件源读取事件并将事件发送到调度通道：

![](https://static.cyub.vip/images/202112/code_pattern4.png)

上面代码中，我们需要改进的地方有：

- 当`len(pending) == 0`时， 禁用`case s.dispatchC`分支防止代码发生恐慌

- 当`len(pending) >= maxPending` 时禁用 `case s.eventSource`分支以避免分配太多内存


改进后的代码如下所示：

![](https://static.cyub.vip/images/202112/code_pattern5.png)

这里的技巧是使用一个额外的变量来打开/关闭原始通道，然后将该变量用于select的case语句中。

![](https://static.cyub.vip/images/202112/code_pattern6.png)


**警告：**注意不要同时禁用所有case语句，否则for-select 循环将停止工作。


## 非阻塞的从通道中读取数据

有时我们想提供“尽力而为”(best-effort)的服务。也就是说我们允许通道是“有损”(lossy)的。例如，当我们有过多的事件要分派(dispatch)给接收者，而其中一些可能没有响应时。这情况是存在的，我们可以忽略那些无响应的接收者，因为这样可以：

- 及时调度给其他接收者
- 避免为挂起导致分配过多内存


![](https://static.cyub.vip/images/202112/code_pattern7.png)

## 匿名结构体

有时我们只是想让一个容器来存储一组相关的值，而这个容器不会出现在其他任何地方。在这些情况下，我们不关心它的类型。在 Python 中，我们可能会创建一个字典或元组。在 Go 中，我们可以创建一个匿名结构体(Anonymous Struct)。我会用2个例子来说明:

### 案例1：Config

如果你想把你的配置值存储到一个变量中。但如下所示，为它专门创建一个类型似乎有点矫枉过正：

![](https://static.cyub.vip/images/202112/code_pattern8.png)


相反你应该这么做：

![](https://static.cyub.vip/images/202112/code_pattern9.png)

**注意：** `struct {...}` 是变量 `Config` 的类型——现在你可以通过 `Config.Timeout` 访问你的配置值。

### 案例2：测试用例

假设你想测试你 `Add()` 函数，而不是像这样编写大量的 `if-else` 语句:

![](https://static.cyub.vip/images/202112/code_pattern10.png)

相反，你可以像下面那样将测试用例和测试逻辑分开（译者注：这种测试称为表驱动测试）：

![](https://static.cyub.vip/images/202112/code_pattern11.png)

当你有许多测试用例时，或者有时需要更改测试逻辑时，这会更便捷。肯定有更多的场景，你可能会发现匿名结构体很方便。例如，当你想解析以下 JSON 时，可以定义一个带有嵌套匿名结构体的匿名结构体，以便可以使用 encoding/json 库对其进行解析。

![](https://static.cyub.vip/images/202112/code_pattern12.png)

## 使用函数包装选项

有时我们有一个包含许多可选字段的复杂结构，这时你会羡慕在 Python 中使用可选参数的功能：


![](https://static.cyub.vip/images/202112/code_pattern13.png)

在 Go 中实现的方法是使用函数包装这些选项。也就是说，我们可以构造函数来应用我们的选项值，这些值存储在函数的闭包中。使用上面的示例，我们有2个可选字段，用户可以在创建 Client 实例时指定它们：

![](https://static.cyub.vip/images/202112/code_pattern14.png)


包装选项(Wrapping options)这种方式使代码易于使用，更重要的是易于阅读：

![](https://static.cyub.vip/images/202112/code_pattern15.png)

## 总结

- 使用 `map[string]struct{}` 实现Set
- 使用 `chan struct{}` 高效同步 goroutine，并使用 `close()` 向任意数量的 goroutine 广播信号
- 将通道变量设置为 nil 以禁用Select语句的case分支
- 通过`select-default`模式创建有损通道
- 使用匿名结构体对配置值和测试用例进行分组
- 将选项包装为函数


如果你是一位经验丰富的 Go 程序员，那么你之前可能已经看过这些代码模式。然而，当我第一次开始用 Go 编程时，这对我来说并不明显。

Go 是一种非常强大的语言，它的结构与我们熟悉的大多数语言（即 C/C++、Python、PHP、Java 等）完全不同。因此，正确使用其优美的语法非常重要，否则你最终可能会遇到非常讨厌的错误，这些错误要么难以触发，要么你可能不知道它的来源。

我试图用上面的代码模式来描绘 Go 的本质，但它们还远远不够完整。要了解更多信息，我建议你查看 [Google 的精彩演讲](https://talks.golang.org/)。

## 进一步阅读

- [Advanced Go Concurrency Patterns](https://talks.golang.org/2013/advconc.slide#1)
- [10 things you (probably) don’t know about Go](https://talks.golang.org/2012/10things.slide#1)
- [Set in Go, map[]bool and map[]struct{} performance comparison](https://itnext.io/set-in-go-map-bool-and-map-struct-performance-comparison-5315b4b107b)