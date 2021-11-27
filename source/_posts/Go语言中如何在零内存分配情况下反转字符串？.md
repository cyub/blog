title: Go语言中如何在零内存分配情况下反转字符串？
author: tinker
tags: []
categories:
  - Golang
date: 2021-11-27 02:33:00
---
一日午饭后散步中，同事问了一道Go相关的测试题目，是他之前面试中面试官问的一个题目，他到现在还没有找到答案。这道测试题就是本篇博文的标题：Go语言中如何在零内存分配情况下反转字符串？

<!--more-->

Go语言中反转字符串很好处理。我们只需要将使用`[]byte(string)`强制将字符串转换成字节切片，然后将该字节切片中第一个字节和最后一个字节对调，第二个字节和倒数第二个字节对调，依次类推，完成整个字节切片反转后，再将字节切片转换成字符串就行了。整个反转操作的时间复杂度是O(n)。需要注意的是对于包含中文等多字节文本的字符串需要转换成`[]rune`类型。为了减少处理起来的复杂性，本博文就只考虑英文字符串的反转了。相关代码如下：

```go
func main() {
	str := "hello,world"
	bytes := reverse([]byte(str))
	println(string(bytes))
}

func reverse(s []byte) []byte {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
	return s
}
```

上面处理是完成了反转字符串的目标，但是string和[]byte或[]rune类型互转时候，会进行内存分配的。至于为啥进行了内存分配可以参见本人写的电子书《[深入Go语言之旅](https://go.cyub.vip/index.html)》中[[]byte(string) 和 string([]byte)为什么需要进行内存拷贝？](https://go.cyub.vip/type/slice.html#byte-string-string-byte)这一小节。本篇博文不再详述。

既然上面处理使用的[]byte(string)和 string([]byte)方法进行字符串和字节切片互转时候需要进行内存分配，那么有没有不进行内存分配的转换方法呢？

答案是有的。因为string和[]byte底层类型大致一样，我们可以通过非类型安全指针`unsafe.Pointer`进行指针类型转换，该方法是优化字符串和字节切片互转的常见手段。具体实现可以参考下面：

```go
func bytes2string(b []byte) string{
    return *(*string)(unsafe.Pointer(&b))
}

func string2bytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(
		&struct {
			string
			Cap int
		}{s, len(s)},
	))
}
```

再接着上面的反转字符串处理，我们使用无内存分配的方式试一下，[点击在线运行](https://goplay.tools/snippet/e_p7AvsWSdZ)：

```go
func main() {
	str := "hello,world"
	fmt.Println("原始字符串：", str)
	bytes := reverse(string2bytes(str))
	fmt.Println("反转字符串：", bytes2string(reverse(bytes)))
}

func reverse(s []byte) []byte {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
	return s
}

func bytes2string(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}

func string2bytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(
		&struct {
			string
			Cap int
		}{s, len(s)},
	))
}
```



运行上面代码我们可以看到类似下面的SEGV内存错误：

```
unexpected fault address 0x461f48
fatal error: fault
[signal SIGSEGV: segmentation violation code=0x2 addr=0x461f48 pc=0x454f97]
```

这是因为我们直接操作的是字符底层内容，而字符串底层内容存储在的进程内存布局的`.rodata`段(准确说应该是`data`段中`.rodata`节）中，该段是只读的。我们反转字符时候，会进行写入操作，故运行时会报出上面的段错误提示，这也是Go中字符串只读的原因。字符串的底层结构如下：

![](https://static.cyub.vip/images/202111/string_mem_layout.png)

一路下来貌似无法做到在零内存分配情况下反转字符串。其实只需要改变上面字符底层内容所在内存的权限，让它可写就行了。Linux中提供了[mprotect](https://man7.org/linux/man-pages/man2/mprotect.2.html)系统调用，可以用来更改进程内存页的读写权限。需要注意的`mprotect`操作的最小单位是内存页，传入的地址参数需要以页边界对齐。最后代码如下，[点击在线运行](https://goplay.tools/snippet/01K710xdn5o)。


```go
func main() {
	str := "hello,world"

	sh := *(*reflect.StringHeader)(unsafe.Pointer(&str))
	page := getPage(uintptr(unsafe.Pointer(sh.Data)))
	syscall.Mprotect(page, syscall.PROT_READ|syscall.PROT_WRITE) // 改变内存页的只读权限

	fmt.Println("原始字符串：", str)
	bytes := (*(*[0xFF]byte)(unsafe.Pointer(sh.Data)))[:len(str)]
	fmt.Println("反转字符串：", bytes2string(reverse(bytes)))
}

func reverse(s []byte) []byte {
	for i, j := 0, len(s)-1; i < j; i, j = i+1, j-1 {
		s[i], s[j] = s[j], s[i]
	}
	return s
}

func getPage(p uintptr) []byte {
	return (*(*[0xFFFFFF]byte)(unsafe.Pointer(p & ^uintptr(syscall.Getpagesize()-1))))[:syscall.Getpagesize()]
}

func bytes2string(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}

func string2bytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(
		&struct {
			string
			Cap int
		}{s, len(s)},
	))
}
```

至此任务完成。需要注意的是上面代码中使用到固定大小的数组，不是非常完美的解决方案。