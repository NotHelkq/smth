local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local DefaultUISize = UDim2.new(0, 800, 0, 450)
local ThemeColor = Color3.fromRGB(125, 125, 125)

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
			properties.ImageTransparency = targetTransparency == 1 and 1 or origImg
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
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	mainFrame.Parent = container

	Instance.new("UICorner", mainFrame)

	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = mainFrame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 200, 0)),
		ColorSequenceKeypoint.new(0.07, Color3.fromRGB(255, 180, 0)),
		ColorSequenceKeypoint.new(0.14, Color3.fromRGB(255, 160, 0)),
		ColorSequenceKeypoint.new(0.21, Color3.fromRGB(255, 140, 0)),
		ColorSequenceKeypoint.new(0.28, Color3.fromRGB(255, 120, 0)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 100, 0)),
		ColorSequenceKeypoint.new(0.42, Color3.fromRGB(255, 80, 0)),
		ColorSequenceKeypoint.new(0.49, Color3.fromRGB(255, 60, 0)),
		ColorSequenceKeypoint.new(0.56, Color3.fromRGB(255, 40, 0)),
		ColorSequenceKeypoint.new(0.63, Color3.fromRGB(255, 20, 0)),
		ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.77, Color3.fromRGB(255, 40, 0)),
		ColorSequenceKeypoint.new(0.84, Color3.fromRGB(255, 80, 0)),
		ColorSequenceKeypoint.new(0.91, Color3.fromRGB(255, 120, 0)),
		ColorSequenceKeypoint.new(0.98, Color3.fromRGB(255, 160, 0)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 200, 0))
	})
	gradient.Rotation = -180
	gradient.Parent = stroke

	local line1 = Instance.new("Frame")
	line1.Name = "line1"
	line1.Position = UDim2.new(0, 0, 0, 27)
	line1.Size = UDim2.new(1, 0, 0, 1)
	line1.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	line1.BorderSizePixel = 0
	line1.Parent = mainFrame

	local line2 = Instance.new("Frame")
	line2.Name = "line2"
	line2.Position = UDim2.new(0, 185, 0, 0)
	line2.Size = UDim2.new(0, 1, 1, 0)
	line2.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	line2.BorderSizePixel = 0
	line2.Parent = mainFrame

	local mainContent = Instance.new("Frame")
	mainContent.Name = "MainContent"
	mainContent.Position = UDim2.new(0, 187, 0, 28)
	mainContent.Size = UDim2.new(1, -188, 1, -29)
	mainContent.BackgroundTransparency = 1
	mainContent.BorderSizePixel = 0
	mainContent.Parent = mainFrame
	self.MainContent = mainContent

	local line3 = Instance.new("Frame")
	line3.Name = "line3"
	line3.Position = UDim2.new(0, 0, 0, 75)
	line3.Size = UDim2.new(0, 185, 0, 1)
	line3.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	line3.BorderSizePixel = 0
	line3.Parent = mainFrame

	local line4 = Instance.new("Frame")
	line4.Name = "line4"
	line4.Position = UDim2.new(0, 0, 1, -50)
	line4.Size = UDim2.new(0, 185, 0, 1)
	line4.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	line4.BorderSizePixel = 0
	line4.Parent = mainFrame

	local nameFrame = Instance.new("Frame")
	nameFrame.Name = "NameFrame"
	nameFrame.Position = UDim2.new(0, 1, 0, 28)
	nameFrame.Size = UDim2.new(0, 175, 0, 50)
	nameFrame.BackgroundTransparency = 1
	nameFrame.BorderSizePixel = 0
	nameFrame.Parent = mainFrame

	local nameText = Instance.new("TextLabel")
	nameText.Name = "NameText"
	nameText.Position = UDim2.new(0, 20, 0, 7)
	nameText.Size = UDim2.new(0, 162, 0, 20)
	nameText.BackgroundTransparency = 1
	nameText.TextColor3 = Color3.fromRGB(210, 210, 210)
	nameText.Text = title
	nameText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	nameText.TextSize = 17
	nameText.TextXAlignment = "Left"
	nameText.Parent = nameFrame

	local versionText = Instance.new("TextLabel")
	versionText.Name = "VersionText"
	versionText.Position = UDim2.new(0, 20, 0, 25)
	versionText.Size = UDim2.new(0, 162, 0, 15)
	versionText.BackgroundTransparency = 1
	versionText.TextColor3 = Color3.fromRGB(68, 68, 68)
	versionText.Text = ver
	versionText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	versionText.TextSize = 15
	versionText.TextXAlignment = "Left"
	versionText.Parent = nameFrame

	local playerFrame = Instance.new("Frame")
	playerFrame.Name = "PlayerFrame"
	playerFrame.Position = UDim2.new(0, 0, 1, -45)
	playerFrame.Size = UDim2.new(0, 175, 0, 45)
	playerFrame.BackgroundTransparency = 1
	playerFrame.BorderSizePixel = 0
	playerFrame.Parent = mainFrame

	local avatarIcon = Instance.new("ImageLabel")
	avatarIcon.Name = "AvatarIcon"
	avatarIcon.Position = UDim2.new(0, 10, 0.5, -2)
	avatarIcon.Size = UDim2.new(0, 35, 0, 35)
	avatarIcon.AnchorPoint = Vector2.new(0, 0.5)
	avatarIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	avatarIcon.Parent = playerFrame

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 8)
	avatarCorner.Parent = avatarIcon

	local displayNameText = Instance.new("TextLabel")
	displayNameText.Name = "DisplayName"
	displayNameText.Position = UDim2.new(0, 50, 0.5, -12)
	displayNameText.Size = UDim2.new(0, 120, 0, 20)
	displayNameText.AnchorPoint = Vector2.new(0, 0.5)
	displayNameText.BackgroundTransparency = 1
	displayNameText.TextColor3 = Color3.fromRGB(210, 210, 210)
	displayNameText.Text = LocalPlayer.DisplayName
	displayNameText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	displayNameText.TextSize = 14
	displayNameText.TextXAlignment = "Left"
	displayNameText.TextTruncate = Enum.TextTruncate.AtEnd
	displayNameText.Parent = playerFrame

	local usernameText = Instance.new("TextLabel")
	usernameText.Name = "Username"
	usernameText.Position = UDim2.new(0, 50, 0.5, 6)
	usernameText.Size = UDim2.new(0, 120, 0, 15)
	usernameText.AnchorPoint = Vector2.new(0, 0.5)
	usernameText.BackgroundTransparency = 1
	usernameText.TextColor3 = Color3.fromRGB(68, 68, 68)
	usernameText.Text = "@" .. LocalPlayer.Name
	usernameText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	usernameText.TextSize = 12
	usernameText.TextXAlignment = "Left"
	usernameText.TextTruncate = Enum.TextTruncate.AtEnd
	usernameText.Parent = playerFrame

	local function loadAvatar()
		local success, result = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
		if success and result then avatarIcon.Image = result
		else avatarIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png" end
	end
	loadAvatar()

	local toggleButton = Instance.new("ImageButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Position = UDim2.new(0, 160, 0, 12)
	toggleButton.Size = UDim2.new(0, 15, 0, 15)
	toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggleButton.BackgroundTransparency = 1
	toggleButton.Image = "rbxassetid://10723346959"
	toggleButton.ScaleType = Enum.ScaleType.Fit
	toggleButton.Parent = playerFrame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 4)
	toggleCorner.Parent = toggleButton

	local isHidden = false
	toggleButton.MouseButton1Click:Connect(function()
		isHidden = not isHidden
		if isHidden then
			displayNameText.Text = "Hidden"
			usernameText.Text = "@Hidden"
			toggleButton.Image = "rbxassetid://10723346871"
		else
			displayNameText.Text = LocalPlayer.DisplayName
			usernameText.Text = "@" .. LocalPlayer.Name
			toggleButton.Image = "rbxassetid://10723346959"
		end
	end)

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(0, 20, 0, 10)
	closeButton.Size = UDim2.new(0, 11, 0, 11)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	closeButton.BorderSizePixel = 0
	closeButton.Text = ""
	closeButton.AutoButtonColor = false
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(5, 0)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function() container:Destroy() end)

	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.AnchorPoint = Vector2.new(1, 0)
	minimizeButton.Position = UDim2.new(0, 40, 0, 10)
	minimizeButton.Size = UDim2.new(0, 11, 0, 11)
	minimizeButton.BackgroundColor3 = Color3.fromRGB(246, 193, 48)
	minimizeButton.BorderSizePixel = 0
	minimizeButton.Text = ""
	minimizeButton.AutoButtonColor = false
	minimizeButton.Parent = mainFrame

	local minimizeCorner = Instance.new("UICorner")
	minimizeCorner.CornerRadius = UDim.new(5, 0)
	minimizeCorner.Parent = minimizeButton

	minimizeButton.MouseButton1Click:Connect(function()
		Library:ToggleUI()
	end)

	local resizeButton = Instance.new("TextButton")
	resizeButton.Name = "ResizeButton"
	resizeButton.Position = UDim2.new(1, -2, 1, -2)
	resizeButton.Size = UDim2.new(0, -15, 0, -15)
	resizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	resizeButton.BackgroundTransparency = 0.75
	resizeButton.BorderSizePixel = 0
	resizeButton.Text = ""
	resizeButton.Parent = mainFrame

	local draggingResize = false
	local resizeOffset = Vector2.new()

	resizeButton.MouseButton1Down:Connect(function()
		draggingResize = true
		local mousePos = Vector2.new(Mouse.X, Mouse.Y)
		local frameBottomRight = mainFrame.AbsolutePosition + mainFrame.AbsoluteSize
		resizeOffset = frameBottomRight - mousePos

		while draggingResize do
			local x, y = Mouse.X, Mouse.Y
			local pos = mainFrame.AbsolutePosition

			local targetX = (x + resizeOffset.X) - pos.X
			local targetY = (y + resizeOffset.Y) - pos.Y

			if targetX >= 800 then
				mainFrame.Size = UDim2.new(0, targetX, 0, mainFrame.Size.Y.Offset)
			end

			if targetY >= 450 then
				mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, targetY)
			end

			DefaultUISize = mainFrame.Size
			RunService.RenderStepped:Wait()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingResize = false
		end
	end)

	task.spawn(function()
		local rotation = -180
		local step = 1
		local maxRotation = 180
		while true do
			if gradient and gradient.Parent then
				gradient.Rotation = rotation
				rotation = rotation + step
				if rotation > maxRotation then
					rotation = -180
				end
				task.wait(0.01)
			else break end
		end
	end)

	local scrollingFrameFrame = Instance.new("Frame")
	scrollingFrameFrame.Name = "SidebarFrame"
	scrollingFrameFrame.Position = UDim2.new(0, 2, 0, 85)
	scrollingFrameFrame.Size = UDim2.new(0, 175, 1, -139)
	scrollingFrameFrame.BackgroundTransparency = 1
	scrollingFrameFrame.BorderSizePixel = 0
	scrollingFrameFrame.Parent = mainFrame

	local sidebarScrollingFrame = Instance.new("ScrollingFrame")
	sidebarScrollingFrame.Name = "SidebarScrollingFrame"
	sidebarScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	sidebarScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	sidebarScrollingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	sidebarScrollingFrame.BackgroundTransparency = 1
	sidebarScrollingFrame.ScrollBarThickness = 1
	sidebarScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(32, 32, 32)
	sidebarScrollingFrame.ScrollBarImageTransparency = 1 
	sidebarScrollingFrame.BorderSizePixel = 0
	sidebarScrollingFrame.Parent = scrollingFrameFrame

	local sidebarListLayout = Instance.new("UIListLayout")
	sidebarListLayout.Padding = UDim.new(0, 5)
	sidebarListLayout.SortOrder = Enum.SortOrder.LayoutOrder 
	sidebarListLayout.Parent = sidebarScrollingFrame

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 5)
	sidebarPadding.PaddingLeft = UDim.new(0, 10)
	sidebarPadding.PaddingRight = UDim.new(0, 10)
	sidebarPadding.Parent = sidebarScrollingFrame

	local function updateSidebarScrolling()
		local totalHeight = sidebarListLayout.AbsoluteContentSize.Y
		sidebarScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

		if totalHeight > sidebarScrollingFrame.AbsoluteSize.Y + 5 then
			sidebarScrollingFrame.ScrollBarImageTransparency = 0
		else
			sidebarScrollingFrame.ScrollBarImageTransparency = 1
		end
	end

	sidebarListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarScrolling)

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Position = UDim2.new(0, 187, 0, 1)
	topbar.Size = UDim2.new(1, -188, 0, 26)
	topbar.BackgroundTransparency = 1
	topbar.BorderSizePixel = 0
	topbar.Parent = mainFrame

	local topbarText = Instance.new("TextLabel")
	topbarText.Position = UDim2.new(0, 0, 0, 0)
	topbarText.Size = UDim2.new(1, 0, 1, 0)
	topbarText.TextColor3 = Color3.fromRGB(125, 125, 125)
	topbarText.BackgroundTransparency = 1
	topbarText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	topbarText.TextSize = 17
	topbarText.Text = ""
	topbarText.Parent = topbar

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

	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Library.ToggleKey then
			Library:ToggleUI()
		end
	end)

	self.Container = container
	self.MainFrame = mainFrame
	self.SidebarScrollingFrame = sidebarScrollingFrame
	self.TopbarText = topbarText
	self.Utility = Utility
