---
title: 掌握Flutter状态管理
authors: 
  - Tinker
tags:
  - Flutter
  - 状态管理
categories:
  - 翻译
  - 软件架构与设计
date: 2026-02-17 15:30:00
---

原文：[Mastering State Management in Flutter](https://www.hungrimind.com/articles/flutter-state-management)

![](https://static.cyub.vip/images/202602/state-management.webp)

想象一下一群书呆子为如何操作数据争吵了五年。这基本上就是 Flutter 社区一直在发生的事情。

五年过去了，关于 GetX 的帖子仍然会引发风暴。我就是那些书呆子之一。所以，我想最后一次狂热一下，然后继续我的生活。这是我**关于状态管理的最终结论**。

## 最终结论

使用任何你想用的状态管理方案。如果你在意别人用什么，那就找点更好的事情去关心。

我不在乎你用什么。然而，我强烈建议你了解你所使用的工具，并理解如何仅使用 Flutter 提供的工具来**管理你的状态**。

## 什么是状态？

**状态管理**这个短语可以分解为一个用于**管理你的状态**的系统。什么是状态？

状态是一种数据。应用程序中有两种类型的数据：

- 常规数据（硬编码且无法更改）
- 状态（可以更改的奇特数据）

一个典型的状态例子是用户信息。例如，你可以在主屏幕上显示 `Hello, Tadas`，其中 `Tadas` 这部分信息是从用户信息状态中获取的。假设你有一个设置页面，可以在其中将名称更改为 `T-Dog`。这将使用新值更新用户信息状态，你的应用将更改为显示 `Hello,T-Dog`。状态管理解决方案将促进这一更改数据并在整个应用程序中传播这些更改的过程。

其他一些常见的状态例子包括新闻动态、关注者数量、待办事项、倒计时器等。

**状态最简单的定义就是可以更改的数据**。

<!-- more -->

## 什么是管理？

状态管理负责管理该状态。管理它意味着什么？为什么这样做很重要？

让我们以上面的用户信息状态为例。这里的信息可以通过多种方式更新。

- 当用户创建账户时。
- 在设置页面上。
- 每当他们被关注时。

以及可以在许多地方读取信息。

- 主页上的名称。
- 个人资料页面上的名称。
- 每个页面上的头像。
- 个人资料页面上的关注者数量。
- 在个人资料页面上是否关注了特定的人。

如果我们没有状态管理，需要构建一个可以完成上述所有功能的应用，会发生什么？

你需要将用户信息状态传递到`每一个`、`单个`、`屏幕`。这听起来很糟糕，但更糟的是什么？状态可以在应用的不同部分更新。如果你的用户在没有状态管理的情况下将他们的名字更改为 `T-Dog`，它只会在一个屏幕上更新。你必须设置一种方式让`每一个其他屏幕`都知道名称已更新。

这听起来像是一个复杂的烂摊子。幸运的是，我们确实有状态管理。

一个适当的状态管理解决方案解决两个问题。

1. 它将所有数据集中在一个地方，因此只有一个事实来源。
2. 每当数据更改时更新用户界面。

## 客户端状态 vs 服务器状态

"状态管理"中的"状态"指的是应用程序中的当前数据，用于显示你的用户界面。服务器状态是应用程序外部的数据（本地存储、数据库、自定义后端）。不要将应用状态与来自数据库的持久化数据混淆。

![](https://static.cyub.vip/images/202602/client_server_state.png)

**这两者并不相同**。通常，你的状态管理解决方案的目标是缩小与服务器状态的差距。仅仅因为它们通常一起工作并不意味着它们是相同的。

状态保存在你的应用程序中，**决定用户界面**。服务器处理应用程序外部的数据，不会直接影响应用程序内的任何内容。即使你是从数据库流式传输数据，你也必须在本地处理流，然后才能反映在用户界面中。

## 仅使用 Flutter 进行状态管理

每当你看到状态管理，你的大脑可能会想到状态管理包。但你不需要使用包来管理你的状态。

每个状态管理包都是使用 Flutter 本身构建的，因此仅使用 Flutter 代码就可以做到这一点。在本文的下一部分，我们将**仅使用 Flutter 提供的工具**构建一个计数器应用程序。

`setState` 是管理状态的最简单形式。每当你调用它时，它都可以更新你的用户界面，但它仅限于单个 widget，所以我们不提及它。然而，对于简单的应用程序，`setState` 可能就是你所需要的。

### 集中数据

最重要的是为与特定功能相关的所有数据拥有**一个事实来源**。由于我们正在制作一个计数器应用程序，主要功能是计数器。我们创建一个名为 `CounterModel` 的类，其中包含一个计数器和一个用户名（为了让事情更有趣）。

```dart
class CounterModel {
  CounterModel({
    required this.username,
    this.counter = 0,
  });

  final String username;
  final int counter;

  CounterModel copyWith({
    final String? username,
    final int? counter,
  }) {
    return CounterModel(
      username: username ?? this.username,
      counter: counter ?? this.counter,
    );
  }
}
```

每当使用数据对象时，我都会创建一个 `copyWith` 方法。这使得**复制**该对象**并**保留先前的数据，只更改你定义的值变得容易。

例如，假设你用用户名 "Tadas" 和计数器值 1 实例化一个新的 `CounterModel`。

```dart
CounterModel _counterModel = CounterModel(username: "Tadas", counter: 1);
```

要创建一个具有相同用户名但更新后的计数器值的新对象，请调用 `copyWith` 方法。

```dart
_counterModel.copyWith(counter: 2);
```

你可以使用一个名为 [Dart Data Class Generator](https://marketplace.visualstudio.com/items?itemName=hzgood.dart-data-class-generator) 的 VSCode 扩展来创建这个 copyWith 方法。

乍一看，这似乎像是额外的工作，但这种称为不可变性的方法非常方便，尤其是在 Flutter 应用程序中。

不可变性意味着一旦创建了对象，你就无法更改它。这有助于推理和调试你的应用程序，因为该对象独立于应用程序内发生的任何事情。这消除了编辑同一对象时出现的问题，而且考虑到 Dart 可以重用旧引用，这也相对高效。

### ChangeNotifier

正如我们提到的，状态管理解决方案需要做两件事：

1. 将所有数据集中在一个地方，以便有一个单一的事实来源。
2. 每当数据更改时更新用户界面。

这第二点是大多数关于状态管理的争论的来源。有许多方法可以更新用户界面，"最佳方式"基于你的偏好。

Flutter 提供了几种更新用户界面的方法。`ChangeNotifier` widget 是其中之一。它**通知**正在监听**更改**的 widget。我必须赞扬 Flutter 团队对 widget 的清晰命名；他们将每个 widget 都命名得恰到好处，准确地描述了它的功能。

要使用它，你需要将 `ChangeNotifier` 实现到你的数据类中，并直接在该不再仅仅是数据的类中编写函数。当使用 `ChangeNotifier` 时，最好将你的计数器设为私有变量，并使用 `getter` 公开它。这样，你只能使用你在 `ChangeNotifier` 内定义的函数来修改值。每当你更新该数据时，你必须调用 `notifyListeners()`。再次，Flutter 团队在命名上做得很好。这个函数**通知**正在监听 `ChangeNotifier` 的 widget 已发生更改。

```dart
class CounterModel with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count += 1;
    notifyListeners();
  }
}
```

当准备在你的应用程序中使用该数据时，将你的 `ChangeNotifier` 传递给 `ListenableBuilder` widget。`ListenableBuilder` 监听 `Listenable` 的内容（如 `ChangeNotifier`），并在数据更改时构建你的用户界面。

### ValueNotifier

`ValueNotifier` 采用了 `ChangeNotifier` 的功能，并添加了**不可变性**。正如我们之前提到的，不可变对象无法被编辑。因此，当我们想要更改任何数据时，我们必须使用 `copyWith` 方法。

当使用 `ChangeNotifier` 时，我们需要调用一个函数来通知监听器数据已更改。`ValueNotifier` 则是在为其 `value` 分配新对象时通知监听器。

这导致了一个简洁的解决方案，我们可以保留原始的 `CounterModel` 类作为数据类，并创建一个 `CounterNotifier` 来处理所有数据操作。

`ValueNotifier` 只能有一个对象作为其 `value`。当我们更新该值时，我们使用 `copyWith` 方法创建一个新对象。

```dart
class CounterNotifier extends ValueNotifier<CounterModel> {
  CounterNotifier(super.state);

  void increment() {
    value = value.copyWith(counter: value.counter + 1);
  }
}
```

### 单一事实来源

无论你使用 `ChangeNotifier` 还是 `ValueNotifier`，这种方法都是关于拥有单一的事实来源。使用 `ChangeNotifier` 时，我们将数据设为私有，这样就没有人可以在 `ChangeNotifier` 外部修改它。使用 `ValueNotifier` 时，数据是不可变的，因此根据定义它无法被修改。对于这两者，数据只能通过其中定义的函数进行更改。

为什么这如此重要？假设你正在开发一个大型应用程序，到处都是计数器。如果你决定计数器应该每次增加 2 而不是 1，你就必须遍历代码中每个更新计数器的地方，确保它们都增加 2。将所有内容放在一个地方意味着你可以在那一个地方更新它，这将在应用程序的其余部分反映出来。

同样，用这样一个简单的例子，它可能看起来不是什么大问题，但当你有一个巨大的应用程序时，它就变得至关重要。

另一个重要的好处是当你遇到 bug 时。由于数据总是可以追溯到事实来源，因此更容易找出问题所在。

### InheritedWidget

使用我们的 `CounterNotifier`，我们可以操作和读取状态，并使用 `ListenableBuilder` 监听更改并更新用户界面。然而，我们留下了一个大问题：我们必须手动将 `CounterNotifier` 传递到我们想要使用的每个屏幕。

幸运的是，Flutter 提供了一个 `InheritedWidget`，允许 widget 树中较低的 widget 访问信息。这就是 `Theme.of(context)` 可以在应用程序的任何地方调用的原因。它是 `MaterialApp` 中的一个 `InheritedWidget`。我们可以创建我们自己的 `InheritedWidget`，称为 "Provider"（因为它将为我们的应用程序提供数据*）。

```dart
class Provider extends InheritedWidget {
   const Provider(this.data, {Key? key, required Widget child})
       : super(key: key, child: child);

   final CounterModel data;

   static CounterModel of(BuildContext context) {
     return context.dependOnInheritedWidgetOfExactType<Provider>()!.data;
   }

   @override
   bool updateShouldNotify(Provider oldWidget) {
     return data != oldWidget.data;
   }
 }
```

`updateShouldNotify` 函数让你定义 `InheritedWidget` 应该何时更新你的应用程序。每当该函数返回 `true` 时，所有使用你的数据的 widget 都知道它们应该被重建。在这种情况下，每当新的 `data` 与旧的 `data` 不匹配时，我们将通知我们的应用程序有关更改。

正如我提到的，`InheritedWidget` 让 widget 树中位于其下方的 widget 知道数据已更新，因此它们会被重建。我们希望所有 widget 都知道数据已更新，所以我们用我们的 `InheritedWidget` 包装整个应用程序。现在，使用 `Provider.of(context)`，我们可以访问我们的 `CounterNotifier`。

```dart
void main() {
  runApp(
    Provider(
      notifier: CounterNotifier(CounterModel(username: "Tadas")),
      child: const MyApp(),
    ),
  );
}
```

这很好，但我们仍然需要使用 `ListenableBuilder` 来监听更新。我们可以做得更好。

### InheritedNotifier

Flutter 有一个 `InheritedNotifier` widget，只能与 `Listenable` 通知器一起使用（包括 `ChangeNotifier` 和 `ValueNotifier`）。因此，`InheritedNotifier` 可以通知用户界面数据已更改。

这消除了对 `ListenableBuilder` 的需求，我们可以直接使用 `Provider.of<CounterNotifier>(context)`。我们必须添加 `<CounterNotifier>`，因为这个新的 `Provider` 是可重用的。正因为如此，我们需要定义我们想要监听哪个通知器。

```dart
class Provider<T extends Listenable> extends InheritedNotifier<T> {
  const Provider({
    super.key,
    required super.child,
    required super.notifier,
  });

  static T of<T extends Listenable>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<Provider<T>>();

    if (provider == null) {
      throw Exception("No Provider found in context");
    }

    final notifier = provider.notifier;

    if (notifier == null) {
      throw Exception("No notifier found in Provider");
    }

    return notifier;
  }
}
```

### 使用状态

现在，我们拥有了一个完整的计数器应用程序状态管理解决方案。

我们可以使用我们的 `InheritedNotifier` 访问 `CounterNotifier`，并在整个应用程序中使用它来显示状态或使用我们定义的函数操作它。

```dart
final counterNotifier = Provider.of<CounterNotifier>(context);

return Scaffold(
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '${counterNotifier.value.username} has pushed the button this many times:',
        ),
        Text(
          '${counterNotifier.value.counter}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => counterNotifier.increment(),
    child: const Icon(Icons.add),
  ),
);
```

## 为什么要使用包？

那么，关于状态管理包的所有 fuss 是什么？它来自一个好的地方，来自编写更有组织和高效软件的动力。

然而，在大多数情况下，最好的方法是保持简单并使用框架的工具，但这并不意味着包是无用的。

包确实提供了好处。它们带有功能和健壮性，可以帮助你扩展状态管理，同时为开发者减少设置工作。

## 选项

有很多管理状态的包选项，每个人对哪些更好哪些更差都有自己的强烈意见。随意探索它们，但有三个选项因其受欢迎程度和在社区中的普遍接受度而脱颖而出。

### [Provider](https://pub.dev/packages/provider)

在这个演示项目中，我将我们的 `InheritedWidget` 称为：`Provider`。`Provider` 包在大多数情况下与我们在这个演示中所做的相同，但样板代码更少。

`Provider` 是 `InheritedWidget` 的包装器，使其更容易与不同的数据类型一起使用。

它有 `FutureProvider` 和 `StreamProvider`，用于处理将 futures 和 streams 传递到你的 widget 树。它还有 `ValueListenableProvider` 和 `ChangeNotifierProvider`，与我们构建的类似。

### [Riverpod](https://riverpod.dev/)

Riverpod 是我为大多数选择使用包的人推荐的。Riverpod 使用来自 `Provider` 的概念，并将它们整合到一个完整的状态管理解决方案中。对于保存状态，你应该使用 `NotifierProvider`，它：

1. 提供应用程序的状态。
2. 创建一个使用 `Notifier` 更新该状态的接口。

这与我们在本文中采用的方法非常相似，只是样板代码更少。

Riverpod 拥有最少的样板代码，同时也适当地利用了核心 Flutter 功能。

### [Bloc](https://bloclibrary.dev)

Bloc 是 Flutter 社区中另一个非常受欢迎的解决方案。它已知可以很好地扩展，是大型项目的不错选择。

我不为我的项目选择 Bloc，因为它包含很多样板代码，而我在使用包时正试图避免这一点。在使用它之前，你还必须学习 Bloc 范式。

有些人将其视为一个优点，因为它迫使你遵循良好的代码实践，这在扩展应用程序时至关重要。但我喜欢开销更少的包。

### 其他

还有很多其他选项，所以随意探索，但这三个是 Flutter 社区中的大玩家，选择它们你不会错。

感谢你的阅读。继续充实你饥渴的头脑 △