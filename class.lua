skyclass = {}
setmetatable(skyclass, skyclass)

local function _GetClassMember(classType, key)
    local classInfo = rawget(classType, "_classInfo")
    if type(key) == "string" and string.sub(key, 1, 2) == "__" then
        return classInfo.classMeta[key]
    end

    local classMembers = classInfo.classMembers
    if classMembers[key] ~= nil then
        return classMembers[key]
    else
        if classInfo.super then
            return _GetClassMember(classInfo.super, key)
        end
    end
end

local function _SetClassMember(classType, key, value)
    local classInfo = rawget(classType, "_classInfo")
    if type(key) == "string" and string.sub(key, 1, 2) == "__" then
        classInfo.classMeta[key] = value
        return
    end

    classInfo.classMembers[key] = value
end

local function _GetInstanceData(instance, key)
    local instanceInfo = rawget(instance, "_instanceInfo")
    local data = instanceInfo.data[key]
    if data ~= nil then
        return data
    end
    return _GetClassMember(instanceInfo.class, key)
end

local function _SetInstanceData(instance, key, value)
    local instanceInfo = rawget(instance, "_instanceInfo")
    instanceInfo.data[key] = value
end

local function _CreateInstance(classType, ...)
    local instance = {}
    instance._instanceInfo = {
        class = classType,
        data = {},
    }

    local classInfo = rawget(classType, "_classInfo")
    setmetatable(instance, classInfo.classMeta)

    local ctor = classType["ctor"]
    if (ctor ~= nil) then
        ctor(instance, ...)
    end

    return instance
end

local function _AddSubClass(super, subClass)
    if (super == nil) then
        return
    end

    local classInfo = rawget(super, "_classInfo")
    local subClassInfo = rawget(subClass, "_classInfo")
    classInfo.subclasses[subClassInfo.name] = subClass

    -- copy meta method
    for key, value in pairs(classInfo.classMeta) do
        subClassInfo.classMeta[key] = value
    end
end

local function _CreateClass(name, super)
    local classData = {
        __index = _GetClassMember,
        __newindex = _SetClassMember,
    }
    -- class meta info
    classData._classInfo = {
        name = name,
        super = super,
        -- storge class's meta method
        classMeta = {
            __index = _GetInstanceData,
            __newindex = _SetInstanceData,
        },
        -- storge class's method and field
        classMembers = {
            new = _CreateInstance,
        },
        subclasses = {},
    }
    _AddSubClass(super, classData)

    setmetatable(classData, classData)
    return classData
end

---* Create a class
---@generic T
---@param name string
---@param super T
---@return table,T
---@overload fun(name : string) : table
function class(name, super)
    assert(type(name) == 'string', "class name is not a string.")
    return _CreateClass(name, super)
end
