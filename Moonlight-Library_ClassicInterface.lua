--[[
    MoonLib - GuildStyle

    Reference-inspired dark UI library based on the original MoonLib API.

    Visual changes:
    - White/dim metallic outer frame and inner strokes
    - Dark glass-like panels with colored card accents
    - Sidebar tabs with optional custom images
    - Active-tab hero header with optional image and title
    - Window title replaces "Guilds"
    - No Level / XP element is created

    Compatible calls:
        local window = MoonLib:CreateWindow("My GUI")
        local tab = window:CreateTab("Overview", "rbxassetid://123")

    CreateTab(name, image, order)
        image may be an rbxassetid string, numeric asset id, or a URL accepted by Roblox.
        order is optional and is the third argument when an image is supplied.

    Optional window image:
        MoonLib:CreateWindow("My GUI", "rbxassetid://123")

    Controls retain the original API:
        CreateLabel(text, order, color)
        CreateButton(text, callback, customColor, order)
        CreateToggle(text, default, callback, order, customColor)
        CreateSlider(text, defaultState, callback, defaultVal, min, max, order, customColor)
        CreateDropdown(text, options, callback, order, customColor, multiSelect)
]]

local MoonLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Background = Color3.fromRGB(8, 11, 14),
    Background2 = Color3.fromRGB(14, 18, 22),
    Panel = Color3.fromRGB(13, 17, 20),
    PanelLight = Color3.fromRGB(23, 28, 32),
    Card = Color3.fromRGB(18, 23, 27),
    CardHover = Color3.fromRGB(27, 34, 39),
    Text = Color3.fromRGB(244, 246, 248),
    MutedText = Color3.fromRGB(171, 178, 184),
    DimText = Color3.fromRGB(112, 120, 127),
    Line = Color3.fromRGB(119, 130, 138),
    WhiteLine = Color3.fromRGB(224, 229, 232),
    Accent = Color3.fromRGB(46, 164, 255),
    Accent2 = Color3.fromRGB(106, 221, 255),
    Success = Color3.fromRGB(70, 220, 103),
    Danger = Color3.fromRGB(221, 58, 83),
    Gold = Color3.fromRGB(212, 173, 83),
    Purple = Color3.fromRGB(123, 104, 204),
}

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = instance
    return corner
end

local function addStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Line
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

local function addGradient(instance, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colorA, colorB)
    gradient.Rotation = rotation or 90
    gradient.Parent = instance
    return gradient
end

local function normalizeImage(image)
    if image == nil or image == "" then
        return nil
    end

    if type(image) == "number" then
        return "rbxassetid://" .. tostring(image)
    end

    local value = tostring(image)
    if value:match("^%d+$") then
        return "rbxassetid://" .. value
    end

    return value
end

local function isColorBright(color)
    return (0.299 * color.R + 0.587 * color.G + 0.114 * color.B) > 0.5
end

local function getTextColor(color)
    if isColorBright(color) then
        return Color3.fromRGB(12, 14, 16)
    end
    return Theme.Text
end

local function getHoverColor(color)
    if isColorBright(color) then
        return color:Lerp(Color3.new(0, 0, 0), 0.08)
    end
    return color:Lerp(Color3.new(1, 1, 1), 0.08)
end

local function setImage(imageLabel, image)
    local normalized = normalizeImage(image)
    imageLabel.Image = normalized or ""
    imageLabel.Visible = normalized ~= nil
end

local function safeParent()
    if gethui then
        local success, hui = pcall(gethui)
        if success and hui then
            return hui
        end
    end
    return CoreGui
end

