# skyClass

**skyClass**是`lua`的基于元表的`class`库

## 功能：
- [x] 构造函数<br>
- [x] 继承<br>
- [x] 允许自定义元方法<br>
- [ ] 简单反射<br>
- [ ] 类型绑定<br>

## 提示
该库加入了基于EmmyLua的类型注释，建议使用EmmyLua插件以获得较好的类型提示

## 使用方法

### 创建类

使用 `a = class("a")` 的方式来创建新的类
使用 function a:new() 来定义构造函数

```lua
require("class")

---@class a
a = class("a")

-- 构造函数
function a:new(name)
    self.name = name
    self.age = 0
end

-- 创建实例
local a1 = a:new("张三")
a1.age = 12
local a2 = a:new("李四")
a2.age = 14

print(a1.name,a1.age)
print(a2.name,a2.age)
```
输出
```
张三    12
李四    14
```

### 类方法

```lua
require("class")

---@class a
a = class("a")

function a:new(name)
    self.name = name
    self.age = 0
end

---* 自定义方法
---@param year number
function a:grow(year)
    self.age = self.age + year
end

local a1 = a:new("张三")
a1.age = 12
a1:grow(4)
print(a1.name,a1.age)
```
输出
```
张三    16
```

### 类静态成员

直接在类上定义的函数与字段即为静态成员，静态成员可在类与对象里进行访问、调用。

```lua
require("class")

---@class a
a = class("a")

a.MONEY = 0
function a:new(name)

end

---@param num number
function a.AddMoney(num)
    a.MONEY = a.MONEY + num
end

a.AddMoney(1000)
local a1 = a:new()
a1.AddMoney(1000)

print(a.MONEY,a1.MONEY)
```
输出
```
2000    2000
```

### 类继承

使用 `b = class("b",a)` 来创建一个继承 `a` 类的 `b` 类<br/>
子类的字段与方法会覆盖基类的字段与方法<br/>
如果需要调用基类的字段与方法，直接使用 `a.field` 或 `a.method()` 即可<br/>
如果需要调用基类的构造函数，使用 `a.ctor(self)` 来调用

```lua
require("class")

---@class a
a = class("a")

---@param name string
function a:new(name)
    self.name = name
    self.age = 0
end

---@param year number
function a:grow(year)
    self.age = self.age + year
end

local super
---@class b:a
b = class("b",a)

---@param name string
function b:new(name)
    a.ctor(self,name)
    self.money = 0
end

---@param num number
function b:earn(num)
    self.money = self.money + num
end

local b1 = b:new("李四")
b1.age = 14
b1:grow(5)
b1:earn(5000)

print(b1.name,b1.age,b1.money)
```
输出
```
李四    19      5000
```

### 元方法定义

```lua
require("class")
---@class a
a = class("a")

function a:new()
    self.num = 0
end

function a:__add(other)
    local new = a:new()
    new.num = self.num + other.num
    return new
end

local a1 = a:new()
a1.num = 10
local a2 = a:new()
a2.num = 5
local a3 = a1 + a2
print(a1.num,a2.num,a3.num)
```
输出
```
10      5       15
```
**注意**：不要覆盖`__index`与`__newindex`方法<br/>
**注意**：由于元方法的定义不在对象上，因此使用访问符是无法获得元方法的。如果要获取元方法，请使用反射的方式获取