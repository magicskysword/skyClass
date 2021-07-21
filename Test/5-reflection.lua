require("class")

local function Test()
    local a = class("a5")

    function a:new()
        self.x = 1
    end

    a.staticField = 2
    function a.AddField(num)
        a.staticField = a.staticField + num
    end

    local b = class("b5",a)
    local c = class("c5",a)

    -- 反射类型创建 - 从名称
    local aInfo = skyClass.classInfo.CreateByName("a5")
    if aInfo:getClass() ~= a then
        print("Test 5-1 fail")
        return false
    end

    -- 反射类型创建 - 从类
    if aInfo ~= skyClass.classInfo.Create(a) then
        print("Test 5-2 fail")
        return false
    end

    -- 反射获取字段
    if aInfo:getClassMember("staticField") ~= 2 then
        print("Test 5-3 fail")
        return false
    end

    -- 反射获取方法
    aInfo:getClassMember("AddField")(5)
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
    local aSubClasses = aInfo:getSubClasses()
    if not (aSubClasses["b5"] == b and aSubClasses["c5"] == c) then
        print("Test 5-6 fail")
        return false
    end

    -- 反射获取类的元方法
    local metaMethods = aInfo:getClassMetaMethods()
    if metaMethods["__index"] == nil then
        print("Test 5-7 fail")
        return false
    end

    local a1 = a:new()
    local a1Info = skyClass.instanceInfo.Create(a1)

    if a1Info:getClassInfo() ~= aInfo then
        print("Test 5-8 fail")
        return false
    end

    -- 通过实例反射对象获取实例字段
    if a1Info:getField("x") ~= 1 then
        print("Test 5-9 fail")
        return false
    end
    -- 通过实例反射对象设置实例字段
    a1Info:setField("x",10)
    if a1Info:getField("x") ~= 10 then
        print("Test 5-10 fail")
        return false
    end

    return true
end

return Test