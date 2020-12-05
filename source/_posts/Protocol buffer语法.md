title: Protocol buffers语法
author: tinker
tags:
  - protobuf
categories:
  - 编码与协议
date: 2020-12-03 20:56:00
---
## 简介

Protocol Buffers简称Protobuf，是google公司推出的一种数据描述语言。Protocol buffers具有平台无关、语言无关、二进制格式编码、编码后体积小，序列化和反序列化快、类型安全、向后兼容等特点。

Protocol buffers有专门的语法结构来定义数据结构。消息和RPC服务接口是Protocol buffers中两大基本组成。消息类似一个Json object，RPC服务接口定义了服务所具有的接口和所依赖的消息类型。

Protocol buffers定义的数据结构应该保存在.proto后缀名的文件中。目前最新版本的语法协议是proto3。

<!--more-->


## 定义消息

message（消息）是protobuf中最基本数据单元。protobuf中使用message关键字来定义消息。假设想要定义一个搜索请求消息格式，其中包含搜索的查询字符串，分页参数。下面是用于定义消息类型的.proto文件内容：

```
syntax = "proto3";

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  repeated string snippets = 4;
}
```

`.proto`文件的第一行使用`syntax = "proto3"`表明使用`proto3`语法。

上面代码中定义了一个名字为`SearchRequest`的消息，它包含了四个字段，每个字段都有**名字（Field Name）**，**类型（Field Type）**，**唯一编号（Field Number)**，**字段规则（Field Rule) **。其中字段规则不是必须。


### 字段编号

消息中定义的每个字段都必须有唯一的编号。字段编号是反序列化时候重要依据。当编号范围在1到15之间时候只需要一个字节进行编码，当范围16到2047的字段时候占用两个字节。所以应该为频繁出现的消息元素保留1到15的字段编号。

字段编号不一定从1开始。最小的字段编号是1，最大可到2^29。其中19000到19999位proto保留编号，不可以使用。

### 字段规则

`proto3`语法与`proto2`语法不同之处，其中一项就是去掉了proto2中`required`,`optional`规则，只保留了`repeated`规则，并且对于由于`repeated`规则的标量类型的字段默认采用了`packed`编码，而proto2中需要额外指定选项才能采用`packed`编码。

proto3消息中定义的字段需要满足以下规则之一：

- singular
    
     proto3的默认规则，字段前面不需要加任何关键字。表明该字段可以出现0次或者1次。相当于proto2中的optional规则
- repeated
    
    消息中该字段可以重复出现0次或多次

### 默认值

当反序列化消息时，如果消息中不包含特定的字段时候，则解析对象中的对应字段将被设置为该字段的默认值。默认值规则如下：

- 字符串类型默认值是空字符
- 字节类型默认值是空字节
- 布尔类型默认值是false
- 数值类型默认值是0
- 枚举类型默认值是枚举第一个元素。第一个元素必须是0.
- 消息类型默认值依赖于具体编程语言
- `repeated`规则的字段默认值是空

### 字段类型

Protocol Buffer中字段的类型既可以是**标量类型（ scalar type）**，也可以是**复合类型（composite type）**。

#### 标量类型

