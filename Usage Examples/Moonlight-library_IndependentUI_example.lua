-- Example LocalScript. Put MoonUI.lua in a ModuleScript named "MoonUI"
-- beside this LocalScript, or update the require path as appropriate.

local MoonUI = require(script.Parent:WaitForChild("MoonUI"))

local window = MoonUI:CreateWindow("My Experience", {
    Width = 680,
    Height = 440,
    ToggleKey = Enum.KeyCode.RightShift,
})

local home = window:CreateTab("Home")
home:CreateLabel("Welcome — add your experience controls here")
home:CreateButton("Print message", function()
    print("Button pressed")
end)
home:CreateToggle("Example toggle", false, function(enabled)
    print("Enabled:", enabled)
end)
home:CreateSlider("Volume", 50, 0, 100, function(value)
    print("Volume:", value)
end, nil, 5) -- final optional argument is the step size

local settings = window:CreateTab("Settings")
settings:CreateDropdown("Quality", {"Low", "Medium", "High"}, function(value, key)
    print("Quality:", value, "key:", key)
end)
settings:CreateTextbox("Player note", "Write something…", function(value, submitted)
    if submitted then print("Submitted:", value) end
end)

-- Floating windows are separate panels: they can be dragged, hidden, and closed
-- without hiding the main window. They share the same ScreenGui and UI controls.
local monitor = window:CreateFloatingWindow("Independent monitor", {
    Width = 360,
    Height = 270,
    Position = UDim2.new(0.75, 0, 0.55, 0),
})
local monitorTab = monitor:CreateTab("Live")
monitorTab:CreateLabel("This panel moves independently.")
monitorTab:CreateToggle("Monitor enabled", true, function(enabled)
    print("Monitor enabled:", enabled)
end)
monitorTab:CreateSlider("Threshold", 25, 0, 100, function(value)
    print("Threshold:", value)
end)

-- Programmatic control examples:
-- monitor:SetVisible(false)
-- monitor:SetVisible(true)
-- monitor:SetPosition(UDim2.new(0.5, 0, 0.5, 0))
-- window:SetVisible(false) -- hides only the main panel, not floating panels
-- window:Destroy()         -- destroys all panels and disconnects the key listener
