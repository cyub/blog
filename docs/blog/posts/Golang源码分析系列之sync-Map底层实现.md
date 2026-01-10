---
title: Golang源码分析系列之sync.Map底层实现
authors: 
  - Tinker
tags: 
  - Golang源码分析系列
  - 编程语言/Golang
categories:
  - 源码分析
date: 2021-02-28 12:58:00
---
Golang中`sync/map`提供了并发读写map功能。这里面分析的源码基于[go1.14.13](https://github.com/cyub/go-1.14.13/blob/master/src/sync/map.go)版本。

## sync.Map的结构

```go
type Map struct {
	mu Mutex // 排他锁，用于对dirty map操作时候加锁处理

	read atomic.Value // read map

	// dirty map。新增key时候，只写入dirty map中，需要使用mu
	dirty map[interface{}]*entry

	// 用来记录从read map中读取key时miss的次数
	misses int
}
```

<!-- more -->

sync.Map结构体中read字段是`atomic.Value`类型，底层是**readOnly结构体**：

```go
type readOnly struct {
	m       map[interface{}]*entry
	amended bool // 当amended为true时候，表示sync.Map中的key也存在dirty map中
}
```

read map和dirty map的value类型是*entry， entry结构体定义如下：
```go
// expunged用来标记从dirty map删除掉了
var expunged = unsafe.Pointer(new(interface{}))

type entry struct {
	// 如果p == nil 说明对应的entry已经被删除掉了， 且m.dirty == nil

	//  如果 p == expunged 说明对应的entry已经被删除了，但m.dirty != nil，且该entry不存在m.dirty中

	// 上述两种情况外，entry则是合法的值并且在m.read.m[key]中存在
	// 如果m.dirty != nil，entry也会在m.dirty[key]中

	// p指针指向sync.Map中key对应的Value
	p unsafe.Pointer // *interface{}
}
```

## 新增和更新操作

对Map的操作可以分为四类：
1. Add key-value 新增key-value
2. Update key-value 更新key对应的value值
3. Get Key-value 获取Key对应的Value值
4. Delete Key 删除key

我们来看看新增和更新操作：

```go
// Store用来新增和更新操作
func (m *Map) Store(key, value interface{}) {
	read, _ := m.read.Load().(readOnly)
	// 如果read map存在该key，且该key对应的value不是expunged时(准确的说key对应的value, value是*entry类型，entry的p字段指向不是expunged时)，
	// 则使用cas更新value，此操作是原子性的
	if e, ok := read.m[key]; ok && e.tryStore(&value) {
		return
	}

	m.mu.Lock() // 先加锁，然后重新读取一次read map，目的是防止dirty map升级到read map（并发Load操作时候），read map更改了。
	read, _ = m.read.Load().(readOnly)
	if e, ok := read.m[key]; ok { // 若read map存在此key，此时就是map的更新操作
		if e.unexpungeLocked() { // 将value由expunged更改成nil，
			// 若成功则表明dirty map中不存在此key，把key-value添加到dirty map中
			m.dirty[key] = e
		}
		e.storeLocked(&value) // 更改value。value是指针类型(*entry)，read map和dirty map的value都指向该值。
	} else if e, ok := m.dirty[key]; ok {// 若dirty map存在该key，则直接更改value
		e.storeLocked(&value)
	} else { // 若read map和dirty map中都不存在该key，其实就是map的新增key-value操作
		if !read.amended {// amended为true时表示sync.Map部分key存在dirty map中
			// dirtyLocked()做两件事情：
			// 1. 若dirty map等于nil，则初始化dirty map。
			// 2. 遍历read map，将read map中的key-value复制到dirty map中，从read map中复制的key-value时，value是nil或expunged的(因为nil和expunged是key删除了的）不进行复制。
			// 同时若value值为nil，则顺便更改成expunged（用来标记dirty map不包含此key)
			
			// 思考🤔：为啥dirtyLocked()要干事情2，即将read map的key-value复制到dirty map中？
			m.dirtyLocked()
			// 该新增key-value将添加dirty map中，所以将read map的amended设置为true。当amended为true时候，从sync.Map读取key时候，优先从read map中读取，若read map读取时候不到时候，会从dirty map中读取
			m.read.Store(readOnly{m: read.m, amended: true})
		}

		// 添加key-value到dirty map中
		m.dirty[key] = newEntry(value)
	}
	// 释放锁
	m.mu.Unlock()
}

func (e *entry) tryStore(i *interface{}) bool {
	for {
		p := atomic.LoadPointer(&e.p)
		if p == expunged {
			return false
		}
		if atomic.CompareAndSwapPointer(&e.p, p, unsafe.Pointer(i)) {
			return true
		}
	}
}

func (e *entry) unexpungeLocked() (wasExpunged bool) {
	return atomic.CompareAndSwapPointer(&e.p, expunged, nil)
}

func (e *entry) storeLocked(i *interface{}) {
	atomic.StorePointer(&e.p, unsafe.Pointer(i))
}

func (m *Map) dirtyLocked() {
	if m.dirty != nil {
		return
	}

	read, _ := m.read.Load().(readOnly)
	m.dirty = make(map[interface{}]*entry, len(read.m))
	for k, e := range read.m {
		if !e.tryExpungeLocked() {
			m.dirty[k] = e
		}
	}
}

func (e *entry) tryExpungeLocked() (isExpunged bool) {
	p := atomic.LoadPointer(&e.p)
	for p == nil {
		if atomic.CompareAndSwapPointer(&e.p, nil, expunged) {
			return true
		}
		p = atomic.LoadPointer(&e.p)
	}
	return p == expunged
}
```

## 获取Key-Value操作

接下来看看Map的Get操作：
```go
// Load方法用来获取key对应的value值，返回的ok表名key是否存在sync.Map中
func (m *Map) Load(key interface{}) (value interface{}, ok bool) {
	read, _ := m.read.Load().(readOnly)
	e, ok := read.m[key]
	if !ok && read.amended { // 若key不存在read map中，且dirty map包含sync.Map中key情况下
		m.mu.Lock() // 加锁
		read, _ = m.read.Load().(readOnly) // 再次从read map读取key
		e, ok = read.m[key]
		if !ok && read.amended {
            e, ok = m.dirty[key] // 从dirty map中读取key
            
			// missLocked() 首先将misses计数加1，misses用来表明read map读取key没有命中的次数。
			// 若misses次数多于dirty map中元素个数时候，则将dirty map升级为read map，dirty map设置为nil, amended置为false
			m.missLocked()
		}
		m.mu.Unlock()
	}
	if !ok { // read map 和 dirty map中都不存在该key
		return nil, false
	}
	// 加载value值
	return e.load()
}

func (e *entry) load() (value interface{}, ok bool) {
	p := atomic.LoadPointer(&e.p)
	if p == nil || p == expunged { // 若value值是nil或expunged，返回nil, false，表示key不存在
		return nil, false
	}
	return *(*interface{})(p), true
}

func (m *Map) missLocked() {
	m.misses++
	if m.misses < len(m.dirty) {
		return
	}
	
	// 新创建一个readOnly对象，其中amended为false, 并将m.dirty直接赋值给该对象的m字段，
	// 这也是上面思考中的dirtyLocked为什么要干事情2的原因，因为通过2操作之后，m.dirty已包含read map中的所有key，可以直接拿来创建readOnly。
	m.read.Store(readOnly{m: m.dirty})
	m.dirty = nil
	m.misses = 0
}
```

## 删除操作

在接着看看Map的删除操作：

```go
// Delete用于删除key
func (m *Map) Delete(key interface{}) {
	read, _ := m.read.Load().(readOnly)
	e, ok := read.m[key]
	if !ok && read.amended {
		m.mu.Lock()
		read, _ = m.read.Load().(readOnly)
		e, ok = read.m[key]
		// 若read map不存在该key，但dirty map中存在该key。则直接调用delete，删除dirty map中该key
		if !ok && read.amended {
			delete(m.dirty, key)
		}
		m.mu.Unlock()
	}
	if ok {
		e.delete()
	}
}

func (e *entry) delete() (hadValue bool) {
	for {
		p := atomic.LoadPointer(&e.p)
		if p == nil || p == expunged { // 若entry中p已经是nil或者expunged则直接返回
			return false
		}
		if atomic.CompareAndSwapPointer(&e.p, p, nil) { // 将entry中的p设置为nil
			return true
		}
	}
}
```



## 遍历操作

sync.Map还提供遍历key-value功能：
```go
// Range方法接受一个迭代回调函数，用来处理遍历的key和value
func (m *Map) Range(f func(key, value interface{}) bool) {
	read, _ := m.read.Load().(readOnly)
	if read.amended { // 若dirty map中包含sync.Map中key时候
		m.mu.Lock()
		read, _ = m.read.Load().(readOnly)
		if read.amended {// 加锁之后，再次判断，是为了防止并发调用Load方法时候，dirty map升级为read map时候，amended为false情况
			// read.amended为true的时候，m.dirty包含sync.Map中所有的key
			read = readOnly{m: m.dirty}
			m.read.Store(read)
			m.dirty = nil
			m.misses = 0
		}
		m.mu.Unlock()
	}

	for k, e := range read.m {
		v, ok := e.load()
		if !ok {
			continue
		}
		if !f(k, v) { //执行迭代回调函数，当返回false时候，停止迭代
			break
		}
	}
}
```

## 总结

- sync.Map是不能值传递的
- sync.Map采用空间换时间策略。其底层结构存在两个map，分别是read map和dirty map。当读取操作时候，优先从read map中读取，是不需要加锁的，若key不存在read map中时候，再从dirty map中读取，这个过程是加锁的。当新增key操作时候，只会将新增key添加到dirty map中，此操作是加锁的，但不会影响read map的读操作
- 当sync.Map读取key操作时候，若从read map中一直未读到，若dirty map中存在read map中不存在的keys时，则会把dirty map升级为read map，这个过程是加锁的。这样下次读取时候只需要考虑从read map读取，且读取过程是无锁的
- sync.Map中的dirty map要么是nil，要么包含read map中所有未删除的key-value
- sync.Map适用于读多写少场景