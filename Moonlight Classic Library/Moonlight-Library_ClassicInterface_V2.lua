--[[
    MoonLib - Classic Interface

    Executor-compatible UI library.

    Main API:

        local Window = MoonLib:CreateWindow(
            "My GUI",
            "rbxassetid://123456789"
        )

        local Tab = Window:CreateTab(
            "Player",
            "rbxassetid://123456789",
            1
        )

    Tab methods:

        Tab:SetTabIcon(image)
            Changes the tab's icon.
            Accepts an image asset ID, number, or image string.
            Pass nil or an empty string to restore the fallback icon.

        Tab:GetTabIcon()
            Returns the current tab icon.

    Tab elements:

        Tab:CreateLabel(text, order, color)
            Creates a text label.
            Returns the TextLabel instance.

        Tab:CreateHeader(title, subtitle, order)
            Creates a section header with an optional subtitle.
            Returns the Frame instance.

        Tab:CreateInfoCard(title, description, accentColor, order)
            Creates an informational card.
            Returns the Frame instance.

        Tab:CreateStatCard(title, value, accentColor, order)
            Creates a statistic card.
            Returns the Frame instance.

        Tab:CreateButton(text, callback, customColor, order)
            Creates a clickable button.
            callback() is called when clicked.
            Returns the TextButton instance.

        Tab:CreateToggle(text, default, callback, order, customColor)
            Creates a toggle.
            callback(enabled) is called when its state changes.
            Returns a ToggleObject.

            ToggleObject methods:

                :GetValue()
                :SetValue(value, callCallback)
                :Toggle()
                :Destroy()

        Tab:CreateSlider(
            text,
            defaultState,
            callback,
            defaultValue,
            minimum,
            maximum,
            order,
            customColor
        )
            Creates a slider with an enable/disable state.
            callback(enabled, value) is called when the slider
            value or enabled state changes.

            Returns a SliderObject.

            SliderObject methods:

                :GetValue()
                :IsEnabled()
                :SetValue(value, callCallback)
                :SetEnabled(value, callCallback)
                :Destroy()

        Tab:CreateTextbox(
            text,
            placeholder,
            callback,
            order,
            customColor,
            defaultValue
        )
            Creates a text input.
            callback(value, enterPressed) is called when the
            input loses focus.

            Returns a TextboxObject.

            TextboxObject methods:

                :GetValue()
                :SetValue(value, callCallback)
                :Clear(callCallback)
                :SetPlaceholder(placeholder)
                :Focus()
                :Destroy()

        Tab:CreateDropdown(
            text,
            options,
            callback,
            order,
            customColor,
            multiSelect
        )
            Creates a dropdown.

            options can be:
                - A table of options.
                - A function returning a table of options.

            multiSelect:
                true or "multi" enables multiple selection.
                Otherwise, the dropdown uses single selection.

            Callback behavior:

                Single selection:
                    callback(value, id)

                Multiple selection:
                    callback(values, ids)

            Returns a DropdownObject.

            DropdownObject methods:

                :GetValue()
                :GetIds()
                :GetSelection()
                :GetMode()
                :SetOpen(value)
                :IsOpen()
                :Clear(callCallback)
                :SetValue(value, callCallback)
                :Refresh(newOptions, callCallback)
                :SetOptions(newOptions, callCallback)
                :GetOptions()
                :SetRefreshOnOpen(value)
                :GetSource()
                :Destroy()

            Dropdown notes:

                Options supplied through a function are re-evaluated
                when the dropdown opens, if refresh-on-open is enabled.

                Refresh() rebuilds the current options.
                Refresh(newOptions) replaces the current options source.

    Window appearance methods:

        Window:SetMainColor(color)
        Window:GetMainColor()

        Window:SetBackground(colorOrImageOrConfig)
        Window:GetBackground()

        Window:SetBackgroundTransparency(transparency)
        Window:GetBackgroundTransparency()

        Window:SetTitle(title)
        Window:GetTitle()

        Window:SetWindowImage(image)

        Window:SetSize(UDim2)
        Window:SetPosition(UDim2)

        Window:SetVisible(bool)
        Window:IsVisible()

        Window:SetStateKeybind(Enum.KeyCode)
        Window:GetStateKeybind()

        Window:SelectTab(tabName)
        Window:Toggle()
        Window:Destroy()

    SetBackground accepts:

        Color3:
            Sets a solid background color.

        Image asset ID / image string:
            Sets an image background.

        Configuration table:
            {
                Image = "rbxassetid://...",
                Rows = 4,
                Columns = 4,
                FrameCount = 16,
                FrameRate = 12,
                ImageSize = Vector2.new(1024, 1024),
                ImageTransparency = 0,
                ScaleType = Enum.ScaleType.Crop
            }

    Sprite-sheet animation uses ImageRectSize and ImageRectOffset.

    External image URLs may require executor-specific functionality.
    Standard Roblox ImageLabels require valid image content IDs.

    Image formats accepted by the library:

        "rbxassetid://123456789"
        123456789
        "https://your-image-url"

    For normal executor usage:

        local MoonLib = loadstring(
            game:HttpGet("YOUR_RAW_URL")
        )()
]]

local MoonLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    OuterBackground = Color3.fromRGB(4, 7, 9),
    MainBackground = Color3.fromRGB(7, 10, 12),
    TopBar = Color3.fromRGB(8, 12, 15),
    Sidebar = Color3.fromRGB(7, 11, 14),
    Panel = Color3.fromRGB(12, 17, 20),
    PanelLight = Color3.fromRGB(18, 24, 28),
    Card = Color3.fromRGB(13, 18, 22),
    CardHover = Color3.fromRGB(24, 32, 38),

    Text = Color3.fromRGB(245, 247, 249),
    SecondaryText = Color3.fromRGB(190, 197, 202),
    MutedText = Color3.fromRGB(137, 147, 154),
    DarkText = Color3.fromRGB(83, 94, 101),

    Border = Color3.fromRGB(123, 137, 145),
    BrightBorder = Color3.fromRGB(235, 240, 243),

    Blue = Color3.fromRGB(43, 163, 255),
    BlueLight = Color3.fromRGB(93, 202, 255),
    BlueDark = Color3.fromRGB(18, 79, 132),

    Green = Color3.fromRGB(80, 221, 111),
    Red = Color3.fromRGB(221, 58, 80),
    Yellow = Color3.fromRGB(219, 176, 77),
    Purple = Color3.fromRGB(141, 112, 226),
}

local function create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 4)
    corner.Parent = object

    return corner
end

local function addStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = object

    return stroke
end

local function addGradient(object, firstColor, secondColor, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, firstColor),
        ColorSequenceKeypoint.new(1, secondColor),
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = object

    return gradient
end

