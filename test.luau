local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

-- Predefine TweenInfo for reuse
local DefaultTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

-- Theme colors (easy to modify by changing these values)
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- Default UI size (modifiable)
local DefaultUISize = UDim2.new(0, 800, 0, 450)

-- Utility module: Contains helper functions
local Utility = {}

-- Creates a new instance with properties and optional children
function Utility:Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
        -- Track theme colors for dynamic updates (stub for future implementation)
        if typeof(value) == "Color3" then
            local themeKey = self:FindKey(Themes, value)
            if themeKey then
                -- Can add theme object tracking here if needed for dynamic theme changes
            end
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

-- Performs a tween on an instance
function Utility:Tween(instance, properties, duration, ...)
    local tweenInfo = TweenInfo.new(duration, ...)
    TweenService:Create(instance, tweenInfo, properties):Play()
end

-- Waits for the next RenderStepped event
function Utility:WaitForRenderStep()
    RunService.RenderStepped:Wait()
    return true
end

-- Finds the key for a value in a table
function Utility:FindKey(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

-- Filters a list based on a pattern (case-insensitive)
function Utility:FilterList(pattern, list)
    pattern = pattern:lower()
    if pattern == "" then return list end
    local filtered = {}
    for _, item in pairs(list) do
        if tostring(item):lower():find(pattern) then
            table.insert(filtered, item)
        end
    end
    return filtered
end

-- Creates a pop effect on an object
function Utility:PopEffect(object, shrinkAmount)
    local clone = object:Clone()
    clone.AnchorPoint = Vector2.new(0.5, 0.5)
    clone.Size = clone.Size - UDim2.new(0, shrinkAmount, 0, shrinkAmount)
    clone.Position = UDim2.new(0.5, 0, 0.5, 0)
    clone.Parent = object
    clone:ClearAllChildren()
    object.ImageTransparency = 1
    self:Tween(clone, {Size = object.Size}, 0.2)
    task.delay(0.2, function()
        object.ImageTransparency = 0
        clone:Destroy()
    end)
    return clone
end

-- Initializes keybind handling
function Utility:InitKeybinds()
    local keybinds = {}
    local endedCallbacks = {}
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and keybinds[input.KeyCode] then
            for _, callback in pairs(keybinds[input.KeyCode]) do
                callback()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, callback in pairs(endedCallbacks) do
                callback()
            end
        end
    end)
    
    return {Keybinds = keybinds, EndedCallbacks = endedCallbacks}
end

-- Binds a callback to a key
function Utility:BindKey(keybindsTable, key, callback)
    keybindsTable[key] = keybindsTable[key] or {}
    
    local safeCallback = function()
        local success, err = pcall(callback)
        if not success then
            warn("Keybind callback error: " .. tostring(err))
        end
    end
    
    table.insert(keybindsTable[key], safeCallback)
    
    return {
        Unbind = function()
            for i, bind in pairs(keybindsTable[key]) do
                if bind == safeCallback then
                    table.remove(keybindsTable[key], i)
                    break
                end
            end
        end
    }
end

-- Waits for and returns the next key press
function Utility:WaitForKeyPress()
    local input = UserInputService.InputBegan:Wait()
    while input.UserInputType ~= Enum.UserInputType.Keyboard do
        input = UserInputService.InputBegan:Wait()
    end
    task.wait()
    return input
end

-- Enables dragging on a frame
function Utility:EnableDragging(frame, target)
    target = target or frame
    local dragging = false
    local dragInput, mousePos, framePos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = target.Position
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
            local delta = input.Position - mousePos
            target.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Registers a callback for drag end
function Utility:OnDragEnd(endedCallbacks, callback)
    table.insert(endedCallbacks, callback)
end

-- Forces layout recalculation
function Utility:RecalculateLayout(instance)
    local layout = instance:FindFirstChildOfClass("UIListLayout") or instance:FindFirstChildOfClass("UIGridLayout")
    if layout then
        layout:ApplyLayout()
    end
    RunService.Heartbeat:Wait()
    RunService.Heartbeat:Wait()
end

-- Library module
local Library = {}
Library.__index = Library

-- Creates a new library instance
function Library.New(title)
    local keybindSystem = Utility:InitKeybinds()
    local container = Utility:Create("ScreenGui", {
        Name = title or "UI Library",
        Parent = game.CoreGui
    }, {
        Utility:Create("Frame", {
            Name = "MainFrame",
            Position = UDim2.new(0.25, 0, 0.05, 0),
            Size = DefaultUISize,
            BackgroundColor3 = Themes.DarkContrast
        }, {
            Utility:Create("UICorner"),
            Utility:Create("UIStroke", {
                Name = "UIStroke",
                Color = Themes.TextColor,
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }),
            Utility:Create("TextButton", {
                Name = "ResizeButton",
                Position = UDim2.new(1, -2, 1, -2),
                Size = UDim2.new(0, -15, 0, -15),
                ZIndex = 5,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.75,
                BorderSizePixel = 0,
                Text = ""
            }),
            Utility:Create("Frame", {
                Name = "TopBar",
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 5,
                BackgroundColor3 = Themes.DarkContrast
            }, {
                Utility:Create("UICorner"),
                Utility:Create("TextLabel", {
                    Name = "TitleLabel",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5,
                    Font = Enum.Font.SourceSansSemibold,
                    Text = title or "UI Library",
                    TextColor3 = Themes.TextColor,
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Center
                })
            }),
            Utility:Create("Frame", {
                Name = "PageContainer",
                ClipsDescendants = true,
                Position = UDim2.new(0, 150, 0, 30),
                Size = UDim2.new(1, -150, 1, -30),
                BackgroundColor3 = Themes.Background
            }, {
                Utility:Create("UICorner")
            }),
            Utility:Create("Frame", {
                Name = "SectionContainer",
                ClipsDescendants = true,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(0, 150, 1, -50),
                ZIndex = 2,
                BackgroundColor3 = Themes.DarkContrast
            }, {
                Utility:Create("ScrollingFrame", {
                    Active = true,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 314),
                    ScrollBarThickness = 0
                }, {
                    Utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 10)
                    })
                })
            })
        })
    })

    Utility:EnableDragging(container.MainFrame.TopBar, container.MainFrame)

    -- Resize logic
    local draggingResize = false
    container.MainFrame.ResizeButton.MouseButton1Down:Connect(function()
        draggingResize = true
        while draggingResize do
            local x, y = Mouse.X - 1, Mouse.Y - 1
            local pos = container.MainFrame.AbsolutePosition
            local size = container.MainFrame.AbsoluteSize
            if x - pos.X >= 500 then
                container.MainFrame.Size = UDim2.new(0, x - pos.X, 0, size.Y)
            end
            size = container.MainFrame.AbsoluteSize
            if y - pos.Y >= 281 then
                container.MainFrame.Size = UDim2.new(0, size.X, 0, y - pos.Y)
            end
            DefaultUISize = UDim2.new(0, container.MainFrame.AbsoluteSize.X, 0, container.MainFrame.AbsoluteSize.Y)
            Utility:WaitForRenderStep()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingResize = false
        end
    end)

    local lib = setmetatable({
        Container = container,
        PagesContainer = container.MainFrame.SectionContainer.ScrollingFrame,
        Pages = {},
        SelectedPage = nil,
        Keybinds = keybindSystem.Keybinds,
        EndedCallbacks = keybindSystem.EndedCallbacks,
        ColorPickers = {},
        Modules = {},
        Binds = {},
        Lists = {},
        ActiveNotification = nil,
        ActivePicker = nil,
        IsToggling = false,
        SavedPosition = nil,
        LastNotificationPosition = nil
    }, Library)
    Utility:OnDragEnd(lib.EndedCallbacks, function()
        -- Additional drag end logic if needed
    end)
    return lib
