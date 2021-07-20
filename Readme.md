# skyClass

**skyClass**是`lua`的基于元表的`class`库

## 功能：
- [x] 构造函数<br>
- [x] 继承<br>
- [x] 允许自定义元表<br>
- [ ] 简单反射<br>
- [ ] 类型绑定<br>

## 提示
该库加入了基于EmmyLua的类型注释，建议使用EmmyLua插件以获得较好的类型提示

## 使用方法

### 创建一个类

```lua
require("class")

---@class a
a = class("a")

-- 构造函数
function a:ctor(name)
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