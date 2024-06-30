local function Tortoise()
    local NORTH = 0 -- -Z
    local EAST = 1  -- +X
    local SOUTH = 2 -- +Z
    local WEST = 3  -- -X

    local self = {
        ["location"]={0,0,0},
        ["direction"]=NORTH
    }

    function self:turnLeft()
        if turtle.turnLeft() then
            self.direction = (self.direction - 1) % 4
        end
    end

    function self:turnRight()
        if turtle.turnRight() then
            self.direction = (self.direction + 1) % 4
        end
    end

    return self
end

_G.t = Tortoise()