end

function Library:addPage(title, icon, isDefault)
	icon = icon or ""

	local pageButton = Instance.new("TextButton")
	pageButton.Name = title or "Page " .. (#self.Pages + 1)
	pageButton.Parent = self.SidebarScrollingFrame
	pageButton.Size = UDim2.new(1, 0, 0, 30)
	pageButton.Text = ""
	pageButton.AutoButtonColor = false
	pageButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	pageButton.LayoutOrder = #self.Pages + 1
	pageButton.BackgroundTransparency = #self.Pages == 0 and 0 or 1

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 5)
	sectionCorner.Parent = pageButton

	local sectionStroke = Instance.new("UIStroke")
	sectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	sectionStroke.Color = Color3.fromRGB(40, 40, 40)
	sectionStroke.Transparency = #self.Pages == 0 and 0 or 1 
	sectionStroke.Parent = pageButton

	local sectionText = Instance.new("TextLabel")
	sectionText.Name = "sectionText"
	if icon ~= "" then
		sectionText.Position = UDim2.new(0, 30, 0, 0)
		sectionText.Size = UDim2.new(1, -35, 1, 0)
	else
		sectionText.Position = UDim2.new(0, 10, 0, 0)
		sectionText.Size = UDim2.new(1, -15, 1, 0)
	end
	sectionText.Text = title
	sectionText.BackgroundTransparency = 1
	sectionText.TextXAlignment = "Left"
	sectionText.TextColor3 = #self.Pages == 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(125, 125, 125)
	sectionText.FontFace = Font.fromName("FredokaOne", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	sectionText.TextSize = 16
	sectionText.Parent = pageButton

	if icon ~= "" then
		local decalID = Instance.new("ImageLabel")
		decalID.Name = "ImageLabel"
		decalID.Position = UDim2.new(0, 5, 0, 5)
		decalID.Size = UDim2.new(0, 20, 0, 20)
		decalID.BackgroundTransparency = 1
		decalID.ImageTransparency = #self.Pages == 0 and 0 or 0.5
		decalID.Image = "rbxassetid://" .. icon
		decalID.ScaleType = Enum.ScaleType.Fit
		decalID.Parent = pageButton
	end

	local isFirstPage = #self.Pages == 0

	local pageContainer = Utility:Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = isFirstPage, 
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = self.MainContent
	})

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 5)
	pagePadding.PaddingLeft = UDim.new(0, 2.5)
	pagePadding.PaddingRight = UDim.new(0, 2.5)
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

	Instance.new("UIListLayout", leftCol).Padding = UDim.new(0, 5)
	Instance.new("UIListLayout", rightCol).Padding = UDim.new(0, 5)

	local pageData = {
		Button = pageButton,
		Stroke = sectionStroke,
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
		self.Utility:Tween(self.SelectedPage.Button, {BackgroundTransparency = 1}, 0.2)
		if self.SelectedPage.Stroke then
			self.Utility:Tween(self.SelectedPage.Stroke, {Transparency = 1}, 0.2)
		end

		local textLabel = self.SelectedPage.Button:FindFirstChild("sectionText")
		if textLabel then
			self.Utility:Tween(textLabel, {TextColor3 = Color3.fromRGB(125, 125, 125)}, 0.2)
		end

		self.SelectedPage.Container.Visible = false
	end

	self.SelectedPage = page

	if self.TopbarText then
		self.TopbarText.Text = page.Title
	end

	self.Utility:Tween(page.Button, {BackgroundTransparency = 0}, 0.2)
	if page.Stroke then
		self.Utility:Tween(page.Stroke, {Transparency = 0}, 0.2)
	end

	local textLabel = page.Button:FindFirstChild("sectionText")
	if textLabel then
		self.Utility:Tween(textLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
	end

	page.Container.Visible = true
end

function Library:PageAddSection(page, title, autoSize)
	page.SectionCount = page.SectionCount + 1
	local targetCol = (page.SectionCount % 2 == 1) and page.LeftCol or page.RightCol

	local layout = targetCol:FindFirstChildOfClass("UIListLayout")
	if layout then
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end

	local section = Instance.new("Frame")
	section.Name = title .. "Section"
	section.Parent = targetCol
	section.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	section.Size = UDim2.new(1, 0, 0, autoSize and 50 or 220)
	section.LayoutOrder = page.SectionCount

	local sectionCorner = Instance.new("UICorner")
	sectionCorner.CornerRadius = UDim.new(0, 5)
	sectionCorner.Parent = section

	local sectionStroke = Instance.new("UIStroke")
	sectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	sectionStroke.Color = Color3.fromRGB(45, 45, 45)
	sectionStroke.Parent = section

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -20, 0, 25)
	titleLabel.Position = UDim2.new(0, 10, 0, 2)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	titleLabel.FontFace = Font.fromName("FredokaOne")
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = "Left"
	titleLabel.Parent = section

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.new(0, 0, 0, 28)
	divider.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	divider.BorderSizePixel = 0
	divider.Parent = section

	local sectionScrolling = Instance.new("ScrollingFrame")
	sectionScrolling.Name = "SectionScrolling"
	sectionScrolling.Parent = section
	sectionScrolling.Position = UDim2.new(0, 0, 0, 30)
	sectionScrolling.Size = UDim2.new(1, 0, 1, -35)
	sectionScrolling.BackgroundTransparency = 1
	sectionScrolling.ScrollBarThickness = 2
	sectionScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)

	local sectionListLayout = Instance.new("UIListLayout")
	sectionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionListLayout.Padding = UDim.new(0, 4)
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

	function sectionData:addButton(text, callback)
		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		})

		local visualFrame = Utility:Create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 1,
			Parent = frame
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local btn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = visualFrame
		})

		btn.MouseButton1Down:Connect(function()
			Utility:Tween(visualFrame, {Size = UDim2.new(0.95, 0, 0.9, 0)}, 0.1)
		end)

		btn.MouseButton1Up:Connect(function()
			Utility:Tween(visualFrame, {Size = UDim2.new(1, 0, 1, 0)}, 0.1)
			if callback then pcall(callback) end
		end)

		btn.MouseLeave:Connect(function()
			Utility:Tween(visualFrame, {Size = UDim2.new(1, 0, 1, 0)}, 0.1)
		end)

		return frame
	end

	function sectionData:addToggle(text, default, callback)
		local toggled = default or false
		
		local btn = Utility:Create("TextButton", {
			Name = "Toggle",
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			TextXAlignment = "Left",
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			AutoButtonColor = false,
			Parent = sectionScrolling
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local switch = Utility:Create("Frame", {
			Size = UDim2.new(0, 30, 0, 16),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			Parent = btn
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local circle = Utility:Create("Frame", {
			Size = UDim2.new(0, 12, 0, 12),
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
				Utility:Tween(switch, {BackgroundColor3 = Color3.fromRGB(40, 200, 100)}, speed)
				Utility:Tween(circle, {Position = UDim2.new(1, -14, 0.5, 0)}, speed)
			else
				Utility:Tween(switch, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, speed)
				Utility:Tween(circle, {Position = UDim2.new(0, 2, 0.5, 0)}, speed)
			end
		end

		btn.MouseButton1Click:Connect(function()
			toggled = not toggled
			updateVisuals(true)
			if callback then pcall(callback, toggled) end
		end)

		updateVisuals(false)
		return btn
	end

	function sectionData:addSlider(text, min, max, default, callback)
		local value = default or min
		local dragging = false

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		}, {
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local valBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 35, 0, 18),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			TextColor3 = Color3.fromRGB(125, 125, 125),
			Text = tostring(value),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 12,
			ClearTextOnFocus = false,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local slideBar = Utility:Create("Frame", {
			Size = UDim2.new(0.3, 0, 0, 4),
			Position = UDim2.new(1, -50, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})
		
		local fill = Utility:Create("Frame", {
			Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(150, 150, 150),
			Parent = slideBar
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
		})

		local function updateVisuals(val)
			local percent = math.clamp((val - min) / (max - min), 0, 1)
			Utility:Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
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
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local labelContainer = Utility:Create("Frame", {
			Size = UDim2.new(1, -100, 0, 28),
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
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			LayoutOrder = 1,
			Parent = labelContainer
		})

		local selectedLabel = Utility:Create("TextLabel", {
			Text = selected,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			LayoutOrder = 2,
			Parent = labelContainer
		})

		local searchBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 80, 0, 20),
			Position = UDim2.new(1, -30, 0, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			ClearTextOnFocus = false,
			Text = "",
			PlaceholderText = "Search...",
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 12,
			ZIndex = 10,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45)})
		})

		local arrow = Utility:Create("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -10, 0, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6034818372",
			ImageColor3 = Color3.fromRGB(125, 125, 125),
			ZIndex = 7,
			Parent = frame
		})

		local triggerBtn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 6,
			Parent = frame
		})

		local optionScrolling = Utility:Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
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
			if open then Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 30 + targetHeight)}, 0.2) end
		end

		local function toggle(force)
			open = (force ~= nil) and force or not open
			optionScrolling.Visible = open
			if open then updateLayout() else Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2) end
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
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					Text = optText,
					TextColor3 = (selected == optText) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
					FontFace = Font.fromName("FredokaOne"),
					TextSize = 12,
					Parent = optionScrolling
				}, {
					Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
					Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
				})
				table.insert(optionButtons, btn)
				btn.MouseButton1Click:Connect(function()
					selected = optText
					selectedLabel.Text = optText
					for _, otherBtn in pairs(optionButtons) do
						otherBtn.TextColor3 = (otherBtn.Text == selected) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
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
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			ZIndex = 5,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local labelContainer = Utility:Create("Frame", {
			Size = UDim2.new(1, -100, 0, 28),
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
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			LayoutOrder = 1,
			Parent = labelContainer
		})

		local selectedCountLabel = Utility:Create("TextLabel", {
			Text = #selected .. " Selected",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			LayoutOrder = 2,
			Parent = labelContainer
		})

		local searchBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 80, 0, 20),
			Position = UDim2.new(1, -30, 0, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Text = "",
			PlaceholderText = "Search...",
			FontFace = Font.fromName("FredokaOne"),
			ClearTextOnFocus = false,
			TextSize = 12,
			ZIndex = 10,
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45)})
		})

		local arrow = Utility:Create("ImageLabel", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -10, 0, 14),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6034818372",
			ImageColor3 = Color3.fromRGB(125, 125, 125),
			ZIndex = 7,
			Parent = frame
		})

		local triggerBtn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 6,
			Parent = frame
		})

		local optionScrolling = Utility:Create("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
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
			if open then Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 30 + targetHeight)}, 0.2) end
		end

		local function toggle(force)
			open = (force ~= nil) and force or not open
			optionScrolling.Visible = open
			if open then updateLayout() else Utility:Tween(frame, {Size = UDim2.new(1, 0, 0, 28)}, 0.2) end
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
					Size = UDim2.new(1, 0, 0, 20),
					BackgroundTransparency = 1,
					Text = optText,
					TextColor3 = table.find(selected, optText) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150),
					FontFace = Font.fromName("FredokaOne"),
					TextSize = 12,
					Parent = optionScrolling
				}, {
					Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
					Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
				})
				table.insert(optionButtons, btn)
				btn.MouseButton1Click:Connect(function()
					local idx = table.find(selected, optText)
					if idx then table.remove(selected, idx) else table.insert(selected, optText) end
					btn.TextColor3 = table.find(selected, optText) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
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
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local label = Utility:Create("TextLabel", {
			Text = text,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		}, {
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local inputBox = Utility:Create("TextBox", {
			Size = UDim2.new(0, 100, 0, 18), 
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			TextColor3 = Color3.fromRGB(200, 200, 200),
			Text = "",
			PlaceholderText = placeholder or "Type...",
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 12,
			ClearTextOnFocus = false, 
			Parent = frame,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ClipsDescendants = true
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = Color3.fromRGB(55, 55, 55)})
		})

		inputBox.FocusLost:Connect(function(enterPressed)
			inputBox.TextXAlignment = Enum.TextXAlignment.Left
			
			if callback then 
				local success, err = pcall(callback, inputBox.Text, enterPressed)
				if not success then warn("Input Callback Error: " .. err) end
			end
		end)

		inputBox.Focused:Connect(function()
			if inputBox.Text ~= "" then
				inputBox.TextXAlignment = Enum.TextXAlignment.Right
			end
		end)

		inputBox:GetPropertyChangedSignal("Text"):Connect(function()
			if inputBox:IsFocused() then
				inputBox.TextXAlignment = Enum.TextXAlignment.Right
			end
		end)

		return frame
	end

	function sectionData:addLabel(text)
		local textService = game:GetService("TextService")
		
		local function calculateHeight(txt)
			local maxWidth = sectionScrolling.AbsoluteSize.X - 20
			local textSize = textService:GetTextSize(
				txt, 
				14, 
				Enum.Font.FredokaOne, 
				Vector2.new(maxWidth > 0 and maxWidth or 180, math.huge)
			)
			return math.max(30, textSize.Y + 12)
		end

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, calculateHeight(text)),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local label = Utility:Create("TextLabel", {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 7, 0, 0), 
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			TextWrapped = true,
			Parent = frame
		})

		local labelController = {}
		function labelController:SetText(newText)
			label.Text = tostring(newText)
			frame.Size = UDim2.new(1, 0, 0, calculateHeight(newText))
		end

		return labelController
	end

	function sectionData:addKeybind(text, default, callback)
		local binding = false
		local currentKey = default or Enum.KeyCode.F

		local frame = Utility:Create("Frame", {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = sectionScrolling
		}, {
			Utility:Create("UIStroke", {Color = Color3.fromRGB(45, 45, 45), ApplyStrokeMode = "Border"}),
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
		})

		local label = Utility:Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = text,
			TextColor3 = Color3.fromRGB(125, 125, 125),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 14,
			TextXAlignment = "Left",
			Parent = frame
		}, {
			Utility:Create("UIPadding", {PaddingLeft = UDim.new(0, 10)})
		})

		local keyBox = Utility:Create("Frame", {
			Size = UDim2.new(0, 40, 0, 18),
			Position = UDim2.new(1, -10, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			Parent = frame
		}, {
			Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
			Utility:Create("UIStroke", {Color = Color3.fromRGB(55, 55, 55)})
		})

		local keyLabel = Utility:Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = currentKey.Name,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			FontFace = Font.fromName("FredokaOne"),
			TextSize = 11,
			Parent = keyBox
		})

		local function updateKeyBox()
			local size = game:GetService("TextService"):GetTextSize(keyLabel.Text, keyLabel.TextSize, keyLabel.Font, Vector2.new(200, 18))
			keyBox.Size = UDim2.new(0, math.max(40, size.X + 16), 0, 18)
		end

		local btn = Utility:Create("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			Parent = frame
		})

		btn.MouseButton1Click:Connect(function()
			binding = true
			keyLabel.Text = "..."
			updateKeyBox()
		end)

		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if binding and input.UserInputType == Enum.UserInputType.Keyboard then
				currentKey = input.KeyCode
				keyLabel.Text = currentKey.Name
				binding = false
				updateKeyBox()
				if callback then pcall(callback, currentKey) end
			end
		end)

		updateKeyBox()
		return frame
	end

	function Library:ShowNotification(title, text, isError, callback)
		if tick() - self.LastNotifyTime < 2 then return end
		self.LastNotifyTime = tick()

		if self.ActiveNotification then self.ActiveNotification() end

		title = title or "Notification"
		text = text or ""

		local notification = Utility:Create("ImageLabel", {
			Name = "Notification",
			Parent = self.Container,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 60),
			Image = "rbxassetid://5028857472",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.25,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ZIndex = 3,
			ClipsDescendants = true
		}, {
			Utility:Create("ImageLabel", {
				Name = "Flash",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4641149554",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = 0.5,
				ZIndex = 5
			}),
			Utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.SourceSansSemibold, 
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = title
			}),
			Utility:Create("TextLabel", {
				Name = "Text",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 1, -24),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.Gotham, 
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = text
			}),
			Utility:Create("ImageButton", {
				Name = "Accept",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538259",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 4
			}),
			Utility:Create("ImageButton", {
				Name = "Decline",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 1, -24),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538583",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ZIndex = 4
			})
		})

		local padding = 10
		local textService = game:GetService("TextService")
		local textSize = textService:GetTextSize(text, 14, Enum.Font.Gotham, Vector2.new(math.huge, 16))

		notification.Position = self.LastNotificationPosition or UDim2.new(0, padding, 1, -70)
		notification.Size = UDim2.new(0, 0, 0, 60)

		Utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)

		task.spawn(function()
			task.wait(0.2)
			notification.ClipsDescendants = false
			Utility:Tween(notification.Flash, {Size = UDim2.new(0, 0, 0, 60), Position = UDim2.new(1, 0, 0, 0)}, 0.2)
		end)

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
			self.ActiveNotification = nil
		end

		self.ActiveNotification = close

		if not isError then
			task.delay(math.random(3, 8), function()
				if active then close() end
			end)
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

	table.insert(page.Sections, sectionData)

	task.spawn(function()
		wait(0.1)
	end)

	return sectionData
end

function Library.new(title, ver)
	Library:Init(title, ver)

	local minimizeButton = Library.MainFrame:FindFirstChild("MinimizeButton")
	if minimizeButton then
		minimizeButton.MouseButton1Click:Connect(function()
			Library:ToggleUI()
		end)
	end

	local window = {}

	window.addPage = function(self, title, icon, isDefault)
		return Library:addPage(title, icon, isDefault)
	end

	window.PageAddSection = function(self, page, title, autoSize)
		return Library:PageAddSection(page, title, autoSize)
	end

	window.SelectPage = function(self, page)
		return Library:SelectPage(page)
	end

	window.Container = Library.Container
	window.MainFrame = Library.MainFrame

	return window
end

return Library
