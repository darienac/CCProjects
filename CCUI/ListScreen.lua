---include ./TitleBar.lua
---include ./ListOption.lua

local function ListScreen(titleBar, options)
    local self = {
        ["titleBar"]=titleBar,
        ["options"]=options,
        ["scroll"]=0
    }

    function self:draw(out)
        self.titleBar:draw(out)
        local w, h = out.getSize()
        RenderTools:drawBox(out, colors.lightGray, w, 2, 1, h-1)
        out.setTextColor(colors.gray)
        out.setCursorPos(w, 3)
        out.write("^")
        out.setCursorPos(w, h-1)
        out.write("v")
        for i=1+scroll,h-1+scroll do
            if self.options[i] then
                local bg = 0
                local fg = 0
                if self.options[i].highlight then
                    fg = colors.black
                    bg = colors.lightGray
                else
                    fg = colors.white
                    bg = colors.gray
                end
                RenderTools:drawBox(out, bg, 1, 1+i, w-1, 1)
                out.setTextColor(fg)
                out.setCursorPos(3, 1+i)
                out.write(self.options[i].label)
            else
                RenderTools:drawBox(out, colors.black, 1, 1+i, w-1, 1)
            end
        end
    end

    return self
end