end

-- Add page to library
function Library:AddPage(title, icon, isDefault)
    local page = self:CreatePage(title, icon)
    table.insert(self.Pages, page)
    if isDefault or #self.Pages == 1 then
        task.defer(function()
            for _ = 1, 3 do RunService.Heartbeat:Wait() end
            self:SelectPage(page, true)
        end)
    end
    page.Button.MouseButton1Click:Connect(function()
        page.NeedsRefresh = true
        self:SelectPage(page, true)
    end)
    return page
end

-- Create a page
function Library:CreatePage(title, icon)
    icon = "rbxassetid://" .. tostring(icon or 5012544693)
    local button = Utility:Create("TextButton", {
        Name = title,
        Parent = self.PagesContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        ZIndex = 3,
        AutoButtonColor = false,
        Font = Enum.Font.SourceSansSemibold,
        Text = ""
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.22, 0, 0.5, 0),
            Size = UDim2.new(0.75, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.SourceSansSemibold,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 14,
            TextTransparency = 0.65,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 3,
            Image = icon,
            ImageColor3 = Themes.TextColor,
            ImageTransparency = 0.64
        })
    })

    local container = Utility:Create("ScrollingFrame", {
        Name = title,
        Parent = self.Container.MainFrame.PageContainer,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(1, 0, 1, -5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Themes.DarkContrast,
        Visible = false
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
    })

    return {
        Library = self,
        Container = container,
        Button = button,
        Sections = {},
        NeedsRefresh = true,
        UIListLayout = container:FindFirstChildOfClass("UIListLayout"),
        LastPosition = nil
    }
end

-- Select a page
function Library:SelectPage(page, instant)
    if self.SelectedPage then
        self.SelectedPage.Container.Visible = false
        Utility:Tween(self.SelectedPage.Button.Title, {TextTransparency = 0.65}, instant and 0 or 0.2)
        Utility:Tween(self.SelectedPage.Button.Icon, {ImageTransparency = 0.64}, instant and 0 or 0.2)
    end

    page.Container.Visible = true

    if page.NeedsRefresh then
        -- Force a layout update
        task.wait(0.1)
        if page.UIListLayout then
            page.UIListLayout:ApplyLayout()
        end
        
        for _, section in pairs(page.Sections) do
            if section.UIListLayout then
                section.UIListLayout:ApplyLayout()
            end
        end
        
        task.wait(0.1)
        self:PageResize(page)
        page.NeedsRefresh = false
    end

    Utility:Tween(page.Button.Title, {TextTransparency = 0}, instant and 0 or 0.2)
    Utility:Tween(page.Button.Icon, {ImageTransparency = 0}, instant and 0 or 0.2)

    self.SelectedPage = page
end

-- Toggle library visibility
function Library:ToggleVisibility()
    if self.IsToggling then return end
    self.IsToggling = true
    local main = self.Container.MainFrame
    local topbar = main.TopBar
    local uistroke = main.UIStroke

    if self.SavedPosition then
        Utility:Tween(main, {Size = DefaultUISize, Position = self.SavedPosition}, 0.2)
        uistroke.Enabled = true
        task.wait(0.2)
        Utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
        task.wait(0.2)
        main.ClipsDescendants = false
        self.SavedPosition = nil
    else
        self.SavedPosition = main.Position
        main.ClipsDescendants = true
        Utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
        uistroke.Enabled = false
        task.wait(0.2)
        Utility:Tween(main, {Size = UDim2.new(0, main.AbsoluteSize.X, 0, 0), Position = self.SavedPosition + UDim2.new(0, 0, 0, 428)}, 0.2)
        task.wait(0.2)
    end
    self.IsToggling = false
end

-- Set theme color
function Library:SetTheme(themeKey, newColor)
    Themes[themeKey] = newColor
    -- To make it dynamic, loop through all UI elements and update colors here
    -- For simplicity, assume users recreate UI after theme change or implement tracking
end

-- Show notification
function Library:ShowNotification(title, text, callback)
    if self.ActiveNotification then
        self.ActiveNotification()
    end

    title = title or "Notification"
    text = text or ""

    local notification = Utility:Create("ImageLabel", {
        Name = "Notification",
        Parent = self.Container,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 200, 0, 60),
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.Background,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(4, 4, 296, 296),
        ZIndex = 3,
        ClipsDescendants = true
    }, {
        Utility:Create("ImageLabel", {
            Name = "Flash",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0,
            Image = "rbxassetid://4641149554",
            ImageColor3 = Themes.TextColor,
            ZIndex = 5
        }),
        Utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -40, 0, 16),
            ZIndex = 4,
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = title
        }),
        Utility:Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 10, 1, -24),
            Size = UDim2.new(1, -40, 0, 16),
            ZIndex = 4,
            Font = Enum.Font.Gotham,
            TextColor3 = Themes.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = text
        }),
        Utility:Create("ImageButton", {
            Name = "Accept",
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -26, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = "rbxassetid://5012538259",
            ImageColor3 = Themes.TextColor,
            ZIndex = 4
        }),
        Utility:Create("ImageButton", {
            Name = "Decline",
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -26, 1, -24),
            Size = UDim2.new(0, 16, 0, 16),
            Image = "rbxassetid://5012538583",
            ImageColor3 = Themes.TextColor,
            ZIndex = 4
        })
    })

    Utility:EnableDragging(notification, notification)

    local padding = 10
    local textSize = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

    notification.Position = self.LastNotificationPosition or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
    notification.Size = UDim2.new(0, 0, 0, 60)

    Utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
    task.wait(0.2)

    notification.ClipsDescendants = false
    Utility:Tween(notification.Flash, {Size = UDim2.new(0, 0, 0, 60), Position = UDim2.new(1, 0, 0, 0)}, 0.2)

    local active = true
    local close = function()
        if not active then return end
        active = false
        notification.ClipsDescendants = true

        self.LastNotificationPosition = notification.Position
        notification.Flash.Position = UDim2.new(0, 0, 0, 0)
        Utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)

        task.wait(0.2)
        Utility:Tween(notification, {Size = UDim2.new(0, 0, 0, 60), Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)}, 0.2)

        task.wait(0.2)
        notification:Destroy()
    end

    self.ActiveNotification = close

    notification.Accept.MouseButton1Click:Connect(function()
        if not active then return end
        if callback then callback(true) end
        close()
    end)

    notification.Decline.MouseButton1Click:Connect(function()
        if not active then return end
        if callback then callback(false) end
        close()
    end)
