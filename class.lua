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
            if string.find(key,"__") == 1 then
                classMeta[key] = value
                return
            end
        end

        classMembers[key] = value
    end

    function classInfo._CreateInstance(classType, ...)
        local instance = {}
        instance._classInfo = classInfo

        setmetatable(instance, classMeta)

        local ctor = classType["ctor"]
        if (ctor ~= nil) then
            ctor(instance, ...)
        end

        return instance
    end

    classMembers.new = classInfo._CreateInstance

    classMeta.__index = classData

    setmetatable(classData, {
        __index = classInfo._GetClassMember,
        __newindex = classInfo._SetClassMember,
    })
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
local classInfo = class("skyClass.classInfo")
skyClass.classInfo = classInfo
classInfo.cacheInfo = {}

---* create a classInfo by class
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

---* create a classInfo by class name
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
---@return table<string,function|table>
function classInfo:getClassMetaMethods()
    local t = {}
    for key, value in pairs(self.bindClassInfo.classMeta) do
        t[key] = value
    end
    return t
end

---* get class meta method
---@param name string meta method name
---@return function|table
function classInfo:getClassMetaMethod(name)
    local t = self.bindClassInfo.classMeta
    return t[name]
end

---* set class meta method
---@param name string meta method name
---@param value function|table meta method value
function classInfo:setClassMetaMethod(name,value)
    self.bindClassInfo.classMeta[name] = value
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

---* get class raw member
---* the constructor's name is "ctor"
---* can not get meta method,please use `getClassMetaMethod`
---@param name any
---@return any
function classInfo:getClassMember(name)
    return self.bindClassInfo.classMembers[name]
end

---* set class raw member
---* the constructor's name is "ctor"
---* can not set meta method,please use `setClassMetaMethod`
---@param name any
---@param value any
function classInfo:setClassMember(name,value)
    self.bindClassInfo.classMembers[name] = value
end

---@class instanceInfo
local instanceInfo = class("skyClass.instanceInfo")
skyClass.instanceInfo = instanceInfo
instanceInfo.cacheInfo = {}
-- set weak table,it can not effect gc
setmetatable(instanceInfo.cacheInfo, {__mode = "kv"})

---* create a instanceInfo by instance
---@generic T : class
---@param instance T
---@return instanceInfo
function instanceInfo.Create(instance)
    if instanceInfo.cacheInfo[instance] then
        return instanceInfo.cacheInfo[instance]
    end
    local self = instanceInfo:new()
    self.bindClassInfo = rawget(instance,"_classInfo")
    self.bindInstance = instance
    instanceInfo.cacheInfo[instance] = self
    return self
end

---* get class's info of instance
---@return classInfo
function instanceInfo:getClassInfo()
    return classInfo.CreateByName(self.bindClassInfo.name)
end

---* get instance raw field
---@param name any
---@return any
function instanceInfo:getField(name)
    return rawget(self.bindInstance,name)
end

---* set instance raw field
---@param name any
---@param value any
---@return any
function instanceInfo:setField(name,value)
    return rawset(self.bindInstance,name,value)
end

---* get instance all raw field
---@param name any
---@return any
function instanceInfo:getAllField()
    local t = {}
    local curMeta = getmetatable(self.bindInstance)
    setmetatable(self,nil)
    for key, value in pairs(self.bindInstance) do
        t[key] = value
    end
    setmetatable(self,curMeta)
    return t
end