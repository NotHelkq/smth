--[[ 
  Updated JennyLib.lua
  --------------------
  This version incorporates improvements for code reuse, event management, modern task delays, and modular UI component creation.

  Improvements include: 
    • A helper to create a base dropdown UI (createDropdownBase) used by both addDropdown and addMultiDropdown.
    • Connection tracking and cleanup for events.
    • Usage of task.wait/task.delay and an async tween helper.
    • Inline comments and clearer variable names.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local tweeninfo = TweenInfo.new

-- Theme and UI constants
local themes = {
    Background = Color3.fromRGB(24,24,24),
    Accent = Color3.fromRGB(10,10,10),
    LightContrast = Color3.fromRGB(20,20,20),
    DarkContrast = Color3.fromRGB(14,14,14),
    TextColor = Color3.fromRGB(255,255,255)
}
local UISize = UDim2.new(0,800,0,450)

-- Utility functions table
local utility = {}

-- Connection tracking: allows later clean-up of event connections.
function utility:trackConnection(object, eventName, callback)
    local connection = object[eventName]:Connect(callback)
    object._connections = object._connections or {}
    table.insert(object._connections, connection)
    return connection
end

function utility:cleanupConnections(object)
    if object._connections then
        for _, connection in ipairs(object._connections) do
            connection:Disconnect()
        end
        object._connections = nil
    end
end

-- Standard instance creation with property and children attachments.
function utility:Create(instance, properties, children)
    local object = Instance.new(instance)
    for i, v in pairs(properties or {}) do
        object[i] = v
        if typeof(v) == "Color3" then
            -- (Optionally track theme-based objects here)
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = object
    end
    return object
end

-- Tween helper (non-blocking)
function utility:Tween(instance, properties, duration, easingStyle, easingDirection)
    local t = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Sine, easingDirection or Enum.EasingDirection.InOut)
    local tweenObject = TweenService:Create(instance, t, properties)
    tweenObject:Play()
    return tweenObject
end

-- TweenAsync waits until the tween completes.
function utility:TweenAsync(instance, properties, duration, easingStyle, easingDirection)
    local t = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Sine, easingDirection or Enum.EasingDirection.InOut)
    local tweenObject = TweenService:Create(instance, t, properties)
    local completed = false
    tweenObject.Completed:Connect(function() completed = true end)
    tweenObject:Play()
    while not completed do
        task.wait()
    end
end

-- Wait helper waits on RenderStepped
function utility:Wait()
    RunService.RenderStepped:Wait()
    return true
end

