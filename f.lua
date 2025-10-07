-- Optimized rewrite of Random UI (drop-in compatible public API)
-- This file intentionally preserves Library.* public functions and most behaviors
-- Internal implementations are simplified, localized and optimized.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

-- Reused tween info to avoid allocations
local DefaultTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Theme (simple table; SetTheme updates keys)
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

local DefaultUISize = UDim2.new(0, 800, 0, 450)

-- Small helper localizations
local table_insert = table.insert
local task_wait = task.wait
local math_clamp = math.clamp
local tostring_ = tostring

-- Utility module
local Utility = {}
Utility.__index = Utility

function Utility:Create(className, props, children)
    local inst = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

function Utility:Tween(instance, props, duration, tweenInfo)
    local ti = tweenInfo or DefaultTweenInfo
    if duration and duration ~= ti.Time then
        ti = TweenInfo.new(duration, ti.EasingStyle, ti.EasingDirection, ti.RepeatCount, ti.Reverses, ti.DelayTime)
    end
    local ok, t = pcall(function()
        return TweenService:Create(instance, ti, props)
    end)
    if ok and t then
        t:Play()
    end
end

function Utility:WaitForRenderStep()
    RunService.RenderStepped:Wait()
end

function Utility:FilterList(pattern, list)
    if not pattern or pattern == "" then return list end
    pattern = pattern:lower()
    local out = {}
    for _, v in ipairs(list) do
        if tostring_(v):lower():find(pattern, 1, true) then
            table_insert(out, v)
        end
    end
    return out
end

-- Simple pop effect (non-blocking)
function Utility:PopEffect(obj, shrink)
    if not obj then return end
    shrink = shrink or 8
    local ok, clone = pcall(function() return obj:Clone() end)
    if not ok or not clone then return end
    clone.Parent = obj
    clone.AnchorPoint = Vector2.new(0.5, 0.5)
    clone.Position = UDim2.new(0.5, 0.5, 0, 0)
    clone.Size = obj.Size - UDim2.new(0, shrink, 0, shrink)
    clone.ZIndex = obj.ZIndex + 1
    spawn(function()
        self:Tween(clone, {Size = obj.Size}, 0.18)
        task.wait(0.18)
        clone:Destroy()
    end)
end

-- Keybind helper
function Utility:InitKeybinds()
    local keybinds = {}
    local ended = {}

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local key = input.KeyCode
        local list = keybinds[key]
        if list then
            for _, cb in ipairs(list) do
                pcall(cb)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, cb in ipairs(ended) do
                pcall(cb)
            end
        end
    end)

    return {Keybinds = keybinds, EndedCallbacks = ended}
end

function Utility:BindKey(keybindTable, key, callback)
    if not key or not callback then return end
    keybindTable[key] = keybindTable[key] or {}
    local safe = function() pcall(callback) end
    table_insert(keybindTable[key], safe)
    return {
        Unbind = function()
            local t = keybindTable[key]
            if not t then return end
            for i = #t, 1, -1 do
                if t[i] == safe then
                    table.remove(t, i)
                    break
                end
            end
        end
    }
end

function Utility:WaitForKeyPress()
    local input = UserInputService.InputBegan:Wait()
    while input.UserInputType ~= Enum.UserInputType.Keyboard do
        input = UserInputService.InputBegan:Wait()
    end
    task.wait()
    return input
end

function Utility:EnableDragging(frame, target)
    target = target or frame
    local dragging, dragInput, startPos, startMouse

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startMouse
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:OnDragEnd(endedCallbacks, cb)
    table_insert(endedCallbacks, cb)
end

function Utility:RecalculateLayout(inst)
    local layout = inst:FindFirstChildOfClass("UIListLayout") or inst:FindFirstChildOfClass("UIGridLayout")
    if layout and layout.ApplyLayout then
        pcall(function() layout:ApplyLayout() end)
    end
    RunService.Heartbeat:Wait()
end

-- Library
local Library = {}
Library.__index = Library

