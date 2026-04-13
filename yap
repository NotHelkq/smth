local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local DefaultUISize = UDim2.new(0, 850, 0, 500)
local AccentColor = Color3.fromRGB(0, 200, 255) -- Cyan accent

local Utility = {}
function Utility:Tween(instance, properties, duration, ...)
	local tweenInfo = TweenInfo.new(duration or 0.2, ...)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Utility:Create(className, properties, children)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		instance[property] = value
	end
	if children then
		for _, child in pairs(children) do
			if type(child) == "table" then
				local childInstance = self:Create(child[1], child[2], child[3])
				childInstance.Parent = instance
			else
				child.Parent = instance
			end
		end
	end
	return instance
end

function Utility:PopEffect(button)
	local clone = button:Clone()
	clone.Name = "Ripple"
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.new(0.5, 0, 0.5, 0)
	clone.BackgroundTransparency = 0.5
	clone.Parent = button
	clone:ClearAllChildren()

	if clone:FindFirstChildWhichIsA("UIStroke") then clone:FindFirstChildWhichIsA("UIStroke"):Destroy() end
	if clone:FindFirstChildWhichIsA("UICorner") then clone:FindFirstChildWhichIsA("UICorner"):Destroy() end

	clone.Size = UDim2.new(1, 0, 1, 0)
	Utility:Tween(clone, {Size = UDim2.new(1.5, 0, 1.5, 0), BackgroundTransparency = 1}, 0.3)

	task.delay(0.3, function() clone:Destroy() end)
end

local Library = {
	Pages = {},
	SelectedPage = nil,
	ActiveNotification = nil,
	ToggleKey = Enum.KeyCode.RightControl,
	LastNotifyTime = 0,
	IsAnimating = false
}

