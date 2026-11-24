--[[
    MoonLib - Customizable Admin Interface
    -----------------------------------------------------------
    Executor-compatible UI library. Dark "Vantage"-style skin
    inspired by the reference admin dashboard (dark slate panels,
    indigo accent, icon sidebar, 2x2 grid logo).

    Basic usage:

        local MoonLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
        local Window = MoonLib:CreateWindow("Moon", "rbxassetid://...")
        local Tab = Window:CreateTab("Home", "rbxassetid://...", 1)

    or create a fully themed window from the start:

        local Window = MoonLib:CreateWindow("Moon", nil, {
            BaseColor = Color3.fromRGB(120, 220, 255),
            Sidebar = Color3.fromRGB(20, 26, 30),
            BackgroundImage = "rbxassetid://123456789",
            BackgroundImageTransparency = 0.4,
            TabsStrokeColor = Color3.fromRGB(120, 220, 255),
            Font = Enum.Font.Gotham,
            CornerRadius = 8,
        })

    ===========================================================
    DESCRIPTION / API INDEX (also: MoonLib.Description table or
    MoonLib:Help("topic") in-game)
    ===========================================================

    CUSTOM THEMES  (NEW)

        MoonLib:CreateWindow(title, windowImage, theme)
            Optional third argument. Only the keys present in `theme`
            are applied; everything not in the table keeps its default.

        Window:SetTheme(theme)
            Applies a theme table at any time. Same rule: keys present
            in the table are changed, everything else is left alone.
            Returns true.

            Recognized keys (all optional):

                Surfaces & panels
                    MainBackground      Color3   window body color
                    Sidebar             Color3   sidebar panel color
                    Panel               Color3   hero/dropdown panels
                    PanelLight          Color3   off-state switches & inner surfaces
                    Card                Color3   cards & control rows
                    CardHover           Color3   card hover color
                    Input               Color3   (legacy) textbox/palette fill
                    Secondary           Color3   on-state switches, textbox
                                          backgrounds & slider rails
                    TabActiveColor      Color3   active sidebar tab fill

                Accent
                    BaseColor           Color3   accent (BlueLight/BlueDark derived)

                Tabs (sidebar buttons)
                    TabsStrokeColor         Color3   stroke color of tab buttons
                    TabStrokeThickness      number   stroke thickness   (default 1)
                    TabStrokeTransparency   number   stroke transparency (default ~0.5)

                Text
                    Text                Color3
                    SecondaryText       Color3
                    MutedText           Color3
                    DarkText            Color3

                Borders & strokes
                    Border              Color3   subtle borders (window furniture)
                    BrightBorder        Color3   bright borders (window frame)
                    ElementStroke       Color3   strokes of buttons & elements
                                          inside tabs (cards, toggles, sliders,
                                          textboxes, dropdowns)

                Background (window body behind the panels)
                    Background          Color3 | assetString | configTable
                                          - Color3:   solid background
                                          - string:   image background
                                          - table:    full background config
                                            { Image=, Rows=, Columns=,
                                              FrameCount=, FrameRate=,
                                              ImageSize=Vector2.new,
                                              ImageTransparency=, ScaleType= }
                    BackgroundImage             string   image shorthand (asset id/url)
                    BackgroundImageTransparency number   image fade (0..1)
                    BackgroundTransparency      number   window fade (0..1)
                    BackgroundConfig            table    sprite-sheet options merged
                                                           onto the current image

                Global style
                    Font                Enum.Font | { Regular=, Bold= }
                                          (Enum.Font applies everywhere;
                                           table form keeps a bold family)
                    CornerRadius        number   px radius for all corners
                                          (clamped per-instance)

            Unknown keys are ignored with a warning.

        Window:SetSidebarColor(color) / SetPanelColor / SetPanelLightColor /
        SetCardColor / SetCardHoverColor / SetInputColor / SetTabActiveColor /
        SetTextColor / SetSecondaryTextColor / SetMutedTextColor / SetDarkTextColor /
        SetBorderColor / SetBrightBorderColor / SetDividerColor /
        SetSecondaryColor / SetElementStrokeColor

            Individual one-key setters. Each changes exactly one thing.
            Divider tints the small separator lines (sidebar/content,
            content/header). Window:GetDividerColor() reads it.
            Secondary re-colors on-state switches, textbox backgrounds
            and slider rails. ElementStroke re-colors the strokes of
            buttons and other tab elements. GetSecondaryColor() and
            GetElementStrokeColor() read them back.

        Window:SetTabsStrokeColor(color) / SetTabStrokeThickness(number) /
        SetTabStrokeTransparency(number)

        Window:SetBaseColor(color)     Window:GetBaseColor()
            Same as SetMainColor/GetMainColor (kept for compatibility).
            Changing it re-tints the accent, the logo gradient, the
            page scrollbar and anything tagged to the accent.

        Window:SetFont(fontOrConfig)   Window:GetFont()
        Window:SetCornerRadius(number) Window:GetCornerRadius()

        Theme registry
        --------------
        MoonLib:RegisterTheme("Ocean", { ... })   save a theme for later
        Window:ThemeLoad("Ocean")                 apply a registered theme
        Window:ThemeSave("Ocean")                 save the window's CURRENT
                                                  effective theme as "Ocean"
        MoonLib:UnregisterTheme("Ocean")
        MoonLib:GetTheme("Ocean")                 -> copied theme table | nil
        MoonLib:GetRegisteredThemes()             -> { "Ocean", ... }

            Built-in themes: "Vantage" (default), "Ocean", "Crimson",
            "Emerald", "Gold". Registering the same name again REPLACES
            the previously registered theme (the old snapshot is dropped,
            so there is never more than one entry per name).

        Window:GetTheme()                         -> snapshot table of the
                                                     current effective theme

    ANNOUNCEMENTS  (NEW)
        Five states. The announcement's UICorner stroke (and icon) change
        color per state:

            Info     -> follows BaseColor (the base GUI color)
            Success  -> forced green
            Warn     -> forced yellow
            Error    -> forced red
            Custom   -> whatever Color3 you pass

        States are case-insensitive; "warning"/"danger"/"fail" also work.

        Window:Announce(title, message, state, duration, color)
            Floating toast. duration in seconds.
            Defaults: 6 seconds for Info/Success/Warn; ERROR is sticky
            (never auto-hides) unless you pass an explicit duration.
            Pass 0 to force sticky on any state. Passing only one string
            shows it as the message with the state label as title.
            Window:Announce({ Title=, Message=, State=, Duration=, Color= })
            also works; Color is used only by the "Custom" state.

        Window:AnnounceInfo(message, title, duration)
        Window:AnnounceSuccess(message, title, duration)
        Window:AnnounceWarn(message, title, duration)
        Window:AnnounceError(message, title, duration)
        Window:AnnounceCustom(message, title, color, duration)

        Tab:CreateAnnouncement(title, message, state, order, color, icon)
            In-page banner with the same 5 states; color is used only
            by the "Custom" state. icon (optional) overrides the icon
            image for this banner only.

            AnnouncementObject:
                :SetState(state, color?)   :GetState()
                :SetColor(color)           :GetColor()
                :SetTitle(text)    :GetTitle()
                :SetMessage(text)  :GetMessage()
                :SetIcon(image)    :SetIcon(nil) resets to the default
                :Dismiss()      :Destroy()

        Window:SetAnnounceBaseColor(bool)   Window:GetAnnounceBaseColor()
            Default false: every type keeps its defined color
            (Info = BaseColor, Success/Warn/Error forced, Custom = the
            color you pass). Set true to force EVERY notification —
            toasts and in-page banners, all five types — to follow
            BaseColor instead. Existing banners update immediately.

        Window:SetAnnounceCustomIcon(imageOrNil)   Window:GetAnnounceCustomIcon()
            Custom-type icon. Default nil: the Custom state shows a star.
            Pass an image id / rbxassetid to use your own image for the
            Custom type instead (toasts and in-page banners). Pass nil
            to go back to the star.

    WINDOW

        Window = MoonLib:CreateWindow(title, windowImage, theme)
            Creates the window. windowImage nil -> drawn 2x2 grid logo.

        Window:SetMainColor(color)     Window:GetMainColor()
            Re-skins the accent (aliases SetBaseColor/GetBaseColor).

        Window:SetSidebarColor / SetPanelColor / ... (see CUSTOM THEMES)

        Window:SetBackground(colorOrImageOrConfig)
        Window:GetBackground()
        Window:SetBackgroundTransparency(transparency)
        Window:GetBackgroundTransparency()
        Window:SetBackgroundImageTransparency(number)
        Window:GetBackgroundImageTransparency()

            SetBackground accepts:
                Color3                        solid background
                asset id / image string       image background
                {
                    Image = "rbxassetid://...",
                    Rows = 4, Columns = 4, FrameCount = 16,
                    FrameRate = 12,
                    ImageSize = Vector2.new(1024, 1024),
                    ImageTransparency = 0,
                    ScaleType = Enum.ScaleType.Crop,
                }
            Sprite-sheet animation uses ImageRectSize/ImageRectOffset.

        Window:SetTitle(title)         Window:GetTitle()
        Window:SetWindowImage(image)
        Window:SetUser(name, role, avatarImage, roleColor)   (NEW, cosmetic)
            Sets the bottom-left user card in one call.
        Window:SetUserVisible(bool)
        Window:SetDefaultSubtitle(text)
        Window:SetProfileName(text)         Window:GetProfileName()
        Window:SetProfileRank(text, color?) Window:GetProfileRank()
        Window:SetProfileRankColor(color)
        Window:SetProfileCardColor(color)
            Granular control of the bottom-left user card.
        Window:SetPresenceColor(color)      Window:GetPresenceColor()
        Window:SetPresenceStyle("Dot" | "Ring" | "Hidden")   Window:GetPresenceStyle()
        Window:SetPresenceImage(assetOrNil) Window:GetPresenceImage()
            Status bubble next to the avatar. No image is added by
            default; pass an asset id/string to decorate the bubble,
            or nil to go back to the plain dot.

        Window:SetSize(UDim2)          Window:SetPosition(UDim2)
        Window:SetVisible(bool)        Window:IsVisible()
        Window:SetStateKeybind(Enum.KeyCode)
        Window:GetStateKeybind()
        Window:SelectTab(tabName)
        Window:Toggle()
        Window:Destroy()

    TABS

        Tab = Window:CreateTab(name, iconImage, order)

        Tab:SetTabIcon(image)          Tab:GetTabIcon()
        Tab:SetSubtitle(text)          Tab:GetSubtitle()   (NEW)
            Subtitle shown under the big page title while active.

        Window:SetTabTransition("Fade" | "Drop-In" | "Pop" | "None")
        Window:GetTabTransition()
            Tab switch animation. "Fade" loads the new page's items
            top-to-bottom with a fade (default), staggering from
            the currently visible region of the page when it is
            scrolled. "Drop-In" slides the items in from off-screen
            to the left, clipping into place at the page's left edge
            and gliding into their slots, staggered top-to-bottom
            (positional only, no transparency change). "Pop" springs
            the items from nothing to full size, one at a time
            (scroll-aware, positional overshoot only). "None"
            disables the animation completely.

    TAB ELEMENTS (all take a trailing LayoutOrder)

        Tab:CreateLabel(text, order, color)
        Tab:CreateHeader(title, subtitle, order)
        Tab:CreateInfoCard(title, description, accentColor, order)
        Tab:CreateStatCard(title, value, accentColor, order)
        Tab:CreateButton(text, callback, customColor, order)
        Tab:CreateToggle(text, default, callback, order, customColor)
        Tab:CreateSlider(text, defaultState, callback, defaultValue,
            minimum, maximum, order, customColor)
        Tab:CreateTextbox(text, placeholder, callback, order, customColor, defaultValue)
        Tab:CreateDropdown(text, options, callback, order, customColor, multiSelect)
        Tab:CreateAnnouncement(title, message, state, order, color?, icon?)

        (Toggle/Slider/Textbox/Dropdown behave exactly like before.)

    NOTES

        Image formats: "rbxassetid://123456789" | 123456789 | "https://..."
        External http urls require an executor (getcustomasset/writefile).
        The state keybind defaults to RightShift and toggles the window.

        ENVIRONMENT
            Works both in plain Roblox (Studio / require) and in executors.
            - Plain Roblox:   UI parents to PlayerGui, protectGui is skipped,
                              executor-only file APIs are never touched.
            - Executors:      UI parents to gethui() (CoreGui fallback),
                              protectGui is applied when available,
                              remote images can be cached via writefile.
            Executor-only globals are resolved dynamically by name, so the
            module compiles and loads without them.

    For normal executor usage:

        local MoonLib = loadstring(game:HttpGet("YOUR_RAW_URL"))()
]]

local MoonLib = {}
MoonLib.Version = "2.28.0"

