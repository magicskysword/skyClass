require("class")

local function Test()
    local a = class("a1")

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
        print("Test 1-1 fail")
        return false
    end

    a1:add()
    a2:add()
    if not (a1.a == 4 and a2.a == 6) then
        print("Test 1-2 fail")
        return false
    end

    return true
end

return Test
