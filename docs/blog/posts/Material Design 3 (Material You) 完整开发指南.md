---
title: Material Design 3 (Material You) 完整开发指南
authors: 
  - Tinker
tags:
  - 入门指南
categories:
  - 工程实践与运维
  - 软件架构与设计
date: 2026-02-14 16:30:00
---

## 概述与核心变革

Material Design 3（代号 **Material You**）是 Google 于 2021 年 I/O 大会发布的第三代设计系统，随 Android 12 正式推出。它代表了从"统一设计"到"个性化表达"的范式转变。

### 与 Material Design 2 的关键差异

| 特性 | Material 2 | Material 3 |
|------|-----------|-----------|
| **颜色哲学** | 固定品牌色（Primary/Secondary） | 动态个性化（从壁纸/种子色生成） |
| **颜色数量** | 12个基础色槽 | 26+个语义化颜色角色 |
| **表面层级** | 阴影海拔（Elevation） | 色调表面（Tone-based Surfaces） |
| **排版体系** | 6种样式（Headline 1-6等） | 15种令牌化样式（Display/Headline/Title/Body/Label） |
| **形状系统** | 固定圆角 | 7级可配置圆角体系 |
| **个性化** | 无 | 核心特性（壁纸取色、算法生成） |

### 核心设计原则

1. **个性化优先**：系统从用户壁纸提取颜色，生成独一无二的主题
2. **算法驱动美学**：基于 HCT 颜色空间的科学算法确保配色和谐
3. **无障碍内置**：所有颜色组合默认满足 WCAG 2.1 AA 对比度标准
4. **跨平台一致**：提供跨平台实现规范，Android（Compose/View）与 Flutter 为官方完整实现，Web 与 iOS 通过 Material Color Utilities 支持配色算法

<!-- more -->

## 动态颜色系统

动态颜色(Dynamic Color)是 Material 3 最具革命性的特性，允许应用根据用户壁纸或预设种子色自动生成完整配色方案。

### 颜色生成原理

动态颜色系统基于 **HCT 颜色空间**（Hue, Chroma, Tone），替代了传统的 HSL：

- **Hue（色相）**：0-360度的颜色类型（红、黄、蓝等）
- **Chroma（色度）**：0（完全灰度）到 ~120（最鲜艳）的饱和度
- **Tone（色调/明度）**：0（纯黑）到 100（纯白）的亮度，是确保无障碍对比度的关键维度

**生成流程**：

1. **提取源色**：从壁纸量化提取代表性颜色（Quantization）
2. **推导关键色**：通过算法从源色生成5个关键色（Primary, Secondary, Tertiary, Neutral, Neutral Variant）
3. **生成色调调色板**：每个关键色生成13级色调（Tone 0-100）
4. **分配颜色角色**：根据对比度要求将特定色调分配给UI角色
5. **生成光/暗主题**：同一调色板生成两套对比度安全的主题

### Flutter 实现示例

```dart
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart'; // 官方插件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // 动态颜色获取失败时回退到种子色生成
        final lightScheme = lightDynamic ?? 
          ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          );
        
        final darkScheme = darkDynamic ?? 
          ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          );

        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true, // 必须启用
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
```

### 颜色方案变体

Android 13 引入了 **6种配色风格**（Color Scheme Styles），改变算法数学逻辑以产生不同视觉效果：

| 风格 | 特点 | 适用场景 |
|------|------|---------|
| **Tonal Spot** | 默认，柔和协调，中性变体明显 | 通用场景 |
| **Spritz** | 低饱和度，灰度感强，优雅克制 | 专业/阅读应用 |
| **Vibrant** | 高饱和度，色彩鲜艳突出 | 娱乐/创意应用 |
| **Expressive** | 色相跨度大，使用互补色，大胆活泼 | 年轻/时尚应用 |
| **Rainbow** | 全色相分布，彩虹般丰富 | 儿童/教育应用 |
| **Fruit Salad** | 源色影响分散到所有角色，色彩分散 | 艺术/个性应用 |

