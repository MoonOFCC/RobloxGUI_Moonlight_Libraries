--[[
    MoonLib - v14

    Features:
    - Smooth draggable GUI
    - Close and minimize buttons
    - RightShift visibility toggle
    - Tabs
    - Buttons
    - Toggles
    - Sliders
    - Dropdowns
    - Manual LayoutOrder support
    - Optional custom background colors
    - Automatic black/white text contrast
]]

local MoonLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Determines whether a color is bright enough for black text.
local function isColorBright(color)
    local luminance =
        (0.299 * color.R) +
        (0.587 * color.G) +
        (0.114 * color.B)

    return luminance > 0.5
end

local function getTextColor(backgroundColor)
    if isColorBright(backgroundColor) then
        return Color3.fromRGB(0, 0, 0)
    end

    return Color3.fromRGB(230, 230, 230)
end

local function getHoverColor(backgroundColor)
    if isColorBright(backgroundColor) then
        return backgroundColor:Lerp(Color3.fromRGB(0, 0, 0), 0.08)
    end

    return backgroundColor:Lerp(Color3.fromRGB(255, 255, 255), 0.08)
end

local function getOptionColor(backgroundColor)
    if isColorBright(backgroundColor) then
        return backgroundColor:Lerp(Color3.fromRGB(0, 0, 0), 0.04)
    end

    return backgroundColor:Lerp(Color3.fromRGB(255, 255, 255), 0.04)
end

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

