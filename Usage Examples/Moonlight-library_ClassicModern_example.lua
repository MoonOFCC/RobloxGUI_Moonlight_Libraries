--[[
    Made For Version: Premium v11
    Updated: 10th july of 2026
]]

-- 1. Load the Library
local LibRaw = "https://raw.githubusercontent.com/MoonOFCC/RobloxGUI_First_Library/refs/heads/main/library_main.lua"
local AccioLib = loadstring(game:HttpGet(LibRaw))()

-- 2. Variables for Macros Logic
local player = game.Players.LocalPlayer
local speedEnabled = false
local jumpEnabled = false

local targetSpeed = 100
local targetJump = 92

local defaultSpeed = 16
local defaultJump = 50

-- 3. Sync Function (Ensures stats are always correct)
local function syncStats()
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        
        -- Handle Speed
        if speedEnabled then
            hum.WalkSpeed = targetSpeed
        end
        
        -- Handle Jump
        if jumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = targetJump
        end
    end
end

-- 4. Background Loop (Forces stats every frame)
task.spawn(function()
    while true do
        task.wait()
        -- We run the sync continuously to prevent game resets
        syncStats()
    end
end)

-- 5. Respawn Handler
player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    task.wait(0.3)
    syncStats()
end)

-- 6. Create the Window
local window = AccioLib:CreateWindow("Moon Hub | Premium v11")

-- 7. Create Tabs
local mainTab = window:CreateTab("Main")
local settingsTab = window:CreateTab("Settings")
local macrosTab = window:CreateTab("Macros")
local creditsTab = window:CreateTab("Credits")

-- [Main Tab Settings]
mainTab:CreateButton("Super Speed", function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 74
    end
end)

mainTab:CreateButton("Super Jump", function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.UseJumpPower = true
        hum.JumpPower = 84
    end
end)

-- CreateSlider Usage
-- Params: text, defaultToggle, callback(state, val), defaultVal, min, max, order
mainTab:CreateSlider("Dynamic Speed Controller", false, function(state, value)
    local hum = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if state then
            hum.WalkSpeed = value
        else
            hum.WalkSpeed = 16 -- Reset to default
        end
    end
    print("Toggle:", state, "| Speed:", value)
end, 16, 1, 500, 1)

-- [Settings Tab]
settingsTab:CreateLabel("--- DANGER ZONE ---", -10, Color3.fromRGB(255, 50, 50)) 

settingsTab:CreateButton("Kill Roblox", function()
    game:Shutdown()
end, Color3.fromRGB(120, 0, 0), -5) 

settingsTab:CreateLabel("--- UI SETTINGS ---", 0)
settingsTab:CreateButton("Check Version", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Moon Hub",
        Text = "Version: Premium v11.2",
        Duration = 5
    })
end, nil, 1)

-- [Macros Tab Settings]
macrosTab:CreateToggle("Speed+", false, function(state)
    speedEnabled = state
    syncStats() -- Update immediately

    if speedEnabled == false then
        task.wait(0.1)
        player.Character.Humanoid.WalkSpeed = defaultSpeed
    end
end, 1)

macrosTab:CreateToggle("Jump+", false, function(state)
    jumpEnabled = state
    syncStats() -- Update immediately

    if jumpEnabled == false then
        task.wait(0.1)
        hum.UseJumpPower = true
        hum.JumpPower = defaultJump
    end
end, 2)

-- [Credits Tab Settings]
creditsTab:CreateLabel("--- Created By ---", -10, Color3.fromRGB(178, 108, 235))
creditsTab:CreateLabel("Moon_OFCC", -9)

-- 8. Final Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Moon Hub",
    Text = "Jump Reset Fix Applied (v11.2)",
    Duration = 5
})