## 颜色角色与令牌体系

Material 3 引入了 **26+个语义化颜色角色**，通过"令牌"（Tokens）机制实现设计与开发的一致性。每个角色都有明确的用途和对比度要求。

### 核心颜色角色分类

#### 强调色组

在 Material Design 3 中，强调色组（Accent Colors）用于表达品牌个性、引导用户操作、传达交互状态的颜色系统。强调色具有高饱和度，在界面中突出显示，吸引用户注意力。强调色组一共包含三组角色：

- **主色组**：primary, onPrimary, primaryContainer, onPrimaryContainer
- **辅助色组**：secondary, onSecondary, secondaryContainer, onSecondaryContainer
- **第三色组**：tertiary, onTertiary, tertiaryContainer, onTertiaryContainer

| 角色 | 用途 | 对应 `on` 角色 | 容器色用途 |
|------|------|---------------|-----------|
| `primary` | 主要按钮、激活状态、关键操作 | `onPrimary` | `primaryContainer`：填充按钮、选中开关 |
| `secondary` | 次要操作、过滤芯片、导航元素 | `onSecondary` | `secondaryContainer`：次要填充按钮 |
| `tertiary` | 对比强调、平衡主/次色、特殊强调 | `onTertiary` | `tertiaryContainer`：强调容器、特殊状态 |

`primary` 和 `onPrimary` 是 Material Design 3 中"一对互补的对比色"，设计目的是确保在任何背景上都有良好的可读性。

| 属性       | `primary`       | `onPrimary`          |
| -------- | --------------- | -------------------- |
| **用途**   | 作为主**背景色**使用    | 作为主背景上的**文字/图标色**使用  |
| **典型场景** | 按钮背景、卡片强调色、选中状态 | 按钮上的文字、图标、前景内容       |
| **对比关系** | 背景色             | 前景色（与 primary 形成高对比） |

类似`primary` 和 `onPrimary` "背景-前景"配对模式有下面这些：

| 背景色                | 对应前景色                | 用途           |
| ------------------ | -------------------- | ------------ |
| `primary`          | `onPrimary`          | 主按钮、悬浮按钮、选中项 |
| `secondary`        | `onSecondary`        | 次要按钮、过滤芯片    |
| `surface`          | `onSurface`          | 卡片、对话框背景     |
| `error`            | `onError`            | 错误提示按钮       |
| `primaryContainer` | `onPrimaryContainer` | 填充按钮、选中开关    |

**关键设计原则**：

- **亮色模式**：`primary` 通常较深（保证对比度），`primaryContainer` 较亮（用于吸引注意力的按钮如 FAB）
- **暗色模式**：`primaryContainer` 可能反而比 `primary` 更亮，形成反转效果
- **固定强调色**：如需跨主题保持一致，使用 `primaryFixed`、`secondaryFixed` 等固定角色

#### 表面色组

在 Material Design 3 中，表面色组（Surface Colors）用于构建界面空间层级、区分海拔高度、提供中性背景的颜色系统。表面色基于中性色调，通过明度变化而非颜色差异来创造深度感。

Material 3 废弃了 M2 的 `surfaceTint` 叠加方式，改用 **8级专用表面色**，构成了完整的表面层级体系：

| 角色 | 用途 | 层级定位 |
|------|------|---------|
| **`surface`** | 基础表面背景 | 第 0 层 - 最底层基础 |
| **`surfaceDim`** | 较暗表面 | 暗色主题底层/氛围背景 |
| **`surfaceBright`** | 较亮表面 | 亮色主题 elevated 表面 |
| **`surfaceContainerLowest`** | 最低层容器 | 第 1 层 - 对话框、菜单背景 |
| **`surfaceContainerLow`** | 低层容器 | 第 2 层 - 卡片、列表项 |
| **`surfaceContainer`** | 标准容器 | 第 3 层 - 标准组件背景 |
| **`surfaceContainerHigh`** | 高层容器 | 第 4 层 - 悬浮按钮、导航栏 |
| **`surfaceContainerHighest`** | 最高层容器 | 第 5 层 - 输入框、开关轨道、模态对话框 |


