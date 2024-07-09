---include ./UI.lua

local ui = UI(term)
local screen1 = ListScreen(TitleBar("Test Screen", colors.white, colors.blue), {})
ui.currentScreen = screen1
ui:draw()