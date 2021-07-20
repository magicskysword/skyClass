require("class")

local function Test()
    local a = class("a4")

    a.MONEY = 0
    function a:new(name)

    end

    ---@param num number
    function a.AddMoney(num)
        a.MONEY = a.MONEY + num
    end

    a.AddMoney(1000)
    local a1 = a:new()
    a1.AddMoney(1000)

    if not (a.MONEY == 2000 and a1.MONEY == 2000) then
        print("Test 4-1 fail")
        return false
    end

    return true
end

return Test