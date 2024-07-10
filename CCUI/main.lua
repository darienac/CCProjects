---include ./UI.lua

local ui = UI(term)
local screen1 = ListScreen(TitleBar("Test Screen", colors.white, colors.blue), {
    ListOption("Option A", nil),
    ListOption("Option B", nil),
    ListOption("Option C", nil)
})
ui.currentScreen = screen1
ui:draw()