end

-- Page methods
function Library:PageAddSection(page, title)
    local section = self:CreateSection(page, title)
    table.insert(page.Sections, section)
    page.NeedsRefresh = true
    
    -- Update page layout
    self:PageResize(page)
    
    if self.SelectedPage == page then
        task.defer(function()
            self:SelectPage(page, true)
        end)
    end
    
    return section
end

-- Create a section
function Library:CreateSection(page, title)
    local container = Utility:Create("Frame", {
        Name = title,
        Parent = page.Container,
        Size = UDim2.new(0.98, 0, 0, 35), -- Start with minimum height
        ZIndex = 2,
        BackgroundColor3 = Themes.LightContrast,
        ClipsDescendants = true
    }, {
        Utility:Create("UICorner"),
        Utility:Create("Frame", {
            Name = "InnerContainer",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 8, 0, 8),
            Size = UDim2.new(1, -16, 1, -16)
        }, {
            Utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 2,
                Font = Enum.Font.SourceSansSemibold,
                Text = title,
                TextColor3 = Themes.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0
            }),
            Utility:Create("ScrollingFrame", {
                Name = "ScrollingFrame",
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 1, -25),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Themes.TextColor,
                ZIndex = 5
            }, {
                Utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })
        })
    })

    local scrollingFrame = container.InnerContainer.ScrollingFrame
    local uiListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

    local section = {
        Page = page,
        Container = container.InnerContainer,
        ScrollingFrame = scrollingFrame,
        UIListLayout = uiListLayout,
        ColorPickers = {},
        Modules = {},
        Binds = {},
        Lists = {}
    }

    -- Connect to UIListLayout changes to update section size dynamically
    if uiListLayout then
        uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            self:SectionResize(section)
        end)
    end

    return section
end

-- Update the SectionResize function
function Library:SectionResize(section)
    if not section or not section.UIListLayout then return end
    
    -- Wait for UI to update
    task.wait(0.1)
    
    local totalSize = section.UIListLayout.AbsoluteContentSize.Y
    local titleHeight = 25 -- Height of the title area
    local containerPadding = 16 -- InnerContainer padding (8px top + 8px bottom)
    
    -- Calculate total content height
    local contentHeight = totalSize + titleHeight
    
    -- Update ScrollingFrame CanvasSize
    section.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalSize)
    
    -- Update section container size with max limit of 260px
    local container = section.Container.Parent
    if container then
        local newHeight = math.min(260, math.max(35, contentHeight + containerPadding))
        container.Size = UDim2.new(1, 0, 0, newHeight)
        
        -- Enable scrollbar if content exceeds max height
        if contentHeight + containerPadding > 260 then
            section.ScrollingFrame.ScrollBarImageTransparency = 0
        else
            section.ScrollingFrame.ScrollBarImageTransparency = 1
        end
    end
    
    -- Update page layout
    self:PageResize(section.Page)
end

-- Section methods
function Library:SectionAddButton(section, title, callback)
    local button = Utility:Create("ImageButton", {
        Name = "Button",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1
        })
    })


    table.insert(section.Modules, button)

    local debounce = false
    button.MouseButton1Click:Connect(function()
        if debounce then return end
        Utility:PopEffect(button, 10)
        debounce = true
        Utility:Tween(button.Title, {TextSize = 12}, 0.1)
        task.wait(0.1)
        Utility:Tween(button.Title, {TextSize = 14}, 0.1)
        
        -- Add error handling with pcall
        if callback then
            local success, err = pcall(function()
                callback(function(...)
                    self:UpdateButton(button, ...)
                end)
            end)
            
            if not success then
                warn("Button callback error: " .. tostring(err))
                self:ShowNotification("Error", "Button action failed: " .. tostring(err))
            end
        end
        
        debounce = false
    end)
    
    -- Trigger section resize after adding the button
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return button
end