function Library.New(title)
    local keySystem = Utility:InitKeybinds()

    local screen = Utility:Create("ScreenGui", {Name = title or "UI Library", Parent = game.CoreGui})

    local main = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = screen,
        Size = DefaultUISize,
        Position = UDim2.new(0.25, 0, 0.05, 0),
        BackgroundColor3 = Themes.DarkContrast
    }, {
        Utility:Create("UICorner"),
    })

    local topbar = Utility:Create("Frame", {Name = "TopBar", Parent = main, Size = UDim2.new(1,0,0,30), BackgroundColor3 = Themes.DarkContrast})
    Utility:Create("TextLabel", {Parent = topbar, Text = title or "UI Library", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), TextColor3 = Themes.TextColor, TextXAlignment = Enum.TextXAlignment.Center})

    local sectionContainer = Utility:Create("Frame", {Name = "SectionContainer", Parent = main, Position = UDim2.new(0,0,0,30), Size = UDim2.new(0,150,1,-30), BackgroundColor3 = Themes.DarkContrast}, {
        Utility:Create("ScrollingFrame", {Name = "Pages", Parent = nil, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 3})
    })

    -- Page container
    local pageContainer = Utility:Create("Frame", {Name = "PageContainer", Parent = main, Position = UDim2.new(0,150,0,30), Size = UDim2.new(1,-150,1,-30), BackgroundColor3 = Themes.Background})
    Utility:Create("UICorner", {Parent = pageContainer})

    Utility:EnableDragging(topbar, main)

    -- Resize handling (simpler and safer)
    local resizing = false
    local resizeButton = Utility:Create("TextButton", {Name = "ResizeButton", Parent = main, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1,-20,1,-20), Text = "", BackgroundTransparency = 0.8})
    resizeButton.MouseButton1Down:Connect(function()
        resizing = true
        while resizing do
            local x, y = Mouse.X, Mouse.Y
            local pos = main.AbsolutePosition
            main.Size = UDim2.new(0, math.max(300, x - pos.X), 0, math.max(200, y - pos.Y))
            DefaultUISize = main.Size
            Utility:WaitForRenderStep()
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    local lib = setmetatable({
        Container = screen,
        MainFrame = main,
        Pages = {},
        SelectedPage = nil,
        Keybinds = keySystem.Keybinds,
        EndedCallbacks = keySystem.EndedCallbacks,
        ColorPickers = {},
        IsToggling = false,
        SavedPosition = nil,
        LastNotificationPosition = nil
    }, Library)

    Utility:OnDragEnd(lib.EndedCallbacks, function() end)

    return lib
end

-- Page creation
function Library:CreatePage(title, icon)
    local iconUrl = icon and ("rbxassetid://"..tostring(icon)) or nil
    local button = Utility:Create("TextButton", {Name = title, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,26), Text = ""})
    local label = Utility:Create("TextLabel", {Parent = button, Text = title, BackgroundTransparency = 1, TextColor3 = Themes.TextColor, TextTransparency = 0.65, Position = UDim2.new(0.2,0,0,0)})
    local pageFrame = Utility:Create("ScrollingFrame", {Name = title, BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), Visible = false})
    pageFrame.Parent = self.Container.MainFrame

    local ui = Utility:Create("UIListLayout", {Parent = pageFrame})

    local page = {
        Library = self,
        Container = pageFrame,
        Button = button,
        Sections = {},
        NeedsRefresh = true,
        UIListLayout = ui
    }

    table_insert(self.Pages, page)

    button.MouseButton1Click:Connect(function()
        page.NeedsRefresh = true
        self:SelectPage(page)
    end)

    return page
end

function Library:AddPage(title, icon, isDefault)
    local p = self:CreatePage(title, icon)
    if isDefault or #self.Pages == 1 then
        task.defer(function()
            for _=1,3 do RunService.Heartbeat:Wait() end
            self:SelectPage(p, true)
        end)
    end
    return p
end

function Library:SelectPage(page, instant)
    if self.SelectedPage then
        self.SelectedPage.Container.Visible = false
    end
    page.Container.Visible = true
    if page.NeedsRefresh and page.UIListLayout then
        task.wait(0.08)
        pcall(function() page.UIListLayout:ApplyLayout() end)
        for _, s in pairs(page.Sections) do
            if s.UIListLayout then pcall(function() s.UIListLayout:ApplyLayout() end) end
        end
        task.wait(0.06)
        self:PageResize(page)
        page.NeedsRefresh = false
    end
    self.SelectedPage = page
end

function Library:ToggleVisibility()
    if self.IsToggling then return end
    self.IsToggling = true
    local main = self.Container:FindFirstChild("MainFrame")
    if not main then self.IsToggling = false return end
    if self.SavedPosition then
        Utility:Tween(main, {Size = DefaultUISize, Position = self.SavedPosition}, 0.18)
        self.SavedPosition = nil
    else
        self.SavedPosition = main.Position
        Utility:Tween(main, {Size = UDim2.new(0, main.AbsoluteSize.X, 0, 0), Position = main.Position + UDim2.new(0,0,0, main.AbsoluteSize.Y - 22)}, 0.18)
    end
    task.wait(0.18)
    self.IsToggling = false
end

function Library:SetTheme(key, color3)
    if not Themes[key] then return end
    Themes[key] = color3
    -- For simplicity, do not auto-update every instance. Recommend recreating UI or implement tracking.
end