local function normalizeImage(image)
    if image == nil or image == "" then
        return nil
    end

    if type(image) == "number" then
        return "rbxassetid://" .. tostring(image)
    end

    local imageString = tostring(image)

    if imageString:match("^%d+$") then
        return "rbxassetid://" .. imageString
    end

    return imageString
end

local function getGuiParent()
    if type(gethui) == "function" then
        local success, hui = pcall(gethui)

        if success and hui then
            return hui
        end
    end

    return CoreGui
end

local function protectGui(gui)
    if type(syn) == "table" and type(syn.protect_gui) == "function" then
        pcall(function()
            syn.protect_gui(gui)
        end)
    end

    if type(protectgui) == "function" then
        pcall(function()
            protectgui(gui)
        end)
    end
end

local function setImage(imageObject, image)
    local normalized = normalizeImage(image)

    if normalized then
        imageObject.Image = normalized
        imageObject.Visible = true
    else
        imageObject.Image = ""
        imageObject.Visible = false
    end
end

local function textColorFor(backgroundColor)
    local brightness =
        (0.299 * backgroundColor.R)
        + (0.587 * backgroundColor.G)
        + (0.114 * backgroundColor.B)

    if brightness > 0.52 then
        return Color3.fromRGB(8, 10, 12)
    end

    return Theme.Text
end

local function hoverColorFor(backgroundColor)
    local brightness =
        (0.299 * backgroundColor.R)
        + (0.587 * backgroundColor.G)
        + (0.114 * backgroundColor.B)

    if brightness > 0.52 then
        return backgroundColor:Lerp(Color3.fromRGB(0, 0, 0), 0.08)
    end

    return backgroundColor:Lerp(Color3.fromRGB(255, 255, 255), 0.08)
end

local function makeTween(object, duration, properties)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