function Library:SectionAddToggle(section, title, default, callback)
    local toggle = Utility:Create("ImageButton", {
        Name = "Toggle",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 1),
            Size = UDim2.new(0.5, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageLabel", {
            Name = "Button",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -50, 0.5, -8),
            Size = UDim2.new(0, 40, 0, 16),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.LightContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("ImageLabel", {
                Name = "Frame",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 2, 0.5, -6),
                Size = UDim2.new(1, -22, 1, -4),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Themes.TextColor,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            })
        })
    })

    table.insert(section.Modules, toggle)

    local active = default or false
    self:UpdateToggle(toggle, nil, active)

    toggle.MouseButton1Click:Connect(function()
        active = not active
        self:UpdateToggle(toggle, nil, active)
        
        -- Add error handling with pcall
        if callback then
            local success, err = pcall(function()
                callback(active)
            end)
            
            if not success then
                warn("Toggle callback error: " .. tostring(err))
                self:ShowNotification("Error", "Toggle action failed: " .. tostring(err))
                -- Revert the toggle state if there was an error
                active = not active
                self:UpdateToggle(toggle, nil, active)
            end
        end
    end)
    
    -- Trigger section resize after adding the toggle
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return toggle
end

function Library:SectionAddTextbox(section, title, default, callback)
    local textbox = Utility:Create("ImageButton", {
        Name = "Textbox",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 1),
            Size = UDim2.new(0.5, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageLabel", {
            Name = "Button",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -110, 0.5, -8),
            Size = UDim2.new(0, 100, 0, 16),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.LightContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("TextBox", {
                Name = "Textbox",
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.SourceSansSemibold,
                Text = default or "",
                TextColor3 = Themes.TextColor,
                TextSize = 14
            })
        })
    })

    table.insert(section.Modules, textbox)

    local button = textbox.Button
    local input = button.Textbox

    textbox.MouseButton1Click:Connect(function()
        if button.Size ~= UDim2.new(0, 100, 0, 16) then return end
        Utility:Tween(button, {Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(1, -210, 0.5, -8)}, 0.2)
        task.wait()
        input.TextXAlignment = Enum.TextXAlignment.Left
        input:CaptureFocus()
    end)

    input:GetPropertyChangedSignal("Text"):Connect(function()
        if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then
            Utility:PopEffect(button, 10)
        end
        if callback then
            local success, err = pcall(function()
                callback(input.Text, nil, function(...)
                    self:UpdateTextbox(textbox, ...)
                end)
            end)
            
            if not success then
                warn("Textbox callback error: " .. tostring(err))
            end
        end
    end)

    input.FocusLost:Connect(function()
        input.TextXAlignment = Enum.TextXAlignment.Center
        Utility:Tween(button, {Size = UDim2.new(0, 100, 0, 16), Position = UDim2.new(1, -110, 0.5, -8)}, 0.2)
        if callback then
            -- Add error handling
            local success, err = pcall(function()
                callback(input.Text, true, function(...)
                    self:UpdateTextbox(textbox, ...)
                end)
            end)
            
            if not success then
                warn("Textbox callback error: " .. tostring(err))
            end
        end
    end)
    
    -- Trigger section resize after adding the textbox
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return textbox
end

function Library:SectionAddKeybind(section, title, default, callback, changedCallback)
    local keybind = Utility:Create("ImageButton", {
        Name = "Keybind",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 1),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageLabel", {
            Name = "Button",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -110, 0.5, -8),
            Size = UDim2.new(0, 100, 0, 16),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.LightContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.SourceSansSemibold,
                Text = default and default.Name or "None",
                TextColor3 = Themes.TextColor,
                TextSize = 14
            })
        })
    })

    table.insert(section.Modules, keybind)

    local text = keybind.Button.Text
    local button = keybind.Button

    local animate = function()
        if button.ImageTransparency == 0 then
            Utility:PopEffect(button, 10)
        end
    end

    -- Store the bind in the section's binds table
    section.Binds[keybind] = {
        Callback = function()
            animate()
            if callback then
                callback(function(...)
                    self:UpdateKeybind(keybind, ...)
                end)
            end
        end
    }

    if default and callback then
        self:UpdateKeybind(keybind, nil, default)
    end

    keybind.MouseButton1Click:Connect(function()
        animate()
        if section.Binds[keybind].Connection then
            return self:UpdateKeybind(keybind)
        end
        if text.Text == "None" then
            text.Text = "..."
            local key = Utility:WaitForKeyPress()
            self:UpdateKeybind(keybind, nil, key.KeyCode)
            animate()
            if changedCallback then
                changedCallback(key, function(...)
                    self:UpdateKeybind(keybind, ...)
                end)
            end
        end
    end)
    
    -- Trigger section resize after adding the keybind
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return keybind
end