这 8 个角色可以分为 **三组**：

##### 基础表面色

- `surface` - 通用基础表面
- `surfaceDim` - 暗色主题偏好（较暗氛围）
- `surfaceBright` - 亮色主题偏好（较亮氛围）

##### 容器层级色

- `surfaceContainerLowest` - 最低强调
- `surfaceContainerLow` - 低强调
- `surfaceContainer` - 默认强调
- `surfaceContainerHigh` - 高强调
- `surfaceContainerHighest` - 最高强调

##### 配套前景色

- `onSurface` - 表面上的主要内容（最高对比度）
- `onSurfaceVariant` - 表面上的次要内容（中等对比度）

##### 使用示例

```dart
// Flutter 中访问完整的 8 级表面色
final cs = Theme.of(context).colorScheme;

// 基础表面
Container(color: cs.surface);           // 最底层背景
Container(color: cs.surfaceDim);        // 暗色氛围背景
Container(color: cs.surfaceBright);     // 亮色强调表面

// 5 级容器层级（从低到高）
Container(color: cs.surfaceContainerLowest);  // 对话框背景
Container(color: cs.surfaceContainerLow);     // 卡片背景
Container(color: cs.surfaceContainer);        // 标准容器
Container(color: cs.surfaceContainerHigh);    // 导航栏
Container(color: cs.surfaceContainerHighest); // 输入框、模态层
```


#### 语义色组

在 Material Design 3 中，语义色组（Semantic Colors）是指那些具有特定功能含义的颜色角色，它们向用户传达状态、反馈或特定信息。与强调色（品牌表达）和表面色（空间层级）不同，语义色专注于功能性沟通。

| 角色                     | 含义       | 用途                  |
| ---------------------- | -------- | ------------------- |
| **`error`**            | 错误/危险    | 错误提示、删除按钮、验证失败、系统警报 |
| **`onError`**          | 错误上的内容   | 错误背景上的文字/图标         |
| **`errorContainer`**   | 错误容器     | 错误提示背景、错误状态卡片       |
| **`onErrorContainer`** | 错误容器上的内容 | 错误容器内的文字            |
| **`outline`**          | 轮廓/边框    | 输入框边框、分割线、卡片描边      |
| **`outlineVariant`**   | 次要轮廓     | 微妙分割线、禁用状态边框        |
| **`scrim`**            | 遮罩       | 模态框背后的半透明遮罩层        |
| **`shadow`**           | 阴影       | 组件阴影（通常黑色半透明）       |


语义色 vs 强调色 vs 表面色 对比：

| 维度       | 强调色组                               | 表面色组                           | 语义色组                                  |
| -------- | ---------------------------------- | ------------------------------ | ------------------------------------- |
| **核心目的** | 品牌识别、引导操作                          | 空间层级、视觉分组                      | 状态传达、功能反馈                             |
| **颜色特征** | 高饱和度、鲜艳                            | 低饱和度、中性                        | 特定色相（红/绿/黄/蓝）                         |
| **典型角色** | `primary`, `secondary`, `tertiary` | `surface`, `surfaceContainer*` | `error`, `success`, `warning`, `info` |
| **用户认知** | "这是什么品牌"                           | "这是哪个层级"                       | "这是什么状态"                              |
| **是否必须** | 是（品牌必需）                            | 是（结构必需）                        | 部分必需（`error` 必须，其他可选）                 |

### 颜色角色使用规范

