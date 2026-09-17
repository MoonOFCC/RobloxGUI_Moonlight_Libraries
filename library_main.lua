function Tab:CreateDropdown(
    text,
    options,
    callback,
    order,
    customColor,
    multiSelect
)
    assert(
        type(options) == "table",
        "CreateDropdown options must be a table"
    )

    local isMultiSelect =
        multiSelect == true
        or (
            type(multiSelect) == "string"
            and string.lower(multiSelect) == "multi"
        )

    local sortedOptions = {}

    for key, value in pairs(options) do
        if type(value) == "string" then
            table.insert(sortedOptions, {
                key = key,
                value = value,
                selected = false
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

    local baseColor = customColor or Color3.fromRGB(45, 45, 45)
    local textColor = getTextColor(baseColor)
    local hoverColor = getHoverColor(baseColor)
    local optionColor = getOptionColor(baseColor)

    local selectedColor = Color3.fromRGB(0, 170, 255)
    local selectedTextColor = getTextColor(selectedColor)

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
    DropdownFrame.ZIndex = 100

    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Parent = DropdownFrame
    Header.BackgroundColor3 = baseColor
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, headerHeight)
    Header.AutoButtonColor = false
    Header.Text = ""
    Header.ZIndex = 101

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
    TitleText.ZIndex = 102

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
    SelectedText.ZIndex = 102

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
    Arrow.ZIndex = 102

    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "Options"
    OptionsContainer.Parent = DropdownFrame
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.BorderSizePixel = 0
    OptionsContainer.Position = UDim2.new(0, 0, 0, optionsTopOffset)
    OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
    OptionsContainer.Visible = false
    OptionsContainer.ClipsDescendants = false
    OptionsContainer.ZIndex = 103

    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.Parent = OptionsContainer
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Padding = UDim.new(0, optionPadding)

    local function getOptionsHeight()
        if #sortedOptions == 0 then
            return 0
        end

        return (#sortedOptions * optionHeight)
            + ((#sortedOptions - 1) * optionPadding)
    end

    local function getSelectedValues()
        local selectedNames = {}
        local selectedIds = {}

        for _, option in ipairs(sortedOptions) do
            if option.selected then
                table.insert(selectedNames, option.value)
                table.insert(selectedIds, option.key)
            end
        end

        return selectedNames, selectedIds
    end

    local function updateHeader()
        local selectedNames = getSelectedValues()

        if #selectedNames == 0 then
            SelectedText.Text = "Select..."
        elseif not isMultiSelect then
            SelectedText.Text = selectedNames[1]
        elseif #selectedNames == 1 then
            SelectedText.Text = selectedNames[1]
        else
            SelectedText.Text = tostring(#selectedNames) .. " selected"
        end
    end

    local function updateOptionVisual(option)
        if not option.button then
            return
        end

        if option.selected then
            option.button.BackgroundColor3 = selectedColor
            option.button.TextColor3 = selectedTextColor
        else
            option.button.BackgroundColor3 = optionColor
            option.button.TextColor3 = textColor
        end
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

        task.defer(function()
            if Page and Page.Parent then
                Page.CanvasSize = UDim2.new(
                    0,
                    0,
                    0,
                    PageLayout.AbsoluteContentSize.Y + 10
                )
            end
        end)
    end

    local function setOpen(state)
        if #sortedOptions == 0 then
            return
        end

        isOpen = state == true
        OptionsContainer.Visible = isOpen
        Arrow.Text = isOpen and "▲" or "▼"

        updateDropdownSize()
    end

    local function fireCallback()
        if not callback then
            return
        end

        if isMultiSelect then
            local selectedNames, selectedIds = getSelectedValues()
            callback(selectedNames, selectedIds)
        else
            local selectedNames, selectedIds = getSelectedValues()
            callback(selectedNames[1], selectedIds[1])
        end
    end

    local function selectSingle(option, callCallback)
        for _, otherOption in ipairs(sortedOptions) do
            otherOption.selected = false
            updateOptionVisual(otherOption)
        end

        option.selected = true
        updateOptionVisual(option)
        updateHeader()
        setOpen(false)

        if callCallback then
            fireCallback()
        end
    end

    local function toggleMulti(option, callCallback)
        option.selected = not option.selected

        updateOptionVisual(option)
        updateHeader()

        -- Keep the dropdown open in multi-select mode so
        -- multiple options can be toggled without reopening it.
        if callCallback then
            fireCallback()
        end
    end

    for index, option in ipairs(sortedOptions) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "Option_" .. tostring(index)
        OptionButton.Parent = OptionsContainer
        OptionButton.BackgroundColor3 = optionColor
        OptionButton.BorderSizePixel = 0
        OptionButton.Size = UDim2.new(1, 0, 0, optionHeight)
        OptionButton.AutoButtonColor = false
        OptionButton.Font = Enum.Font.GothamBold
        OptionButton.Text = option.value
        OptionButton.TextColor3 = textColor
        OptionButton.TextSize = 14
        OptionButton.TextTruncate = Enum.TextTruncate.AtEnd
        OptionButton.LayoutOrder = index
        OptionButton.ZIndex = 104

        addCorner(OptionButton, 5)

        option.button = OptionButton

        OptionButton.MouseEnter:Connect(function()
            if option.selected then
                TweenService:Create(
                    OptionButton,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 = selectedColor:Lerp(
                            Color3.fromRGB(255, 255, 255),
                            0.1
                        )
                    }
                ):Play()
            else
                TweenService:Create(
                    OptionButton,
                    TweenInfo.new(0.15),
                    {
                        BackgroundColor3 = hoverColor
                    }
                ):Play()
            end
        end)

        OptionButton.MouseLeave:Connect(function()
            updateOptionVisual(option)
        end)

        OptionButton.MouseButton1Click:Connect(function()
            if isMultiSelect then
                toggleMulti(option, true)
            else
                selectSingle(option, true)
            end
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
        local selectedNames = getSelectedValues()

        if isMultiSelect then
            return selectedNames
        end

        return selectedNames[1]
    end

    function Dropdown:GetIds()
        local _, selectedIds = getSelectedValues()

        if isMultiSelect then
            return selectedIds
        end

        return selectedIds[1]
    end

    function Dropdown:GetMode()
        return isMultiSelect and "Multi" or "Single"
    end

    function Dropdown:SetValue(value, callCallback)
        callCallback = callCallback == true

        if isMultiSelect then
            if type(value) ~= "table" then
                return false
            end

            for _, option in ipairs(sortedOptions) do
                option.selected = false
            end

            for _, requestedValue in ipairs(value) do
                for _, option in ipairs(sortedOptions) do
                    if option.value == requestedValue
                        or option.key == requestedValue then
                        option.selected = true
                        break
                    end
                end
            end

            for _, option in ipairs(sortedOptions) do
                updateOptionVisual(option)
            end

            updateHeader()

            if callCallback then
                fireCallback()
            end

            return true
        end

        for _, option in ipairs(sortedOptions) do
            if option.value == value or option.key == value then
                selectSingle(option, callCallback)
                return true
            end
        end

        return false
    end

    function Dropdown:Clear(callCallback)
        for _, option in ipairs(sortedOptions) do
            option.selected = false
            updateOptionVisual(option)
        end

        updateHeader()

        if callCallback then
            fireCallback()
        end
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
