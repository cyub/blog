---
title: 告别 Xcode IDE:用 VS Code + SweetPad + XcodeGen 开发 iOS 应用的完整指南
authors: 
  - Tinker
tags:
  - 构建工具/Xcode
  - 构建工具/SweetPad
  - 构建工具/XcodeGen
  - 热重载
  - 编程语言/Swift
  - 入门指南
categories:
  - 工程实践与运维
date: 2026-10-06 10:10:00
---

# 告别 Xcode IDE:用 VS Code + SweetPad + XcodeGen 开发 iOS 应用的完整指南

> 本文以一个真实的小项目 **FloatingBottomSheetsApp**(一个 SwiftUI 底部浮层 Demo)为例,手把手带你搭好一套完全不打开 Xcode IDE 的 iOS 开发环境:工程生成、构建运行、调试、代码补全、格式化、热重载,一次讲清。
>
> 配套示例代码:[cyub/sweetpad-demo](https://github.com/cyub/sweetpad-demo),文中所有配置文件都可以直接对照源码查看。

## 为什么是 VS Code + SweetPad?

很多从其他技术栈转来、或者常年写前端的开发者,对 Xcode 那套 IDE 并不亲近——窗口繁重、编辑器手感一般、和 git 工作流的结合也别扭。SweetPad 是一个 VS Code 扩展,它把 Xcode 的核心能力(构建、运行、调试、热重载)全部搬进了 VS Code,底层驱动的仍然是苹果官方的 `xcodebuild` 和 `lldb`,所以构建产物、签名行为和 Xcode IDE 完全一致,团队成员可以混用两种开发方式,互不影响。

再配上 XcodeGen,`.xcodeproj` 不再是一个需要手工维护(和 git merge 时痛苦)的二进制格式文件,而是一个几十行的 YAML 清单。

一句话总结这套组合的分工:

| 工具 | 职责 |
| --- | --- |
| **XcodeGen** | 用 `project.yml` 声明工程,生成 `.xcodeproj` |
| **SweetPad** | 在 VS Code 里构建、运行、调试、热重载 |
| **VS Code + Swift 扩展** | 编辑器、代码补全(SourceKit-LSP)、格式化 |

<!-- more -->

## 准备工作

你需要一台装了完整 Xcode 的 Mac(Xcode 自带 `xcodebuild`、模拟器、LLDB,这些是 SweetPad 的地基)。

**安装 SweetPad 扩展**:打开 VS Code 扩展面板,搜索 "SweetPad" 安装即可(在 Cursor 里同样可用,它是 VS Code 的 fork)。

![安装 SweetPad 扩展](https://static.cyub.vip/images/202610/install-extension-3f06bf29fab2842c3ce56bbe17eb5f37.png)

**安装 SweetPad CLI**(后面代码补全和调试会用到):

```sh
brew install sweetpad-dev/tap/sweetpad
```

建议顺手把 `xcbeautify` 也装上,构建日志会好看很多:

```sh
brew install xcbeautify
```

当然,SweetPad 侧边栏的 **Tools** 面板提供了一键安装这些工具的入口,不想敲命令行也可以。

## 用 XcodeGen 管理工程

### 为什么需要工程生成器

`.xcodeproj` 里的 `project.pbxproj` 是出了名的难合并、难 review。XcodeGen 的思路是:整个工程用一个 YAML 文件描述,`.xcodeproj` 变成**生成产物**,可以随时删掉重新生成,git 里甚至可以忽略它。

本项目根目录的 `project.yml` 长这样:

```yaml
name: FloatingBottomSheetsApp
options:
  bundleIdPrefix: com.tink
packages:
  Inject:
    url: https://github.com/krzysztofzablocki/Inject
    from: 1.0.0
targets:
  FloatingBottomSheetsApp:
    type: application
    platform: iOS
    deploymentTarget: "17.0"
    sources:
      - path: FloatingBottomSheetsApp
    dependencies:
      - package: Inject
    settings:
      GENERATE_INFOPLIST_FILE: YES
```

几行配置就声明了:应用 target、iOS 17 起步、源码目录、一个 SPM 依赖(Inject,热重载一节会讲),以及让 Xcode 自动生成 Info.plist。

在终端运行:

```sh
xcodegen generate
```

就会在根目录生成 `FloatingBottomSheetsApp.xcodeproj`。

**一个新手常见坑**:如果 target 既没有 `INFOPLIST_FILE` 也没有 `GENERATE_INFOPLIST_FILE: YES`,构建时会报:

```
error: Cannot code sign because the target does not have an Info.plist file
and one is not being generated automatically.
```

这就是上面配置里 `GENERATE_INFOPLIST_FILE: YES` 的来历(Xcode 16 起官方推荐的做法,纯 SwiftUI App 不需要手写 plist)。

### 让 SweetPad 自动重新生成工程

XcodeGen 的工作模式有一个隐患:它只在执行 `xcodegen generate` 的那一刻扫描源码目录,之后**新建的 Swift 文件不会自动进入工程**。如果你新建了 `BottomSheetDemoView.swift` 却忘了重新生成,编译时就会得到一个摸不着头脑的错误:

```
error: cannot find 'BottomSheetDemoView' in scope
```

SweetPad 可以替你盯着这件事。在 `.vscode/settings.json` 里加一行:

```json
{
  "sweetpad.xcodegen.autogenerate": true
}
```

SweetPad 会监听 Swift 文件的新增和删除,自动在后台重跑 `xcodegen generate`。注意两点:

1. **改完设置要重启 VS Code**,watcher 才会激活;
2. watcher 只在**工作区根目录存在 `project.yml`** 时生效。

也可以随时手动触发:命令面板(`⌘⇧P`)运行 `SweetPad: Generate an Xcode project using XcodeGen`。

> **进阶提示**:XcodeGen 2.44+ 支持给 source 加 `type: syncedFolder`(或在 `options` 下设 `defaultSourceDirectoryType: syncedFolder`),生成的工程直接引用文件夹而不是罗列文件,Xcode 会自动感知磁盘上的文件增删,连重新生成都省了。不过修改 `project.yml` 本身仍然需要 regenerate。

## 构建与运行

### 第一次构建

用 VS Code 打开**项目根目录**(即包含 `.xcodeproj` 的文件夹,不是 `.xcodeproj` 本身),点开左侧的 SweetPad 侧边栏(棒棒糖图标 🍭)。

![打开项目](https://static.cyub.vip/images/202610/open-project-46d9e2740a16e0c7cb3ea3b48565ff5e.png)

侧边栏分三块:

- **Build**:所有 scheme,每个都有 ▶️ 构建运行按钮;
- **Destinations**:所有可运行的位置(模拟器、真机、macOS);
- **Tools**:辅助工具一键安装。

点击 scheme 旁边的 ▶️,SweetPad 会让你选一个模拟器,然后执行构建、启动模拟器、安装并拉起 App——全程不需要碰 Xcode。官方的完整流程演示:

![构建与运行演示](https://static.cyub.vip/images/202610/build-demo-ed226f37b3e31a92674e49daf254b588.gif)

构建视图速览:

- **▶️ Build & Run**:scheme 名字旁的播放键,构建并运行;
- **⚙️ Build**:齿轮键,只构建不运行;
- **右键 scheme**:`SweetPad: Clean`(清理构建目录)、`SweetPad: Resolve Dependencies`(解析 SPM 依赖)。

构建过程中, scheme 旁会出现 ⏹ 停止按钮,点它(或命令面板运行 `SweetPad: Stop build / running app`)可以随时终止构建或正在运行的 App——对付卡死的测试或停不下来的进程特别好用。

![构建面板](https://static.cyub.vip/images/202610/build-preview-d0bb6bf50c7500e5ce4cc23fe88b9965.png)

### 固定 scheme 和目标设备

每次构建都弹选择框很烦。可以直接在 `.vscode/settings.json` 里固定:

```json
{
  "sweetpad.build.scheme": "FloatingBottomSheetsApp",
  "sweetpad.build.destination": {
    "type": "iOSSimulator",
    "id": "iossimulator-AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
  }
}
```

`destination` 最省事的写法是运行命令 `SweetPad: Select destination`,让 SweetPad 帮你写入。也可以手动粘贴 `xcrun simctl list` 里的 UDID。

> **协作提示**:`destination` 里的模拟器 UDID 是**机器相关**的(每台 Mac 都不同),提交到 git 会在别人机器上显示为本地改动。团队项目建议只固定 scheme,destination 留给每个人自己选。

### 常用构建配置

SweetPad 暴露了不少构建设置,按需取用:

```json
{
  // 自定义 DerivedData 路径(比如放进项目内,方便 CI 缓存)
  "sweetpad.build.derivedDataPath": ".build/derivedData",

  // 透传给 xcodebuild 的额外参数
  "sweetpad.build.args": ["-skipMacroValidation"],

  // 传给 App 本身的启动参数 / 环境变量
  "sweetpad.build.launchArgs": ["--my-arg"],
  "sweetpad.build.launchEnv": {
    "MY_ENV_VAR": "my-value"
  }
}
```

### 把构建接入 tasks.json

SweetPad 注册了 VS Code 的 task provider,构建动作天然出现在 `Tasks: Run Task` 里。也可以写进 `.vscode/tasks.json` 组合使用。本项目的配置:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "type": "sweetpad",
      "action": "launch",
      "label": "sweetpad: launch",
      "detail": "Build and launch the app",
      "isBackground": true,
      "problemMatcher": ["$sweetpad-watch"]
    }
  ]
}
```

> `isBackground: true` 和 `$sweetpad-watch` 两个属性在把该 task 用作调试的 preLaunchTask 时**缺一不可**,它们让 VS Code 知道"构建已就绪、App 正在启动"。

## 代码补全:让 SourceKit-LSP 认识 Xcode 工程

VS Code 的 Swift 补全由 [Swift 扩展](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)的 SourceKit-LSP 提供,但 SourceKit-LSP 需要一个 **build server** 告诉它每个文件是怎么编译的(SDK、模块名、编译条件……)。纯 Swift Package 不需要额外配置,而 `.xcodeproj` 工程需要 `buildServer.json`。

SweetPad 内置了自家的 build server(通过 `sweetpad bsp serve` 运行,**无需先构建一次**,补全立即可用)。第一次构建时 SweetPad 会自动在工作区根目录生成 `buildServer.json`,也可以用命令面板手动生成:`SweetPad: Generate Build Server Config`。

生成的 `buildServer.json` 大致长这样(`argv` 里的路径因机器而异,所以这个文件不需要提交,`.gitignore` 掉即可,首次构建时 SweetPad 会重新生成):

```json
{
  "name": "sweetpad",
  "version": "0.2.18",
  "bspVersion": "2.2.0",
  "languages": ["swift", "objective-c", "objective-cpp", "c", "cpp"],
  "argv": [
    "/opt/homebrew/bin/sweetpad",
    "bsp",
    "serve",
    "--config",
    "/Users/tinker/.local/state/sweetpad/projects/6d30e6004bc5/bsp.json"
  ]
}
```

配置好后打开任意 Swift 文件,补全、跳转定义、悬浮文档、实时的编译诊断就都有了:

![自动补全预览](https://static.cyub.vip/images/202610/autocomplete-preview-7a93e7ec8175fe48f6fbbe1787c2b06d.png)

如果补全不工作,运行 `SweetPad: Diagnose BSP (Doctor)`,它会逐项检查整条链路并给出修复建议。

## 格式化代码:保存即格式化

SweetPad 默认使用 Apple 官方的 **swift-format**(Xcode 16 起随 Xcode 附带,无需单独安装;Xcode 15 及更早需要 `brew install swift-format`)。

在 `.vscode/settings.json` 中配置保存时自动格式化:

```json
{
  "[swift]": {
    "editor.defaultFormatter": "sweetpad.sweetpad",
    "editor.formatOnSave": true
  }
}
```

之后打开 Swift 文件按 `⌘S`,文件就会自动整理格式:

![格式化演示](https://static.cyub.vip/images/202610/format-demo-a062e8a06a192b08747a03161cc003a9.gif)

不喜欢 swift-format 的风格?可以换成社区流行的 SwiftFormat:

```json
{
  "sweetpad.format.path": "swiftformat",
  "sweetpad.format.args": ["--quiet", "${file}"]
}
```

> `--quiet` 让 stderr 安静下来,避免 SweetPad 把正常输出误判为格式化失败。格式化报错时,运行 `SweetPad: Show format logs` 查看原因。

## 调试:断点、LLDB 一应俱全

### 最小配置

SweetPad 有两种调试后端:

- **SweetPad CLI 的 `sweetpad dap`**(驱动 Xcode 自带的 `lldb-dap`,零配置,推荐);
- **CodeLLDB 扩展**(CLI 未安装时的回退,需要手动指定 Xcode 的 LLDB 库路径)。

在 `.vscode` 下创建 `launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "sweetpad-lldb",
      "request": "launch",
      "name": "SweetPad: Build and Run"
    }
  ]
}
```

也可以在 Run and Debug 面板点击 "Create a launch.json file" 自动生成:

![创建 launch.json](https://static.cyub.vip/images/202610/debug-create-launch-json-bd5de1e4cce4ecf51c4d5a29c304d63c.png)

选择 SweetPad 调试器:

![选择 SweetPad LLDB](https://static.cyub.vip/images/202610/debug-select-sweetpad-lldb-29fa39aaebfec166921aa64be6dc66e8.png)

### 开始调试

按 **F5**。SweetPad 会构建 App、装进模拟器、启动,然后把 LLDB 附到运行中的进程上。设好断点,当代码命中断点时,你会在 VS Code 里看到完整熟悉的面板:变量查看、调用栈、单步执行、LLDB 控制台,和任何语言的调试体验一致。

![启动调试器](https://static.cyub.vip/images/202610/debug-launch-debugger-58f4bd733807c66719aa4f798d38d370.png)

![断点调试](https://static.cyub.vip/images/202610/debug-breakpoints-aacaa32b9c66b8356081542cad61c91b.png)

之后的每次调试,直接按 F5 就行——重建、重启、重新附加,一条龙。

### 使用 CodeLLDB 的情况

如果没装 SweetPad CLI 走的是 CodeLLDB,需要在 `settings.json` 里把 CodeLLDB 指向 Xcode 内置的 LLDB:

```json
{
  "lldb.library": "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/LLDB"
}
```

### 调试进阶

- 想调试 Release 配置?在 `tasks.json` 里定义一个自定义 task(`scheme`/`configuration` 填 Release,同样带 `isBackground` + `$sweetpad-watch`),然后 `launch.json` 里用 `"preLaunchTask"` 引用;
- `launch.json` 顶层的 `scheme`、`configuration`、`destination`、`args`、`env` 可以覆盖 SweetPad 面板中的选择;
- 真机调试开箱即用(iOS 17+ 真机走 `devicectl` / pymobiledevice3 的开发者隧道,首次连接有一次性的信任设置)。

## 热重载:保存即见效

这是整套工作流里最爽的一环:改一行 SwiftUI 代码,`⌘S` 保存,模拟器里的 App **不重新构建、不重启**,一秒内就更新了。做 UI 微调时,这个反馈循环从"编译 30 秒"缩短到"眨眼之间"。

SweetPad 为你接好了开源项目 **InjectionNext**,不用动任何 Xcode 构建设置或 AppDelegate。

> **平台限制**:热重载只支持 iOS / tvOS / visionOS 模拟器和 macOS。真机因为苹果的代码签名机制(会剥离 `DYLD_INSERT_LIBRARIES`)无法使用;watchOS 不支持。

### 安装 InjectionNext

命令行安装(InjectionNext 不在 Homebrew,GitHub Releases 是唯一渠道):

```sh
curl -L -o /tmp/InjectionNext.zip \
  https://github.com/johnno1962/InjectionNext/releases/latest/download/InjectionNext.zip
