local function Tortoise()
    local NORTH = 0 -- -Z
    local EAST = 1  -- +X
    local SOUTH = 2 -- +Z
    local WEST = 3  -- -X
    local UP = 4
    local DOWN = 5
    local FUEL_BUFFER = 1

    local self = {
        ["location"]={0,0,0},
        ["direction"]=NORTH,
        ["homeLocation"]={0,0,0},
        ["homeDirection"]=NORTH,
        ["homeRefuelName"]="back",
        ["homeStoreName"]="back",
        ["refuelMax"]=turtle.getFuelLimit() * 0.9,
        ["configPath"]=".tortoise"
    }

    function self:save()
        local f = fs.open(self.configPath, "w")
        f.writeLine("location " .. self.location[1] .. " " .. self.location[2] .. " " .. self.location[3])
        f.writeLine("direction " .. self.direction)
        f.writeLine("homeLocation " .. self.homeLocation[1] .. " " .. self.homeLocation[2] .. " " .. self.homeLocation[3])
        f.writeLine("homeDirection " .. self.homeDirection)
        f.writeLine("homeRefuelName " .. self.homeRefuelName)
        f.writeLine("homeStoreName " .. self.homeStoreName)
        f.writeLine("refuelMax " .. self.refuelMax)
        f.close()
    end

    function self:load()
        local f = fs.open(self.configPath, "r")
        if not f then
            return
        end
        for line in f.readLine do
            local args = {}
            for word in string.gmatch(line, "([^%s]+)") do
                table.insert(args, word)
            end
            if args[1] == "location" then
                self.location = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
            elseif args[1] == "direction" then
                self.direction = tonumber(args[2])
            elseif args[1] == "homeLocation" then
                self.homeLocation = {tonumber(args[2]), tonumber(args[3]), tonumber(args[4])}
            elseif args[1] == "homeDirection" then
                self.homeDirection = tonumber(args[2])
            elseif args[1] == "homeRefuelName" then
                self.homeRefuelName = args[2]
            elseif args[1] == "homeStoreName" then
                self.homeStoreName = args[2]
            elseif args[1] == "refuelMax" then
                self.refuelMax = tonumber(args[2])
            end
        end
        f.close()
    end

    function self:refuel(minAmount)
        local startLevel = turtle.getFuelLevel()
        if startLevel >= minAmount then
            return true
        end
        for i = 1,16 do
            turtle.select(i)
            turtle.refuel()
        end
        return turtle.getFuelLevel() >= minAmount
    end

    function self:turnLeft()
        if turtle.turnLeft() then
            self.direction = (self.direction - 1) % 4
            self:save()
            return true
        end
        return false
    end

    function self:turnRight()
        if turtle.turnRight() then
            self.direction = (self.direction + 1) % 4
            self:save()
            return true
        end
        return false
    end

    function self:forward()
        if not turtle.forward() and not (self:refuel(FUEL_BUFFER) and turtle.forward()) then
            return false
        end
        if self.direction == NORTH then
            self.location[3] = self.location[3] - 1
        elseif self.direction == EAST then
            self.location[1] = self.location[1] + 1
        elseif self.direction == SOUTH then
            self.location[3] = self.location[3] + 1
        elseif self.direction == WEST then
            self.location[1] = self.location[1] - 1
        end
        self:save()
        return true
    end

    function self:back()
        if not turtle.back() and not (self:refuel(FUEL_BUFFER) and turtle.back()) then
            return false
        end
        if self.direction == NORTH then
            self.location[3] = self.location[3] + 1
        elseif self.direction == EAST then
            self.location[1] = self.location[1] - 1
        elseif self.direction == SOUTH then
            self.location[3] = self.location[3] - 1
        elseif self.direction == WEST then
            self.location[1] = self.location[1] + 1
        end
        self:save()
        return true
    end

    function self:up()
        if not turtle.up() and not (self:refuel(FUEL_BUFFER) and turtle.up()) then
            return false
        end
        self.location[2] = self.location[2] + 1
        self:save()
        return true
    end

    function self:down()
        if not turtle.down() and not (self:refuel(FUEL_BUFFER) and turtle.down()) then
            return false
        end
        self.location[2] = self.location[2] - 1
        self:save()
        return true
    end

    function self:setLocation(location, direction)
        self.location = table.pack(table.unpack(location))
        self.direction = direction
        self:save()
    end

    function self:setHome(location, direction, refuel, store)
        self.homeLocation = table.pack(table.unpack(location))
        self.homeDirection = direction
        self.homeRefuelName = refuel
        self.homeStoreName = store
        self:save()
    end

    function self:distanceBetween(loc1, loc2)
        return math.abs(loc1[1] - loc2[1]) + math.abs(loc1[2] - loc2[2]) + math.abs(loc1[3] - loc2[3])
    end

    function self:distanceTo(location)
        return self:distanceBetween(self.location, location)
    end

    function self:faceTo(direction)
        if (self.direction - 1) % 4 == direction then
            return self:turnLeft()
        else
            while direction ~= self.direction do
                if not self:turnRight() then
                    return false
                end
            end
            return true
        end
    end

    function self:moveTo(location)
        local xDone = location[1] == self.location[1]
        local yDone = location[2] == self.location[2]
        local zDone = location[3] == self.location[3]
        while (not xDone) or (not yDone) or (not zDone) do
            local workDone = false
            if not xDone then
                if not self:faceTo(EAST) then
                    return false
                end
                if (self.location[1] < location[1] and self:forward()) or (self.location[1] > location[1] and self:back()) then
                    workDone = true
                end
            end
            if not workDone and not yDone then
                if (self.location[2] < location[2] and self:up()) or (self.location[2] > location[2] and self:down()) then
                    workDone = true
                end
            end
            if not workDone and not zDone then
                if not self:faceTo(SOUTH) then
                    return false
                end
                if (self.location[3] < location[3] and self:forward()) or (self.location[3] > location[3] and self:back()) then
                    workDone = true
                end
            end
            if not workDone then
                return false
            end
            xDone = location[1] == self.location[1]
            yDone = location[2] == self.location[2]
            zDone = location[3] == self.location[3]
        end
        return true
    end

    function self:goHome()
        return self:moveTo(self.homeLocation) and self:faceTo(self.homeDirection)
    end

    function self:homeRefuel()
        if not self:goHome() then
            return false
        end
        if turtle.getItemCount(16) > 0 then
            return false
        end
        while turtle.getFuelLevel() < self.refuelMax and turtle.suckDown() do
            self:refuel(self.refuelMax)
        end
        if turtle.getFuelLevel() >= self.refuelMax then
            return true
        end
        local refuelStore = peripheral.wrap(self.homeRefuelName)
        if not refuelStore then
            return false
        end
        local helperStore = peripheral.wrap("bottom")
        if not helperStore then
            return false
        end
        while turtle.getFuelLevel() < self.refuelMax do
            local itemCount = 0
            for i = 1, refuelStore.size() do
                itemCount = itemCount + helperStore.pullItems(self.homeRefuelName, i)
            end
            if itemCount == 0 then
                break
            end
            while turtle.suckDown() do
                turtle.refuel(self.refuelMax)
            end
        end
        return true
    end

    function self:homeDeposit()
        if not self:goHome() then
            return false
        end
        local helperStore = peripheral.wrap("bottom")
        if not helperStore then
            return false
        end
        for i = 1,16 do
            turtle.select(i)
            if turtle.getItemCount(i) > 0 and not turtle.dropDown() then
                return false
            end
        end
        local homeStore = peripheral.wrap(self.homeStoreName)
        if not homeStore then
            return true
        end
        for i = 1, helperStore.size() do
            if (helperStore.getItemDetail(i) ~= nil) and not helperStore.pushItems(self.homeStoreName, i) then
                return true
            end
        end
        return true
    end

    function self:makeTripTo(location, allowDeposit)
        if self:refuel(self:distanceTo(location) + self:distanceBetween(location, self.homeLocation)) then
            return self:moveTo(location)
        end
        if not self:homeRefuel() then
            return false
        end
        if allowDeposit then
            self:homeDeposit()
        end
        if self:distanceTo(location) * 2 > turtle.getFuelLevel() then
            return false
        end
        return self:moveTo(location)
    end

    self:load()

    return self
end

_G.t = Tortoise()