function MoonLib:CreateWindow(title, windowImage)
    local Window = {}

    local destroyed = false
    local visible = true
    local currentTab = nil

    local stateKeybind = Enum.KeyCode.RightShift

    local connections = {}
    local tabs = {}

    local ScreenGui = create("ScreenGui", {
        Name = "MoonLib_ModernInterface",
        Parent = getGuiParent(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    })

    protectGui(ScreenGui)

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.MainBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -470, 0.5, -300),
        Size = UDim2.new(0, 940, 0, 600),
        ClipsDescendants = true,
        ZIndex = 1,
    })

    addCorner(MainFrame, 3)
    addStroke(MainFrame, Theme.BrightBorder, 2, 0.05)

    local InnerFrame = create("Frame", {
        Name = "InnerFrame",
        Parent = MainFrame,
        BackgroundColor3 = Theme.MainBackground,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 1, -10),
        ZIndex = 1,
    })

    addStroke(InnerFrame, Theme.Border, 1, 0.22)

    local InnerGradient = addGradient(
        InnerFrame,
        Color3.fromRGB(13, 25, 31),
        Color3.fromRGB(5, 8, 10),
        90
    )

    -- Kept behind the interface panels so the window can use a solid or
    -- image-based background without covering tabs and controls.
    local BackgroundImage = create("ImageLabel", {
        Name = "BackgroundImage",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(1, -10, 1, -10),
        Image = "",
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Crop,
        Visible = false,
        ZIndex = 2,
    })

    local TopBar = create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.TopBar,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 7, 0, 7),
        Size = UDim2.new(1, -14, 0, 64),
        ZIndex = 10,
    })

    addStroke(TopBar, Theme.Border, 1, 0.25)

    local TopBarGradient = addGradient(
        TopBar,
        Color3.fromRGB(19, 33, 41),
        Color3.fromRGB(5, 9, 12),
        0
    )

    local WindowImage = create("ImageLabel", {
        Name = "WindowImage",
        Parent = TopBar,
        BackgroundColor3 = Theme.PanelLight,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0, 9),
        Size = UDim2.new(0, 46, 0, 46),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 12,
    })

    addCorner(WindowImage, 4)
    addStroke(WindowImage, Theme.BrightBorder, 1, 0.3)
    setImage(WindowImage, windowImage)

    local WindowTitle = create("TextLabel", {
        Name = "WindowTitle",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, normalizeImage(windowImage) and 72 or 18, 0, 0),
        Size = UDim2.new(1, -160, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = tostring(title or "Moon Library"),
        TextColor3 = Theme.Text,
        TextSize = 25,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })

    local HeaderLine = create("Frame", {
        Name = "HeaderLine",
        Parent = TopBar,
        BackgroundColor3 = Theme.Blue,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(0.42, 0, 0, 2),
        ZIndex = 13,
    })

    addGradient(
        HeaderLine,
        Theme.Blue,
        Color3.fromRGB(30, 67, 90),
        0
    )

    local WindowButtons = create("Frame", {
        Name = "WindowButtons",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -104, 0, 0),
        Size = UDim2.new(0, 94, 1, 0),
        ZIndex = 20,
    })

    local function makeWindowButton(name, text, position, size, color)
        local button = create("TextButton", {
            Name = name,
            Parent = WindowButtons,
            BackgroundTransparency = 1,
            Position = position,
            Size = size,
            Font = Enum.Font.GothamBold,
            Text = text,
            TextColor3 = color,
            TextSize = name == "Close" and 42 or 26,
            AutoButtonColor = false,
            ZIndex = 21,
        })

        button.MouseEnter:Connect(function()
            makeTween(button, 0.12, {
                TextColor3 = name == "Close"
                    and Color3.fromRGB(255, 90, 105)
                    or Theme.BlueLight,
            })
        end)

        button.MouseLeave:Connect(function()
            makeTween(button, 0.12, {
                TextColor3 = color,
            })
        end)

        return button
    end

    local MinimizeButton = makeWindowButton(
        "Minimize",
        "−",
        UDim2.new(0, 0, 0, 0),
        UDim2.new(0, 40, 1, 0),
        Theme.SecondaryText
    )

    local CloseButton = makeWindowButton(
        "Close",
        "×",
        UDim2.new(0, 44, 0, -5),
        UDim2.new(0, 45, 1, 0),
        Theme.Text
    )

    local stopBackgroundAnimation

    local function toggleWindow()
        if destroyed then
            return
        end

        visible = not visible
        MainFrame.Visible = visible
    end

    MinimizeButton.MouseButton1Click:Connect(toggleWindow)

    CloseButton.MouseButton1Click:Connect(function()
        if destroyed then
            return
        end

        destroyed = true

        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        stopBackgroundAnimation()
        ScreenGui:Destroy()
    end)

    table.insert(
        connections,
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or destroyed then
                return
            end

            if input.KeyCode == stateKeybind then
                toggleWindow()
            end
        end)
    )

    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
            dragInput = input
        end
    end)

    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    table.insert(
        connections,
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging and not destroyed then
                local delta = input.Position - dragStart

                local targetPosition = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )

                MainFrame.Position = MainFrame.Position:Lerp(
                    targetPosition,
                    0.22
                )
            end
        end)
    )

    table.insert(
        connections,
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                dragging = false
            end
        end)
    )

    local Sidebar = create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 20, 0, 88),
        Size = UDim2.new(0, 218, 1, -108),
        ZIndex = 3,
    })

    addStroke(Sidebar, Theme.BrightBorder, 1, 0.2)

    addGradient(
        Sidebar,
        Color3.fromRGB(17, 25, 29),
        Color3.fromRGB(5, 8, 10),
        90
    )

    local SidebarInner = create("Frame", {
        Name = "SidebarInner",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        ZIndex = 4,
    })

    local TabContainer = create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = SidebarInner,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 5,
    })

    local TabList = create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })

    local ContentArea = create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 253, 0, 88),
        Size = UDim2.new(1, -273, 1, -108),
        ClipsDescendants = false,
        ZIndex = 3,
    })

    local HeroHeader = create("Frame", {
        Name = "HeroHeader",
        Parent = ContentArea,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 74),
        ZIndex = 10,
    })

    addStroke(HeroHeader, Theme.Border, 1, 0.15)

    addGradient(
        HeroHeader,
        Color3.fromRGB(25, 34, 39),
        Color3.fromRGB(9, 13, 15),
        0
    )

    local HeroImage = create("ImageLabel", {
        Name = "HeroImage",
        Parent = HeroHeader,
        BackgroundColor3 = Theme.MainBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 54, 0, 54),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 11,
    })

    addCorner(HeroImage, 3)
    addStroke(HeroImage, Theme.BrightBorder, 1, 0.28)

    local HeroTitle = create("TextLabel", {
        Name = "HeroTitle",
        Parent = HeroHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 78, 0, 0),
        Size = UDim2.new(1, -90, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = tostring(title or "Overview"),
        TextColor3 = Theme.Text,
        TextSize = 23,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
    })

    local HeroAccent = create("Frame", {
        Name = "HeroAccent",
        Parent = HeroHeader,
        BackgroundColor3 = Theme.Blue,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(0.3, 0, 0, 2),
        ZIndex = 12,
    })

    local function updateCanvas(page, layout)
        task.defer(function()
            if page and page.Parent and layout and layout.Parent then
                page.CanvasSize = UDim2.new(
                    0,
                    0,
                    0,
                    layout.AbsoluteContentSize.Y + 15
                )
            end
        end)
    end

    local function setTabVisual(button, active)
        button.BackgroundColor3 = active
            and Color3.fromRGB(23, 49, 66)
            or Theme.Panel

        button.BackgroundTransparency = active and 0 or 0.2

        local stroke = button:FindFirstChildOfClass("UIStroke")

        if stroke then
            stroke.Color = active and Theme.Blue or Theme.BrightBorder
            stroke.Transparency = active and 0.05 or 0.34
        end

        local titleObject = button:FindFirstChild("TabTitle")

        if titleObject then
            titleObject.TextColor3 = active
                and Theme.Text
                or Theme.SecondaryText
        end

        local iconBorder = button:FindFirstChild("IconBorder")

        if iconBorder then
            iconBorder.BackgroundColor3 = active
                and Theme.Blue
                or Theme.PanelLight
        end
    end

    local function selectTab(record)
        if currentTab then
            currentTab.Page.Visible = false
            setTabVisual(currentTab.Button, false)
        end

        currentTab = record

        currentTab.Page.Visible = true
        setTabVisual(currentTab.Button, true)

        HeroTitle.Text = currentTab.Name
        setImage(HeroImage, currentTab.Image)
    end

    function Window:CreateTab(name, image, order)
        local tabName = tostring(name or "Tab")
        local normalizedImage = normalizeImage(image)

        local record = {}
        local Tab = {}

        local TabButton = create("TextButton", {
            Name = tabName .. "Tab",
            Parent = TabContainer,
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 52),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order or 0,
            ZIndex = 6,
        })

        addStroke(TabButton, Theme.BrightBorder, 1, 0.34)

        local IconBorder = create("Frame", {
            Name = "IconBorder",
            Parent = TabButton,
            BackgroundColor3 = Theme.PanelLight,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 9, 0.5, -18),
            Size = UDim2.new(0, 36, 0, 36),
            ZIndex = 7,
        })

        addCorner(IconBorder, 3)

        local TabIcon = create("ImageLabel", {
            Name = "Icon",
            Parent = IconBorder,
            BackgroundColor3 = Theme.MainBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 2, 0, 2),
            Size = UDim2.new(1, -4, 1, -4),
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 8,
        })

        addCorner(TabIcon, 2)

        local FallbackIcon = create("TextLabel", {
            Name = "FallbackIcon",
            Parent = IconBorder,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = string.upper(string.sub(tabName, 1, 1)),
            TextColor3 = Theme.BlueLight,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 9,
        })

        local normalizedTabImage = normalizeImage(image)

        if normalizedTabImage then
            setImage(TabIcon, normalizedTabImage)
            FallbackIcon.Visible = false
        else
            TabIcon.Visible = false
            FallbackIcon.Visible = true
        end

        local TabTitle = create("TextLabel", {
            Name = "TabTitle",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 57, 0, 0),
            Size = UDim2.new(1, -66, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = Theme.SecondaryText,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 8,
        })

        local Page = create("ScrollingFrame", {
            Name = tabName .. "Page",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 88),
            Size = UDim2.new(1, 0, 1, -88),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Blue,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 5,
        })

        local PageLayout = create("UIListLayout", {
            Parent = Page,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 9),
        })

        record.Name = tabName
        record.Image = normalizedImage
        record.Button = TabButton
        record.Page = Page
        record.Layout = PageLayout

        table.insert(tabs, record)

        TabButton.MouseEnter:Connect(function()
            if currentTab ~= record then
                makeTween(TabButton, 0.14, {
                    BackgroundColor3 = Theme.CardHover,
                })
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if currentTab ~= record then
                makeTween(TabButton, 0.14, {
                    BackgroundColor3 = Theme.Panel,
                })
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            selectTab(record)
        end)

        if not currentTab then
            selectTab(record)
        end

        function Tab:SetTabIcon(newImage)
            local normalizedImage = normalizeImage(newImage)
        
            record.Image = normalizedImage
        
            if normalizedImage then
                setImage(TabIcon, normalizedImage)
                FallbackIcon.Visible = false
            else
                TabIcon.Image = ""
                TabIcon.Visible = false
                FallbackIcon.Visible = true
            end
        
            -- Update the large image in the content header
            -- if this tab is currently selected.
            if currentTab == record then
                setImage(HeroImage, normalizedImage)
            end
        
            return true
        end
        
        function Tab:GetTabIcon()
            return record.Image
        end
        
        local function finish(instance)
            updateCanvas(Page, PageLayout)
            return instance
        end

        function Tab:CreateLabel(text, itemOrder, color)
            local Label = create("TextLabel", {
                Name = "Label",
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 28),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = color or Theme.SecondaryText,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            return finish(Label)
        end

        function Tab:CreateHeader(headerText, subtitle, itemOrder)
            local Header = create("Frame", {
                Name = "SectionHeader",
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 0, 49),
                BorderSizePixel = 0,
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            local Title = create("TextLabel", {
                Name = "Title",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 2, 0, 0),
                Size = UDim2.new(1, -4, 0, 27),
                Font = Enum.Font.GothamBold,
                Text = tostring(headerText),
                TextColor3 = Theme.Text,
                TextSize = 22,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            local Subtitle = create("TextLabel", {
                Name = "Subtitle",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 2, 0, 27),
                Size = UDim2.new(1, -4, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(subtitle or ""),
                TextColor3 = Theme.MutedText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 8,
            })

            return finish(Header)
        end

        function Tab:CreateInfoCard(
            cardTitle,
            description,
            accentColor,
            itemOrder
        )
            local accent = accentColor or Theme.Blue

            local Card = create("Frame", {
                Name = tostring(cardTitle) .. "InfoCard",
                Parent = Page,
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 70),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addStroke(Card, accent, 1, 0.32)

            local Accent = create("Frame", {
                Name = "Accent",
                Parent = Card,
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 3, 1, 0),
                ZIndex = 8,
            })

            local Title = create("TextLabel", {
                Name = "Title",
                Parent = Card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 8),
                Size = UDim2.new(1, -30, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = tostring(cardTitle),
                TextColor3 = Theme.Text,
                TextSize = 17,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            local Description = create("TextLabel", {
                Name = "Description",
                Parent = Card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 36),
                Size = UDim2.new(1, -30, 0, 24),
                Font = Enum.Font.Gotham,
                Text = tostring(description or ""),
                TextColor3 = Theme.MutedText,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 8,
            })

            return finish(Card)
        end

        function Tab:CreateStatCard(
            statTitle,
            statValue,
            accentColor,
            itemOrder
        )
            local accent = accentColor or Theme.Blue

            local Card = create("Frame", {
                Name = tostring(statTitle) .. "StatCard",
                Parent = Page,
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 82),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addStroke(Card, accent, 1, 0.24)

            local Title = create("TextLabel", {
                Name = "Title",
                Parent = Card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(1, -28, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = tostring(statTitle),
                TextColor3 = Theme.SecondaryText,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            local Value = create("TextLabel", {
                Name = "Value",
                Parent = Card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 30),
                Size = UDim2.new(1, -28, 0, 43),
                Font = Enum.Font.GothamBold,
                Text = tostring(statValue),
                TextColor3 = accent,
                TextSize = 30,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            return finish(Card)
        end

        function Tab:CreateButton(
            text,
            callback,
            customColor,
            itemOrder
        )
            local baseColor = customColor or Theme.Card
            local textColor = textColorFor(baseColor)

            local Button = create("TextButton", {
                Name = tostring(text) .. "Button",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 46),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColor,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Center,
                AutoButtonColor = false,
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(Button, 3)
            addStroke(
                Button,
                customColor or Theme.BrightBorder,
                1,
                customColor and 0.18 or 0.35
            )

            Button.MouseEnter:Connect(function()
                makeTween(Button, 0.14, {
                    BackgroundColor3 = hoverColorFor(baseColor),
                })
            end)

            Button.MouseLeave:Connect(function()
                makeTween(Button, 0.14, {
                    BackgroundColor3 = baseColor,
                })
            end)

            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return finish(Button)
        end

        function Tab:CreateToggle(
            text,
            default,
            callback,
            itemOrder,
            customColor
        )
            local toggled = default == true
            local baseColor = customColor or Theme.Card

            local ToggleFrame = create("Frame", {
                Name = tostring(text) .. "Toggle",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 50),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(ToggleFrame, 3)
            addStroke(
                ToggleFrame,
                customColor or Theme.BrightBorder,
                1,
                customColor and 0.18 or 0.35
            )

            local ToggleLabel = create("TextLabel", {
                Name = "Title",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(1, -95, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            local Switch = create("Frame", {
                Name = "Switch",
                Parent = ToggleFrame,
                BackgroundColor3 = Color3.fromRGB(54, 65, 72),
                BorderSizePixel = 0,
                Position = UDim2.new(1, -66, 0.5, -11),
                Size = UDim2.new(0, 46, 0, 22),
                ZIndex = 8,
            })

            addCorner(Switch, 20)

            local Knob = create("Frame", {
                Name = "Knob",
                Parent = Switch,
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 3, 0, 3),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 9,
            })

            addCorner(Knob, 20)

            local ClickRegion = create("TextButton", {
                Name = "ClickRegion",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 10,
            })

            local function updateToggle()
                makeTween(Switch, 0.13, {
                    BackgroundColor3 = toggled
                        and Theme.Blue
                        or Color3.fromRGB(54, 65, 72),
                })

                makeTween(Knob, 0.13, {
                    Position = toggled
                        and UDim2.new(1, -19, 0, 3)
                        or UDim2.new(0, 3, 0, 3),
                })
            end

            updateToggle()

            ClickRegion.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()

                if callback then
                    callback(toggled)
                end
            end)

            local ToggleObject = {
                Frame = ToggleFrame,
            }

            function ToggleObject:GetValue()
                return toggled
            end

            function ToggleObject:SetValue(value, callCallback)
                toggled = value == true
                updateToggle()

                if callCallback and callback then
                    callback(toggled)
                end
            end

            function ToggleObject:Toggle()
                toggled = not toggled
                updateToggle()

                if callback then
                    callback(toggled)
                end
            end

            function ToggleObject:Destroy()
                ToggleFrame:Destroy()
            end

            finish(ToggleFrame)

            return ToggleObject
        end

        function Tab:CreateSlider(
            text,
            defaultState,
            callback,
            defaultValue,
            minimum,
            maximum,
            itemOrder,
            customColor
        )
            local minValue = tonumber(minimum) or 0
            local maxValue = tonumber(maximum) or 100

            if maxValue < minValue then
                minValue, maxValue = maxValue, minValue
            end

            if maxValue == minValue then
                maxValue = minValue + 1
            end

            local toggled = defaultState == true
            local currentValue = tonumber(defaultValue) or minValue

            currentValue = math.clamp(
                currentValue,
                minValue,
                maxValue
            )

            local baseColor = customColor or Theme.Card

            local SliderFrame = create("Frame", {
                Name = tostring(text) .. "Slider",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 82),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(SliderFrame, 3)
            addStroke(
                SliderFrame,
                customColor or Theme.BrightBorder,
                1,
                customColor and 0.18 or 0.35
            )

            local SliderTitle = create("TextLabel", {
                Name = "Title",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 7),
                Size = UDim2.new(1, -100, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            local ValueDisplay = create("TextLabel", {
                Name = "Value",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -74, 0, 7),
                Size = UDim2.new(0, 58, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = tostring(currentValue),
                TextColor3 = Theme.BlueLight,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 8,
            })

            local SliderBack = create("Frame", {
                Name = "SliderBack",
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(48, 60, 67),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 16, 0, 53),
                Size = UDim2.new(1, -32, 0, 7),
                ZIndex = 8,
            })

            addCorner(SliderBack, 8)

            local SliderFill = create("Frame", {
                Name = "Fill",
                Parent = SliderBack,
                BackgroundColor3 = Theme.Blue,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 9,
            })

            addCorner(SliderFill, 8)

            local SliderKnob = create("Frame", {
                Name = "Knob",
                Parent = SliderBack,
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 10,
            })

            addCorner(SliderKnob, 16)

            local function updateSliderVisual()
                local ratio =
                    (currentValue - minValue)
                    / (maxValue - minValue)

                SliderFill.Size = UDim2.new(
                    ratio,
                    0,
                    1,
                    0
                )

                SliderKnob.Position = UDim2.new(
                    ratio,
                    -8,
                    0.5,
                    -8
                )

                ValueDisplay.Text = tostring(currentValue)
            end

            updateSliderVisual()

            local sliderMoving = false
            local sliderMoveConnection
            local sliderEndConnection

            local function stopSlider()
                sliderMoving = false

                if sliderMoveConnection then
                    sliderMoveConnection:Disconnect()
                    sliderMoveConnection = nil
                end

                if sliderEndConnection then
                    sliderEndConnection:Disconnect()
                    sliderEndConnection = nil
                end
            end

            local function updateFromInput(input)
                if SliderBack.AbsoluteSize.X <= 0 then
                    return
                end

                local ratio = math.clamp(
                    (
                        input.Position.X
                        - SliderBack.AbsolutePosition.X
                    )
                    / SliderBack.AbsoluteSize.X,
                    0,
                    1
                )

                currentValue = math.floor(
                    minValue
                    + ((maxValue - minValue) * ratio)
                )

                currentValue = math.clamp(
                    currentValue,
                    minValue,
                    maxValue
                )

                updateSliderVisual()

                if callback then
                    callback(toggled, currentValue)
                end
            end

            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.MouseButton1
                    and input.UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                stopSlider()

                sliderMoving = true
                updateFromInput(input)

                sliderMoveConnection =
                    UserInputService.InputChanged:Connect(function(changed)
                        if not sliderMoving then
                            return
                        end

                        if changed.UserInputType
                            == Enum.UserInputType.MouseMovement
                            or changed.UserInputType
                            == Enum.UserInputType.Touch then

                            updateFromInput(changed)
                        end
                    end)

                sliderEndConnection =
                    UserInputService.InputEnded:Connect(function(ended)
                        if ended.UserInputType
                            == Enum.UserInputType.MouseButton1
                            or ended.UserInputType
                            == Enum.UserInputType.Touch then

                            stopSlider()
                        end
                    end)
            end)

            local ToggleArea = create("TextButton", {
                Name = "ToggleArea",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 36),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 11,
            })

            ToggleArea.MouseButton1Click:Connect(function()
                toggled = not toggled

                if callback then
                    callback(toggled, currentValue)
                end
            end)

            local SliderObject = {
                Frame = SliderFrame,
            }

            function SliderObject:GetValue()
                return currentValue
            end

            function SliderObject:IsEnabled()
                return toggled
            end

            function SliderObject:SetValue(value, callCallback)
                currentValue = math.clamp(
                    tonumber(value) or minValue,
                    minValue,
                    maxValue
                )

                updateSliderVisual()

                if callCallback and callback then
                    callback(toggled, currentValue)
                end
            end

            function SliderObject:SetEnabled(value, callCallback)
                toggled = value == true

                if callCallback and callback then
                    callback(toggled, currentValue)
                end
            end

            function SliderObject:Destroy()
                stopSlider()
                SliderFrame:Destroy()
            end

            finish(SliderFrame)

            return SliderObject
        end

        function Tab:CreateTextbox(
            text,
            placeholder,
            callback,
            itemOrder,
            customColor,
            defaultValue
        )
            local baseColor = customColor or Theme.Card

            local TextboxFrame = create("Frame", {
                Name = tostring(text) .. "Textbox",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 78),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(TextboxFrame, 3)
            addStroke(
                TextboxFrame,
                customColor or Theme.BrightBorder,
                1,
                customColor and 0.18 or 0.35
            )

            local TextboxTitle = create("TextLabel", {
                Name = "Title",
                Parent = TextboxFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 7),
                Size = UDim2.new(1, -32, 0, 23),
                Font = Enum.Font.GothamBold,
                Text = tostring(text or "Input"),
                TextColor3 = textColorFor(baseColor),
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 8,
            })

            local Input = create("TextBox", {
                Name = "Input",
                Parent = TextboxFrame,
                BackgroundColor3 = Theme.PanelLight,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 36),
                Size = UDim2.new(1, -24, 0, 31),
                Font = Enum.Font.Gotham,
                Text = tostring(defaultValue or ""),
                PlaceholderText = tostring(placeholder or "Enter text..."),
                PlaceholderColor3 = Theme.MutedText,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                TextTruncate = Enum.TextTruncate.AtEnd,
                MultiLine = false,
                TextEditable = true,
                ZIndex = 8,
            })

            addCorner(Input, 3)
            addStroke(Input, Theme.Border, 1, 0.35)

            local function fireCallback(enterPressed)
                if callback then
                    callback(Input.Text, enterPressed == true)
                end
            end

            Input.Focused:Connect(function()
                makeTween(Input, 0.12, {
                    BackgroundColor3 = Theme.CardHover,
                })
            end)

            Input.FocusLost:Connect(function(enterPressed)
                makeTween(Input, 0.12, {
                    BackgroundColor3 = Theme.PanelLight,
                })

                fireCallback(enterPressed)
            end)

            local TextboxObject = {
                Frame = TextboxFrame,
                Input = Input,
            }

            function TextboxObject:GetValue()
                return Input.Text
            end

            function TextboxObject:SetValue(value, callCallback)
                Input.Text = tostring(value or "")

                if callCallback then
                    fireCallback(false)
                end

                return Input.Text
            end

            function TextboxObject:Clear(callCallback)
                return self:SetValue("", callCallback)
            end

            function TextboxObject:SetPlaceholder(newPlaceholder)
                Input.PlaceholderText = tostring(newPlaceholder or "")
            end

            function TextboxObject:Focus()
                if Input.Parent then
                    Input:CaptureFocus()
                end
            end

            function TextboxObject:Destroy()
                TextboxFrame:Destroy()
            end

            finish(TextboxFrame)

            return TextboxObject
        end

        function Tab:CreateDropdown(
            text,
            options,
            callback,
            itemOrder,
            customColor,
            multiSelect
        )
            assert(
                type(options) == "table"
                    or type(options) == "function",
                "MoonLib CreateDropdown options must be a table "
                    .. "or a function returning a table"
            )

            local isMulti =
                multiSelect == true
                or (
                    type(multiSelect) == "string"
                    and string.lower(multiSelect) == "multi"
                )

            -- `currentSource` is re-evaluated on every open and on
            -- Refresh(). Refresh(newOptions) replaces it permanently,
            -- so a manual update is not undone by the next open.
            local currentSource = options
            local refreshOnOpen = true

            local sortedOptions = {}
            local optionButtons = {}

            local baseColor = customColor or Theme.Card
            local isOpen = false

            local DropdownFrame = create("Frame", {
                Name = tostring(text) .. "Dropdown",
                Parent = Page,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 50),
                LayoutOrder = itemOrder or 0,
                ClipsDescendants = false,
                ZIndex = 30,
            })

            local Header = create("TextButton", {
                Name = "Header",
                Parent = DropdownFrame,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                Font = Enum.Font.GothamBold,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 31,
            })

            addCorner(Header, 3)
            addStroke(
                Header,
                customColor or Theme.BrightBorder,
                1,
                customColor and 0.18 or 0.35
            )

            local DropdownTitle = create("TextLabel", {
                Name = "Title",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(0.45, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 32,
            })

            local SelectedText = create("TextLabel", {
                Name = "Selected",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.45, 0, 0, 0),
                Size = UDim2.new(0.43, -5, 1, 0),
                Font = Enum.Font.Gotham,
                Text = "Select...",
                TextColor3 = Theme.SecondaryText,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 32,
            })

            local Arrow = create("TextLabel", {
                Name = "Arrow",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -37, 0, 0),
                Size = UDim2.new(0, 24, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = Theme.BlueLight,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 32,
            })

            local OptionsFrame = create("Frame", {
                Name = "Options",
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 58),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ClipsDescendants = false,
                ZIndex = 40,
            })

            addStroke(OptionsFrame, Theme.Border, 1, 0.15)

            local OptionsLayout = create("UIListLayout", {
                Parent = OptionsFrame,
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            })

            local function resolveOptions(source)
                local result = source

                if type(result) == "function" then
                    local success, returned = pcall(result)

                    if not success then
                        warn(
                            "MoonLib dropdown options function failed: "
                            .. tostring(returned)
                        )

                        return {}
                    end

                    result = returned
                end

                if type(result) ~= "table" then
                    warn(
                        "MoonLib dropdown options must be a table "
                        .. "or a function returning a table"
                    )

                    return {}
                end

                return result
            end

            local function getSelection()
                local selectedNames = {}
                local selectedIds = {}

                for _, option in ipairs(sortedOptions) do
                    if option.Selected then
                        table.insert(selectedNames, option.Value)
                        table.insert(selectedIds, option.Key)
                    end
                end

                return selectedNames, selectedIds
            end

            local function refreshHeader()
                local names = getSelection()

                if #names == 0 then
                    SelectedText.Text = "Select..."
                elseif not isMulti then
                    SelectedText.Text = names[1]
                elseif #names == 1 then
                    SelectedText.Text = names[1]
                else
                    SelectedText.Text = tostring(#names) .. " selected"
                end
            end

            local function refreshOption(option)
                local button = optionButtons[option]

                if not button then
                    return
                end

                button.BackgroundColor3 = option.Selected
                    and Theme.Blue
                    or Theme.PanelLight

                button.TextColor3 = option.Selected
                    and textColorFor(Theme.Blue)
                    or Theme.Text
            end

            local function getOptionsHeight()
                if #sortedOptions == 0 then
                    return 0
                end

                return (#sortedOptions * 36)
                    + ((#sortedOptions - 1) * 4)
                    + 8
            end

            local function updateDropdownSize()
                local height = getOptionsHeight()

                if isOpen and height > 0 then
                    OptionsFrame.Visible = true
                    OptionsFrame.Size = UDim2.new(1, 0, 0, height)

                    DropdownFrame.Size = UDim2.new(
                        1,
                        -8,
                        0,
                        58 + height
                    )

                    Arrow.Text = "▲"
                else
                    OptionsFrame.Visible = false
                    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)

                    DropdownFrame.Size = UDim2.new(
                        1,
                        -8,
                        0,
                        50
                    )

                    Arrow.Text = "▼"
                end

                updateCanvas(Page, PageLayout)
            end

            local function fireCallback()
                if not callback then
                    return
                end

                local names, ids = getSelection()

                if isMulti then
                    callback(names, ids)
                else
                    callback(names[1], ids[1])
                end
            end

            -- Rebuild the option list from `currentSource`. This is the
            -- only place options are read, so Refresh() and open-time
            -- refresh always produce a fresh list.
            local function rebuildOptions(newSource)
                if newSource ~= nil then
                    currentSource = newSource
                end

                local source = resolveOptions(currentSource)

                -- Keep selections whose displayed value still exists.
                local selectedBefore = {}

                for _, option in ipairs(sortedOptions) do
                    if option.Selected then
                        selectedBefore[option.Value] = true
                    end
                end

                for _, button in pairs(optionButtons) do
                    pcall(function()
                        button:Destroy()
                    end)
                end

                for index = #sortedOptions, 1, -1 do
                    sortedOptions[index] = nil
                end

                for key in pairs(optionButtons) do
                    optionButtons[key] = nil
                end

                for key, value in pairs(source) do
                    if type(value) == "string"
                        or type(value) == "number" then

                        table.insert(sortedOptions, {
                            Key = key,
                            Value = tostring(value),
                            Selected =
                                selectedBefore[tostring(value)] == true,
                        })
                    end
                end

                table.sort(sortedOptions, function(a, b)
                    if type(a.Key) == "number"
                        and type(b.Key) == "number" then

                        return a.Key < b.Key
                    end

                    return tostring(a.Key) < tostring(b.Key)
                end)

                for index, option in ipairs(sortedOptions) do
                    local OptionButton = create("TextButton", {
                        Name = "Option_" .. tostring(index),
                        Parent = OptionsFrame,
                        BackgroundColor3 = Theme.PanelLight,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -8, 0, 36),
                        Font = Enum.Font.GothamBold,
                        Text = option.Value,
                        TextColor3 = Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        LayoutOrder = index,
                        ZIndex = 41,
                    })

                    OptionButton.Position = UDim2.new(0, 4, 0, 0)

                    addCorner(OptionButton, 2)

                    optionButtons[option] = OptionButton

                    OptionButton.MouseEnter:Connect(function()
                        makeTween(OptionButton, 0.12, {
                            BackgroundColor3 = option.Selected
                                and Theme.BlueLight
                                or Theme.CardHover,
                        })
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        refreshOption(option)
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        if isMulti then
                            option.Selected = not option.Selected
                        else
                            for _, other in ipairs(sortedOptions) do
                                other.Selected = false
                            end

                            option.Selected = true
                            isOpen = false
                        end

                        for _, other in ipairs(sortedOptions) do
                            refreshOption(other)
                        end

                        refreshHeader()
                        updateDropdownSize()
                        fireCallback()
                    end)

                    refreshOption(option)
                end

                refreshHeader()
                updateDropdownSize()
            end

            Header.MouseEnter:Connect(function()
                makeTween(Header, 0.12, {
                    BackgroundColor3 = hoverColorFor(baseColor),
                })
            end)

            Header.MouseLeave:Connect(function()
                makeTween(Header, 0.12, {
                    BackgroundColor3 = baseColor,
                })
            end)

            Header.MouseButton1Click:Connect(function()
                isOpen = not isOpen

                -- Re-read the options every time the list expands.
                if isOpen and refreshOnOpen then
                    rebuildOptions()
                else
                    updateDropdownSize()
                end
            end)

            local DropdownObject = {
                Frame = DropdownFrame,
            }

            function DropdownObject:GetValue()
                local names = getSelection()

                if isMulti then
                    return names
                end

                return names[1]
            end

            function DropdownObject:GetIds()
                local _, ids = getSelection()

                if isMulti then
                    return ids
                end

                return ids[1]
            end

            function DropdownObject:GetSelection()
                return getSelection()
            end

            function DropdownObject:GetMode()
                return isMulti and "Multi" or "Single"
            end

            function DropdownObject:SetOpen(value)
                isOpen = value == true
                updateDropdownSize()
            end

            function DropdownObject:IsOpen()
                return isOpen
            end

            function DropdownObject:Clear(callCallback)
                for _, option in ipairs(sortedOptions) do
                    option.Selected = false
                    refreshOption(option)
                end

                refreshHeader()
                updateDropdownSize()

                if callCallback and callback then
                    fireCallback()
                end
            end

            function DropdownObject:SetValue(value, callCallback)
                local requestedValues = {}

                if isMulti then
                    if type(value) ~= "table" then
                        return false
                    end

                    requestedValues = value
                else
                    requestedValues = { value }
                end

                for _, option in ipairs(sortedOptions) do
                    option.Selected = false
                end

                local matched = false

                for _, requested in ipairs(requestedValues) do
                    for _, option in ipairs(sortedOptions) do
                        if option.Value == tostring(requested)
                            or option.Key == requested then

                            option.Selected = true
                            matched = true
                            break
                        end
                    end
                end

                for _, option in ipairs(sortedOptions) do
                    refreshOption(option)
                end

                refreshHeader()

                if not isMulti then
                    isOpen = false
                end

                updateDropdownSize()

                if callCallback and matched then
                    fireCallback()
                end

                return matched
            end

            -- ------------------------------------------------------
            -- NEW: force the option list to update.
            --
            --   Refresh()                 re-read the source now
            --   Refresh({"A", "B"})       replace the source with a
            --                            new table, then rebuild
            --   Refresh(getList, true)    also fire the callback with
            --                            the resulting selection
            -- ------------------------------------------------------
            function DropdownObject:Refresh(newOptions, callCallback)
                rebuildOptions(newOptions)

                if callCallback and callback then
                    fireCallback()
                end

                return true
            end

            function DropdownObject:SetOptions(newOptions, callCallback)
                return self:Refresh(newOptions, callCallback)
            end

            function DropdownObject:GetOptions()
                local values = {}
                local ids = {}

                for _, option in ipairs(sortedOptions) do
                    table.insert(values, option.Value)
                    table.insert(ids, option.Key)
                end

                return values, ids
            end

            function DropdownObject:SetRefreshOnOpen(value)
                refreshOnOpen = value == true
            end

            function DropdownObject:GetSource()
                return currentSource
            end

            function DropdownObject:Destroy()
                DropdownFrame:Destroy()
            end

            rebuildOptions()

            return finish(DropdownObject)
        end

        return Tab
    end

    function Window:SetTitle(newTitle)
        WindowTitle.Text = tostring(newTitle or "")
    end

    function Window:SetImage(image)
        setImage(WindowImage, image)

        WindowTitle.Position = UDim2.new(
            0,
            normalizeImage(image) and 72 or 18,
            0,
            0
        )
    end

    function Window:SetStateKeybind(keyCode)
        if typeof(keyCode) ~= "EnumItem"
            or keyCode.EnumType ~= Enum.KeyCode then
    
            warn(
                "MoonLib SetStateKeybind expects an Enum.KeyCode value."
            )
    
            return false
        end
    
        stateKeybind = keyCode
    
        return true
    end
    
    function Window:GetStateKeybind()
        return stateKeybind
    end
    
    function Window:SelectTab(tabName)
        for _, record in ipairs(tabs) do
            if record.Name == tostring(tabName) then
                selectTab(record)
                return true
            end
        end

        return false
    end

    function Window:Toggle()
        toggleWindow()
    end

    function Window:IsVisible()
        return visible
    end

    function Window:Destroy()
        if destroyed then
            return
        end

        destroyed = true

        for _, connection in ipairs(connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end

        stopBackgroundAnimation()
        ScreenGui:Destroy()
    end

    -- // Window appearance API

    local mainColor = Theme.Blue
    local backgroundValue = Theme.MainBackground
    local backgroundTransparency = 0
    local backgroundAnimationConnection = nil
    local backgroundAnimationToken = 0

    stopBackgroundAnimation = function()
        backgroundAnimationToken += 1
        if backgroundAnimationConnection then
            backgroundAnimationConnection:Disconnect()
            backgroundAnimationConnection = nil
        end
        BackgroundImage.ImageRectOffset = Vector2.zero
        BackgroundImage.ImageRectSize = Vector2.zero
    end

    local function replaceColorInGui(oldColor, newColor)
        for _, object in ipairs(ScreenGui:GetDescendants()) do
            pcall(function()
                if object:IsA("GuiObject") then
                    if object.BackgroundColor3 == oldColor then
                        object.BackgroundColor3 = newColor
                    end
                    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                        if object.TextColor3 == oldColor then
                            object.TextColor3 = newColor
                        end
                    end
                    if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                        if object.ImageColor3 == oldColor then
                            object.ImageColor3 = newColor
                        end
                    end
                elseif object:IsA("UIStroke") then
                    if object.Color == oldColor then
                        object.Color = newColor
                    end
                elseif object:IsA("UIGradient") then
                    local keypoints = {}
                    for _, keypoint in ipairs(object.Color.Keypoints) do
                        local color = keypoint.Value == oldColor and newColor or keypoint.Value
                        table.insert(keypoints, ColorSequenceKeypoint.new(keypoint.Time, color))
                    end
                    object.Color = ColorSequence.new(keypoints)
                end
            end)
        end
    end

    function Window:SetMainColor(color)
        assert(typeof(color) == "Color3", "SetMainColor expects a Color3")

        local oldBlue = Theme.Blue
        local oldBlueLight = Theme.BlueLight
        local oldBlueDark = Theme.BlueDark
        local oldHeaderGradient = Color3.fromRGB(30, 67, 90)

        local newLight = color:Lerp(Color3.new(1, 1, 1), 0.28)
        local newDark = color:Lerp(Color3.new(0, 0, 0), 0.48)
        local newHeaderGradient = color:Lerp(Color3.new(0, 0, 0), 0.58)

        replaceColorInGui(oldBlue, color)
        replaceColorInGui(oldBlueLight, newLight)
        replaceColorInGui(oldBlueDark, newDark)
        replaceColorInGui(oldHeaderGradient, newHeaderGradient)

        Theme.Blue = color
        Theme.BlueLight = newLight
        Theme.BlueDark = newDark
        mainColor = color

        HeaderLine.BackgroundColor3 = color
        if TopBarGradient then
            TopBarGradient.Color = ColorSequence.new(color, newHeaderGradient)
        end

        return true
    end

    function Window:GetMainColor()
        return mainColor
    end

    function Window:SetBackground(value)
        stopBackgroundAnimation()
        backgroundValue = value

        if typeof(value) == "Color3" then
            BackgroundImage.Visible = false
            BackgroundImage.Image = ""
            MainFrame.BackgroundColor3 = value
            InnerFrame.BackgroundColor3 = value
            InnerFrame.BackgroundTransparency = 1
            InnerGradient.Enabled = false
            backgroundTransparency = 0
            return true
        end

        local config = type(value) == "table" and value or nil
        local image = config and (config.Image or config.image) or value
        local normalized = normalizeImage(image)

        if not normalized then
            BackgroundImage.Visible = false
            BackgroundImage.Image = ""
            MainFrame.BackgroundColor3 = Theme.MainBackground
            InnerFrame.BackgroundTransparency = 1
            InnerGradient.Enabled = false
            return false
        end

        -- Standard Roblox ImageLabels use asset content IDs. In executor
        -- environments that expose these file APIs, allow HTTP images by
        -- downloading them and converting the file into a custom asset.
        if normalized:match("^https?://")
            and type(getcustomasset) == "function"
            and type(writefile) == "function"
            and type(game.HttpGet) == "function" then

            local success, customAsset = pcall(function()
                local response = game:HttpGet(normalized)
                local extension = normalized:match("%.([%w]+)[%?]?.*$") or "png"
                local fileName = "MoonLibBackground_" .. tostring(math.floor(os.clock() * 100000)) .. "." .. extension
                writefile(fileName, response)
                return getcustomasset(fileName)
            end)

            if success and customAsset then
                normalized = customAsset
            end
        end

        MainFrame.BackgroundColor3 = Theme.MainBackground
        InnerFrame.BackgroundTransparency = 1
        InnerGradient.Enabled = false
        local imageSuccess = pcall(function()
            BackgroundImage.Image = normalized
        end)
        if not imageSuccess then
            BackgroundImage.Visible = false
            return false
        end
        BackgroundImage.ImageTransparency = math.clamp(config and (config.ImageTransparency or config.Transparency) or 0, 0, 1)
        BackgroundImage.ScaleType = config and config.ScaleType or Enum.ScaleType.Crop
        BackgroundImage.Visible = true

        local rows = math.max(1, math.floor(config and config.Rows or 1))
        local columns = math.max(1, math.floor(config and config.Columns or 1))
        local frameCount = math.max(1, math.floor(config and config.FrameCount or rows * columns))
        local frameRate = math.max(1, tonumber(config and config.FrameRate) or 12)

        if frameCount > 1 and (rows > 1 or columns > 1) then
            local imageSize = config and config.ImageSize
            if typeof(imageSize) ~= "Vector2" then
                imageSize = Vector2.new(1024, 1024)
            end
            local frameSize = Vector2.new(imageSize.X / columns, imageSize.Y / rows)
            BackgroundImage.ImageRectSize = frameSize

            local frame = 0
            local elapsed = 0
            local token = backgroundAnimationToken
            backgroundAnimationConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if destroyed or token ~= backgroundAnimationToken then
                    return
                end
                elapsed += deltaTime
                local frameDuration = 1 / frameRate
                if elapsed >= frameDuration then
                    local steps = math.floor(elapsed / frameDuration)
                    elapsed -= steps * frameDuration
                    frame = (frame + steps) % frameCount
                    local column = frame % columns
                    local row = math.floor(frame / columns)
                    BackgroundImage.ImageRectOffset = Vector2.new(column * frameSize.X, row * frameSize.Y)
                end
            end)
        end

        return true
    end

    function Window:GetBackground()
        return backgroundValue
    end

    function Window:SetBackgroundTransparency(transparency)
        transparency = math.clamp(tonumber(transparency) or 0, 0, 1)
        backgroundTransparency = transparency
        BackgroundImage.ImageTransparency = transparency
        if not BackgroundImage.Visible then
            MainFrame.BackgroundTransparency = transparency
        end
        return true
    end

    function Window:GetBackgroundTransparency()
        return backgroundTransparency
    end

    function Window:SetTitle(newTitle)
        WindowTitle.Text = tostring(newTitle or "")
    end

    function Window:GetTitle()
        return WindowTitle.Text
    end

    function Window:SetWindowImage(image)
        setImage(WindowImage, image)
        WindowTitle.Position = UDim2.new(0, normalizeImage(image) and 72 or 18, 0, 0)
    end

    function Window:SetSize(size)
        assert(typeof(size) == "UDim2", "SetSize expects a UDim2")
        MainFrame.Size = size
    end

    function Window:SetPosition(position)
        assert(typeof(position) == "UDim2", "SetPosition expects a UDim2")
        MainFrame.Position = position
    end

    function Window:SetVisible(state)
        visible = state == true
        MainFrame.Visible = visible
    end

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.Theme = Theme

    return Window
end

return MoonLib