```dart
// ✅ 正确使用语义角色
Container(
  color: Theme.of(context).colorScheme.surfaceContainerLow, // 卡片背景
  child: Text(
    '标题',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface, // 确保对比度
    ),
  ),
);

// 按钮示例：使用容器色获得更好的视觉效果
FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
  ),
  onPressed: () {},
  child: const Text('确认'),
);

// ❌ 错误：硬编码颜色或混淆角色
Container(
  color: Colors.white, // 破坏暗色主题
  child: Text(
    '文本',
    style: TextStyle(color: Theme.of(context).colorScheme.primary), // 背景白+主色可能对比度不足
  ),
);
```

## 海拔与表面层级系统

Material 3 彻底重构了海拔（Elevation）概念，从"阴影深度"转向"表面色调变化"。

### 海拔层级

| 海拔层级 | DP值 | 表面色变化 | 典型组件 |
|------|------|-----------|---------|
| **Level 0** | 0dp | `surface` / `surfaceDim` / `surfaceBright` | 底层背景、标准卡片 |
| **Level 1** | 1dp | `surfaceContainerLowest` | 对话框、底部菜单 |
| **Level 2** | 3dp | `surfaceContainerLow` | 卡片（选中）、自动完成菜单 |
| **Level 3** | 6dp | `surfaceContainer` | 导航抽屉、底部导航栏 |
| **Level 4** | 8dp | `surfaceContainerHigh` | 悬浮按钮（FAB）、顶部应用栏 |
| **Level 5** | 12dp | `surfaceContainerHighest` | 模态对话框、抽屉导航（展开） |

### 阴影与色调叠加

**废弃方案（Surface Tint）**：

- M3 早期使用 `surfaceTint` 颜色叠加在表面色上模拟海拔
- 通过透明度变化（0-12%）表示高度
- **已废弃**：不应与新表面色角色混用

**当前推荐方案**：

- 直接使用 `surfaceContainer*` 系列颜色角色
- 阴影仅保留用于临时叠加层（Modal、Dialog）
- 暗色主题中阴影几乎不可见，依赖表面色区分层级

### Flutter 海拔实现

```dart
// 使用 Material 3 的 Elevation 规范
Card(
  elevation: 0, // M3 卡片默认无阴影，依赖 surfaceContainerLow
  color: Theme.of(context).colorScheme.surfaceContainerLow,
  child: const ListTile(...),
);

// 需要阴影的临时层
Dialog(
  elevation: 6, // Level 3
  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
  child: ...,
);
```


## 排版系统

Material 3 采用 **15级类型比例**（Type Scale）的排班系统(Typography)，分为5大类别，每类3级尺寸。

### 类型角色体系

| 类别 | 角色 | 尺寸 | 字重 | 行高 | 用途 |
|------|------|------|------|------|------|
| **Display** | `displayLarge` | 57sp | Regular | 64 | 品牌展示、营销标题 |
| | `displayMedium` | 45sp | Regular | 52 | 关键视觉标题 |
| | `displaySmall` | 36sp | Regular | 44 | 次级展示文字 |
| **Headline** | `headlineLarge` | 32sp | Regular | 40 | 页面大标题 |
| | `headlineMedium` | 28sp | Regular | 36 | 区块标题 |
| | `headlineSmall` | 24sp | Regular | 32 | 卡片标题 |
| **Title** | `titleLarge` | 22sp | Regular | 28 | 应用栏标题 |
| | `titleMedium` | 16sp | Medium | 24 | 列表标题、对话框标题 |
| | `titleSmall` | 14sp | Medium | 20 | 卡片副标题 |
| **Body** | `bodyLarge` | 16sp | Regular | 24 | 长文本段落 |
| | `bodyMedium` | 14sp | Regular | 20 | 标准正文 |
| | `bodySmall` | 12sp | Regular | 16 | 辅助说明、脚注 |
| **Label** | `labelLarge` | 14sp | Medium | 20 | 按钮文字、标签 |
| | `labelMedium` | 12sp | Medium | 16 | 输入框标签、徽章 |
| | `labelSmall` | 11sp | Medium | 16 | 时间戳、最小标签 |

### 排版使用原则

