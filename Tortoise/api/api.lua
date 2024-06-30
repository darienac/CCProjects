local function Tortoise()
    local NORTH = 0 -- -Z
    local EAST = 1  -- +X
    local SOUTH = 2 -- +Z
    local WEST = 3  -- -X
    local FUEL_BUFFER = 1

    local self = {
        ["location"]={0,0,0},
        ["direction"]=NORTH
    }

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
            return true
        end
        return false
    end

    function self:turnRight()
        if turtle.turnRight() then
            self.direction = (self.direction + 1) % 4
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
        return true
    end

    function self:back()
        if not turtle.back() and not (self:refuel(FUEL_BUFFER) and turtle.forward()) then
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
        return true
    end

    function self:up()
        if not turtle.up() and not (self:refuel(FUEL_BUFFER) and turtle.up()) then
            return false
        end
        self.location[2] = self.location[2] + 1
    end

    function self:down()
        if not turtle.down() and not (self:refuel(FUEL_BUFFER) and turtle.up()) then
            return false
        end
        self.location[2] = self.location[2] - 1
    end

    function self:setLocation(location, direction)
        self.location = table.pack(table.unpack(location))
        self.direction = table.pack(table.unpack(direction))
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
                if (self.location[2] < location[2] and self:forward()) or (self.location[2] > location[2] and self:back()) then
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

    return self
end

_G.t = Tortoise()