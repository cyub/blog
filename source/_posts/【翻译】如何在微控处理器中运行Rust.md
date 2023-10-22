title: 【翻译】如何在微控制器中运行Rust?
author: Tink
tags:
  - 固件
  - 微控制器
  - 嵌入式编程
categories:
  - Rust
date: 2023-10-22 00:00:00
---
原文：[Running Rust on Microcontrollers](https://blog.mbedded.ninja/programming/languages/rust/running-rust-on-microcontrollers/#rp2040)

## 概览

`Rust` 是一个相当新的编程语言(它诞生于2010[^1]年)，但在开发嵌入式固件方面显示出巨大的潜力。它首先被设计为一种系统编程语言，这使得它特别适合用于微控制器。它试图通过实现一个强大的所有权模型(可以消除整个错误类的发生)来改进 `C/C++` 的一些最大缺点，这对固件也非常适用。

截至2022年，`C` 和 `C++` 编程语言仍然是嵌入式固件的事实标准。然而 `Rust` 在固件中的角色看起来很光明。`Rust` 对固件的支持并不是后面才考虑到，而是一开始就考虑支持。 为此，`Rust` 专门有官方的 **[嵌入式设备工作组](https://github.com/rust-embedded/wg)** 和 介绍如何使用 `Rust` 进行嵌入式开发的 **[嵌入式Rust之书](https://docs.rust-embedded.org/book/)**。下图就是Rust嵌入式设备工作组logo[^2]。

![Rust嵌入式设备工作组logo](https://static.cyub.vip/images/202310/ewg-logo-blue-white-on-transparent.png)

本篇文章旨在探索在微控制器（这里指的是低级嵌入式固件，而不是在 `Linux` 等主机环境上运行）上运行 `Rust`，涵盖以下内容：

- 语言特性
- 架构支持
- MCU家族支持
- IDE, 编码 和 编码体验
- 实时操作系统
- Rust缺点

<!-- more -->

## Rust语言特性

让我们探索 `Rust` 的一些语言特性以及把它们如何应用于嵌入式固件中。

### 所有权

`Rust` 与 `C/C++` 的核心区别之一是 `Rust` 实现了一个强大的所有权模型。这可以预防 `C/C++` 中可能出现的许多与内存相关的错误(例如内存泄漏、悬挂指针等)。`Rust` 的这些优势，不仅适用于软件，也适用于嵌入式固件。

对于除了基本原始数据类型之外的任何存在于堆栈上的数据类型（基本原始数据类型包括 `u32`、`bool`、`f64` 等），`Rust` 在使用赋值运算符时都会移动数据，而不是执行复制。下面示例显示编译器如何强制一次只有一个变量可以拥有一段数据：

```rust
let s1 = String::from("hello"); // Create complex data type which involves the use of the heap
let s2 = s1; // This "moves" the data from s1 to s2 (s2 owns the data), s1 is no longer valid

println!("{}", s1); // The compiler will throw an error here, s1 is no longer valid!
```

如果你确实想执行拷贝，正确作用法是 `s2 = s1.clone()`。这些所有权规则也适用于向函数传递变量。你可以在《**[Rust编程语言](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)**》第4章“理解所有权”中找到详细介绍。

除了转移所有权， Rust还允许你通过引用“**借用**”数据。你只被允许:

- 可以借用任意数量的不可变引用，但不允许再借用可变引用
- 有且只能借用一个可变引用，但不再允许借用不可变引用
 
## 访问外围设备

编写固件的一个重要部分是与外围设备（外围设备简称外设，比如 `GPIO`、`UART`、`USB`、`DMA` 等）进行交互。大多数外设都是内存映射的——即你需要通过读/写“魔术”内存地址(magic adress)来控制外设。在 `Rust` 中访问外设的标准方式是使用外设访问((Peripheral Access)库或 `PAC`。很有可能你使用的特定微控制器已经有了`PAC`。

例如，`cortex_m` 库 提供对所有 `Cortex-M` 设备共享的外设的访问（例如 `NVIC 中断`、`SysTick`）。你可以通过调用 `take().unwrap()` 来“声明”外设：

```rust
use cortex_m::interrupt;
use cortex_m::peripheral::Peripherals;
use stm32f30x::Interrupt;

let cp = cortex_m::Peripherals::take().unwrap(); // This will work only once!

// Let's enable an interrupt
let mut nvic = cp.NVIC;
nvic.enable(Interrupt::TIM2);
```

请注意，这里采用了单例模式 - 你只能调用 `take()` 一次并使其返回 `Some<T>`。下次它将返回 `None`，然后调用 `unwrap()` 会导致 `panic`。你通常需要会在 `main()` 或 App类的开始进行 `take()`。

对于那些不是 `Cortex-M` 架构一部分的其他外设(例如 `UART`、定时器、`PWM` 等)通常可以在特定微控制器的不同库中找到。例如，如果我使用 `STM32F30x` 微控制器，我会添加适当的 `PAC` 库，然后可以编写:

```rust
let mut peripherals = stm32f30x::Peripherals::take().unwrap(); // Again, will work only once!
peripherals.GPIOA.odr.write(|w| w.bits(1));
```

Rust 还可以在编译时提供编译时检查，确保硬件已根据代码的使用方式进行了正确配置。正如《**[嵌入式Rust之书](https://docs.rust-embedded.org/book/)**》一书所说:

- 当应用于嵌入式程序时,这些静态检查可以用于确保正确配置I/O接口。例如,可以设计一个API,其中只有首先配置串口接口将使用的引脚,才能初始化串口接口。

 - 还可以静态检查仅在正确配置的外设上执行操作(如设置引脚为低电平)是否有效。例如,试图改变配置为浮空输入模式的引脚的输出状态会引发编译错误。——来自《嵌入式Rust之书》中静态保证[^3]

让我们用一个例子来解释这一点。我们遵循《**[嵌入式Rust之书](https://docs.rust-embedded.org/book/)**》指南,使用 `GPIO` 引脚(MCU外设的一种基本形式)作为示例,使用 `into_...()` 命名函数在不同类型之间转换。

```rust
let pin = get_gpio();

// We can't do much with a disabled GPIO pin, let's convert it
// into an input pin
let input_pin = pin.into_enabled_input_pin();

// We can now read the state of the pin
let pin_state = input_pin.is_set();

input_pin.set(); // We can't set an input, this produces a compile time error!

// We've changed our minds, we now want it to be an output! This
// is easy to do, again it "consumes" the input_pin object
let output_pin = input_pin.into_enabled_output_pin();

// Set output pin high
output_pin.set(true);
```

`svd2rust` 是一个命令行工具，可以提取 `SVD` 文件（又名 `CMSIS-SVD`，它们是定义寄存器名称、地址和用途的文件，你可以将它们视为微控制器数据表的计算机可读版本）并创建 `Rust PAC` 包在类型安全的 `Rust API`[^4] 中公开外围设备。目前它支持 `Cortex-M`、`MSP430`、`RISCV` 和 `Xtensa LX6` 微控制器[^4]。

### 特征

`Rust` 通过其 **特征(trait)** 支持 **临时多态性(ad-hoc polymorphism)**。一个常见的例子是浮点数和整数类型都实现了 `Add` 特征，因为它们可以相加。**[embedded-hal](https://github.com/rust-embedded/embedded-hal)** 项目利用特征来定义 `GPIO` 引脚(输入和输出)、`UART`、`I2C`、`SPI`、`ADC` 等。这些通用接口可以被应用程序代码使用，而底层具体的驱动程序为每个特定的微控制器实现正确的功能。这与 `C++` 中如何使用虚拟接口类来创建可移植的 `HAL` 非常相似。在本篇的文章 **[cargo和包结构部分](#cargo和包组织结构)** 会有更多相关内容介绍。

例如，`serial::Read` 和 `Write` 特征被定义为[^5]。


```rust
pub trait Read<Word> {
    type Error;
    fn read(&mut self) -> Result<Word, Self::Error>;
}

pub trait Write<Word> {
    type Error;
    fn write(&mut self, word: Word) -> Result<(), Self::Error>;
    fn flush(&mut self) -> Result<(), Self::Error>;
}
```

### 更安全的数组

在 `Rust` 中，如果你索引一个数组，它会自动进行**边界检查(bounds checking)**。这可以防止在 `C/C++` 中尝试相同的操作时出现大量微妙的“未定义行为错误”（以及安全问题！）。当然，边界检查确实会产生少量的运行时开销（在 99% 的用例中这可能可以忽略不计）。
 
```rust
fn main() {
    let arr: [i8; 3] = [1, 2, 3];
    // Rust will throw a compiler error on the next line, since it can work out a compile time that this
    // index is out of bounds
    let _ = arr[3];
}
```

如果将数组引用传递给函数，那么如果索引越界，`Rust` 将无法在编译时进行计算。在这种情况下，它将在运行时进行边界检查并出现恐慌：

```rust
fn main() {
    let arr: [i8; 3] = [1, 2, 3];
    out_of_bounds(&arr);
}

fn out_of_bounds(arr: &[i8]) {
    println!("{:?}", arr);
    let _ = arr[3]; // Rust will do a runtime bounds check and panic here
}
```

如果你的应用程序需要考虑边界检查的运行时开销，那么你可以通过使用数组迭代器而不是索引（或使用 `get_unchecked()`）来消除此开销。事实上，这是访问数组的推荐方法，除非你确实必须使用索引（某些情况仍然需要随机访问数组）。

你可能还注意到，数组不会像在 `C/C++` 中那样容易地退化为指针（即丢失维度信息 - `sizeof` 现在为你提供指针的大小）。在 `Rust` 中，你可以将对任何大小的数组的引用传递到函数中，同时仍然可以通过调用 `.len()` 找到它的长度，这是你在 `C/C++` 中无法做到的（你可以在 `C/C++` 中传递数组，而无需变量退化为一个指针，但你必须将函数硬编码为特定的数组大小，这是因为大小信息未保存在数组内存布局中）。

```rust
fn no_decaying_to_pointer(arr: &[i8]) {
    // Yay! Arrays don't decay to pointers, I still
    // have length information!
    println!("{:?}", arr.len());
}
```

### 并发

当涉及到中断和多线程/多核心（例如运行 `RTOS`）时，并发性是嵌入式固件中你必须关心的问题。你第一次遇到并发问题的时候之一是在中断内更新变量时。在 `C/C++` 中，使用易失性(`volatile`)和临界区(`critical sections`)通常是解决问题的办法。当使用多线程时，互斥体/队列/等 `RTOS` 原语可以用于防止数据遭到破坏。

在 Rust 中，你还可以使用临界区来防止中断中的数据竞争。**[nb](https://docs.rs/nb/latest/nb/index.html)** 库采用了一种有趣的方法来解决决定 `API` 调用是否应该阻塞（或如何阻塞！）的问题。它允许编写 API 的人编写核心功能，然后让调用者决定阻塞行为。 `API` 返回 `nb::Result<T, Error>` 类型，其中 `T` 是函数的标准返回类型。如果调用者确实想要阻塞等待函数完成，他们可以将调用包装在块中 `block!`。**[nb](https://docs.rs/nb/latest/nb/index.html)** 库有一定的潜力与 `HAL` 外设一起使用，例如 `UART`的 `read/write()` 函数（通常会阻塞，直到发送/接收数据）。

### 错误处理

在大多数语言中，有两种常见的错误处理方式。

- 返回错误代码
- 抛出异常

在嵌入式固件中，有时由于执行时间不可预测(尽管与普遍认识相反,异常实际上可以改进非异常情况下的运行时性能)或增加了每个开发者都必须注意的复杂性，需要禁止使用异常。返回错误代码是许多嵌入式项目的标准错误处理方式，但你必须记住检查错误并将它们适当地传播到调用堆栈。`Rust` 的 `Result` 类型，它可以极大地改善错误处理体验。

例如，让我们实现一个 `uart_write_bytes()` 函数，它通过 `UART` 写入一组字节。我们的 `UART` 有一些特殊的要求，一次不能写入超过 10 个字节。如果用户提供超过 10 个字节，我们希望返回错误条件。如果他们提供 10 个字节或更少，我们希望将它们写出 `UART`，然后返回写入的字节数。让我们来写这个函数：

```rust
fn uart_write_bytes(bytes: &[u8]) -> Result<usize, &'static str> {
    if bytes.len() > 10 {
        return Err("Can only write 10 bytes or less!");
    }
    // Write bytes here
    // ....

    // Writing completed successfully, return number of bytes written
    Ok(bytes.len())
}
```

如果我们尝试使用这个函数并且忘记检查返回的结果，`Rust` 会产生警告，例如如果我们这样写：

```rust
let data = [32, 38, 24, 34];
uart_write_bytes(&data); // Oh oh, we've forgotten to check for an error
```

`Rust` 会抛出如下错误：

![](https://static.cyub.vip/images/202310/compiler-warning-about-unused-result.png)

如何正确处理这个返回的 `Result` 对象呢？一种方法是调用 `unwrap()`。如果没有错误，`unwrap()` 将返回该值；如果有错误，则会出现恐慌。在错误不可恢复的情况下，你可以使用 `unwrap()`，并且在嵌入式情况下，你可以定义恐慌的作用（将其视为与 `C/C++` 断言相同）。

```rust
// Using unwrap() we can unpack the returned `Result` type, we either get the number of bytes if write was successful or panic if `Err` was returned
let num_bytes = uart_write_bytes(&data).unwrap(); 
```

还有 `Expect()` ，它与 `.unwrap()` 类似，只不过它还允许你提供自定义错误消息：

```rust
let num_bytes = uart_write_bytes(&data).expect("Writing bytes to UART failed."); 
```

如果错误是可恢复的和/或预期的，则可以在 `Result` 对象上使用 `match` 语句来适当地处理错误情况。

```rust
fn main() {
    // We used the ? operator in perform_comms(), which propagates the error
    // back to here.
    perform_comms().unwrap();
}

fn perform_comms() -> Result<(), &'static str> {
    let data = [32, 38, 24, 34];
    let num_bytes = match uart_write_bytes(&data) {
        Ok(num_bytes) => num_bytes,
        Err(e) => // Handle error condition here -- maybe retry?
    };

    return Ok(());
}

fn uart_write_bytes(bytes: &[u8]) -> Result<usize, &'static str> {
    if bytes.len() > 10 {
        return Err("Can only write 10 bytes or less!");
    }
    // Write bytes here
    // ....

    // Writing completed successfully, return number of bytes written
    Ok(bytes.len())
}
```

另一种选择是使用问号运算符 `?` 。 这是执行匹配语句并在出现错误时提前返回的简写，它本质上是在堆栈中传播错误条件。这种设计风格是常见的做法（它与异常的工作方式非常相似），因此 `Rust` 为其引入简写是有道理的。以下示例显示了这一点，并添加了一个额外的函数来显示错误传播。

```rust
let num_bytes = uart_write_bytes(&data)?;
```

上面代码等效于：

```rust
let num_bytes = match uart_write_bytes(&data) {
    Ok(num_bytes) => num_bytes,
    Err(e) => return Err(e),
};
```

**注意：** 阅读完所有内容后，你可能想知道 `Rust` 如何实现这些看似包含不同“类型”数据的返回类型。这背后的关键思想是 `Rust` 的枚举在幕后实现为所有事物的标记联合。还有空指针优化，这意味着当有两种可能的返回类型时，`Rust` 可以优化联合类型的空间：
- 不包含任何数据（例如 `None`）
- 另一个包含数据但不可能是0。在这种情况下，`Rust` 会将这两件事折叠成一个变量，并使用 `0` 来表示 `None`。这就是 `Option<&T>` 的工作原理。

### no_std

`Rust` 拥有 **第一层嵌入式支持(first-tier embedded support)** 的原因之一是标准化的 `#![no_std]` crate级的属性。此属性指示 crate 将链接到 `core-crate` 而不是 `std-crate`。 `core-crate` 是 `std-crate` 的子集，它不包含任何假设/需要使用操作系统的 `API`。此 `no_std` 非常适合裸机或自定义 `RTOS` 环境。它提供了基本功能，例如基本数据类型（浮点、字符串、切片等）和通用处理器功能，例如原子操作和 `SIMD` 指令。但是，它不提供任何 `API` 来创建线程、文件系统访问或进行系统调用的能力等功能。

`no_std` 无法实现的另一件事是初始化，它设置堆栈溢出保护并生成一个线程来调用 `main()` 。因此，在嵌入式 `no_std` 开发中，你可以定义要作为 "main" 的函数。

`no_std` 还意味着在默认情况下，你无法在堆上动态分配内存。乍一看这可能看起来很奇怪，因为在嵌入式 `C` 开发中通常有 `malloc()/free()` 等，而在 `C++` 中则有 `new/delete`。没有动态内存分配意味着你不能使用任何依赖它的对象（如动态数组或字符串），`Rust` 这些被称为集合（Vec、Box、BTreeMap 等）。在某些情况下，固件中没有动态内存分配是可以的（事实上更可取或必需，例如 MISRA）。然而，动态内存分配有一些很好的用例（我对非危及生命的应用程序的一般规则是允许它，但仅在初始化期间）。幸运的是，只要它们是适合你的微控制器架构的分配器，你就可以启用它。例如，**[alloc-cortex-m](https://github.com/rust-embedded/alloc-cortex-m)** 库 为 `Cortex-M` 架构提供了一个自定义分配器。然后，你还可以使用标准 `Rust` 集合（但要小心它们！）。

`no_std` 还意味着你必须定义恐慌的作用。在嵌入式开发中，不允许从恐慌函数返回，因此函数需要具有`fn(&PanicInfo) -> !`签名 。你可以包含一些第三方包，它们对于嵌入式固件中的恐慌很有用：

- panic-halt：通过进入无限循环导致当前线程停止。
- panic-itm：恐慌消息通过 `ITM` 记录到主机，`ITM` 是 Cortex-M 特定的调试外设（比半主机更快）。
- panic-semihosting：恐慌消息通过半主机(panic-semihosting)记录到主机。

一旦你添加了这些包之一作为依赖项，你所需要做的就是告诉 Rust 编译器你想要链接到它，因为你不会直接从中调用任何内容。为此，请使用：

```rust
use panic_halt as _;
```

`_` 很重要，因为它告诉编译器你想要链接到它，但不从中调用任何内容。如果你没有这个，编译器会向你发出未使用的导入警告。

### cargo和包组织结构

`C/C++` 非常缺乏的一个功能是用于管理依赖项和构建过程的标准化包管理器。幸运的是（像大多数常见语言一样）`Rust` 附带了 `cargo` 包管理器。 `cargo` 可以很好地转化为嵌入式开发，你可以使用它轻松包含第三方包（他们称之为 crate），或者创建你自己的库以使你的代码更加模块化和可重用。

我真正喜欢货物的一件事是它允许安装扩展，这可以为 `cargo` 命令添加功能。**[cargo-flash](https://github.com/probe-rs/cargo-flash)** 包可为 `cargo` 添加微控制器烧录支持。你可以使用以下命令安装 `cargo-flash`：

```rust
$ cargo install cargo-flash
```

它会将子命令 `cargo flash` 添加到 `cargo` 命令中。然后，你可以输入以下内容，使用 `Rust` 可执行文件对微控制器进行编程：

```shell
$ cargo flash --chip STM32F042C4Tx
```

Cargo 和嵌入式的另一个好处是，社区似乎已经采用了一种结构化的方式来组织各种与固件相关的库。这包括：

- **外设访问包 (Peripheral Access Crates，简写成PAC)**：包含控制微控制器外设的内存映射寄存器的最小命名。

- **架构支持包(Architecture Support Crate)**：包含用于控制 `CPU` 和跨 `CPU` 架构共享的外设的 `API`（例如用于控制中断、系统滴答的 `API`）。

- **硬件抽象层 (Hardware Abstraction Layers，简写成HAL)**：将 `PAC` 寄存器包装成易于使用的外设 `API`，例如 `uart.init()`、`uart.write_byte()`、`adc.read_value()` 等。虽然这不是 `Rust` 所独有的，但我们可能期望 `Rust` 中的 `HAL` 能有更好的标准化，因为 `embedded-hal` 努力保持其在 `MCU` 系列之间的一致性。在 `C/C++` 中，`HAL` 的 `API` 通常对于 `MCU` 系列（STM32、SAMD 等）或框架（Arduino、mbed 等）是唯一的。

- **板级支持包(Board Support Crate)**： 该包是为包含微控制器的特定 `PCB` 项目而构建的。 板级支持包使用 `HAL` 并根据 `MCU` 与物理世界的连接方式创建适当命名的 `HAL` 对象实例。这是一个可选的额外包，如果你正在设计一个可供许多人用于许多不同目的的板子，那么创建板级支持包这是一个好主意。对于一次性项目，创建板级支持包的额外开销可能不值得，相反，你可以将此代码捆绑在应用程序中。

- **实时操作系统 (Real-time Operating System，简写成RTOS)**： 就像 `C/C++` 固件开发一样，你也可以获得 `Rust` 的 `RTOS`。其中一些是 `C/C++` `RTOS`（如 `FreeRTOS`）的端口/包装器，另一些是针对 `Rust` 从头开发的 `RTOS`。使用 RTOS 是完全可选的，并且通常对于较大、复杂的固件应用程序有意义。

- **应用程序(Application)**： 作为任何固件项目的最后一层，包含高级业务逻辑。应用程序层通常向下调用 `RTOS`（如果存在）和 `HAL` 层。

该结构如下图所示：

![Rust嵌入式固件项目的分层结构](https://static.cyub.vip/images/202310/crate-structure-for-embedded-rust.png)

### cargo特性


在嵌入式固件中，通常希望能够基于条件（例如 `DEBUG` 与 `PRODUCTION` 或 `ENABLE_LARGE_LUT_ARRAY`）包含/排除代码块，比如通过删除生产版本中的调试字符串或包含特定于架构的字符串来释放内存使用量代码（因此你可以使用相同的代码库来定位多个微控制器）。在 `C/C++` 领域，这通常使用预处理器指令（`#ifdef` 等）来实现。然而，Rust 中没有预处理器。在 Rust 中解决这个问题的惯用方法是使用 **[Cargo 特性](https://doc.rust-lang.org/cargo/reference/features.html#the-features-section)**。

所有 `cargo` 特性都必须在 `cargo.toml` 的 `[features]` 下定义。例如：

```toml
[features]
DEBUG
```

然后，在 `.rs` 源代码文件中，你可以有条件地包含代码块：

```rust
#[cfg(feature = "DEBUG")]
<debug code goes here>
```

默认情况下，所有特性均被禁用，除非在 `cargo.toml` 中定义了`default` 特性。

### Rust宏

`C/C++` 预处理器的另一个用途是出于性能原因：可能需要通过创建执行直接文本替换的预处理器宏来避免函数调用。这在现代 `C/C++` 中不是什么问题，因为编译器已经非常擅长知道何时自动内联函数。但尽管如此，你仍然可以使用 `Rust` 的宏系统在 `Rust` 中执行类似的技巧。它在很多方面都比 `C/C++` 预处理器（执行基本文本替换）更强大、更智能。然而，你可以使用 `C/C++` 预处理器执行一些在 `Rust` 中无法执行的技巧，例如部分变量名称替换。

嵌入式 `C/C++` 固件中的一种常见模式是使用预处理器创建一个 `assert()` 宏，该宏不仅检查提供的表达式是否为真，而且还获取当前文件、行号和提供的表达式作为字符串。例如：

```c
#define assert( exp ) \
    ( (exp) ? (void)0 : assert_fn( __LINE__, __FILE__, #exp))
#endif
```

这是通过特殊的宏 `__LINE__`、`__FILE__` 和 `#exp`（其中 `#` 对 `exp` 进行字符串化）实现的，而且宏内容在 `assert()` 的任何地方都会被放入源代码中。幸运的是，你可以通过利用 `line!()`、`file!()` 和 `stringify!()` 宏（它们是编译器内置宏）在 Rust 中执行相同的操作[^6]。

![Rust标准库中使用宏的示例](https://static.cyub.vip/images/202310/file-macro-in-rust-compiler-built-in.png)

### 易失性访问

大多数嵌入式开发人员都会熟悉 `C/C++` 中的 `volatile` 关键字。它告诉编译器该变量的值可能随时更改，这对于指向在硬件中 **内存映射外设寄存器(memory-mapped peripheral registers)** 的指针来说也是如此。这很重要，这样编译器就不会执行不正确的优化（有关 `C/C++` 易失性关键字的更多信息，请参阅 **[嵌入式系统和volatile关键字](https://blog.mbedded.ninja/programming/languages/c/embedded-systems-and-the-volatile-keyword/)** ）。

`Rust` 提供了两个方法 `core::ptr::write_volatile()` 和 `core::ptr::read_volatile()` 来告诉编译器同样的事情。 `write_volatile()` 接受 `*mut T` 类型的变量，`read_volatile()` 接受 `*const T` 类型的变量。

## Rust 架构支持

当考虑将 `Rust` 用于嵌入式项目时，你会想知道“Rust 支持我使用的微控制器吗？”。由于市场上有如此多的制造商和 `MCU` 系列（以及一些不同的架构），这完全取决于你所使用的产品。我们将在下面介绍一些流行架构和 `MCU` 系列的 `Rust` 支持级别。

通常通过运行 `rustup` 添加对特定架构的支持（默认情况下 `rustup` 仅安装适用于你的主机平台的标准库[^7]）：

```shell
$ rustup target add <architecture>
```

这将设置用于交叉编译到你选择的架构的构建环境。有关受支持平台的完整列表，请参阅 **[rustc手册：平台支持](https://doc.rust-lang.org/nightly/rustc/platform-support.html)**。

让我们更详细地了解当今嵌入式领域使用的主要架构的 `Rust` 支持。

### Cortex-M (ARM)

`Rust` 很好地支持了 `ARM Cortex-M CPU` 架构，因此许多使用 `Cortex-M` 的 `MCU` 系列自然也得到了很好的支持。 **[rust-embedded/cortex-m](https://github.com/rust-embedded/cortex-m)** 库为 `Cortex-M` 家族系列提供了最少的启动代码和运行时（包括半主机）。

**Rust 支持的 ARM Cortex-Mx 编译目标列表表[^7] [^8] [^9]：**

ISA | rustup Target
--- | ---
ARMv6-M (Cortex-M0, M0+, M1) | thumbv6m-none-eabi
Armv7-M (Cortex-M3)	 | thumbv7m-none-eabi
Armv7E-M (Cortex-M4, M7 -- no floating-point-support) | thumbv7em-none-eabi
Armv7E-M (Cortex-M4F, M7F -- floating-point-support) | thumbv7em-none-eabihf

你可以使用以下命令快速启动 Cortex-M CPU 的新项目：

```shell
cargo generate --git https://github.com/rust-embedded/cortex-m-quickstart
```

![通过运行上面命令创建的Cortex-M快速启动项目](https://static.cyub.vip/images/202310/cargo-cortex-m-quickstart-project-files.png)

**[alloc-cortex-m](https://github.com/rust-embedded/alloc-cortex-m)** 为基于 `Cortex-M` 的微控制器提供堆分配器。下面的代码示例显示了如何将此分配器设置为全局分配器（以便 Vec 等标准集合工作）并在固件应用程序中使用[^11]：

```rust
#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

extern crate alloc;

use alloc::vec::Vec;
use alloc_cortex_m::CortexMHeap;
use core::alloc::Layout;
use core::panic::PanicInfo;
use cortex_m_rt::entry;

#[global_allocator]
static ALLOCATOR: CortexMHeap = CortexMHeap::empty();

#[entry]
fn main() -> ! {
    // Initialize the allocator BEFORE you use it
    {
        use core::mem::MaybeUninit;
        const HEAP_SIZE: usize = 1024;
        static mut HEAP: [MaybeUninit<u8>; HEAP_SIZE] = [MaybeUninit::uninit(); HEAP_SIZE];
        unsafe { ALLOCATOR.init(HEAP.as_ptr() as usize, HEAP_SIZE) }
    }

    let mut xs = Vec::new();
    xs.push(1);

    loop { /* .. */ }
}

#[alloc_error_handler]
fn oom(_: Layout) -> ! {
    loop {}
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}
```

### RISC-V

`Rust` 对 `RISC-V` 架构的支持相当好。以下是支持架构：

ISA | rustup Target
--- | ---
RV32I ISA	| riscv32i-unknown-none-elf
RV32IMAC ISA | riscv32imac-unknown-none-elf
RV32IMC ISA	 | riscv32imc-unknown-none-elf
RV64IMAFDC ISA	| riscv64gc-unknown-none-elf
RV64IMAC ISA | riscv64imac-unknown-none-elf

**[riscv_rt](https://docs.rs/riscv-rt/latest/riscv_rt/)** 库 为 `RISC-V` `CPU` 提供基本的启动/运行时。

![riscv_rt(RISC-V运行时)库](https://static.cyub.vip/images/202310/riscv-rt-crate-docs-screenshot.png)

### Xtensa

`Xtensa` 架构仅在 `ESP32` 系列 `MCU` 中占主导地位，因此我们将在下面的 ESP32（Espressif Systems）部分中介绍该架构。

## Rust MCU家族支持

我们已经介绍了 `CPU` 架构（它定义了指令集），但是对围绕它并构成 `MCU` 的所有外设的支持又如何呢？让我们介绍一下一些流行制造商及其 `MCU` 系列对 `Rust` 的支持程度。

### STM32（意法半导体）

`STM32` 系列微控制器拥有所有微控制器中最丰富的 `Rust` 支持。 **[stm32-rs/stm32-rs](https://github.com/stm32-rs/stm32-rs)** 库包含适用于多种 `STM32` 微控制器的 Rust PAC 工具包。截至 2022 年 11 月，它得到积极维护，拥有 824 颗星。

![stm32-rs库](https://static.cyub.vip/images/202310/stm32-rs-repo-readme-screenshot.png)

### Atmel AVR

https://github.com/Rahix/avr-hal 是适用于 `ATmega AVR`（包括 `Arduino`、`ATmega`、`ATtiny`）的流行第三方 `Rust HAL` 层。

`ravedude` 是一个有用的 `cargo` 应用程序，它增加了对 `cargo` 运行的支持以对 `Arduino` 板进行编程，然后连接串行以显示任何打印消息。

```shell
cargo +stable install ravedude
```

![cargo使用Rahix/avr-hal-template库生成Arduino板的Rust项目](https://static.cyub.vip/images/202310/using-cargo-generate-for-arduino-uno.png)

在 https://blog.logrocket.com/complete-guide-running-rust-arduino/ 上有一个关于让 `Rust` 在 `Arduino Uno`（使用 `ATmega328P` 微控制器）上工作的很棒的教程。在 `WSL` 中开发时（使用 `usbip` 连接 `Arduino USB` 设备），使用该教程构建一个点亮LED的 `Rust` 项目大约需要 5 分钟。

![用Rust编写的Arduino应用程序的屏幕截图（点亮LED并向控制台打印“Hello”）](https://static.cyub.vip/images/202310/screenshot-of-basic-arduino-app-in-rust.png)

### Atmel SAM

**[atsamd-rs/atsamd](https://github.com/atsamd-rs/atsamd)** 库提供了各种 `crate`，用于使用 **Rust[^12]** 处理基于 Atmel `samd11`、`samd21`、`samd51` 和 `same5x` 的设备。该库提供 `PAC（外围访问包）` 和更高级别的 `HAL（硬件抽象层）`。 `HAL` 实现由 `embedded-hal` 项目指定的特征。此库中还包含许多开发板的 `BSP（Board Support Packages，中文为板支持包）`。它们按照第 1 层(Tier 1)和第 2 层(Tier 2) 进行区分，第 1 层 `BSP` 是那些与最新版本的 `atsamd-hal` 保持同步的 `BSP`，而第 2 层 `BSP` 则不然（它们可能被锁定到某个过去的版本） ）。

![atsamd-rs/atsamd库](https://static.cyub.vip/images/202310/atsamd-rs-atsamd-repo-screenshot.png)

截至 2022 年 11 月，该存储库看起来很活跃，有 705 次提交和 421 颗星。

### MSP430（德州仪器）

**[japaric/msp430-rtfm](https://github.com/japaric/msp430-rtfm)** 上有一个可用于 `MSP430 MCU` 的 `RTFM`（Real-Time For the Masses，RTIC 的旧名称）版本，维护得不太好。

### ESP32（乐鑫系统）

`Rust` 编译器有一个分支（**[esp-rs/rust](https://github.com/esp-rs/rust)**），它添加了对 `Xtensa` 指令集（例如 `ESP32S3`）的支持。如果 `Xtensa` 上游支持其架构进入 `LLVM`，那么将来可能不需要这个分支。同一个 `esp-rs` 组织还在 `GitHub` 上的 **[esp-rs/esp-hal](https://github.com/esp-rs/esp-hal)** 提供了 `no_std HAL`，并在 **[esp-rs/esp-idf-hal](https://github.com/esp-rs/esp-idf-hal)** 提供了 `std` 支持。

**[esp-rs/esp-idf-svc](https://github.com/esp-rs/esp-idf-svc)** 为各种 `ESP-IDF` 服务（例如 `WiFi`、网络和日志记录）提供 `Rust` 包装器。这定义了 **[esp-rs/embedded-svc](https://github.com/esp-rs/embedded-svc)** 中定义的特征的实现（将其视为基本 **[embedded-hal](https://github.com/rust-embedded/embedded-hal)** 特征的扩展）。

`esp-rs` 组织还提供了自己的安装程序 `espup`，即“rustup for esp-rs”。它是一个工具（`rustup` 的替代品），用于安装和维护在 `Espressif` 设备上使用 `Rust` 进行开发所需的工具链。

### Nordic nRF

**[nrf-rs/nrf-hal](https://github.com/nrf-rs/nrf-hal)** 库为 `nRF51`、`nRF52` 和 `nRF91` 系列微控制器提供 `Rust HAL`[^13]。
默认的嵌入式 Rust 教程现在使用 `micro:bit v2`（它曾经使用 `STM32F303 Discovery Kit`），它恰好有一个板载 `nRF52 MCU`。

### SiFive

`rustup` 目标 `riscv32imac-unknown-none-elf` 可用于 `Freedom E310`（例如 `HiFive1`）的交叉编译。我找不到对 `HiFive1 Rev B` 引导加载程序的任何支持，因此需要专门的程序员来对电路板进行编程。

### RP2040

`RP2040` 只是一个芯片而不是一个“系列”，但是你可以购买许多基于该 `IC` 的板。 **[rp-rs/rp-hal](https://github.com/rp-rs/rp-hal)** 库提供了高质量的 `RP2040`。该仓库被组织为 Cargo Workspace，其中还包括许多用于使用该芯片的开发板的板支持crate，包括 `Raspberry Pi Pico`、`Adafruit Feather RP2040`、`Adafruit ItsyBitsy RP2040`、`Pimoroni Pico Explorer`、`SolderParty RP2040 Stamp`、`Sparkfun Pro Micro RP2040`、`Sparkfun Thing Plus RP2040` 和 `Seeeduino XIAO RP204014`[^14]。

![rp-rs/rp-hal库](https://static.cyub.vip/images/202310/rp-hal-rust-support-for-the-rp2040-readme-screenshot.png)

### 其他

- PSoC：**[psoc-rs GutHub 组织](https://github.com/psoc-rs)** 有 `PSoC 6` 的 `PAC` 和 `HAL` 库，但它们看起来维护或使用得不好。
- PIC：GitHub 存储库 **[kiffie/pic32-rs](https://github.com/kiffie/pic32-rs)** 包含 `PIC32` 的 `HAL`。看起来有些维护。

#### Rust IDE、编程和调试经验

嵌入式开发必须具备一个流畅的 `编写代码` -> `构建` -> `编程` ->`调试` 的工作流程。理想情况下，这不需要供应商锁定（即被迫使用供应商特定的 IDE），并且可以在代码编辑器中（而不仅仅是在命令行上）进行逐步调试。幸运的是 `Rust` 可以提供这一切！我专注于使用 `VS Code`，因为它是当今最流行的非特定于供应商的 `IDE`。 `VS Code` 对 `Rust` 和嵌入式开发有很好的支持。 `Cortex-Debug` 和 `rust-analyzer` 是你肯定想要安装的两个 `VS Code` 扩展。

我可以使用 `STM32F303 Discovery Kit`（带有 `STM32F303 MCU` 的开发板），因此我进行了一些搜索并找到了 **[rubberduck203/stm32f3-discovery](https://github.com/rubberduck203/stm32f3-discovery)**。其中包含预制的 `VS Code` 启动配置，因此我应该能够直接从 `VS Code` 中调试 `Rust` 代码。通过一些调整（包括将`"cortex-debug.gdbPath"："gdb-multiarch"`添加到`settings.json`），我能够启动并运行工作流程！

我所需要做的就是按 `F5` – 这会构建代码，并将其烧录到 `STM32F303` 设备。下面是我单步执行 "Blinky" 示例时的图像。我使用 `VS Code` 通过 `WSL` 连接到 `Ubuntu`（使用 `usbip` 连接 `STM32F303 USB` 设备）。

![在 VS Code 中逐步调试 STM32F303 Discovery Kit 的"Blinky"程序。我从 https://github.com/rubberduck203/stm32f3-discovery 的存储库开始，经过一些调整，它已经启动并运行了](https://static.cyub.vip/images/202310/stm32-discovery-blinky-debugging-in-vs-code.png)

**[Knurling](https://github.com/knurling-rs/)** 是 `Ferrous Systems` 的项目集合（他们的两个流行工具包括 `probe-run` 和 `defmt`）。
通过 `cortex-m` crate 为 `Cortex-M` MCU 提供半主机。半主机允许你通过附加的调试器将调试消息记录到主机，无需额外的电缆（例如 `USB` 到 `UART` 设备）。缺点是速度慢。一条消息可能需要很多毫秒，具体取决于你正在使用的附加调试器。 `Panic-semihosting` crate 还可用于在主机上提供有用的恐慌消息。 `ITM` 是比半主机更快的选项，但仅适用于 `Cortex-M3` 及更高版本。 `RTT` 可能是一个更好的选择（在大多数目标/程序员上可用，如半主机，但速度像 `ITM` 一样快）[^15]。它主要与平台无关，仅依赖于支持后台目标内存访问的调试探针。启用后，你可以使用 `rprintln!()` 宏。我还没有使用过这个，所以不能发表太多评论！

## Rust实时操作系统

如果没有可供选择的 `RTOS`，任何语言都不能声称适合嵌入式编程。幸运的是，`Rust` 有一些，从现有 `C/C++ RTOS`（例如 `FreeRTOS` 和 `RIOT`）的 `Rust` 包装器到从头开始构建的在 `Rust` 上运行的 `RTOS`（例如 `RTIC`、`Embassy` 和 `Tock`）。让我们回顾一下 `Rust` 开发人员可用的一些流行 `RTOS`。

### FreeRTOS 包装器

- **[hashmismatch/freertos.rs](https://github.com/hashmismatch/freertos.rs)**：不幸的是，这个库看起来多年来没有任何积极的开发。
- **[lobaro/FreeRTOS-rust](https://github.com/lobaro/FreeRTOS-rust)**：积极寻求改进 `hashmismatch/freertos.rs` 并简化 `Rust` 中 `FreeRTOS` 的使用。

### RTIC

`RTIC`（Real-Time Interrupt-driven Concurrency）是一种有趣的 `RTOS` 方法，似乎拥有相当多的积极开发和社区支持。所有任务共享一个调用堆栈，并在编译时保证无死锁执行。下面是 `RTIC` 的一些特点：

项 | 值
--- | ---
调度机制 | 基于中断的优先抢占(Interrupt-based preemptive with priority)
仓库星星数 | 1k
仓库提交数 | 1.1k

![RITC项目主页](https://static.cyub.vip/images/202310/rtic-documentation-screenshot.png)

### Embassy

`Embassy` 主要支持协作多任务处理而不是抢占式调度。但是，它确实允许你创建具有不同优先级的多个执行程序，因此你可以在需要时获得抢占。它利用了 `Rust` 的 `async/await`。调度程序在单个堆栈上运行所有任务。它还提供了一套库，例如用于 `IP` 网络的 `embassy-net`、用于 LoRa 网络的 `embassy-lora`、用于 USB 设备的 `embassy-usb` 以及用于引导加载程序的 `embassy-boot`。下面是 `Embassy` 是一些特点：

项 | 值
--- |---
调度机制 | 协作式（Co-operative）
仓库星星数 | 1.2k
仓库提交数 | 3.4k

### Tock

![Tock logo](https://static.cyub.vip/images/202310/tock-os-logo.png)

> `Tock` 是一款嵌入式操作系统，设计用于在基于 `Cortex-M` 和 `RISC-V` 的嵌入式平台上运行多个并发、互不信任的应用程序。

下面是 `Tock` 的一些特点：

项 | 值
--- | ---
调度机制 | 抢占式(Preemptive)
仓库星星数 | 4k
仓库提交数 | 11k

![Tock RTOS 架构图](https://static.cyub.vip/images/202310/tock-architecture-diagram.png)

`Tock` 的某些功能并未完全融入 `Rust`，例如你必须突破 `Rust` 生态系统并调用 `make` 将内核编程到你的主板上。一旦内核被编程到你的主板上，你就可以使用他们自己的 `tockloader` 程序来刷新应用程序代码。

### Drone

**[Drone](https://www.drone-os.com/)** 是一个基于中断的抢占式 `RTOS`，采用 `Rust` 构建，适用于嵌入式设备。下面是 `Drone` 的一些特点：

项 | 值
--- | ---
调度机制 | Interrupt-based pre-emptive with priority
仓库星星数 | 361
仓库提交数 | 251

## Rust 速度和内存使用情况

`Rust` 构建的应用程序的速度和内存使用情况与 `C/C++` 相比如何？首先值得一提的是，`Rust` 的大多数独特的所有权/借用检查纯粹是编译时构造，并且在速度和内存使用方面都产生零运行时开销。

正如 `Rust` 语言特性部分中提到的，`Rust` 在访问数组时会自动进行边界检查。最好在编译时执行此操作，但在某些情况下无法执行此操作（例如，将对数组的引用传递给函数），并且必须在运行时执行此操作。开销很小，并且在 99% 的用例中可能都是值得的。如果你确实想避免边界检查，你可以：

- 使用迭代器（如果适用）
- 使用 `get_unchecked()`

当编译时没有使用 `--release` 选项时，`Rust` 也会在进行加法和乘法等数学运算时执行溢出检查。如果我们使用 `Godbolt Compiler Explorer` 并比较 `C++` 和 `Rust` 中简单 `square()` 函数的汇编输出，我们可以看到这一点：

![C++ 和 Rust 的 square() 汇编输出的差异](https://static.cyub.vip/images/202310/comparison-of-the-square-function-in-cpp-and-rust.png)

你可以在 `Rust` 窗格中看到它有一些额外的指令，包括 `seto` 读取溢出标志，然后进行 `test` 并跳转到 `panic!` 在发生溢出的情况下。这会减慢数学运算的速度，但在大多数情况下，为了捕获溢出错误，这是值得的权衡。请记住如果你使用 `--release` 选项构建，开销就会消失。

**提示：** 如果你希望在 `--release` 版本中进行溢出检查，则可以使用 `checked_xxx` 函数，例如 `checked_add()`，如果值溢出，它会返回一个为 `None` 的 `Option<T>` 。

尽管溢出可能很糟糕，但在许多用例中（尤其是在嵌入式编程中）你需要（甚至依赖）溢出包装。一个典型的示例是获取当前系统刻度值并减去保存的先前系统刻度值来计算持续时间。你的系统记号可能存储在 32 位无符号整数中，并计算自启动以来的毫秒数。在连续运行 1193 小时多一点的时间里，这将回到 0。然而，由于整数数学实现方式的性质，当当前系统滴答回零时，依赖于减法的持续时间仍然可以正常工作，只要没有一个持续时间跨越总系统滴答周期的一半以上（大约 597小时）。在 `Rust` 中，你可以使用 `wrapping_xxx` 函数（例如 `wrapping_add()`）安全地执行溢出方程。

**[gccrs](https://rust-gcc.github.io/)** 是一个将 Rust“前端(front-end)”合并到 `GCC` 中的项目。截至 2022 年 12 月，这仍然是 `WIP（进行中）`。最终目标是使 `GCC` 能够编译 `Rust` 代码。这样做的主要好处是：
- 我们可以受益于 `GCC` 非常好的优化（这与 `LLVM` 不同）
- 我们还有另一个 `Rust` 编译器可供选择（这通常是一件好事！）


> 由于这是一个前端项目，编译器将获得对 `GCC` 的所有内部中端优化通道的完全访问权限，这与 LLVM 不同。 – GCC Front-End For Rust[^17]


https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/rust-gpp.html 有一些关于 `Rust` 与 `C++` 的有趣基准测试。 `Rust` 在 4 个基准测试中明显更快，`C++` 在其中 3 个基准测试中明显更快，而对于其余 3 个基准测试，它们基本相同。

## 使用 Rust 的缺点

如果不提及负面因素，任何评论都是不公平的。使用 `Rust` 进行嵌入式固件有哪些缺点？

- **不像C/C++那样得到很好的支持**：`C/C++` 肯定受到许多微控制器供应商和 `IDE` 的更好支持，并且 `C/C++` 的嵌入式库比 `Rust` 多得多（库的成熟度）。但如上所示，`Rust` 对许多顶级微控制器系列的支持相当好，并且希望随着该语言的成熟，它会继续变得更好。
- **Rust的学习曲线很陡**：如果你熟悉 `C/C++` 等编译语言以及 `Javascript` 和 `Python` 等一些解释型高级语言，你可能会发现学习新语言非常容易。然而，Rust 的工作方式有一些显着的核心差异（与大多数其他流行语言相比，它的借用检查器/所有权概念很新颖），因此仍然很难学习。有一句众所周知的说法，在学习 `Rust` 时，你将“与借用检查器搏斗”。

- **找到Rust开发人员将会更加困难**：同样，由于 `Rust` 与其他语言相比相对不成熟，如果你运营着大型团队，通常会更难找到有能力的开发人员。
- **不如C/C++代码优化得好**：尽管如此，编译后的 `Rust` 代码将会很快，并且在 99% 的用例中可能足够快。在某些特定用例中，`C/C++` 代码可能会击败 `Rust`。随着时间的推移，`Rust` 的速度可能会变得更好，像 **[GCC Front-End For Rust](https://blog.mbedded.ninja/programming/languages/rust/running-rust-on-microcontrollers/)** 这样的项目将有助于这一过程。


## 进一步阅读


请务必查看 **[Matrix'Rust Embedded](https://app.element.io/#/room/#rust-embedded:matrix.org)** 聊天室。

`GitHub` 存储库 **[rust-embedded/awesome-embedded-rust](https://github.com/rust-embedded/awesome-embedded-rust)** 是由 `Rust` 资源团队维护的大量嵌入式 `Rust` 资源列表。它包括工具、RTOS、外设访问包 (PAC)、硬件抽象层 (HAL)、板级支持包 (BSP)、博客、书籍和其他培训材料。

你可以使用在线编辑器/编译器（例如 `Replit`）来尝试 `Rust`。或者，如果你更喜欢在本地运行某些内容，请安装 `cargo`，然后使用 `cargo new hello_world --bin` 初始化一个新项目（这将用于在你的计算机上运行，而不是在微控制器上运行）。


## 引用

[^1]: Wikipedia (2022, Nov 11). Rust (programming language). Retrieved 2022-11-19, from https://en.wikipedia.org/wiki/Rust_(programming_language)
[^2]: Rust Embedded. Embedded Devices Working Group (repository). GitHub. Retrieved 2022-11-12, from https://github.com/rust-embedded/wg
[^3]: Rust Embedded. The Embedded Rust Book. Retrieved 2022-11-14, from https://docs.rust-embedded.org/book/
[^4]: vd2rust. Crate svd2rust (documentation). Retrieved 2022-11-14, from https://docs.rs/svd2rust/latest/svd2rust/
[^5]: Embedded HAL. Module embedded_hal::serial (documentation). Retrieved 2022-12-05, from https://docs.rs/embedded-hal/latest/embedded_hal/serial/
[^6]:Rust Language Docs. Macro std::line. Retrieved 2022-11-29, from https://doc.rust-lang.org/std/macro.line.html
[^7]: rust-lang. The rustup book: Cross-compilation. Retrieved 2022-11-14, from https://rust-lang.github.io/rustup/cross-compilation.html
[^8]: rust-lang. The rustc book: Platform Support. Retrieved 2022-11-15, from https://doc.rust-lang.org/nightly/rustc/platform-support.html
[^9]: ARM Developer. Processors: Cortex-M3. Retrieved 2022-11-15, from https://developer.arm.com/Processors/Cortex-M3
[^10]: ARM Developer. Processors: Cortex-M4. Retrieved 2022-11-15, from https://developer.arm.com/Processors/Cortex-M4
[^11]: Rust Embedded. alloc-cortex-m - A heap allocator for Cortex-M processors (repository). Retrieved 2022-11-30, from https://github.com/rust-embedded/alloc-cortex-m
[^12]: atsamd-rs. atsamd & atsame support for Rust (Git repository). Retrieved 2022-11-21, from https://github.com/atsamd-rs/atsamd
[^13]: nrf-rs. nrf-hal (Git repository). Retrieved 2022-11-14, from https://github.com/nrf-rs/nrf-hal
[^14]: rp-rs GitHub Organization. Rust support for the “Raspberry Silicon” family of microcontrollers. Retrieved 2022-11-28, from https://github.com/rp-rs/rp-hal
[^15]: rust-embedded/book. Discourage use of semihosting and mention viable alternatives #257 (GitHub issue). Retrieved 2022-12-05, from https://github.com/rust-embedded/book/issues/257
[^17]: rust-gcc. GCC Front-End For Rust - Homepage. Retrieved 2022-12-11, from https://rust-gcc.github.io/.