function Library:ToggleUI()
	if self.IsAnimating then return end
	self.IsAnimating = true

	local mainFrame = self.MainFrame
	local container = self.Container
	local isOpening = not container.Enabled

	local function applyFade(obj, targetTransparency, duration)
		local properties = {}

		local isSidebar = obj:IsDescendantOf(self.SidebarScrollingFrame)
		local origBG = obj:GetAttribute("OriginalBackgroundTransparency") or 0
		local origText = obj:GetAttribute("OriginalTextTransparency") or 0
		local origStroke = obj:GetAttribute("OriginalTransparency") or 0

		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			properties.TextTransparency = targetTransparency == 1 and 1 or origText
		end

		if obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			if isSidebar and (obj:IsA("TextButton")) then
				local isSelected = (self.SelectedPage and self.SelectedPage.Button == obj)
				properties.BackgroundTransparency = (targetTransparency == 1 or not isSelected) and 1 or 0
			else
				properties.BackgroundTransparency = targetTransparency == 1 and 1 or origBG
			end
		end

		if obj:IsA("UIStroke") then
			if isSidebar then
				local btn = obj.Parent:IsA("TextButton") and obj.Parent
				local isSelected = (self.SelectedPage and self.SelectedPage.Button == btn)
				properties.Transparency = (targetTransparency == 1 or not isSelected) and 1 or 0
			else
				properties.Transparency = targetTransparency == 1 and 1 or origStroke
			end
		end

		if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			local origImg = obj:GetAttribute("OriginalImageTransparency") or 0
			
			if isSidebar then
				local btn = obj:FindFirstAncestorOfClass("TextButton")
				local isSelected = (self.SelectedPage and self.SelectedPage.Button == btn)
				properties.ImageTransparency = targetTransparency == 1 and 1 or (isSelected and 0 or 0.5)
			else
				properties.ImageTransparency = targetTransparency == 1 and 1 or origImg
			end
		end

		if next(properties) then
			self.Utility:Tween(obj, properties, duration)
		end
	end

	for _, v in pairs(mainFrame:GetDescendants()) do
		if not v:GetAttribute("HasSnapshot") then
			if v:IsA("Frame") or v:IsA("ScrollingFrame") or v:IsA("TextButton") or v:IsA("TextBox") then
				v:SetAttribute("OriginalBackgroundTransparency", v.BackgroundTransparency)
			end
			if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
				v:SetAttribute("OriginalTextTransparency", v.TextTransparency)
			end
			if v:IsA("UIStroke") then
				v:SetAttribute("OriginalTransparency", v.Transparency)
			end
			if v:IsA("ImageLabel") or v:IsA("ImageButton") then
				v:SetAttribute("OriginalImageTransparency", v.ImageTransparency)
			end
			v:SetAttribute("HasSnapshot", true)
		end
	end

	local currentSize = mainFrame.Size
	local currentPos = mainFrame.Position
	local closedSize = UDim2.new(0, currentSize.X.Offset * 0.9, 0, currentSize.Y.Offset * 0.9)
	local centerOffsetPos = UDim2.new(currentPos.X.Scale, currentPos.X.Offset + (currentSize.X.Offset * 0.05), currentPos.Y.Scale, currentPos.Y.Offset + (currentSize.Y.Offset * 0.05))

	if isOpening then
		mainFrame.Size = closedSize
		mainFrame.Position = centerOffsetPos

		for _, v in pairs(mainFrame:GetDescendants()) do
			if v:IsA("GuiObject") then
				if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then v.TextTransparency = 1 end
				if v:IsA("ImageLabel") or v:IsA("ImageButton") then v.ImageTransparency = 1 end
				v.BackgroundTransparency = 1
			elseif v:IsA("UIStroke") then
				v.Transparency = 1
			end
		end

		container.Enabled = true

		for _, v in pairs(mainFrame:GetDescendants()) do
			applyFade(v, 0, 0.4)
		end

		self.Utility:Tween(mainFrame, {Size = currentSize, Position = currentPos}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out).Completed:Wait()
	else
		local animDuration = 0.3
		for _, v in pairs(mainFrame:GetDescendants()) do
			applyFade(v, 1, animDuration)
		end

		local closeTween = self.Utility:Tween(mainFrame, {Size = closedSize, Position = centerOffsetPos}, animDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		closeTween.Completed:Wait()

		container.Enabled = false
		mainFrame.Size = currentSize
		mainFrame.Position = currentPos
	end

	self.IsAnimating = false
end

function Library:Init(title, ver)
	title = title or "Unknown Script"
	ver = ver or "Version : ???"

	local container = Instance.new("ScreenGui")
	container.Name = title
	container.Parent = game.CoreGui
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Global

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.AnchorPoint = Vector2.new(0, 0)
	mainFrame.Position = UDim2.new(0.5, -DefaultUISize.X.Offset/2, 0.5, -DefaultUISize.Y.Offset/2)
	mainFrame.Size = DefaultUISize
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.Parent = container

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Color = AccentColor
	stroke.Thickness = 2
	stroke.Transparency = 0.3
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = mainFrame

	-- Animated gradient for border
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, AccentColor),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
		ColorSequenceKeypoint.new(1.00, AccentColor)
	})
	gradient.Rotation = 0
	gradient.Parent = stroke

	-- Header bar
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	header.BackgroundTransparency = 0.2
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Size = UDim2.new(0, 200, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = "Left"
	titleLabel.Parent = header

	local versionLabel = Instance.new("TextLabel")
	versionLabel.Name = "Version"
	versionLabel.Position = UDim2.new(0, 15, 0, 20)
	versionLabel.Size = UDim2.new(0, 200, 0, 16)
	versionLabel.BackgroundTransparency = 1
	versionLabel.Text = ver
	versionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	versionLabel.Font = Enum.Font.Gotham
	versionLabel.TextSize = 12
	versionLabel.TextXAlignment = "Left"
	versionLabel.Parent = header

	-- Window controls
	local closeButton = Instance.new("ImageButton")
	closeButton.Name = "Close"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -10, 0, 10)
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.BackgroundTransparency = 1
	closeButton.Image = "rbxassetid://10747329282" -- X icon
	closeButton.ImageColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.Parent = header
	closeButton.MouseButton1Click:Connect(function() container:Destroy() end)

	local minimizeButton = Instance.new("ImageButton")
	minimizeButton.Name = "Minimize"
	minimizeButton.AnchorPoint = Vector2.new(1, 0)
	minimizeButton.Position = UDim2.new(1, -35, 0, 10)
	minimizeButton.Size = UDim2.new(0, 20, 0, 20)
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.Image = "rbxassetid://10747326624" -- Minimize icon
	minimizeButton.ImageColor3 = Color3.fromRGB(255, 200, 100)
	minimizeButton.Parent = header
	minimizeButton.MouseButton1Click:Connect(function() Library:ToggleUI() end)

	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Position = UDim2.new(0, 0, 0, 40)
	sidebar.Size = UDim2.new(0, 200, 1, -40)
	sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	sidebar.BackgroundTransparency = 0.3
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, 12)
	sidebarCorner.Parent = sidebar

	local sidebarScrolling = Instance.new("ScrollingFrame")
	sidebarScrolling.Name = "SidebarScrollingFrame"
	sidebarScrolling.Position = UDim2.new(0, 0, 0, 10)
	sidebarScrolling.Size = UDim2.new(1, 0, 1, -20)
	sidebarScrolling.BackgroundTransparency = 1
	sidebarScrolling.ScrollBarThickness = 2
	sidebarScrolling.ScrollBarImageColor3 = AccentColor
	sidebarScrolling.ScrollBarImageTransparency = 0.5
	sidebarScrolling.BorderSizePixel = 0
	sidebarScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
	sidebarScrolling.Parent = sidebar

	local sidebarListLayout = Instance.new("UIListLayout")
	sidebarListLayout.Padding = UDim.new(0, 8)
	sidebarListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarListLayout.Parent = sidebarScrolling

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 5)
	sidebarPadding.PaddingLeft = UDim.new(0, 10)
	sidebarPadding.PaddingRight = UDim.new(0, 10)
	sidebarPadding.Parent = sidebarScrolling

	local function updateSidebarScrolling()
		local totalHeight = sidebarListLayout.AbsoluteContentSize.Y
		sidebarScrolling.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
		sidebarScrolling.ScrollBarImageTransparency = totalHeight > sidebarScrolling.AbsoluteSize.Y and 0.5 or 1
	end
	sidebarListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScrolling)

	-- Main content area
	local mainContent = Instance.new("Frame")
	mainContent.Name = "MainContent"
	mainContent.Position = UDim2.new(0, 200, 0, 40)
	mainContent.Size = UDim2.new(1, -200, 1, -40)
	mainContent.BackgroundTransparency = 1
	mainContent.BorderSizePixel = 0
	mainContent.Parent = mainFrame
	self.MainContent = mainContent

	-- Topbar for page title
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Position = UDim2.new(0, 200, 0, 40)
	topbar.Size = UDim2.new(1, -200, 0, 30)
	topbar.BackgroundTransparency = 1
	topbar.BorderSizePixel = 0
	topbar.Parent = mainFrame

	local topbarText = Instance.new("TextLabel")
	topbarText.Position = UDim2.new(0, 15, 0, 0)
	topbarText.Size = UDim2.new(1, -30, 1, 0)
	topbarText.TextColor3 = Color3.fromRGB(200, 200, 200)
	topbarText.BackgroundTransparency = 1
	topbarText.Font = Enum.Font.GothamSemibold
	topbarText.TextSize = 16
	topbarText.TextXAlignment = "Left"
	topbarText.Text = ""
	topbarText.Parent = topbar

	-- Dragging functionality
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	-- Toggle keybind
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Library.ToggleKey then
			Library:ToggleUI()
		end
	end)

	-- Gradient animation
	task.spawn(function()
		local rotation = 0
		while gradient and gradient.Parent do
			gradient.Rotation = rotation
			rotation = (rotation + 1) % 360
			task.wait(0.02)
		end
	end)

	self.Container = container
	self.MainFrame = mainFrame
	self.SidebarScrollingFrame = sidebarScrolling
	self.TopbarText = topbarText
	self.Utility = Utility