function Library:SectionAddColorPicker(section, title, default, callback)
    local colorpicker = Utility:Create("ImageButton", {
        Name = "ColorPicker",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, 1),
            Size = UDim2.new(0.5, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -50, 0.5, -7),
            Size = UDim2.new(0, 40, 0, 14),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        })
    })

    local tab = Utility:Create("ImageLabel", {
        Name = "ColorPickerTab",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.75, 0, 0.4, 0),
        Selectable = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 162, 0, 169),
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.Background,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298),
        Visible = false
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -40, 0, 16),
            ZIndex = 2,
            Font = Enum.Font.SourceSansSemibold,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("ImageButton", {
            Name = "Close",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -26, 0, 8),
            Size = UDim2.new(0, 16, 0, 16),
            ZIndex = 2,
            Image = "rbxassetid://5012538583",
            ImageColor3 = Themes.TextColor
        }),
        Utility:Create("Frame", {
            Name = "Container",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 32),
            Size = UDim2.new(1, -18, 1, -40)
        }, {
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            }),
            Utility:Create("ImageButton", {
                Name = "Canvas",
                BackgroundTransparency = 1,
                BorderColor3 = Themes.LightContrast,
                Size = UDim2.new(1, 0, 0, 60),
                AutoButtonColor = false,
                Image = "rbxassetid://5108535320",
                ImageColor3 = Color3.fromRGB(255, 0, 0),
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility:Create("ImageLabel", {
                    Name = "WhiteOverlay",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    Image = "rbxassetid://5107152351",
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }),
                Utility:Create("ImageLabel", {
                    Name = "BlackOverlay",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 60),
                    Image = "rbxassetid://5107152095",
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }),
                Utility:Create("ImageLabel", {
                    Name = "Cursor",
                    BackgroundColor3 = Themes.TextColor,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1.000,
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0, 0, 0, 0),
                    Image = "rbxassetid://5100115962",
                    SliceCenter = Rect.new(2, 2, 298, 298)
                })
            }),
            Utility:Create("ImageButton", {
                Name = "Color",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 4),
                Selectable = false,
                Size = UDim2.new(1, 0, 0, 16),
                ZIndex = 2,
                AutoButtonColor = false,
                Image = "rbxassetid://5028857472",
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility:Create("Frame", {
                    Name = "Select",
                    BackgroundColor3 = Themes.TextColor,
                    BorderSizePixel = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 2, 1, 0),
                    ZIndex = 2
                }),
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                    })
                })
            }),
            Utility:Create("Frame", {
                Name = "Inputs",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 158),
                Size = UDim2.new(1, 0, 0, 16)
            }, {
                Utility:Create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6)
                }),
                Utility:Create("ImageLabel", {
                    Name = "R",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.305, 0, 1, 0),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = Themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    Utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        Text = "R:",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    }),
                    Utility:Create("TextBox", {
                        Name = "Textbox",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.3, 0, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        PlaceholderColor3 = Themes.DarkContrast,
                        Text = "255",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    })
                }),
                Utility:Create("ImageLabel", {
                    Name = "G",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.305, 0, 1, 0),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = Themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    Utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        Text = "G:",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    }),
                    Utility:Create("TextBox", {
                        Name = "Textbox",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.3, 0, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        PlaceholderColor3 = Themes.DarkContrast,
                        Text = "255",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    })
                }),
                Utility:Create("ImageLabel", {
                    Name = "B",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.305, 0, 1, 0),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = Themes.DarkContrast,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    Utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        Text = "B:",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    }),
                    Utility:Create("TextBox", {
                        Name = "Textbox",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.3, 0, 0, 0),
                        Size = UDim2.new(0.6, 0, 1, 0),
                        ZIndex = 2,
                        Font = Enum.Font.Gotham,
                        PlaceholderColor3 = Themes.DarkContrast,
                        Text = "255",
                        TextColor3 = Themes.TextColor,
                        TextSize = 12
                    })
                })
            }),
            Utility:Create("ImageButton", {
                Name = "SubmitButton",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Themes.DarkContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = "Submit",
                    TextColor3 = Themes.TextColor,
                    TextSize = 12
                })
            })
        })
    })

    Utility:EnableDragging(tab, tab)
    table.insert(section.Modules, colorpicker)

    local allowed = {
        [""] = true
    }

    local canvas = tab.Container.Canvas
    local color = tab.Container.Color

    local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
    local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition

    local draggingColor, draggingCanvas

    local color3 = default or Color3.fromRGB(255, 255, 255)
    local hue, sat, brightness = 0, 0, 1
    local rgb = {
        r = 255,
        g = 255,
        b = 255
    }

    section.ColorPickers[colorpicker] = {
        tab = tab,
        callback = function(prop, value)
            rgb[prop] = value
            hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
        end
    }

    local callbackFunc = function(value)
        if callback then
            callback(value, function(...)
                self:UpdateColorPicker(colorpicker, ...)
            end)
        end
    end

    Utility:OnDragEnd(self.EndedCallbacks, function()
        draggingColor, draggingCanvas = false, false
    end)

    if default then
        self:UpdateColorPicker(colorpicker, nil, default)

        hue, sat, brightness = Color3.toHSV(default)
        default = Color3.fromHSV(hue, sat, brightness)

        for i, prop in pairs({"r", "g", "b"}) do
            rgb[prop] = default[prop:upper()] * 255
        end
    end

    for i, container in pairs(tab.Container.Inputs:GetChildren()) do 
        if container:IsA("ImageLabel") then
            local textbox = container.Textbox
            local focused

            textbox.Focused:Connect(function()
                focused = true
            end)

            textbox.FocusLost:Connect(function()
                focused = false

                if not tonumber(textbox.Text) then
                    textbox.Text = math.floor(rgb[container.Name:lower()])
                end
            end)

            textbox:GetPropertyChangedSignal("Text"):Connect(function()
                local text = textbox.Text

                if not allowed[text] and not tonumber(text) then
                    textbox.Text = text:sub(1, #text - 1)
                elseif focused and not allowed[text] then
                    rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)

                    local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
                    hue, sat, brightness = Color3.toHSV(color3)

                    self:UpdateColorPicker(colorpicker, nil, color3)
                    callbackFunc(color3)
                end
            end)
        end
    end

    canvas.MouseButton1Down:Connect(function()
        draggingCanvas = true

        while draggingCanvas do
            local x, y = Mouse.X, Mouse.Y

            sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
            brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)

            color3 = Color3.fromHSV(hue, sat, brightness)

            for i, prop in pairs({"r", "g", "b"}) do
                rgb[prop] = color3[prop:upper()] * 255
            end

            self:UpdateColorPicker(colorpicker, nil, {hue, sat, brightness})
            Utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1)

            callbackFunc(color3)
            Utility:WaitForRenderStep()
        end
    end)

    color.MouseButton1Down:Connect(function()
        draggingColor = true

        while draggingColor do
            hue = 1 - math.clamp(1 - ((Mouse.X - colorPosition.X) / colorSize.X), 0, 1)
            color3 = Color3.fromHSV(hue, sat, brightness)

            for i, prop in pairs({"r", "g", "b"}) do
                rgb[prop] = color3[prop:upper()] * 255
            end

            local x = hue 
            self:UpdateColorPicker(colorpicker, nil, {hue, sat, brightness}) 
            Utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1)

            callbackFunc(color3)
            Utility:WaitForRenderStep()
        end
    end)

    local button = colorpicker.Button
    local toggle, debounce, animate

    local lastColor = Color3.fromHSV(hue, sat, brightness)
    animate = function(visible, overwrite)
        if overwrite then
            if not toggle then return end
            if debounce then
                while debounce do
                    Utility:WaitForRenderStep()
                end
            end
        elseif not overwrite then
            if debounce then return end
            if button.ImageTransparency == 0 then
                Utility:PopEffect(button, 10)
            end
        end

        toggle = visible
        debounce = true

        if visible then
            if self.ActivePicker and self.ActivePicker ~= animate then
                self.ActivePicker(nil, true)
            end

            self.ActivePicker = animate
            lastColor = Color3.fromHSV(hue, sat, brightness)

            local x1, x2 = button.AbsoluteSize.X / 2, 162
            local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y

            tab.ClipsDescendants = true
            tab.Visible = true
            tab.Size = UDim2.new(0, 0, 0, 0)

            tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
            Utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)

            task.wait(0.2)
            tab.ClipsDescendants = false

            canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
            colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
        else
            Utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            tab.ClipsDescendants = true

            task.wait(0.2)
            tab.Visible = false
        end

        debounce = false
    end

    local toggleTab = function()
        animate(not toggle)
    end

    button.MouseButton1Click:Connect(toggleTab)
    colorpicker.MouseButton1Click:Connect(toggleTab)

    tab.Container.SubmitButton.MouseButton1Click:Connect(function()
        animate(false)
    end)

    tab.Close.MouseButton1Click:Connect(function()
        self:UpdateColorPicker(colorpicker, nil, lastColor)
        animate(false)
    end)
    
    -- Trigger section resize after adding the color picker
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return colorpicker
end

