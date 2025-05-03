local UICorner = UICorner or function(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(radius, 0)
    corner.Parent = instance
end

local UIListLayout = UIListLayout or function(instance, padding)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding)
    layout.Parent = instance
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    return layout
end

local Library = {}
Library.__index = Library

function Library.CreateWindow(name)
    local self = setmetatable({}, Library)
    self.elements = {}
    self.open = true
    
    -- Main Window
    self.main = Instance.new("Frame")
    self.main.Name = name
    self.main.BackgroundColor3 = Color3.new(0, 0, 0)
    self.main.BorderSizePixel = 2
    self.main.BorderColor3 = Color3.new(1, 1, 1)
    self.main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.main.Size = UDim2.new(0, 300, 0, 400)
    UICorner(self.main, 0.1)
    
    -- Title Bar
    self.title = Instance.new("TextLabel")
    self.title.Text = name
    self.title.Size = UDim2.new(1, 0, 0, 30)
    self.title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    self.title.TextColor3 = Color3.new(1, 1, 1)
    self.title.Parent = self.main
    
    -- Close Button
    self.close = Instance.new("TextButton")
    self.close.Text = "X"
    self.close.Size = UDim2.new(0, 30, 0, 30)
    self.close.Position = UDim2.new(1, -30, 0, 0)
    self.close.BackgroundColor3 = Color3.new(0.8, 0, 0)
    self.close.TextColor3 = Color3.new(1, 1, 1)
    self.close.Parent = self.title
    UICorner(self.close, 0.1)
    
    -- Content Container
    self.container = Instance.new("Frame")
    self.container.BackgroundTransparency = 1
    self.container.Size = UDim2.new(1, -10, 1, -40)
    self.container.Position = UDim2.new(0, 5, 0, 35)
    self.container.Parent = self.main
    self.listLayout = UIListLayout(self.container, 5)
    
    -- Resize Handle
    self.resizeHandle = Instance.new("Frame")
    self.resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    self.resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    self.resizeHandle.BackgroundTransparency = 0.8
    self.resizeHandle.BackgroundColor3 = Color3.new(1, 1, 1)
    self.resizeHandle.Parent = self.main
    UICorner(self.resizeHandle, 0.2)
    
    -- Dragging Logic
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    self.title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Resize Logic
    local resizing
    local resizeStart
    local startSize
    
    self.resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = self.main.Size
        end
    end)
    
    self.resizeHandle.InputEnded:Connect(function(input)
        resizing = false
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newSize = UDim2.new(
                startSize.X.Scale,
                math.clamp(startSize.X.Offset + delta.X, 200, 600),
                startSize.Y.Scale,
                math.clamp(startSize.Y.Offset + delta.Y, 150, 800)
            )
            self.main.Size = newSize
            
            -- Update elements
            for _, element in pairs(self.elements) do
                element.Size = UDim2.new(1, -10, 0, element.AbsoluteSize.Y)
            end
        end
    end)
    
    -- Close Button Logic
    self.close.MouseButton1Click:Connect(function()
        self.main.Visible = false
        self.open = false
    end)
    
    return self
end

function Library:addButton(text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 35)
    button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = self.container
    UICorner(button, 0.1)
    
    table.insert(self.elements, button)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    return button
end

function Library:addToggle(text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -10, 0, 35)
    toggle.BackgroundTransparency = 1
    toggle.Parent = self.container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Parent = toggle
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    toggleButton.Text = ""
    UICorner(toggleButton, 0.1)
    toggleButton.Parent = toggle
    
    local state = default or false
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 20, 1, -4)
    toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
    toggleIndicator.BackgroundColor3 = state and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    UICorner(toggleIndicator, 0.1)
    toggleIndicator.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        toggleIndicator.BackgroundColor3 = state and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        toggleIndicator.Position = state and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
        
        if callback then
            callback(state)
        end
    end)
    
    table.insert(self.elements, toggle)
    return toggle
end

return Library