unzip -d /tmp /tmp/InjectionNext.zip
mv /tmp/InjectionNext.app /Applications/
```

或者从 SweetPad 侧边栏 Tools 面板的 InjectionNext 一键入口跳到 Releases 页面下载。不需要手动启动它,SweetPad 运行 App 时会自动拉起。

### 打开开关

`.vscode/settings.json`:

```json
{
  "sweetpad.hotReload.enabled": true
}
```

打开后,SweetPad 会自动做三件事:

1. **构建参数**:给 `xcodebuild` 追加 `OTHER_LDFLAGS=$(inherited) -Xlinker -interposable`(把 Swift 函数发射为可替换符号)和 `EMIT_FRONTEND_COMMAND_LINES=YES`;
2. **启动环境**:设置 `DYLD_INSERT_LIBRARIES` 自动加载注入 dylib,设置 `INJECTION_PROJECT_ROOT` 告诉 InjectionNext 监听哪个目录;
3. **框架路径**:把当前 Xcode 的平台目录前置于 `DYLD_FRAMEWORK_PATH`,避免 dyld 找不到 XCTest 框架。

### 添加 Inject 依赖(SwiftUI 项目)

SwiftUI 会缓存 `body` 的计算结果,需要 Krzysztof Zabłocki 的 [Inject](https://github.com/krzysztofzablocki/Inject) 包配合刷新。XcodeGen 项目在 `project.yml` 里声明:

```yaml
packages:
  Inject:
    url: https://github.com/krzysztofzablocki/Inject
    from: 1.0.0