-- Search for a value in a table; returns key if found.
function utility:Find(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

-- Filter values matching a substring (case-insensitive).
function utility:Sort(pattern, values)
    local new = {}
    pattern = pattern:lower()
    if pattern == "" then return values end
    for _, value in pairs(values) do
        if tostring(value):lower():find(pattern) then
            table.insert(new, value)
        end
    end
    return new
end

-- Pop animation: clones the object, shrinks it temporarily, then restores.
function utility:Pop(object, shrink)
    local clone = object:Clone()
    clone.AnchorPoint = Vector2.new(0.5,0.5)
    clone.Size = clone.Size - UDim2.new(0,shrink,0,shrink)
    clone.Position = UDim2.new(0.5,0,0.5,0)
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

-- Keybind management
function utility:InitializeKeybind()
    self.keybinds = {}
    self.ended = {}
    self:trackConnection(UserInputService, "InputBegan", function(input, proc)
        if self.keybinds[input.KeyCode] and not proc then
            for _, bind in pairs(self.keybinds[input.KeyCode]) do
                bind()
            end
        end
    end)
    self:trackConnection(UserInputService, "InputEnded", function(key)
        if key.UserInputType == Enum.UserInputType.MouseButton1 then
            for _, callback in pairs(self.ended) do
                callback()
            end
        end
    end)
end

function utility:BindToKey(key, callback)
    self.keybinds[key] = self.keybinds[key] or {}
    table.insert(self.keybinds[key], callback)
    return {
        UnBind = function()
            for i, bind in ipairs(self.keybinds[key]) do
                if bind == callback then
                    table.remove(self.keybinds[key], i)
                    break
                end
            end
        end
    }
end

function utility:KeyPressed()
    local key = UserInputService.InputBegan:Wait()
    while key.UserInputType ~= Enum.UserInputType.Keyboard do
        key = UserInputService.InputBegan:Wait()
    end
    task.wait()
    return key
end

-- Enables dragging for frames.
function utility:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, mousePos, framePos
    self:trackConnection(frame, "InputBegan", function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            self:trackConnection(input, "Changed", function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self:trackConnection(frame, "InputChanged", function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    self:trackConnection(UserInputService, "InputChanged", function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                         framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function utility:DraggingEnded(callback)
    table.insert(self.ended, callback)
end

-- Global table to store objects for theme updates (if needed)
local objects = {}

--------------------------------------------------------------------------------
-- Library, Page, and Section Definitions
--------------------------------------------------------------------------------
local library = {}
local page = {}
local section = {}

library.__index = library
page.__index = page
section.__index = section

function library.new(title)
    local container = utility:Create("ScreenGui", {
        Name = title or "Bubble Gum Simulator Infinity",
        Parent = game.CoreGui,
    }, {
        utility:Create("Frame", {
            Name = "Main",
            Position = UDim2.new(0.25,0,0.052435593,0),
            Size = UDim2.new(0,800,0,450),
            BackgroundColor3 = themes.DarkContrast,
        }, {
            utility:Create("UICorner"),
            utility:Create("TextButton", {
                Name = "ResizeWindow",
                Position = UDim2.new(1, -2, 1, -2),
                Size = UDim2.new(0, -15, 0,-15),
                ZIndex = 5,
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 0.75,
                BorderSizePixel = 0,
                Text = ""
            }),
            utility:Create("Frame", {
                Name = "TopBar",
                ClipsDescendants = true,
                Position = UDim2.new(0,0,0,0),
                Size = UDim2.new(1,0,0,30),
                ZIndex = 5,
                BackgroundColor3 = themes.DarkContrast,
            }, {
                utility:Create("UICorner"),
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                    ZIndex = 5,
                    Font = Enum.Font.SourceSansSemibold,
                    Text = title or "Bubble Gum Simulator Infinity",
                    TextColor3 = themes.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Center,
                })
            }),
            utility:Create("Frame", {
                Name = "Page",
                ClipsDescendants = true,
                Position = UDim2.new(0,150,0,30),
                Size = UDim2.new(1,-150,1,-30),
                BackgroundColor3 = themes.Background,
            }, { utility:Create("UICorner") }),
            utility:Create("Frame", {
                Name = "Sections",
                ClipsDescendants = true,
                BorderSizePixel = 0,
                Position = UDim2.new(0,0,0,30),
                Size = UDim2.new(0,150,1,-50),
                ZIndex = 2,
                BackgroundColor3 = themes.DarkContrast,
            }, {
                utility:Create("ScrollingFrame", {
                    Active = true,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(1,0,1,0),
                    CanvasSize = UDim2.new(0,0,0,314),
                    ScrollBarThickness = 0,
                }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0,10)
                    })
                })
            }),
        })
    })

    utility:InitializeKeybind()
    utility:DraggingEnabled(container.Main.TopBar, container.Main)

    local draggingResize
    container.Main.ResizeWindow.MouseButton1Down:Connect(function()
        draggingResize = true
        while draggingResize do
            local x, y = mouse.X - 1, mouse.Y - 1
            local pos = container.Main.AbsolutePosition
            local size = container.Main.AbsoluteSize
            if x - pos.X >= 500 then
                container.Main.Size = UDim2.new(0, x - pos.X, 0, size.Y)
            end
            size = container.Main.AbsoluteSize
            if y - pos.Y >= 281 then
                container.Main.Size = UDim2.new(0, size.X, 0, y - pos.Y)
            end
            UISize = UDim2.new(0, container.Main.AbsoluteSize.X, 0, container.Main.AbsoluteSize.Y)
            utility:Wait()
        end
    end)
    utility:trackConnection(UserInputService, "InputEnded", function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingResize = false
        end
    end)
    
    return setmetatable({
        container = container,
        pagesContainer = container.Main.Sections.ScrollingFrame,
        pages = {}
    }, library)
