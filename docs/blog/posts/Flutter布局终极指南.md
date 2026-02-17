---
title: Flutter布局终极指南：轻松布局 Flutter 组件的唯一指南
authors: 
  - Tinker
tags:
  - 编程语言/Dart
  - 入门指南
categories:
  - 翻译
  - 编程语言
date: 2026-02-12 16:30:00
---

原文：[The Ultimate Flutter Layout Guide:The only guide you need to layout your Flutter widgets hassle-free](https://blog.adityasharma.co/the-ultimate-flutter-layout-guide)

## 引言

你在构建 Flutter 应用时是否曾被以下错误困扰过？

- `A RenderFlex overflowed…`（RenderFlex 溢出…）
- `RenderBox was not laid out`（RenderBox 未布局）
- `Viewport was given unbounded height`（Viewport 被赋予了无限高度）
- `An InputDecorator …cannot have an unbounded width`（InputDecorator 不能拥有无限宽度）
- `Incorrect use of ParentData widget`（ParentData 组件使用不正确）

如果答案是肯定的，那么这篇博客文章就是为你准备的！

在这篇博客文章中，我将讨论并分享一些常见的 Flutter 布局场景和最佳实践。我会更多地关注代码片段，而不是组件细节。对于组件详情，我会分享相关链接。


## 单个子元素布局组件

### Align（对齐）

一个将其子组件在其内部对齐的组件，并可选择根据子组件的大小调整自身大小。

![](https://static.cyub.vip/images/202602/Zq9bGq8xA.webp)

```dart
Center(
  child: Container(
    height: 120.0,
    width: 120.0,
    color: Colors.blue[50],
    child: const Align(
      alignment: Alignment.topRight,
      child: FlutterLogo(
        size: 60,
      ),
    ),
  ),
)
```

<!-- more -->

如果你想按照相对于父容器中心的比例来对齐组件：

![](https://static.cyub.vip/images/202602/4WXXU707N.webp)

```dart
Center(
  child: Container(
    height: 120.0,
    width: 120.0,
    color: Colors.blue[50],
    child: const Align(
      alignment: Alignment(0.2, 0.6),
      child: FlutterLogo(
        size: 60,
      ),
    ),
  ),
)
```

在[此处](https://api.flutter.dev/flutter/widgets/Align-class.html)阅读更多关于 Align 的内容。


### AspectRatio（宽高比）

一个尝试将子组件调整为特定宽高比的组件。

**注意：aspectRatio = 宽度 / 高度**

![](https://static.cyub.vip/images/202602/aE2onzGCV.webp)

```dart
Container(
  color: Colors.blue[100],
  alignment: Alignment.center,
  width: double.infinity,
  height: 100.0,
  child: AspectRatio(
    aspectRatio: 16 / 9,
      child: Container(
        color: Colors.green,
    ),
  ),
)
```

#### 最佳实践

1. 永远不要将 `AspectRatio()` 放在 `Expanded()` 或类似强制其子组件拉伸或占据父容器所给全部空间的组件内部。
2. 如果需要，将 `AspectRatio()` 组件放在 `Align()` 内部，再将 `Align()` 放在 `Expanded()` 内部。

示例：

```dart
Expanded(
  child: Align(
    child: AspectRatio(
      aspectRatio: 16 / 9,
        child: Container(),
    ),
  ),
)
```

在[此处](https://api.flutter.dev/flutter/widgets/AspectRatio-class.html)阅读更多关于 AspectRatio 的内容。


### Center（居中）

一个将其子组件在其内部居中的组件。默认情况下，该组件将匹配其子组件的大小。

![](https://static.cyub.vip/images/202602/BIUi19DjT.webp)

```dart
Center(
  child: FlutterLogo(
    size: 60,
  ),
)
```

在[此处](https://api.flutter.dev/flutter/widgets/Center-class.html)阅读更多关于 Center 的内容。


### ConstrainedBox（约束盒子）

默认情况下，大多数组件会尽可能少地使用空间。

例如：

![](https://static.cyub.vip/images/202602/sBHWk0Q9y.webp)

```dart
Card(
  color: Colors.blue[200],
  child: Text(
    'Widget without constraints',
  ),
)
```

`ConstrainedBox` 允许其子组件根据需要使用剩余空间。

![](https://static.cyub.vip/images/202602/Exg5DwIjx.webp)

```dart
ConstrainedBox(
  constraints: BoxConstraints.expand(),
  child: Card(
    color: Colors.blue[200],
    child: Text(
      'Widget inside ConstrainedBox',
    ),
  ),
)
```

**注意：** 相同的行为也可以使用 `SizedBox.expand()` 组件获得。

在[此处](https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html)阅读更多关于 ConstrainedBox 的内容。


### Container（容器）

**Container** 是最常用的组件之一！

Container 结合了多个其他组件，每个组件都有自己的布局行为，因此 Container 的布局行为有些复杂。

在继续之前，了解 Container 的布局行为很重要。

#### 布局行为

- 如果 Container 没有 `child`、没有 `height`、没有 `width`、没有约束，且父容器提供无界约束，那么 Container 尝试尽可能**小**。
- 如果 Container 没有 `child` 且没有 `alignment`，但提供了 `height`、`width` 或约束，那么 Container 在给定这些约束和父容器约束的组合下，尝试尽可能**小**。
- 如果 Container 没有 `child`、没有 `height`、没有 `width`、没有约束、没有 `alignment`，但父容器提供有界约束，那么 Container **扩展**以适应父容器提供的约束。
- 如果 Container 有 `alignment`，且父容器提供无界约束，那么 Container 尝试调整自身大小以**匹配** `child`。
- 如果 Container 有 `alignment`，且父容器提供有界约束，那么 Container 尝试**扩展**以适应父容器，然后根据对齐方式在其内部定位 `child`。
- 否则，如果 Container 有 `child` 但没有 `height`、没有 `width`、没有约束、没有 `alignment`，Container 将父容器的约束传递给 `child`，并调整自身大小以**匹配**子组件。

我知道这内容很多！但别担心，你很快就会理解的。让我们看看下面的一些示例：


- 当你不指定 Container 的 `height` 和 `width` 时，它将匹配其 `child` 的大小。

    ![](https://static.cyub.vip/images/202602/quKxub41I.png)

    ```dart
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
            title: Text(widget.title),
            ),
            body: Container(
            color: Colors.yellow[200],
            child: Text(
                'Widget inside Container',
            ),
            ),
        );
    }
    ```

- 当你指定了 Container 的 `alignment` 但没有指定 `height` 和 `width` 时，它将匹配其父级的大小，并根据对齐方式定位子组件。

    ![](https://static.cyub.vip/images/202602/s9B4ifawr.webp)

    ```dart
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(widget.title),
        ),
        body: Container(
        color: Colors.yellow[200],
        alignment: Alignment.center,
        child: Text(
            'Widget inside Container',
        ),
        ),
    );
    }
    ```

- 当你仅指定了 Container 的 `height`，它将匹配使用子组件的 `width`。

    ![](https://static.cyub.vip/images/202602/CVWsClHmn.webp)

    ```dart
    Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(widget.title),
        ),
        body: Container(
        color: Colors.yellow[200],
        height: 100,
        child: Text(
            'Widget inside Container',
        ),
        ),
    );
    }
    ```

- 当你仅指定了 Container 的 `width`，它将匹配使用子组件的 `height`。

    ![](https://static.cyub.vip/images/202602/AKl53ZFU6.webp)

    ```dart
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
            title: Text(widget.title),
            ),
            body: Container(
            color: Colors.yellow[200],
            width: 100,
            child: Text(
                'Widget inside Container',
            ),
            ),
        );
    }
    ```

- 当你只指定 Container 的高度并指定对齐方式时，它将匹配其父级的宽度，并根据指定的对齐属性对齐其子级。


    ![](https://static.cyub.vip/images/202602/S_WGlAQ6V.webp)

    ```dart
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
            title: Text(widget.title),
            ),
            body: Container(
            color: Colors.yellow[200],
            height: 100,
            alignment: Alignment.center,
            child: Text(
                'Widget inside Container',
            ),
            ),
        );
    }
    ```

- 当你只指定 Container 的宽度并指定对齐方式时，它将匹配其父级的高度，并根据指定的对齐属性对齐其子级。

    ![](https://static.cyub.vip/images/202602/7LiNWwHwQ.webp)

    ```dart
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
            title: Text(widget.title),
            ),
            body: Container(
            color: Colors.yellow[200],
            width: 100,
            alignment: Alignment.center,
            child: Text(
                'Widget inside Container',
            ),
            ),
        );
    }
    ```

在[此处](https://api.flutter.dev/flutter/widgets/FittedBox-class.html)阅读更多关于 Container 的内容。


### Expanded（扩展）

一个用于 Row、Column 或 Flex 的子组件的组件，用于扩展以填充主轴上的可用空间。

![](https://static.cyub.vip/images/202602/Yu1APGlQN.webp)

```dart
Column /*or Row*/ (
  children: <Widget>[
    Expanded(
      child: Card(
        color: Colors.teal,
        child: Center(child: Text('Flex: 1')),
      ),
      flex: 1,
    ),
    Expanded(
      child: Card(
        color: Colors.green,
        child: Center(child: Text('Flex: 2')),
      ),
      flex: 2,
    ),
    Expanded(
      child: Card(
        color: Colors.lightGreen,
        child: Center(child: Text('Flex: 3')),
      ),
      flex: 3,
    ),
  ],
),
```

#### 最佳实践

1. `Expanded` 只能用于 `Row`、`Column` 或 `Flex` 内部。
2. 如果你有多个 `Expanded` 组件，可以使用 `flex` 属性来控制它们之间的空间分配比例。

    ```dart
    Row(
    children: [
        Expanded(
        flex: 2,
        child: Container(
            color: Colors.blue[200],
            height: 100,
        ),
        ),
        Expanded(
        flex: 1,
        child: Container(
            color: Colors.green[200],
            height: 100,
        ),
        ),
    ],
    )
    ```

在[此处](https://api.flutter.dev/flutter/widgets/Expanded-class.html)阅读更多关于 Expanded 的内容。

### FittedBox（自适应盒子）

它会根据自身大小调整子元素的位置和大小。它主要用于像调整桌面壁纸一样，将图像适配到自身内部！

![](https://static.cyub.vip/images/202602/VjXrjhjvd.webp)

```dart
Container(
  height: 150,
  width: 300,
  color: Colors.yellow[200],
  child: FittedBox(
    clipBehavior: Clip.antiAlias,
    fit: BoxFit.cover,
    child: Image.network(
      'https://xyz.jpg',
    ),
  ),
),
```

在[此处](https://api.flutter.dev/flutter/widgets/Container-class.html)阅读更多关于 FittedBox 的内容。

### FractionallySizedBox（分数尺寸盒子）

一个将其子组件的大小调整为可用空间的一部分的组件。

![](https://static.cyub.vip/images/202602/TQQ_pbmMn.webp)

```dart
Center(
  child: FractionallySizedBox(
    widthFactor: 0.6,
    heightFactor: 0.1,
    child: Card(
      color: Colors.orange,
      child: Text('Some Widget'),
    ),
  ),
),
```

#### 最佳实践

- 使用不带子元素的 FractionallySizedBox() 来创建分数大小的空白区域。
- 将 FractionallySizedBox() 包裹在 Flexible() 组件中，以便更好地与行/列控件配合使用。

在[此处](https://api.flutter.dev/flutter/widgets/FractionallySizedBox-class.html)阅读更多关于 FractionallySizedBox 的内容。

### SizedBox（尺寸盒子）

它是最简单但非常有用的 widget 之一。它强制其 child 具有特定的大小。

#### 布局行为

- 如果给定了 child，该 widget 会强制其具有特定的 width 和/或 height。
- 如果该 widget 的父组件不允许这些值，这些值将被忽略。例如，当父组件是屏幕或另一个 SizedBox 时就会发生这种情况。
- 如果 width 或 height 为 null，SizedBox 会尝试在该维度上匹配 child 的大小。
- 如果 height 或 width 为 null 或未指定，则视为零。
- 使用 SizedBox.expand() 可使 SizedBox 匹配其父组件的大小。相当于将 width 和 height 设置为 double.infinity。

- SizedBox 作为固定大小的填充

    ![](https://static.cyub.vip/images/202602/vaswzpEdR.webp)

    ```dart
    Column(
    children: <Widget>[
        FlutterLogo(size: 50),
        const SizedBox(height: 100),
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- 如果想匹配父组件的大小，使用 SizedBox.expand()

    ![](https://static.cyub.vip/images/202602/rdLYcDYAV.webp)

    ```dart
    SizedBox.expand(
    child: Card(
        color: Colors.orange[200],
        child: Text('Widget inside SizedBox'),
    ),
    ),
    ```

#### 最佳实践

- 当把 SizedBox 作为子组件放在一个强制其子组件与自身大小相同的父 widget 中时（例如另一个 SizedBox），请将子 SizedBox 包裹在一个允许其大小可变的 widget 中，例如 Center 或 Align。  
示例：

    ```dart
    SizedBox(
    height: double.infinity,
    width: double.infinity,
    child: Align(
        child: SizedBox(
        height: 100,
        width: 100,
        child: Card(
            color: Colors.orange[200],
            child: Text('Widget inside SizedBox'),
        ),
        ),
    ),
    )
    ```

在[此处](https://api.flutter.dev/flutter/widgets/SizedBox-class.html)阅读更多关于 SizedBox 的内容。



## 多个子元素的布局组件

### Row 和 Column（行和列）

**Row**：沿水平方向布局一组子 widget。  
**Column**：沿垂直方向布局一组子 widget。

要对齐 Row/Column 内部的子 widget，我们使用 `mainAxisAlignment` 和 `crossAxisAlignment`。来看看这两个参数：

#### MainAxisAlignment（主轴对齐）

- MainAxisAlignment.start

  ![](https://static.cyub.vip/images/202602/wR-hdPz-z6.webp)

  ```dart
  Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
    ],
  ),
  ```

- MainAxisAlignment.center

  ![](https://static.cyub.vip/images/202602/7tNAhPy_sB.webp)

  ```dart
  Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
    ],
  ),
  ```

- MainAxisAlignment.end

  ![](https://static.cyub.vip/images/202602/sxZOpkSWa.webp)

  ```dart
  Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
    ],
  ),
  ```

- MainAxisAlignment.spaceBetween

  ![](https://static.cyub.vip/images/202602/qgeEy3nUh.webp)

  ```dart
  Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
      FlutterLogo(size: 50),
    ],
  ),
  ```

- MainAxisAlignment.spaceEvenly

    ![](https://static.cyub.vip/images/202602/dUNBfQ-TV.png)

    ```dart
    Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- MainAxisAlignment.spaceAround

    ![](https://static.cyub.vip/images/202602/bOz2Vt0Ee.webp)

    ```dart
    Row /*or Column*/ (
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
    ],
    ),
    ```

#### CrossAxisAlignment（交叉轴对齐）

- CrossAxisAlignment.start

    ![](https://static.cyub.vip/images/202602/in9D8YT0W.webp)

    ```dart
    Row /*or Column*/ (
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 200),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- CrossAxisAlignment.center

    ![](https://static.cyub.vip/images/202602/Ms-8JfzKkV.webp)


    ```dart
    Row /*or Column*/ (
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 200),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- CrossAxisAlignment.end

    ![](https://static.cyub.vip/images/202602/aA0edoDDv.webp)

    ```dart
    Row /*or Column*/ (
    crossAxisAlignment: CrossAxisAlignment.end,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 200),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- CrossAxisAlignment.stretch

    ![](https://static.cyub.vip/images/202602/vUq5kmRDv.webp)

    ```dart
    Row /*or Column*/ (
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 200),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- CrossAxisAlignment.baseline

    将子元素沿交叉轴放置，使它们的基线对齐。由于基线始终是水平的，因此此对齐方式适用于行控件。如果主轴是垂直的，则此值将被视为 CrossAxisAlignment.start。

    ![](https://static.cyub.vip/images/202602/WgANZEAJz.webp)

    ```dart
    Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: <Widget>[
        Text(
        'Heading',
        style: Theme.of(context).textTheme.headline2,
        ),
        Text(
        'Body',
        style: Theme.of(context).textTheme.bodyText2,
        ),
    ],
    ),
    ```

### MainAxisSize（主轴尺寸）

使用 MainAxisSize 来调整行/列的大小，使其与父元素匹配或适应子元素。

- MainAxisSize.max

    ![](https://static.cyub.vip/images/202602/wR-hdPz-z6.webp)

    ```dart
    Row /*or Column*/ (
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
    ],
    ),
    ```

- MainAxisSize.min

    ![](https://static.cyub.vip/images/202602/0ZtL8ayxI.webp)

    ```dart
    Row /*or Column*/ (
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
        FlutterLogo(size: 50),
    ],
    ),
    ```

在[此处](https://api.flutter.dev/flutter/widgets/Row-class.html)阅读更多关于 Row 的信息。
在[此处](https://api.flutter.dev/flutter/widgets/Column-class.html)阅读更多关于 Column 的信息。



### Stack（堆叠）

一个将子元素堆叠排列的组件。让我们来看看它的一些有趣特性。

- 默认情况下，所有子元素都与堆栈的左上角对齐。

    ![](https://static.cyub.vip/images/202602/_fwm05aDe.webp)

    ```dart
    Stack(
    children: <Widget>[
        Container(
        width: 120,
        height: 120,
        color: Colors.green,
        ),
        Container(
        width: 100,
        height: 100,
        color: Colors.red,
        ),
        Container(
        width: 80,
        height: 80,
        color: Colors.blue,
        ),
    ],
    ),
    ```

- 要对齐所有子元素，我们可以使用 alignment 属性。

    ![](https://static.cyub.vip/images/202602/S7y6QqQxC.webp)

    ```dart
    Stack(
    alignment: Alignment.center,
    children: <Widget>[
        Container(
        width: 120,
        height: 120,
        color: Colors.green,
        ),
        Container(
        width: 100,
        height: 100,
        color: Colors.red,
        ),
        Container(
        width: 80,
        height: 80,
        color: Colors.blue,
        ),
    ],
    ),
    ```

- 但如果想要唯一地定位所有元素呢？在这种情况下，我们可以用 Align() 或 Positioned() 组件包裹各个子组件。

    ![](https://static.cyub.vip/images/202602/mwktorG9J.webp)

    ```dart
    Stack(
    children: <Widget>[
        Align(
        alignment: Alignment.topLeft,
        child: Icon(
            Icons.menu,
        ),
        ),
        Align(
        alignment: Alignment.topRight,
        child: Icon(
            Icons.delete,
        ),
        ),
        Positioned(
        bottom: 0,
        right: 0,
        child: Icon(
            Icons.add_circle,
        ),
        ),
        Positioned(
        bottom: 0,
        left: 0,
        child: Icon(
            Icons.home,
        ),
        ),
    ],
    ),
    ```

- 有时，子元素会移动到栈的边界之外。默认情况下，它会被裁剪。

    ![](https://static.cyub.vip/images/202602/O44jNPb8hY.webp)

    为防止裁剪，请使用 clipBehavior: Clip.none。

    ![](https://static.cyub.vip/images/202602/zCkUOpm81Y.webp)

    ```dart
    Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: <Widget>[
        Container(
        width: 120,
        height: 120,
        color: Colors.black54,
        ),
        Positioned(
        bottom: -30,
        right: -30,
        child: Container(
            width: 80,
            height: 80,
            color: Colors.blue,
        ),
        ),
    ],
    ),
    ```

在[此处](https://api.flutter.dev/flutter/widgets/Stack-class.html)阅读更多关于 Stack 的内容。


### LayoutBuilder（布局构建器）

如果你想根据父组件的大小来布局组件，那么这就是你需要的组件。LayoutBuilder 的一个应用场景是为不同的屏幕尺寸构建不同的布局。

![](https://static.cyub.vip/images/202602/XIot-Tz3p.webp)

![](https://static.cyub.vip/images/202602/YTN8cNrQW.webp)

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('LayoutBuilder')),
    body: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideContainers(constraints.maxWidth);
        } else {
          return _buildNormalContainer();
        }
      },
    ),
  );
}

Widget _buildNormalContainer() {
  return Center(
    child: Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.teal,
    ),
  );
}

Widget _buildWideContainers(double width) {
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          height: double.infinity,
          width: width / 2,
          color: Colors.teal,
        ),
        Container(
          height: double.infinity,
          width: width / 2,
          color: Colors.green,
        ),
      ],
    ),
  );
}
```

在[此处](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)阅读更多关于 LayoutBuilder 的内容。

## 参考资料

- [Flutter 官方文档 - 布局](https://flutter.dev/docs/development/ui/layout)
- [Flutter Widget 目录](https://flutter.dev/docs/reference/widgets)