targets:
  FloatingBottomSheetsApp:
    # ...
    dependencies:
      - package: Inject
```

然后 `xcodegen generate` 重新生成工程。

### 给视图加两行注解

在想热重载的 SwiftUI 视图上加两行(本项目的 `ContentView.swift`,一个最简底部浮层 Demo):

```swift
import Inject
import SwiftUI

struct ContentView: View {
  @ObserveInjection var inject
  @State private var showSheet = false

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "rectangle.bottomthird.inset.filled")
        .font(.system(size: 56))
        .foregroundStyle(.tint)
      Text("Floating Bottom Sheets")
        .font(.title2.bold())
      Button("Show Bottom Sheet") {
        showSheet.toggle()
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .sheet(isPresented: $showSheet) {
      SheetContent()
        .presentationDetents([.height(220), .medium])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
    }
    .enableInjection()
  }
}
```

- `@ObserveInjection`:订阅 InjectionNext 的注入通知,让 SwiftUI 认为视图已失效;
- `.enableInjection()`:确保注入运行时已加载,并用 `AnyView` 包裹视图,容忍 `body` 结构变化。

> **偷懒技巧**:只在**根视图**加这两个注解就够了——注入触发时 SwiftUI 会从根向下整棵失效刷新。代价是每次保存整棵树重算,小 App 无感,超大 App 会明显。也可以用 InjectionNext 菜单栏的 `Prepare SwiftUI → Prepare Project` 自动给所有文件加上注解。UIKit 项目则完全不需要 Inject,方法体会被自动替换。

### 试一下

1. 在 SweetPad 里 Build & Run,观察控制台输出:

   ```
   🔥 InjectionNext: arm64 iPhoneSimulator connected to app, waiting for commands.
   ```

   同时菜单栏的 InjectionNext 图标变为橙色(蓝色=空闲,橙色=已连接,绿色=编译中,黄色=出错);

2. 把 SheetContent 里的 `Text("Hello, bottom sheet!")` 随便改点什么(比如加个 `.foregroundColor(.red)`),`⌘S` 保存;

3. 控制台出现 `🔥 ✅ Hot reload complete - Rebound N symbols`,模拟器在一秒内更新,`@State`、滚动位置等状态全部保留。

### 边界与排错

**能改的**:函数体、`body` 内容、闭包、计算属性、函数内常量。
**不能改的**(改了需要重启 App):存储属性的增删改名、非 final 类的方法增删、函数签名、`@main`/`App` body、泛型约束、顶层代码。

常见问题速查:

| 症状 | 原因/解法 |
| --- | --- |
| 保存后没反应,但控制台有 `✅ Hot reload complete` | 视图忘了 `.enableInjection()` |
| 菜单栏图标是蓝色 | App 没连上 InjectionNext,检查是否走的模拟器 |
| 图标是黄色 | 上次编译失败,点图标 → Show Log 看错误 |
| 启动崩溃 `dyld: Library not loaded @rpath/XCTest` | `xcode-select` 指向的 Xcode 不对,`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| 链接错误 | 工程自己设置了冲突的 `OTHER_LDFLAGS`,关掉开关手动加 `-Xlinker -interposable` |

