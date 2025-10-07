local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Background = Color3.fromRGB(24,24,24), -- same as Random UI
    Accent = Color3.fromRGB(10,10,10),    -- Random UI Accent (very dark)
    LightContrast = Color3.fromRGB(20,20,20),
    DarkContrast = Color3.fromRGB(14,14,14),
    -- Map our semantic names to the Random UI palette
    Panel = Color3.fromRGB(14,14,14),
    Row = Color3.fromRGB(20,20,20),
    Text = Color3.fromRGB(255,255,255),
}

local Util = {}
function Util.newInstance(class, props, children)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do obj[k] = v end
    end
    if children then
        for _,c in pairs(children) do c.Parent = obj end
    end
    return obj
end

function Util.tween(instance, props, time)
    time = time or 0.15
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(instance, info, props):Play()
end

function Util.makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local SimpleUI = {}
SimpleUI.__index = SimpleUI

-- Create the UI
function SimpleUI.new(title)
    title = title or "Simple UI"

    local screen = Util.newInstance("ScreenGui", {Name = title, ResetOnSpawn = false, Parent = game:GetService("CoreGui")})

    local main = Util.newInstance("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 800, 0, 450), -- default size from Random UI
        Position = UDim2.new(0.18,0,0.12,0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = screen,
    })

    Util.newInstance("UICorner", {Parent = main})

    local top = Util.newInstance("Frame", {
        Name = "Top",
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = Theme.Panel,
        Parent = main,
    })
    Util.newInstance("UICorner", {Parent = top})

    local titleLabel = Util.newInstance("TextLabel", {
        Text = title,
        Parent = top,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    -- Left sidebar for pages
    local sidebar = Util.newInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0,140,1,-34),
        Position = UDim2.new(0,0,0,34),
        BackgroundColor3 = Theme.Panel,
        Parent = main,
    })
    Util.newInstance("UICorner", {Parent = sidebar})

    local pagesContainer = Util.newInstance("Frame", {
        Name = "Pages",
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    local pagesLayout = Util.newInstance("UIListLayout", {Parent = pagesContainer}) pagesLayout.SortOrder = Enum.SortOrder.LayoutOrder pagesLayout.Padding = UDim.new(0,6)

    -- Content area
    local content = Util.newInstance("Frame", {
        Name = "Content",
        Position = UDim2.new(0,140,0,34),
        Size = UDim2.new(1,-140,1,-34),
        BackgroundColor3 = Theme.Background,
        Parent = main,
    })
    Util.newInstance("UICorner", {Parent = content})

    local pages = {}

    local self = setmetatable({
        Screen = screen,
        Main = main,
        Sidebar = sidebar,
        PagesContainer = pagesContainer,
        Content = content,
        Pages = pages,
        Selected = nil,
    }, SimpleUI)

    -- Make draggable via top bar
    Util.makeDraggable(main, top)

    -- Resize grip (bottom-right) - hold and drag to resize the main frame
    local resizeGrip = Util.newInstance("Frame", {
        Name = "ResizeGrip",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -14, 1, -14),
        BackgroundColor3 = Theme.Panel,
        AnchorPoint = Vector2.new(0, 0),
        Parent = main,
    })
    Util.newInstance("UICorner", {Parent = resizeGrip})

    do
        local resizing = false
        local startMouse = Vector2.new(0, 0)
        local startSize = Vector2.new(600, 380)
        local minSize = Vector2.new(300, 200)

        resizeGrip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                startMouse = input.Position
                startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startMouse
                local newW = math.max(minSize.X, math.floor(startSize.X + delta.X))
                local newH = math.max(minSize.Y, math.floor(startSize.Y + delta.Y))
                main.Size = UDim2.new(0, newW, 0, newH)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end

    return self
end

-- Add a page (button appears in sidebar and container in content area)
function SimpleUI:addPage(name)
    local pageButton = Util.newInstance("TextButton", {
        Text = name or "Page",
        Size = UDim2.new(1,-12,0,28),
        Position = UDim2.new(0,6,0,0),
        BackgroundColor3 = Theme.Background,
        Parent = self.PagesContainer,
        AutoButtonColor = true,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
    })

    Util.newInstance("UICorner", {Parent = pageButton})

    local pageFrame = Util.newInstance("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 6,
        Parent = self.Content,
        Visible = false,
    })
    local list = Util.newInstance("UIListLayout", {Parent = pageFrame}) list.SortOrder = Enum.SortOrder.LayoutOrder list.Padding = UDim.new(0,8)
    -- center section frames horizontally inside the page
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local page = {
        Name = name,
        Button = pageButton,
        Frame = pageFrame,
        Layout = list,
    }

    -- capture library reference for closures below
    local LIB = self

    table.insert(self.Pages, page)

    pageButton.MouseButton1Click:Connect(function()
        self:selectPage(page)
    end)

    -- If first page, select
    if #self.Pages == 1 then self:selectPage(page) end

    -- API for adding sections and controls scoped to the page
    function page:addSection(title)
        -- give sections a centered, slightly narrower width so they sit in the middle
            local container = Util.newInstance("Frame", {
                Size = UDim2.new(0.95,0,0,40),
                BackgroundColor3 = Theme.Panel,
                Parent = self.Frame,
            })
        container.AnchorPoint = Vector2.new(0.5, 0)
        -- push sections a bit down so they don't sit flush with top padding
        container.Position = UDim2.new(0.5, 0, 0, 14)
        Util.newInstance("UICorner", {Parent = container})

        local header = Util.newInstance("TextLabel", {
            Text = title,
            Size = UDim2.new(1,0,0,24),
            BackgroundTransparency = 1,
            Parent = container,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local content = Util.newInstance("Frame", {
            Name = "Inner",
            BackgroundTransparency = 1,
            Position = UDim2.new(0,0,0,26),
            Size = UDim2.new(1,0,0,0),
            Parent = container,
        })
        -- add small left padding so child controls' text shifts right slightly
        Util.newInstance("UIPadding", {Parent = content, PaddingLeft = UDim.new(0,6)})
        local innerLayout = Util.newInstance("UIListLayout", {Parent = content}) innerLayout.SortOrder = Enum.SortOrder.LayoutOrder innerLayout.Padding = UDim.new(0,6)

        -- keep track of content size
        innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.Size = UDim2.new(1,0,0, innerLayout.AbsoluteContentSize.Y)
            container.Size = UDim2.new(1,-16,0, 26 + innerLayout.AbsoluteContentSize.Y + 12)
            -- update scroll canvas
            self.Frame.CanvasSize = UDim2.new(0,0,0, self.Frame.UIListLayout and self.Frame.UIListLayout.AbsoluteContentSize.Y or 0)
        end)

        local section = {
            Container = content,
            AddButton = function(_, txt, cb)
                -- row container
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = content, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,8)})
                -- inner transparent button to receive clicks but show row background
                local inner = Util.newInstance("TextButton", {Text = txt or "Button", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                inner.MouseButton1Click:Connect(function() pcall(cb) end)
                return inner
            end,
            AddKeybind = function(_, txt, defaultKey, cb)
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = content, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                Util.newInstance("TextLabel", {Text = txt, Size = UDim2.new(0.6,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

                -- action box on the right that contains the keybind control
                local action = Util.newInstance("Frame", {Size = UDim2.new(0,120,0,24), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = action})
                Util.newInstance("UIPadding", {Parent = action, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

                local btn = Util.newInstance("TextButton", {Text = "None", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = action, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, BorderSizePixel = 0})

                -- Normalize defaultKey: allow Enum.KeyCode or string
                local boundKey
                if typeof(defaultKey) == "EnumItem" then
                    boundKey = defaultKey
                elseif type(defaultKey) == "string" then
                    boundKey = Enum.KeyCode[defaultKey]
                end

                local bindConnection
                local function applyBinding(key)
                    boundKey = key
                    btn.Text = key and (tostring(key.Name) or tostring(key)) or "None"
                    if bindConnection then
                        bindConnection:Disconnect()
                        bindConnection = nil
                    end
                    if boundKey then
                        bindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == boundKey and not gameProcessed then
                                pcall(cb, input.KeyCode)
                            end
                        end)
                    end
                end

                -- clicking the button enters capture mode for next key press
                local captureConn
                btn.MouseButton1Click:Connect(function()
                    btn.Text = "Press a key..."
                    if captureConn then captureConn:Disconnect() captureConn = nil end
                    captureConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            applyBinding(input.KeyCode)
                            captureConn:Disconnect()
                            captureConn = nil
                        end
                    end)
                end)

                -- apply default if provided
                if boundKey then applyBinding(boundKey) end

                return btn
            end,
            AddToggle = function(_, txt, default, cb)
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = content, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                local label = Util.newInstance("TextLabel", {Text = txt, Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

                -- action box containing the switch
                local action = Util.newInstance("Frame", {Size = UDim2.new(0,80,0,24), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = action})
                Util.newInstance("UIPadding", {Parent = action, PaddingRight = UDim.new(0,6)})

                -- switch track
                local track = Util.newInstance("Frame", {Size = UDim2.new(0,44,0,20), Position = UDim2.new(1,-8,0.5,-10), BackgroundColor3 = (default and Color3.fromRGB(85,170,255) or Theme.Row), Parent = action, BorderSizePixel = 0, AnchorPoint = Vector2.new(1,0)})
                Util.newInstance("UICorner", {Parent = track})
                -- knob
                local knob = Util.newInstance("Frame", {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0.06,0,0.5,-8), BackgroundColor3 = Theme.Panel, Parent = track, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = knob})

                local state = default and true or false
                local function setState(on, instant)
                    state = not not on
                    local targetX = state and 1 or 0
                    local knobPos = state and UDim2.new(0.88, -16, 0.5, -8) or UDim2.new(0.06,0,0.5,-8)
                    local trackColor = state and Color3.fromRGB(85,170,255) or Theme.Row
                    if instant then
                        knob.Position = knobPos
                        track.BackgroundColor3 = trackColor
                    else
                        Util.tween(knob, {Position = knobPos}, 0.12)
                        Util.tween(track, {BackgroundColor3 = trackColor}, 0.12)
                    end
                end

                -- initial visual
                setState(state, true)

                -- toggle on click
                track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        setState(not state)
                        pcall(cb, state)
                    end
                end)

                return {
                    Track = track,
                    Knob = knob,
                    Set = setState,
                    Get = function() return state end
                }
            end,
            AddTextbox = function(_, txt, default, cb)
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = content, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                Util.newInstance("TextLabel", {Text = txt, Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

                local action = Util.newInstance("Frame", {Size = UDim2.new(0,220,0,24), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = action})
                Util.newInstance("UIPadding", {Parent = action, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

                local box = Util.newInstance("TextBox", {Text = default or "", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = action, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = box})
                Util.newInstance("UIPadding", {Parent = box, PaddingLeft = UDim.new(0,10)})
                box.FocusLost:Connect(function(enter)
                    pcall(cb, box.Text, enter)
                end)
                return box
            end,
            AddSlider = function(_, txt, min, max, default, cb)
                min = min or 0 max = max or 100 default = default or min
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,40), BackgroundColor3 = Theme.Row, Parent = content, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                Util.newInstance("TextLabel", {Text = txt, Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                -- slightly reduce bar width to make room for numeric value label
                local barBg = Util.newInstance("Frame", {Size = UDim2.new(0.46,0,0,10), Position = UDim2.new(0.44,0,0.5,-5), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = barBg})
                local fill = Util.newInstance("Frame", {Size = UDim2.new( (default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(85,170,255), Parent = barBg})
                Util.newInstance("UICorner", {Parent = fill})
                -- numeric value label on the right
                local valueLabel = Util.newInstance("TextLabel", {Text = tostring(default), Size = UDim2.new(0,50,0,18), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,-9), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right})
                local dragging
                barBg.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                end)
                barBg.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                game:GetService("UserInputService").InputChanged:Connect(function(inp)
                    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((inp.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                        fill.Size = UDim2.new(rel,0,1,0)
                        local value = math.floor(min + rel*(max-min))
                        if valueLabel then valueLabel.Text = tostring(value) end
                        pcall(cb, value)
                    end
                end)
                -- set initial value label
                if valueLabel then valueLabel.Text = tostring(math.floor(default)) end
                return fill
            end,
            AddDropdown = function(_, label, options, defaultIndex, cb)
                options = options or {}
                local container = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = content})
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = container, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                Util.newInstance("TextLabel", {Text = label, Size = UDim2.new(0.35,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                -- action box on the right that contains the dropdown display
                local action = Util.newInstance("Frame", {Size = UDim2.new(0,240,0,24), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = action})
                Util.newInstance("UIPadding", {Parent = action, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

                local btn = Util.newInstance("TextButton", {Text = options[defaultIndex] or "Select", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = action, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left})
                -- create popup under top-level screen to avoid clipping / overlap
                local listContainer = Util.newInstance("Frame", {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Theme.Panel, Parent = LIB.Screen, ClipsDescendants = true, Visible = false, BorderSizePixel = 0, ZIndex = 50})
                Util.newInstance("UICorner", {Parent = listContainer})
                local scroll = Util.newInstance("ScrollingFrame", {Parent = listContainer, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 6, BorderSizePixel = 0, ZIndex = 51})
                local layout = Util.newInstance("UIListLayout", {Parent = scroll}) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0,4)

                local currentOverlayZ = 0
                local function rebuild()
                    for _,c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for i,v in ipairs(options) do
                        local opt = Util.newInstance("TextButton", {Text = tostring(v), Size = UDim2.new(1,0,0,28), Parent = scroll, BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 52})
                        Util.newInstance("UICorner", {Parent = opt})
                        Util.newInstance("UIPadding", {Parent = opt, PaddingLeft = UDim.new(0,12)})
                        opt.MouseButton1Click:Connect(function()
                            btn.Text = tostring(v)
                            listContainer.Visible = false
                            if LIB._popupOverlay then pcall(function() LIB._popupOverlay:Destroy() end) LIB._popupOverlay = nil end
                            pcall(cb, v, i)
                        end)
                    end
                    -- adjust canvas and container height
                    local entries = #options
                    local h = math.clamp(entries * 32, 0, 32 * 6)
                        -- position the popup directly under the button using absolute coordinates
                        local absPos = btn.AbsolutePosition
                        local absSize = btn.AbsoluteSize
                        local screenW = LIB.Screen.AbsoluteSize.X
                        local width = math.clamp(absSize.X, 120, math.max(120, screenW - absPos.X - 16))
                        listContainer.Size = UDim2.new(0, width, 0, h)
                        listContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    scroll.CanvasSize = UDim2.new(0,0,0, entries * 32)
                end

                btn.MouseButton1Click:Connect(function()
                    -- explicit toggle: if already visible, hide and disconnect outside handler
                    if listContainer.Visible then
                        listContainer.Visible = false
                        if LIB._popupOutsideConn then pcall(function() LIB._popupOutsideConn:Disconnect() end) LIB._popupOutsideConn = nil end
                        return
                    end

                    -- close any other popup handler
                    if LIB._popupOutsideConn then
                        pcall(function() LIB._popupOutsideConn:Disconnect() end)
                        LIB._popupOutsideConn = nil
                    end

                    rebuild()
                    -- ensure popup sits above other UI and is positioned correctly
                    listContainer.ZIndex = 50
                    scroll.ZIndex = 51
                    -- position using absolute position of the button
                    local absPos = btn.AbsolutePosition
                    local absSize = btn.AbsoluteSize
                    local screenW = LIB.Screen.AbsoluteSize.X
                    local width = math.clamp(absSize.X, 120, math.max(120, screenW - absPos.X - 16))
                    listContainer.Size = UDim2.new(0, width, 0, listContainer.Size.Y.Offset)
                    listContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    listContainer.Visible = true

                    -- defer outside-click registration one tick to avoid treating the opening click as an outside click
                    task.defer(function()
                        if LIB._popupOutsideConn then pcall(function() LIB._popupOutsideConn:Disconnect() end) LIB._popupOutsideConn = nil end
                        LIB._popupOutsideConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local pos = listContainer.AbsolutePosition
                                local size = listContainer.AbsoluteSize
                                local mx, my = input.Position.X, input.Position.Y
                                if mx < pos.X or mx > pos.X + size.X or my < pos.Y or my > pos.Y + size.Y then
                                    listContainer.Visible = false
                                    if LIB._popupOutsideConn then LIB._popupOutsideConn:Disconnect() LIB._popupOutsideConn = nil end
                                end
                            end
                        end)
                    end)
                end)

                return btn
            end,
            AddMultiDropdown = function(_, label, options, defaultSelected, cb)
                options = options or {}
                local selected = {}
                if type(defaultSelected) == "table" then
                    for _,v in pairs(defaultSelected) do selected[v] = true end
                end

                local container = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1, Parent = content})
                local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,34), BackgroundColor3 = Theme.Row, Parent = container, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = row})
                Util.newInstance("UIPadding", {Parent = row, PaddingLeft = UDim.new(0,12)})
                Util.newInstance("TextLabel", {Text = label, Size = UDim2.new(0.35,0,1,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})

                -- action box on the right containing the display control
                local action = Util.newInstance("Frame", {Size = UDim2.new(0,240,0,24), AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0), BackgroundColor3 = Theme.Panel, Parent = row, BorderSizePixel = 0})
                Util.newInstance("UICorner", {Parent = action})
                Util.newInstance("UIPadding", {Parent = action, PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8)})

                local display = Util.newInstance("TextButton", {Text = "", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = action, BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = false, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left})
                Util.newInstance("UICorner", {Parent = display})
                Util.newInstance("UIPadding", {Parent = display, PaddingLeft = UDim.new(0,12)})

                -- popup lives under top-level screen to avoid overlap
                local listContainer = Util.newInstance("Frame", {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Theme.Panel, Parent = LIB.Screen, ClipsDescendants = true, Visible = false, BorderSizePixel = 0, ZIndex = 60})
                Util.newInstance("UICorner", {Parent = listContainer})
                local scroll = Util.newInstance("ScrollingFrame", {Parent = listContainer, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 6, BorderSizePixel = 0, ZIndex = 61})
                local layout = Util.newInstance("UIListLayout", {Parent = scroll}) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Padding = UDim.new(0,4)

                local function updateDisplay()
                    local parts = {}
                    for _,v in pairs(options) do
                        if selected[v] then table.insert(parts, tostring(v)) end
                    end
                    display.Text = #parts > 0 and table.concat(parts, ", ") or "(none)"
                end

                local function rebuild()
                    for _,c in pairs(scroll:GetChildren()) do if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end end
                    for i,v in ipairs(options) do
                        local row = Util.newInstance("Frame", {Size = UDim2.new(1,0,0,28), Parent = scroll, BackgroundTransparency = 1})
                        local opt = Util.newInstance("TextButton", {Text = tostring(v), Size = UDim2.new(1,0,0,28), Parent = row, BackgroundColor3 = Theme.Row, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, AutoButtonColor = true, BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 62})
                        Util.newInstance("UICorner", {Parent = opt})
                        Util.newInstance("UIPadding", {Parent = opt, PaddingLeft = UDim.new(0,12)})
                        local check = Util.newInstance("TextLabel", {Text = selected[v] and "✓" or "", Size = UDim2.new(0,28,1,0), Position = UDim2.new(1,-28,0,0), BackgroundTransparency = 1, Parent = row, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 63})
                        opt.MouseButton1Click:Connect(function()
                            selected[v] = not selected[v]
                            check.Text = selected[v] and "✓" or ""
                            updateDisplay()
                            if cb then pcall(cb, selected) end
                            if LIB._popupOverlay then pcall(function() LIB._popupOverlay:Destroy() end) LIB._popupOverlay = nil end
                        end)
                    end
                    local entries = #options
                    local h = math.clamp(entries * 32, 0, 32 * 6)
                    -- compute width from display button absolute size and position popup under it
                    local absPos = display.AbsolutePosition
                    local absSize = display.AbsoluteSize
                    local screenW = LIB.Screen.AbsoluteSize.X
                    local width = math.clamp(absSize.X, 120, math.max(120, screenW - absPos.X - 16))
                    listContainer.Size = UDim2.new(0, width, 0, h)
                    scroll.CanvasSize = UDim2.new(0,0,0, entries * 32)
                end

                display.MouseButton1Click:Connect(function()
                    -- explicit toggle
                    if listContainer.Visible then
                        listContainer.Visible = false
                        if LIB._popupOutsideConn then pcall(function() LIB._popupOutsideConn:Disconnect() end) LIB._popupOutsideConn = nil end
                        return
                    end

                    if LIB._popupOutsideConn then
                        pcall(function() LIB._popupOutsideConn:Disconnect() end)
                        LIB._popupOutsideConn = nil
                    end

                    rebuild()
                    -- position and show popup beneath the display control
                    local absPos = display.AbsolutePosition
                    local absSize = display.AbsoluteSize
                    local screenW = LIB.Screen.AbsoluteSize.X
                    local width = math.clamp(absSize.X, 120, math.max(120, screenW - absPos.X - 16))
                    listContainer.Size = UDim2.new(0, width, 0, listContainer.Size.Y.Offset)
                    listContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                    listContainer.Visible = true

                    task.defer(function()
                        if LIB._popupOutsideConn then pcall(function() LIB._popupOutsideConn:Disconnect() end) LIB._popupOutsideConn = nil end
                        LIB._popupOutsideConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local pos = listContainer.AbsolutePosition
                                local size = listContainer.AbsoluteSize
                                local mx, my = input.Position.X, input.Position.Y
                                if mx < pos.X or mx > pos.X + size.X or my < pos.Y or my > pos.Y + size.Y then
                                    listContainer.Visible = false
                                    if LIB._popupOutsideConn then LIB._popupOutsideConn:Disconnect() LIB._popupOutsideConn = nil end
                                end
                            end
                        end)
                    end)
                end)

                updateDisplay()
                return display
            end,
        }

        return section
    end

    return page
end

-- Select page
function SimpleUI:selectPage(page)
    for _,p in pairs(self.Pages) do
        p.Frame.Visible = (p == page)
        p.Button.BackgroundColor3 = (p == page) and Theme.Panel or Theme.Background
    end
    self.Selected = page
end

-- Simple notification helper
function SimpleUI:notify(title, text, duration)
    duration = duration or 3
    local n = Util.newInstance("Frame", {Size = UDim2.new(0,260,0,64), Position = UDim2.new(0.5,-130,0.1,0), BackgroundColor3 = Theme.Panel, Parent = self.Screen})
    Util.newInstance("UICorner", {Parent = n})
    Util.newInstance("TextLabel", {Text = title, Size = UDim2.new(1,-12,0,22), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1, Parent = n, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16})
    Util.newInstance("TextLabel", {Text = text, Size = UDim2.new(1,-12,0,30), Position = UDim2.new(0,6,0,28), BackgroundTransparency = 1, Parent = n, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 14, TextWrapped = true})
    Util.tween(n, {Size = UDim2.new(0,260,0,64)}, 0.18)
    delay(duration, function() Util.tween(n, {Size = UDim2.new(0,0,0,0)}, 0.18) task.wait(0.2) pcall(function() n:Destroy() end) end)
end

-- Return module table
return SimpleUI
