title: Golang设计模式系列之简单工厂模式
author: tinker
tags:
  - 设计模式
categories:
  - Golang设计模式系列
date: 2020-06-22 23:08:00
---
## 定义

简单工厂模式是一种创建型设计模式，一般又称为静态工厂方法（Static Factory Method）模式。这种模式通过一个静态方法或者函数来达到隐藏正在创建的实例的创建逻辑目的

客户端仅与工厂方法交互，并告知需要创建的实例类型。工厂方法与相应的具体产品进行交互，并返回正确的产品实例。

<!--more-->

## 示例

考虑下面的例子，我们想要购买一只枪

- **iGun**接口定义了枪所有的方法
- 枪的具体产品**ak47**和**maverick**实现了**iGun**接口
- **getGun**方法用来创建**ak47**或者**maverick**具体产品
- main.go充当客户端，而不是直接与**ak47**或者**maverick**的交互，它依靠gunFactory.go创建**ak47**和**maverick**的实例

**UML图**

![](https://static.cyub.vip/images/202006/static_factory_method.jpg)

类与代码映射关系


类 | 代码
---|---
ProductFactory | getGun
IProduct | iGun
Concrete Production | ak47, maverick
Client | main.go |

### 实现

**iGun**
---

```go
type iGun interface {
    setName(name string)
    setPower(power int)
    getName() string
    getPower() int
}
```

**ak47**
---

```go
type gun struct {
    name  string
    power int
}

func (g *gun) setName(name string) {
    g.name = name
}

func (g *gun) getName() string {
    return g.name
}

func (g *gun) setPower(power int) {
    g.power = power
}

func (g *gun) getPower() int {
    return g.power
}

type ak47 struct {
    gun
}

func newAk47() iGun {
    return &ak47{
        gun: gun{
            name:  "AK47 gun",
            power: 4,
        },
    }
}
```

**maverick**
---

```go
type maverick struct {
    gun
}

func newMaverick() iGun {
    return &maverick{
        gun: gun{
            name:  "Maverick gun",
            power: 5,
        },
    }
}
```

**getGun**
---

```go
func getGun(gunType string) (iGun, error) {
    if gunType == "ak47" {
        return newAk47(), nil
    }
    if gunType == "maverick" {
        return newMaverick(), nil
    }
    return nil, fmt.Errorf("Wrong gun type passed")
}
```

**main.go**
---

```go
func main() {
    ak47, _ := getGun("ak47")
    maverick, _ := getGun("maverick")
    printDetails(ak47)
    printDetails(maverick)
}

func printDetails(g iGun) {
    fmt.Printf("Gun: %s", g.getName())
    fmt.Println()
    fmt.Printf("Power: %d", g.getPower())
    fmt.Println()
}
```

### 开源源码分析

[docker/distribution](https://github.com/docker/distribution/tree/v2.7.1)项目用于创建docker镜像仓库。其中镜像信息支持存储到aws-s3,azure,filesystem等多个存储后端，每个存储后端驱动都实现了[StorageDriver](https://github.com/docker/distribution/blob/2461543d988979529609e8cb6fca9ca190dc48da/registry/storage/driver/storagedriver.go#L41)接口：

```go
type StorageDriver interface {
	Name() string

	GetContent(ctx context.Context, path string) ([]byte, error)

	PutContent(ctx context.Context, path string, content []byte) error

	Stat(ctx context.Context, path string) (FileInfo, error)

	List(ctx context.Context, path string) ([]string, error)
	...
}
```


distribution同时还实现了[简单工厂模式](https://github.com/docker/distribution/blob/v2.7.1/registry/storage/driver/factory/factory.go)来创建不同的存储驱动器。

```go
// 从存储驱动器名称到具体存储驱动器工厂的映射
var driverFactories = make(map[string]StorageDriverFactory)

// 抽象存储器工厂
type StorageDriverFactory interface {
	Create(parameters map[string]interface{}) (storagedriver.StorageDriver, error)
}

// 外部接口，支持注册具体存储驱动器工厂
func Register(name string, factory StorageDriverFactory) {
    ...
	driverFactories[name] = factory
    ...
}

// 简单工厂模式，支持根据名字返回对应的具体存储驱动器工厂，并创建存储驱动器
func Create(name string, parameters map[string]interface{}) (storagedriver.StorageDriver, error) {
	...
	return driverFactory.Create(parameters)
    ...
}
```

以[本地文件系统驱动器](https://github.com/docker/distribution/blob/2461543d988979529609e8cb6fca9ca190dc48da/registry/storage/driver/filesystem/driver.go#L42)为例：

```go
...
// filesystem存储驱动器工厂
type filesystemDriverFactory struct{}

func (factory *filesystemDriverFactory) Create(parameters map[string]interface{}) (storagedriver.StorageDriver, error) {
	return FromParameters(parameters)
}

func FromParameters(parameters map[string]interface{}) (*Driver, error) {
	...
	return New(*params), nil
    ...
}

func New(params DriverParameters) *Driver {
	...
	fsDriver := &driver{rootDirectory: params.RootDirectory}
    ...
}

// filesystem存储驱动器
type driver struct {
	rootDirectory string
}


const driverName           = "filesystem"
func init() {
    // 将具体工厂注册到driverFactories映射中
	factory.Register(driverName, &filesystemDriverFactory{})
}
...
```

distribution通过简单工厂模式来创建docker镜像存储驱动器，其底层是通过工厂模式来创建驱动器。通过工厂模式解决了简单工厂存在的封闭开放问题，添加新驱动器时候，仅需要添加具体对象和对应的具体工厂。



## 总结

简单工厂模式优缺点：

优点：

- 实现了客户端与具体产品创建解耦，通过传入不同参数来实现不同的产品

缺点：

- 增加新的产品适合需要修改静态方法代码，不符合开闭原则

## 参考

- [示例来源](https://golangbyexample.com/golang-factory-design-pattern/)