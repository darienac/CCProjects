local PROGRAM_NAME = "dasConcrete"
local BUFFER_MAX = 256
local DYE_BUFFER_MAX = 64

local config
local bufferInventory
local sandInventory
local gravelInventory
local dyeInventory
local concreteInventory

function createConfigFile()
    local out = {
        sandInventory="left",
        gravelInventory="left",
        dyeInventory="left",
        concreteInventory="back",
        bufferInventory=1, -- either 1 or -1
        digDirection=0,     -- either -1, 0, or 1 for down, forward, or up
    }
    local f = fs.open(PROGRAM_NAME .. ".config", "w")
    f.write(textutils.serialize(out))
    f.close()
end

function loadConfigFile()
    local f = fs.open(PROGRAM_NAME .. ".config", "r")
    local out = textutils.unserialize(f.readAll())
    f.close()

    return out
end

function printUsageInfo()
    print("Commands:")
    print("construct [amount] [color]")
    print("    Ex: construct 128 red")
    print("exit")
end

function getDyeColor(color)
    return "minecraft:" .. color .. "_dye"
end

function splitSlotTo(slot1, slot2)
    local amount1 = turtle.getItemCount(slot1)
    local amount2 = turtle.getItemCount(slot2)
    local diff = amount1 - amount2
    if (diff == 0) then
        return false
    elseif (diff < 0) then
        turtle.select(slot2)
        turtle.transferTo(slot1, math.floor(diff / -2))
    else
        turtle.select(slot1)
        turtle.transferTo(slot2, math.floor(diff / 2))
    end

    return true
end

function bufferMaterial(name, inventory, bufferInventory, currentAmount, bufferMax)
    local items = inventory.list()
    local slotsRemaining = bufferMax - currentAmount
    for slot, item in pairs(inventory.list()) do
        if (item.name == name) then
            local amountToRemove = slotsRemaining
            if (item.count < amountToRemove) then
                amountToRemove = item.count
            end

            amountToRemove = inventory.pushItems(peripheral.getName(bufferInventory), slot, amountToRemove)
            slotsRemaining = slotsRemaining - amountToRemove
            if (slotsRemaining <= 0) then
                break
            end
        end
    end

    local ableToSuck = true
    while ableToSuck do
        if (config.bufferInventory == 1) then
            ableToSuck = turtle.suckUp()
        else
            ableToSuck = turtle.suckDown()
        end
    end

    return bufferMax - slotsRemaining
end

function constructConcrete(dye, amount)
    local sandNeeded = amount / 2
    local gravelNeeded = amount / 2
    local dyeNeeded = amount / 8

    local amountMade = 0

    turtle.select(4)
    turtle.transferTo(9)
    turtle.select(8)
    turtle.transferTo(10)

    local sandCount = turtle.getItemCount(1) + turtle.getItemCount(2) + turtle.getItemCount(3) + turtle.getItemCount(9)
    local gravelCount = turtle.getItemCount(5) + turtle.getItemCount(6) + turtle.getItemCount(7) + turtle.getItemCount(10)
    local dyeCount = 0
    if (turtle.getItemCount(11) > 0) then
        print("Remove items from dye slot (slot 11) before use")
        return
    end

    while (amountMade < amount) do
        if (sandCount < 32) then
            turtle.select(1)
            sandCount = bufferMaterial("minecraft:sand", sandInventory, bufferInventory, sandCount, BUFFER_MAX)
        end
        if (gravelCount < 32) then
            turtle.select(5)
            gravelCount = bufferMaterial("minecraft:gravel", gravelInventory, bufferInventory, gravelCount, BUFFER_MAX)
        end
        if (dyeCount < 8) then
            turtle.select(11)
            dyeCount = bufferMaterial(dye, dyeInventory, bufferInventory, dyeCount, math.ceil((amount - amountMade) / 8))
        end

        turtle.select(4)
        turtle.transferTo(9)
        turtle.select(8)
        turtle.transferTo(10)

        splitSlotTo(1, 2)
        splitSlotTo(1, 3)
        splitSlotTo(2, 9)

        splitSlotTo(5, 6)
        splitSlotTo(5, 7)
        splitSlotTo(6, 10)

        turtle.select(16)
        turtle.craft(math.min(8, math.ceil((amount - amountMade) / 8)))

        local powderLeft = turtle.getItemCount(16)
        while (powderLeft > 0) do
            turtle.select(16)
            local success = false
            while (not success) do
                if (config.digDirection == 0) then
                    success = turtle.place()
                elseif (config.digDirection == 1) then
                    success = turtle.placeUp()
                else
                    success = turtle.placeDown()
                end
                if (not success) then
                    print("Unable to place block, trying again in 5 seconds..")
                    sleep(5)
                end
            end
            turtle.select(15)
            success = false
            while (not success) do
                if (config.digDirection == 0) then
                    success = turtle.dig()
                elseif (config.digDirection == 1) then
                    success = turtle.digUp()
                else
                    success = turtle.digDown()
                end
                if (not success) then
                    print("Unable to dig block, trying again in 5 seconds..")
                    sleep(5)
                end
            end
            if (turtle.getItemCount(15) > 0) then
                powderLeft = powderLeft - turtle.getItemCount(15)
                if (config.bufferInventory == 1) then
                    turtle.dropUp()
                else
                    turtle.dropDown()
                end
                bufferInventory.pushItems(peripheral.getName(concreteInventory), 1)
            end
            powderLeft = turtle.getItemCount(16)
        end

        while (sandCount > 3 and gravelCount > 3 and dyeCount > 0) do
            sandCount = sandCount - 4
            gravelCount = gravelCount - 4
            dyeCount = dyeCount - 1
            amountMade = amountMade + 8
        end

        if (amountMade < amount) then
            print("Waiting for materials..")
            sleep(5)
        end
    end
end

-- CODE
if (not fs.exists(PROGRAM_NAME .. ".config")) then
    createConfigFile()
end
config = loadConfigFile()

if (config.bufferInventory == 1) then
    bufferInventory = peripheral.wrap("top")
else
    bufferInventory = peripheral.wrap("bottom")
end
sandInventory = peripheral.wrap(config.sandInventory)
gravelInventory = peripheral.wrap(config.gravelInventory)
dyeInventory = peripheral.wrap(config.dyeInventory)
concreteInventory = peripheral.wrap(config.concreteInventory)

while true do
    printUsageInfo()
    local input = read()
    local words = string.gmatch(input, "[^%s]+")
    local command = words()
    if (command == "exit") then
        break
    elseif (command == "construct") then
        local amount = tonumber(words())
        local dye = getDyeColor(words())
        constructConcrete(dye, amount)
    end
end