end

function page.new(library, title, icon)
    icon = "rbxassetid://" .. tostring(icon)
    local button = utility:Create("TextButton", {
        Name = title,
        Parent = library.pagesContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,26),
        ZIndex = 3,
        AutoButtonColor = false,
        Font = Enum.Font.SourceSansSemibold,
        Text = "",
        TextSize = 14,
    }, {
        utility:Create("TextLabel", {
            Name = "Title",
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.22, 0, 0.5, 0),
            Size = UDim2.new(0.75, 0, 1, 0),
            ZIndex = 3,
            Font = Enum.Font.SourceSansSemibold,
            Text = title,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextTransparency = 0.65,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        utility:Create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0,12,0.5,0),
            Size = UDim2.new(0,16,0,16),
            ZIndex = 3,
            Image = "rbxassetid://5012544693" or icon,
            ImageColor3 = themes.TextColor,
            ImageTransparency = 0.64,
        })
    })
    
    local container = utility:Create("ScrollingFrame", {
        Name = title,
        Parent = library.container.Main.Page,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0,0,0,5),
        Size = UDim2.new(1,0,1,-5),
        CanvasSize = UDim2.new(0,0,0,466),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = themes.DarkContrast,
        Visible = false,
    })
    
    return setmetatable({
        library = library,
        container = container,
        button = button,
        sections = {}
    }, page)
end

function section.new(page, title)
    local container = utility:Create("Frame", {
        Name = title,
        Parent = page.container,
        Size = UDim2.new(1,-10,0,28),
        ZIndex = 2,
        BackgroundColor3 = themes.LightContrast,
        ClipsDescendants = true,
    }, {
        utility:Create("UICorner"),
        utility:Create("Frame", {
            Name = "Container",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0,8,0,8),
            Size = UDim2.new(1,-16,1,-16),
        }, {
            utility:Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,20),
                ZIndex = 2,
                Font = Enum.Font.SourceSansSemibold,
                Text = title,
                TextColor3 = themes.TextColor,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 1,
            }),
            utility:Create("ScrollingFrame", {
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0,0,0,25),
                Size = UDim2.new(1,0,1,-25),
                CanvasSize = UDim2.new(0,0,0,466),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = themes.TextColor,
                ZIndex = 5,
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0,4),
                })
            }),
        })
    })
    return setmetatable({
        page = page,
        container = container.Container,
        colorpickers = {},
        modules = {},
        binds = {},
        lists = {},
    }, section)
end

function library:addPage(...)
    local newPage = page.new(self, ...)
    table.insert(self.pages, newPage)
    newPage.button.MouseButton1Click:Connect(function()
        self:SelectPage(newPage, true)
    end)
    return newPage
end

function page:addSection(...)
    local newSection = section.new(self, ...)
    table.insert(self.sections, newSection)
    return newSection
end

function library:setTheme(theme, color3)
    themes[theme] = color3
    for property, objs in pairs(objects[theme] or {}) do
        for i, object in pairs(objs) do
            if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
                objs[i] = nil 
            else
                object[property] = color3
            end
        end
    end
end

function library:toggle()
    if self.toggling then return end
    self.toggling = true
    local container = self.container.Main
    local topbar = container.TopBar
    if self.position then
        utility:Tween(container, {Size = UISize, Position = self.position}, 0.2)
        task.wait(0.2)
        utility:Tween(topbar, {Size = UDim2.new(1,0,0,30)}, 0.2)
        task.wait(0.2)
        container.ClipsDescendants = false
        self.position = nil
    else
        self.position = container.Position
        container.ClipsDescendants = true
        utility:Tween(topbar, {Size = UDim2.new(1,0,1,0)}, 0.2)
        task.wait(0.2)
        utility:Tween(container, {Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0), Position = self.position + UDim2.new(0,0,0,428)}, 0.2)
        task.wait(0.2)
    end
    self.toggling = false