-- In-game index, see MoonLib:Help()
local Description = {
    Order = {
        "MoonLib 2.5 quick index (MoonLib:Help('Topic') prints full details)",
        "Topics: Themes, Announce, Window, Tabs, Elements",
        "local Window = MoonLib:CreateWindow(title, logoImage?, theme?)",
        "MoonLib:RegisterTheme('Ocean', { BaseColor = Color3.fromRGB(80,180,255) })",
        "Window:SetTheme({ Sidebar = ..., TabsStrokeColor = ... }) -- partial",
        "Window:ThemeLoad('Ocean')  /  Window:ThemeSave('MyTheme')",
        "MoonLib:GetRegisteredThemes()  MoonLib:GetTheme(name)",
        "Built-ins: Vantage, Ocean, Crimson, Emerald, Gold",
        "Window:Announce(title, message, 'Info'|'Success'|'Warn'|'Error', seconds)",
        "Window:AnnounceInfo/Success/Warn/Error(message, title?, duration?)",
        "Window:AnnounceCustom(message, title?, color, duration?)",
        "Tab:CreateAnnouncement(title, message, state, order, color?, icon?)",
        "Info = accent | Success = green | Warn = yellow | Error = red | Custom = your Color3",
        "Error toasts are sticky unless you pass a duration",
        "Window:SetTabTransition('Fade'|'Drop-In'|'Pop'|'None') -- tab transition",
        "Only keys in a theme table are applied; the rest stay unchanged.",
    },
    Themes = table.concat({
        "MoonLib:CreateWindow(title, logoImage?, theme?)",
        "Window:SetTheme(theme) -- applies ONLY the keys you provide",
        "Keys: MainBackground Sidebar Panel PanelLight Card CardHover Input",
        "      TabActiveColor BaseColor Border BrightBorder Divider",
        "      Secondary ElementStroke",
        "      Text SecondaryText MutedText DarkText",
        "      TabsStrokeColor TabStrokeThickness TabStrokeTransparency",
        "      Background BackgroundImage BackgroundImageTransparency",
        "      BackgroundTransparency BackgroundConfig",
        "      Font (Enum.Font | { Regular=, Bold= })  CornerRadius (px)",
        "Window:SetSidebarColor(c) SetPanelColor(c) SetPanelLightColor(c)",
        "Window:SetCardColor(c) SetCardHoverColor(c) SetInputColor(c)",
        "Window:SetTabActiveColor(c)",
        "Window:SetTextColor(c) SetSecondaryTextColor(c) SetMutedTextColor(c)",
        "Window:SetDarkTextColor(c) SetBorderColor(c) SetBrightBorderColor(c) SetDividerColor(c)",
        "Window:SetSecondaryColor(c) SetElementStrokeColor(c)",
        "Window:SetTabsStrokeColor(c) SetTabStrokeThickness(n) SetTabStrokeTransparency(n)",
        "Window:SetBaseColor(c) Window:GetBaseColor()  (== SetMainColor)",
        "Window:SetFont(fontOrConfig) Window:GetFont()",
        "Window:SetCornerRadius(px) Window:GetCornerRadius()",
        "Window:SetBackgroundImageTransparency(n) Window:GetBackgroundImageTransparency()",
        "Window:ThemeSave(name) -- save current effective theme",
        "Window:ThemeLoad(name)  MoonLib:RegisterTheme(name, theme)",
        "RegisterTheme with an existing name replaces the old registration",
        "MoonLib:UnregisterTheme(name) MoonLib:GetTheme(name) MoonLib:GetRegisteredThemes()",
        "Window:GetTheme() -- snapshot of the current effective theme",
    }, "\n"),
    Announce = table.concat({
        "States: Info | Success | Warn | Error | Custom",
        "(aliases: warning/danger/fail)",
        "Info = BaseColor accent | Success = forced green",
        "Warn = forced yellow | Error = forced red | Custom = your Color3",
        "Window:Announce(title, message, state?, duration?, color?)",
        "   duration: 6s default for Info/Success/Warn",
        "   Error is sticky unless a duration is passed; 0 = sticky on any state",
        "Window:Announce({ Title=, Message=, State=, Duration=, Color= })",
        "Window:AnnounceInfo/Success/Warn/Error(msg, title?, duration?)",
        "Window:AnnounceCustom(msg, title?, color, duration?)",
        "Window:SetAnnounceBaseColor(bool) -- all types follow BaseColor when true (default false)",
        "Window:GetAnnounceBaseColor()",
        "Window:SetAnnounceCustomIcon(imageOrNil) -- Custom-type icon; nil = star",
        "Window:GetAnnounceCustomIcon()",
        "Tab:CreateAnnouncement(title, message, state, order, color?, icon?)",
        "   -> :SetState(state, color?) :GetState :SetColor :GetColor",
        "      :SetTitle :GetTitle :SetMessage :GetMessage :SetIcon(imageOrNil)",
        "      :Dismiss :Destroy",
    }, "\n"),
    Window = table.concat({
        "Window:SetTitle/GetTitle  Window:SetWindowImage(image)",
        "Window:SetSize/SetPosition/SetVisible/IsVisible/Toggle/Destroy",
        "Window:SetStateKeybind(Enum.KeyCode) Window:GetStateKeybind()",
        "Window:SelectTab(name)",
        "Window:SetMainColor/GetMainColor (== SetBaseColor)",
        "Window:SetBackground(Color3|asset|{Image,Rows,Columns,FrameCount,",
        "   FrameRate,ImageSize,ImageTransparency,ScaleType})",
        "Window:SetBackgroundTransparency(n) Window:GetBackgroundTransparency()",
        "Window:SetUser(name, role, avatarImage?, roleColor?) Window:SetUserVisible(bool)",
        "Window:SetProfileName(n) GetProfileName Window:SetProfileRank(r, color?)",
        "Window:GetProfileRank SetProfileRankColor(c) SetProfileCardColor(c)",
        "Window:SetPresenceColor(c) GetPresenceColor SetPresenceStyle('Dot'|'Ring'|'Hidden')",
        "Window:GetPresenceStyle Window:SetPresenceImage(assetOrNil)",
        "Window:SetDefaultSubtitle(text)",
        "Window:SetTabTransition('Fade'|'Drop-In'|'Pop'|'None') GetTabTransition()",
        "   Fade = fade in top-to-bottom (default) | Drop-In = slide",
        "   in from off-screen left into slots (positional)",
        "   | Pop = spring into size one at a time | None = off",
    }, "\n"),
    Tabs = table.concat({
        "Window:CreateTab(name, iconImage?, order) -> Tab",
        "Tab:SetTabIcon(image) Tab:GetTabIcon()",
        "Tab:SetSubtitle(text) Tab:GetSubtitle()",
    }, "\n"),
    Elements = table.concat({
        "Tab:CreateLabel(text, order, color?)",
        "Tab:CreateHeader(title, subtitle?, order)",
        "Tab:CreateInfoCard(title, description, accentColor?, order)",
        "Tab:CreateStatCard(title, value, accentColor?, order)",
        "Tab:CreateButton(text, callback, customColor?, order)",
        "Tab:CreateToggle(text, default, callback, order?, customColor?)",
        "   -> :GetValue() :SetValue(v, callCallback) :Toggle() :Destroy()",
        "Tab:CreateSlider(text, defaultState, callback, defaultValue, min, max,",
        "   order?, customColor?)",
        "   -> :GetValue() :IsEnabled() :SetValue(v, callCallback)",
        "      :SetEnabled(v, callCallback) :Destroy()",
        "Tab:CreateTextbox(text, placeholder, callback, order?, customColor?,",
        "   defaultValue?) -> :GetValue() :SetValue(v, callCallback)",
        "      :Clear(callCallback) :SetPlaceholder(p) :Focus() :Destroy()",
        "Tab:CreateDropdown(text, options|function, callback, order?, customColor?,",
        "   multiSelect?) -> :GetValue() :GetIds() :GetSelection() :GetMode()",
        "   :SetOpen(b) :IsOpen() :Clear(callCallback) :SetValue(v, callCallback)",
        "   :Refresh(newOptions?, callCallback?) :SetOptions :GetOptions",
        "   :SetRefreshOnOpen(b) :GetSource() :Destroy()",
        "Tab:CreateAnnouncement(title, message, state, order, color?, icon?)",
    }, "\n"),
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- =====================================================
--  Theme (Vantage dark / indigo)
-- =====================================================

local Theme = {
    MainBackground = Color3.fromRGB(16, 23, 40),
    Sidebar        = Color3.fromRGB(16, 23, 40),
    Panel          = Color3.fromRGB(26, 35, 56),
    PanelLight     = Color3.fromRGB(34, 44, 68),
    Card           = Color3.fromRGB(26, 35, 56),
    CardHover      = Color3.fromRGB(36, 47, 73),
    Input          = Color3.fromRGB(21, 29, 49),
    NavActive      = Color3.fromRGB(34, 44, 71),
    Secondary      = Color3.fromRGB(40, 50, 77),
    ElementStroke  = Color3.fromRGB(63, 76, 111),

    Text           = Color3.fromRGB(236, 238, 248),
    SecondaryText  = Color3.fromRGB(169, 176, 204),
    MutedText      = Color3.fromRGB(118, 126, 156),
    DarkText       = Color3.fromRGB(75, 82, 110),

    Border         = Color3.fromRGB(43, 53, 80),
    BrightBorder   = Color3.fromRGB(61, 74, 107),
    Divider        = Color3.fromRGB(46, 56, 83),

    Blue           = Color3.fromRGB(138, 140, 248),
    BlueLight      = Color3.fromRGB(169, 171, 255),
    BlueDark       = Color3.fromRGB(63, 63, 143),
    BaseColor      = Color3.fromRGB(138, 140, 248),

    Green          = Color3.fromRGB(65, 217, 141),
    Red            = Color3.fromRGB(242, 104, 104),
    Yellow         = Color3.fromRGB(233, 196, 106),
    Purple         = Color3.fromRGB(166, 138, 248),

    OwnerGold      = Color3.fromRGB(233, 196, 106),
}

-- Global corner radius used for newly created corners. Windows
-- re-clamp existing ones through Window:SetCornerRadius.
local cornerRadiusDefault = 10

-- ---------------------------------------------------------------
-- Live color tags.
-- Every GuiObject/UIStroke created through MoonLib is tagged with
-- the theme key(s) whose value its color matched at creation time.
-- swapColor() recolors ONLY tagged matches, which makes theme swaps
-- exact and order-independent: two theme keys that happen to share
-- the same starting color can never cross-recolor each other.
-- ---------------------------------------------------------------

local colorTags = {}

local colorTagProperties = {
    BackgroundColor3 = true,
    TextColor3 = true,
    ImageColor3 = true,
    ScrollBarImageColor3 = true,
}

local function tagObjectColors(object)
    if not object then
        return
    end

    for property in pairs(colorTagProperties) do
        pcall(function()
            local value = object[property]

            if typeof(value) ~= "Color3" then
                return
            end

            for key, themeValue in pairs(Theme) do
                if typeof(themeValue) == "Color3" and themeValue == value then
                    table.insert(colorTags, {
                        object = object,
                        property = property,
                        key = key,
                    })
                end
            end
        end)
    end

    pcall(function()
        if not object:IsA("UIStroke") then
            return
        end

        local value = object.Color

        for key, themeValue in pairs(Theme) do
            if typeof(themeValue) == "Color3" and themeValue == value then
                table.insert(colorTags, {
                    object = object,
                    property = "Color",
                    key = key,
                })
            end
        end
    end)
end

-- Recolor every tagged object that still shows oldValue for key.
-- Entries backed by destroyed instances prune themselves here.
local function recolorTagged(key, oldValue, newValue)
    for index = #colorTags, 1, -1 do
        local tag = colorTags[index]

        if tag.key == key then
            local object = tag.object
            local ok, current = pcall(function()
                return object[tag.property]
            end)

            if not ok then
                table.remove(colorTags, index)
            elseif current == oldValue then
                pcall(function()
                    object[tag.property] = newValue
                end)
            end
        end
    end
end

-- =====================================================
--  Environment detection (executor vs plain Roblox)
-- =====================================================
-- Executor-only globals (gethui, writefile, ...) do NOT exist when the
-- module is loaded as a plain Roblox ModuleScript, and referencing them
-- directly would fail compilation. Everything executor-specific is
-- resolved dynamically BY NAME at runtime, and only under an executor.

local function lookupExecutorGlobal(name)
    local ok, value = pcall(function()
        -- Executors expose their globals on _G / the shared environment.
        if _G[name] ~= nil then
            return _G[name]
        end

        local getfenvFn = _G["getfenv"]

        if type(getfenvFn) == "function" then
            local env = getfenvFn()

            if type(env) == "table" and env[name] ~= nil then
                return env[name]
            end
        end

        return nil
    end)

    if ok then
        return value
    end

    return nil
end

local IS_EXECUTOR = (function()
    local ok, result = pcall(function()
        if _G["identifyexecutor"] ~= nil
            or _G["getexecutorname"] ~= nil
            or _G["getgenv"] ~= nil
            or _G["hookfunction"] ~= nil
            or _G["gethui"] ~= nil
            or _G["protect_gui"] ~= nil then

            return true
        end

        local getfenvFn = _G["getfenv"]

        if type(getfenvFn) == "function" then
            local env = getfenvFn()

            if type(env) == "table" then
                return env["gethui"] ~= nil
                    or env["getgenv"] ~= nil
                    or env["identifyexecutor"] ~= nil
                    or env["hookfunction"] ~= nil
            end
        end

        return false
    end)

    return ok and result == true
end)()

-- =====================================================
--  Small helpers
-- =====================================================

local function isBoldFont(font)
    local name = tostring(font)
    return name:match("Bold") ~= nil
        or name:match("Black") ~= nil
        or name:match("Heavy") ~= nil
end

local regularFamily = {
    [Enum.Font.Gotham] = Enum.Font.GothamBold,
    [Enum.Font.SourceSans] = Enum.Font.SourceSansBold,
    [Enum.Font.Arial] = Enum.Font.ArialBold,
    [Enum.Font.Code] = Enum.Font.Code,
}

-- Resolve a theme Font value into { Regular = font, Bold = font }.
local function resolveFontConfig(fontValue)
    if typeof(fontValue) == "EnumItem" and fontValue.EnumType == Enum.Font then
        return {
            Regular = fontValue,
            Bold = regularFamily[fontValue] or fontValue,
        }
    end

    if type(fontValue) == "table" then
        local regular = fontValue.Regular or fontValue.regular or fontValue.Bold or fontValue.bold
        local bold = fontValue.Bold or fontValue.bold or fontValue.Regular or fontValue.regular

        if typeof(regular) ~= "EnumItem" or regular.EnumType ~= Enum.Font then
            warn("[MoonLib] Theme Font table expects Enum.Font values for Regular/Bold")
            return nil
        end

        if typeof(bold) ~= "EnumItem" or bold.EnumType ~= Enum.Font then
            bold = regular
        end

        return { Regular = regular, Bold = bold }
    end

    warn("[MoonLib] Theme Font must be an Enum.Font or a { Regular=, Bold= } table")
    return nil
end

-- Monotonic creation counter. Lets layout code reproduce the exact visual
-- order of instances (same as UIListLayout with SortOrder=LayoutOrder and
-- creation-order tie-breaking) without touching attributes.
local creationCounter = 0
local creationOrder = setmetatable({}, { __mode = "k" })
local pendingReveals = setmetatable({}, { __mode = "k" })

local function creationSeq(object)
    return creationOrder[object] or 0
end

-- Stores an object's ORIGINAL transparency the first time it is hidden by
-- the tab-open animation. Re-entering the animation never re-captures a
-- mid-hide (transparency=1) value, which previously left the last items
-- permanently invisible after fast tab switches.
local hiddenOriginals = setmetatable({}, { __mode = "k" })


local function create(className, properties)
    local object = Instance.new(className)

    -- Apply Parent LAST: pair order over the properties table is
    -- undefined, and anything with children that lays out on attach
    -- (UIListLayout with a scrolling canvas, UIPageLayout, etc.) must see
    -- all of its other properties already in place when it attaches.
    local parent = properties and properties.Parent

    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            object[property] = value
        end
    end

    if parent ~= nil then
        object.Parent = parent
    end

    -- Remember weight so Window:SetFont can re-map every text object,
    -- even ones created after the theme is applied.
    if properties and typeof(properties.Font) == "EnumItem" then
        pcall(function()
            object:SetAttribute("FontBold", isBoldFont(properties.Font))
        end)
    end

    creationCounter = creationCounter + 1
    creationOrder[object] = creationCounter

    tagObjectColors(object)

    return object
end

local function addCorner(object, radius)
    local baseRadius = radius or cornerRadiusDefault
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, baseRadius)
    corner.Parent = object

    pcall(function()
        corner:SetAttribute("BaseRadius", baseRadius)
    end)

    return corner
end

