require("class")

local function Test()
    local flag = true
    local a = class("a")

    a.MONEY = 0
    function a:ctor(name)

    end

    ---@param num number
    function a.AddMoney(num)
        a.MONEY = a.MONEY + num
    end

    a.AddMoney(1000)
    local a1 = a:new()
    a1.AddMoney(1000)

    if not (a.MONEY == 2000 and a1.MONEY == 2000) then
        flag = false
    end

    return flag
end

return Test