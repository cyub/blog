title: Golang设计模式系列之工厂方法模式
author: tinker
tags:
  - 设计模式
categories:
  - Golang设计模式系列
date: 2020-08-01 11:09:00
---
## 定义

工厂方法模式(Factory Method Pattern)也称为工厂模式(Factory Pattern)。同简单工厂模式一样，工厂方法模式也是一种创建型设计模式。不同于简单工厂模式的都是通过同一个具体类（类的静态方法）或者函数来创建对象，工厂方法模式是通过一系列实现创建对象接口的具体子类来创建对象。即：

**工厂方法模式定义一个用于创建对象的接口，让子类决定实例化哪一个类。Factory Method 使一个类的实例化延迟到其子类。**

## 示例

### UML类图

![工厂方法模式](https://static.cyub.vip/images/202006/factory_method.gif)

### 实现

现在我们考虑实现一个各种图形svg格式绘制功能。首先我们先定义一个绘制接口**IShape**，接下来实现该接口的具体图形**Circle**和**Rectangle**。接着就是创建图形的接口**IShapeFactory**，以及实现该接口的具体工厂**CircleFactory**和**RectangleFactory**。

角色与代码映射


角色 | 代码
---|---
Creator | IShapeFactory
ConcreteCreator | CircleFactory, RectangleFactory
Product | IShape
ConcreteProduct | Circle, Rectangle


**IShape**

```go
type IShape interface {
	Draw(io.Writer) error
}
```

```go
type Circle struct {
	Location Point
	Radius   float64
}

func (c *Circle) Draw(w io.Writer) error {
	_, err := fmt.Fprintf(w, `<circle cx="%f" cy="%f" r="%f"/>`, c.Location.X, c.Location.Y, c.Radius)
	return err
}
```

**Rectangle**

```go
type Rectangle struct {
	Location Point
	Size     Size
}

func (rect *Rectangle) Draw(w io.Writer) error {
	_, err := fmt.Fprintf(w, `<rect x="%f" y="%f" width="%f" height="%f"/>`, rect.Location.X, rect.Location.Y, rect.Size.Width, rect.Size.Height)
	return err
}
```

**IShapeFactory**

```go
type IShapeFactory interface {
	Create(viewport Viewport) Shape
}
```

**CircleFactory**

```go
type CircleFactory struct{}

func (factory *CircleFactory) Create(viewport Viewport) Shape {
	return &Circle{
		Location: viewport.Location,
		Radius:   math.Min(viewport.Size.Width, viewport.Size.Height),
	}
}
```


**RactangleFactory**

```go
type RactangleFactory struct{}

func (factory *RactangleFactory) Create(viewport Viewport) Shape {
	return &Rectangle{
		Location: viewport.Location,
		Size:     viewport.Size,
	}
}
```

**Document**

```go
type Point struct {
	X float64
	Y float64
}

type Size struct {
	Width  float64
	Height float64
}

type Viewport struct {
	Location Point
	Size     Size
}

type Document struct {
	ShapeFactories []ShapeFactory
}

func (doc *Document) Draw(w io.Writer) error {
	viewport := Viewport{
		Location: Point{
			X: 0,
			Y: 0,
		},
		Size: Size{
			Width:  640,
			Height: 480,
		},
	}
	if _, err := fmt.Fprintf(w, `<svg height="%f" width="%f">`, viewport.Size.Height, viewport.Size.Width); err != nil {
		return err
	}

	for _, factory := range doc.ShapeFactories {
		shape := factory.Create(viewport)
		if err := shape.Draw(w); err != nil {
			return err
		}
	}

	_, err := fmt.Fprint(w, `</svg>`)
	return err
}

doc := &svg.Document{
	ShapeFactories: []svg.ShapeFactory{
		&svg.CircleFactory{},
		&svg.RactangleFactory{},
	},
}

doc.Draw(os.Stdout)
```

## 总结

优点：可以避免创建者和具体产品之间的紧密耦合。
 
- 符合单一职责原则。 你可以将产品创建代码放在程序的单一位置，从而使得代码更容易维护。

- 符合开闭原则。 无需更改现有客户端代码，你就可以在程序中引入新的产品类型。

缺点：

- 每一个具体产品类就得需要一个对应的工厂，增加了代码的复杂度

## 参考

- [示例来源](http://blog.ralch.com/tutorial/design-patterns/golang-factory-method/)