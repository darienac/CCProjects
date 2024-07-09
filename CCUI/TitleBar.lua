---include ./RenderTools.lua

local function TitleBar(title, fg, bg)
    local self = {
        ["title"]=title,
        ["fg"]=fg,
        ["bg"]=bg
    }

    function self:draw(out)
        local tw, th = out.getSize()
        RenderTools:drawTextBox(out, self.title, self.fg, self.bg, 1, 1, tw, 1)
    end

    return self
end