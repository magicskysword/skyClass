local classes = {}

local function _CreateClass(name, base)
    local classData = {}

    assert(classes[name] == nil,
    string.format("create class [%s] fail,it has been defined",name))
    classes[name] = classData

    -- class info
    local classInfo = {}
    classData._classInfo = classInfo
    -- storge class's meta method
    local classMeta = {}
    -- storge class's method and field
    local classMembers = {}

    classInfo.class = classData
    classInfo.name = name
    classInfo.base = base
    classInfo.classMeta = classMeta
    classInfo.classMembers = classMembers
    classInfo.subclasses = {}
    classInfo.new = nil

    if base ~= nil then
        local baseClassInfo = rawget(base, "_classInfo")
        baseClassInfo.subclasses[name] = classData

        -- copy meta method
        for key, value in pairs(baseClassInfo.classMeta) do
            classMeta[key] = value
        end
    end

    function classInfo._GetClassMember(classType, key)
        if classMembers[key] ~= nil then
            return classMembers[key]
        else
            if classInfo.base then
                local baseClassInfo = rawget(base, "_classInfo")
                return baseClassInfo._GetClassMember(classInfo.base, key)
            end
        end
    end

    function classInfo._SetClassMember(classType, key, value)
        if type(key) == "string" then
            if key == "new" then
                classMembers["ctor"] = value
                return
            end
            if string.sub(key, 1, 2) == "__" then
                classMeta[key] = value
                return
            end
        end

        classMembers[key] = value
    end

    function classInfo._CreateInstance(classType, ...)
        local instance = {}
        instance._instanceInfo = {
            class = classType,
        }

        setmetatable(instance, classMeta)

        local ctor = classType["ctor"]
        if (ctor ~= nil) then
            ctor(instance, ...)
        end

        return instance
    end

    classMembers.new = classInfo._CreateInstance

    classData.__index = classInfo._GetClassMember
    classData.__newindex = classInfo._SetClassMember

    classMeta.__index = classData

    setmetatable(classData, classData)
    return classData
end

---* Create a class
---@generic T
---@param name string
---@param base T
---@return table,T
---@overload fun(name : string) : table
function class(name, base)
    assert(type(name) == 'string', "class name is not a string.")
    return _CreateClass(name, base)
end

---@class skyClass
skyClass = class("skyClass")
local skyClass = skyClass
skyClass.classes = classes

---@class classInfo
local classInfo = class("reflection")
skyClass.classInfo = classInfo
classInfo.cacheInfo = {}

---* create a reflectionType by class
---@param classType class
---@return classInfo
function classInfo.Create(classType)
    if classInfo.cacheInfo[classType] then
        return classInfo.cacheInfo[classType]
    end
    local self = classInfo:new()
    self.bindClassInfo = rawget(classType,"_classInfo")
    classInfo.cacheInfo[classType] = self
    return self
end

---* create a reflectionType by name
---@param name string
---@return classInfo
function classInfo.CreateByName(name)
    return classInfo.Create(skyClass.classes[name])
end

---* get the true class
---@return class
function classInfo:getClass()
    return self.bindClassInfo.class
end

---* get the class name
---@return string
function classInfo:getName()
    return self.bindClassInfo.name
end

---* get the base class
---@return class
function classInfo:getBaseClass()
    return self.bindClassInfo.base
end

---* get the base class's reflectionType
---@return classInfo
function classInfo:getBaseClassType()
    return classInfo.Create(self.bindClassInfo.base)
end

---* get all subclasses
---@return table<string,class>
function classInfo:getSubClasses()
    local t = {}
    for key, value in pairs(self.bindClassInfo.subclasses) do
        t[key] = value
    end
    return t
end

---* get all subclasses's reflectionType
---@return table<string,class>
function classInfo:getSubClassesType()
    local t = {}
    for key, value in pairs(self.bindClassInfo.subclasses) do
        t[key] = classInfo.Create(value)
    end
    return t
end

---* get all class defined meta method
---@return table
function classInfo:getClassMetaMethods()
    local t = {}
    for key, value in pairs(self.bindClassInfo.classMeta) do
        t[key] = value
    end
    return t
end

---* get all class static member
---@return table
function classInfo:getClassMember(memberName)
    local t = self.bindClassInfo.classMembers
    return t[memberName]
end

---* get all class static member
---@return table
function classInfo:getClassMembers()
    local t = {}
    for key, value in pairs(self.bindClassInfo.classMembers) do
        t[key] = value
    end
    return t
end