function Library:SectionAddSlider(section, title, default, min, max, callback)
    local slider = Utility:Create("ImageButton", {
        Name = "Slider",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 298, 298)
    }, {
        Utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 6),
            Size = UDim2.new(0.5, 0, 0, 16),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = Themes.TextColor,
            TextSize = 16,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left
        }),
        Utility:Create("TextBox", {
            Name = "TextBox",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 0, 6),
            Size = UDim2.new(0, 20, 0, 16),
            ZIndex = 3,
            Font = Enum.Font.SourceSansSemibold,
            Text = default or min,
            TextColor3 = Themes.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right
        }),
        Utility:Create("TextLabel", {
            Name = "Slider",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 28),
            Size = UDim2.new(1, -20, 0, 16),
            ZIndex = 3,
            Text = "",
        }, {
            Utility:Create("ImageLabel", {
                Name = "Bar",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, 4),
                ZIndex = 3,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Themes.LightContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility:Create("ImageLabel", {
                    Name = "Fill",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.8, 0, 1, 0),
                    ZIndex = 3,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = Themes.TextColor,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    Utility:Create("ImageLabel", {
                        Name = "Circle",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        ImageTransparency = 1.000,
                        ImageColor3 = Themes.TextColor,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.new(0, 10, 0, 10),
                        ZIndex = 3,
                        Image = "rbxassetid://4608020054"
                    })
                })
            })
        })
    })

    table.insert(section.Modules, slider)

    local allowed = {
        [""] = true,
        ["-"] = true
    }

    local textbox = slider.TextBox
    local circle = slider.Slider.Bar.Fill.Circle

    local value = default or min
    local dragging, last

    local callbackFunc = function(val)
        if callback then
            callback(val, function(...)
                self:UpdateSlider(slider, ...)
            end)
        end
    end

    self:UpdateSlider(slider, nil, value, min, max)

    Utility:OnDragEnd(self.EndedCallbacks, function()
        dragging = false
    end)

    slider.MouseButton1Down:Connect(function(input)
        dragging = true

        while dragging do
            Utility:Tween(circle, {ImageTransparency = 0}, 0.1)

            value = self:UpdateSlider(slider, nil, nil, min, max, value)
            callbackFunc(value)

            Utility:WaitForRenderStep()
        end

        task.wait(0.5)
        Utility:Tween(circle, {ImageTransparency = 1}, 0.2)
    end)

    textbox.FocusLost:Connect(function()
        if not tonumber(textbox.Text) then
            value = self:UpdateSlider(slider, nil, default or min, min, max)
            callbackFunc(value)
        end
    end)

    textbox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = textbox.Text

        if not allowed[text] and not tonumber(text) then
            textbox.Text = text:sub(1, #text - 1)
        elseif not allowed[text] then	
            value = self:UpdateSlider(slider, nil, tonumber(text) or value, min, max)
            callbackFunc(value)
        end
    end)
    
    -- Trigger section resize after adding the slider
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return slider
end

