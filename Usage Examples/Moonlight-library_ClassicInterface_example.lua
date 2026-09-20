--[[
    MoonLib ClassicInterface example

    Place MoonLib_ClassicInterface as a ModuleScript next to this LocalScript,
    then run this LocalScript from StarterPlayerScripts or StarterGui.

    The toggle changes the local player's movement values while enabled
    and restores the original values when disabled.
]]

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local MoonLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MoonOFCC/RobloxGUI_Moonlight_Libraries/refs/heads/main/Moonlight Classic Library/Moonlight-library_ClassicInterface.lua"))()

local Window = MoonLib:CreateWindow(
    "Player Controls",
    "rbxassetid://0" -- Replace with your own window image asset ID.
)

local PlayerTab = Window:CreateTab(
    "Player",
    "rbxassetid://0", -- Replace with your own tab image asset ID.
    1
)

local ENABLED_SPEED = 32
local ENABLED_JUMP_POWER = 75

local savedWalkSpeed
local savedJumpPower
local savedUseJumpPower
local activeHumanoid
local movementEnabled = false
local movementToggle

local function getHumanoid()
    local character = Player.Character or Player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid")
end

local function saveDefaults(humanoid)
    activeHumanoid = humanoid
    savedWalkSpeed = humanoid.WalkSpeed
    savedUseJumpPower = humanoid.UseJumpPower
    savedJumpPower = humanoid.JumpPower
end

local function applyMovement(enabled)
    local humanoid = getHumanoid()

    if humanoid ~= activeHumanoid or savedWalkSpeed == nil then
        saveDefaults(humanoid)
    end

    movementEnabled = enabled == true

    if enabled then
        humanoid.WalkSpeed = ENABLED_SPEED
        humanoid.UseJumpPower = true
        humanoid.JumpPower = ENABLED_JUMP_POWER
    else
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.UseJumpPower = savedUseJumpPower
        humanoid.JumpPower = savedJumpPower
    end
end

Player.CharacterAdded:Connect(function(character)
    activeHumanoid = character:WaitForChild("Humanoid")

    -- If the toggle is enabled when the player respawns, reapply the values.
    if movementEnabled then
        applyMovement(true)
    end
end)

movementToggle = PlayerTab:CreateToggle(
    "Speed + Jump Boost",
    false,
    function(enabled)
        applyMovement(enabled)
    end,
    1
)

PlayerTab:CreateLabel(
    "Speed: " .. tostring(ENABLED_SPEED) .. "  |  JumpPower: " .. tostring(ENABLED_JUMP_POWER),
    2
)