end

function Library:addPage(title, icon, isDefault)
	icon = icon or ""

	local pageButton = Utility:Create("TextButton", {
		Name = title,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Color3.fromRGB(35, 35, 40),
		BackgroundTransparency = #self.Pages == 0 and 0.5 or 0.8,
		Text = "",
		AutoButtonColor = false,
		Parent = self.SidebarScrollingFrame,
		LayoutOrder = #self.Pages + 1
	}, {
		Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Utility:Create("UIStroke", {
			Color = AccentColor,
			Transparency = #self.Pages == 0 and 0.3 or 0.8,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})
	})

	local iconLabel
	if icon ~= "" then
		iconLabel = Utility:Create("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. icon,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = #self.Pages == 0 and 0.2 or 0.5,
			ScaleType = Enum.ScaleType.Fit,
			Parent = pageButton
		})
	end

	local textLabel = Utility:Create("TextLabel", {
		Text = title,
		Position = icon ~= "" and UDim2.new(0, 40, 0, 0) or UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		TextColor3 = #self.Pages == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextXAlignment = "Left",
		Parent = pageButton
	})

	local pageContainer = Utility:Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = #self.Pages == 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = AccentColor,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.MainContent
	})

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 10)
	pagePadding.PaddingLeft = UDim.new(0, 10)
	pagePadding.PaddingRight = UDim.new(0, 10)
	pagePadding.Parent = pageContainer

	local leftCol = Instance.new("Frame")
	leftCol.Name = "Left"
	leftCol.Size = UDim2.new(0.5, -7.5, 1, 0)
	leftCol.Position = UDim2.new(0, 5, 0, 0)
	leftCol.BackgroundTransparency = 1
	leftCol.Parent = pageContainer

	local rightCol = Instance.new("Frame")
	rightCol.Name = "Right"
	rightCol.Position = UDim2.new(0.5, 2.5, 0, 0)
	rightCol.Size = UDim2.new(0.5, -7.5, 1, 0)
	rightCol.BackgroundTransparency = 1
	rightCol.Parent = pageContainer

	Instance.new("UIListLayout", leftCol).Padding = UDim.new(0, 8)
	Instance.new("UIListLayout", rightCol).Padding = UDim.new(0, 8)

	local pageData = {
		Button = pageButton,
		Container = pageContainer,
		LeftCol = leftCol,
		RightCol = rightCol,
		Title = title,
		Sections = {},
		SectionCount = 0
	}

	table.insert(self.Pages, pageData)

	pageButton.MouseButton1Click:Connect(function()
		self:SelectPage(pageData)
	end)

	if isDefault or #self.Pages == 1 then
		self:SelectPage(pageData)
	end

	return pageData
