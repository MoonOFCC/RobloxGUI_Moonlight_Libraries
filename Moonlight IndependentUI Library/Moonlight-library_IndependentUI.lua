-- MoonUI: a lightweight, client-side Roblox UI library for legitimate Roblox experiences.
-- #: Upgraded with Dropdown Refresh Support
-- #: Upgraded with Floating Window support (window:CreateFloatingWindow)

local MoonUI = {}
MoonUI.__index = MoonUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local COLORS = {
    background = Color3.fromRGB(24, 25, 29),
    sidebar = Color3.fromRGB(29, 30, 35),
    surface = Color3.fromRGB(37, 39, 45),
    surfaceHover = Color3.fromRGB(47, 49, 57),
    text = Color3.fromRGB(239, 240, 244),
    muted = Color3.fromRGB(151, 155, 166),
    accent = Color3.fromRGB(119, 94, 255),
    track = Color3.fromRGB(63, 65, 74),
}

local function corner(parent: Instance, radius: number)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent: Instance, color: Color3?, transparency: number?)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255, 255, 255)
    s.Transparency = transparency or 0.9
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function make(className: string, props: {[string]: any}, parent: Instance)
    local inst = Instance.new(className)
    for key, value in pairs(props) do
        (inst :: any)[key] = value
    end
    inst.Parent = parent
    return inst
end

local function textLabel(parent: Instance, text: string, size: number, color: Color3, bold: boolean?)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
        Text = text,
        TextColor3 = color,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end

local function addListLayout(parent: Instance, padding: number?)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function normalizeOptions(options: any)
    local result = {}
    if type(options) ~= "table" then return result end
    for key, value in pairs(options) do
        if type(value) == "string" or type(value) == "number" then
            table.insert(result, {key = key, value = tostring(value), selected = false})
        end
    end
    table.sort(result, function(a, b)
        if type(a.key) == "number" and type(b.key) == "number" then
            return a.key < b.key
        end
        return tostring(a.key) < tostring(b.key)
    end)
    return result
end

local function draggable(handle: GuiObject, target: GuiObject)
    local dragging = false
    local inputStart: Vector3? = nil
    local frameStart: UDim2? = nil
    local moveConnection: RBXScriptConnection? = nil
    local endConnection: RBXScriptConnection? = nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = true
        inputStart = input.Position
        frameStart = target.Position
        if moveConnection then moveConnection:Disconnect() end
        if endConnection then endConnection:Disconnect() end
        moveConnection = UserInputService.InputChanged:Connect(function(changed)
            if not dragging or not inputStart or not frameStart then return end
            if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
                local delta = changed.Position - inputStart
                target.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
            end
        end)
        endConnection = UserInputService.InputEnded:Connect(function(ended)
            if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
                if endConnection then endConnection:Disconnect(); endConnection = nil end
            end
        end)
    end)
end

local function makePage(parent: Instance)
    local page = make("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLORS.muted,
        Visible = false,
    }, parent)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 3)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = page
    addListLayout(page, 8)
    return page
end