end

function library:Notify(title, text, callback)
    if self.activeNotification then
        self.activeNotification = self.activeNotification()
    end
    local notification = utility:Create("ImageLabel", {
        Name = "Notification",
        Parent = self.container,
        BackgroundTransparency = 1,
        Size = UDim2.new(0,200,0,60),
        Image = "rbxassetid://5028857472",
        ImageColor3 = themes.Background,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(4,4,296,296),
        ZIndex = 3,
        ClipsDescendants = true,
    }, {
        utility:Create("ImageLabel", {
            Name = "Flash",
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://4641149554",
            ImageColor3 = themes.TextColor,
            ZIndex = 5,
        }),
        utility:Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,0,8),
            Size = UDim2.new(1,-40,0,16),
            ZIndex = 4,
            Font = Enum.Font.SourceSansSemibold,
            TextColor3 = themes.TextColor,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        utility:Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Position = UDim2.new(0,10,1,-24),
            Size = UDim2.new(1,-40,0,16),
            ZIndex = 4,
            Font = Enum.Font.Gotham,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        utility:Create("ImageButton", {
            Name = "Accept",
            BackgroundTransparency = 1,
            Position = UDim2.new(1,-26,0,8),
            Size = UDim2.new(0,16,0,16),
            Image = "rbxassetid://5012538259",
            ImageColor3 = themes.TextColor,
            ZIndex = 4,
        }),
        utility:Create("ImageButton", {
            Name = "Decline",
            BackgroundTransparency = 1,
            Position = UDim2.new(1,-26,1,-24),
            Size = UDim2.new(0,16,0,16),
            Image = "rbxassetid://5012538583",
            ImageColor3 = themes.TextColor,
            ZIndex = 4,
        }),
    })
    utility:DraggingEnabled(notification)
    title = title or "Notification"
    text = text or ""
    notification.Title.Text = title
    notification.Text.Text = text
    local padding = 10
    local textSize = TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge,16))
    notification.Position = self.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
    notification.Size = UDim2.new(0,0,0,60)
    utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0,60)}, 0.2)
    task.wait(0.2)
    notification.ClipsDescendants = false
    utility:Tween(notification.Flash, {Size = UDim2.new(0,0,0,60), Position = UDim2.new(1,0,0,0)}, 0.2)
    local active = true
    local close = function()
        if not active then return end
        active = false
        notification.ClipsDescendants = true
        self.lastNotification = notification.Position
        notification.Flash.Position = UDim2.new(0,0,0,0)
        utility:Tween(notification.Flash, {Size = UDim2.new(1,0,1,0)}, 0.2)
        task.wait(0.2)
        utility:Tween(notification, {Size = UDim2.new(0,0,0,60), Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)}, 0.2)
        task.wait(0.2)
        notification:Destroy()
    end
    self.activeNotification = close
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