end

function Library:SelectPage(page)
	if self.SelectedPage == page then return end

	if self.SelectedPage then
		self.Utility:Tween(self.SelectedPage.Button, {BackgroundTransparency = 0.8}, 0.2)
		if self.SelectedPage.Button:FindFirstChild("UIStroke") then
			self.Utility:Tween(self.SelectedPage.Button.UIStroke, {Transparency = 0.8}, 0.2)
		end
		local textLabel = self.SelectedPage.Button:FindFirstChildOfClass("TextLabel")
		if textLabel then
			self.Utility:Tween(textLabel, {TextColor3 = Color3.fromRGB(180, 180, 180)}, 0.2)
		end
		local iconLabel = self.SelectedPage.Button:FindFirstChild("ImageLabel")
		if iconLabel then
			self.Utility:Tween(iconLabel, {ImageTransparency = 0.5}, 0.2)
		end
		self.SelectedPage.Container.Visible = false
	end

	self.SelectedPage = page

	if self.TopbarText then
		self.TopbarText.Text = page.Title
	end

	self.Utility:Tween(page.Button, {BackgroundTransparency = 0.5}, 0.2)
	if page.Button:FindFirstChild("UIStroke") then
		self.Utility:Tween(page.Button.UIStroke, {Transparency = 0.3}, 0.2)
	end
	local textLabel = page.Button:FindFirstChildOfClass("TextLabel")
	if textLabel then
		self.Utility:Tween(textLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
	end
	local iconLabel = page.Button:FindFirstChild("ImageLabel")
	if iconLabel then
		self.Utility:Tween(iconLabel, {ImageTransparency = 0.2}, 0.2)
	end

	page.Container.Visible = true
end

function Library:PageAddSection(page, title, autoSize)
	page.SectionCount = page.SectionCount + 1
	local targetCol = (page.SectionCount % 2 == 1) and page.LeftCol or page.RightCol

	local section = Utility:Create("Frame", {
		Name = title .. "Section",
		Size = UDim2.new(1, 0, 0, autoSize and 50 or 220),
		BackgroundColor3 = Color3.fromRGB(30, 30, 35),
		BackgroundTransparency = 0.3,
		Parent = targetCol,
		LayoutOrder = page.SectionCount
	}, {
		Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Utility:Create("UIStroke", {
			Color = AccentColor,
			Transparency = 0.7,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		})
	})

	local titleLabel = Utility:Create("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, -20, 0, 25),
		Position = UDim2.new(0, 10, 0, 5),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = "Left",
		Parent = section
	})

	local sectionScrolling = Utility:Create("ScrollingFrame", {
		Name = "SectionScrolling",
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 1, -35),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = AccentColor,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = section
	})

	local sectionListLayout = Instance.new("UIListLayout")
	sectionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionListLayout.Padding = UDim.new(0, 6)
	sectionListLayout.Parent = sectionScrolling

	local sectionPadding = Instance.new("UIPadding")
	sectionPadding.PaddingTop = UDim.new(0, 5)
	sectionPadding.PaddingBottom = UDim.new(0, 5)
	sectionPadding.PaddingLeft = UDim.new(0, 5)
	sectionPadding.PaddingRight = UDim.new(0, 5)
	sectionPadding.Parent = sectionScrolling

	local function updateSize()
		local contentHeight = sectionListLayout.AbsoluteContentSize.Y
		sectionScrolling.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
		if autoSize then
			section.Size = UDim2.new(1, 0, 0, contentHeight + 45)
		end
		local hL = page.LeftCol.UIListLayout.AbsoluteContentSize.Y
		local hR = page.RightCol.UIListLayout.AbsoluteContentSize.Y
		page.Container.CanvasSize = UDim2.new(0, 0, 0, math.max(hL, hR) + 20)
	end
	sectionListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

	local sectionData = {
		ScrollingFrame = sectionScrolling,
		Container = section
	}

	-- ============== ELEMENT METHODS ==============

	function sectionData:addButton(text, callback)
		local btn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = AccentColor,
			BackgroundTransparency = 0.8,
			Text = text,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		btn.MouseButton1Down:Connect(function()
			Utility:Tween(btn, {BackgroundTransparency = 0.6}, 0.1)
		end)
		btn.MouseButton1Up:Connect(function()
			Utility:Tween(btn, {BackgroundTransparency = 0.8}, 0.1)
			if callback then pcall(callback) end
		end)
		btn.MouseLeave:Connect(function()
			Utility:Tween(btn, {BackgroundTransparency = 0.8}, 0.1)
		end)

		return btn
	end

	function sectionData:addToggle(text, default, callback)
		local toggled = default or false

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		})

		local btn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			Text = text,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextXAlignment = "Left",
			Font = Enum.Font.Gotham,
			TextSize = 14,
			AutoButtonColor = false,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}),
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local switch = Utility:Create("Frame", {
			Size = UDim2.new(0, 36, 0, 18),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(50, 50, 55),
			Parent = btn
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local circle = Utility:Create("Frame", {
			Size = UDim2.new(0, 14, 0, 14),
			Position = UDim2.new(0, 2, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = switch
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local function updateVisuals(animate)
			local speed = animate and 0.2 or 0
			if toggled then
				Utility:Tween(switch, {BackgroundColor3 = AccentColor}, speed)
				Utility:Tween(circle, {Position = UDim2.new(1, -16, 0.5, 0)}, speed)
			else
				Utility:Tween(switch, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}, speed)
				Utility:Tween(circle, {Position = UDim2.new(0, 2, 0.5, 0)}, speed)
			end
		end

		btn.MouseButton1Click:Connect(function()
			toggled = not toggled
			updateVisuals(true)
			if callback then pcall(callback, toggled) end
		end)

		updateVisuals(false)
		return frame
	end

	function sectionData:addSlider(text, min, max, default, callback)
		local value = default or min
		local dragging = false

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.new(0, 10, 0, 5),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		})

		local valBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 40, 0, 18),
			Position = UDim2.new(1, -10, 0, 5),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = tostring(value),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			ClearTextOnFocus = false,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5})
		})

		local slideBar = Utility:Create("Frame", {
			Size = UDim2.new(1, -20, 0, 6),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundColor3 = Color3.fromRGB(40, 40, 45),
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local fill = Utility:Create("Frame", {
			Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
			BackgroundColor3 = AccentColor,
			Parent = slideBar
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local thumb = Utility:Create("Frame", {
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new((value-min)/(max-min), -6, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = slideBar
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
			Utility:Create("UIStroke", {Color = AccentColor})
		})

		local function updateVisuals(val)
			local percent = math.clamp((val - min) / (max - min), 0, 1)
			fill.Size = UDim2.new(percent, 0, 1, 0)
			thumb.Position = UDim2.new(percent, 0, 0.5, 0)
			valBox.Text = tostring(val)
		end

		valBox.FocusLost:Connect(function()
			local newValue = tonumber(valBox.Text)
			if newValue then
				value = math.clamp(math.floor(newValue), min, max)
				updateVisuals(value)
				if callback then pcall(callback, value) end
			else
				valBox.Text = tostring(value)
			end
		end)

		local function update(input)
			local percent = math.clamp((input.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
			value = math.floor(min + (max - min) * percent)
			updateVisuals(value)
			if callback then pcall(callback, value) end
		end

		slideBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				update(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				update(input)
			end
		end)

		return frame
	end

	function sectionData:addDropdown(text, options, default, callback)
		local open = false
		local initial = default or options[1]
		local selected = type(initial) == "function" and "None" or tostring(initial)
		local optionButtons = {}

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			ClipsDescendants = true,
			ZIndex = 5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local labelContainer = Utility:Create("Frame", {
			Size = UDim2.new(1, -100, 0, 32),
			BackgroundTransparency = 1,
			Parent = frame
		}, {
			Utility:Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local label = Utility:Create("TextLabel", {
			Text = text .. ":",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			LayoutOrder = 1,
			Parent = labelContainer
		})

		local selectedLabel = Utility:Create("TextLabel", {
			Text = selected,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = AccentColor,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			LayoutOrder = 2,
			Parent = labelContainer
		})

		local searchBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 80, 0, 20),
			Position = UDim2.new(1, -30, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "",
			PlaceholderText = "Search...",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			ClearTextOnFocus = false,
			ZIndex = 10,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5})
		})

		local arrow = Utility:Create("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6034818372",
			ImageColor3 = AccentColor,
			ZIndex = 7,
			Parent = frame
		})

		local triggerBtn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 6,
			Parent = frame
		})

		local optionScrolling = Utility:Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = AccentColor,
			Visible = false,
			Parent = frame
		}, {
			Utility:Create("UIListLayout", {SortOrder = "LayoutOrder", Padding = UDim.new(0, 4)}),
			Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
		})

		local dpController = {}

		local function updateLayout()
			local visibleCount = 0
			for _, b in pairs(optionButtons) do if b.Visible then visibleCount = visibleCount + 1 end end
			local targetHeight = math.min(visibleCount, 5.5) * 24
			optionScrolling.Size = UDim2.new(1, 0, 0, targetHeight)
			optionScrolling.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 24)
			if open then Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 32 + targetHeight)}, 0.2) end
		end

		local function toggle(force)
			open = (force ~= nil) and force or not open
			optionScrolling.Visible = open
			if open then updateLayout() else Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2) end
			Utility:Tween(arrow, {Rotation = open and 180 or 0}, 0.2)
		end

		triggerBtn.MouseButton1Click:Connect(toggle)
		searchBox.Focused:Connect(function() toggle(true) end)

		function dpController:Refresh(newList)
			for _, b in pairs(optionButtons) do b:Destroy() end
			table.clear(optionButtons)
			for _, opt in pairs(newList) do
				local optText = tostring(opt)
				local btn = Utility:Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundColor3 = Color3.fromRGB(40, 40, 45),
					BackgroundTransparency = 0.5,
					Text = optText,
					TextColor3 = (selected == optText) and AccentColor or Color3.fromRGB(180, 180, 180),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					Parent = optionScrolling
				}, {
					Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
				})
				table.insert(optionButtons, btn)
				btn.MouseButton1Click:Connect(function()
					selected = optText
					selectedLabel.Text = optText
					for _, otherBtn in pairs(optionButtons) do
						otherBtn.TextColor3 = (otherBtn.Text == selected) and AccentColor or Color3.fromRGB(180, 180, 180)
					end
					toggle(false)
					if callback then pcall(callback, opt) end
				end)
			end
			updateLayout()
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = searchBox.Text:lower()
			for _, b in pairs(optionButtons) do b.Visible = b.Text:lower():find(q) ~= nil end
			updateLayout()
		end)

		dpController:Refresh(options)
		return dpController
	end

	function sectionData:addMultiDropdown(text, options, default, callback)
		local open = false
		local selected = type(default) == "table" and default or {}
		local optionButtons = {}
		for i, v in pairs(selected) do selected[i] = tostring(v) end

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			ClipsDescendants = true,
			ZIndex = 5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local labelContainer = Utility:Create("Frame", {
			Size = UDim2.new(1, -100, 0, 32),
			BackgroundTransparency = 1,
			Parent = frame
		}, {
			Utility:Create("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local label = Utility:Create("TextLabel", {
			Text = text .. ":",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			LayoutOrder = 1,
			Parent = labelContainer
		})

		local selectedCountLabel = Utility:Create("TextLabel", {
			Text = #selected .. " Selected",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = AccentColor,
			Font = Enum.Font.GothamSemibold,
			TextSize = 14,
			LayoutOrder = 2,
			Parent = labelContainer
		})

		local searchBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 80, 0, 20),
			Position = UDim2.new(1, -30, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "",
			PlaceholderText = "Search...",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			ClearTextOnFocus = false,
			ZIndex = 10,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5})
		})

		local arrow = Utility:Create("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6034818372",
			ImageColor3 = AccentColor,
			ZIndex = 7,
			Parent = frame
		})

		local triggerBtn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 6,
			Parent = frame
		})

		local optionScrolling = Utility:Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = AccentColor,
			Visible = false,
			Parent = frame
		}, {
			Utility:Create("UIListLayout", {SortOrder = "LayoutOrder", Padding = UDim.new(0, 4)}),
			Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 5)})
		})

		local mdpController = {}

		local function updateLayout()
			local visibleCount = 0
			for _, b in pairs(optionButtons) do if b.Visible then visibleCount = visibleCount + 1 end end
			local targetHeight = math.min(visibleCount, 5.5) * 24
			optionScrolling.Size = UDim2.new(1, 0, 0, targetHeight)
			optionScrolling.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 24)
			if open then Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 32 + targetHeight)}, 0.2) end
		end

		local function toggle(force)
			open = (force ~= nil) and force or not open
			optionScrolling.Visible = open
			if open then updateLayout() else Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 32)}, 0.2) end
			Utility:Tween(arrow, {Rotation = open and 180 or 0}, 0.2)
		end

		triggerBtn.MouseButton1Click:Connect(toggle)
		searchBox.Focused:Connect(function() toggle(true) end)

		function mdpController:Refresh(newList)
			for _, b in pairs(optionButtons) do b:Destroy() end
			table.clear(optionButtons)
			for _, opt in pairs(newList) do
				local optText = tostring(opt)
				local btn = Utility:Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundColor3 = Color3.fromRGB(40, 40, 45),
					BackgroundTransparency = 0.5,
					Text = optText,
					TextColor3 = table.find(selected, optText) and AccentColor or Color3.fromRGB(180, 180, 180),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					Parent = optionScrolling
				}, {
					Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
				})
				table.insert(optionButtons, btn)
				btn.MouseButton1Click:Connect(function()
					local idx = table.find(selected, optText)
					if idx then table.remove(selected, idx) else table.insert(selected, optText) end
					btn.TextColor3 = table.find(selected, optText) and AccentColor or Color3.fromRGB(180, 180, 180)
					selectedCountLabel.Text = #selected .. " Selected"
					if callback then pcall(callback, selected) end
				end)
			end
			updateLayout()
		end

		searchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = searchBox.Text:lower()
			for _, b in pairs(optionButtons) do b.Visible = b.Text:lower():find(q) ~= nil end
			updateLayout()
		end)

		mdpController:Refresh(options)
		return mdpController
	end

	function sectionData:addInput(text, placeholder, callback)
		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		})

		local inputBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 100, 0, 20),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "",
			PlaceholderText = placeholder or "Type...",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			ClearTextOnFocus = false,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5}),
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})
		})

		inputBox.FocusLost:Connect(function(enterPressed)
			if callback then pcall(callback, inputBox.Text, enterPressed) end
		end)

		return frame
	end

	function sectionData:addLabel(text)
		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local label = Utility:Create("TextLabel", {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = "Left",
			TextWrapped = true,
			Parent = frame
		})

		local labelController = {}
		function labelController:SetText(newText)
			label.Text = tostring(newText)
		end

		return labelController
	end

	function sectionData:addKeybind(text, default, callback)
		local binding = false
		local currentKey = default or Enum.KeyCode.F

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, -100, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		})

		local keyBox = Utility:Create("Frame", {
			Size = UDim2.new(0, 50, 0, 20),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5})
		})

		local keyLabel = Utility:Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = currentKey.Name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			Parent = keyBox
		})

		local btn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = frame
		})

		btn.MouseButton1Click:Connect(function()
			binding = true
			keyLabel.Text = "..."
		end)

		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if binding and input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				keyLabel.Text = currentKey.Name
				binding = false
				if callback then pcall(callback, currentKey) end
			end
		end)

		return frame
	end

	function sectionData:addColorPicker(text, default, callback)
		local color = default or Color3.fromRGB(255, 255, 255)
		local open = false
		local hue, sat, val = 0, 0, 1

		local function updateFromColor3(c)
			local r, g, b = c.R, c.G, c.B
			local minV, maxV = math.min(r, g, b), math.max(r, g, b)
			val = maxV
			local delta = maxV - minV
			if delta == 0 then
				hue, sat = 0, 0
			else
				sat = delta / maxV
				if r == maxV then
					hue = (g - b) / delta
				elseif g == maxV then
					hue = 2 + (b - r) / delta
				else
					hue = 4 + (r - g) / delta
				end
				hue = hue / 6
				if hue < 0 then hue = hue + 1 end
			end
		end
		updateFromColor3(color)

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(35, 35, 40),
			BackgroundTransparency = 0.5,
			ClipsDescendants = true,
			ZIndex = 5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {
				Color = AccentColor,
				Transparency = 0.7,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		})

		local preview = Utility:Create("Frame", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = color,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor})
		})

		local pickerFrame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 180),
			Position = UDim2.new(0, 0, 0, 32),
			BackgroundColor3 = Color3.fromRGB(30, 30, 35),
			Visible = false,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
			Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.5})
		})

		-- Hue slider
		local hueSlider = Utility:Create("Frame", {
			Size = UDim2.new(1, -20, 0, 15),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = pickerFrame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
					ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
					ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
				})
			})
		})

		local hueThumb = Utility:Create("Frame", {
			Size = UDim2.new(0, 6, 1, 4),
			Position = UDim2.new(hue, -3, 0, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = hueSlider
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
			Utility:Create("UIStroke", {Color = Color3.new(0,0,0)})
		})

		-- SV canvas
		local svCanvas = Utility:Create("Frame", {
			Size = UDim2.new(1, -20, 0, 100),
			Position = UDim2.new(0, 10, 0, 35),
			BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
			Parent = pickerFrame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Image = "rbxassetid://4155801252", -- white gradient
				ScaleType = Enum.ScaleType.Stretch,
				BackgroundTransparency = 1
			}),
			Utility:Create("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Image = "rbxassetid://4155801437", -- black gradient
				ScaleType = Enum.ScaleType.Stretch,
				BackgroundTransparency = 1
			})
		})

		local svPicker = Utility:Create("Frame", {
			Size = UDim2.new(0, 8, 0, 8),
			Position = UDim2.new(sat, -4, 1-val, -4),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = svCanvas
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
			Utility:Create("UIStroke", {Color = Color3.new(0,0,0)})
		})

		-- Hex input
		local hexInput = Utility:Create("TextBox", {
			Size = UDim2.new(0, 80, 0, 20),
			Position = UDim2.new(0, 10, 0, 145),
			BackgroundColor3 = Color3.fromRGB(25, 25, 30),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255),
			Font = Enum.Font.Gotham,
			TextSize = 12,
			Parent = pickerFrame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = AccentColor})
		})

		local function updateColor()
			color = Color3.fromHSV(hue, sat, val)
			preview.BackgroundColor3 = color
			svCanvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			hexInput.Text = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255)
			if callback then pcall(callback, color) end
		end

		local function updateSVFromPos(x, y)
			sat = math.clamp((x - svCanvas.AbsolutePosition.X) / svCanvas.AbsoluteSize.X, 0, 1)
			val = 1 - math.clamp((y - svCanvas.AbsolutePosition.Y) / svCanvas.AbsoluteSize.Y, 0, 1)
			svPicker.Position = UDim2.new(sat, -4, 1-val, -4)
			updateColor()
		end

		local draggingHue, draggingSV = false, false

		hueSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingHue = true
				local x = input.Position.X
				hue = math.clamp((x - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
				hueThumb.Position = UDim2.new(hue, -3, 0, -2)
				updateColor()
			end
		end)
		svCanvas.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSV = true
				updateSVFromPos(input.Position.X, input.Position.Y)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
				hue = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
				hueThumb.Position = UDim2.new(hue, -3, 0, -2)
				updateColor()
			elseif draggingSV and input.UserInputType == Enum.UserInputType.MouseMovement then
				updateSVFromPos(input.Position.X, input.Position.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingHue, draggingSV = false, false
			end
		end)

		hexInput.FocusLost:Connect(function()
			local hex = hexInput.Text:gsub("#", "")
			if #hex == 6 then
				local r = tonumber(hex:sub(1,2), 16) or 255
				local g = tonumber(hex:sub(3,4), 16) or 255
				local b = tonumber(hex:sub(5,6), 16) or 255
				color = Color3.fromRGB(r, g, b)
				updateFromColor3(color)
				svPicker.Position = UDim2.new(sat, -4, 1-val, -4)
				hueThumb.Position = UDim2.new(hue, -3, 0, -2)
				updateColor()
			end
		end)

		local triggerBtn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 2,
			Parent = frame
		})
		triggerBtn.MouseButton1Click:Connect(function()
			open = not open
			pickerFrame.Visible = open
			Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, open and 212 or 32)}, 0.2)
		end)

		return frame
	end

	table.insert(page.Sections, sectionData)
	return sectionData