function MoonLib:CreateWindow(title, windowImage)
    local Window = {}
    local destroyed = false
    local visible = true
    local currentTab
    local inputConnections = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoonLib_GuildStyle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = safeParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -250)
    MainFrame.Size = UDim2.new(0, 780, 0, 500)
    MainFrame.ClipsDescendants = true
    addCorner(MainFrame, 3)
    addStroke(MainFrame, Theme.WhiteLine, 2, 0.08)

    local OuterGlow = Instance.new("Frame")
    OuterGlow.Name = "OuterGlow"
    OuterGlow.Parent = MainFrame
    OuterGlow.BackgroundColor3 = Theme.Accent
    OuterGlow.BackgroundTransparency = 0.92
    OuterGlow.BorderSizePixel = 0
    OuterGlow.Position = UDim2.new(0, 2, 0, 2)
    OuterGlow.Size = UDim2.new(1, -4, 1, -4)
    OuterGlow.ZIndex = 0
    addGradient(OuterGlow, Color3.fromRGB(18, 58, 75), Color3.fromRGB(12, 14, 18), 0)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Theme.Background2
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 68)
    TopBar.ZIndex = 5
    addStroke(TopBar, Theme.Line, 1, 0.2)

    local TopImage = Instance.new("ImageLabel")
    TopImage.Name = "WindowImage"
    TopImage.Parent = TopBar
    TopImage.BackgroundColor3 = Theme.PanelLight
    TopImage.BackgroundTransparency = 0.1
    TopImage.BorderSizePixel = 0
    TopImage.Position = UDim2.new(0, 14, 0, 11)
    TopImage.Size = UDim2.new(0, 46, 0, 46)
    TopImage.ScaleType = Enum.ScaleType.Crop
    TopImage.ZIndex = 6
    addCorner(TopImage, 4)
    addStroke(TopImage, Theme.WhiteLine, 1, 0.3)
    setImage(TopImage, windowImage)

    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = TopBar
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Position = UDim2.new(0, windowImage and 72 or 18, 0, 0)
    WindowTitle.Size = UDim2.new(1, -130, 1, 0)
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = tostring(title or "Moon Library")
    WindowTitle.TextColor3 = Theme.Text
    WindowTitle.TextSize = 25
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.ZIndex = 6

    local HeaderAccent = Instance.new("Frame")
    HeaderAccent.Name = "HeaderAccent"
    HeaderAccent.Parent = TopBar
    HeaderAccent.BackgroundColor3 = Theme.Accent
    HeaderAccent.BorderSizePixel = 0
    HeaderAccent.Position = UDim2.new(0, 0, 1, -2)
    HeaderAccent.Size = UDim2.new(0.36, 0, 0, 2)
    HeaderAccent.ZIndex = 7

    local WindowButtons = Instance.new("Frame")
    WindowButtons.Name = "WindowButtons"
    WindowButtons.Parent = TopBar
    WindowButtons.BackgroundTransparency = 1
    WindowButtons.Position = UDim2.new(1, -88, 0, 0)
    WindowButtons.Size = UDim2.new(0, 78, 1, 0)
    WindowButtons.ZIndex = 8

    local function makeWindowButton(name, text, position, textColor)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = WindowButtons
        button.BackgroundTransparency = 1
        button.Position = position
        button.Size = UDim2.new(0, 36, 1, 0)
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = textColor
        button.TextSize = name == "Close" and 35 or 25
        button.AutoButtonColor = false
        button.ZIndex = 9
        return button
    end

    local MinimizeButton = makeWindowButton(
        "Minimize", "−", UDim2.new(0, 0, 0, 0), Theme.MutedText
    )
    local CloseButton = makeWindowButton(
        "Close", "×", UDim2.new(0, 40, 0, -2), Theme.Text
    )

    local function toggleVisible()
        if destroyed then
            return
        end
        visible = not visible
        MainFrame.Visible = visible
    end

    MinimizeButton.MouseButton1Click:Connect(toggleVisible)
    CloseButton.MouseButton1Click:Connect(function()
        destroyed = true
        for _, connection in ipairs(inputConnections) do
            connection:Disconnect()
        end
        ScreenGui:Destroy()
    end)

    table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            toggleVisible()
        end
    end))

    local dragging = false
    local dragStart
    local startPosition

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
        end
    end)

    table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    table.insert(inputConnections, RunService.RenderStepped:Connect(function()
        if dragging and not destroyed then
            local mouse = UserInputService:GetMouseLocation()
            local target = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + mouse.X - dragStart.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + mouse.Y - dragStart.Y - 36
            )
            MainFrame.Position = MainFrame.Position:Lerp(target, 0.16)
        end
    end))

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = Theme.Panel
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 12, 0, 80)
    Sidebar.Size = UDim2.new(0, 220, 1, -92)
    Sidebar.ZIndex = 2
    addCorner(Sidebar, 3)
    addStroke(Sidebar, Theme.WhiteLine, 1, 0.18)
    addGradient(Sidebar, Color3.fromRGB(24, 30, 35), Theme.Panel, 90)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 9, 0, 10)
    TabContainer.Size = UDim2.new(1, -18, 1, -20)
    TabContainer.ScrollBarThickness = 0
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ZIndex = 3

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 7)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Parent = MainFrame
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 244, 0, 80)
    ContentArea.Size = UDim2.new(1, -256, 1, -92)
    ContentArea.ClipsDescendants = false
    ContentArea.ZIndex = 2

    local HeroHeader = Instance.new("Frame")
    HeroHeader.Name = "HeroHeader"
    HeroHeader.Parent = ContentArea
    HeroHeader.BackgroundColor3 = Theme.PanelLight
    HeroHeader.BorderSizePixel = 0
    HeroHeader.Size = UDim2.new(1, 0, 0, 62)
    HeroHeader.ZIndex = 10
    addCorner(HeroHeader, 3)
    addStroke(HeroHeader, Theme.Line, 1, 0.1)

    local HeroImage = Instance.new("ImageLabel")
    HeroImage.Name = "TabImage"
    HeroImage.Parent = HeroHeader
    HeroImage.BackgroundColor3 = Theme.Background
    HeroImage.BorderSizePixel = 0
    HeroImage.Position = UDim2.new(0, 9, 0, 8)
    HeroImage.Size = UDim2.new(0, 46, 0, 46)
    HeroImage.ScaleType = Enum.ScaleType.Crop
    HeroImage.ZIndex = 11
    addCorner(HeroImage, 3)
    addStroke(HeroImage, Theme.WhiteLine, 1, 0.35)

    local HeroTitle = Instance.new("TextLabel")
    HeroTitle.Name = "TabTitle"
    HeroTitle.Parent = HeroHeader
    HeroTitle.BackgroundTransparency = 1
    HeroTitle.Position = UDim2.new(0, 68, 0, 0)
    HeroTitle.Size = UDim2.new(1, -80, 1, 0)
    HeroTitle.Font = Enum.Font.GothamBold
    HeroTitle.TextColor3 = Theme.Text
    HeroTitle.TextSize = 21
    HeroTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeroTitle.ZIndex = 11

    local Pages = {}

    local function updatePageCanvas(page, layout)
        task.defer(function()
            if page and page.Parent then
                page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
            end
        end)
    end

    local function styleTab(button, active)
        button.BackgroundColor3 = active and Theme.PanelLight or Theme.Card
        button.BackgroundTransparency = active and 0 or 0.18
        button.TextColor3 = active and Theme.Text or Theme.MutedText

        local titleLabel = button:FindFirstChild("Title")
        if titleLabel then
            titleLabel.TextColor3 = active and Theme.Text or Theme.MutedText
        end

        local stroke = button:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = active and Theme.Accent or Theme.Line
            stroke.Transparency = active and 0.05 or 0.55
        end
    end

    local function selectTab(record)
        if currentTab then
            currentTab.Page.Visible = false
            styleTab(currentTab.Button, false)
        end

        currentTab = record
        record.Page.Visible = true
        styleTab(record.Button, true)
        setImage(HeroImage, record.Image)
        HeroTitle.Text = record.Name
    end

    function Window:CreateTab(name, image, order)
        local Tab = {}
        local tabName = tostring(name or "Tab")
        local normalizedImage = normalizeImage(image)

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Theme.Card
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 49)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = order or 0
        TabButton.ZIndex = 4
        addCorner(TabButton, 3)
        addStroke(TabButton, Theme.Line, 1, 0.55)

        local TabImage = Instance.new("ImageLabel")
        TabImage.Name = "Icon"
        TabImage.Parent = TabButton
        TabImage.BackgroundColor3 = Theme.Background
        TabImage.BorderSizePixel = 0
        TabImage.Position = UDim2.new(0, 9, 0.5, -16)
        TabImage.Size = UDim2.new(0, 32, 0, 32)
        TabImage.ScaleType = Enum.ScaleType.Crop
        TabImage.ZIndex = 5
        addCorner(TabImage, 3)
        setImage(TabImage, normalizedImage)

        local TabText = Instance.new("TextLabel")
        TabText.Name = "Title"
        TabText.Parent = TabButton
        TabText.BackgroundTransparency = 1
        TabText.Position = UDim2.new(0, normalizedImage and 51 or 15, 0, 0)
        TabText.Size = UDim2.new(1, normalizedImage and -60 or -25, 1, 0)
        TabText.Font = Enum.Font.GothamBold
        TabText.Text = tabName
        TabText.TextColor3 = Theme.MutedText
        TabText.TextSize = 17
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTruncate = Enum.TextTruncate.AtEnd
        TabText.ZIndex = 5

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Parent = ContentArea
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Position = UDim2.new(0, 0, 0, 74)
        Page.Size = UDim2.new(1, 0, 1, -74)
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ClipsDescendants = false
        Page.ZIndex = 3

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local record = {
            Name = tabName,
            Image = normalizedImage,
            Button = TabButton,
            Page = Page,
            Layout = PageLayout,
        }
        table.insert(Pages, record)

        TabButton.MouseEnter:Connect(function()
            if currentTab ~= record then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.CardHover,
                }):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if currentTab ~= record then
                TweenService:Create(TabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.Card,
                }):Play()
            end
        end)
        TabButton.MouseButton1Click:Connect(function()
            selectTab(record)
        end)

        if not currentTab then
            selectTab(record)
        end

        local function finish(instance)
            updatePageCanvas(Page, PageLayout)
            return instance
        end

        function Tab:CreateLabel(text, itemOrder, color)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = Page
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, -10, 0, 27)
            label.Font = Enum.Font.GothamBold
            label.Text = tostring(text)
            label.TextColor3 = color or Theme.MutedText
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.LayoutOrder = itemOrder or 0
            return finish(label)
        end

        function Tab:CreateButton(text, callback, customColor, itemOrder)
            local baseColor = customColor or Theme.Card
            local button = Instance.new("TextButton")
            button.Name = tostring(text) .. "Button"
            button.Parent = Page
            button.BackgroundColor3 = baseColor
            button.BorderSizePixel = 0
            button.Size = UDim2.new(1, -10, 0, 43)
            button.Font = Enum.Font.GothamBold
            button.Text = tostring(text)
            button.TextColor3 = getTextColor(baseColor)
            button.TextSize = 16
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.TextXAlignment = Enum.TextXAlignment.Center
            button.AutoButtonColor = false
            button.LayoutOrder = itemOrder or 0
            addCorner(button, 4)
            addStroke(button, customColor or Theme.Line, 1, customColor and 0.2 or 0.45)

            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.15), {
                    BackgroundColor3 = getHoverColor(baseColor),
                }):Play()
            end)
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.15), {
                    BackgroundColor3 = baseColor,
                }):Play()
            end)
            button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            return finish(button)
        end

        function Tab:CreateToggle(text, default, callback, itemOrder, customColor)
            local toggled = default == true
            local baseColor = customColor or Theme.Card
            local frame = Instance.new("Frame")
            frame.Name = tostring(text) .. "Toggle"
            frame.Parent = Page
            frame.BackgroundColor3 = baseColor
            frame.BorderSizePixel = 0
            frame.Size = UDim2.new(1, -10, 0, 43)
            frame.LayoutOrder = itemOrder or 0
            addCorner(frame, 4)
            addStroke(frame, customColor or Theme.Line, 1, customColor and 0.2 or 0.45)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 15, 0, 0)
            label.Size = UDim2.new(1, -80, 1, 0)
            label.Font = Enum.Font.GothamBold
            label.Text = tostring(text)
            label.TextColor3 = getTextColor(baseColor)
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left

            local switch = Instance.new("Frame")
            switch.Name = "Switch"
            switch.Parent = frame
            switch.Position = UDim2.new(1, -56, 0.5, -10)
            switch.Size = UDim2.new(0, 40, 0, 20)
            switch.BorderSizePixel = 0
            addCorner(switch, 20)

            local knob = Instance.new("Frame")
            knob.Name = "Knob"
            knob.Parent = switch
            knob.BackgroundColor3 = Theme.Text
            knob.Size = UDim2.new(0, 16, 0, 16)
            addCorner(knob, 16)

            local function update()
                switch.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(59, 67, 73)
                knob.Position = toggled and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            end
            update()

            local click = Instance.new("TextButton")
            click.Name = "ClickRegion"
            click.Parent = frame
            click.BackgroundTransparency = 1
            click.Size = UDim2.new(1, 0, 1, 0)
            click.Text = ""
            click.MouseButton1Click:Connect(function()
                toggled = not toggled
                update()
                if callback then
                    callback(toggled)
                end
            end)
            return finish(frame)
        end

        function Tab:CreateSlider(text, defaultState, callback, defaultValue, min, max, itemOrder, customColor)
            min = tonumber(min) or 0
            max = tonumber(max) or 100
            if max < min then min, max = max, min end
            if max == min then max = min + 1 end

            local toggled = defaultState == true
            local value = math.clamp(tonumber(defaultValue) or min, min, max)
            local baseColor = customColor or Theme.Card

            local frame = Instance.new("Frame")
            frame.Name = tostring(text) .. "Slider"
            frame.Parent = Page
            frame.BackgroundColor3 = baseColor
            frame.BorderSizePixel = 0
            frame.Size = UDim2.new(1, -10, 0, 70)
            frame.LayoutOrder = itemOrder or 0
            addCorner(frame, 4)
            addStroke(frame, customColor or Theme.Line, 1, customColor and 0.2 or 0.45)

            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 15, 0, 4)
            label.Size = UDim2.new(1, -95, 0, 27)
            label.Font = Enum.Font.GothamBold
            label.Text = tostring(text)
            label.TextColor3 = getTextColor(baseColor)
            label.TextSize = 15
            label.TextXAlignment = Enum.TextXAlignment.Left

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = frame
            valueLabel.BackgroundTransparency = 1
            valueLabel.Position = UDim2.new(1, -72, 0, 4)
            valueLabel.Size = UDim2.new(0, 57, 0, 27)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextColor3 = Theme.Accent2
            valueLabel.TextSize = 14
            valueLabel.Text = tostring(value)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local sliderBack = Instance.new("Frame")
            sliderBack.Name = "SliderBack"
            sliderBack.Parent = frame
            sliderBack.BackgroundColor3 = Color3.fromRGB(54, 63, 69)
            sliderBack.Position = UDim2.new(0, 15, 0, 47)
            sliderBack.Size = UDim2.new(1, -30, 0, 7)
            sliderBack.BorderSizePixel = 0
            addCorner(sliderBack, 8)

            local fill = Instance.new("Frame")
            fill.Name = "Fill"
            fill.Parent = sliderBack
            fill.BackgroundColor3 = Theme.Accent
            fill.BorderSizePixel = 0
            addCorner(fill, 8)

            local sliderKnob = Instance.new("Frame")
            sliderKnob.Name = "Knob"
            sliderKnob.Parent = sliderBack
            sliderKnob.BackgroundColor3 = Theme.Text
            sliderKnob.Size = UDim2.new(0, 15, 0, 15)
            addCorner(sliderKnob, 15)

            local function updateVisual()
                local ratio = (value - min) / (max - min)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                sliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
                valueLabel.Text = tostring(value)
            end
            updateVisual()

            local moveConnection
            local endConnection
            local function stopSlider()
                if moveConnection then moveConnection:Disconnect() moveConnection = nil end
                if endConnection then endConnection:Disconnect() endConnection = nil end
            end
            local function updateFromInput(input)
                if sliderBack.AbsoluteSize.X <= 0 then return end
                local ratio = math.clamp(
                    (input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X,
                    0, 1
                )
                value = math.floor(min + (max - min) * ratio)
                updateVisual()
                if callback then callback(toggled, value) end
            end
            sliderBack.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then return end
                stopSlider()
                updateFromInput(input)
                moveConnection = UserInputService.InputChanged:Connect(function(changed)
                    if changed.UserInputType == Enum.UserInputType.MouseMovement
                        or changed.UserInputType == Enum.UserInputType.Touch then
                        updateFromInput(changed)
                    end
                end)
                endConnection = UserInputService.InputEnded:Connect(function(ended)
                    if ended.UserInputType == Enum.UserInputType.MouseButton1
                        or ended.UserInputType == Enum.UserInputType.Touch then
                        stopSlider()
                    end
                end)
            end)

            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "ToggleRegion"
            toggleButton.Parent = frame
            toggleButton.BackgroundTransparency = 1
            toggleButton.Position = UDim2.new(0, 0, 0, 0)
            toggleButton.Size = UDim2.new(1, 0, 0, 38)
            toggleButton.Text = ""
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                if callback then callback(toggled, value) end
            end)
            return finish(frame)
        end

        function Tab:CreateDropdown(text, options, callback, itemOrder, customColor, multiSelect)
            assert(type(options) == "table", "CreateDropdown options must be a table")
            local isMulti = multiSelect == true
                or (type(multiSelect) == "string" and string.lower(multiSelect) == "multi")
            local entries = {}

            for key, option in pairs(options) do
                if type(option) == "string" then
                    table.insert(entries, { key = key, value = option, selected = false })
                end
            end
            table.sort(entries, function(a, b)
                if type(a.key) == "number" and type(b.key) == "number" then
                    return a.key < b.key
                end
                return tostring(a.key) < tostring(b.key)
            end)

            local baseColor = customColor or Theme.Card
            local optionColor = Theme.PanelLight
            local selectedColor = Theme.Accent
            local open = false
            local headerHeight = 43
            local optionHeight = 32
            local gap = 5

            local frame = Instance.new("Frame")
            frame.Name = tostring(text) .. "Dropdown"
            frame.Parent = Page
            frame.BackgroundTransparency = 1
            frame.Size = UDim2.new(1, -10, 0, headerHeight)
            frame.BorderSizePixel = 0
            frame.LayoutOrder = itemOrder or 0
            frame.ClipsDescendants = false
            frame.ZIndex = 50

            local header = Instance.new("TextButton")
            header.Name = "Header"
            header.Parent = frame
            header.BackgroundColor3 = baseColor
            header.BorderSizePixel = 0
            header.Size = UDim2.new(1, 0, 0, headerHeight)
            header.AutoButtonColor = false
            header.Text = ""
            header.ZIndex = 51
            addCorner(header, 4)
            addStroke(header, customColor or Theme.Line, 1, customColor and 0.2 or 0.45)

            local headerTitle = Instance.new("TextLabel")
            headerTitle.Parent = header
            headerTitle.BackgroundTransparency = 1
            headerTitle.Position = UDim2.new(0, 15, 0, 0)
            headerTitle.Size = UDim2.new(0.46, 0, 1, 0)
            headerTitle.Font = Enum.Font.GothamBold
            headerTitle.Text = tostring(text)
            headerTitle.TextColor3 = getTextColor(baseColor)
            headerTitle.TextSize = 15
            headerTitle.TextXAlignment = Enum.TextXAlignment.Left
            headerTitle.ZIndex = 52

            local selectedText = Instance.new("TextLabel")
            selectedText.Parent = header
            selectedText.BackgroundTransparency = 1
            selectedText.Position = UDim2.new(0.46, 0, 0, 0)
            selectedText.Size = UDim2.new(0.45, -8, 1, 0)
            selectedText.Font = Enum.Font.Gotham
            selectedText.Text = "Select..."
            selectedText.TextColor3 = Theme.MutedText
            selectedText.TextSize = 14
            selectedText.TextXAlignment = Enum.TextXAlignment.Right
            selectedText.TextTruncate = Enum.TextTruncate.AtEnd
            selectedText.ZIndex = 52

            local arrow = Instance.new("TextLabel")
            arrow.Parent = header
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -32, 0, 0)
            arrow.Size = UDim2.new(0, 24, 1, 0)
            arrow.Font = Enum.Font.GothamBold
            arrow.Text = "▼"
            arrow.TextColor3 = Theme.Accent2
            arrow.TextSize = 12
            arrow.ZIndex = 52

            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "Options"
            optionsFrame.Parent = frame
            optionsFrame.BackgroundTransparency = 1
            optionsFrame.Position = UDim2.new(0, 0, 0, headerHeight + gap)
            optionsFrame.Size = UDim2.new(1, 0, 0, 0)
            optionsFrame.Visible = false
            optionsFrame.ZIndex = 53

            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Parent = optionsFrame
            optionsLayout.Padding = UDim.new(0, gap)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local function selectedValues()
                local names, ids = {}, {}
                for _, entry in ipairs(entries) do
                    if entry.selected then
                        table.insert(names, entry.value)
                        table.insert(ids, entry.key)
                    end
                end
                return names, ids
            end

            local function refreshHeader()
                local names = selectedValues()
                if #names == 0 then
                    selectedText.Text = "Select..."
                elseif isMulti and #names > 1 then
                    selectedText.Text = tostring(#names) .. " selected"
                else
                    selectedText.Text = names[1]
                end
            end

            local function refreshOption(entry)
                if not entry.button then return end
                entry.button.BackgroundColor3 = entry.selected and selectedColor or optionColor
                entry.button.TextColor3 = entry.selected and getTextColor(selectedColor) or Theme.Text
            end

            local function updateSize()
                local height = 0
                if open then
                    height = #entries * optionHeight + math.max(0, #entries - 1) * gap
                    optionsFrame.Size = UDim2.new(1, 0, 0, height)
                else
                    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                end
                optionsFrame.Visible = open
                frame.Size = UDim2.new(1, -10, 0, open and headerHeight + gap + height or headerHeight)
                arrow.Text = open and "▲" or "▼"
                updatePageCanvas(Page, PageLayout)
            end

            local function fireCallback()
                if not callback then return end
                local names, ids = selectedValues()
                if isMulti then callback(names, ids) else callback(names[1], ids[1]) end
            end

            for index, entry in ipairs(entries) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option_" .. tostring(index)
                optionButton.Parent = optionsFrame
                optionButton.BackgroundColor3 = optionColor
                optionButton.BorderSizePixel = 0
                optionButton.Size = UDim2.new(1, 0, 0, optionHeight)
                optionButton.Font = Enum.Font.GothamBold
                optionButton.Text = entry.value
                optionButton.TextColor3 = Theme.Text
                optionButton.TextSize = 14
                optionButton.TextTruncate = Enum.TextTruncate.AtEnd
                optionButton.AutoButtonColor = false
                optionButton.LayoutOrder = index
                optionButton.ZIndex = 54
                addCorner(optionButton, 3)
                entry.button = optionButton

                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.12), {
                        BackgroundColor3 = entry.selected and selectedColor:Lerp(Color3.new(1, 1, 1), 0.1)
                            or Theme.CardHover,
                    }):Play()
                end)
                optionButton.MouseLeave:Connect(function() refreshOption(entry) end)
                optionButton.MouseButton1Click:Connect(function()
                    if isMulti then
                        entry.selected = not entry.selected
                    else
                        for _, other in ipairs(entries) do other.selected = false end
                        entry.selected = true
                        open = false
                    end
                    for _, other in ipairs(entries) do refreshOption(other) end
                    refreshHeader()
                    updateSize()
                    fireCallback()
                end)
            end

            header.MouseEnter:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.12), {
                    BackgroundColor3 = getHoverColor(baseColor),
                }):Play()
            end)
            header.MouseLeave:Connect(function()
                TweenService:Create(header, TweenInfo.new(0.12), {
                    BackgroundColor3 = baseColor,
                }):Play()
            end)
            header.MouseButton1Click:Connect(function()
                if #entries > 0 then
                    open = not open
                    updateSize()
                end
            end)

            local dropdown = { Frame = frame }
            function dropdown:GetValue()
                local names = selectedValues()
                return isMulti and names or names[1]
            end
            function dropdown:GetIds()
                local _, ids = selectedValues()
                return isMulti and ids or ids[1]
            end
            function dropdown:GetSelection()
                return selectedValues()
            end
            function dropdown:GetMode()
                return isMulti and "Multi" or "Single"
            end
            function dropdown:SetOpen(state)
                open = state == true and #entries > 0
                updateSize()
            end
            function dropdown:Clear(callCallback)
                for _, entry in ipairs(entries) do
                    entry.selected = false
                    refreshOption(entry)
                end
                refreshHeader()
                if callCallback == true then fireCallback() end
            end
            function dropdown:SetValue(valueToSet, callCallback)
                if isMulti and type(valueToSet) ~= "table" then return false end
                for _, entry in ipairs(entries) do entry.selected = false end
                local requested = isMulti and valueToSet or { valueToSet }
                local found = false
                for _, requestedValue in ipairs(requested) do
                    for _, entry in ipairs(entries) do
                        if entry.value == requestedValue or entry.key == requestedValue then
                            entry.selected = true
                            found = true
                            break
                        end
                    end
                end
                for _, entry in ipairs(entries) do refreshOption(entry) end
                refreshHeader()
                if not isMulti then open = false end
                updateSize()
                if callCallback == true then fireCallback() end
                return found
            end
            function dropdown:Destroy()
                if frame then frame:Destroy() end
            end

            updateSize()
            return dropdown
        end

        return Tab
    end

    function Window:SetTitle(newTitle)
        WindowTitle.Text = tostring(newTitle or "")
    end

    function Window:SetImage(image)
        setImage(TopImage, image)
        TopImage.Visible = normalizeImage(image) ~= nil
        WindowTitle.Position = UDim2.new(0, normalizeImage(image) and 72 or 18, 0, 0)
    end

    function Window:Toggle()
        toggleVisible()
    end

    function Window:Destroy()
        if not destroyed then
            destroyed = true
            for _, connection in ipairs(inputConnections) do
                connection:Disconnect()
            end
            ScreenGui:Destroy()
        end
    end

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.Theme = Theme

    return Window
end

return MoonLib