```dart
// Flutter 中访问排版
Text(
  '页面标题',
  style: Theme.of(context).textTheme.headlineMedium,
);

// 自定义排版主题
ThemeData(
  textTheme: Typography.material2021().copyWith(
    displayLarge: const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25, // 大字号使用负字间距
    ),
    labelLarge: const TextStyle(
      fontWeight: FontWeight.w500, // 标签使用 Medium 字重
      letterSpacing: 0.1, // 小字号使用正字间距提升可读性
    ),
  ),
);
```

### 响应式排版

Material 3 推荐根据屏幕尺寸调整排版比例：

- **紧凑型布局**（手机）：使用默认尺寸
- **中等型布局**（平板）：Display 类可增加 1.2-1.5 倍
- **扩展型布局**（桌面）：Display 类可增加 1.5-2 倍，行高相应增加



## 形状与圆角规范

Material 3 建立了 **7级圆角体系**（Shape Scale），实现从锐利到圆润的视觉表达。

### 形状令牌

| 令牌 | 圆角值 | 用途 |
|------|--------|------|
| `none` | 0dp | 全屏对话框、底部菜单（顶部无圆角） |
| `extraSmall` | 4dp | 小型组件、输入框 |
| `small` | 8dp | 按钮、芯片、小型卡片 |
| `medium` | 12dp | 卡片、对话框、菜单 |
| `large` | 16dp | 悬浮按钮、导航抽屉 |
| `extraLarge` | 28dp | 大型卡片、模态底部面板 |
| `full` | 50% | 圆形按钮、头像、单选按钮 |

### 组件形状应用

```dart
// 全局形状主题
ThemeData(
  useMaterial3: true,
  shapeScheme: const ShapeScheme(
    small: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
    medium: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    large: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
);

// 组件级覆盖
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12), // medium
  ),
  child: ...,
);

// 完全圆形
FloatingActionButton(
  shape: const CircleBorder(), // full
  child: const Icon(Icons.add),
);
```


## 组件状态系统

Material 3 定义了 **6种交互状态**，每种状态都有明确的颜色和叠加层规范。

### 状态类型

| 状态 | 触发条件 | 视觉表现 | 适用平台 |
|------|---------|---------|---------|
| **Enabled** | 默认可交互 | 标准颜色、无叠加 | 全平台 |
| **Disabled** | `enabled = false` | 38% 透明度（表面色）、无阴影 | 全平台 |
| **Hovered** | 鼠标悬停 | 状态叠加层（State Layer）4% 透明度 | 桌面/Web |
| **Focused** | 键盘/语音聚焦 | 状态叠加层 12% 透明度 + 焦点环 | 全平台 |
| **Pressed** | 触摸/点击按下 | 状态叠加层 12% 透明度 | 全平台 |
| **Selected** | 选中/激活 | 容器色变化、图标填充 | 全平台 |
| **Dragged** | 拖动中 | 阴影提升（Elevation +3） | 触摸设备 |

### 状态层叠加

状态层（State Layer）是一种半透明的颜色叠加，统一使用 `onSurface` 颜色：

```dart
// 状态层透明度规范
const Map<MaterialState, double> stateLayerOpacity = {
  MaterialState.hovered: 0.08,   // 8%
  MaterialState.focused: 0.12,   // 12%
  MaterialState.pressed: 0.12,   // 12%
  MaterialState.dragged: 0.16,   // 16%
};

// Flutter 实现状态层
MaterialStateProperty<Color?> getStateLayerColor(BuildContext context) {
  final Color onSurface = Theme.of(context).colorScheme.onSurface;
  
  return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.pressed)) {
      return onSurface.withOpacity(0.12);
    }
    if (states.contains(MaterialState.hovered)) {
      return onSurface.withOpacity(0.08);
    }
    if (states.contains(MaterialState.focused)) {
      return onSurface.withOpacity(0.12);
    }
    return null; // 无叠加
  });
}
```

### 禁用状态规范

