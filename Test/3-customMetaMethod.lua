require("class")

local function Test()
    local flag = true;

    local a = class("a")

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
    if a3.num ~= 15 then
        flag = false
    end

    local b = class("b",a)

    function b:new()
        a.ctor(self)
    end

    local b1 = b:new()
    b1.num = 10
    local b2 = b:new()
    b2.num = 5
    local b3 = b1 + b2
    if b3.num ~= 15 then
        flag = false
    end

    function b:__add(other)
        local new = b:new()
        new.num = self.num + other.num + other.num
        return new
    end
    local b4 = b1 + b2
    if b4.num ~= 20 then
        flag = false
    end

    return flag
end

return Test