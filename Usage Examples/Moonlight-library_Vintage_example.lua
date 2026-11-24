--[[
    MoonLib - Complete feature showcase
    ===========================================================
    Paste this whole file into a LocalScript (Studio) or an executor
    script. It builds a "Moon" dashboard with every feature the
    library offers, including the new theme system and announcements.

    Announcements: Window:SetAnnounceBaseColor(true) forces every
    notification (all five states) to follow BaseColor instead of the
    type's defined color (default false). Window:SetAnnounceCustomIcon
    picks a custom image for the Custom state (default star).

    Before running, host MoonLib.lua somewhere raw and set the URL,
    or require it as a ModuleScript in Studio:

        local MoonLib = require(script.Parent.MoonLib)
]]

local MoonLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
-- local MoonLib = require(script.Parent.MoonLib) -- Studio alternative

-- Constructor theme: ONLY the keys you provide are applied.
-- Omit a key and it keeps the default.
local Window = MoonLib:CreateWindow("Moon", nil, {
    BaseColor = Color3.fromRGB(138, 140, 248), -- indigo accent (default anyway)
    -- Sidebar = Color3.fromRGB(20, 26, 38), -- Uncomment to customize one thing at a time
})

-- User card (bottom-left). Omit the call to hide it, or: Window:SetUserVisible(false)
Window:SetUser("Moon", "Owner", nil, Color3.fromRGB(233, 196, 106))
-- Window:SetDefaultSubtitle("Server overview and recent activity") -- optional: one subtitle for every tab without its own

-- =====================================================
--  HOME TAB — photo-style overview
-- =====================================================
local Home = Window:CreateTab("Home", nil, 1)
Home:SetSubtitle("Server overview and recent activity")

Home:CreateStatCard("Players", "1", nil, 1)
Home:CreateStatCard("Server uptime", "0m", nil, 2)
Home:CreateStatCard("Average ping", "0 ms", nil, 3)
Home:CreateStatCard("Staff online", "1", nil, 4)

Home:CreateHeader("PROFILE CARD", "Bottom-left of the sidebar — name, rank, presence bubble", 20)
Home:CreateButton("SetProfileName('Moon')", function()
    Window:SetProfileName("Moon")
end, nil, 21)
Home:CreateButton("SetProfileName('Traveler')", function()
    Window:SetProfileName("Traveler")
end, nil, 22)
Home:CreateButton("SetProfileRank('Owner', gold)", function()
    Window:SetProfileRank("Owner", Color3.fromRGB(233, 196, 106))
end, nil, 23)
Home:CreateButton("SetProfileRank('Admin', red)", function()
    Window:SetProfileRank("Admin", Color3.fromRGB(255, 110, 110))
end, nil, 24)
Home:CreateButton("SetPresenceColor(green)", function()
    Window:SetPresenceColor(Color3.fromRGB(65, 217, 141))
end, nil, 25)
Home:CreateButton("SetPresenceColor(red)", function()
    Window:SetPresenceColor(Color3.fromRGB(242, 104, 104))
end, nil, 26)
Home:CreateButton("SetPresenceStyle('Dot')", function()
    Window:SetPresenceStyle("Dot")
end, nil, 27)
Home:CreateButton("SetPresenceStyle('Ring')", function()
    Window:SetPresenceStyle("Ring")
end, nil, 28)
Home:CreateButton("SetPresenceStyle('Hidden')", function()
    Window:SetPresenceStyle("Hidden")
end, nil, 29)
Home:CreateButton("SetPresenceImage(asset)", function()
    -- Pass any asset id to decorate the bubble yourself; omit for the plain dot.
    Window:SetPresenceImage("rbxassetid://5936124050")
end, nil, 30)
Home:CreateButton("SetPresenceImage(nil) — clear", function()
    Window:SetPresenceImage(nil)
end, nil, 31)

Home:CreateHeader("QUICK ACTIONS", "Every button here fires an announcement", 5)
Home:CreateButton("Announce maintenance", function()
    Window:AnnounceWarn("Restart in 10 minutes.", "Maintenance", 6)
end, nil, 6)
Home:CreateButton("Broadcast to server", function()
    Window:AnnounceInfo("Welcome to the server, traveler!", "Broadcast", 5)
end, nil, 7)
Home:CreateButton("Heal everyone", function()
    Window:AnnounceSuccess("Full heal granted.", "Heal", 4)
end, nil, 8)
Home:CreateButton("Something broke", function()
    Window:AnnounceError("Storage quota reached.", "Error", 0) -- 0 = sticky
end, nil, 9)

-- =====================================================
--  CONTROLS TAB — every input element
-- =====================================================
local Controls = Window:CreateTab("Controls", nil, 2)
Controls:SetSubtitle("Toggles, sliders, textboxes and dropdowns")