end

function Library:ShowNotification(title, text, isError, callback)
	if tick() - self.LastNotifyTime < 2 then return end
	self.LastNotifyTime = tick()

	if self.ActiveNotification then self.ActiveNotification() end

	local notification = Utility:Create("Frame", {
		Name = "Notification",
		Parent = self.Container,
		BackgroundColor3 = Color3.fromRGB(20, 20, 25),
		BackgroundTransparency = 0.1,
		Size = UDim2.new(0, 0, 0, 70),
		Position = UDim2.new(1, -20, 1, -80),
		AnchorPoint = Vector2.new(1, 1),
		ZIndex = 10,
		ClipsDescendants = true
	}, {
		Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
		Utility:Create("UIStroke", {Color = AccentColor, Transparency = 0.3}),
		Utility:Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1, AccentColor)
			}),
			Transparency = NumberSequence.new(0.9),
			Rotation = 45
		}),
		Utility:Create("TextLabel", {
			Name = "Title",
			Position = UDim2.new(0, 15, 0, 10),
			Size = UDim2.new(1, -70, 0, 20),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextXAlignment = "Left",
			ZIndex = 11
		}),
		Utility:Create("TextLabel", {
			Name = "Text",
			Position = UDim2.new(0, 15, 0, 32),
			Size = UDim2.new(1, -70, 0, 28),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextXAlignment = "Left",
			TextWrapped = true,
			ZIndex = 11
		}),
		Utility:Create("ImageButton", {
			Name = "Accept",
			Position = UDim2.new(1, -50, 0, 12),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			Image = "rbxassetid://10747329282", -- Check/X? Using check icon: 7733962740
			ImageColor3 = Color3.fromRGB(100, 255, 100),
			ZIndex = 11
		}),
		Utility:Create("ImageButton", {
			Name = "Decline",
			Position = UDim2.new(1, -25, 0, 12),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			Image = "rbxassetid://10747329282",
			ImageColor3 = Color3.fromRGB(255, 100, 100),
			ZIndex = 11
		})
	})

	local textSize = game:GetService("TextService"):GetTextSize(text, 13, Enum.Font.Gotham, Vector2.new(200, 100))
	local width = math.max(250, math.min(350, textSize.X + 100))

	notification.Size = UDim2.new(0, 0, 0, 70)
	Utility:Tween(notification, {Size = UDim2.new(0, width, 0, 70)}, 0.3)

	local active = true
	local close = function()
		if not active then return end
		active = false
		Utility:Tween(notification, {Size = UDim2.new(0, 0, 0, 70), Position = notification.Position + UDim2.new(0, width, 0, 0)}, 0.3)
		task.wait(0.3)
		notification:Destroy()
		self.ActiveNotification = nil
	end

	self.ActiveNotification = close

	if not isError then
		task.delay(5, function() if active then close() end end)
	end

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

	return close
end

function Library.new(title, ver)
	Library:Init(title, ver)

	local window = {}
	window.addPage = function(self, title, icon, isDefault) return Library:addPage(title, icon, isDefault) end
	window.PageAddSection = function(self, page, title, autoSize) return Library:PageAddSection(page, title, autoSize) end
	window.SelectPage = function(self, page) return Library:SelectPage(page) end
	window.Container = Library.Container
	window.MainFrame = Library.MainFrame

	return window
end

return Library
