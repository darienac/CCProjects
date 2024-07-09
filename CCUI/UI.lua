---include ./ListScreen.lua

local function UI(out)
    local self = {
        ["out"]=out,
        ["currentScreen"]=nil
    }

    function self:draw()
        self.currentScreen.draw(self.out)
    end

    return self
end