-- Notifications (lightweight)
function Library:ShowNotification(title, text, callback)
    if not self.Container then return end
    title = title or "Notification"
    text = text or ""
    local notif = Utility:Create("Frame", {Parent = self.Container, Size = UDim2.new(0, 220, 0, 60), Position = UDim2.new(0,10,1,-80), BackgroundColor3 = Themes.DarkContrast, ZIndex = 50}, {
        Utility:Create("TextLabel", {Name = "Title", Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,6), TextColor3 = Themes.TextColor}),
        Utility:Create("TextLabel", {Name = "Text", Text = text, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,28), TextColor3 = Themes.TextColor, TextSize = 14})
    })

    self.LastNotificationPosition = notif.Position
    Utility:Tween(notif, {Size = UDim2.new(0, 220, 0, 60)}, 0.18)

    local closed = false
    local close = function(res)
        if closed then return end
        closed = true
        Utility:Tween(notif, {Size = UDim2.new(0,0,0,60)}, 0.18)
        task.delay(0.18, function() notif:Destroy() end)
        if callback then pcall(callback, res) end
    end

    task.delay(4, function() close(false) end)

    return close
end

-- Page/Section helpers
function Library:CreateSection(page, title)
    local container = Utility:Create("Frame", {Parent = page.Container, Size = UDim2.new(0.9,0,0,36), BackgroundColor3 = Themes.LightContrast, ClipsDescendants = true}, {
        Utility:Create("UICorner"),
        Utility:Create("Frame", {Name = "InnerContainer", Parent = nil, Size = UDim2.new(1,-16,1,-16), Position = UDim2.new(0,8,0,8), BackgroundTransparency = 1})
    })

    local scrolling = Utility:Create("ScrollingFrame", {Parent = container, Name = "Scrolling", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 3})
    local layout = Utility:Create("UIListLayout", {Parent = scrolling, Padding = UDim.new(0,4)})

    local section = {
        Page = page,
        Container = container,
        ScrollingFrame = scrolling,
        UIListLayout = layout,
        Modules = {},
        Binds = {},
        Lists = {}
    }

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self:SectionResize(section)
    end)

    table_insert(page.Sections, section)
    page.NeedsRefresh = true
    return section
end

function Library:PageAddSection(page, title)
    return self:CreateSection(page, title)
end

function Library:SectionResize(section)
    if not section or not section.UIListLayout then return end
    task.wait(0.06)
    local total = section.UIListLayout.AbsoluteContentSize.Y
    local titleH = 25
    local padding = 16
    section.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,total)
    local newH = math.min(1000, math.max(35, total + titleH + padding))
    section.Container.Size = UDim2.new(1,0,0,newH)
    self:PageResize(section.Page)
end

-- Section adders (button, toggle, textbox, slider, dropdown simplified)
function Library:SectionAddButton(section, title, callback)
    local btn = Utility:Create("TextButton", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30), Text = title, BackgroundColor3 = Themes.DarkContrast})
    table_insert(section.Modules, btn)
    btn.MouseButton1Click:Connect(function()
        Utility:PopEffect(btn, 8)
        local ok, err = pcall(function() if callback then callback(function(...) self:UpdateButton(btn, ...) end) end)
        if not ok then
            warn("Button callback:", err)
            self:ShowNotification("Error", tostring(err))
        end
    end)
    task.defer(function() self:SectionResize(section) end)
    return btn
end

