local RenderTools = {}

function RenderTools:drawBox(out, color, x, y, w, h)
    out.setBackgroundColor(color)
    for i = y, y+h-1 do
        out.setCursorPos(x, i)
        out.write(string.rep(" ", w))
    end
end

function RenderTools:drawTextBox(out, text, fg, bg, x, y, w, h)
    RenderTools:drawBox(out, bg, x, y, w, h)
    out.setTextColor(fg)
    out.setCursorPos(x + math.floor((w - #text) / 2), y + math.floor(h / 2))
    out.write(text)
end