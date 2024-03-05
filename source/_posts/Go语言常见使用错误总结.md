title: Go语言常见使用错误总结
author: tink
tags:
  - 易错点
categories:
  - Golang
date: 2024-03-05 21:42:00
---
在学习和使用 Go 语言的过程中，我们不可避免地会遇到一些陷阱和常见的使用错误。这些建议性错误或潜在的问题，有时可能会在代码中悄悄滋生，直到某一天给你带来难以察觉的 bug。为了帮助大家更好地理解和规避这些陷阱，我整理了一些 Go 语言中常见的使用错误，这些建议或许能成为你编写更健壮、可维护代码的助力。

本篇博客旨在提醒读者注意一些在 Go 语言中易犯的错误，不仅包括语法和语义级别的问题，还包括一些最佳实践和规范。通过深入理解这些错误，我们可以更好地规避潜在的风险，写出更高效、更稳定的 Go 代码。

在我们开始探索这些错误之前，让我们一同回顾一下“在错误中学习，不断成长”的理念。编程世界中，错误不是失败的代名词，而是成长的机会。当我们深入了解常见错误时，我们更能够逐步提升自己的编程技能，写出更加健壮的代码。

愿这篇博客能够帮助你更好地使用 Go 语言，避免一些不必要的困扰。让我们开始我们的探索之旅，一同领略 Go 语言的优雅之美，并在编程的路上越走越远。

Happy coding! 🚀

## 切片相关

### 对切片并发地进行append操作

append操作是并发不安全的，在使用过程中，需要特别注意。下面代码中是有问题的：

```go
func append_to_slice(s []int, i int) {
	append(s, i)
}

var slices = []int{1,2, 3}
go append_to_slice(slices, 4)
go append_to_slice(slices, 5)
```

解决办法之一是我们可以使用sync.Mutex进行加锁处理。

<!--more-->

### copy切片时候未设置目标切片长度

使用内置copy函数进行切片复制时候，目标切片长度需要设置为要复制的数量。下面代码是有问题的，即使设置了dist容量，但由于dist长度是0，最终没有任何src数据会复制到dist中。

```go
var src = []int{1, 2, 3}
var dist = make([]int, 0, len(src))
copy(dist, src)
```

修复后版本：

```go
var src = []int{1, 2, 3}
var dist = make([]int, len(src))
copy(dist, src)
```

### 切片作为参数传递或者返回值返回时候

切片包含了指向底层数据的指针，是一种“引用类型”数据。在使用切片作为函数或方法参数传递过程中，需要注意函数内部如果修改了该切片，可能导致函数外部使用时候会造成问题。

我们可以看下这个例子：

```c
func myfunc(nums []int) {
	for idx := range nums {
		nums[idx] += 100
	}
}

func main() {
	nums := []int{1, 2, 3}
	myfunc(nums)
	fmt.Println(nums[0] == 1)   // 输出false
	fmt.Println(nums[0] == 101) // 输出true
}
```

解决办法使用copy函数复制一份：

```go
func myfunc(nums []int) {
	for idx := range nums {
		nums[idx] += 100
	}
}

func main() {
	nums := []int{1, 2, 3}
	numscopy := make([]int, len(nums)) // 复制一份nums
	copy(numscopy, nums)
	myfunc(numscopy)
	fmt.Println(nums[0] == 1)   // 输出true
	fmt.Println(nums[0] == 101) // 输出false
}
```