> **性能提醒**:`-interposable` 让每个 Swift 函数调用多一次指针跳转,Debug 无感,Release 别开。打正式包前把 `sweetpad.hotReload.enabled` 关掉即可。

## 最终的配置清单

跟着做完后,本项目的 VS Code 相关文件长这样,可以直接抄作业。

**`.vscode/settings.json`**:

```json
{
  "sweetpad.build.scheme": "FloatingBottomSheetsApp",
  "sweetpad.xcodegen.autogenerate": true,
  "sweetpad.hotReload.enabled": true,
  "[swift]": {
    "editor.defaultFormatter": "sweetpad.sweetpad",
    "editor.formatOnSave": true
  }
}
```

> 注意这里**没有**固定 `sweetpad.build.destination`:模拟器 UDID 是机器相关的,公开仓库里写死只会在别人机器上变成"本地改动"。第一次构建时 SweetPad 会让你选一次并记住。

**`.vscode/tasks.json`**(见"把构建接入 tasks.json"节)、**`.vscode/launch.json`**(见调试一节)、**`project.yml`**(见 XcodeGen 一节)、**`buildServer.json`**(自动生成,见代码补全一节)。

**`.gitignore`**(既然 `.xcodeproj` 是生成产物,就让它和自动生成的 `buildServer.json` 一起留在本地):

```gitignore
*.xcodeproj
*.xcworkspace
DerivedData/
.build/
.DS_Store
buildServer.json
```

## 总结

这套工作流的总览:

1. `project.yml` 声明工程 → XcodeGen 生成 `.xcodeproj`(SweetPad 可自动重生成);
2. SweetPad 侧边栏 ▶️ 构建运行,`settings.json` 固定 scheme 和模拟器;
3. `buildServer.json` + SweetPad CLI 让 SourceKit-LSP 活起来,补全和诊断齐备;
4. `[swift]` format on save,保存即格式化;
5. `launch.json` + F5,断点调试一步到位;
6. InjectionNext + Inject 包 + 两行注解,保存即热重载。

从此 Xcode 只需要躺在 `/Applications` 里提供工具链,日常开发完全可以在 VS Code(或 Cursor)里完成。

## 参考资料

- [SweetPad 官方文档](https://sweetpad.hyzyla.dev/docs/vscode/getting-started)
- [SweetPad GitHub](https://github.com/sweetpadhq/sweetpad)