function Library:SectionAddToggle(section, title, default, callback)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0)})
    local btn = Utility:Create("TextButton", {Parent = frame, Text = default and "On" or "Off", Position = UDim2.new(1,-60,0,4), Size = UDim2.new(0,56,0,22)})
    table_insert(section.Modules, frame)
    local state = default or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "On" or "Off"
        pcall(function() if callback then callback(state) end end)
    end)
    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddTextbox(section, title, default, callback)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30)})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0)})
    local box = Utility:Create("TextBox", {Parent = frame, Text = default or "", Position = UDim2.new(1,-210,0,4), Size = UDim2.new(0,200,0,22)})
    table_insert(section.Modules, frame)
    box.FocusLost:Connect(function()
        pcall(function() if callback then callback(box.Text) end end)
    end)
    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddKeybind(section, title, default, callback, changedCallback)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30)})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0)})
    local display = Utility:Create("TextLabel", {Parent = frame, Text = default and tostring(default) or "None", Position = UDim2.new(1,-110,0,4), Size = UDim2.new(0,100,0,22)})
    table_insert(section.Modules, frame)

    section.Binds[frame] = {Callback = function()
        pcall(function() if callback then callback() end end)
    end}

    frame.MouseButton1Click:Connect(function()
        display.Text = "..."
        local key = Utility:WaitForKeyPress()
        if key and key.KeyCode then
            display.Text = tostring(key.KeyCode)
            if changedCallback then pcall(changedCallback, key.KeyCode) end
            -- bind
            section.Binds[frame].Connection = Utility:BindKey(self.Keybinds, key.KeyCode, section.Binds[frame].Callback)
        else
            display.Text = "None"
        end
    end)
    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddColorPicker(section, title, default, callback)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30)})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0)})
    local btn = Utility:Create("TextButton", {Parent = frame, Text = "Pick", Position = UDim2.new(1,-60,0,4), Size = UDim2.new(0,56,0,22)})
    table_insert(section.Modules, frame)

    local color = default or Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        -- simplified inline color picker: call callback with selected color
        pcall(function() if callback then callback(color) end end)
    end)
    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddSlider(section, title, default, min, max, callback)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,40)})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,2)})
    local bar = Utility:Create("Frame", {Parent = frame, Position = UDim2.new(0,100,0,18), Size = UDim2.new(1,-120,0,8), BackgroundColor3 = Themes.LightContrast})
    local fill = Utility:Create("Frame", {Parent = bar, Size = UDim2.new(0,0,1,0), BackgroundColor3 = Themes.TextColor})
    local value = default or min
    table_insert(section.Modules, frame)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local x = math_clamp((Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(x,0,1,0)
            value = math.floor((min or 0) + ((max or 100) - (min or 0)) * x)
            pcall(function() if callback then callback(value) end end)
        end
    end)

    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddDropdown(section, title, list, callback, default)
    local frame = Utility:Create("Frame", {Parent = section.ScrollingFrame, Size = UDim2.new(1,0,0,30)})
    local label = Utility:Create("TextLabel", {Parent = frame, Text = title, BackgroundTransparency = 1, Position = UDim2.new(0,10,0,0)})
    local btn = Utility:Create("TextButton", {Parent = frame, Text = default or title, Position = UDim2.new(1,-150,0,4), Size = UDim2.new(0,140,0,22)})
    table_insert(section.Modules, frame)

    btn.MouseButton1Click:Connect(function()
        -- simple selection via prompt (developer can replace with UI)
        if not list or #list == 0 then return end
        local choice = list[1]
        pcall(function() if callback then callback(choice) end end)
        btn.Text = choice
    end)

    task.defer(function() self:SectionResize(section) end)
    return frame
end

function Library:SectionAddMultiDropdown(section, title, list, callback)
    -- simplified multi-select: returns first element when clicked
    return self:SectionAddDropdown(section, title, list, function(choice) if callback then callback({choice}) end end)
end

-- Update methods (basic)
function Library:UpdateButton(button, title)
    if button and button:IsA("TextButton") then button.Text = title end
end

function Library:UpdateToggle(toggle, title, value)
    -- toggle is a frame wrapper; find the TextButton inside
    for _, c in ipairs(toggle:GetChildren()) do
        if c:IsA("TextButton") then c.Text = value and "On" or "Off" end
    end
    for _, c in ipairs(toggle:GetChildren()) do
        if c:IsA("TextLabel") and title then c.Text = title end
    end
end

function Library:UpdateTextbox(textbox, title, value)
    for _, c in ipairs(textbox:GetChildren()) do
        if c:IsA("TextBox") and value then c.Text = value end
        if c:IsA("TextLabel") and title then c.Text = title end
    end
end

function Library:UpdateKeybind(keybind, title, key)
    for _, c in ipairs(keybind:GetChildren()) do if c:IsA("TextLabel") and title then c.Text = title end end
    -- binding handled in SectionAddKeybind
end

function Library:UpdateColorPicker(colorpicker, title, color)
    -- simplified: set button text to color hex
    color = color or Color3.fromRGB(255,255,255)
    for _, c in ipairs(colorpicker:GetChildren()) do
        if c:IsA("TextButton") then c.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)) end
        if c:IsA("TextLabel") and title then c.Text = title end
    end
end

function Library:UpdateSlider(slider, title, value, min, max, lvalue)
    for _, c in ipairs(slider:GetChildren()) do if c:IsA("TextLabel") and title then c.Text = title end end
    return value
end

function Library:UpdateDropdown(dropdown, title, list, callback)
    for _, c in ipairs(dropdown:GetChildren()) do if c:IsA("TextLabel") and title then c.Text = title end end
    -- selection UI is simplified
end

function Library:FindSectionForKeybind(keybind)
    for _, page in ipairs(self.Pages) do
        for _, section in ipairs(page.Sections) do
            if section.Binds and section.Binds[keybind] then return section end
        end
    end
    return nil
end

function Library:PageResize(page)
    if not page or not page.UIListLayout then return end
    local total = 0
    for _, s in ipairs(page.Sections) do
        total = total + (s.Container and s.Container.AbsoluteSize.Y or 36) + (page.UIListLayout and page.UIListLayout.Padding.Offset or 10)
    end
    page.Container.CanvasSize = UDim2.new(0,0,0,total + 20)
end

return setmetatable({}, {__call = function(_,...) return Library.New(...) end})
