--[[
    MoonLib ClassicInterface example

    An Example code of how to use this Classic Interface Library
]]

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local MoonLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MoonOFCC/RobloxGUI_Moonlight_Libraries/refs/heads/main/Moonlight%20Classic%20Library/Moonlight-Library_ClassicInterface_V2.lua"
))()

local Window = MoonLib:CreateWindow(
    "Player Controls"
)

local Theme = Window.Theme

local PlayerTab = Window:CreateTab(
    "Player",
    nil,
    1
)

local ENABLED_WALK_SPEED = 32
local ENABLED_JUMP_POWER = 75

local movementEnabled = false
local selectedSpeed = ENABLED_WALK_SPEED

local savedValues = {}
local activeHumanoid

local function getHumanoid()
    local character = Player.Character
        or Player.CharacterAdded:Wait()

    return character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid")
end

local function saveOriginalValues(humanoid)
    if savedValues[humanoid] then
        return
    end

    savedValues[humanoid] = {
        WalkSpeed = humanoid.WalkSpeed,
        JumpPower = humanoid.JumpPower,
        UseJumpPower = humanoid.UseJumpPower,
    }
end

local function applyMovement(enabled)
    local humanoid = getHumanoid()

    if humanoid ~= activeHumanoid then
        activeHumanoid = humanoid
        saveOriginalValues(humanoid)
    end

    movementEnabled = enabled == true

    if movementEnabled then
        humanoid.WalkSpeed = selectedSpeed
        humanoid.UseJumpPower = true
        humanoid.JumpPower = ENABLED_JUMP_POWER
    else
        local original = savedValues[humanoid]

        if original then
            humanoid.WalkSpeed = original.WalkSpeed
            humanoid.JumpPower = original.JumpPower
            humanoid.UseJumpPower = original.UseJumpPower
        end
    end
end

PlayerTab:CreateHeader(
    "Player Settings",
    "Adjust your movement options",
    1
)

PlayerTab:CreateInfoCard(
    "Movement",
    "Customize your character's movement values.",
    Theme.Blue,
    2
)

local MovementToggle = PlayerTab:CreateToggle(
    "Speed + Jump Boost",
    false,
    function(enabled)
        applyMovement(enabled)
    end,
    3
)

local SpeedSlider = PlayerTab:CreateSlider(
    "WalkSpeed",
    false,
    function(_, value)
        selectedSpeed = value

        if movementEnabled then
            local humanoid = getHumanoid()
            humanoid.WalkSpeed = selectedSpeed
            humanoid.JumpPower = ENABLED_JUMP_POWER
            humanoid.UseJumpPower = true
        end
    end,
    ENABLED_WALK_SPEED,
    16,
    100,
    4
)

PlayerTab:CreateLabel(
    "JumpPower: " .. tostring(ENABLED_JUMP_POWER),
    5
)

PlayerTab:CreateButton(
    "Reset Movement",
    function()
        movementEnabled = false

        if MovementToggle then
            MovementToggle:SetValue(false)
        end

        local humanoid = getHumanoid()
        local original = savedValues[humanoid]

        if original then
            humanoid.WalkSpeed = original.WalkSpeed
            humanoid.JumpPower = original.JumpPower
            humanoid.UseJumpPower = original.UseJumpPower
        end
    end,
    Theme.Red,
    6
)

PlayerTab:CreateDropdown(
    "Movement Mode",
    {
        [1] = "Normal",
        [2] = "Fast",
        [3] = "Extreme",
    },
    function(name)
        if name == "Normal" then
            selectedSpeed = 16
        elseif name == "Fast" then
            selectedSpeed = 32
        elseif name == "Extreme" then
            selectedSpeed = 100
        end

        if SpeedSlider then
            SpeedSlider:SetValue(selectedSpeed)
        end

        if movementEnabled then
            applyMovement(true)
        end
    end,
    7
)

Player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")

    activeHumanoid = humanoid
    saveOriginalValues(humanoid)

    if movementEnabled then
        task.wait(0.25)
        applyMovement(true)
    end
end)

print("[MoonLib] Player controls loaded successfully")
