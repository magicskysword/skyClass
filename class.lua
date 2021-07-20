skyclass = {}
setmetatable(skyclass, skyclass)


local function _CreateClass(name, base)
    local classData = {}
    -- class info
    local classInfo = {}
    classData._classInfo = classInfo
    -- storge class's meta method
    local classMeta = {}
    -- storge class's method and field
    local classMembers = {}

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
        elseif classMeta[key] ~= nil then
            return classMeta[key]
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
