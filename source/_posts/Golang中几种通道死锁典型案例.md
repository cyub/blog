title: Golang中几种通道死锁典型案例
author: tinker
tags:
  - Golang
  - 通道
categories: []
date: 2020-07-19 19:31:00
---
Golang中通道是进行数据同步一个重要手段，当主进程读取空通道，或者向没有协程读取的通道写入时候，都会发生死锁现象（编译时候提示fatal error: all goroutines are asleep - deadlock!）。下面列出几个常见死锁情况。

<!--more-->

## 对无缓冲通道先行写入

```
func main() {
	ch := make(chan int)
	ch <- 100
	fmt.Println(<-ch)
}
```

或者如下

```
func main() {
	ch := make(chan int)
	ch <- 100
	go func() {
		fmt.Println(<-ch)
	}()
}
```

以上两种情况都会发生死锁

解决办法：

1. 使用缓存通道

```
func main() {
	ch := make(chan int, 1)
	ch <- 100
	fmt.Println(<-ch)

}
```

2. 将通道写入放到协程中处理

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
	}()
	fmt.Println(<-ch)
}
```

## 通道未写入之前先行读取

```
func main() {
	ch := make(chan int)
	fmt.Println(<-ch)
	ch<-100
}
```

或者如下

```
func main() {
	ch := make(chan int)
	fmt.Println(<-ch)

	go func() {
		ch <- 100
	}()
}
```

以上两种情况都会发生死锁

### 读取次数多于写入次数

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
	}()
	for {
		fmt.Println(<-ch)
	}
}
```

或者

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
	}()

	fmt.Println(<-ch, <-ch)
}
```

或者

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
	}()

	for v := range ch {
		fmt.Println(v)
	}
}
```

以上几种情况都会发生死锁

注意下面例子情况：不会发生死锁，先输出100，通道关闭后，会一直输出0

```
go func() {
    ch <-100
    close(ch)
}()
for {
    fmt.Println(<-ch)
}
```

解决一直输出0可以：

1. 判断通道是否关闭：

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
		close(ch)
	}()
	for {
		input, open := <-ch
		if !open {
			break
		}
		fmt.Println(input)
	}
}
```
2. 使用for-range来获取通道数据。for-range会自动检测通道是否关闭

```
func main() {
	ch := make(chan int)
	go func() {
		ch <- 100
		close(ch)
	}()

	for input := range ch {
		fmt.Println(input)
	}
}
```

## 多通道写入和读取顺序不一致

```
func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go func() {
		ch1 <- 100
		ch2 <- 200
	}()

	fmt.Println(<-ch2, <-ch1)
}
```

或者

```
func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go func() {
		fmt.Println(<-ch2, <-ch1)

	}()

	ch1 <- 100
	ch2 <- 200
}
```