禁用状态遵循 **38% 透明度规则**：

- 容器：38% 透明度（相对于 surface）
- 文字/图标：38% 透明度（相对于 onSurface）
- 边框：12% 透明度（如果存在）
- 无阴影、无状态层

```dart
// 禁用按钮示例
ElevatedButton(
  onPressed: null, // 禁用状态
  style: ElevatedButton.styleFrom(
    disabledBackgroundColor: Theme.of(context)
        .colorScheme
        .onSurface
        .withOpacity(0.12), // 12% 表面叠加
    disabledForegroundColor: Theme.of(context)
        .colorScheme
        .onSurface
        .withOpacity(0.38), // 38% 文字
  ),
  child: const Text('不可用'),
);
```

## 跨平台实现

Material 3 通过 Google 官方库 **Material Color Utilities** 库实现跨平台一致性：

- Quantizer（色彩量化）
- Score（主色选择）
- HCT 转换
- CorePalette 生成
- Scheme 生成（Light/Dark）

Flutter 的 ColorScheme.fromSeed() 内部即调用该算法生成：

- primary palette
- secondary palette
- tertiary palette
- neutral palette
- neutralVariant palette

### 官方支持平台

| 平台/框架 | 实现方式 | 动态颜色支持 |
|-----------|---------|-------------|
| **Android (Compose)** | `androidx.compose.material3` | Android 12+ 原生 |
| **Android (Views)** | `com.google.android.material:material:1.7.0+` | `DynamicColors.applyToActivityIfAvailable()` |
| **Flutter** | `flutter/material.dart` + `dynamic_color` 包 | Android 12+，其他平台回退 |
| **Web (Material Web)** | `@material/web` | Chrome/Edge 通过 API |
| **iOS** | `material-color-utilities` Swift 库 | 需手动实现提取 |
| **桌面 (Windows/macOS/Linux)** | 各平台 SDK | 系统强调色适配 |

### 品牌色与动态色的平衡

当应用需要保持品牌识别度时，可采用 **部分动态化策略**：

```dart
// 保留品牌主色，其他角色动态化
ColorScheme buildBrandAwareScheme(Color? dynamicPrimary) {
  final brandPrimary = const Color(0xFF2A57D9); // 品牌蓝
  
  return ColorScheme.fromSeed(
    seedColor: dynamicPrimary ?? brandPrimary, // 优先动态，回退品牌
    primary: brandPrimary, // 强制固定品牌色
    secondary: dynamicPrimary != null ? null : brandSecondary,
    brightness: Brightness.light,
  );
}
```

### 无障碍强制要求

Material 3 的所有颜色角色默认满足以下标准：

- **AA 级对比度**：正常文本 4.5:1，大文本/图标 3:1
- **状态可识别**：不仅依赖颜色，还需形状/图标变化
- **暗色主题优化**：避免纯黑背景（使用 `surfaceDim` 减少眼部疲劳）


## 总结

Material Design 3 代表了设计系统从"静态规范"向"动态算法"的演进。掌握其核心需要理解：

1. **HCT 颜色空间**是动态颜色的科学基础
2. **语义化颜色角色**（26+个）替代了传统的固定色值
3. **Tone-based Surfaces** 废弃了阴影海拔，改用专用表面色
4. **状态层叠加** 提供了统一的状态视觉语言
5. **令牌系统** 确保了设计到开发的单一事实来源

通过 `ColorScheme.fromSeed()` 和 `DynamicColorBuilder`，开发者可以在 Flutter 中轻松实现这套系统，同时保持对品牌一致性的控制。


**参考资源**：

- [Material Design 3 官方文档](https://m3.material.io/)
- [Material Color Utilities GitHub](https://github.com/material-foundation/material-color-utilities)
- [Flutter Material 3 迁移指南](https://docs.flutter.dev/ui/material/material-3)
- [AOSP 核心主题：Material You 设计](https://source.android.com/docs/core/display/material?hl=zh-cn)