local function createControls(context, page: ScrollingFrame)
    local controls = {}
    local function addCard(name: string, height: number, order: number?)
        local card = make("Frame", {
            Name = name,
            BackgroundColor3 = COLORS.surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -2, 0, height),
            LayoutOrder = order or 0,
        }, page)
        corner(card, 9)
        return card
    end

    function controls:CreateLabel(text, order)
        local label = textLabel(page, tostring(text), 14, COLORS.muted, false)
        label.Size = UDim2.new(1, -8, 0, 22)
        label.LayoutOrder = order or 0
        return label
    end

    function controls:CreateButton(text, callback, customColor, order)
        local button = make("TextButton", {
            BackgroundColor3 = customColor or COLORS.surface,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -2, 0, 40),
            Font = Enum.Font.GothamSemibold,
            Text = tostring(text),
            TextColor3 = COLORS.text,
            TextSize = 14,
            AutoButtonColor = false,
            LayoutOrder = order or 0,
        }, page)
        corner(button, 9)
        button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.surfaceHover}):Play() end)
        button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = customColor or COLORS.surface}):Play() end)
        button.Activated:Connect(function() if callback then callback() end end)
        return button
    end

    function controls:CreateToggle(text, default, callback, order)
        local value = default == true
        local card = addCard(tostring(text) .. "Toggle", 44, order)
        local title = textLabel(card, tostring(text), 14, COLORS.text, true)
        title.Position = UDim2.new(0, 13, 0, 0)
        title.Size = UDim2.new(1, -72, 1, 0)
        local switch = make("Frame", {BackgroundColor3 = value and COLORS.accent or COLORS.track, Position = UDim2.new(1, -52, 0.5, -10), Size = UDim2.new(0, 40, 0, 20)}, card)
        corner(switch, 12)
        local knob = make("Frame", {BackgroundColor3 = Color3.new(1,1,1), Position = value and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2), Size = UDim2.new(0,16,0,16)}, switch)
        corner(knob, 10)
        local hit = make("TextButton", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = "", ZIndex = 2}, card)
        local function render(notify)
            switch.BackgroundColor3 = value and COLORS.accent or COLORS.track
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = value and UDim2.new(1,-18,0,2) or UDim2.new(0,2,0,2)}):Play()
            if notify and callback then callback(value) end
        end
        hit.Activated:Connect(function() value = not value; render(true) end)
        local api = {}
        function api:GetValue() return value end
        function api:SetValue(nextValue, notify) value = nextValue == true; render(notify == true) end
        function api:Destroy() card:Destroy() end
        return api
    end

    function controls:CreateSlider(text, defaultValue, min, max, callback, order, step)
        min = tonumber(min) or 0; max = tonumber(max) or 100
        if min > max then min, max = max, min end
        if min == max then max = min + 1 end
        step = math.max(tonumber(step) or 1, 0.000001)
        local value = math.clamp(tonumber(defaultValue) or min, min, max)
        local card = addCard(tostring(text) .. "Slider", 72, order)
        local title = textLabel(card, tostring(text), 14, COLORS.text, true)
        title.Position = UDim2.new(0,13,0,7); title.Size = UDim2.new(1,-90,0,22)
        local display = textLabel(card, tostring(value), 13, COLORS.muted, false)
        display.TextXAlignment = Enum.TextXAlignment.Right; display.Position = UDim2.new(1,-72,0,7); display.Size = UDim2.new(0,58,0,22)
        local track = make("TextButton", {BackgroundColor3 = COLORS.track, BorderSizePixel = 0, Position = UDim2.new(0,13,0,43), Size = UDim2.new(1,-26,0,8), Text = "", AutoButtonColor = false}, card)
        corner(track, 5)
        local fill = make("Frame", {BackgroundColor3 = COLORS.accent, BorderSizePixel = 0, Size = UDim2.new(0,0,1,0)}, track); corner(fill,5)
        local thumb = make("Frame", {BackgroundColor3 = COLORS.text, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0,0,0.5,0), Size = UDim2.new(0,14,0,14)}, track); corner(thumb,10)
        local function setFromX(x, notify)
            local width = track.AbsoluteSize.X
            if width <= 0 then return end
            local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
            local raw = min + (max - min) * alpha
            value = math.clamp(min + math.floor((raw - min) / step + 0.5) * step, min, max)
            local ratio = (value - min) / (max - min)
            fill.Size = UDim2.new(ratio,0,1,0); thumb.Position = UDim2.new(ratio,0,0.5,0); display.Text = tostring(value)
            if notify and callback then callback(value) end
        end
        local isDragging = false
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true; setFromX(input.Position.X, true)
            end
        end)
        local moveConn = UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X, true) end
        end)
        local endConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
        end)
        setFromX(track.AbsolutePosition.X + track.AbsoluteSize.X * ((value-min)/(max-min)), false)
        local api = {}
        function api:GetValue() return value end
        function api:SetValue(nextValue, notify) value = math.clamp(tonumber(nextValue) or min, min, max); setFromX(track.AbsolutePosition.X + track.AbsoluteSize.X*((value-min)/(max-min)), notify == true) end
        function api:Destroy() moveConn:Disconnect(); endConn:Disconnect(); card:Destroy() end
        return api
    end

    function controls:CreateDropdown(text, options, callback, order, multiSelect)
        local items = normalizeOptions(options)
        local multi = multiSelect == true or (type(multiSelect) == "string" and string.lower(multiSelect) == "multi")
        local selected = {}
        local open = false
        local card = make("Frame", {Name = tostring(text) .. "Dropdown", BackgroundTransparency = 1, Size = UDim2.new(1,-2,0,40), ClipsDescendants = false, LayoutOrder = order or 0, ZIndex = 5}, page)
        local header = make("TextButton", {BackgroundColor3 = COLORS.surface, BorderSizePixel = 0, Size = UDim2.new(1,0,0,40), Text = "", AutoButtonColor = false, ZIndex = 6}, card)
        corner(header, 9)
        local title = textLabel(header, tostring(text), 14, COLORS.text, true); title.Position = UDim2.new(0,13,0,0); title.Size = UDim2.new(0.48,0,1,0); title.ZIndex = 7
        local chosen = textLabel(header, "Select…", 13, COLORS.muted, false); chosen.TextXAlignment = Enum.TextXAlignment.Right; chosen.Position = UDim2.new(0.48,0,0,0); chosen.Size = UDim2.new(0.44,-8,1,0); chosen.ZIndex = 7
        local arrow = textLabel(header, "⌄", 18, COLORS.muted, true); arrow.TextXAlignment = Enum.TextXAlignment.Center; arrow.Position = UDim2.new(1,-30,0,0); arrow.Size = UDim2.new(0,22,1,0); arrow.ZIndex = 7
        local list = make("ScrollingFrame", {BackgroundColor3 = COLORS.surface, BorderSizePixel = 0, Position = UDim2.new(0,0,0,44), Size = UDim2.new(1,0,0,0), Visible = false, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ZIndex = 8}, card)
        corner(list, 8); addListLayout(list, 3)

        local function refresh()
            local names = {}
            for _, item in ipairs(items) do if selected[item.key] then table.insert(names,item.value) end end
            if #names == 0 then chosen.Text = "Select…" elseif multi and #names > 1 then chosen.Text = tostring(#names) .. " selected" else chosen.Text = names[1] end
            for _, item in ipairs(items) do
                if item.button then item.button.BackgroundColor3 = selected[item.key] and COLORS.accent or COLORS.surfaceHover end
            end
        end

        local function callbackValue()
            if not callback then return end
            local names, ids = {}, {}
            for _, item in ipairs(items) do if selected[item.key] then table.insert(names,item.value); table.insert(ids,item.key) end end
            if multi then callback(names, ids) else callback(names[1], ids[1]) end
        end

        local function buildItems()
            -- Clear existing option buttons if rebuilding
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            for i, item in ipairs(items) do
                local option = make("TextButton", {BackgroundColor3 = COLORS.surfaceHover, BorderSizePixel = 0, Size = UDim2.new(1,-8,0,32), Position = UDim2.new(0,4,0,0), Font = Enum.Font.Gotham, Text = "  " .. item.value, TextColor3 = COLORS.text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = i, ZIndex = 9}, list)
                corner(option,6); item.button = option
                option.Activated:Connect(function()
                    if multi then selected[item.key] = not selected[item.key] else selected = {[item.key] = true}; open = false; list.Visible = false; card.Size = UDim2.new(1,-2,0,40); arrow.Text = "⌄" end
                    refresh(); callbackValue()
                end)
            end
            refresh()
        end

        buildItems()

        header.Activated:Connect(function()
            open = not open; list.Visible = open; arrow.Text = open and "⌃" or "⌄"
            local height = math.min(#items * 35, 175)
            list.Size = UDim2.new(1,0,0,open and height or 0)
            card.Size = UDim2.new(1,-2,0,open and (44 + height) or 40)
        end)

        local api = {}
        function api:GetValue()
            local names = {}; for _, item in ipairs(items) do if selected[item.key] then table.insert(names,item.value) end end
            if multi then return names end; return names[1]
        end
        function api:GetIds()
            local ids = {}; for _, item in ipairs(items) do if selected[item.key] then table.insert(ids,item.key) end end
            if multi then return ids end; return ids[1]
        end
        function api:SetValue(value, notify)
            selected = {}
            if multi then
                if type(value) ~= "table" then return false end
                for _, v in ipairs(value) do for _, item in ipairs(items) do if item.key == v or item.value == tostring(v) then selected[item.key] = true end end end
            else
                for _, item in ipairs(items) do if item.key == value or item.value == tostring(value) then selected[item.key] = true; break end end
            end
            refresh(); if notify then callbackValue() end; return true
        end
        
        -- NEW: SetOptions / Refresh method added here!
        function api:SetOptions(newOptions)
            items = normalizeOptions(newOptions)
            -- Clear selections that no longer exist
            local newSelected = {}
            for _, item in ipairs(items) do
                if selected[item.key] then
                    newSelected[item.key] = true
                end
            end
            selected = newSelected
            
            buildItems()
            
            -- Reset open state visual bounds if list is open
            if open then
                local height = math.min(#items * 35, 175)
                list.Size = UDim2.new(1,0,0,height)
                card.Size = UDim2.new(1,-2,0,44 + height)
            else
                card.Size = UDim2.new(1,-2,0,40)
            end
        end

        function api:Destroy() card:Destroy() end
        return api
    end

    function controls:CreateTextbox(text, placeholder, callback, order)
        local card = addCard(tostring(text) .. "Textbox", 68, order)
        local title = textLabel(card, tostring(text), 13, COLORS.muted, false)
        title.Position = UDim2.new(0,13,0,5); title.Size = UDim2.new(1,-26,0,20)
        local box = make("TextBox", {BackgroundColor3 = COLORS.background, BorderSizePixel = 0, Position = UDim2.new(0,10,0,31), Size = UDim2.new(1,-20,0,28), Font = Enum.Font.Gotham, PlaceholderText = placeholder or "Type here…", PlaceholderColor3 = COLORS.muted, Text = "", TextColor3 = COLORS.text, TextSize = 13, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left}, card)
        corner(box,6)
        local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0,8); pad.Parent = box
        box.FocusLost:Connect(function(enterPressed) if callback then callback(box.Text, enterPressed) end end)
        local api = {}; function api:GetValue() return box.Text end; function api:SetValue(value) box.Text = tostring(value) end; function api:Destroy() card:Destroy() end
        return api
    end
    return controls
end

function MoonUI:CreateWindow(title: string?, options: {[string]: any}?)
    options = options or {}
    local player = Players.LocalPlayer
    assert(player, "MoonUI must be required from a LocalScript on the client")
    local playerGui = options.Parent or player:WaitForChild("PlayerGui")
    local old = playerGui:FindFirstChild(options.Name or "MoonUI")
    if old then old:Destroy() end

    local screen = make("ScreenGui", {Name = options.Name or "MoonUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = options.DisplayOrder or 20}, playerGui)
    local window = {ScreenGui = screen, _destroyed = false, _tabs = {}, _floating = {}}
    local width = options.Width or 660
    local height = options.Height or 430
    local main = make("Frame", {Name = "Main", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(0,width,0,height), BackgroundColor3 = COLORS.background, BorderSizePixel = 0, ClipsDescendants = true}, screen)
    corner(main, 12); stroke(main, Color3.fromRGB(255,255,255), 0.91)
    local top = make("Frame", {Name = "Topbar", BackgroundColor3 = COLORS.background, BorderSizePixel = 0, Size = UDim2.new(1,0,0,54)}, main)
    local titleLabel = textLabel(top, title or "MoonUI", 16, COLORS.text, true); titleLabel.Position = UDim2.new(0,20,0,0); titleLabel.Size = UDim2.new(1,-110,1,0)
    local hide = make("TextButton", {BackgroundColor3 = COLORS.surface, BorderSizePixel = 0, Position = UDim2.new(1,-82,0,12), Size = UDim2.new(0,30,0,30), Font = Enum.Font.GothamBold, Text = "−", TextColor3 = COLORS.text, TextSize = 20, AutoButtonColor = false}, top); corner(hide,8)
    local close = make("TextButton", {BackgroundColor3 = Color3.fromRGB(77,43,52), BorderSizePixel = 0, Position = UDim2.new(1,-43,0,12), Size = UDim2.new(0,30,0,30), Font = Enum.Font.GothamBold, Text = "×", TextColor3 = Color3.fromRGB(255,143,158), TextSize = 20, AutoButtonColor = false}, top); corner(close,8)
    draggable(top, main)
    local sidebarWidth = options.SidebarWidth or 158
    local sidebar = make("Frame", {Name = "Sidebar", BackgroundColor3 = COLORS.sidebar, BorderSizePixel = 0, Position = UDim2.new(0,0,0,54), Size = UDim2.new(0,sidebarWidth,1,-54)}, main)
    local tabList = make("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0,10,0,12), Size = UDim2.new(1,-20,1,-24)}, sidebar)
    addListLayout(tabList,5)
    local content = make("Frame", {Name = "Content", BackgroundTransparency = 1, Position = UDim2.new(0,sidebarWidth+18,0,69), Size = UDim2.new(1,-sidebarWidth-30,1,-84)}, main)
    local active = nil

    local function createTab(owner, tabParent, pageParent, name)
        local tab = {Name = tostring(name)}
        local button = make("TextButton", {BackgroundColor3 = COLORS.accent, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,0,37), Font = Enum.Font.GothamSemibold, Text = tostring(name), TextColor3 = COLORS.muted, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false}, tabParent)
        local leftPad = Instance.new("UIPadding"); leftPad.PaddingLeft = UDim.new(0,12); leftPad.Parent = button; corner(button,8)
        local page = makePage(pageParent)
        tab.Page, tab.Button = page, button
        local function select()
            if owner._activeTab then
                owner._activeTab.Page.Visible = false
                owner._activeTab.Button.BackgroundTransparency = 1
                owner._activeTab.Button.TextColor3 = COLORS.muted
            end
            owner._activeTab = tab; page.Visible = true; button.BackgroundTransparency = 0; button.TextColor3 = COLORS.text
        end
        button.Activated:Connect(select)
        local controls = createControls(owner, page)
        for key, method in pairs(controls) do if type(method) == "function" then tab[key] = method end end
        tab.Select = select
        function tab:Destroy() if owner._activeTab == tab then owner._activeTab = nil end; button:Destroy(); page:Destroy() end
        return tab
    end

    function window:CreateTab(name)
        assert(not self._destroyed, "Window has been destroyed")
        local tab = createTab(self, tabList, content, name)
        table.insert(self._tabs, tab)
        if #self._tabs == 1 then tab.Select() end
        return tab
    end

    -- # NEW: independent, draggable, resizable floating mini-windows.
    -- Each one gets its own ScreenGui so it can sit outside/above the main
    -- window, and its own scrolling page with the full Create* control set.
    function window:CreateFloatingWindow(title, options)
        assert(not self._destroyed, "Window has been destroyed")
        options = options or {}
        local owner = self

        owner._floatingCount = (owner._floatingCount or 0) + 1
        local index = owner._floatingCount

        local floatW = tonumber(options.Width) or 300
        local floatH = tonumber(options.Height) or 200
        local minW = tonumber(options.MinWidth) or 180
        local minH = tonumber(options.MinHeight) or 120
        local guiParent = owner.ScreenGui.Parent

        local gui = make("ScreenGui", {
            Name = options.Name or ("MoonUI_Floating_" .. tostring(index)),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = options.DisplayOrder or (owner.ScreenGui.DisplayOrder + index),
        }, guiParent)

        local frame = make("Frame", {
            Name = "Floating",
            Position = options.Position or UDim2.new(0.5, -floatW / 2, 0.5, -floatH / 2),
            Size = UDim2.new(0, floatW, 0, floatH),
            BackgroundColor3 = COLORS.background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, gui)
        corner(frame, 10)
        stroke(frame, Color3.fromRGB(255, 255, 255), 0.91)

        local topbar = make("Frame", {
            Name = "Topbar",
            BackgroundColor3 = COLORS.background,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 34),
        }, frame)
        local floatTitle = textLabel(topbar, title or "Floating", 14, COLORS.text, true)
        floatTitle.Position = UDim2.new(0, 12, 0, 0)
        floatTitle.Size = UDim2.new(1, -76, 1, 0)

        local minimize = make("TextButton", {
            BackgroundColor3 = COLORS.surface,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -58, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = "−",
            TextColor3 = COLORS.text,
            TextSize = 16,
            AutoButtonColor = false,
        }, topbar)
        corner(minimize, 6)

        local floatClose = make("TextButton", {
            BackgroundColor3 = Color3.fromRGB(77, 43, 52),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 0.5, -12),
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 143, 158),
            TextSize = 16,
            AutoButtonColor = false,
        }, topbar)
        corner(floatClose, 6)

        draggable(topbar, frame)

        local floatContent = make("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 38),
            Size = UDim2.new(1, -12, 1, -44),
        }, frame)
        local page = makePage(floatContent)
        page.Visible = true -- makePage() starts pages hidden for the tab system

        local controls = createControls(self, page)

        -- resize grip, bottom-right corner
        local grip = make("TextButton", {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.new(0, 16, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = "◢",
            TextColor3 = COLORS.muted,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Bottom,
            AutoButtonColor = false,
            ZIndex = 3,
        }, frame)

        local resizing = false
        local resizeStartPos = nil
        local resizeStartSize = nil
        grip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStartPos = input.Position
                resizeStartSize = frame.AbsoluteSize
            end
        end)
        local gripMove = UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStartPos
                frame.Size = UDim2.new(
                    0, math.max(resizeStartSize.X + delta.X, minW),
                    0, math.max(resizeStartSize.Y + delta.Y, minH)
                )
            end
        end)
        local gripEnd = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)

        local floating = {
            Name = gui.Name,
            ScreenGui = gui,
            Frame = frame,
            Page = page,
            _destroyed = false,
        }
        for key, method in pairs(controls) do
            if type(method) == "function" then floating[key] = method end
        end

        function floating:SetVisible(visible) frame.Visible = visible == true end
        function floating:Toggle() frame.Visible = not frame.Visible end
        function floating:SetTitle(text) floatTitle.Text = tostring(text) end
        function floating:SetPosition(position) frame.Position = position end
        function floating:SetSize(size) frame.Size = size end
        function floating:Destroy()
            if floating._destroyed then return end
            floating._destroyed = true
            gripMove:Disconnect()
            gripEnd:Disconnect()
            for i = #owner._floating, 1, -1 do
                if owner._floating[i] == floating then table.remove(owner._floating, i) end
            end
            gui:Destroy()
        end

        minimize.Activated:Connect(function() floating:SetVisible(false) end)
        floatClose.Activated:Connect(function() floating:Destroy() end)

        table.insert(owner._floating, floating)
        return floating
    end

    function window:SetVisible(visible) main.Visible = visible == true end
    function window:Toggle() main.Visible = not main.Visible end
    function window:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        -- close every floating window this main window owns first
        for i = #self._floating, 1, -1 do
            self._floating[i]:Destroy()
        end
        screen:Destroy()
    end
    hide.Activated:Connect(function() window:SetVisible(false) end)
    close.Activated:Connect(function() window:Destroy() end)
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local keyConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey and not window._destroyed then window:Toggle() end
    end)
    screen.Destroying:Connect(function() keyConnection:Disconnect() end)

    return window
end

return MoonUI
