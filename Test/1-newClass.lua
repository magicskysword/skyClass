require("class")

local function Test()
    local flag = true;

    local a = class("a")

    function a:new(x)
        self.a = x
        self.b = 2
    end

    function a:add()
        self.a = self.a + self.b
    end

    local a1 = a:new(1)
    local a2 = a:new(2)

    a1.b = 3
    a2.b = 4
    if not (a1.a == 1 and a1.b == 3 and a2.a == 2 and a2.b == 4) then
        flag = false
    end

    a1:add()
    a2:add()
    if not (a1.a == 4 and a2.a == 6) then
        flag = false
    end

    return flag
end

return Test