function Library:SectionAddDropdown(section, title, list, callback, default)
    local dropdown = Utility:Create("Frame", {
        Name = "Dropdown",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ClipsDescendants = true
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        }),
        Utility:Create("ImageLabel", {
            Name = "Search",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("TextBox", {
                Name = "TextBox",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 10, 0.5, 1),
                Size = UDim2.new(1, -42, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = Themes.TextColor,
                TextSize = 16,
                TextTransparency = 0.1,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility:Create("ImageButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -28, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                ZIndex = 3,
                Image = "rbxassetid://5012539403",
                ImageColor3 = Themes.TextColor,
                SliceCenter = Rect.new(2, 2, 298, 298)
            })
        }),
        Utility:Create("ImageLabel", {
            Name = "List",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, -34),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.Background,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("ScrollingFrame", {
                Name = "Frame",
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 4, 0, 4),
                Size = UDim2.new(1, -8, 1, -8),
                CanvasPosition = Vector2.new(0, 28),
                CanvasSize = UDim2.new(0, 0, 0, 120),
                ZIndex = 2,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Themes.DarkContrast
            }, {
                Utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })
        })
    })

    table.insert(section.Modules, dropdown)

    local search = dropdown.Search
    local focused

    list = list or {}

    if default then
        if table.find(list, default) then
            search.TextBox.Text = default
            if callback then
                callback(default)
            end
        else
            warn("Default value '"..tostring(default).."' not found in list")
        end
    end

    search.Button.MouseButton1Click:Connect(function()
        if search.Button.Rotation == 0 then
            self:UpdateDropdown(dropdown, nil, list, callback)
        else
            self:UpdateDropdown(dropdown, nil, nil, callback)
        end
    end)

    search.TextBox.Focused:Connect(function()
        if search.Button.Rotation == 0 then
            self:UpdateDropdown(dropdown, nil, list, callback)
        end

        focused = true
    end)

    search.TextBox.FocusLost:Connect(function()
        focused = false
    end)

    search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if focused then
            local filteredList = Utility:FilterList(search.TextBox.Text, list)
            filteredList = #filteredList ~= 0 and filteredList

            self:UpdateDropdown(dropdown, nil, filteredList, callback)
        end
    end)

    dropdown:GetPropertyChangedSignal("Size"):Connect(function()
        self:SectionResize(section)
    end)
    
    -- Trigger section resize after adding the dropdown
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return dropdown
end

function Library:SectionAddMultiDropdown(section, title, list, callback)
    local dropdown = Utility:Create("Frame", {
        Name = "MultiDropdown",
        Parent = section.ScrollingFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ClipsDescendants = true
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4)
        }),
        Utility:Create("ImageLabel", {
            Name = "Search",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("TextBox", {
                Name = "TextBox",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(1, -42, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.Gotham,
                Text = title,
                TextColor3 = Themes.TextColor,
                TextSize = 16,
                TextTransparency = 0.1,
                TextXAlignment = Enum.TextXAlignment.Left
            }),
            Utility:Create("ImageButton", {
                Name = "Button",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -28, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                ZIndex = 3,
                Image = "rbxassetid://5012539403",
                ImageColor3 = Themes.TextColor,
                SliceCenter = Rect.new(2, 2, 298, 298)
            })
        }),
        Utility:Create("ImageLabel", {
            Name = "List",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, -34),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.Background,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("ScrollingFrame", {
                Name = "Frame",
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 4, 0, 4),
                Size = UDim2.new(1, -8, 1, -8),
                CanvasPosition = Vector2.new(0, 28),
                CanvasSize = UDim2.new(0, 0, 0, 120),
                ZIndex = 2,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Themes.DarkContrast
            }, {
                Utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })
        })
    })

    local selected = {}
    local allOptions = list or {}

    local function updateSearchText()
        local textBox = dropdown.Search.TextBox
        if #selected > 0 then
            local txt = ""
            for _, v in pairs(selected) do
                txt = txt .. v .. ", "
            end
            textBox.Text = txt:sub(1, -3)
        else
            textBox.Text = title
        end
    end

    local function updateMultiDropdown(filteredList, callbackArg)
        for _, child in pairs(dropdown.List.Frame:GetChildren()) do
            if child:IsA("ImageButton") then
                child:Destroy()
            end
        end

        local entries = 0
        local optionsToDisplay = filteredList or allOptions

        for _, value in pairs(optionsToDisplay) do
            local isSelected = table.find(selected, value) ~= nil

            local optionButton = Utility:Create("ImageButton", {
                Parent = dropdown.List.Frame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = Themes.DarkContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                Utility:Create("Frame", {
                    Name = "Indicator",
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, 5, 1, 0),
                    Visible = isSelected,
                    ZIndex = 4
                }),
                Utility:Create("ImageLabel", {
                    Name = "Check",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 3,
                    Image = "rbxassetid://5012538583",  -- Change to appropriate check icon
                    Visible = isSelected
                }),
                Utility:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.SourceSansSemibold,
                    Text = value,
                    TextColor3 = Themes.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.1
                })
            })

            optionButton.MouseButton1Click:Connect(function()
                local found = table.find(selected, value)
                if found then
                    table.remove(selected, found)
                else
                    table.insert(selected, value)
                end
                optionButton.Check.Visible = not found
                optionButton.Indicator.Visible = not found
                updateSearchText()
                if callbackArg then
                    callbackArg(selected)
                elseif callback then
                    callback(selected)
                end
            end)
            entries = entries + 1
        end

        local frame = dropdown.List.Frame
        Utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 5) * 34 + 38)}, 0.3)
        Utility:Tween(dropdown.Search.Button, {Rotation = entries > 0 and 180 or 0}, 0.3)

        if entries > 5 then
            for _, button in pairs(frame:GetChildren()) do
                if button:IsA("ImageButton") then
                    button.Size = UDim2.new(1, -6, 0, 30)
                end
            end
            frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
            frame.ScrollBarImageTransparency = 0
        else
            frame.CanvasSize = UDim2.new(0, 0, 0, 0)
            frame.ScrollBarImageTransparency = 1
        end
    end

    updateMultiDropdown({}, callback)

    local search = dropdown.Search
    local focused = false

    search.Button.MouseButton1Click:Connect(function()
        if search.Button.Rotation == 0 then
            updateMultiDropdown(allOptions, callback)
        else
            updateMultiDropdown({}, callback)
        end
    end)

    search.TextBox.Focused:Connect(function()
        if search.Button.Rotation == 0 then
            updateMultiDropdown(allOptions, callback)
        end
        focused = true
    end)

    search.TextBox.FocusLost:Connect(function()
        focused = false
    end)

    search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        if focused then
            local filteredList = Utility:FilterList(search.TextBox.Text, allOptions)
            filteredList = #filteredList ~= 0 and filteredList

            updateMultiDropdown(filteredList, callback)
        end
    end)

    dropdown:GetPropertyChangedSignal("Size"):Connect(function()
        self:SectionResize(section)
    end)
    
    -- Trigger section resize after adding the multidropdown
    task.defer(function()
        self:SectionResize(section)
    end)
    
    return dropdown
