---include ../api/api.lua

function getNextPos(prevPos, startPos, endPos)
    nextPos = {prevPos[1], prevPos[2], prevPos[3]}
    local xDir = (endPos[1] > startPos[1] and 1) or -1
    local zDir = (endPos[3] > startPos[3] and 1) or -1
    if prevPos[1] == endPos[1] then
        nextPos[1] = startPos[1]
        if prevPos[3] == endPos[3] then
            nextPos[3] = startPos[3]
            nextPos[2] = prevPos[2] - 1
        else
            nextPos[3] = prevPos[3] + zDir
        end
    else
        nextPos[1] = prevPos[1] + xDir
    end
    return nextPos
end

function writeConfigToPath(config)
    local f = fs.open(".quarryTask", "w")
    f.writeLine("startPos " .. config.startPos[1] .. " " .. config.startPos[2] .. " " .. config.startPos[3])
    f.writeLine("endPos " .. config.endPos[1] .. " " .. config.endPos[2] .. " " .. config.endPos[3])
    f.writeLine("nextPos " .. config.startPos[1] .. " " .. config.startPos[2] .. " " .. config.startPos[3])
    f.close()
end

local t, setupExists = Tortoise()
if not setupExists then
    print("Configure Tortoise API in .tortoise file")
    return
end

local config = {
    ["startPos"] = {0,0,0},
    ["endPos"] = {0,0,0},
    ["nextPos"] = {0,0,0}
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
        elseif args[1] == "endPos" then
            config.endPos = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
        elseif args[1] == "nextPos" then
            config.nextPos = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
        end
    end
    f.close()
else
    print("Enter Quarry Start Coordinates")
    term.write("(space separated): ")
    config.startPos = {}
    for word in string.gmatch(read(), "([^%s]+)") do
        table.insert(config.startPos, tonumber(word))
    end
    config.nextPos = {config.startPos[1], config.startPos[2], config.startPos[3]}
    print("Enter Quarry End Coordinates")
    term.write("(space separated): ")
    config.endPos = {}
    for word in string.gmatch(read(), "([^%s]+)") do
        table.insert(config.endPos, tonumber(word))
    end
    writeConfigToPath(config)
end

local complete = false
while not complete do
    if config.nextPos[1] == config.endPos[1] and config.nextPos[2] == config.endPos[2] and config.nextPos[3] == config.endPos[3] then
        complete = true
    end
    if t:isFull() then
        if not t:homeDeposit() then
            print("Unable to deposit inventory")
            return
        end
    end
    if not t:makeTripTo(config.nextPos, true) then
        print("Unable to travel to next position")
        return
    end
    turtle.digDown()
    if not complete then
        config.nextPos = getNextPos(config.nextPos, config.startPos, config.endPos)
        writeConfigToPath(config)
    end
end
fs.delete(".quarryTask")
if not t:homeDeposit() then
    print("Unable to deposit inventory")
    return
end
print("Quarry Task Complete")