function MoonLib:CreateWindow(title)
    local Window = {}

    local ui_toggled = true
    local is_destroyed = false

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoonLib_v14"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.ClipsDescendants = true

    addCorner(MainFrame, 8)

    -- Top bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.ZIndex = 2

    addCorner(TopBar, 8)

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TopBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title or "Moon Library"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.RichText = true
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3

    -- Top bar buttons
    local Buttons = Instance.new("Frame")
    Buttons.Name = "WindowButtons"
    Buttons.Parent = TopBar
    Buttons.BackgroundTransparency = 1
    Buttons.Position = UDim2.new(1, -75, 0, 0)
    Buttons.Size = UDim2.new(0, 70, 1, 0)
    Buttons.ZIndex = 10

    local function createTopButton(text, color, position)
        local button = Instance.new("TextButton")
        button.Parent = Buttons
        button.BackgroundTransparency = 1
        button.Position = position
        button.Size = UDim2.new(0, 30, 1, 0)
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = color
        button.TextSize = 24
        button.AutoButtonColor = false
        button.ZIndex = 11

        return button
    end

    local CloseButton = createTopButton(
        "×",
        Color3.fromRGB(255, 80, 80),
        UDim2.new(0, 35, 0, 0)
    )

    local MinimizeButton = createTopButton(
        "−",
        Color3.fromRGB(200, 200, 200),
        UDim2.new(0, 0, 0, 0)
    )

    -- Permanently destroy the UI
    CloseButton.MouseButton1Click:Connect(function()
        is_destroyed = true
        ScreenGui:Destroy()
    end)

    -- Hide/show the UI
    local function toggleUI()
        if is_destroyed then
            return
        end

        ui_toggled = not ui_toggled
        MainFrame.Visible = ui_toggled
    end

    MinimizeButton.MouseButton1Click:Connect(toggleUI)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            toggleUI()
        end
    end)

    -- Smooth dragging
    local dragging = false
    local dragStart
    local startPos

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and not is_destroyed then
            local mouse = UserInputService:GetMouseLocation()

            local targetPosition = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + (mouse.X - dragStart.X),
                startPos.Y.Scale,
                startPos.Y.Offset + (mouse.Y - dragStart.Y) - 36
            )

            MainFrame.Position = MainFrame.Position:Lerp(targetPosition, 0.1)
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.ZIndex = 1

    addCorner(Sidebar, 8)

    -- Tab container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 5)
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    -- Content area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 155, 0, 45)
    ContentArea.Size = UDim2.new(1, -160, 1, -50)

    local currentTab = nil

    function Window:CreateTab(name)
        local Tab = {}

        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tostring(name) .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, -14, 0, 40)
        TabButton.Text = tostring(name)
        TabButton.TextColor3 = Color3.fromRGB(160, 160, 160)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.TextSize = 18
        TabButton.RichText = true
        TabButton.TextXAlignment = Enum.TextXAlignment.Center
        TabButton.AutoButtonColor = false

        addCorner(TabButton, 6)

        -- Tab page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tostring(name) .. "Page"
        Page.Parent = ContentArea
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ClipsDescendants = true

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 7)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function selectTab()
            if currentTab then
                currentTab.Button.TextColor3 = Color3.fromRGB(160, 160, 160)
                currentTab.Button.BackgroundTransparency = 1
                currentTab.Page.Visible = false
            end

            currentTab = {
                Button = TabButton,
                Page = Page
            }

            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundTransparency = 0
            Page.Visible = true
        end

        TabButton.MouseButton1Click:Connect(selectTab)

        if not currentTab then
            selectTab()
        end

        -- Label
        function Tab:CreateLabel(text, order, color)
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Parent = Page
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, -10, 0, 25)
            Label.Font = Enum.Font.GothamBold
            Label.Text = tostring(text)
            Label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            Label.TextSize = 16
            Label.RichText = true
            Label.TextXAlignment = Enum.TextXAlignment.Center
            Label.LayoutOrder = order or 0

            return Label
        end

        -- Button
        function Tab:CreateButton(text, callback, customColor, order)
            local baseColor = customColor or Color3.fromRGB(45, 45, 45)
            local textColor = getTextColor(baseColor)
            local hoverColor = getHoverColor(baseColor)

            local Button = Instance.new("TextButton")
            Button.Name = tostring(text) .. "Button"
            Button.Parent = Page
            Button.BackgroundColor3 = baseColor
            Button.BorderSizePixel = 0
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.Font = Enum.Font.GothamBold
            Button.Text = tostring(text)
            Button.TextColor3 = textColor
            Button.TextSize = 16
            Button.LayoutOrder = order or 0
            Button.AutoButtonColor = false

            addCorner(Button, 6)

            Button.MouseEnter:Connect(function()
                TweenService:Create(
                    Button,
                    TweenInfo.new(0.2),
                    {
                        BackgroundColor3 = hoverColor
                    }
                ):Play()
            end)

            Button.MouseLeave:Connect(function()
                TweenService:Create(
                    Button,
                    TweenInfo.new(0.2),
                    {
                        BackgroundColor3 = baseColor
                    }
                ):Play()
            end)

            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return Button
        end

        -- Toggle
        function Tab:CreateToggle(text, default, callback, order, customColor)
            local Toggled = default or false
            local baseColor = customColor or Color3.fromRGB(45, 45, 45)
            local textColor = getTextColor(baseColor)

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = tostring(text) .. "Toggle"
            ToggleFrame.Parent = Page
            ToggleFrame.BackgroundColor3 = baseColor
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.LayoutOrder = order or 0

            addCorner(ToggleFrame, 6)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Text = tostring(text)
            ToggleLabel.TextColor3 = textColor
            ToggleLabel.TextSize = 15
            ToggleLabel.Font = Enum.Font.GothamBold
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Name = "Switch"
            SwitchBG.Parent = ToggleFrame
            SwitchBG.BackgroundColor3 = Toggled
                and Color3.fromRGB(0, 170, 255)
                or Color3.fromRGB(60, 60, 60)
            SwitchBG.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchBG.Size = UDim2.new(0, 40, 0, 20)

            addCorner(SwitchBG, 20)

            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Parent = SwitchBG
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Position = Toggled
                and UDim2.new(1, -18, 0, 2)
                or UDim2.new(0, 2, 0, 2)
            Knob.Size = UDim2.new(0, 16, 0, 16)

            addCorner(Knob, 20)

            local Click = Instance.new("TextButton")
            Click.Name = "ClickRegion"
            Click.Parent = ToggleFrame
            Click.BackgroundTransparency = 1
            Click.Size = UDim2.new(1, 0, 1, 0)
            Click.Text = ""

            Click.MouseButton1Click:Connect(function()
                Toggled = not Toggled

                SwitchBG.BackgroundColor3 = Toggled
                    and Color3.fromRGB(0, 170, 255)
                    or Color3.fromRGB(60, 60, 60)

                Knob.Position = Toggled
                    and UDim2.new(1, -18, 0, 2)
                    or UDim2.new(0, 2, 0, 2)

                if callback then
                    callback(Toggled)
                end
            end)

            return ToggleFrame
        end

        -- Slider
        function Tab:CreateSlider(
            text,
            defaultState,
            callback,
            defaultVal,
            min,
            max,
            order,
            customColor
        )
            min = tonumber(min) or 0
            max = tonumber(max) or 100

            if max < min then
                min, max = max, min
            end

            if max == min then
                max = min + 1
            end

            local Toggled = defaultState or false
            local CurrentValue = tonumber(defaultVal) or min
            CurrentValue = math.clamp(CurrentValue, min, max)

            local baseColor = customColor or Color3.fromRGB(45, 45, 45)
            local textColor = getTextColor(baseColor)
            local brightBackground = isColorBright(baseColor)

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = tostring(text) .. "Slider"
            SliderFrame.Parent = Page
            SliderFrame.BackgroundColor3 = baseColor
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Size = UDim2.new(1, -10, 0, 65)
            SliderFrame.LayoutOrder = order or 0

            addCorner(SliderFrame, 6)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = SliderFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 15, 0, 5)
            ToggleLabel.Size = UDim2.new(1, -100, 0, 30)
            ToggleLabel.Text = tostring(text)
            ToggleLabel.TextColor3 = textColor
            ToggleLabel.TextSize = 15
            ToggleLabel.Font = Enum.Font.GothamBold
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local SwitchBG = Instance.new("Frame")
            SwitchBG.Name = "Switch"
            SwitchBG.Parent = SliderFrame
            SwitchBG.BackgroundColor3 = Toggled
                and Color3.fromRGB(0, 170, 255)
                or Color3.fromRGB(60, 60, 60)
            SwitchBG.Position = UDim2.new(1, -50, 0, 10)
            SwitchBG.Size = UDim2.new(0, 40, 0, 20)

            addCorner(SwitchBG, 20)

            local Knob = Instance.new("Frame")
            Knob.Name = "Knob"
            Knob.Parent = SwitchBG
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Position = Toggled
                and UDim2.new(1, -18, 0, 2)
                or UDim2.new(0, 2, 0, 2)
            Knob.Size = UDim2.new(0, 16, 0, 16)

            addCorner(Knob, 20)

            local sliderRatio = (CurrentValue - min) / (max - min)

            local SliderBack = Instance.new("Frame")
            SliderBack.Name = "SliderBack"
            SliderBack.Parent = SliderFrame
            SliderBack.BackgroundColor3 = brightBackground
                and Color3.fromRGB(0, 0, 0)
                or Color3.fromRGB(60, 60, 60)
            SliderBack.BackgroundTransparency = 0.5
            SliderBack.Position = UDim2.new(0, 15, 0, 45)
            SliderBack.Size = UDim2.new(1, -80, 0, 6)

            addCorner(SliderBack, 6)

            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Parent = SliderBack
            SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SliderFill.Size = UDim2.new(sliderRatio, 0, 1, 0)

            addCorner(SliderFill, 6)

            local SliderKnob = Instance.new("Frame")
            SliderKnob.Name = "Knob"
            SliderKnob.Parent = SliderBack
            SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderKnob.Position = UDim2.new(sliderRatio, -6, 0.5, -6)
            SliderKnob.Size = UDim2.new(0, 12, 0, 12)

            addCorner(SliderKnob, 12)

            local ValueDisplay = Instance.new("TextLabel")
            ValueDisplay.Name = "Value"
            ValueDisplay.Parent = SliderFrame
            ValueDisplay.BackgroundTransparency = 1
            ValueDisplay.Position = UDim2.new(1, -60, 0, 33)
            ValueDisplay.Size = UDim2.new(0, 50, 0, 30)
            ValueDisplay.Font = Enum.Font.GothamBold
            ValueDisplay.Text = tostring(CurrentValue)
            ValueDisplay.TextColor3 = textColor
            ValueDisplay.TextSize = 14
            ValueDisplay.TextXAlignment = Enum.TextXAlignment.Center

            local function updateSlider(input)
                local sliderWidth = SliderBack.AbsoluteSize.X

                if sliderWidth <= 0 then
                    return
                end

                local position = math.clamp(
                    (input.Position.X - SliderBack.AbsolutePosition.X) / sliderWidth,
                    0,
                    1
                )

                CurrentValue = math.floor(min + ((max - min) * position))
                CurrentValue = math.clamp(CurrentValue, min, max)

                SliderFill.Size = UDim2.new(position, 0, 1, 0)
                SliderKnob.Position = UDim2.new(position, -6, 0.5, -6)
                ValueDisplay.Text = tostring(CurrentValue)

                if callback then
                    callback(Toggled, CurrentValue)
                end
            end

            local sliderMoveConnection
            local sliderEndConnection

            local function stopSliderDrag()
                if sliderMoveConnection then
                    sliderMoveConnection:Disconnect()
                    sliderMoveConnection = nil
                end

                if sliderEndConnection then
                    sliderEndConnection:Disconnect()
                    sliderEndConnection = nil
                end
            end

            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                updateSlider(input)

                stopSliderDrag()

                sliderMoveConnection = UserInputService.InputChanged:Connect(function(changedInput)
                    if changedInput.UserInputType == Enum.UserInputType.MouseMovement
                        or changedInput.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(changedInput)
                    end
                end)

                sliderEndConnection = UserInputService.InputEnded:Connect(function(endedInput)
                    if endedInput.UserInputType == Enum.UserInputType.MouseButton1
                        or endedInput.UserInputType == Enum.UserInputType.Touch then
                        stopSliderDrag()
                    end
                end)
            end)

            local Click = Instance.new("TextButton")
            Click.Name = "ToggleRegion"
            Click.Parent = SliderFrame
            Click.BackgroundTransparency = 1
            Click.Position = UDim2.new(0, 0, 0, 0)
            Click.Size = UDim2.new(1, 0, 0, 40)
            Click.Text = ""

            Click.MouseButton1Click:Connect(function()
                Toggled = not Toggled

                SwitchBG.BackgroundColor3 = Toggled
                    and Color3.fromRGB(0, 170, 255)
                    or Color3.fromRGB(60, 60, 60)

                Knob.Position = Toggled
                    and UDim2.new(1, -18, 0, 2)
                    or UDim2.new(0, 2, 0, 2)

                if callback then
                    callback(Toggled, CurrentValue)
                end
            end)

            return SliderFrame
        end

        -- Dropdown
        --
        -- Parameters:
        -- CreateDropdown(text, options, callback, order, customColor)
        --
        -- The values inside options must be strings.
        -- Numeric keys are sorted numerically, so tables such as
        -- {[97] = "Aperture", [98] = "NEXUS"} work correctly.
        function Tab:CreateDropdown(
            text,
            options,
            callback,
            order,
            customColor
        )
            assert(
                type(options) == "table",
                "CreateDropdown options must be a table"
            )

            local sortedOptions = {}

            for key, value in pairs(options) do
                if type(value) == "string" then
                    table.insert(sortedOptions, {
                        key = key,
                        value = value
                    })
                else
                    warn(
                        "MoonLib CreateDropdown skipped non-string option at key:",
                        key
                    )
                end
            end

            table.sort(sortedOptions, function(a, b)
                if type(a.key) == "number" and type(b.key) == "number" then
                    return a.key < b.key
                end

                return tostring(a.key) < tostring(b.key)
            end)

            local validOptions = {}

            for _, entry in ipairs(sortedOptions) do
                table.insert(validOptions, entry.value)
            end

            local baseColor = customColor or Color3.fromRGB(45, 45, 45)
            local textColor = getTextColor(baseColor)
            local hoverColor = getHoverColor(baseColor)
            local optionColor = getOptionColor(baseColor)

            local selectedValue = nil
            local isOpen = false

            local headerHeight = 35
            local optionsTopOffset = 40
            local optionHeight = 30
            local optionPadding = 4

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = tostring(text) .. "Dropdown"
            DropdownFrame.Parent = Page
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Size = UDim2.new(1, -10, 0, headerHeight)
            DropdownFrame.LayoutOrder = order or 0
            DropdownFrame.ClipsDescendants = false
            DropdownFrame.ZIndex = 3

            local Header = Instance.new("TextButton")
            Header.Name = "Header"
            Header.Parent = DropdownFrame
            Header.BackgroundColor3 = baseColor
            Header.BorderSizePixel = 0
            Header.Size = UDim2.new(1, 0, 0, headerHeight)
            Header.AutoButtonColor = false
            Header.Text = ""
            Header.ZIndex = 5

            addCorner(Header, 6)

            local TitleText = Instance.new("TextLabel")
            TitleText.Name = "Title"
            TitleText.Parent = Header
            TitleText.BackgroundTransparency = 1
            TitleText.Position = UDim2.new(0, 15, 0, 0)
            TitleText.Size = UDim2.new(0.45, 0, 1, 0)
            TitleText.Font = Enum.Font.GothamBold
            TitleText.Text = tostring(text)
            TitleText.TextColor3 = textColor
            TitleText.TextSize = 15
            TitleText.TextXAlignment = Enum.TextXAlignment.Left
            TitleText.TextTruncate = Enum.TextTruncate.AtEnd
            TitleText.ZIndex = 6

            local SelectedText = Instance.new("TextLabel")
            SelectedText.Name = "SelectedValue"
            SelectedText.Parent = Header
            SelectedText.BackgroundTransparency = 1
            SelectedText.Position = UDim2.new(0.45, 0, 0, 0)
            SelectedText.Size = UDim2.new(0.45, -5, 1, 0)
            SelectedText.Font = Enum.Font.Gotham
            SelectedText.Text = "Select..."
            SelectedText.TextColor3 = textColor
            SelectedText.TextSize = 14
            SelectedText.TextXAlignment = Enum.TextXAlignment.Right
            SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
            SelectedText.ZIndex = 6

            local Arrow = Instance.new("TextLabel")
            Arrow.Name = "Arrow"
            Arrow.Parent = Header
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -28, 0, 0)
            Arrow.Size = UDim2.new(0, 18, 1, 0)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = textColor
            Arrow.TextSize = 11
            Arrow.TextXAlignment = Enum.TextXAlignment.Center
            Arrow.ZIndex = 6

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Name = "Options"
            OptionsContainer.Parent = DropdownFrame
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.BorderSizePixel = 0
            OptionsContainer.Position = UDim2.new(0, 0, 0, optionsTopOffset)
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            OptionsContainer.Visible = false
            OptionsContainer.ZIndex = 5

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Parent = OptionsContainer
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, optionPadding)

            local function getOptionsHeight()
                if #validOptions == 0 then
                    return 0
                end

                return (#validOptions * optionHeight)
                    + ((#validOptions - 1) * optionPadding)
            end

            local function updateDropdownSize()
                if isOpen then
                    local optionsHeight = getOptionsHeight()

                    OptionsContainer.Size = UDim2.new(
                        1,
                        0,
                        0,
                        optionsHeight
                    )

                    DropdownFrame.Size = UDim2.new(
                        1,
                        -10,
                        0,
                        optionsTopOffset + optionsHeight + 5
                    )
                else
                    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)

                    DropdownFrame.Size = UDim2.new(
                        1,
                        -10,
                        0,
                        headerHeight
                    )
                end
            end

            local function setOpen(state)
                if #validOptions == 0 then
                    return
                end

                isOpen = state == true
                OptionsContainer.Visible = isOpen
                Arrow.Text = isOpen and "▲" or "▼"

                updateDropdownSize()
            end

            local function setSelectedValue(value, callCallback)
                if type(value) ~= "string" then
                    return false
                end

                if not table.find(validOptions, value) then
                    return false
                end

                selectedValue = value
                SelectedText.Text = value

                setOpen(false)

                if callCallback and callback then
                    callback(value)
                end

                return true
            end

            for index, value in ipairs(validOptions) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = "Option_" .. tostring(index)
                OptionButton.Parent = OptionsContainer
                OptionButton.BackgroundColor3 = optionColor
                OptionButton.BorderSizePixel = 0
                OptionButton.Size = UDim2.new(1, 0, 0, optionHeight)
                OptionButton.AutoButtonColor = false
                OptionButton.Font = Enum.Font.GothamBold
                OptionButton.Text = value
                OptionButton.TextColor3 = textColor
                OptionButton.TextSize = 14
                OptionButton.TextTruncate = Enum.TextTruncate.AtEnd
                OptionButton.LayoutOrder = index
                OptionButton.ZIndex = 6

                addCorner(OptionButton, 5)

                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(
                        OptionButton,
                        TweenInfo.new(0.15),
                        {
                            BackgroundColor3 = hoverColor
                        }
                    ):Play()
                end)

                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(
                        OptionButton,
                        TweenInfo.new(0.15),
                        {
                            BackgroundColor3 = optionColor
                        }
                    ):Play()
                end)

                OptionButton.MouseButton1Click:Connect(function()
                    setSelectedValue(value, true)
                end)
            end

            Header.MouseEnter:Connect(function()
                TweenService:Create(
                    Header,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 = hoverColor
                    }
                ):Play()
            end)

            Header.MouseLeave:Connect(function()
                TweenService:Create(
                    Header,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 = baseColor
                    }
                ):Play()
            end)

            Header.MouseButton1Click:Connect(function()
                setOpen(not isOpen)
            end)

            updateDropdownSize()

            local Dropdown = {}

            function Dropdown:GetValue()
                return selectedValue
            end

            function Dropdown:SetValue(value)
                return setSelectedValue(value, false)
            end

            function Dropdown:SetOpen(state)
                setOpen(state)
            end

            function Dropdown:Destroy()
                if DropdownFrame then
                    DropdownFrame:Destroy()
                end
            end

            Dropdown.Frame = DropdownFrame

            return Dropdown
        end

        return Tab
    end

    return Window
end

return MoonLib