end

-- Update methods
function Library:UpdateButton(button, title)
    button.Title.Text = title
end

function Library:UpdateToggle(toggle, title, value)
    local position = {
        In = UDim2.new(0, 2, 0.5, -6),
        Out = UDim2.new(0, 20, 0.5, -6)
    }
    local frame = toggle.Button.Frame
    value = value and "Out" or "In"
    if title then toggle.Title.Text = title end
    Utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -9), Position = position[value] + UDim2.new(0, 0, 0, 2.5)}, 0.2)
    if value == "Out" then
        Utility:Tween(toggle.Button, {ImageColor3 = Color3.new(0.235, 1, 0)}, 0.1)
    else
        Utility:Tween(toggle.Button, {ImageColor3 = Themes.LightContrast}, 0.1)
    end
    task.wait(0.1)
    Utility:Tween(frame, {Size = UDim2.new(1, -22, 1, -4), Position = position[value]}, 0.1)
end

function Library:UpdateTextbox(textbox, title, value)
    if title then
        textbox.Title.Text = title
    end
    if value then
        textbox.Button.Textbox.Text = value
    end
end

function Library:UpdateKeybind(keybind, title, key)
    if title then
        keybind.Title.Text = title
    end
    
    local section = self:FindSectionForKeybind(keybind)
    if not section then return end
    
    local bind = section.Binds[keybind]
    if bind and bind.Connection then
        bind.Connection:Unbind()
    end
    
    if key then
        if bind then
            bind.Connection = Utility:BindKey(self.Keybinds, key, bind.Callback)
        end
        keybind.Button.Text.Text = key.Name
    else
        keybind.Button.Text.Text = "None"
        if bind then
            bind.Connection = nil
        end
    end
end

function Library:UpdateColorPicker(colorpicker, title, color)
    local picker = self.ColorPickers[colorpicker]
    local tab = picker.tab

    if title then
        colorpicker.Title.Text = title
        tab.Title.Text = title
    end

    local color3
    local hue, sat, brightness

    if type(color) == "table" then
        hue, sat, brightness = unpack(color)
        color3 = Color3.fromHSV(hue, sat, brightness)
    else
        color3 = color
        hue, sat, brightness = Color3.toHSV(color3)
    end

    Utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
    Utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)

    Utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
    Utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0), ImageColor3 = Color3.fromRGB(255 - (color3.R * 255), 255 - (color3.G * 255), 255 - (color3.B * 255))}, 0.1)

    for i, prop in pairs({"r", "g", "b"}) do
        local num = math.clamp(color3[prop:upper()] * 255, 0, 255)
        tab.Container.Inputs[prop:upper()].Textbox.Text = math.floor(num)
    end
end

function Library:UpdateSlider(slider, title, value, min, max, lvalue)
    if title then
        slider.Title.Text = title
    end

    local bar = slider.Slider.Bar
    local percent = (Mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

    if value then
        percent = (value - min) / (max - min)
    end

    percent = math.clamp(percent or 0, 0, 1)

    if value then
        slider.TextBox.Text = value
    end

    Utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)

    value = value or math.floor(min + (max - min) * percent)
    slider.TextBox.Text = value

    if value ~= lvalue and slider.ImageTransparency == 0 then
        Utility:PopEffect(slider, 10)
    end

    return value
end

function Library:UpdateDropdown(dropdown, title, list, callback)
    if title then
        dropdown.Search.TextBox.Text = title
    end

    local entries = 0

    Utility:PopEffect(dropdown.Search, 10)

    for i, button in pairs(dropdown.List.Frame:GetChildren()) do
        if button:IsA("ImageButton") then
            button:Destroy()
        end
    end

    for i, value in pairs(list or {}) do
        local button = Utility:Create("ImageButton", {
            Parent = dropdown.List.Frame,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 30),
            ZIndex = 2,
            Image = "rbxassetid://5028857472",
            ImageColor3 = Themes.DarkContrast,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(2, 2, 298, 298)
        }, {
            Utility:Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                ZIndex = 3,
                Font = Enum.Font.SourceSansSemibold,
                Text = value,
                TextColor3 = Themes.TextColor,
                TextSize = 14,
                TextXAlignment = "Left",
                TextTransparency = 0.1
            })
        })

        button.MouseButton1Click:Connect(function()
            if callback then
                callback(value, function(...)
                    self:UpdateDropdown(dropdown, ...)
                end)	
            end

            self:UpdateDropdown(dropdown, value, nil, callback)
        end)

        entries = entries + 1
    end

    local frame = dropdown.List.Frame

    Utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 5) * 34 + 38)}, 0.3)
    Utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)

    if entries > 5 then
        for i, button in pairs(dropdown.List.Frame:GetChildren()) do
            if button:IsA("ImageButton") then
                button.Size = UDim2.new(1, -6, 0, 30)
            end
        end

        frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
        frame.ScrollBarImageTransparency = 0
    else
        frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        frame.ScrollBarImageTransparency = 1
    end
end

function Library:FindSectionForKeybind(keybind)
    for _, page in pairs(self.Pages) do
        for _, section in pairs(page.Sections) do
            if section.Binds and section.Binds[keybind] then
                return section
            end
        end
    end
    return nil
end

-- Resize page
function Library:PageResize(page)
    if not page or not page.UIListLayout then return end
    
    -- Calculate total height needed based on section heights
    local totalHeight = 0
    
    for _, section in ipairs(page.Sections) do
        local sectionHeight = section.Container.Parent.AbsoluteSize.Y
        totalHeight = totalHeight + sectionHeight + page.UIListLayout.Padding.Offset
    end
    
    -- Update page container CanvasSize
    page.Container.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20) -- Extra padding for safety
end

return Library