.proto Type  | Notes  | C++ Type  | Java Type  | Python Type<sup>[2]</sup>  | Go Type  | Ruby Type  | C# Type  | PHP Type  | Dart Type
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
double | | double  | double  | float  | float64  | Float  | double  | float  | double
float | | float  | float  | float  | float32  | Float  | float  | float  | double
int32  | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead.  | int32  | int  | int  | int32  | Fixnum or Bignum (as required)  | int  | integer  | int
int64  | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead.  | int64  | long  | int/long<sup>[3]</sup>  | int64  | Bignum  | long  | integer/string<sup>[5]</sup>  | Int64
uint32  | Uses variable-length encoding.  | uint32  | int<sup>[1]</sup>  | int/long<sup>[3]</sup>  | uint32  | Fixnum or Bignum (as required)  | uint  | integer  | int
uint64  | Uses variable-length encoding.  | uint64  | long<sup>[1]</sup>  | int/long<sup>[3]</sup>  | uint64  | Bignum  | ulong  | integer/string<sup>[5]</sup>  | Int64
sint32  | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s.  | int32  | int  | int  | int32  | Fixnum or Bignum (as required)  | int  | integer  | int
sint64  | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s.  | int64  | long  | int/long<sup>[3]</sup>  | int64  | Bignum  | long  | integer/string<sup>[5]</sup>  | Int64
fixed32  | Always four bytes. More efficient than uint32 if values are often greater than 228.  | uint32  | int<sup>[1]</sup>  | int/long<sup>[3]</sup>  | uint32  | Fixnum or Bignum (as required)  | uint  | integer  | int
fixed64  | Always eight bytes. More efficient than uint64 if values are often greater than 256.  | uint64  | long<sup>[1]</sup>  | int/long<sup>[3]</sup>  | uint64  | Bignum  | ulong  | integer/string<sup>[5]</sup>  | Int64
sfixed32  | Always four bytes.  | int32  | int  | int  | int32  | Fixnum or Bignum (as required)  | int  | integer  | int
sfixed64  | Always eight bytes.  | int64  | long  | int/long<sup>[3]</sup>  | int64  | Bignum  | long  | integer/string<sup>[5]</sup>  | Int64
bool | | bool  | boolean  | bool  | bool  | TrueClass/FalseClass  | bool  | boolean  | bool
string  | A string must always contain UTF-8 encoded or 7-bit ASCII text, and cannot be longer than 232.  | string  | String  | str/unicode<sup>[4]</sup>  | string  | String (UTF-8)  | string  | string  | String
bytes  | May contain any arbitrary sequence of bytes no longer than 232.  | string  | ByteString  | str  | []byte  | String (ASCII-8BIT)  | ByteString  | string  | List

<sup>[1]</sup> In Java, unsigned 32-bit and 64-bit integers are represented using their signed counterparts, with the top bit simply being stored in the sign bit.

<sup>[2]</sup> In all cases, setting values to a field will perform type checking to make sure it is valid.

<sup>[3]</sup> 64-bit or unsigned 32-bit integers are always represented as long when decoded, but can be an int if an int is given when setting the field. In all cases, the value must fit in the type represented when set. See [2].

<sup>[4]</sup> Python strings are represented as unicode on decode but can be str if an ASCII string is given (this is subject to change).

<sup>[5]</sup> Integer is used on 64-bit machines and string is used on 32-bit machines.

#### 枚举类型

我们可以通过`enum`关键字定义枚举类型。

```
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    WEB = 1;
    IMAGES = 2;
    LOCAL = 3;
    NEWS = 4;
    PRODUCTS = 5;
    VIDEO = 6;
  }
  Corpus corpus = 4;
}
```

上面结构体中Corpus是一个枚举类型，它的值可以是`UNIVERSAL`,`WEB`,`IMAGES`,`LOCAL`,`NEWS`,`PRODUCTS`,`VIDEO`。

注意：

1. 枚举常量必须是32位整数范围
2. 由于枚举值采用varint编码，负值编码效率不高，不推荐使用负值作为枚举值
3. 每一个枚举定义必须要包含映射到0的元素（比如Corpus中UNIVERSAL）。一方面0值用来作为默认值。二来为了兼容proto2语法，在proto2中第一个元素总是作为默认值


#### 其他消息类型

我们可以使用其他消息类型作为某个字段的类型：

```
message SearchResponse {
  repeated Result results = 1;
}

message Result {
  string url = 1;
  string title = 2;
  repeated string snippets = 3;
}
```

上面proto定义中可以看出来，在`SearchResponse`消息中，我们使用`Result`类型来定义字段result的类型。

#### 嵌套类型

我们可以在一个消息类型中，嵌套其他类型的消息。比如下面的`SearchResponse`消息中嵌套了`Result`类型

