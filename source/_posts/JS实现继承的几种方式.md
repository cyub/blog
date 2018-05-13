---
title: JS实现继承的几种方式
date: 2018-02-14 08:23:51
tags:
    JS
---
JS无法像其他高级语言那样通过extend直接实现继承。只通过一定方式来实现继承机制。常见的几种实现继承的方式有：
1. 对象冒充
2. call/apply方法
3. 原型链（prototype chain)
4. 混合方式（call/apply+prototype chain)
<!-- more -->

## 1. 对象冒充

父类：
```javascript
function superClass(name){
    this.name=name;
    this.type='superClass';
}
```
子类：
```javascript
function subClass(name)
{
   
    this.extends= superClass;//使用父类构造函数冒充子类的一个属性
    this.extends(name);//调用父类构造函数
    delete this.extends;    //删除冒充属性
    this.type='subClass';
}
```
这种方式的缺点有1.需额外添加一个属性；2.无法使用父级原型的拥有的属性

**注意：子类的独自拥有的属性应该放在最后，以防止父类的属性覆盖了**

对象冒充可以实现多重继承:

```javascript
function ClassZ() {
    this.newMethod = ClassX;
    this.newMethod();
    delete this.newMethod;
 
    this.newMethod = ClassY;
    this.newMethod();
    delete this.newMethod;
}
```

## 2. call/apply方法

父类:
```javascript
function superClass(name){
  this.name=name;
  this.type='superClass';
}
```
子类：
```JavaScript
function subClass(name){
   superClass.call(this,name);
   //或 superClass.apply(this,[name]);
   //或 superClass.apply(this,arguments);//arguments以数组形式存储着函数的参数
   this.type='subClass';
}
```
这种实现方式的缺点是无法继承来自父级原型的属性

## 3. 原型链（prototype chain)
父类：
```JavaScript
function superClass(name){
 this.name=name;
 this.type='superClass';
}
```

子类：
```JavaScript
function subClass(){
 this.type='subClass';
}
subClass.prototype=new superClass;//将原型设置父类superClass
subObj=new subClass('it is subObj');
```

使用firebug打印对象subObj信息：`console.dir(subObj)`

![firebug调试](//static.cyub.vip/images/201802/firebug_inspect.png)

程序原意将name属性设为'it is subobj'但没有起作用。这是因为要调用父类，必须在设置原型的时候调用。即`subClass.prototype=new superClass(name)`

但属性较多的情况下，就过于麻烦了。解决办法就是下面将讲的混合方式实现继承

在讲混合方式实现继承之前，我们先来了解一下对象继承关系和属性来源判断

**子类对象既是子类的实例也是父类的实例也是Object的实例。任何应用类型默认继承了Object.所有函数的默认都是Object的实例**

```javascript
console.log(subObj instanceof superClass)=== true
console.log(subObj instanceof subClass)=== true
console.log(subObj instanceof Object)=== true
```

**通过过`in`和`hasOwnPropertype`能判断属性的来源**
```javascript
if(property in object){
//如果属性是继承来的或本身拥有的，则为输出true
console.log(true);
}else{
console.log(false);
}

if(object.hasOwnPropertype('property')){
//如果属性属于本身拥有者输出真
console.log(true)
}else{
console.log(false)
}

if(property in object && !object.hasOwnProperty('property')){
//如果属性是继承而来的则为真
console.log(true);
}
```


**如果对象的属性与其原型的属性同名，则原型的属性会被屏蔽但不会覆盖，如果delete操作后，对象的属性将使原型的属性值**
```JavaScript
function superClass(){
    this.name='superClass';
}
function subClass(){
    this.name='subClass';
}
subClass.prototype=new superClass();
var sub=new subClass();
console.log(sub.name);
delete sub.name;
console.log(sub.name);
```

## 4. 混合方式（call/apply+prototype chain)

父类:
```JavaScript
function superClass(name)
{
this.type='superClass';
this.name=name;
}
superClass.prototype.exendInfo='i\'m parent class prototype property';
```

子类：
```JavaScript
function subClass(name){
  superClass.apply(this,arguments);
  this.type='subClass';
}
subClass.prototype=new superClass;
```

问：为什么会添加最后一句？使用superClass.apply(this,arguments);不就行了吗？
答：如果只使用superClass.apply(this.arguments)则使用父类的构造函数。但是无法继承了父类的原型属性，即extendInfo属性。


## 参考资料
[ECMAScript继承机制实现](http://www.w3school.com.cn/js/pro_js_inheritance_implementing.asp)

[JavaScript面向对象简介](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript)





