--------------------------------------------------------------------------------
-- Dropdown Helper: Creates a base for dropdown UI for reuse.
function section:createDropdownBase(name, title)
    local container = utility:Create("Frame", {
        Name = name,
        Parent = self.container.ScrollingFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,0,30),
        ClipsDescendants = true,
    }, {
        utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0,4),
        })
    })
    local search = utility:Create("ImageLabel", {
        Name = "Search",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,30),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = themes.DarkContrast,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2,2,298,298),
    }, {
        utility:Create("TextBox", {
            Name = "TextBox",
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundTransparency = 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.new(0,10,0.5,0),
            Size = UDim2.new(1,-42,1,0),
            ZIndex = 3,
            Font = Enum.Font.Gotham,
            Text = title,
            TextColor3 = themes.TextColor,
            TextSize = 12,
            TextTransparency = 0.1,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
        utility:Create("ImageButton", {
            Name = "Button",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1,-28,0.5,-9),
            Size = UDim2.new(0,18,0,18),
            ZIndex = 3,
            Image = "rbxassetid://5012539403",
            ImageColor3 = themes.TextColor,
            SliceCenter = Rect.new(2,2,298,298),
        })
    })
    
    local listContainer = utility:Create("ImageLabel", {
        Name = "List",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,-34),
        ZIndex = 2,
        Image = "rbxassetid://5028857472",
        ImageColor3 = themes.Background,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2,2,298,298),
    }, {
        utility:Create("ScrollingFrame", {
            Name = "Frame",
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0,4,0,4),
            Size = UDim2.new(1,-8,1,-8),
            CanvasPosition = Vector2.new(0,28),
            CanvasSize = UDim2.new(0,0,0,120),
            ZIndex = 2,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = themes.DarkContrast,
        }, {
            utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,4),
            })
        })
    })
    
    return { container = container, search = search, listContainer = listContainer }
end