```
message SearchResponse {
  message Result {
    string url = 1;
    string title = 2;
    repeated string snippets = 3;
  }
  repeated Result results = 1;
}
```

我们一个通过`_Parent_._Type_`语法来复用父级消息的类型。`SomeOtherMessage`消息中的result字段的类型`SearchResponse`中的`Result`类型

```
message SomeOtherMessage {
  SearchResponse.Result result = 1;
}
```

#### 任意类型

通过任意类型，可以将消息作为嵌入类型使用，任意类型的字段以字节的形式进行序列化。使用任意类型，需要导入`google/protobuf/any.proto`类型

```
import "google/protobuf/any.proto";

message ErrorStatus {
  string message = 1;
  repeated google.protobuf.Any details = 2;
}
```

#### Oneof类型

当一个消息中包含多个字段，并且最多同时设置一个字段。我们就可以使用Oneof类型节省内存。

```
message SampleMessage {
  oneof test_oneof {
    string name = 4;
    SubMessage sub_message = 9;
  }
}
```

Oneof字段特性：

1. 除了`map`类型字段和`repeated`规则字段外，Oneof字段支持其他任意类型
2. 当给Oneof字段设置值时，会自动清除该字段已有值。这就是说Oneof字段的值只有最后一次设置才有效


#### Map类型

我们可以通过下面语法声明map类型字段：

```
map<key_type, value_type> map_field = N;
```

其中key_type可以除了`float`和`bytes`之外的任意标量类型。value_type可以是除了map类型的任意类型。map类型字段不能是`repeated`规则。


#### 未知字段

未知字段指的是反序列化时候，无法识别的字段。当旧代码解析带有新字段的消息生成的序列化数据时候，该字段对就代码来说就是未知字段。对于未知字段处理规则：

1. proto2默认保留未知字段
2. proto3总是丢弃该未知字段。但3.5版本及更高版本会保留未知字段


### 更新时注意事项

当需要更新消息格式时候，比如增加一个额外的字段，为了不影响已有功能。需要注意以下几个规则:

1. **不要更改字段编号**
2. **新增字段时候，旧消息格式序列化的数据依然能被新生成的代码解析，此时新字段值为默认值，我们要注意到这一点。而旧代码处理新格式序列化的数据会丢弃新增的字段信息**
3. 不再使用的字段可以删除，或者**保留以防止该字段的字段编号被其他字段使用**
4. `int32`, `uint32`, `int64`, `uint64`以及`bool`类型都是兼容的。从其中一种类型更改为另一种类型，不会破坏向前或向后兼容性，但要注意截断问题(比如：int64向int32转换时候，会被截断)
5. `sint32`和`sint64`彼此兼容，但与其他整数类型不兼容
6. 只要字节是有效的UTF-8编码，字符串和字节是兼容的
7. 当`bytes`类型包含一个消息体，嵌套类型的消息类型是与其兼容的
8. `fixed32`和`sfixed32`, `fixed64`, `sfixed64`是兼容的
9. 对于`string`, `bytes`以及消息类型字段，`optional`和`repeated`规则是兼容的
10. `enum`类型与`int32`, `uint32`, `int64`, `uint64`是兼容的。同规则4一样，需注意截断问题
11. 将一个值更改为新`oneof`成员是安全的和二进制兼容的。如果确信没有代码会一次设置多个字段，那么将多个字段移到一个新的字段中可能是安全的。将任何字段移动到现有字段中是不安全的



## 定义服务

通过在`.proto`文件中定义RPC服务接口，接着我们就可以使用protocol buffer编译器生成特定语言的服务接口代码和stub。

比如定义一个RPC服务，该服务具有Search接口，该接口接收SearchRequest参数并返回一个SearchResponse，你可以在你的.proto文件中定义它如下:

```
service SearchService {
  rpc Search(SearchRequest) returns (SearchResponse);
}
```

## 文章来源

- [官方proto3语法指南](https://developers.google.com/protocol-buffers/docs/proto3)