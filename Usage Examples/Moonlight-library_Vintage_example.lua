--[[
    VantageLib - Example usage
    ===========================================================
    Recreates the "Vantage" Home screen from the reference screenshot,
    plus a couple of extra tabs showing the new announcement system,
    the activity log and the command bar.

    HOW TO USE

    Executor (after hosting VantageLib.lua somewhere raw):

        loadstring(game:HttpGet("YOUR_VANTAGELIB_RAW_URL"))()

    Roblox Studio / legitimate:
        Save VantageLib.lua as a ModuleScript named "VantageLib",
        then in a LocalScript:

        local VantageLib = require(script.Parent.VantageLib)
        ...

    RightShift toggles the window (Change with Window:SetStateKeybind).
]]

local VantageLib = loadstring(game:HttpGet("YOUR_VANTAGELIB_RAW_URL"))()
-- local VantageLib = require(script.Parent.VantageLib)  -- Studio alternative

local Window = VantageLib:CreateWindow("Vantage")
-- Custom logo (optional, uses the drawn 2x2 grid otherwise):
-- local Window = VantageLib:CreateWindow("Vantage", "rbxassetid://YOUR_LOGO_ID")

-- Sidebar user card (bottom-left)
Window:SetUser("Moon", "Owner", nil, Color3.fromRGB(233, 196, 106))

-- =============================================
--  HOME TAB
-- =============================================
local Home = Window:CreateTab("Home", nil, 1)
Home:SetSubtitle("Server overview and recent activity")

-- Stat row (4 compact cards, like the screenshot).
-- Icons are optional: pass an "rbxassetid://..." image, any glyph
-- string like "+", or omit entirely.
local stats = Home:CreateStatRow({
    { Title = "Players",       Value = "1"    }, -- Icon = "rbxassetid://ICON_ID"
    { Title = "Server uptime", Value = "0m"   },
    { Title = "Average ping",  Value = "0 ms" },
    { Title = "Staff online",  Value = "1"    },
}, 1)

-- QUICK ACTIONS (pill buttons with glyph icons)
Home:CreateHeader("QUICK ACTIONS", nil, 2)

local activity = Home:CreateActivityLog(4)

local quickActions = Home:CreateQuickActionRow({
    {
        Text = "Announce",
        Icon = "!",
        Callback = function()
            Window:Announce("Announcement", "Server restart in 10 minutes.", "Warn")
            activity:Add("Announcement sent", Color3.fromRGB(233, 196, 106))
        end,
    },
    {
        Text = "Kick",
        Icon = "→",
        Callback = function()
            Window:Announce("Player kicked", "Target has been removed.", "Error")
            activity:Add("Kicked player", Color3.fromRGB(242, 104, 104))
        end,
    },
    {
        Text = "Ban",
        Icon = "∅",
        Callback = function()
            Window:Announce("Player banned", "Target was banned from the server.", "Error")
            activity:Add("Banned player", Color3.fromRGB(242, 104, 104))
        end,
    },
    {
        Text = "Teleport",
        Icon = "•",
        Callback = function()
            activity:Add("Teleport executed", Color3.fromRGB(138, 140, 248))
        end,
    },
    {
        Text = "Speed",
        Icon = "»",
        Callback = function()
            activity:Add("Speed boost applied", Color3.fromRGB(138, 140, 248))
        end,
    },
    {
        Text = "Heal",
        Icon = "+",
        Callback = function()
            Window:AnnounceSuccess("Healed!", "Player", 4)
            activity:Add("Heal cast", Color3.fromRGB(65, 217, 141))
        end,
    },
}, 3)

-- RECENT ACTIVITY (empty card until the first entry is added)
Home:CreateHeader("RECENT ACTIVITY", nil, 3)

-- Note: CreateActivityLog was already created above with order 4;
-- if you want it under the header instead, just re-order the numbers.

