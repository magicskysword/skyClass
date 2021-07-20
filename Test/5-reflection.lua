require("class")

local function Test()
    local a = class("a5")
    a.staticField = 2
    function a.AddField(num)
        a.staticField = a.staticField + num
    end

    local b = class("b5",a)
    local c = class("c5",a)

    -- 反射类型创建 - 从名称
    local aType = skyClass.classInfo.CreateByName("a5")
    if aType:getClass() ~= a then
        print("Test 5-1 fail")
        return false
    end

    -- 反射类型创建 - 从类
    if aType ~= skyClass.classInfo.Create(a) then
        print("Test 5-2 fail")
        return false
    end

    -- 反射获取字段
    if aType:getClassMember("staticField") ~= 2 then
        print("Test 5-3 fail")
        return false
    end

    -- 反射获取方法
    aType:getClassMember("AddField")(5)
    if a.staticField ~= 7 then
        print("Test 5-4 fail")
        return false
    end

    local bType = skyClass.classInfo.Create(b)
    local cType = skyClass.classInfo.Create(c)

    -- 反射获取父类
    if bType:getBaseClass() ~= cType:getBaseClass() then
        print("Test 5-5 fail")
        return false
    end

    -- 反射获取子类
    local aSubClasses = aType:getSubClasses()
    if not (aSubClasses["b5"] == b and aSubClasses["c5"] == c) then
        print("Test 5-6 fail")
        return false
    end

    return true
end

return Test