local function addStroke(object, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = object

    tagObjectColors(stroke)

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

local function isAssetLike(imageString)
    if not imageString then
        return false
    end

    return imageString:match("^rbxassetid://") ~= nil
        or imageString:match("^%d+$") ~= nil
        or imageString:match("^https?://") ~= nil
        or imageString:match("^rbxtemp://") ~= nil
        or imageString:match("^asset://") ~= nil
end

local function getGuiParent()
    -- Executors: prefer gethui(), then CoreGui (both pcall-guarded).
    if IS_EXECUTOR then
        local gethuiFn = lookupExecutorGlobal("gethui")

        if type(gethuiFn) == "function" then
            local success, hui = pcall(gethuiFn)

            if success and hui then
                return hui
            end
        end

        local coreGuiOk, coreGui = pcall(function()
            return game:GetService("CoreGui")
        end)

        if coreGuiOk and coreGui then
            return coreGui
        end
    end

    -- Plain Roblox (Studio / require()): parent to PlayerGui, which is
    -- always permitted. CoreGui is intentionally not used here.
    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            or LocalPlayer:WaitForChild("PlayerGui", 5)

        if playerGui then
            return playerGui
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local playerGui = player:FindFirstChildOfClass("PlayerGui")

        if playerGui then
            return playerGui
        end
    end

    warn("[MoonLib] Could not find a PlayerGui to parent the UI to.")
    return nil
end

local function protectGui(gui)
    if not IS_EXECUTOR then
        return
    end

    local synTable = lookupExecutorGlobal("syn")

    if type(synTable) == "table" and type(synTable.protect_gui) == "function" then
        pcall(function()
            synTable.protect_gui(gui)
        end)
    end

    local protect = lookupExecutorGlobal("protectgui")

    if type(protect) == "function" then
        pcall(function()
            protect(gui)
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
        return Color3.fromRGB(16, 21, 36)
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

local tweenRegistry = setmetatable({}, { __mode = "k" })

-- Cancels in-flight tweens for an object. With no properties table,
-- cancels everything the registry knows about that object.
local function cancelTweens(object, properties)
    local existing = tweenRegistry[object]

    if not existing then
        return
    end

    local targets = {}

    if type(properties) == "table" and next(properties) ~= nil then
        for property in pairs(properties) do
            targets[property] = true
        end
    else
        for property in pairs(existing) do
            targets[property] = true
        end
    end

    for property in pairs(targets) do
        local previous = existing[property]

        if previous then
            pcall(function()
                previous:Cancel()
            end)
            existing[property] = nil
        end
    end
end

-- Hover/focus tracking. Every hoverable registers a refresh function that
-- re-applies its CURRENT theme-derived colors instantly and synchronously.
-- Window:SetTheme / SetMainColor / SetCardHoverColor (etc.) call
-- refreshAllHovers() at the end, so anything currently hovered snaps to
-- the new palette immediately -- never stuck on the old theme color, and
-- never overridden by a stale in-flight tween afterwards.
local hoverTracked = {}

local function trackHover(object, apply)
    local entry = { object = object, apply = apply, hovered = false }
    table.insert(hoverTracked, entry)
    return entry
end

local function refreshAllHovers()
    for index = #hoverTracked, 1, -1 do
        local entry = hoverTracked[index]

        if not entry.object or entry.object.Parent == nil then
            table.remove(hoverTracked, index)
        else
            cancelTweens(entry.object)
            pcall(entry.apply, entry.hovered)
        end
    end
end

local function makeTween(object, duration, properties, easingStyle, easingDirection)
    -- Cancel any in-flight tween on the same object+property so stale
    -- targets never override the newest one (fixes hover/theme races).
    local existing = tweenRegistry[object]

    if existing then
        for property in pairs(properties) do
            local previous = existing[property]

            if previous then
                pcall(function()
                    previous:Cancel()
                end)
            end
        end
    else
        existing = {}
        tweenRegistry[object] = existing
    end

    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            easingStyle or Enum.EasingStyle.Quad,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )

    for property in pairs(properties) do
        existing[property] = tween
    end

    pcall(function()
        tween.Completed:Connect(function()
            local registryEntry = tweenRegistry[object]

            if registryEntry then
                for property in pairs(properties) do
                    if registryEntry[property] == tween then
                        registryEntry[property] = nil
                    end
                end
            end
        end)
    end)

    tween:Play()

    return tween
end

-- Turn a user supplied "Icon" into either an ImageLabel or a TextLabel glyph.
local function buildIcon(parent, icon, size, position, zIndex, glyphColor)
    local normalized = normalizeImage(icon)

    if normalized and isAssetLike(normalized) then
        local image = create("ImageLabel", {
            Name = "Icon",
            Parent = parent,
            BackgroundTransparency = 1,
            Position = position,
            Size = size,
            Image = normalized,
            ImageColor3 = glyphColor or Theme.BlueLight,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = zIndex or 5,
        })

        return image, "image"
    elseif icon ~= nil and tostring(icon) ~= "" then
        local glyph = create("TextLabel", {
            Name = "Icon",
            Parent = parent,
            BackgroundTransparency = 1,
            Position = position,
            Size = size,
            Font = Enum.Font.GothamBold,
            Text = tostring(icon),
            TextColor3 = glyphColor or Theme.BlueLight,
            TextSize = math.floor(size.Y.Offset * 0.72),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = zIndex or 5,
        })

        return glyph, "glyph"
    end

    return nil, nil
end

-- Recursive copy for theme tables (Colors/enums/Vector2 pass through).
local function deepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end

    -- Roblox value datatypes are immutable and must be returned by reference,
    -- not unpacked into plain tables.
    local valueType = typeof(value)

    if valueType == "EnumItem"
        or valueType == "Color3"
        or valueType == "UDim2"
        or valueType == "UDim"
        or valueType == "Vector2"
        or valueType == "Vector3"
        or valueType == "NumberRange"
        or valueType == "ColorSequence"
        or valueType == "NumberSequence" then
        return value
    end

    seen = seen or {}

    if seen[value] then
        return seen[value]
    end

    local copy = {}
    seen[value] = copy

    for key, nested in pairs(value) do
        copy[key] = deepCopy(nested, seen)
    end

    return copy
end

-- =====================================================
--  Announcement state styling (forced colors)
-- =====================================================

local function normalizeAnnouncementState(state)
    local lowered = string.lower(tostring(state or "Info"))

    if lowered == "success" or lowered == "ok" or lowered == "good" then
        return "Success"
    elseif lowered == "warn" or lowered == "warning" or lowered == "caution" then
        return "Warn"
    elseif lowered == "error" or lowered == "danger" or lowered == "fail" or lowered == "failed" then
        return "Error"
    elseif lowered == "custom" then
        return "Custom"
    end

    return "Info"
end

local function stateColor(state, customColor)
    if state == "Success" then
        return Color3.fromRGB(65, 217, 141) -- forced green
    elseif state == "Warn" then
        return Color3.fromRGB(233, 196, 106) -- forced yellow
    elseif state == "Error" then
        return Color3.fromRGB(242, 104, 104) -- forced red
    elseif state == "Custom" and typeof(customColor) == "Color3" then
        return customColor -- caller-provided color
    end

    return Theme.Blue -- Info/Custom fallback: the GUI accent / BaseColor
end

local function stateGlyph(state)
    if state == "Success" then
        return "✓"
    elseif state == "Warn" then
        return "!"
    elseif state == "Error" then
        return "×"
    elseif state == "Custom" then
        return "★"
    end

    return "i"
end

local function defaultStateTitle(state)
    if state == "Warn" then
        return "Warning"
    end

    return state
end

-- =====================================================
--  Theme registry (shared between all windows)
-- =====================================================

local RegisteredThemes = {}

local function registerThemeInternal(name, theme)
    if type(name) ~= "string" or name == "" then
        return false, "RegisterTheme expects a non-empty name"
    end

    if type(theme) ~= "table" then
        return false, "RegisterTheme expects a theme table"
    end

    -- Overwrite semantics: re-registering the same name drops the old
    -- snapshot completely, so there is never more than one entry per name.
    RegisteredThemes[name] = nil
    RegisteredThemes[name] = deepCopy(theme)

    return true
end

-- Built-in themes.
registerThemeInternal("Vantage", {
    BaseColor = Color3.fromRGB(138, 140, 248),
    TabActiveColor = Color3.fromRGB(34, 44, 71),
    TabsStrokeColor = Color3.fromRGB(61, 74, 107),
    Divider = Color3.fromRGB(46, 56, 83),
    Secondary = Color3.fromRGB(40, 50, 77),
    ElementStroke = Color3.fromRGB(63, 76, 111),
})

registerThemeInternal("Ocean", {
    BaseColor = Color3.fromRGB(80, 180, 255),
    TabActiveColor = Color3.fromRGB(22, 46, 66),
    TabsStrokeColor = Color3.fromRGB(66, 110, 150),
    Divider = Color3.fromRGB(36, 58, 84),
    Secondary = Color3.fromRGB(30, 55, 78),
    ElementStroke = Color3.fromRGB(70, 114, 154),
    Card = Color3.fromRGB(23, 38, 56),
    Panel = Color3.fromRGB(23, 38, 56),
    CardHover = Color3.fromRGB(33, 52, 74),
    Sidebar = Color3.fromRGB(14, 23, 34),
    MainBackground = Color3.fromRGB(14, 23, 34),
})

registerThemeInternal("Crimson", {
    BaseColor = Color3.fromRGB(242, 104, 104),
    TabActiveColor = Color3.fromRGB(66, 30, 34),
    TabsStrokeColor = Color3.fromRGB(150, 70, 70),
    Divider = Color3.fromRGB(60, 36, 38),
    Secondary = Color3.fromRGB(55, 35, 37),
    ElementStroke = Color3.fromRGB(126, 68, 68),
    Card = Color3.fromRGB(46, 26, 28),
    Panel = Color3.fromRGB(46, 26, 28),
    CardHover = Color3.fromRGB(62, 37, 39),
    Sidebar = Color3.fromRGB(34, 19, 21),
    MainBackground = Color3.fromRGB(34, 19, 21),
})

registerThemeInternal("Emerald", {
    BaseColor = Color3.fromRGB(65, 217, 141),
    TabActiveColor = Color3.fromRGB(24, 54, 40),
    TabsStrokeColor = Color3.fromRGB(60, 140, 105),
    Divider = Color3.fromRGB(30, 56, 43),
    Secondary = Color3.fromRGB(28, 60, 47),
    ElementStroke = Color3.fromRGB(55, 126, 94),
    Card = Color3.fromRGB(22, 44, 33),
    Panel = Color3.fromRGB(22, 44, 33),
    CardHover = Color3.fromRGB(32, 60, 47),
    Sidebar = Color3.fromRGB(16, 34, 25),
    MainBackground = Color3.fromRGB(16, 34, 25),
})

registerThemeInternal("Gold", {
    BaseColor = Color3.fromRGB(233, 196, 106),
    TabActiveColor = Color3.fromRGB(56, 46, 22),
    TabsStrokeColor = Color3.fromRGB(150, 130, 80),
    Divider = Color3.fromRGB(56, 50, 32),
    Secondary = Color3.fromRGB(58, 52, 31),
    ElementStroke = Color3.fromRGB(136, 119, 76),
    Card = Color3.fromRGB(44, 39, 22),
    Panel = Color3.fromRGB(44, 39, 22),
    CardHover = Color3.fromRGB(58, 52, 30),
    Sidebar = Color3.fromRGB(33, 29, 17),
    MainBackground = Color3.fromRGB(33, 29, 17),
})

-- =====================================================
--  Module entry point
-- =====================================================

function MoonLib:CreateWindow(title, windowImage, theme)
    local Window = {}

    local destroyed = false
    local visible = true
    local currentTab = nil
    local tabTransition = "Fade"

    local stateKeybind = Enum.KeyCode.RightShift
    local defaultSubtitle = ""

    local defaultUserName = (LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name)) or "User"
    local defaultUserRole = "Member"

    local connections = {}
    local tabs = {}
    local tabStrokeRefs = {}   -- strokes of sidebar tab buttons (themeable)

    -- Effective theme state tracked for snapshots/themes.
    local tabStroke = {
        Color = Theme.BrightBorder,
        Thickness = 1,
        Transparency = 0.5,
    }

    local tabActiveColor = Theme.NavActive

    local backgroundState = {
        Value = Theme.MainBackground,
        Transparency = 0,
        ImageTransparency = 0,
        Config = {
            Rows = 1,
            Columns = 1,
            FrameCount = 1,
            FrameRate = 12,
            ImageSize = Vector2.new(1024, 1024),
            ImageTransparency = 0,
            ScaleType = Enum.ScaleType.Crop,
        },
    }

    local ScreenGui = create("ScreenGui", {
        Name = "MoonLib_Interface",
        Parent = getGuiParent(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    })

    protectGui(ScreenGui)

    -- =================================================
    --  Main frame
    -- =================================================

    local WINDOW_WIDTH = 950
    local WINDOW_HEIGHT = 600
    local SIDEBAR_WIDTH = 230
    local PADDING = 14
    local HEADER_HEIGHT = 64

    local MainFrame = create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.MainBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.5, -WINDOW_HEIGHT / 2),
        Size = UDim2.new(0, WINDOW_WIDTH, 0, WINDOW_HEIGHT),
        ClipsDescendants = true,
        ZIndex = 1,
    })

    addCorner(MainFrame, 14)
    addStroke(MainFrame, Theme.BrightBorder, 1, 0.45)

    local InnerFrame = create("Frame", {
        Name = "InnerFrame",
        Parent = MainFrame,
        BackgroundColor3 = Theme.MainBackground,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 1,
    })

    addCorner(InnerFrame, 14)

    local InnerGradient = addGradient(
        InnerFrame,
        Color3.fromRGB(22, 30, 50),
        Color3.fromRGB(13, 18, 32),
        90
    )

    -- Solid/image background behind everything else.
    local BackgroundImage = create("ImageLabel", {
        Name = "BackgroundImage",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "",
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Crop,
        Visible = false,
        ZIndex = 2,
    })

    addCorner(BackgroundImage, 14)

    -- =================================================
    --  Sidebar
    -- =================================================

    local Sidebar = create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, 0),
        ZIndex = 3,
    })

    addCorner(Sidebar, 14)

    -- Logo (custom image or drawn 2x2 grid)
    local LogoIcon = create("Frame", {
        Name = "LogoIcon",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Blue,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 18, 0, 15),
        Size = UDim2.new(0, 38, 0, 38),
        ZIndex = 4,
    })

    addCorner(LogoIcon, 10)
    local LogoGradient = addGradient(
        LogoIcon,
        Theme.BlueLight,
        Theme.BlueDark,
        45
    )

    local GridSquares = {}

    for index, offset in ipairs({
        Vector2.new(10, 10),
        Vector2.new(21, 10),
        Vector2.new(10, 21),
        Vector2.new(21, 21),
    }) do
        GridSquares[index] = create("Frame", {
            Name = "GridSquare" .. index,
            Parent = LogoIcon,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            Position = UDim2.new(0, offset.X, 0, offset.Y),
            Size = UDim2.new(0, 7, 0, 7),
            ZIndex = 5,
        })

        addCorner(GridSquares[index], 2)
    end

    local LogoImage = create("ImageLabel", {
        Name = "LogoImage",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 15),
        Size = UDim2.new(0, 38, 0, 38),
        ScaleType = Enum.ScaleType.Crop,
        Visible = false,
        ZIndex = 6,
    })

    addCorner(LogoImage, 10)

    local function applyLogoImage(image)
        local normalized = normalizeImage(image)

        if normalized then
            LogoImage.Image = normalized
            LogoImage.Visible = true

            for _, square in ipairs(GridSquares) do
                square.Visible = false
            end

            LogoIcon.Visible = false
        else
            LogoImage.Image = ""
            LogoImage.Visible = false

            for _, square in ipairs(GridSquares) do
                square.Visible = true
            end

            LogoIcon.Visible = true
        end
    end

    applyLogoImage(windowImage)

    local WindowTitle = create("TextLabel", {
        Name = "WindowTitle",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 66, 0, 15),
        Size = UDim2.new(1, -78, 0, 38),
        Font = Enum.Font.GothamBold,
        Text = tostring(title or "Moon"),
        TextColor3 = Theme.Text,
        TextSize = 21,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4,
    })

    local SidebarDivider = create("Frame", {
        Name = "SidebarDivider",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 18),
        Size = UDim2.new(0, 1, 1, -36),
        ZIndex = 3,
    })

    local NavContainer = create("ScrollingFrame", {
        Name = "NavContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 78),
        Size = UDim2.new(1, -20, 1, -162),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    })

    create("UIPadding", {
        Parent = NavContainer,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
    })

    create("UIListLayout", {
        Parent = NavContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    })

    -- =================================================
    --  Sidebar user card (bottom-left)
    -- =================================================

    local UserCard = create("Frame", {
        Name = "UserCard",
        Parent = Sidebar,
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -74),
        Size = UDim2.new(1, -20, 0, 60),
        ZIndex = 5,
    })

    addCorner(UserCard, 12)
    addStroke(UserCard, Theme.Border, 1, 0.4)

    local AvatarHolder = create("Frame", {
        Name = "AvatarHolder",
        Parent = UserCard,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -19),
        Size = UDim2.new(0, 38, 0, 38),
        ZIndex = 6,
    })

    addCorner(AvatarHolder, 10)

    local AvatarImage = create("ImageLabel", {
        Name = "AvatarImage",
        Parent = AvatarHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScaleType = Enum.ScaleType.Crop,
        Image = "",
        Visible = false,
        ZIndex = 7,
    })

    addCorner(AvatarImage, 10)

    local AvatarFallback = create("TextLabel", {
        Name = "AvatarFallback",
        Parent = AvatarHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = string.upper(string.sub(defaultUserName, 1, 1)),
        TextColor3 = Theme.BlueLight,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 7,
    })

    local StatusDot = create("Frame", {
        Name = "StatusDot",
        Parent = AvatarHolder,
        BackgroundColor3 = Theme.Green,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -10, 1, -10),
        Size = UDim2.new(0, 11, 0, 11),
        ZIndex = 8,
    })

    addCorner(StatusDot, 20)
    addStroke(StatusDot, Theme.MainBackground, 2, 0)

    local UserNameLabel = create("TextLabel", {
        Name = "UserName",
        Parent = UserCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 56, 0, 10),
        Size = UDim2.new(1, -66, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = tostring(defaultUserName),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 6,
    })

    local UserRoleLabel = create("TextLabel", {
        Name = "UserRole",
        Parent = UserCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 56, 0, 30),
        Size = UDim2.new(1, -66, 0, 16),
        Font = Enum.Font.Gotham,
        Text = tostring(defaultUserRole),
        TextColor3 = Theme.OwnerGold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 6,
    })

    -- Best-effort: pull the local player's headshot for the avatar.
    if LocalPlayer then
        task.spawn(function()
            local ok, url = pcall(function()
                return Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size48x48
                )
            end)

            if ok and url and AvatarImage.Parent then
                AvatarImage.Image = url
                AvatarImage.Visible = true
                AvatarFallback.Visible = false
            end
        end)
    end

    -- Presence bubble next to the avatar (color / style / custom image).
    -- No image is used unless the user sets one with Window:SetPresenceImage.
    local presenceColor = Theme.Green
    local presenceStyle = "Dot"
    local presenceImage = nil
    local presenceImageLabel = nil

    local function applyPresence()
        local stroke = StatusDot:FindFirstChildOfClass("UIStroke")

        if presenceStyle == "Hidden" then
            StatusDot.Visible = false
        elseif presenceStyle == "Ring" then
            StatusDot.Visible = true
            StatusDot.BackgroundTransparency = 1

            if stroke then
                stroke.Color = presenceColor
                stroke.Thickness = 2
                stroke.Transparency = 0
            end
        else -- Dot
            StatusDot.Visible = true
            StatusDot.BackgroundColor3 = presenceColor
            StatusDot.BackgroundTransparency = 0

            if stroke then
                stroke.Color = Theme.MainBackground
                stroke.Thickness = 2
                stroke.Transparency = 0
            end
        end

        if presenceImage then
            if not presenceImageLabel or not presenceImageLabel.Parent then
                presenceImageLabel = create("ImageLabel", {
                    Name = "PresenceImage",
                    Parent = AvatarHolder,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -15, 1, -15),
                    Size = UDim2.new(0, 15, 0, 15),
                    ScaleType = Enum.ScaleType.Crop,
                    Image = presenceImage,
                    ZIndex = 9,
                })

                addCorner(presenceImageLabel, 20)
                addStroke(presenceImageLabel, Theme.MainBackground, 1, 0)
            else
                presenceImageLabel.Image = presenceImage
                presenceImageLabel.Visible = true
            end

            StatusDot.Visible = false
        elseif presenceImageLabel then
            presenceImageLabel.Visible = false
        end
    end

    -- =================================================
    --  Content area (header + pages)
    -- =================================================

    local CONTENT_X = SIDEBAR_WIDTH + PADDING

    local ContentArea = create("Frame", {
        Name = "ContentArea",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, CONTENT_X, 0, 0),
        Size = UDim2.new(1, -(CONTENT_X + PADDING), 1, 0),
        -- Clips page content entering from the sidebar side: the
        -- Drop-In transition slides the page in from the left edge of
        -- this region.
        ClipsDescendants = true,
        ZIndex = 3,
    })

    local PageTitle = create("TextLabel", {
        Name = "PageTitle",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 12),
        Size = UDim2.new(1, -150, 0, 28),
        Font = Enum.Font.GothamBold,
        Text = tostring(title or "Home"),
        TextColor3 = Theme.Text,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4,
    })

    local PageSubtitle = create("TextLabel", {
        Name = "PageSubtitle",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 38),
        Size = UDim2.new(1, -150, 0, 18),
        Font = Enum.Font.Gotham,
        Text = defaultSubtitle,
        TextColor3 = Theme.MutedText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
    })

    local HeaderDivider = create("Frame", {
        Name = "HeaderDivider",
        Parent = ContentArea,
        BackgroundColor3 = Theme.Divider,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, HEADER_HEIGHT),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 4,
    })

    -- Window buttons (top-right): minimize + close.
    local MinimizeButton = create("TextButton", {
        Name = "MinimizeButton",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -96, 0, 10),
        Size = UDim2.new(0, 40, 0, 44),
        Font = Enum.Font.GothamBold,
        Text = "–",
        TextColor3 = Theme.SecondaryText,
        TextSize = 24,
        AutoButtonColor = false,
        ZIndex = 20,
    })

    local CloseButton = create("TextButton", {
        Name = "CloseButton",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -54, 0, 10),
        Size = UDim2.new(0, 44, 0, 44),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Theme.SecondaryText,
        TextSize = 26,
        AutoButtonColor = false,
        ZIndex = 20,
    })

    local minimizeHover = trackHover(MinimizeButton, function(hovered)
        MinimizeButton.TextColor3 = hovered and Theme.BlueLight or Theme.SecondaryText
    end)

    MinimizeButton.MouseEnter:Connect(function()
        minimizeHover.hovered = true
        makeTween(MinimizeButton, 0.12, { TextColor3 = Theme.BlueLight })
    end)

    MinimizeButton.MouseLeave:Connect(function()
        minimizeHover.hovered = false
        makeTween(MinimizeButton, 0.12, { TextColor3 = Theme.SecondaryText })
    end)

    local closeButtonHover = trackHover(CloseButton, function(hovered)
        CloseButton.TextColor3 = hovered and Theme.Red or Theme.SecondaryText
    end)

    CloseButton.MouseEnter:Connect(function()
        closeButtonHover.hovered = true
        makeTween(CloseButton, 0.12, { TextColor3 = Theme.Red })
    end)

    CloseButton.MouseLeave:Connect(function()
        closeButtonHover.hovered = false
        makeTween(CloseButton, 0.12, { TextColor3 = Theme.SecondaryText })
    end)

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

    -- Dragging (grab the header strip)
    local dragHandle = create("Frame", {
        Name = "DragHandle",
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -160, 0, HEADER_HEIGHT),
        Active = true,
        ZIndex = 2,
    })

    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position
            dragInput = input
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
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

                MainFrame.Position = MainFrame.Position:Lerp(targetPosition, 0.22)
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

    -- Pages with a Drop-In sweep in flight. Keyed by page; each value
    -- carries a bail() so an interrupted drop can be finished cleanly
    -- before starting another one.
    local dropSweeps = {}

    -- -------------------------------------------------
    -- Tab switch animation.
    -- "Fade":    items appear top-to-bottom with a fade.
    -- "Drop-In": items glide in one at a time from off the left
    --            clip edge into their slots, staggered like the Fade
    --            (scrolled-past items land instantly). Items are
    --            moved to a temporary overlay with the page's exact
    --            geometry and frozen-canvas scroll safety; slot Y is
    --            measured from the engine when it publishes distinct
    --            AbsolutePosition values, and RECONSTRUCTED from the
    --            layout config (padding + gap + item heights, stacked
    --            in visual order) when it doesn't. Items return so
    --            the layout re-derives the slots itself. Items stay
    --            invisible until their own turn, fully opaque through
    --            the sweep.
    -- "Pop":     items spring from Scale 0 to full size one at a
    --            time (scroll-aware like the others). Items never
    --            leave the layout; a temporary UIScale child drives
    --            the animation and is removed when the item finishes.
    -- "None":    disabled, instant page swap. Unrecognized values
    --            behave as "None".
    -- -------------------------------------------------

    local function animateTabIn(page, style)
        if destroyed or not page then
            return
        end

        -- Force-stop every Drop-In sweep in flight, not just the one
        -- on this page: a mid-flight sweep keeps its items in an
        -- overlay ABOVE the content area, so a stale sweep would keep
        -- rendering over the tab the user just switched to ("stacking").
        -- The old page is invisible by now, so restoring instantly is
        -- invisible to the user.
        for _, sweepState in pairs(dropSweeps) do
            pcall(sweepState.bail)
        end

        local mode = string.lower(tostring(style or "Fade")):gsub("[%-_%s]", "")

        if mode ~= "fade" and mode ~= "dropin" and mode ~= "pop" then
            return
        end

        local items = {}

        for _, child in ipairs(page:GetChildren()) do
            pcall(function()
                if child:IsA("GuiObject") then
                    table.insert(items, child)
                end
            end)
        end

        if #items == 0 then
            return
        end

        -- Visual order == UIListLayout order: LayoutOrder, then creation
        -- sequence. (Previously Name broke ties, which scrambled the
        -- "load" order into apparent middle-out.)
        table.sort(items, function(a, b)
            local ao = tonumber(a.LayoutOrder) or 0
            local bo = tonumber(b.LayoutOrder) or 0

            if ao ~= bo then
                return ao < bo
            end

            return creationSeq(a) < creationSeq(b)
        end)

        -- Deterministic slot geometry for the "above the fold"
        -- (snap instantly) decision: padding-top, then stacked
        -- heights + layout gap in visual order. Reconstruction never
        -- reads AbsolutePosition -- this runtime does not publish
        -- usable geometry for items. Memoized; used by Fade and Pop.
        local slotYs = {}
        local visualHeights = {}
        local slotsComputed = false

        local function reconstructedSlots()
            if slotsComputed then
                return
            end

            slotsComputed = true

            local padTop, gap = 5, 9

            pcall(function()
                local padding = page:FindFirstChildOfClass("UIPadding")

                if padding then
                    padTop = tonumber(padding.PaddingTop and padding.PaddingTop.Offset) or padTop
                end
            end)

            pcall(function()
                local layoutNow = page:FindFirstChildOfClass("UIListLayout")

                if layoutNow then
                    gap = tonumber(layoutNow.Padding and layoutNow.Padding.Offset) or gap
                end
            end)

            local function slotHeight(item)
                local off = nil

                pcall(function()
                    off = tonumber(item.Size and item.Size.Y and item.Size.Y.Offset)
                end)

                if off and off > 0 then
                    return off
                end

                local h = nil

                pcall(function()
                    h = tonumber(item.AbsoluteSize and item.AbsoluteSize.Y)
                end)

                return h or 50
            end

            local cursor = padTop

            for _, item in ipairs(items) do
                local height = slotHeight(item)
                slotYs[item] = cursor
                visualHeights[item] = height
                cursor = cursor + height + gap
            end
        end

        local stagger = 0.05

        if mode == "dropin" then
            local dropStagger = 0.06
            local slideDuration = 0.28

            -- If a sweep on THIS page is still running (re-switch to
            -- the same tab mid-drop), finish it before starting anew.
            local previous = dropSweeps[page]

            if previous then
                pcall(previous.bail)
            end

            local sweep = { bailed = false }

            -- Shared measurements used by the canvas freeze AND the
            -- slot reconstruction. All of these read properties this
            -- library itself sets, so they work even when the runtime
            -- does not compute layout render positions.
            local function itemHeight(item)
                -- Prefer the library-set Size offset: it is deterministic
                -- on every runtime. AbsoluteSize is only a fallback (this
                -- runtime mispublishes geometry for detached items).
                local off = nil

                pcall(function()
                    off = tonumber(item.Size and item.Size.Y and item.Size.Y.Offset)
                end)

                if off and off > 0 then
                    return off
                end

                local h = nil

                pcall(function()
                    h = tonumber(item.AbsoluteSize and item.AbsoluteSize.Y)
                end)

                return h or 50
            end

            local function layoutMetrics()
                local padTop, padBottom, padL, padR = 5, 8, 4, 4
                local gap = 9

                pcall(function()
                    local padding = page:FindFirstChildOfClass("UIPadding")

                    if padding then
                        padTop = tonumber(padding.PaddingTop and padding.PaddingTop.Offset) or padTop
                        padBottom = tonumber(padding.PaddingBottom and padding.PaddingBottom.Offset) or padBottom
                        padL = tonumber(padding.PaddingLeft and padding.PaddingLeft.Offset) or padL
                        padR = tonumber(padding.PaddingRight and padding.PaddingRight.Offset) or padR
                    end
                end)

                pcall(function()
                    local layoutNow = page:FindFirstChildOfClass("UIListLayout")

                    if layoutNow then
                        gap = tonumber(layoutNow.Padding and layoutNow.Padding.Offset) or gap
                    end
                end)

                return padTop, padBottom, padL, padR, gap
            end

            local function estimateContentHeight()
                local padTop, padBottom, _, _, gap = layoutMetrics()
                local total = padTop + padBottom

                for _, item in ipairs(items) do
                    total = total + itemHeight(item) + gap
                end

                return math.max(0, total - gap)
            end

            -- A detached page has an empty, pinned canvas, so wheel
            -- scrolling cannot do anything for these ~0.3s -- and the
            -- overlay would swallow the input regardless. Disable the
            -- ScrollingFrame for the duration of the sweep.
            local scrollingWasEnabled = nil

            pcall(function()
                scrollingWasEnabled = page.ScrollingEnabled
                page.ScrollingEnabled = false
            end)

            -- Freeze the canvas FIRST: with the items gone the layout
            -- would shrink it and clamp CanvasPosition, losing the
            -- user's scroll. AutomaticCanvasSize is toggled off and
            -- CanvasSize pinned to the live content size; both are
            -- restored when the items are back. CanvasPosition itself
            -- is only ever read, never written.
            local autoCanvas = nil
            local layout = nil

            pcall(function()
                autoCanvas = page.AutomaticCanvasSize
            end)
            pcall(function()
                layout = page:FindFirstChildOfClass("UIListLayout")
            end)

            -- Remember the live scroll window so the pinned canvas
            -- below can never shrink past it (a shrink would clamp
            -- CanvasPosition and jump the user's scroll on open).
            local preCanvasY, preViewportH = 0, 0
            local currentCanvasH = 0
            pcall(function()
                preCanvasY = tonumber(page.CanvasPosition and page.CanvasPosition.Y) or 0
            end)
            pcall(function()
                currentCanvasH = tonumber(page.CanvasSize and page.CanvasSize.Y and page.CanvasSize.Y.Offset) or 0
            end)
            pcall(function()
                preViewportH = tonumber(page.AbsoluteSize and page.AbsoluteSize.Y) or 0
            end)

            if layout and autoCanvas ~= nil then
                local engineH = 0

                pcall(function()
                    engineH = tonumber(layout.AbsoluteContentSize and layout.AbsoluteContentSize.Y) or 0
                end)

                -- This runtime reports AbsoluteContentSize as 0, so pin
                -- the canvas to a self-estimated content height instead
                -- (same padding/gap/heights the reconstruction uses) --
                -- that estimate IS the layout's content height. Never
                -- below what the current scroll position needs, or the
                -- engine clamps CanvasPosition and the window math is
                -- corrupted for the whole sweep. No slack: extra pixels
                -- become scrollable empty space at the bottom.
                local contentH = math.max(engineH, estimateContentHeight(), preCanvasY + math.max(preViewportH, 300))
                contentH = math.min(contentH, 0x0FFFFFFF)

                pcall(function()
                    page.CanvasSize = UDim2.new(0, 0, 0, contentH)
                end)
                pcall(function()
                    page.AutomaticCanvasSize = Enum.AutomaticSize.None
                end)
            end

            -- The item UIListLayout re-applies placement on this
            -- runtime (and does NOT publish its result through
            -- item.Position -- everything reads 0), so per-item motion
            -- must happen outside its reach. The overlay Frame has the
            -- page's EXACT geometry -- same Position, same Size, one
            -- ZIndex up, clipped, no layout of its own. Item positions
            -- are written in page-window coordinates (contentY -
            -- canvasY), which is exactly what the overlay clips
            -- against; the page re-derives the same slots through
            -- its own canvas offset when items land.
            -- The overlay is a plain clipped Frame with the page's
            -- EXACT geometry (same Position, same Size, one ZIndex
            -- up). Items are positioned in PAGE-WINDOW coordinates
            -- (contentY - canvasY), so the overlay renders exactly
            -- the scrolled window the page shows: items above the
            -- fold snap instantly, items in view slide, items below
            -- the fold stay clipped and pop in via the layout on
            -- landing. No second ScrollingFrame, no CanvasPosition
            -- writes, no overlay canvas pinning -- a failed scroll
            -- read degrades to canvasY = 0, i.e. the unscrolled case.
            local overlay = create("Frame", {
                Name = "DropInOverlay",
                Parent = page.Parent,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = page.Position,
                Size = page.Size,
                ClipsDescendants = true,
                Active = false,
                ZIndex = (page.ZIndex or 5) + 1,
            })

            -- The page's layout resolves item scale against its
            -- content box (AbsoluteSize minus padding), so give the
            -- overlay the identical UIPadding or items render wider
            -- than they should while riding it.
            pcall(function()
                local padding = page:FindFirstChildOfClass("UIPadding")

                if padding then
                    create("UIPadding", {
                        Parent = overlay,
                        PaddingTop = padding.PaddingTop,
                        PaddingBottom = padding.PaddingBottom,
                        PaddingLeft = padding.PaddingLeft,
                        PaddingRight = padding.PaddingRight,
                    })
                end
            end)

            -- Capture state and freeze items FULLY INVISIBLE while
            -- they wait for their turn (transparency is never
            -- layout-managed). Slot geometry is measured one frame
            -- later inside task.defer, when the engine has laid out
            -- the freshly visible page.
            local captured = {}

            for _, item in ipairs(items) do
                local entry = { item = item }

                pcall(function()
                    entry.height = tonumber(entry.item.AbsoluteSize and entry.item.AbsoluteSize.Y)
                end)

                pcall(function()
                    entry.bg = item.BackgroundTransparency
                    if entry.bg ~= nil then item.BackgroundTransparency = 1 end
                end)
                pcall(function()
                    entry.tx = item.TextTransparency
                    if entry.tx ~= nil then item.TextTransparency = 1 end
                end)
                pcall(function()
                    entry.im = item.ImageTransparency
                    if entry.im ~= nil then item.ImageTransparency = 1 end
                end)

                -- UIStroke is an untracked child: without this the
                -- buttons & elements arrive as hollow outline ghosts
                -- (background hidden, stroke still drawn) while they
                -- wait their turn. Freeze it too, restore with the
                -- rest.
                pcall(function()
                    entry.strokes = {}
                    for _, d in ipairs(item:GetDescendants()) do
                        pcall(function()
                            if d:IsA("UIStroke") then
                                entry.strokes[#entry.strokes + 1] = { stroke = d, enabled = d.Enabled }
                                d.Enabled = false
                            end
                        end)
                    end
                end)

                -- Children render independently of their parent's
                -- transparency, and at capture time the page has not
                -- been shown/laid out yet, so the old content would
                -- otherwise paint (labels, switches, knobs) until the
                -- precise park happens one frame later. Freeze the
                -- whole subtree to the default state right now --
                -- exactly like Fade does -- and restore per item at
                -- its turn.
                pcall(function()
                    entry.descendants = {}
                    for _, d in ipairs(item:GetDescendants()) do
                        pcall(function()
                            if d:IsA("UIStroke") then
                                return
                            end

                            local rec = { object = d }
                            local okBg, bg = pcall(function() return d.BackgroundTransparency end)
                            local okTx, tx = pcall(function() return d.TextTransparency end)
                            local okIm, im = pcall(function() return d.ImageTransparency end)

                            if okBg and bg ~= nil then rec.BackgroundTransparency = bg end
                            if okTx and tx ~= nil then rec.TextTransparency = tx end
                            if okIm and im ~= nil then rec.ImageTransparency = im end

                            if rec.BackgroundTransparency ~= nil or rec.TextTransparency ~= nil or rec.ImageTransparency ~= nil then
                                if rec.BackgroundTransparency ~= nil then pcall(function() d.BackgroundTransparency = 1 end) end
                                if rec.TextTransparency ~= nil then pcall(function() d.TextTransparency = 1 end) end
                                if rec.ImageTransparency ~= nil then pcall(function() d.ImageTransparency = 1 end) end
                                entry.descendants[#entry.descendants + 1] = rec
                            end
                        end)
                    end
                end)

                table.insert(captured, entry)
            end

            -- Move everything into the overlay (same geometry: nothing
            -- jumps, and everything stays invisible regardless of
            -- where it lands).
            for _, entry in ipairs(captured) do
                pcall(function()
                    entry.item.Parent = overlay
                end)
            end

            -- DEFAULT STATE first, before anything can paint: park
            -- everything far off the left clip edge, invisible, right
            -- now. Slot geometry is only measured one frame later in
            -- task.defer; this far-left park guarantees the tab never
            -- shows stale content even if measurement or the precise
            -- park fails. The defer overwrites this with the exact
            -- per-slot park before anything animates. Done AFTER the
            -- re-parent so the page's layout cannot re-seat the items
            -- over the park before the frame presents.
            for _, entry in ipairs(captured) do
                pcall(function()
                    entry.item.Position = UDim2.new(0, -100000, 0, 0)
                end)
            end

            local function restoreItem(entry)
                pcall(function()
                    if entry.bg ~= nil then entry.item.BackgroundTransparency = entry.bg end
                    if entry.tx ~= nil then entry.item.TextTransparency = entry.tx end
                    if entry.im ~= nil then entry.item.ImageTransparency = entry.im end
                    if entry.descendants then
                        for _, rec in ipairs(entry.descendants) do
                            pcall(function()
                                if rec.BackgroundTransparency ~= nil then rec.object.BackgroundTransparency = rec.BackgroundTransparency end
                                if rec.TextTransparency ~= nil then rec.object.TextTransparency = rec.TextTransparency end
                                if rec.ImageTransparency ~= nil then rec.object.ImageTransparency = rec.ImageTransparency end
                            end)
                        end
                    end
                    if entry.strokes then
                        for _, s in ipairs(entry.strokes) do
                            pcall(function()
                                s.stroke.Enabled = s.enabled
                            end)
                        end
                    end
                end)
            end

            local finishSweep

            -- Seat one item back into the page the moment its slide
            -- ends: from here on the layout owns its position, so the
            -- final rendering is always exactly the slot the layout
            -- derives (never a reconstruction approximation).
            local landedCount = 0

            local function landItem(entry)
                if entry.landed then
                    return
                end

                entry.landed = true
                restoreItem(entry)

                pcall(function()
                    entry.item.Parent = page
                end)

                landedCount = landedCount + 1

                if landedCount >= #captured and finishSweep then
                    task.defer(finishSweep)
                end
            end

            finishSweep = function()
                if sweep.bailed then
                    return
                end

                sweep.bailed = true
                sweep.finished = true

                -- Items go straight back; the layout re-derives its
                -- own output on the next pass, so nothing pops. Order
                -- comes from LayoutOrder, not parenting order.
                for _, entry in ipairs(captured) do
                    if not entry.landed then
                        entry.landed = true
                        restoreItem(entry)

                        -- Same as the bail path: no in-flight tween may
                        -- outlive the sweep that created it.
                        pcall(function()
                            cancelTweens(entry.item, { Position = true })
                        end)

                        pcall(function()
                            entry.item.Parent = page
                        end)
                    end
                end

                pcall(function()
                    overlay:Destroy()
                end)

                if autoCanvas ~= nil then
                    pcall(function()
                        local engineH = 0

                        pcall(function()
                            engineH = layout and tonumber(layout.AbsoluteContentSize and layout.AbsoluteContentSize.Y) or 0
                        end)

                        if engineH > 0 then
                            -- Engine-driven canvas works on this runtime; hand it back.
                            page.AutomaticCanvasSize = autoCanvas
                        else
                            -- This runtime reports no usable content size; restoring
                            -- automatic mode would collapse the canvas and clamp the
                            -- scroll to the top. Keep a never-shrinking pinned canvas.
                            page.AutomaticCanvasSize = Enum.AutomaticSize.None
                            local pinH = math.max(estimateContentHeight(), preCanvasY + math.max(preViewportH, 300))
                            page.CanvasSize = UDim2.new(0, 0, 0, math.min(pinH, 0x0FFFFFFF))
                        end
                    end)
                end

                if scrollingWasEnabled ~= nil then
                    pcall(function()
                        page.ScrollingEnabled = scrollingWasEnabled
                    end)
                end

                dropSweeps[page] = nil
            end

            local function bailSweep()
                if sweep.bailed then
                    return
                end

                sweep.bailed = true
                sweep.finished = true

                for _, entry in ipairs(captured) do
                    entry.landed = true

                    -- Kill any in-flight slide this sweep started. Without
                    -- this, the stale tween keeps dragging the restored
                    -- item toward its old target (off-screen / stale Y)
                    -- while the layout re-seats it, which is exactly the
                    -- "breaks on rapid re-open" failure.
                    pcall(function()
                        cancelTweens(entry.item, { Position = true })
                    end)

                    pcall(function()
                        entry.item.Parent = page
                    end)
                    restoreItem(entry)
                end

                pcall(function()
                    overlay:Destroy()
                end)

                if autoCanvas ~= nil then
                    pcall(function()
                        local engineH = 0

                        pcall(function()
                            engineH = layout and tonumber(layout.AbsoluteContentSize and layout.AbsoluteContentSize.Y) or 0
                        end)

                        if engineH > 0 then
                            -- Engine-driven canvas works on this runtime; hand it back.
                            page.AutomaticCanvasSize = autoCanvas
                        else
                            -- This runtime reports no usable content size; restoring
                            -- automatic mode would collapse the canvas and clamp the
                            -- scroll to the top. Keep a never-shrinking pinned canvas.
                            page.AutomaticCanvasSize = Enum.AutomaticSize.None
                            local pinH = math.max(estimateContentHeight(), preCanvasY + math.max(preViewportH, 300))
                            page.CanvasSize = UDim2.new(0, 0, 0, math.min(pinH, 0x0FFFFFFF))
                        end
                    end)
                end

                if scrollingWasEnabled ~= nil then
                    pcall(function()
                        page.ScrollingEnabled = scrollingWasEnabled
                    end)
                end

                dropSweeps[page] = nil
            end

            sweep.bail = bailSweep
            dropSweeps[page] = sweep

            task.defer(function()
                if destroyed or not page or not page.Parent then
                    bailSweep()
                    return
                end

                -- Measure slots from the engine's layout output.
                -- item.Position is never used (the layout does not
                -- publish through it). When the engine reports no
                -- usable geometry, slots are reconstructed below from
                -- the layout config instead.
                local pageAbsX, pageAbsY = 0, 0

                pcall(function()
                    pageAbsX = tonumber(page.AbsolutePosition and page.AbsolutePosition.X) or 0
                    pageAbsY = tonumber(page.AbsolutePosition and page.AbsolutePosition.Y) or 0
                end)

                -- Scroll offset: slots are CONTENT coordinates so
                -- they can be shifted into page-window coordinates
                -- (slotY - canvasY) for the overlay. Engine-measured
                -- AbsolutePosition is viewport-relative, so the scroll
                -- is added back; the reconstruction below already
                -- yields content coordinates.
                local canvasY = 0

                pcall(function()
                    canvasY = tonumber(page.CanvasPosition and page.CanvasPosition.Y) or 0
                end)

                local firstY = nil
                local distinct = false
                local anyMissing = false

                for _, entry in ipairs(captured) do
                    local item = entry.item
                    local absX, absY, width = nil, nil, nil

                    pcall(function()
                        local abs = item.AbsolutePosition
                        local size = item.AbsoluteSize
                        absX = tonumber(abs and abs.X)
                        absY = tonumber(abs and abs.Y)
                        width = tonumber(size and size.X)
                    end)

                    if absX == nil or absY == nil then
                        anyMissing = true
                    else
                        entry.slotX = absX - pageAbsX
                        entry.slotY = absY - pageAbsY + canvasY
                        entry.width = width or 420

                        if firstY == nil then
                            firstY = entry.slotY
                        elseif math.abs(entry.slotY - firstY) > 1 then
                            distinct = true
                        end
                    end
                end

                if anyMissing or (#captured > 1 and not distinct) then
                    -- The runtime does not publish usable slot geometry
                    -- (items report the page's own position). Reconstruct
                    -- deterministically from the layout configuration and
                    -- the items' own sizes instead:
                    --   slotY = paddingTop, then heights + layout gap
                    --   stacked in visual order (LayoutOrder, creation)
                    --   slotX = paddingLeft, centered horizontally
                    -- Landing is still guaranteed by the layout itself
                    -- when the items are re-parented afterwards.
                    local padTop, _, padL, padR, gap = layoutMetrics()
                    local pageW = 400
                    local pageH = 300

                    pcall(function()
                        pageW = tonumber(page.AbsoluteSize and page.AbsoluteSize.X) or pageW
                    end)
                    pcall(function()
                        pageH = tonumber(page.AbsoluteSize and page.AbsoluteSize.Y) or pageH
                    end)

                    local estContentH = estimateContentHeight()
                    local sbThickness = 0

                    pcall(function()
                        sbThickness = tonumber(page.ScrollBarThickness) or 0
                    end)

                    local inset = 0

                    if sbThickness > 0 and pageH > 0 and estContentH > pageH then
                        inset = sbThickness
                    end

                    local windowW = pageW - inset
                    local contentW = windowW - padL - padR
                    local centered = true

                    pcall(function()
                        if layout then
                            centered = layout.HorizontalAlignment == Enum.HorizontalAlignment.Center
                        end
                    end)

                    local y = padTop

                    for _, entry in ipairs(captured) do
                        local width = tonumber(entry.item.AbsoluteSize and entry.item.AbsoluteSize.X) or contentW
                        local x = padL

                        if centered then
                            x = padL + math.max(0, (contentW - width) / 2)
                        end

                        entry.height = entry.height or itemHeight(entry.item)
                        entry.slotX = x
                        entry.slotY = y
                        entry.width = width

                        y = y + entry.height + gap
                    end
                end

                -- Park the items off the overlay's left clip edge
                -- (still invisible), now that real slots are known.
                for _, entry in ipairs(captured) do
                    pcall(function()
                        entry.item.Position = UDim2.new(
                            0,
                            entry.slotX - entry.width - 24,
                            0,
                            entry.slotY - canvasY
                        )
                    end)
                end

                -- Scroll-aware scheduling, same semantics as Fade:
                -- items scrolled above the viewport land instantly;
                -- everything else follows top-to-bottom from the
                -- visible region.
                local rank = 0
                local maxDelay = 0

                for _, entry in ipairs(captured) do
                    local delayTime = 0
                    local snap = false

                    if canvasY > 0 then
                        local height = entry.height or itemHeight(entry.item)

                        if entry.slotY + height < canvasY then
                            -- Scrolled above the viewport: land instantly.
                            snap = true
                        end
                    end

                    if not snap then
                        delayTime = rank * dropStagger
                        rank = rank + 1
                    end

                    if delayTime > maxDelay then
                        maxDelay = delayTime
                    end

                    task.delay(delayTime, function()
                        if destroyed or not page or not page.Parent or sweep.bailed or sweep.finished then
                            -- An interrupted sweep must not touch the
                            -- sweep that replaced it; the bail path has
                            -- already restored this item.
                            return
                        end

                        restoreItem(entry)

                        local orig = UDim2.new(0, entry.slotX, 0, entry.slotY - canvasY)

                        if snap then
                            pcall(function()
                                entry.item.Position = orig
                            end)
                            landItem(entry)
                            return
                        end

                        local tween = nil

                        pcall(function()
                            tween = makeTween(entry.item, slideDuration, { Position = orig })
                        end)

                        if tween then
                            pcall(function()
                                tween.Completed:Connect(function()
                                    landItem(entry)
                                end)
                            end)
                        end
                    end)
                end

                -- Bring everyone home once the sweep is done.
                task.delay(maxDelay + slideDuration + 0.15, function()
                    if sweep.bailed then
                        return
                    end

                    finishSweep()
                end)
            end)

            return
        end

        if mode == "pop" then
            -- "Pop": items spring from nothing to full size, one at a
            -- time. Items never leave the layout -- no overlay, no slot
            -- math, no canvas freeze -- a temporary UIScale child does
            -- all the work, so there is no placement to get wrong. The
            -- Scale object is destroyed when the item finishes (or by
            -- the safety net), leaving the item exactly as the layout
            -- expects it. Waiting items render at Scale 0: invisible
            -- until their own turn.
            local popStagger = 0.055

            local backStyle = nil
            pcall(function()
                if Enum and Enum.EasingStyle and Enum.EasingStyle.Back then
                    backStyle = Enum.EasingStyle.Back
                end
            end)

            local captured = {}

            for _, item in ipairs(items) do
                -- An interrupted pop may have left a Scale object
                -- behind; start clean.
                pcall(function()
                    local stale = item:FindFirstChild("MoonPopScale")
                    if stale then stale:Destroy() end
                end)

                -- If the item already carries its own UIScale, leave
                -- it alone and skip it (it shows at full size).
                local hasOwnScale = false

                pcall(function()
                    for _, child in ipairs(item:GetChildren()) do
                        pcall(function()
                            if child:IsA("UIScale") and child.Name ~= "MoonPopScale" then
                                hasOwnScale = true
                            end
                        end)
                    end
                end)

                if hasOwnScale then
                    table.insert(captured, { item = item })
                else
                    local scaleObj = nil

                    pcall(function()
                        scaleObj = create("UIScale", {
                            Name = "MoonPopScale",
                            Parent = item,
                            Scale = 0,
                        })
                    end)

                    table.insert(captured, { item = item, scaleObj = scaleObj })
                end
            end

            local function finishPopEntry(entry)
                if entry.done then
                    return
                end

                entry.done = true

                if entry.scaleObj then
                    pcall(function()
                        cancelTweens(entry.scaleObj, { Scale = true })
                    end)

                    local s = entry.scaleObj
                    entry.scaleObj = nil
                    pcall(function()
                        s:Destroy()
                    end)
                end
            end

            local function springEntry(entry, instant)
                if entry.done or not entry.scaleObj then
                    return
                end

                if instant then
                    pcall(function()
                        entry.scaleObj.Scale = 1
                    end)
                    finishPopEntry(entry)
                    return
                end

                local started = false

                if backStyle then
                    local tween = nil

                    pcall(function()
                        tween = makeTween(entry.scaleObj, 0.42, { Scale = 1 }, backStyle, Enum.EasingDirection.Out)
                    end)

                    if tween then
                        started = true
                        pcall(function()
                            tween.Completed:Connect(function()
                                finishPopEntry(entry)
                            end)
                        end)
                    end
                end

                if not started then
                    -- Two-stage spring for runtimes without
                    -- Enum.EasingStyle.Back: fast out to a slight
                    -- overshoot, then settle back to 1.
                    local first = nil

                    pcall(function()
                        first = makeTween(entry.scaleObj, 0.2, { Scale = 1.14 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    end)

                    if not first then
                        pcall(function()
                            entry.scaleObj.Scale = 1
                        end)
                        finishPopEntry(entry)
                        return
                    end

                    pcall(function()
                        first.Completed:Connect(function()
                            if entry.done then
                                return
                            end

                            local second = nil

                            pcall(function()
                                second = makeTween(entry.scaleObj, 0.18, { Scale = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                            end)

                            if second then
                                pcall(function()
                                    second.Completed:Connect(function()
                                        finishPopEntry(entry)
                                    end)
                                end)
                            else
                                pcall(function()
                                    entry.scaleObj.Scale = 1
                                end)
                                finishPopEntry(entry)
                            end
                        end)
                    end)
                end
            end

            task.defer(function()
                if destroyed or not page or not page.Parent then
                    for _, entry in ipairs(captured) do
                        finishPopEntry(entry)
                    end

                    return
                end

                local canvasY = 0

                pcall(function()
                    canvasY = tonumber(page.CanvasPosition and page.CanvasPosition.Y) or 0
                end)

                -- Above-fold classification from the reconstructed
                -- slots; never AbsolutePosition (unpublished on this
                -- runtime). Items above the scroll position land
                -- instantly, the rest cascade from the visible point.
                reconstructedSlots()

                for _, entry in ipairs(captured) do
                    entry.height = entry.height or visualHeights[entry.item]
                    entry.slotY = slotYs[entry.item]
                end

                local rank = 0
                local maxDelay = 0

                for _, entry in ipairs(captured) do
                    if entry.scaleObj then
                        local delayTime = 0
                        local snap = false

                        if canvasY > 0 and entry.slotY then
                            if entry.slotY + entry.height < canvasY then
                                -- Scrolled above the viewport: land instantly.
                                snap = true
                            end
                        end

                        if not snap then
                            delayTime = rank * popStagger
                            rank = rank + 1
                        end

                        if delayTime > maxDelay then
                            maxDelay = delayTime
                        end

                        task.delay(delayTime, function()
                            if destroyed or not page or not page.Parent then
                                finishPopEntry(entry)
                                return
                            end

                            springEntry(entry, snap)
                        end)
                    end
                end

                -- Safety net: nobody may stay at Scale 0 forever.
                task.delay(maxDelay + 1.0, function()
                    for _, entry in ipairs(captured) do
                        finishPopEntry(entry)
                    end
                end)
            end)

            return
        end

        for _, item in ipairs(items) do
            local entries = {}

            local function grab(object)
                local entry = { object = object }
                local saved = hiddenOriginals[object]

                pcall(function()
                    entry.BackgroundTransparency = saved and saved.BackgroundTransparency or object.BackgroundTransparency
                end)
                pcall(function()
                    entry.TextTransparency = saved and saved.TextTransparency or object.TextTransparency
                end)
                pcall(function()
                    entry.ImageTransparency = saved and saved.ImageTransparency or object.ImageTransparency
                end)
                pcall(function()
                    if object:IsA("UIStroke") then
                        entry.StrokeTransparency = saved and saved.Transparency or object.Transparency
                    end
                end)

                if not saved then
                    hiddenOriginals[object] = {
                        BackgroundTransparency = entry.BackgroundTransparency,
                        TextTransparency = entry.TextTransparency,
                        ImageTransparency = entry.ImageTransparency,
                        Transparency = entry.StrokeTransparency,
                    }
                end

                table.insert(entries, entry)
            end

            grab(item)

            pcall(function()
                for _, descendant in ipairs(item:GetDescendants()) do
                    grab(descendant)
                end
            end)

                for _, entry in ipairs(entries) do
                    pcall(function()
                        if entry.BackgroundTransparency ~= nil then
                            entry.object.BackgroundTransparency = 1
                        end
                        if entry.TextTransparency ~= nil then
                            entry.object.TextTransparency = 1
                        end
                        if entry.ImageTransparency ~= nil then
                            entry.object.ImageTransparency = 1
                        end
                        if entry.StrokeTransparency ~= nil then
                            entry.object.Transparency = 1
                        end
                    end)
                end

            local function reveal(delayTime)
                task.delay(delayTime, function()
                    if destroyed then
                        return
                    end

                    for _, entry in ipairs(entries) do
                        pcall(function()
                            local properties = {}

                            if entry.BackgroundTransparency ~= nil then
                                properties.BackgroundTransparency = entry.BackgroundTransparency
                            end
                            if entry.TextTransparency ~= nil then
                                properties.TextTransparency = entry.TextTransparency
                            end
                            if entry.ImageTransparency ~= nil then
                                properties.ImageTransparency = entry.ImageTransparency
                            end

                            if next(properties) then
                                makeTween(entry.object, 0.24, properties)
                            end

                            if entry.StrokeTransparency ~= nil then
                                makeTween(entry.object, 0.24, { Transparency = entry.StrokeTransparency })
                            end
                        end)
                    end
                end)
            end

            pendingReveals[item] = reveal
        end

        -- Schedule the staggers one frame later, starting from the
        -- currently visible region of the page: items above the scroll
        -- position appear instantly, the rest stagger top-to-bottom from
        -- the visible point. Slots are reconstructed (never
        -- AbsolutePosition, which this runtime does not publish).
        task.defer(function()
            if destroyed or not page.Parent then
                for _, item in ipairs(items) do
                    local reveal = pendingReveals[item]
                    pendingReveals[item] = nil

                    if reveal then
                        reveal(0)
                    end
                end

                return
            end

            local canvasY = 0

            pcall(function()
                canvasY = tonumber(page.CanvasPosition and page.CanvasPosition.Y) or 0
            end)

            -- Same deterministic above-the-fold test Pop uses: items
            -- above the scroll position appear instantly, the rest
            -- stagger in from the top of the visible region.
            reconstructedSlots()

            local rank = 0

            for _, item in ipairs(items) do
                local reveal = pendingReveals[item]
                pendingReveals[item] = nil

                if not reveal then
                    -- nothing recorded (already revealed elsewhere); skip
                elseif canvasY > 0 and slotYs[item] then
                    if slotYs[item] + visualHeights[item] < canvasY then
                        -- scrolled above the viewport: land instantly
                        reveal(0)
                    else
                        reveal(rank * stagger)
                        rank = rank + 1
                    end
                else
                    reveal(rank * stagger)
                    rank = rank + 1
                end
            end
        end)
    end

    -- =================================================
    --  Tab plumbing
    -- =================================================

    local function updateCanvas(page, layout)
        task.defer(function()
            if not (page and page.Parent) then
                return
            end

            -- Resolve the live layout instead of trusting a captured
            -- reference (it can outlive the tab it laid out).
            if not layout or not layout.Parent then
                layout = page:FindFirstChildOfClass("UIListLayout")
            end

            if layout and layout.Parent then
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
        button.BackgroundColor3 = active and tabActiveColor or Theme.Sidebar
        button.BackgroundTransparency = active and 0 or 1

        local stroke = button:FindFirstChildOfClass("UIStroke")

        if stroke then
            stroke.Color = tabStroke.Color
            stroke.Thickness = tabStroke.Thickness
            stroke.Transparency = active and math.max(tabStroke.Transparency - 0.1, 0) or tabStroke.Transparency
        end

        local titleObject = button:FindFirstChild("TabTitle")

        if titleObject then
            titleObject.TextColor3 = active and Theme.Text or Theme.SecondaryText
        end

        local iconObject = button:FindFirstChild("Icon")

        if iconObject then
            local tint = active and Theme.BlueLight or Theme.MutedText

            if iconObject:IsA("ImageLabel") then
                iconObject.ImageColor3 = tint
            elseif iconObject:IsA("TextLabel") then
                iconObject.TextColor3 = tint
            end
        end
    end

    local function selectTab(record)
        -- Re-clicking the already-open tab is a no-op. Without this,
        -- every click re-runs the show/hide + force-stop + re-animate
        -- cycle, so spamming the button dumps all items back into the
        -- layout instantly ("added back to the UIList before the
        -- animation finishes").
        if currentTab == record then
            return
        end

        if currentTab then
            currentTab.Page.Visible = false
            setTabVisual(currentTab.Button, false)
        end

        currentTab = record

        -- Prepare the page BEFORE it is shown: the animation paths
        -- hide its entire subtree and park it off-screen synchronously,
        -- so the old content never paints, not even for a frame.
        animateTabIn(currentTab.Page, tabTransition)

        currentTab.Page.Visible = true
        setTabVisual(currentTab.Button, true)

        PageTitle.Text = currentTab.Name
        PageSubtitle.Text = currentTab.Subtitle ~= "" and currentTab.Subtitle or defaultSubtitle
    end

    -- =================================================
    --  Announcements (toasts live above everything)
    -- =================================================

    local announceUseBaseColor = false
    local announceCustomIcon = nil

    local ToastContainer = create("Frame", {
        Name = "Announcements",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -185, 0, 8),
        Size = UDim2.new(0, 370, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 500,
    })

    create("UIListLayout", {
        Parent = ToastContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
    })

    local toastOrder = 0

    local function dismissToast(toast, stroke, progress)
        if not toast or not toast.Parent then
            return
        end

        makeTween(toast, 0.22, { BackgroundTransparency = 1 })

        if stroke then
            makeTween(stroke, 0.22, { Transparency = 1 })
        end

        if progress then
            makeTween(progress, 0.18, { BackgroundTransparency = 1 })
        end

        for _, descendant in ipairs(toast:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                makeTween(descendant, 0.2, { TextTransparency = 1 })
            elseif descendant:IsA("UIStroke") then
                makeTween(descendant, 0.2, { Transparency = 1 })
            elseif descendant:IsA("Frame") then
                makeTween(descendant, 0.2, { BackgroundTransparency = 1 })
            end
        end

        task.delay(0.25, function()
            if toast and toast.Parent then
                toast:Destroy()
            end
        end)
    end

    -- Reassigners for colors computed AFTER creation (updaters/tweens,
    -- not tagged at birth). Registered components re-apply their
    -- theme-derived colors on every theme swap so nothing is left
    -- wearing a stale palette (toggle switch, dropdown options).
    local dynamicRefreshers = {}

    local function registerDynamicRefresher(fn)
        table.insert(dynamicRefreshers, fn)
    end

    local function refreshDynamic()
        for index = #dynamicRefreshers, 1, -1 do
            local refresher = dynamicRefreshers[index]
            local ok, result = pcall(refresher)

            if not ok or result == false then
                table.remove(dynamicRefreshers, index)
            end
        end
    end

    local announceRefreshers = {}

    -- BaseColor override: when the window's announce-base-color setting is
    -- enabled, EVERY notification (Info/Success/Warn/Error/Custom) takes the
    -- base accent color instead of its type's defined color.
    local function announceAccent(state, customColor)
        if announceUseBaseColor then
            return Theme.BaseColor or Theme.Blue
        end

        return stateColor(state, customColor)
    end

    local function refreshAnnouncements()
        for index = #announceRefreshers, 1, -1 do
            local refresher = announceRefreshers[index]
            local ok, result = pcall(refresher)

            if not ok or result == false then
                table.remove(announceRefreshers, index)
            end
        end
    end

    local function showToast(title, message, state, duration, customColor, customIcon)
        if destroyed then
            return nil
        end

        local normalizedState = normalizeAnnouncementState(state)
        local accent = announceAccent(normalizedState, customColor)

        duration = tonumber(duration)

        if duration == nil then
            -- Error never hides on its own; every other state defaults to 6s.
            duration = (normalizedState == "Error") and 0 or 6
        end

        -- Per-call icon wins; otherwise the Custom state falls back to the
        -- window's custom icon setting (star when none is set).
        local resolvedIcon = customIcon

        if resolvedIcon == nil and normalizedState == "Custom" then
            resolvedIcon = announceCustomIcon
        end

        if resolvedIcon ~= nil then
            resolvedIcon = normalizeImage(resolvedIcon)
        end

        local resolvedTitle = title

        if resolvedTitle == nil or resolvedTitle == "" then
            resolvedTitle = defaultStateTitle(normalizedState)
        end

        toastOrder = toastOrder + 1

        local toast = create("Frame", {
            Name = "Announcement_" .. toastOrder,
            Parent = ToastContainer,
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 76),
            LayoutOrder = toastOrder,
            ClipsDescendants = true,
            ZIndex = 500,
        })

        addCorner(toast, 12)
        local stroke = addStroke(toast, accent, 2, 0.05)

        local iconCircle = create("Frame", {
            Name = "IconCircle",
            Parent = toast,
            BackgroundColor3 = accent,
            BackgroundTransparency = 0.82,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 12, 0, 15),
            Size = UDim2.new(0, 44, 0, 44),
            ZIndex = 501,
        })

        addCorner(iconCircle, 22)

        if resolvedIcon then
            create("ImageLabel", {
                Name = "IconImage",
                Parent = iconCircle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -13, 0.5, -13),
                Size = UDim2.new(0, 26, 0, 26),
                ScaleType = Enum.ScaleType.Fit,
                Image = resolvedIcon,
                ImageColor3 = accent,
                ZIndex = 502,
            })
        else
            create("TextLabel", {
                Name = "IconGlyph",
                Parent = iconCircle,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = stateGlyph(normalizedState),
                TextColor3 = accent,
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 502,
            })
        end

        addStroke(iconCircle, accent, 1, 0.25)

        create("TextLabel", {
            Name = "Title",
            Parent = toast,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 68, 0, 11),
            Size = UDim2.new(1, -110, 0, 19),
            Font = Enum.Font.GothamBold,
            Text = tostring(resolvedTitle),
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 501,
        })

        local messageHolder = create("Frame", {
            Name = "MessageHolder",
            Parent = toast,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 68, 0, 31),
            Size = UDim2.new(1, -112, 0, 32),
            ClipsDescendants = true,
            ZIndex = 501,
        })

        create("TextLabel", {
            Name = "Message",
            Parent = messageHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.Gotham,
            Text = tostring(message or ""),
            TextColor3 = Theme.SecondaryText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 501,
        })

        local close = create("TextButton", {
            Name = "Dismiss",
            Parent = toast,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -32, 0, 8),
            Size = UDim2.new(0, 24, 0, 24),
            Font = Enum.Font.GothamBold,
            Text = "×",
            TextColor3 = Theme.MutedText,
            TextSize = 17,
            AutoButtonColor = false,
            ZIndex = 502,
        })

        local toastCloseHover = trackHover(close, function(hovered)
            close.TextColor3 = hovered and Theme.Text or Theme.MutedText
        end)

        close.MouseEnter:Connect(function()
            toastCloseHover.hovered = true
            makeTween(close, 0.12, { TextColor3 = Theme.Text })
        end)

        close.MouseLeave:Connect(function()
            toastCloseHover.hovered = false
            makeTween(close, 0.12, { TextColor3 = Theme.MutedText })
        end)

        local progress

        if duration > 0 then
            progress = create("Frame", {
                Name = "Progress",
                Parent = toast,
                BackgroundColor3 = accent,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 1, -3),
                Size = UDim2.new(1, -28, 0, 3),
                ZIndex = 502,
            })

            addCorner(progress, 2)
            makeTween(progress, duration, { Size = UDim2.new(0, 0, 0, 3) })
        end

        close.MouseButton1Click:Connect(function()
            dismissToast(toast, stroke, progress)
        end)

        if duration > 0 then
            task.delay(duration, function()
                dismissToast(toast, stroke, progress)
            end)
        end

        return toast
    end

    -- =================================================
    --  Tab creation
    -- =================================================

    function Window:CreateTab(name, image, order)
        local tabName = tostring(name or "Tab")
        local normalizedImage = normalizeImage(image)

        local record = {}
        local Tab = {}

        local TabButton = create("TextButton", {
            Name = tabName .. "Tab",
            Parent = NavContainer,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -4, 0, 38),
            Font = Enum.Font.Gotham,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order or 0,
            ZIndex = 5,
        })

        addCorner(TabButton, 9)
        local tabStrokeRef = addStroke(TabButton, tabStroke.Color, tabStroke.Thickness, tabStroke.Transparency)
        table.insert(tabStrokeRefs, tabStrokeRef)

        local iconObject, iconKind = buildIcon(
            TabButton,
            normalizedImage,
            UDim2.new(0, 20, 0, 20),
            UDim2.new(0, 12, 0.5, -10),
            7,
            Theme.MutedText
        )

        if not iconObject then
            iconObject = create("TextLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = string.upper(string.sub(tabName, 1, 1)),
                TextColor3 = Theme.MutedText,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 7,
            })
        end

        local TabTitle = create("TextLabel", {
            Name = "TabTitle",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 42, 0, 0),
            Size = UDim2.new(1, -52, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = Theme.SecondaryText,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 7,
        })

        local Page = create("ScrollingFrame", {
            Name = tabName .. "Page",
            Parent = ContentArea,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, HEADER_HEIGHT + 12),
            Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + 26)),
            ScrollBarThickness = 3,
            -- Inset the canvas by the scrollbar gutter while it is
            -- visible, so content never renders under the thumb.
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            ScrollBarImageColor3 = Theme.Blue,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 5,
        })

        create("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
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
        record.Subtitle = ""
        record.Button = TabButton
        record.Page = Page
        record.Layout = PageLayout

        table.insert(tabs, record)

        local tabHover = trackHover(TabButton, function(hovered)
            if currentTab == record then
                return
            end

            if hovered then
                TabButton.BackgroundTransparency = 0
                TabButton.BackgroundColor3 = Theme.CardHover
            else
                TabButton.BackgroundTransparency = 1
                TabButton.BackgroundColor3 = Theme.Sidebar
            end
        end)

        TabButton.MouseEnter:Connect(function()
            tabHover.hovered = true
            if currentTab ~= record then
                makeTween(TabButton, 0.14, {
                    BackgroundTransparency = 0,
                    BackgroundColor3 = Theme.CardHover,
                })
            end
        end)

        TabButton.MouseLeave:Connect(function()
            tabHover.hovered = false
            if currentTab ~= record then
                makeTween(TabButton, 0.14, {
                    BackgroundTransparency = 1,
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
            local newNormalized = normalizeImage(newImage)

            record.Image = newNormalized

            if iconObject and iconObject.Parent then
                iconObject:Destroy()
            end

            local rebuilt = buildIcon(
                TabButton,
                newNormalized,
                UDim2.new(0, 20, 0, 20),
                UDim2.new(0, 12, 0.5, -10),
                7,
                (currentTab == record and Theme.BlueLight) or Theme.MutedText
            )

            if rebuilt then
                iconObject = rebuilt
            else
                iconObject = create("TextLabel", {
                    Name = "Icon",
                    Parent = TabButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, -10),
                    Size = UDim2.new(0, 20, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = string.upper(string.sub(tabName, 1, 1)),
                    TextColor3 = (currentTab == record and Theme.BlueLight) or Theme.MutedText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 7,
                })
            end

            return true
        end

        function Tab:GetTabIcon()
            return record.Image
        end

        function Tab:SetSubtitle(subtitle)
            record.Subtitle = tostring(subtitle or "")

            if currentTab == record then
                PageSubtitle.Text = record.Subtitle ~= "" and record.Subtitle or defaultSubtitle
            end

            return true
        end

        function Tab:GetSubtitle()
            return record.Subtitle
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
                Size = UDim2.new(1, -8, 0, 26),
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
                Size = UDim2.new(1, -8, 0, subtitle and subtitle ~= "" and 46 or 26),
                BorderSizePixel = 0,
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            create("TextLabel", {
                Name = "Title",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 2, 0, 0),
                Size = UDim2.new(1, -4, 0, 22),
                Font = Enum.Font.GothamBold,
                Text = string.upper(tostring(headerText)),
                TextColor3 = Theme.MutedText,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            if subtitle and subtitle ~= "" then
                create("TextLabel", {
                    Name = "Subtitle",
                    Parent = Header,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 2, 0, 20),
                    Size = UDim2.new(1, -4, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(subtitle),
                    TextColor3 = Theme.SecondaryText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 8,
                })
            end

            return finish(Header)
        end

        function Tab:CreateInfoCard(cardTitle, description, accentColor, itemOrder)
            local accent = accentColor or Theme.Blue

            local Card = create("Frame", {
                Name = tostring(cardTitle) .. "InfoCard",
                Parent = Page,
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 70),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
                ClipsDescendants = true,
            })

            addCorner(Card, 10)
            addStroke(Card, Theme.ElementStroke, 1, 0.35)

            -- Flush full-height bar along the card's far-left edge. It
            -- deliberately overflows into the rounded corner region; the
            -- card's ClipsDescendants clips whatever sticks out.
            create("Frame", {
                Name = "Accent",
                Parent = Card,
                BackgroundColor3 = accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 4, 1, 0),
                ZIndex = 8,
            })

            create("TextLabel", {
                Name = "Title",
                Parent = Card,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 8),
                Size = UDim2.new(1, -30, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = tostring(cardTitle),
                TextColor3 = Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 8,
            })

            create("TextLabel", {
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

        function Tab:CreateStatCard(statTitle, statValue, accentColor, itemOrder)
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

            addCorner(Card, 10)
            addStroke(Card, Theme.ElementStroke, 1, 0.35)

            create("TextLabel", {
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

            create("TextLabel", {
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

        function Tab:CreateButton(text, callback, customColor, itemOrder)
            local baseColor = customColor or Theme.Card
            local textColor = textColorFor(baseColor)

            local Button = create("TextButton", {
                Name = tostring(text) .. "Button",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 44),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColor,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Center,
                AutoButtonColor = false,
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(Button, 9)
            addStroke(
                Button,
                customColor or Theme.ElementStroke,
                1,
                customColor and 0.18 or 0.35
            )

            local buttonHover = trackHover(Button, function(hovered)
                if hovered then
                    Button.BackgroundColor3 = hoverColorFor(customColor or Theme.Card)
                else
                    Button.BackgroundColor3 = customColor or Theme.Card
                end
            end)

            Button.MouseEnter:Connect(function()
                buttonHover.hovered = true
                makeTween(Button, 0.14, {
                    BackgroundColor3 = hoverColorFor(customColor or Theme.Card),
                })
            end)

            Button.MouseLeave:Connect(function()
                buttonHover.hovered = false
                makeTween(Button, 0.14, {
                    BackgroundColor3 = customColor or Theme.Card,
                })
            end)

            Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)

            return finish(Button)
        end

        function Tab:CreateToggle(text, default, callback, itemOrder, customColor)
            local toggled = default == true
            local baseColor = customColor or Theme.Card

            local ToggleFrame = create("Frame", {
                Name = tostring(text) .. "Toggle",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 48),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(ToggleFrame, 9)
            addStroke(
                ToggleFrame,
                customColor or Theme.ElementStroke,
                1,
                customColor and 0.18 or 0.35
            )

            create("TextLabel", {
                Name = "Title",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(1, -95, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 8,
            })

            local Switch = create("Frame", {
                Name = "Switch",
                Parent = ToggleFrame,
                BackgroundColor3 = Theme.PanelLight,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -64, 0.5, -11),
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
                    BackgroundColor3 = toggled and Theme.Secondary or Theme.PanelLight,
                })

                makeTween(Knob, 0.13, {
                    Position = toggled and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3),
                })
            end

            updateToggle()

            registerDynamicRefresher(function()
                if ToggleFrame.Parent == nil then
                    return false
                end

                updateToggle()
                return true
            end)

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

        function Tab:CreateSlider(text, defaultState, callback, defaultValue, minimum, maximum, itemOrder, customColor)
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

            currentValue = math.clamp(currentValue, minValue, maxValue)

            local baseColor = customColor or Theme.Card

            local SliderFrame = create("Frame", {
                Name = tostring(text) .. "Slider",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 80),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(SliderFrame, 9)
            addStroke(
                SliderFrame,
                customColor or Theme.ElementStroke,
                1,
                customColor and 0.18 or 0.35
            )

            create("TextLabel", {
                Name = "Title",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 7),
                Size = UDim2.new(1, -100, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
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
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 16, 0, 52),
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
                local ratio = (currentValue - minValue) / (maxValue - minValue)

                SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
                SliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
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
                    (input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X,
                    0,
                    1
                )

                currentValue = math.floor(minValue + ((maxValue - minValue) * ratio))
                currentValue = math.clamp(currentValue, minValue, maxValue)

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

                        if changed.UserInputType == Enum.UserInputType.MouseMovement
                            or changed.UserInputType == Enum.UserInputType.Touch then

                            updateFromInput(changed)
                        end
                    end)

                sliderEndConnection =
                    UserInputService.InputEnded:Connect(function(ended)
                        if ended.UserInputType == Enum.UserInputType.MouseButton1
                            or ended.UserInputType == Enum.UserInputType.Touch then

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
                currentValue = math.clamp(tonumber(value) or minValue, minValue, maxValue)

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

        function Tab:CreateTextbox(text, placeholder, callback, itemOrder, customColor, defaultValue)
            local baseColor = customColor or Theme.Card

            local TextboxFrame = create("Frame", {
                Name = tostring(text) .. "Textbox",
                Parent = Page,
                BackgroundColor3 = baseColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 76),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(TextboxFrame, 9)
            addStroke(
                TextboxFrame,
                customColor or Theme.ElementStroke,
                1,
                customColor and 0.18 or 0.35
            )

            create("TextLabel", {
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
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 12, 0, 36),
                Size = UDim2.new(1, -24, 0, 30),
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

            addCorner(Input, 7)
            addStroke(Input, Theme.ElementStroke, 1, 0.3)

            local function fireCallback(enterPressed)
                if callback then
                    callback(Input.Text, enterPressed == true)
                end
            end

            local inputHover = trackHover(Input, function(hovered)
                Input.BackgroundColor3 = hovered and Theme.CardHover or Theme.Secondary
            end)

            Input.Focused:Connect(function()
                inputHover.hovered = true
                makeTween(Input, 0.12, {
                    BackgroundColor3 = Theme.CardHover,
                })
            end)

            Input.FocusLost:Connect(function(enterPressed)
                inputHover.hovered = false
                makeTween(Input, 0.12, {
                    BackgroundColor3 = Theme.Secondary,
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

        function Tab:CreateDropdown(text, options, callback, itemOrder, customColor, multiSelect)
            assert(
                type(options) == "table" or type(options) == "function",
                "MoonLib CreateDropdown options must be a table or a function returning a table"
            )

            local isMulti =
                multiSelect == true
                or (
                    type(multiSelect) == "string"
                    and string.lower(multiSelect) == "multi"
                )

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
                Size = UDim2.new(1, 0, 0, 48),
                Font = Enum.Font.GothamBold,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 31,
            })

            addCorner(Header, 9)
            addStroke(
                Header,
                customColor or Theme.ElementStroke,
                1,
                customColor and 0.18 or 0.35
            )

            create("TextLabel", {
                Name = "Title",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 0),
                Size = UDim2.new(0.45, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = tostring(text),
                TextColor3 = textColorFor(baseColor),
                TextSize = 15,
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
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 32,
            })

            local Arrow = create("TextLabel", {
                Name = "Arrow",
                Parent = Header,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -34, 0, 0),
                Size = UDim2.new(0, 22, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = Theme.BlueLight,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 32,
            })

            local OptionsFrame = create("Frame", {
                Name = "Options",
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 56),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ClipsDescendants = false,
                ZIndex = 40,
            })

            addCorner(OptionsFrame, 10)
            addStroke(OptionsFrame, Theme.ElementStroke, 1, 0.25)

            create("UIListLayout", {
                Parent = OptionsFrame,
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
            })

            create("UIPadding", {
                Parent = OptionsFrame,
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
            })

            local function resolveOptions(source)
                local result = source

                if type(result) == "function" then
                    local success, returned = pcall(result)

                    if not success then
                        warn("MoonLib dropdown options function failed: " .. tostring(returned))
                        return {}
                    end

                    result = returned
                end

                if type(result) ~= "table" then
                    warn("MoonLib dropdown options must be a table or a function returning a table")
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

                button.BackgroundColor3 = option.Selected and Theme.Blue or Theme.PanelLight
                button.TextColor3 = option.Selected and textColorFor(Theme.Blue) or Theme.Text
            end

            local function getOptionsHeight()
                if #sortedOptions == 0 then
                    return 0
                end

                return (#sortedOptions * 36) + ((#sortedOptions - 1) * 4) + 8
            end

            local function updateDropdownSize()
                local height = getOptionsHeight()

                if isOpen and height > 0 then
                    OptionsFrame.Visible = true
                    OptionsFrame.Size = UDim2.new(1, 0, 0, height)
                    DropdownFrame.Size = UDim2.new(1, -8, 0, 56 + height)
                    Arrow.Text = "▲"
                else
                    OptionsFrame.Visible = false
                    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                    DropdownFrame.Size = UDim2.new(1, -8, 0, 50)
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

            local function rebuildOptions(newSource)
                if newSource ~= nil then
                    currentSource = newSource
                end

                local source = resolveOptions(currentSource)

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
                    if type(value) == "string" or type(value) == "number" then
                        table.insert(sortedOptions, {
                            Key = key,
                            Value = tostring(value),
                            Selected = selectedBefore[tostring(value)] == true,
                        })
                    end
                end

                table.sort(sortedOptions, function(a, b)
                    if type(a.Key) == "number" and type(b.Key) == "number" then
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

                    addCorner(OptionButton, 7)

                    create("UIPadding", {
                        Parent = OptionButton,
                        PaddingLeft = UDim.new(0, 10),
                    })

                    optionButtons[option] = OptionButton

                    local optionHover = trackHover(OptionButton, function(hovered)
                        if hovered then
                            OptionButton.BackgroundColor3 = option.Selected and Theme.BlueLight or Theme.CardHover
                        else
                            refreshOption(option)
                        end
                    end)

                    OptionButton.MouseEnter:Connect(function()
                        optionHover.hovered = true
                        makeTween(OptionButton, 0.12, {
                            BackgroundColor3 = option.Selected and Theme.BlueLight or Theme.CardHover,
                        })
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        optionHover.hovered = false
                        refreshOption(option)
                    end)

                    registerDynamicRefresher(function()
                        if OptionButton.Parent == nil then
                            return false
                        end

                        refreshOption(option)
                        return true
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

            local headerHover = trackHover(Header, function(hovered)
                if hovered then
                    Header.BackgroundColor3 = hoverColorFor(customColor or Theme.Card)
                else
                    Header.BackgroundColor3 = customColor or Theme.Card
                end
            end)

            Header.MouseEnter:Connect(function()
                headerHover.hovered = true
                makeTween(Header, 0.12, {
                    BackgroundColor3 = hoverColorFor(customColor or Theme.Card),
                })
            end)

            Header.MouseLeave:Connect(function()
                headerHover.hovered = false
                makeTween(Header, 0.12, {
                    BackgroundColor3 = customColor or Theme.Card,
                })
            end)

            Header.MouseButton1Click:Connect(function()
                isOpen = not isOpen

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

        -- In-page announcement banner. Colors follow the same rules as
        -- toasts: Info = accent, Success/Warn/Error forced.
        function Tab:CreateAnnouncement(annTitle, message, state, itemOrder, color, icon)
            local customAccent = color
            local currentState = normalizeAnnouncementState(state)
            local accent = announceAccent(currentState, customAccent)

            local Banner = create("Frame", {
                Name = "Announcement",
                Parent = Page,
                BackgroundColor3 = Theme.Card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 64),
                LayoutOrder = itemOrder or 0,
                ZIndex = 7,
            })

            addCorner(Banner, 10)
            local stroke = addStroke(Banner, accent, 1.5, 0.08)

            local IconHolder = create("Frame", {
                Name = "IconHolder",
                Parent = Banner,
                BackgroundColor3 = accent,
                BackgroundTransparency = 0.82,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 11, 0.5, -17),
                Size = UDim2.new(0, 34, 0, 34),
                ZIndex = 8,
            })

            addCorner(IconHolder, 8)
            local iconStroke = addStroke(IconHolder, accent, 1, 0.25)

            local Glyph = create("TextLabel", {
                Name = "Glyph",
                Parent = IconHolder,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = stateGlyph(currentState),
                TextColor3 = accent,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 9,
            })

            -- Icon resolution: a per-call icon override wins; otherwise the
            -- Custom type falls back to the window's custom icon setting
            -- (a star glyph is used when none is configured).
            local iconOverrideSet = icon ~= nil
            local explicitIcon = iconOverrideSet and normalizeImage(icon) or nil

            local function resolveBannerIcon()
                if iconOverrideSet then
                    return explicitIcon
                end

                if currentState == "Custom" and announceCustomIcon then
                    return normalizeImage(announceCustomIcon)
                end

                return nil
            end

            local iconImage

            local function refreshBannerIcon()
                local img = resolveBannerIcon()

                if img then
                    if not iconImage then
                        iconImage = create("ImageLabel", {
                            Name = "IconImage",
                            Parent = IconHolder,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, -8, 1, -8),
                            Position = UDim2.new(0, 4, 0, 4),
                            ScaleType = Enum.ScaleType.Fit,
                            ZIndex = 9,
                        })
                    end

                    iconImage.Image = img
                    iconImage.ImageColor3 = accent
                    iconImage.Visible = true
                    Glyph.Visible = false
                else
                    if iconImage then
                        iconImage.Visible = false
                    end

                    Glyph.Visible = true
                end
            end

            refreshBannerIcon()

            local TitleLabel = create("TextLabel", {
                Name = "Title",
                Parent = Banner,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 56, 0, 8),
                Size = UDim2.new(1, -100, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = tostring(annTitle or defaultStateTitle(currentState)),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 8,
            })

            local messageHolder = create("Frame", {
                Name = "MessageHolder",
                Parent = Banner,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 56, 0, 27),
                Size = UDim2.new(1, -100, 0, 26),
                ClipsDescendants = true,
                ZIndex = 8,
            })

            local MessageLabel = create("TextLabel", {
                Name = "Message",
                Parent = messageHolder,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = tostring(message or ""),
                TextColor3 = Theme.SecondaryText,
                TextSize = 12,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                ZIndex = 9,
            })

            local DismissButton = create("TextButton", {
                Name = "Dismiss",
                Parent = Banner,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -34, 0.5, -13),
                Size = UDim2.new(0, 26, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = "×",
                TextColor3 = Theme.MutedText,
                TextSize = 16,
                AutoButtonColor = false,
                ZIndex = 10,
            })

            local dismissHover = trackHover(DismissButton, function(hovered)
                DismissButton.TextColor3 = hovered and Theme.Text or Theme.MutedText
            end)

            DismissButton.MouseEnter:Connect(function()
                dismissHover.hovered = true
                makeTween(DismissButton, 0.12, { TextColor3 = Theme.Text })
            end)

            DismissButton.MouseLeave:Connect(function()
                dismissHover.hovered = false
                makeTween(DismissButton, 0.12, { TextColor3 = Theme.MutedText })
            end)

            local AnnouncementObject = {}

            local function applyState(newState, newColor)
                if newColor ~= nil then
                    customAccent = newColor
                end

                currentState = normalizeAnnouncementState(newState)
                accent = announceAccent(currentState, customAccent)

                stroke.Color = accent
                IconHolder.BackgroundColor3 = accent
                iconStroke.Color = accent
                Glyph.TextColor3 = accent
                Glyph.Text = stateGlyph(currentState)

                if iconImage then
                    iconImage.ImageColor3 = accent
                end

                refreshBannerIcon()
            end

            announceRefreshers[#announceRefreshers + 1] = function()
                if Banner.Parent == nil then
                    return false
                end

                applyState(currentState, customAccent)
                refreshBannerIcon()
                return true
            end

            function AnnouncementObject:SetState(newState, color)
                applyState(newState, color)
                return currentState
            end

            function AnnouncementObject:SetColor(color)
                if typeof(color) ~= "Color3" then
                    warn("[MoonLib] SetColor expects a Color3")
                    return false
                end

                applyState(currentState, color)
                return true
            end

            function AnnouncementObject:GetColor()
                return accent
            end

            function AnnouncementObject:GetState()
                return currentState
            end

            function AnnouncementObject:SetTitle(newTitle)
                TitleLabel.Text = tostring(newTitle or "")
                return true
            end

            function AnnouncementObject:GetTitle()
                return TitleLabel.Text
            end

            function AnnouncementObject:SetMessage(newMessage)
                MessageLabel.Text = tostring(newMessage or "")
                return true
            end

            function AnnouncementObject:GetMessage()
                return MessageLabel.Text
            end

            function AnnouncementObject:SetIcon(image)
                if image == nil or image == "" then
                    -- Reset to the window default (star, or the custom
                    -- icon set through SetAnnounceCustomIcon).
                    iconOverrideSet = false
                    explicitIcon = nil
                    refreshBannerIcon()
                    return true
                end

                local normalized = normalizeImage(image)

                if not normalized then
                    warn("[MoonLib] SetIcon expects an image id, rbxassetid or nil to reset")
                    return false
                end

                iconOverrideSet = true
                explicitIcon = normalized
                refreshBannerIcon()
                return true
            end

            function AnnouncementObject:Dismiss()
                Banner:Destroy()
            end

            AnnouncementObject.Destroy = AnnouncementObject.Dismiss

            DismissButton.MouseButton1Click:Connect(function()
                AnnouncementObject:Dismiss()
            end)

            finish(Banner)

            return AnnouncementObject
        end

        return Tab
    end

    -- =================================================
    --  Window API
    -- =================================================

    function Window:SetTitle(newTitle)
        WindowTitle.Text = tostring(newTitle or "")
    end

    function Window:GetTitle()
        return WindowTitle.Text
    end

    function Window:SetWindowImage(image)
        applyLogoImage(image)
    end

    function Window:SetImage(image)
        applyLogoImage(image)
    end

    function Window:SetUser(name, role, avatarImage, roleColor)
        if name ~= nil then
            UserNameLabel.Text = tostring(name)
            AvatarFallback.Text = string.upper(string.sub(tostring(name), 1, 1))
        end

        if role ~= nil then
            UserRoleLabel.Text = tostring(role)
        end

        if typeof(roleColor) == "Color3" then
            UserRoleLabel.TextColor3 = roleColor
        end

        if avatarImage ~= nil then
            local normalized = normalizeImage(avatarImage)

            if normalized then
                AvatarImage.Image = normalized
                AvatarImage.Visible = true
                AvatarFallback.Visible = false
            end
        end

        return true
    end

    function Window:SetUserVisible(state)
        UserCard.Visible = state == true
        return UserCard.Visible
    end

    -- Granular user card controls.
    function Window:SetProfileName(name)
        name = tostring(name or "")

        UserNameLabel.Text = name
        AvatarFallback.Text = string.upper(string.sub(name, 1, 1))

        return true
    end

    function Window:GetProfileName()
        return UserNameLabel.Text
    end

    function Window:SetProfileRank(rank, color)
        UserRoleLabel.Text = tostring(rank == nil and "" or rank)

        if typeof(color) == "Color3" then
            UserRoleLabel.TextColor3 = color
        end

        return true
    end

    function Window:GetProfileRank()
        return UserRoleLabel.Text
    end

    function Window:SetProfileRankColor(color)
        if typeof(color) ~= "Color3" then
            warn("[MoonLib] SetProfileRankColor expects a Color3")
            return false
        end

        UserRoleLabel.TextColor3 = color
        return true
    end

    function Window:SetProfileCardColor(color)
        if typeof(color) ~= "Color3" then
            warn("[MoonLib] SetProfileCardColor expects a Color3")
            return false
        end

        UserCard.BackgroundColor3 = color
        return true
    end

    -- Presence bubble controls.
    function Window:SetPresenceColor(color)
        if typeof(color) ~= "Color3" then
            warn("[MoonLib] SetPresenceColor expects a Color3")
            return false
        end

        presenceColor = color
        applyPresence()

        return true
    end

    function Window:GetPresenceColor()
        return presenceColor
    end

    function Window:SetPresenceStyle(style)
        local value = string.lower(tostring(style or ""))

        if value == "dot" then
            presenceStyle = "Dot"
        elseif value == "ring" then
            presenceStyle = "Ring"
        elseif value == "hidden" or value == "off" or value == "none" then
            presenceStyle = "Hidden"
        else
            warn("[MoonLib] SetPresenceStyle expects 'Dot', 'Ring' or 'Hidden'")
            return false
        end

        applyPresence()
        return true
    end

    function Window:GetPresenceStyle()
        return presenceStyle
    end

    -- Pass an asset id/string to decorate the bubble, or nil to remove it.
    function Window:SetPresenceImage(image)
        if image == nil then
            presenceImage = nil
            applyPresence()
            return true
        end

        local normalized = normalizeImage(image)

        if not normalized then
            warn("[MoonLib] SetPresenceImage could not normalize the image")
            return false
        end

        presenceImage = normalized
        applyPresence()

        return true
    end

    function Window:GetPresenceImage()
        return presenceImage
    end

    function Window:SetDefaultSubtitle(text)
        defaultSubtitle = tostring(text or "")

        if currentTab then
            PageSubtitle.Text = currentTab.Subtitle ~= "" and currentTab.Subtitle or defaultSubtitle
        else
            PageSubtitle.Text = defaultSubtitle
        end

        return true
    end

    function Window:SetStateKeybind(keyCode)
        if typeof(keyCode) ~= "EnumItem" or keyCode.EnumType ~= Enum.KeyCode then
            warn("MoonLib SetStateKeybind expects an Enum.KeyCode value.")
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

    -- Tab switch animation style: "Fade" (default), "Drop-In", "Pop"
    -- or "None". "Jump" and "Slide" were removed in 2.6.0 (they fall
    -- back to Fade).
    local transitionFallbackWarned = false

    function Window:SetTabTransition(style)
        local value = string.lower(tostring(style or ""))

        if value == "fade" then
            tabTransition = "Fade"
        elseif value == "drop-in" or value == "drop_in" or value == "dropin" then
            tabTransition = "Drop-In"
        elseif value == "pop" or value == "pop-in" or value == "pop_in" or value == "spring" then
            tabTransition = "Pop"
        elseif value == "jump" or value == "slide" then
            -- Jump (and its former name, Slide) was removed; fall back to
            -- Fade so existing configs keep working.
            if not transitionFallbackWarned then
                transitionFallbackWarned = true
                warn("[MoonLib] SetTabTransition('Jump') was removed; using 'Fade' instead")
            end

            tabTransition = "Fade"
        elseif value == "none" or value == "off" or value == "disabled" then
            tabTransition = "None"
        else
            warn("[MoonLib] SetTabTransition expects 'Fade', 'Drop-In', 'Pop' or 'None'")
            return false
        end

        return true
    end

    function Window:GetTabTransition()
        return tabTransition
    end

    function Window:Toggle()
        toggleWindow()
    end

    function Window:IsVisible()
        return visible
    end

    function Window:SetVisible(state)
        visible = state == true
        MainFrame.Visible = visible
    end

    function Window:SetSize(size)
        assert(typeof(size) == "UDim2", "SetSize expects a UDim2")
        MainFrame.Size = size
    end

    function Window:SetPosition(position)
        assert(typeof(position) == "UDim2", "SetPosition expects a UDim2")
        MainFrame.Position = position
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

    -- =================================================
    --  Announcement API
    -- =================================================

    -- Window:Announce("Title", "Message", "Success", 5)
    -- Window:Announce("Message")               -- title = state label
    -- Window:Announce({ Title=, Message=, State=, Duration=, Color= })
    -- duration 0 = sticky. States: Info/Success/Warn/Error/Custom.
    -- Error is sticky by default; pass a duration to show a timer.
    function Window:Announce(a, b, c, d, e)
        local title, message, state, duration, color

        if type(a) == "table" then
            local tbl = a
            title = tbl.Title or tbl.title
            message = tbl.Message or tbl.message
            state = tbl.State or tbl.state
            duration = tbl.Duration or tbl.duration
            color = tbl.Color or tbl.color or tbl.CustomColor
        else
            title, message, state, duration, color = a, b, c, d, e
        end

        if message == nil then
            message = title
            title = nil
        end

        return showToast(title, message, state, duration, color)
    end

    function Window:AnnounceInfo(message, title, duration)
        return showToast(title, message, "Info", duration)
    end

    function Window:AnnounceSuccess(message, title, duration)
        return showToast(title, message, "Success", duration)
    end

    function Window:AnnounceWarn(message, title, duration)
        return showToast(title, message, "Warn", duration)
    end

    function Window:AnnounceError(message, title, duration)
        return showToast(title, message, "Error", duration)
    end

    -- Custom accent toast (color is the accent; falls back to the window
    -- accent when omitted).
    function Window:AnnounceCustom(message, title, color, duration)
        return showToast(title, message, "Custom", duration, color)
    end

    -- Notification color mode. Default false: every type keeps its defined
    -- color (Info = accent, Success/Warn/Error forced, Custom = the color
    -- you pass). Set true to force EVERY notification to the base accent
    -- color (BaseColor), including Custom.
    function Window:SetAnnounceBaseColor(enabled)
        announceUseBaseColor = enabled == true
        refreshAnnouncements()
        return announceUseBaseColor
    end

    function Window:GetAnnounceBaseColor()
        return announceUseBaseColor
    end

    -- Custom-type icon. Default nil: the Custom announcement shows a star.
    -- Pass an image id / rbxassetid to use your own image for the Custom
    -- type (toasts and in-page banners). Pass nil to reset to the star.
    function Window:SetAnnounceCustomIcon(image)
        if image == nil or image == false or image == "" then
            announceCustomIcon = nil
            refreshAnnouncements()
            return true
        end

        local normalized = normalizeImage(image)

        if not normalized then
            warn("[MoonLib] SetAnnounceCustomIcon expects an image id, rbxassetid or nil to reset")
            return false
        end

        announceCustomIcon = normalized
        refreshAnnouncements()
        return true
    end

    function Window:GetAnnounceCustomIcon()
        return announceCustomIcon
    end

    -- =================================================
    --  Window appearance API
    -- =================================================

    local mainColor = Theme.Blue
    local backgroundAnimationConnection = nil
    local backgroundAnimationToken = 0

    stopBackgroundAnimation = function()
        backgroundAnimationToken = backgroundAnimationToken + 1

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

    -- Generic single-key surface color swap. Used by the individual
    -- setters and by the theme system.
    local function swapColor(key, value)
        if typeof(value) ~= "Color3" then
            warn("[MoonLib] '" .. tostring(key) .. "' expects a Color3")
            return false
        end

        recolorTagged(key, Theme[key], value)
        Theme[key] = value
        refreshAllHovers()
        refreshDynamic()
        refreshAnnouncements()

        return true
    end

    local function refreshAllTabVisuals()
        if currentTab then
            setTabVisual(currentTab.Button, true)
        end

        for _, record in ipairs(tabs) do
            if record ~= currentTab then
                setTabVisual(record.Button, false)
            end
        end
    end

    local function applyTabStrokes()
        for _, stroke in ipairs(tabStrokeRefs) do
            stroke.Color = tabStroke.Color
            stroke.Thickness = tabStroke.Thickness
            stroke.Transparency = tabStroke.Transparency
        end

        refreshAllTabVisuals()
    end

    local currentRegularFont = Enum.Font.Gotham
    local currentBoldFont = Enum.Font.GothamBold

    local function applyFont()
        for _, object in ipairs(ScreenGui:GetDescendants()) do
            if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                local ok, bold = pcall(function()
                    return object:GetAttribute("FontBold")
                end)

                object.Font = (ok and bold) and currentBoldFont or currentRegularFont
            end
        end
    end

    local function applyCornerRadius(radius)
        cornerRadiusDefault = math.max(0, tonumber(radius) or cornerRadiusDefault)

        for _, object in ipairs(ScreenGui:GetDescendants()) do
            if object:IsA("UICorner") then
                local parent = object.Parent
                local side = 0

                if parent and parent:IsA("GuiObject") then
                    local size = parent.AbsoluteSize
                    side = math.min(size.X, size.Y)
                end

                local value = cornerRadiusDefault

                if side > 0 then
                    value = math.min(cornerRadiusDefault, math.floor(side / 2))
                end

                object.CornerRadius = UDim.new(0, value)
            end
        end
    end

    local function mergeSpriteConfig(config)
        local cfg = backgroundState.Config

        if type(config) ~= "table" then
            return cfg
        end

        if config.Rows ~= nil then
            cfg.Rows = math.max(1, math.floor(tonumber(config.Rows) or cfg.Rows))
        end

        if config.Columns ~= nil then
            cfg.Columns = math.max(1, math.floor(tonumber(config.Columns) or cfg.Columns))
        end

        if config.FrameCount ~= nil then
            cfg.FrameCount = math.max(1, math.floor(tonumber(config.FrameCount) or cfg.FrameCount))
        end

        if config.FrameRate ~= nil then
            cfg.FrameRate = math.max(1, tonumber(config.FrameRate) or cfg.FrameRate)
        end

        if config.ImageSize ~= nil then
            if typeof(config.ImageSize) == "Vector2" then
                cfg.ImageSize = config.ImageSize
            end
        end

        if config.ImageTransparency ~= nil then
            cfg.ImageTransparency = math.clamp(tonumber(config.ImageTransparency) or cfg.ImageTransparency, 0, 1)
        end

        if config.ScaleType ~= nil then
            cfg.ScaleType = config.ScaleType
        end

        return cfg
    end

    -- Applies an image/background string with the stored (or merged) config.
    local function applyBackgroundImage(imageString, config)
        stopBackgroundAnimation()

        if config then
            mergeSpriteConfig(config)
        end

        local normalized = normalizeImage(imageString)

        if not normalized then
            BackgroundImage.Visible = false
            BackgroundImage.Image = ""
            backgroundState.Value = imageString
            return false
        end

        -- Executors with file APIs can cache remote images locally.
        -- Skipped entirely outside executors (plain Roblox modules).
        if IS_EXECUTOR and normalized:match("^https?://") then
            local writefileFn = lookupExecutorGlobal("writefile")
            local getcustomassetFn = lookupExecutorGlobal("getcustomasset")

            if type(writefileFn) == "function" and type(getcustomassetFn) == "function" then
                local success, customAsset = pcall(function()
                    local httpOk, response = pcall(function()
                        return game:HttpGet(normalized)
                    end)

                    if not httpOk or not response then
                        return nil
                    end

                    local extension = normalized:match("%.([%w]+)[%?]?.*$") or "png"
                    local fileName = "MoonLibBackground_" .. tostring(math.floor(os.clock() * 100000)) .. "." .. extension
                    writefileFn(fileName, response)
                    return getcustomassetFn(fileName)
                end)

                if success and customAsset then
                    normalized = customAsset
                end
            end
        end

        backgroundState.Value = imageString

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

        backgroundState.ImageTransparency = backgroundState.Config.ImageTransparency
        BackgroundImage.ImageTransparency = backgroundState.ImageTransparency
        BackgroundImage.ScaleType = backgroundState.Config.ScaleType
        BackgroundImage.Visible = true

        local rows = backgroundState.Config.Rows
        local columns = backgroundState.Config.Columns
        local frameCount = backgroundState.Config.FrameCount
        local frameRate = backgroundState.Config.FrameRate

        if frameCount > 1 and (rows > 1 or columns > 1) then
            local frameSize = Vector2.new(
                backgroundState.Config.ImageSize.X / columns,
                backgroundState.Config.ImageSize.Y / rows
            )

            BackgroundImage.ImageRectSize = frameSize

            local frame = 0
            local elapsed = 0
            local token = backgroundAnimationToken

            backgroundAnimationConnection = RunService.Heartbeat:Connect(function(deltaTime)
                if destroyed or token ~= backgroundAnimationToken then
                    return
                end

                elapsed = elapsed + deltaTime

                local frameDuration = 1 / frameRate

                if elapsed >= frameDuration then
                    local steps = math.floor(elapsed / frameDuration)
                    elapsed = elapsed - steps * frameDuration
                    frame = (frame + steps) % frameCount

                    local column = frame % columns
                    local row = math.floor(frame / columns)

                    BackgroundImage.ImageRectOffset = Vector2.new(column * frameSize.X, row * frameSize.Y)
                end
            end)
        end

        return true
    end

    local function applyBackgroundValue(value)
        if value == nil then
            value = backgroundState.Value
        end

        stopBackgroundAnimation()

        if typeof(value) == "Color3" then
            backgroundState.Value = value
            BackgroundImage.Visible = false
            BackgroundImage.Image = ""
            MainFrame.BackgroundColor3 = value
            InnerFrame.BackgroundColor3 = value
            InnerFrame.BackgroundTransparency = 1
            InnerGradient.Enabled = false
            return true
        end

        local config = type(value) == "table" and value or nil
        local image = config and (config.Image or config.image) or value

        if config then
            mergeSpriteConfig(config)
        end

        return applyBackgroundImage(image, nil)
    end

    function Window:SetMainColor(color)
        assert(typeof(color) == "Color3", "SetMainColor expects a Color3")

        local oldBlue = Theme.Blue
        local oldBlueLight = Theme.BlueLight
        local oldBlueDark = Theme.BlueDark

        local newLight = color:Lerp(Color3.new(1, 1, 1), 0.32)
        local newDark = color:Lerp(Color3.new(0, 0, 0), 0.55)

        replaceColorInGui(oldBlue, color)
        replaceColorInGui(oldBlueLight, newLight)
        replaceColorInGui(oldBlueDark, newDark)

        -- Tag-based pass: catches ScrollBarImageColor3 and any other
        -- property replaceColorInGui does not know about.
        recolorTagged("Blue", oldBlue, color)
        recolorTagged("BlueLight", oldBlueLight, newLight)
        recolorTagged("BlueDark", oldBlueDark, newDark)

        Theme.Blue = color
        Theme.BlueLight = newLight
        Theme.BlueDark = newDark
        Theme.BaseColor = color
        mainColor = color
        refreshAllHovers()
        refreshDynamic()
        refreshAnnouncements()

        LogoGradient.Color = ColorSequence.new(newLight, newDark)

        return true
    end

    function Window:GetMainColor()
        return mainColor
    end

    -- Alias matching the theme key name.
    function Window:SetBaseColor(color)
        return self:SetMainColor(color)
    end

    function Window:GetBaseColor()
        return self:GetMainColor()
    end

    function Window:SetBackground(value)
        local result = applyBackgroundValue(value)

        if result and typeof(value) == "Color3" then
            backgroundState.Transparency = 0
            MainFrame.BackgroundTransparency = 0
        end

        return result
    end

    function Window:GetBackground()
        return backgroundState.Value
    end

    function Window:SetBackgroundTransparency(transparency)
        transparency = math.clamp(tonumber(transparency) or 0, 0, 1)

        backgroundState.Transparency = transparency
        MainFrame.BackgroundTransparency = transparency
        InnerFrame.BackgroundTransparency = transparency
        BackgroundImage.ImageTransparency = math.clamp(
            math.max(backgroundState.ImageTransparency, transparency),
            0,
            1
        )

        return true
    end

    function Window:GetBackgroundTransparency()
        return backgroundState.Transparency
    end

    function Window:SetBackgroundImageTransparency(transparency)
        backgroundState.ImageTransparency = math.clamp(tonumber(transparency) or 0, 0, 1)

        if BackgroundImage.Visible then
            BackgroundImage.ImageTransparency = backgroundState.ImageTransparency
        end

        return true
    end

    function Window:GetBackgroundImageTransparency()
        return backgroundState.ImageTransparency
    end

    -- =================================================
    --  Individual appearance setters (one change each)
    -- =================================================

    local function mainBackgroundSwap(value)
        local ok = swapColor("MainBackground", value)

        if ok and typeof(value) == "Color3" then
            MainFrame.BackgroundColor3 = value
            InnerFrame.BackgroundColor3 = value
            InnerGradient.Color = ColorSequence.new(
                value:Lerp(Color3.new(1, 1, 1), 0.10),
                value:Lerp(Color3.new(0, 0, 0), 0.55)
            )
        end

        return ok
    end

    local themeableKeys = {
        MainBackground = true, Sidebar = true, Panel = true, PanelLight = true,
        Card = true, CardHover = true, Input = true,
        TabActiveColor = true, BaseColor = true,
        Border = true, BrightBorder = true, Divider = true,
        Secondary = true, ElementStroke = true,
        Text = true, SecondaryText = true, MutedText = true, DarkText = true,
        TabsStrokeColor = true, TabStrokeThickness = true, TabStrokeTransparency = true,
        Background = true, BackgroundImage = true, BackgroundImageTransparency = true,
        BackgroundConfig = true, BackgroundTransparency = true,
        Font = true, CornerRadius = true,
    }

    function Window:SetMainBackgroundColor(value)
        return mainBackgroundSwap(value)
    end

    function Window:SetSidebarColor(value)
        return swapColor("Sidebar", value)
    end

    function Window:SetPanelColor(value)
        return swapColor("Panel", value)
    end

    function Window:SetPanelLightColor(value)
        return swapColor("PanelLight", value)
    end

    function Window:SetCardColor(value)
        return swapColor("Card", value)
    end

    function Window:SetCardHoverColor(value)
        return swapColor("CardHover", value)
    end

    function Window:SetInputColor(value)
        return swapColor("Input", value)
    end

    function Window:SetTabActiveColor(value)
        if typeof(value) ~= "Color3" then
            warn("[MoonLib] SetTabActiveColor expects a Color3")
            return false
        end

        replaceColorInGui(tabActiveColor, value)
        tabActiveColor = value
        refreshAllTabVisuals()
        refreshAllHovers()

        return true
    end

    function Window:SetTextColor(value)
        return swapColor("Text", value)
    end

    function Window:SetSecondaryTextColor(value)
        return swapColor("SecondaryText", value)
    end

    function Window:SetMutedTextColor(value)
        return swapColor("MutedText", value)
    end

    function Window:SetDarkTextColor(value)
        return swapColor("DarkText", value)
    end

    function Window:SetBorderColor(value)
        return swapColor("Border", value)
    end

    function Window:SetBrightBorderColor(value)
        return swapColor("BrightBorder", value)
    end

    function Window:SetDividerColor(value)
        return swapColor("Divider", value)
    end

    function Window:GetDividerColor()
        return Theme.Divider
    end

    function Window:SetSecondaryColor(value)
        return swapColor("Secondary", value)
    end

    function Window:GetSecondaryColor()
        return Theme.Secondary
    end

    function Window:SetElementStrokeColor(value)
        return swapColor("ElementStroke", value)
    end

    function Window:GetElementStrokeColor()
        return Theme.ElementStroke
    end

    function Window:SetTabsStrokeColor(value)
        if typeof(value) ~= "Color3" then
            warn("[MoonLib] SetTabsStrokeColor expects a Color3")
            return false
        end

        tabStroke.Color = value
        applyTabStrokes()

        return true
    end

    function Window:SetTabStrokeThickness(value)
        value = tonumber(value)

        if not value or value < 0 then
            warn("[MoonLib] SetTabStrokeThickness expects a number >= 0 (0 disables the stroke)")
            return false
        end

        tabStroke.Thickness = value
        applyTabStrokes()

        return true
    end

    function Window:SetTabStrokeTransparency(value)
        value = tonumber(value)

        if value == nil then
            warn("[MoonLib] SetTabStrokeTransparency expects a number")
            return false
        end

        tabStroke.Transparency = math.clamp(value, 0, 1)
        applyTabStrokes()

        return true
    end

    function Window:SetFont(fontOrConfig)
        local resolved = resolveFontConfig(fontOrConfig)

        if not resolved then
            return false
        end

        currentRegularFont = resolved.Regular
        currentBoldFont = resolved.Bold
        applyFont()

        return true
    end

    function Window:GetFont()
        return {
            Regular = currentRegularFont,
            Bold = currentBoldFont,
        }
    end

    function Window:SetCornerRadius(radius)
        local value = tonumber(radius)

        if value == nil then
            warn("[MoonLib] SetCornerRadius expects a number of pixels")
            return false
        end

        applyCornerRadius(value)

        return true
    end

    function Window:GetCornerRadius()
        return cornerRadiusDefault
    end

    -- =================================================
    --  Custom themes
    -- =================================================

    -- Applies a theme table. Only keys present in the table are
    -- changed; everything else is left exactly as it was.
    function Window:SetTheme(themeTable)
        assert(type(themeTable) == "table", "SetTheme expects a theme table")

        for key in pairs(themeTable) do
            if not themeableKeys[key] then
                warn("[MoonLib] Unknown theme key '" .. tostring(key) .. "' - ignored")
            end
        end

        -- Simple surface colors
        local colorMap = {
            Sidebar = "Sidebar",
            Panel = "Panel",
            PanelLight = "PanelLight",
            Card = "Card",
            CardHover = "CardHover",
            Input = "Input",
            Border = "Border",
            BrightBorder = "BrightBorder",
            Divider = "Divider",
            Secondary = "Secondary",
            ElementStroke = "ElementStroke",
            Text = "Text",
            SecondaryText = "SecondaryText",
            MutedText = "MutedText",
            DarkText = "DarkText",
        }

        if themeTable.MainBackground ~= nil then
            mainBackgroundSwap(themeTable.MainBackground)
        end

        for key, themeKey in pairs(colorMap) do
            if themeTable[key] ~= nil then
                swapColor(themeKey, themeTable[key])
            end
        end

        -- Tab stroke
        local tabStrokeChanged = false

        if themeTable.TabsStrokeColor ~= nil then
            if typeof(themeTable.TabsStrokeColor) == "Color3" then
                tabStroke.Color = themeTable.TabsStrokeColor
                tabStrokeChanged = true
            else
                warn("[MoonLib] TabsStrokeColor expects a Color3")
            end
        end

        if themeTable.TabStrokeThickness ~= nil then
            local value = tonumber(themeTable.TabStrokeThickness)

            if value and value >= 0 then
                tabStroke.Thickness = value
                tabStrokeChanged = true
            else
                warn("[MoonLib] TabStrokeThickness expects a number >= 0 (0 disables the stroke)")
            end
        end

        if themeTable.TabStrokeTransparency ~= nil then
            local value = tonumber(themeTable.TabStrokeTransparency)

            if value ~= nil then
                tabStroke.Transparency = math.clamp(value, 0, 1)
                tabStrokeChanged = true
            else
                warn("[MoonLib] TabStrokeTransparency expects a number")
            end
        end

        if tabStrokeChanged then
            applyTabStrokes()
        end

        if themeTable.TabActiveColor ~= nil then
            self:SetTabActiveColor(themeTable.TabActiveColor)
        end

        -- Accent
        if themeTable.BaseColor ~= nil then
            self:SetMainColor(themeTable.BaseColor)
        end

        -- Background (value/image/config)
        if themeTable.Background ~= nil then
            applyBackgroundValue(themeTable.Background)
        end

        if themeTable.BackgroundConfig ~= nil then
            mergeSpriteConfig(themeTable.BackgroundConfig)

            -- Re-apply the stored background so the new config takes effect,
            -- without clobbering it with the stale stored table.
            if BackgroundImage.Visible then
                local stored = backgroundState.Value
                local imageSource = type(stored) == "table" and ((stored.Image or stored.image)) or stored

                if type(imageSource) == "string" or type(imageSource) == "number" then
                    applyBackgroundImage(imageSource, nil)
                end
            end
        end

        if themeTable.BackgroundImage ~= nil then
            applyBackgroundImage(themeTable.BackgroundImage, themeTable.BackgroundConfig)
        end

        if themeTable.BackgroundImageTransparency ~= nil then
            self:SetBackgroundImageTransparency(themeTable.BackgroundImageTransparency)
        end

        if themeTable.BackgroundTransparency ~= nil then
            self:SetBackgroundTransparency(themeTable.BackgroundTransparency)
        end

        -- Global style
        if themeTable.Font ~= nil then
            self:SetFont(themeTable.Font)
        end

        if themeTable.CornerRadius ~= nil then
            self:SetCornerRadius(themeTable.CornerRadius)
        end

        return true
    end

    -- Snapshot of the CURRENT effective theme (all keys).
    function Window:GetTheme()
        return {
            MainBackground = Theme.MainBackground,
            Sidebar = Theme.Sidebar,
            Panel = Theme.Panel,
            PanelLight = Theme.PanelLight,
            Card = Theme.Card,
            CardHover = Theme.CardHover,
            Input = Theme.Input,
            TabActiveColor = tabActiveColor,
            BaseColor = Theme.Blue,
            Border = Theme.Border,
            BrightBorder = Theme.BrightBorder,
            Divider = Theme.Divider,
            Secondary = Theme.Secondary,
            ElementStroke = Theme.ElementStroke,
            Text = Theme.Text,
            SecondaryText = Theme.SecondaryText,
            MutedText = Theme.MutedText,
            DarkText = Theme.DarkText,
            TabsStrokeColor = tabStroke.Color,
            TabStrokeThickness = tabStroke.Thickness,
            TabStrokeTransparency = tabStroke.Transparency,
            Background = deepCopy(backgroundState.Value),
            BackgroundConfig = deepCopy(backgroundState.Config),
            BackgroundTransparency = backgroundState.Transparency,
            BackgroundImageTransparency = backgroundState.ImageTransparency,
            Font = {
                Regular = currentRegularFont,
                Bold = currentBoldFont,
            },
            CornerRadius = cornerRadiusDefault,
        }
    end

    -- Save the window's current effective theme under a name.
    function Window:ThemeSave(name)
        return registerThemeInternal(name, self:GetTheme())
    end

    -- Load a theme registered with MoonLib:RegisterTheme / Window:ThemeSave.
    function Window:ThemeLoad(name)
        local theme = RegisteredThemes[tostring(name)]

        if not theme then
            warn("[MoonLib] No theme registered under '" .. tostring(name) .. "'")
            return false
        end

        return self:SetTheme(deepCopy(theme))
    end

    -- Construct the window with an optional theme (only provided keys apply).
    if theme ~= nil then
        Window:SetTheme(theme)
    end

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.Theme = Theme

    return Window
end

-- =====================================================
--  Theme registry (shared between all windows)
-- =====================================================

-- MoonLib:RegisterTheme("Ocean", { BaseColor = Color3.fromRGB(80, 180, 255), ... })
-- Window:ThemeLoad("Ocean") applies it to a window any time.
function MoonLib:RegisterTheme(name, theme)
    local success, err = registerThemeInternal(name, theme)

    if not success then
        warn("[MoonLib] " .. tostring(err))
        return false
    end

    return true
end

function MoonLib:UnregisterTheme(name)
    name = tostring(name)

    local existed = RegisteredThemes[name] ~= nil
    RegisteredThemes[name] = nil

    return existed
end

function MoonLib:GetTheme(name)
    local theme = RegisteredThemes[tostring(name)]

    return theme and deepCopy(theme) or nil
end

function MoonLib:GetRegisteredThemes()
    local names = {}

    for name in pairs(RegisteredThemes) do
        table.insert(names, name)
    end

    table.sort(names)

    return names
end

-- =====================================================
--  In-game documentation helpers
-- =====================================================

MoonLib.Description = Description

-- MoonLib:Help() prints the quick index.
-- MoonLib:Help("Themes") prints one section.
-- Topics (case-insensitive): Themes, Announce, Window, Tabs, Elements.
function MoonLib:Help(topic)
    if topic == nil then
        print(table.concat(Description.Order, "\n"))
        return true
    end

    local key

    for name in pairs(Description) do
        if name ~= "Order" and string.lower(name) == string.lower(tostring(topic)) then
            key = name
            break
        end
    end

    if key then
        print(Description[key])
        return true
    end

    warn(
        "[MoonLib] Unknown help topic '" .. tostring(topic)
        .. "'. Topics: Themes, Announce, Window, Tabs, Elements"
    )

    return false
end

return MoonLib