-- Live stat example: pretend uptime ticks every minute.
task.spawn(function()
    local minutes = 0
    while true do
        task.wait(60)
        minutes = minutes + 1
        stats:SetValue("Server uptime", tostring(minutes) .. "m")
    end
end)

-- =============================================
--  ANNOUNCEMENTS TAB (shows the 4 forced states)
-- =============================================
local Notify = Window:CreateTab("Notifications", nil, 2)
Notify:SetSubtitle("The 4 announcement states: Info / Success / Warn / Error")

Notify:CreateAnnouncement("Info", "This banner follows your GUI accent color. Change it with Window:SetMainColor.", "Info", 1)
Notify:CreateAnnouncement("Success", "This banner is forced green — it never follows the accent.", "Success", 2)
Notify:CreateAnnouncement("Warning", "This banner is forced yellow — it never follows the accent.", "Warn", 3)
Notify:CreateAnnouncement("Error", "This banner is forced red — it never follows the accent.", "Error", 4)

Notify:CreateHeader("TOAST DEMOS", "Floating announcements, same 4 states", 5)

Notify:CreateButton("Trigger Info toast", function()
    Window:Announce("Info", "Something noteworthy happened.", "Info")
end, nil, 6)

Notify:CreateButton("Trigger Success toast", function()
    Window:AnnounceSuccess("Everything went fine.", "Success", 4)
end, nil, 7)

Notify:CreateButton("Trigger Warn toast", function()
    Window:AnnounceWarn("This action may need attention.", "Warning", 6)
end, nil, 8)

Notify:CreateButton("Trigger Error toast (sticky)", function()
    -- duration = 0 keeps the toast until the user closes it
    Window:Announce("Something failed.", "Error", 0)
end, nil, 9)

-- =============================================
--  SETTINGS TAB (classic elements, restyled)
-- =============================================
local Settings = Window:CreateTab("Settings", nil, 3)
Settings:SetSubtitle("Favourite speed, ESP and more")

Settings:CreateToggle("Enable sprint", true, function(enabled)
    Window:AnnounceInfo("Sprint " .. (enabled and "enabled" or "disabled"))
end, 1)

Settings:CreateSlider("Walk speed", true, function(enabled, value)
    print("Sprint slider:", enabled, value)
end, 16, 16, 100, 2)

Settings:CreateDropdown("Theme accent", {
    [1] = "Indigo (default)",
    [2] = "Crimson",
    [3] = "Emerald",
    [4] = "Amber",
}, function(value, id)
    local accents = {
        [1] = Color3.fromRGB(138, 140, 248),
        [2] = Color3.fromRGB(242, 104, 104),
        [3] = Color3.fromRGB(65, 217, 141),
        [4] = Color3.fromRGB(233, 196, 106),
    }

    Window:SetMainColor(accents[id] or accents[1])
end, 3)

Settings:CreateTextbox("Broadcast message", "Type a message and press Enter...", function(text, enterPressed)
    if enterPressed and text ~= "" then
        Window:Announce("Broadcast", text, "Info")
    end
end, 4)

-- =============================================
--  COMMAND BAR (top-right pill)
-- =============================================
Window:CreateCommand("announce", function()
    Window:Announce("Maintenance", "Restart in 10 minutes.", "Warn")
end, "Broadcast a maintenance warning")

Window:CreateCommand("heal", function()
    Window:AnnounceSuccess("Healed!", "Player", 4)
end, "Heal the local player")

Window:CreateCommand("kick", function(player)
    Window:Announce("Kick", "Specify who to kick in the command.", "Error")
end, "Kick a player from the server")

Window:CreateCommand("clearlogs", function()
    activity:Clear()
end, "Clear the recent activity log")

Window:CreateCommand("ping", function()
    Window:AnnounceInfo("Pong!", "Command bar", 3)
end, "Replies with Pong")

print("[Vantage] Loaded. RightShift toggles the UI, or use the Command bar.")
