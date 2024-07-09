---include ./TitleBar.lua

local function ListScreen(titleBar, options)
    local self = {
        ["titleBar"]=titleBar,
        ["options"]=options
    }

    function self:draw(out)
        self.titleBar.draw(out)
    end

    return self
end