require("class")

local function Test()
    local flag = true;

    local a = class("a")

    function a:ctor()
        self.a = 1
        self.b = 2
    end

    function a:add()
        self.a = self.a + self.b
    end

    local b = class("b",a)

    function b:ctor()
        a.ctor(self)
        self.c = 10
    end

    local a1 = a:new()
    local b1 = b:new()

    a1.a = 3
    b1.b = 3
    if not (a1.a == 3 and a1.b == 2 and b1.a == 1 and b1.b == 3) then
        flag = false
    end

    a1:add()
    b1:add()
    if not (a1.a == 5 and a1.b == 2 and b1.a == 4 and b1.b == 3) then
        flag = false
    end

    function b:add()
        self.c = self.c + self.b
    end
    a1:add()
    b1:add()
    if not (a1.a == 7 and b1.c == 13) then
        flag = false
    end

    local c = class("c",b)
    function c:ctor()
        b.ctor(self)
        self.c = 20
    end

    local c1 = c:new()
    c1:add()

    if not (c1.c == 22) then
        flag = false
    end

    return flag
end

return Test