--------------------------------------------------------------------------------
-- Dropdown Functions
--------------------------------------------------------------------------------
-- Single-selection dropdown (similar to your original addDropdown).
function section:addDropdown(title, list, callback)
    local base = self:createDropdownBase("Dropdown", title)
    local dropdown = base.container
    local searchBox = base.search.TextBox
    local listFrame = base.listContainer.Frame
    list = list or {}

    local function updateDropdown(filteredList)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("ImageButton") then child:Destroy() end
        end
        local entries = 0
        local optionsToDisplay = filteredList or list
        for _, value in ipairs(optionsToDisplay) do
            local btn = utility:Create("ImageButton", {
                Parent = listFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0,30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2,2,298,298),
            }, {
                utility:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,10,0,0),
                    Size = UDim2.new(1,-10,1,0),
                    ZIndex = 3,
                    Font = Enum.Font.SourceSansSemibold,
                    Text = value,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.1,
                })
            })
            btn.MouseButton1Click:Connect(function()
                searchBox.Text = value
                if callback then callback(value) end
                updateDropdown({})
            end)
            entries = entries + 1
        end
        utility:Tween(dropdown, {Size = UDim2.new(1,0,0, (entries == 0 and 30) or math.clamp(entries,0,3)*34 + 38)}, 0.3)
        utility:Tween(base.search.Button, {Rotation = (entries > 0 and 180) or 0}, 0.3)
        if entries > 3 then
            for _, btn in ipairs(listFrame:GetChildren()) do
                if btn:IsA("ImageButton") then
                    btn.Size = UDim2.new(1,-6,0,30)
                end
            end
            listFrame.CanvasSize = UDim2.new(0,0,0,(entries*34)-4)
            listFrame.ScrollBarImageTransparency = 0
        else
            listFrame.CanvasSize = UDim2.new(0,0,0,0)
            listFrame.ScrollBarImageTransparency = 1
        end
    end

    updateDropdown(list)

    local focused = false
    base.search.Button.MouseButton1Click:Connect(function()
        if base.search.Button.Rotation == 0 then
            updateDropdown(list)
        else
            updateDropdown({})
        end
    end)
    searchBox.Focused:Connect(function()
        if base.search.Button.Rotation == 0 then
            updateDropdown(list)
        end
        focused = true
    end)
    searchBox.FocusLost:Connect(function() focused = false end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if focused then
            local sorted = utility:Sort(searchBox.Text, list)
            updateDropdown(#sorted ~= 0 and sorted or list)
        end
    end)
    return dropdown
end

-- Multi-selection dropdown with visual selection indicator.
function section:addMultiDropdown(title, list, callback)
    local base = self:createDropdownBase("MultiDropdown", title)
    local dropdown = base.container
    local searchBox = base.search.TextBox
    local listFrame = base.listContainer.Frame
    list = list or {}

    -- Table holding the currently selected options.
    local selected = {}

    -- Update the search box text to show the joined selected options.
    local function updateSearchText()
        if next(selected) then
            searchBox.Text = table.concat(selected, ", ")
        else
            searchBox.Text = title
        end
    end

    -- Build or rebuild the dropdown list.
    local function updateMultiDropdown(filteredList)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("ImageButton") then child:Destroy() end
        end
        local entries = 0
        local optionsToDisplay = filteredList or list
        for _, value in ipairs(optionsToDisplay) do
            -- Determine if this option is already selected.
            local isSelected = false
            for _, sel in ipairs(selected) do
                if sel == value then
                    isSelected = true
                    break
                end
            end

            -- Create an option button that includes:
            --   • A left vertical indicator (green when selected)
            --   • A checkmark image on the right (placeholder asset)
            --   • The option text.
            local optionButton = utility:Create("ImageButton", {
                Parent = listFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0,30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2,2,298,298),
            }, {
                utility:Create("Frame", {
                    Name = "Indicator",
                    BackgroundColor3 = Color3.fromRGB(0,255,0), -- green indicator; change as needed
                    BorderSizePixel = 0,
                    Position = UDim2.new(0,0,0,0),
                    Size = UDim2.new(0,4,1,0),
                    Visible = isSelected,
                    ZIndex = 4,
                }),
                utility:Create("ImageLabel", {
                    Name = "Check",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1,-20,0.5,-8),
                    Size = UDim2.new(0,16,0,16),
                    ZIndex = 3,
                    Image = "rbxassetid://1234567890", -- replace with your actual checkmark asset ID
                    Visible = isSelected,
                }),
                utility:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,10,0,0),
                    Size = UDim2.new(1,-40,1,0),
                    ZIndex = 3,
                    Font = Enum.Font.SourceSansSemibold,
                    Text = value,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTransparency = 0.1,
                }),
            })

            -- Toggle the selection state when the option is clicked.
            optionButton.MouseButton1Click:Connect(function()
                local found = false
                for i, sel in ipairs(selected) do
                    if sel == value then
                        table.remove(selected, i)
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(selected, value)
                end
                local checkMark = optionButton:FindFirstChild("Check")
                if checkMark then
                    checkMark.Visible = not found
                end
                local indicator = optionButton:FindFirstChild("Indicator")
                if indicator then
                    indicator.Visible = not found
                end
                updateSearchText()
                if callback then callback(selected) end
            end)
            entries = entries + 1
        end

        utility:Tween(dropdown, {Size = UDim2.new(1,0,0, (entries == 0 and 30) or math.clamp(entries,0,3)*34 + 38)}, 0.3)
        utility:Tween(base.search.Button, {Rotation = (entries > 0 and 180) or 0}, 0.3)
        if entries > 3 then
            for _, btn in ipairs(listFrame:GetChildren()) do
                if btn:IsA("ImageButton") then
                    btn.Size = UDim2.new(1,-6,0,30)
                end
            end
            listFrame.CanvasSize = UDim2.new(0,0,0,(entries*34)-4)
            listFrame.ScrollBarImageTransparency = 0
        else
            listFrame.CanvasSize = UDim2.new(0,0,0,0)
            listFrame.ScrollBarImageTransparency = 1
        end
    end

    updateMultiDropdown(list)

    local focused = false
    base.search.Button.MouseButton1Click:Connect(function()
        if base.search.Button.Rotation == 0 then
            updateMultiDropdown(list)
        else
            updateMultiDropdown({})
        end
    end)
    searchBox.Focused:Connect(function()
        updateMultiDropdown(list)
        focused = true
    end)
    searchBox.FocusLost:Connect(function() focused = false end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if focused then
            local sorted = utility:Sort(searchBox.Text, list)
            updateMultiDropdown(#sorted ~= 0 and sorted or list)
        end
    end)
    return dropdown
end

--------------------------------------------------------------------------------
return library