Controls:CreateLabel("I'm a plain CreateLabel", 1)
Controls:CreateHeader("SECTION HEADER", "Subtitles work with CreateHeader too", 2)

Controls:CreateToggle("Enable sprint", true, function(enabled)
    print("Sprint:", enabled)
end, 3)

Controls:CreateSlider("Walk speed", true, function(enabled, value)
    print("Slider:", enabled, value)
end, 16, 16, 100, 4)

Controls:CreateTextbox("Broadcast", "Type something and press Enter...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        Window:AnnounceInfo(text, "Broadcast", 4)
    end
end, 5, nil, "")

Controls:CreateDropdown("Difficulty", {
    [1] = "Easy",
    [2] = "Normal",
    [3] = "Hard",
}, function(value, id)
    print("Difficulty:", value, "->", id)
end, 6)

Controls:CreateDropdown("Modules (multi)", {
    [1] = "Aimbot",
    [2] = "ESP",
    [3] = "Fly",
    [4] = "Speed",
    [5] = "Noclip",
}, function(values, ids)
    print("Selected", #values, "modules")
end, 7, nil, true)

-- Options can also be a function, re-evaluated every time the dropdown opens.
Controls:CreateDropdown("Live list (function)", function()
    return {
        [1] = "Tick: " .. tostring(os.time()),
        [2] = "Random: " .. tostring(math.random(1, 1000)),
    }
end, function(value, id)
    print("Live option:", value)
end, 8)

Controls:CreateInfoCard(
    "Did you know?",
    "Dropdowns accept a table or a function. Function options refresh on open.",
    nil, 9
)

-- =====================================================
--  ANNOUNCE TAB — the states (Info/Success/Warn/Error + your Custom color)
-- =====================================================
local Notify = Window:CreateTab("Announce", nil, 3)
Notify:SetSubtitle("Info = accent | Success = green | Warn = yellow | Error = red | Custom = your color")

Notify:CreateAnnouncement("Info", "This banner follows your accent color (BaseColor). Try a theme below.", "Info", 1)
Notify:CreateAnnouncement("Success", "This banner is forced green — themes cannot change it.", "Success", 2)
Notify:CreateAnnouncement("Warning", "This banner is forced yellow — themes cannot change it.", "Warn", 3)
Notify:CreateAnnouncement("Error", "This banner is forced red — themes cannot change it.", "Error", 4)
Notify:CreateAnnouncement("Custom", "This banner uses the color you passed to it (pink here).", "Custom", 5, Color3.fromRGB(255, 105, 180))

Notify:CreateButton("Toast: Info", function()
    Window:Announce("Info", "Something noteworthy happened.", "Info", 5)
end, nil, 6)
Notify:CreateButton("Toast: Success", function()
    Window:AnnounceSuccess("Everything went fine.", "Success", 4)
end, nil, 7)
Notify:CreateButton("Toast: Warn", function()
    Window:AnnounceWarn("Double-check your settings.", "Warning", 6)
end, nil, 8)
Notify:CreateButton("Toast: Error (sticky)", function()
    -- Error is sticky by default; pass 0 explicitly or omit the duration.
    Window:AnnounceError("This one stays until you close it.", "Error")
end, nil, 9)
Notify:CreateButton("Toast: Error (10s timer)", function()
    -- ...but pass a duration and it times out with a timer like the others.
    Window:AnnounceError("This one hides after 10 seconds.", "Error", 10)
end, nil, 10)
Notify:CreateButton("Toast: Custom (pink)", function()
    -- Custom takes a color argument: Window:AnnounceCustom(msg, title, color, duration)
    Window:AnnounceCustom("Custom accent, your rules.", "Custom", Color3.fromRGB(255, 105, 180), 5)
end, nil, 11)
Notify:CreateButton("Toast: Custom (cyan, sticky)", function()
    Window:AnnounceCustom("Sticky, and cyan.", "Custom", Color3.fromRGB(94, 234, 212), 0)
end, nil, 12)

-- Notification color mode (default OFF = each type keeps its color).
-- Flip it ON to make EVERY notification follow BaseColor instead.
local forceBaseColor = false
local baseColorToggle
baseColorToggle = Notify:CreateButton("Toggle: notifications follow BaseColor (currently OFF)", function()
    forceBaseColor = not forceBaseColor
    Window:SetAnnounceBaseColor(forceBaseColor)
    -- Existing in-page banners refresh instantly; toasts pick it up on next show.
    baseColorToggle.Text = forceBaseColor
        and "Toggle: notifications follow BaseColor (currently ON)"
        or "Toggle: notifications follow BaseColor (currently OFF)"
end, nil, 13)

-- Custom-type icon: default is a star. Pass your own image to replace it.
local customIconSet = false
local iconToggle
iconToggle = Notify:CreateButton("Toggle: Custom icon = star / custom image (currently star)", function()
    customIconSet = not customIconSet
    Window:SetAnnounceCustomIcon(customIconSet and "rbxassetid://5936124050" or nil)
    iconToggle.Text = customIconSet
        and "Toggle: Custom icon = star / custom image (currently custom)"
        or "Toggle: Custom icon = star / custom image (currently star)"
end, nil, 14)

Notify:CreateButton("Toast: Custom (uses your icon setting)", function()
    -- The window's SetAnnounceCustomIcon applies here automatically:
    -- star by default, your image once you flip the toggle above.
    Window:AnnounceCustom("Same call, icon comes from the setting.", "Custom", Color3.fromRGB(255, 105, 180), 5)
end, nil, 15)

Notify:CreateAnnouncement(
    "Icon demo",
    "This banner uses a custom icon image instead of a glyph.",
    "Custom", 16, Color3.fromRGB(255, 105, 180),
    "rbxassetid://5936124050" -- per-banner icon override (:SetIcon(nil) resets to the window default)
)

-- =====================================================
--  THEMES TAB — the new custom theme system
-- =====================================================
local Themes = Window:CreateTab("Themes", nil, 4)
Themes:SetSubtitle("Change one key or the whole look — the rest stays untouched")
local dividerFlipped = false

Themes:CreateHeader("BUILT-IN PRESETS", "Registered out of the box", 1)
for _, preset in ipairs({ "Vantage", "Ocean", "Crimson", "Emerald", "Gold" }) do
    Themes:CreateButton("Apply preset: " .. preset, function()
        Window:ThemeLoad(preset)
    end, nil, 10)
end

Themes:CreateButton("SetDividerColor(vivid) / Reset", function()
    -- The segment separator lines (sidebar divider, header divider) are
    -- theme-driven. One-key setter, like every other surface color.
    dividerFlipped = not dividerFlipped
    Window:SetDividerColor(dividerFlipped and Color3.fromRGB(138, 140, 248) or Color3.fromRGB(46, 56, 83))
end, nil, 15)

Themes:CreateHeader("REGISTER CUSTOM THEMES", "Register once, load anywhere, anytime", 20)

Themes:CreateButton("Register/overwrite + apply 'Midnight'", function()
    -- Re-registering "Midnight" REPLACES the old snapshot — no duplicates,
    -- the registry never holds more than one entry per name.
    MoonLib:RegisterTheme("Midnight", {
        MainBackground = Color3.fromRGB(12, 12, 18),
        Sidebar = Color3.fromRGB(15, 15, 24),
        Card = Color3.fromRGB(22, 22, 34),
        Panel = Color3.fromRGB(22, 22, 34),
        PanelLight = Color3.fromRGB(30, 30, 46),
        CardHover = Color3.fromRGB(30, 30, 46),
        Input = Color3.fromRGB(18, 18, 28),
        BaseColor = Color3.fromRGB(178, 140, 255),
        TabActiveColor = Color3.fromRGB(34, 30, 54),
        TabsStrokeColor = Color3.fromRGB(120, 100, 180),
        Border = Color3.fromRGB(44, 40, 66),
        BrightBorder = Color3.fromRGB(90, 80, 130),
    })

    Window:ThemeLoad("Midnight")
    Window:AnnounceSuccess("Theme 'Midnight' registered and applied.", "Themes", 4)
end, nil, 21)

Themes:CreateButton("Save CURRENT theme as 'MyTheme'", function()
    Window:ThemeSave("MyTheme")
    Window:AnnounceSuccess("Saved. Window:ThemeLoad('MyTheme') restores it.", "Themes", 5)
end, nil, 22)

Themes:CreateButton("Load 'MyTheme'", function()
    if not Window:ThemeLoad("MyTheme") then
        Window:AnnounceWarn("Save the theme first with the button above.", "Themes", 4)
    end
end, nil, 23)

Themes:CreateButton("List registered themes", function()
    local names = MoonLib:GetRegisteredThemes()
    local joined = table.concat(names, ", ")

    print("Registered themes:", joined)
    Window:AnnounceInfo(joined, "Registered themes", 6)
end, nil, 24)

Themes:CreateHeader("PARTIAL THEMES", "Only the keys you provide change", 30)

Themes:CreateButton("Accent only (background stays!)", function()
    Window:SetTheme({ BaseColor = Color3.fromRGB(255, 120, 200) })
    -- Cards, sidebar, text, background... all stay exactly as they are.
end, nil, 31)

Themes:CreateButton("Background image only", function()
    Window:SetTheme({
        BackgroundImage = "rbxassetid://5936124050", -- any wallpaper asset; omit if you have none
        BackgroundImageTransparency = 0.55,
    })
    -- Colors, fonts, corners: untouched. Only the background changed.
end, nil, 32)

Themes:CreateButton("Tab strokes only", function()
    Window:SetTheme({
        TabsStrokeColor = Color3.fromRGB(255, 214, 90),
        TabStrokeThickness = 2,
        TabStrokeTransparency = 0,
    })
end, nil, 33)

Themes:CreateButton("Font + corners only", function()
    Window:SetTheme({
        Font = Enum.Font.Gotham, -- or { Regular = ..., Bold = ... }
        CornerRadius = 16,
    })
end, nil, 34)

Themes:CreateButton("Full background config (sprite sheet)", function()
    Window:SetBackground({
        Image = "rbxassetid://5936124050",
        Rows = 1,
        Columns = 1,
        FrameCount = 1,
        FrameRate = 12,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Crop,
    })
end, nil, 35)

Themes:CreateButton("Reset background (solid)", function()
    Window:SetTheme({ Background = Color3.fromRGB(16, 23, 40) })
end, nil, 36)

Themes:CreateHeader("TAB TRANSITION", "Fade = top-to-bottom fade | Drop-In = slide in from the left | Pop = spring into size | None = off", 37)

Themes:CreateButton("SetTabTransition('Fade')", function()
    Window:SetTabTransition("Fade")
end, nil, 38)
Themes:CreateButton("SetTabTransition('Drop-In')", function()
    Window:SetTabTransition("Drop-In")
end, nil, 39)
Themes:CreateButton("SetTabTransition('Pop')", function()
    Window:SetTabTransition("Pop")
end, nil, 40)
Themes:CreateButton("SetTabTransition('None')", function()
    Window:SetTabTransition("None")
end, nil, 41)

Themes:CreateHeader("INDIVIDUAL SETTERS", "Same power, one key per call", 42)

Themes:CreateButton("SetCornerRadius(4) — sharp", function()
    Window:SetCornerRadius(4)
end, nil, 43)
Themes:CreateButton("SetCornerRadius(18) — round", function()
    Window:SetCornerRadius(18)
end, nil, 44)
Themes:CreateButton("SetTabsStrokeColor(red)", function()
    Window:SetTabsStrokeColor(Color3.fromRGB(255, 90, 90))
end, nil, 45)
Themes:CreateButton("SetSecondaryColor(teal)", function()
    -- On-state switches, textbox backgrounds and slider rails.
    Window:SetSecondaryColor(Color3.fromRGB(94, 234, 212))
end, nil, 46)
Themes:CreateButton("SetTabActiveColor(deep blue)", function()
    Window:SetTabActiveColor(Color3.fromRGB(20, 40, 80))
end, nil, 47)
Themes:CreateButton("SetSecondaryColor(reset)", function()
    Window:SetSecondaryColor(Color3.fromRGB(40, 50, 77))
end, nil, 48)
Themes:CreateButton("SetFont(Gotham)", function()
    Window:SetFont(Enum.Font.Gotham)
end, nil, 49)
Themes:CreateButton("SetElementStrokeColor(gold)", function()
    -- Strokes of buttons & elements inside tabs (cards, dropdowns...).
    Window:SetElementStrokeColor(Color3.fromRGB(233, 196, 106))
end, nil, 50)
Themes:CreateButton("SetFont(Code)", function()
    Window:SetFont(Enum.Font.Code)
end, nil, 51)
Themes:CreateButton("SetElementStrokeColor(reset)", function()
    Window:SetElementStrokeColor(Color3.fromRGB(63, 76, 111))
end, nil, 52)
Themes:CreateButton("BackgroundImageTransparency(0.7)", function()
    Window:SetBackgroundImageTransparency(0.7)
end, nil, 53)
Themes:CreateButton("SetTabStrokeThickness(0) — hide stroke", function()
    Window:SetTabStrokeThickness(0)
end, nil, 54)
Themes:CreateButton("SetTabStrokeThickness(1) — thin", function()
    Window:SetTabStrokeThickness(1)
end, nil, 55)

Themes:CreateHeader("GETTERS", "Everything is readable too", 56)
Themes:CreateButton("Print current theme", function()
    local theme = Window:GetTheme()

    for key, value in pairs(theme) do
        print(("theme.%s = %s"):format(tostring(key), tostring(value)))
    end

    Window:AnnounceInfo("Dumped the theme to the output console.", "GetTheme", 4)
end, nil, 57)

print("[MoonLib demo] Loaded. RightShift toggles the UI.")
