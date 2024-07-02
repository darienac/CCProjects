---include ../api/api.lua

local t, newSetup = Tortoise()
if newSetup then
    print("Configure Tortoise API in .tortoise file")
    return
end

local config = {
    ["startPos"] = {0,0,0},
    ["endPos"] = {0,0,0}
}
if fs.exists(".quarryTask") then
    local f = fs.open(".quarryTask", "r")
    for line in f.readLine do
        local args = {}
        for word in string.gmatch(line, "([^%s]+)") do
            table.insert(args, word)
        end
        if args[1] == "startPos" then
            config.startPos = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
        elseif args[2] == "endPos" then
            config.endPos = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
        end
    end
    f.close()
else
    term.write("Enter Quarry Start Coordinates\n(space separated): ")
    config.startPos = {}
    for word in string.gmatch(read(), "([^%s]+)") do
        table.insert(config.startPos, tonumber(word))
    end
    term.write("Enter Quarry End Coordinates\n(space separated): ")
    config.endPos = {}
    for word in string.gmatch(read(), "([^%s]+)") do
        table.insert(config.endPos, tonumber(word))
    end
    local f = fs.open(".quarryTask", "w")
    f.writeLine("startPos " .. config.startPos[1] .. " " .. config.startPos[2] .. " " .. config.startPos[3])
    f.writeLine("endPos " .. config.endPos[1] .. " " .. config.endPos[2] .. " " .. config.endPos[3])
    f.close()
end