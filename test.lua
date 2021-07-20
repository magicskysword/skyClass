local testCount = 0
local testPass = 0
local testNonPassList = {}

function CheckTest(testChunk)
    testCount = testCount + 1
    local testFunc = require("Test."..testChunk)
    if testFunc() then
        testPass = testPass + 1
    else
        table.insert(testNonPassList,testChunk)
    end
end

CheckTest("1-newClass")
CheckTest("2-inherit")
CheckTest("3-customMetaMethod")
CheckTest("4-staticMember")

print(string.format("共有 %d/%d 测试通过",testPass,testCount))
if testPass < testCount then
    local tip = "以下测试未通过："..table.concat(testNonPassList,",")
    print(tip)
end