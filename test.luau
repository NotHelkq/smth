local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

local utility = {}
local objects = {}
local themes = {
	Background = Color3.fromRGB(24, 24, 24),  
	Accent = Color3.fromRGB(10, 10, 10), 
	LightContrast = Color3.fromRGB(20, 20, 20), 
	DarkContrast = Color3.fromRGB(14, 14, 14),  
	TextColor = Color3.fromRGB(255, 255, 255)
}
local UISize = UDim2.new(0,800,0,450);

do
	--[[
		Creates a new Roblox instance with properties and children
		@param instance: string - Class name of instance to create
		@param properties: table - Properties to apply to the instance
		@param children: table - Child instances to parent to the new instance
		@return: Instance - The created instance
	]]
	function utility:Create(instance, properties, children)
		local object = Instance.new(instance)
		for i, v in pairs(properties or {}) do
			object[i] = v
			if typeof(v) == "Color3" then
				local theme = utility:Find(themes, v)
				if theme then
					objects[theme] = objects[theme] or {}
					objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})
					table.insert(objects[theme][i], object)
				end
			end
		end
		for i, module in pairs(children or {}) do
			module.Parent = object
		end
		return object
	end

	--[[
		Tweens an instance's properties over a duration
		@param instance: Instance - Instance to tween
		@param properties: table - Properties to animate with target values
		@param duration: number - Duration of the tween in seconds
		@param ...: any - Additional TweenInfo parameters
	]]
	function utility:Tween(instance, properties, duration, ...)
		tween:Create(instance, tweeninfo(duration, ...), properties):Play()
	end

	--[[
		Waits for the next RenderStepped event
		@return: boolean - Always returns true
	]]
	function utility:Wait()
		run.RenderStepped:Wait()
		return true
	end

	--[[
		Finds a key in a table that matches the given value
		@param table: table - Table to search
		@param value: any - Value to find
		@return: any - Key if found, otherwise nil
	]]
	function utility:Find(table, value) 
		for i, v in pairs(table) do
			if v == value then
				return i
			end
		end
	end

	--[[
		Filters values based on a pattern match
		@param pattern: string - Pattern to match (case-insensitive)
		@param values: table - Array of values to filter
		@return: table - Filtered array of values
	]]
	function utility:Sort(pattern, values)
		local new = {}
		pattern = pattern:lower()
		if pattern == "" then
			return values
		end
		for i, value in pairs(values) do
			if tostring(value):lower():find(pattern) then
				table.insert(new, value)
			end
		end
		return new
	end

	--[[
		Creates a pop animation effect on an object
		@param object: Instance - Object to animate
		@param shrink: number - Amount to shrink the clone by
		@return: Instance - Clone object used for animation
	]]
	function utility:Pop(object, shrink)
		local clone = object:Clone()
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)
		clone.Parent = object
		clone:ClearAllChildren()
		object.ImageTransparency = 1
		utility:Tween(clone, {Size = object.Size}, 0.2)
		spawn(function()
			wait(0.2)
			object.ImageTransparency = 0
			clone:Destroy()
		end)
		return clone
	end

	--[[
		Initializes the keybind system for handling keyboard inputs
	]]
	function utility:InitializeKeybind()
		self.keybinds = {}
		self.ended = {}
		input.InputBegan:Connect(function(key,proc)
			if self.keybinds[key.KeyCode] and not proc then
				for i, bind in pairs(self.keybinds[key.KeyCode]) do
					bind()
				end
			end
		end)
		input.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				for i, callback in pairs(self.ended) do
					callback()
				end
			end
		end)
	end

	--[[
		Binds a callback function to a specific key
		@param key: Enum.KeyCode - Key to bind to
		@param callback: function - Function to call when key is pressed
		@return: table - Table with UnBind method to remove binding
	]]
	function utility:BindToKey(key, callback)
		self.keybinds[key] = self.keybinds[key] or {}
		table.insert(self.keybinds[key], callback)
		return {
			UnBind = function()
				for i, bind in pairs(self.keybinds[key]) do
					if bind == callback then
						table.remove(self.keybinds[key], i)
					end
				end
			end
		}
	end

	--[[
		Waits for and returns the next keyboard key press
		@return: InputObject - The input object for the pressed key
	]]
	function utility:KeyPressed()
		local key = input.InputBegan:Wait()
		while key.UserInputType ~= Enum.UserInputType.Keyboard do
			key = input.InputBegan:Wait()
		end
		wait() 
		return key
	end

	--[[
		Enables dragging functionality for a frame
		@param frame: Instance - Frame to make draggable
		@param parent: Instance - Optional parent to move instead of frame
	]]
	function utility:DraggingEnabled(frame, parent)
		parent = parent or frame
		local dragging = false
		local dragInput, mousePos, framePos
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				mousePos = input.Position
				framePos = parent.Position
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
		input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
			end
		end)
	end

	--[[
		Registers a callback for when dragging ends
		@param callback: function - Function to call when dragging stops
	]]
	function utility:DraggingEnded(callback)
		table.insert(self.ended, callback)
	end
end

local library = {} 
local page = {}
local section = {}

do
	library.__index = library
	page.__index = page
	section.__index = section

	--[[
		Forces recalculation of UI layout for an instance
		@param instance: Instance - Instance to recalculate layout for
	]]
	function utility:ForceLayoutRecalculate(instance)
		local Layout = instance:FindFirstChildOfClass("UIListLayout") or instance:FindFirstChildOfClass("UIGridLayout")
		if Layout then
			Layout:ApplyLayout()
		end
		game:GetService("RunService").Heartbeat:Wait()
		game:GetService("RunService").Heartbeat:Wait()
	end

	--[[
		Creates a new library instance with a main UI container
		@param title: string - Title of the library window
		@return: table - New library object
	]]
	function library.new(title)
		local container = utility:Create("ScreenGui", {
			Name = title or "Random UI",
			Parent = game.CoreGui
		}, {
			utility:Create("Frame", {
				Name = "Main",
				Position = UDim2.new(0.25, 0, 0.052435593, 0),
				Size = UDim2.new(0, 800, 0, 450),
				BackgroundColor3 = themes.DarkContrast
			}, {
				utility:Create("UICorner"),
				utility:Create("UIStroke", {
					Color = themes.TextColor,
					Transparency = 0,
					Thickness = 2,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}),
				utility:Create("TextButton", {
					Name = "ResizeWindow",
					Position = UDim2.new(1,-2,1,-2),
					Size = UDim2.new(0,-15,0,-15),
					ZIndex = 5,
					BackgroundColor3 = Color3.fromRGB(0,0,0),
					BackgroundTransparency = 0.75,
					BorderSizePixel = 0,
					Text = ""
				}),
				utility:Create("Frame", {
					Name = "TopBar",
					ClipsDescendants = true,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 30),
					ZIndex = 5,
					BackgroundColor3 = themes.DarkContrast,
				},{
					utility:Create("UICorner"),
					utility:Create("TextLabel", {
						Name = "Title",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 5,
						Font = Enum.Font.SourceSansSemibold,
						Text = title or "Random UI",
						TextColor3 = themes.TextColor,
						TextSize = 16,
						TextXAlignment = Enum.TextXAlignment.Center
					})
				}),
				utility:Create("Frame", {
					Name = "Page",
					ClipsDescendants = true,
					Position = UDim2.new(0, 150, 0, 30),
					Size = UDim2.new(1, -150, 1, -30),
					BackgroundColor3 = themes.Background,
				},{
					utility:Create("UICorner"),
				}),
				utility:Create("Frame", {
					Name = "Sections",
					ClipsDescendants = true,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(0, 150, 1, -50),
					ZIndex = 2,
					BackgroundColor3 = themes.DarkContrast,
				}, {
					utility:Create("ScrollingFrame", {
						Active = true,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						CanvasSize = UDim2.new(0, 0, 0, 314),
						ScrollBarThickness = 0
					}, {
						utility:Create("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 10)
						})
					})
				})
			})
		})

		utility:InitializeKeybind()
		utility:DraggingEnabled(container.Main.TopBar, container.Main)

		local draggingResize
		container.Main.ResizeWindow.MouseButton1Down:Connect(function()
			draggingResize = true
			while draggingResize do
				local x, y = mouse.X-1, mouse.Y-1
				local pos = container.Main.AbsolutePosition
				local size = container.Main.AbsoluteSize
				if x-pos.X >= 500 then
					container.Main.Size = UDim2.new(0,x-pos.X,0,size.Y)
				end
				size = container.Main.AbsoluteSize
				if y-pos.Y >= 281 then
					container.Main.Size = UDim2.new(0,size.X,0,y-pos.Y)
				end
				UISize = UDim2.new(0, container.Main.AbsoluteSize.X, 0, container.Main.AbsoluteSize.Y)
				utility:Wait()
			end
		end)
		
		input.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingResize = false
			end
		end)		
		
		return setmetatable({
			container = container,
			pagesContainer = container.Main.Sections.ScrollingFrame,
			pages = {},
			selectedPage = nil 
		}, library)
	end

	--[[
		Creates a new page in the library
		@param library: table - The library instance
		@param title: string - Title of the page
		@param icon: string - Icon ID for the page
		@return: table - New page object
	]]
	function page.new(library, title, icon)
		icon = "rbxassetid://" .. tostring(icon)
		local button = utility:Create("TextButton", {
			Name = title,
			Parent = library.pagesContainer,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 3,
			AutoButtonColor = false,
			Font = Enum.Font.SourceSansSemibold,
			Text = "",
			TextSize = 16
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.22, 0, 0.5, 0),
				Size = UDim2.new(0.75, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.SourceSansSemibold,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.65,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Icon", 
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				ZIndex = 3,
				Image =  "rbxassetid://5012544693" or icon,
				ImageColor3 = themes.TextColor,
				ImageTransparency = 0.64
			})
		})

		local container = utility:Create("ScrollingFrame", {
			Name = title,
			Parent = library.container.Main.Page,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 5),
			Size = UDim2.new(1, 0, 1, -5),
			CanvasSize = UDim2.new(0, 0, 0, 466),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = themes.DarkContrast,
			Visible = false
		})

		local UIListLayout = container:FindFirstChildOfClass("UIListLayout")

		return setmetatable({
			library = library,
			container = container,
			button = button,
			sections = {},
			needsRefresh = true,
			UIListLayout = UIListLayout
		}, page)
	end

	--[[
		Creates a new section in a page
		@param page: table - The page instance
		@param title: string - Title of the section
		@return: table - New section object
	]]
	function section.new(page, title)
		local container = utility:Create("Frame", {
			Name = title,
			Parent = page.container,
			Size = UDim2.new(1, -10, 0, 28),
			ZIndex = 2,
			BackgroundColor3 = themes.LightContrast,
			ClipsDescendants = true
		}, {
			utility:Create("UICorner"),
			utility:Create("Frame", {
				Name = "Container",
				Active = true,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 8),
				Size = UDim2.new(1, -16, 1, -16)
			}, {
				utility:Create("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 2,
					Font = Enum.Font.SourceSansSemibold,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTransparency = 1
				}),
				utility:Create("ScrollingFrame", {
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 25),
					Size = UDim2.new(1, 0, 1, -25),
					CanvasSize = UDim2.new(0, 0, 0, 466),
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = themes.TextColor,
					ZIndex=5,
				},
				{
					utility:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				}),
			})
		})

		local scrollingFrame = container.Container.ScrollingFrame
		local UIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

		if UIListLayout then
			UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
			end)
		end
		
		return setmetatable({
			page = page,
			container = container.Container,
			scrollingFrame = scrollingFrame,
			UIListLayout = UIListLayout,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, section) 
	end

	--[[
		Adds a new page to the library
		@param title: string - Title of the page
		@param icon: string - Icon ID for the page
		@param isDefault: boolean - Whether this page should be selected by default
		@return: table - The created page
	]]
	function library:addPage(title, icon, isDefault)
		local page = page.new(self, title, icon)
		local button = page.button
	
		table.insert(self.pages, page)
	
		if isDefault or #self.pages == 1 then
			task.defer(function()
				for _ = 1, 3 do game:GetService("RunService").Heartbeat:Wait() end
				self:SelectPage(page, true)
			end)
		end
	
		button.MouseButton1Click:Connect(function()
			page.needsRefresh = true
			self:SelectPage(page, true)
		end)
	
		return page
	end

	--[[
		Waits for the next heartbeat event
		@return: boolean - Always returns true
	]]
	function utility:Wait()
    	return game:GetService("RunService").Heartbeat:Wait()
	end
	
	--[[
		Selects and displays a specific page
		@param selectedPage: table - The page to select
		@param instant: boolean - Whether to transition instantly
	]]
	function library:SelectPage(selectedPage, instant)
		if self.selectedPage then
			self.selectedPage.container.Visible = false
			utility:Tween(self.selectedPage.button.Title, {TextTransparency = 0.65}, instant and 0 or 0.2)
			utility:Tween(self.selectedPage.button.Icon, {ImageTransparency = 0.64}, instant and 0 or 0.2)
		end
	
		selectedPage.container.Visible = true
		
		if selectedPage.needsRefresh then
			game:GetService("RunService").Heartbeat:Wait()
			game:GetService("RunService").Heartbeat:Wait()
			
			if selectedPage.UIListLayout then
				utility:ForceLayoutRecalculate(selectedPage.container)
				selectedPage.container.CanvasSize = UDim2.new(
					0, 0,
					0, selectedPage.UIListLayout.AbsoluteContentSize.Y + 20
				)
			end
			
			for _, section in ipairs(selectedPage.sections) do
				if section.UIListLayout then
					utility:ForceLayoutRecalculate(section.scrollingFrame)
					section.scrollingFrame.CanvasSize = UDim2.new(
						0, 0,
						0, section.UIListLayout.AbsoluteContentSize.Y + 10
					)
				end
			end
			
			selectedPage.needsRefresh = false
		end
	
		utility:Tween(selectedPage.button.Title, {TextTransparency = 0}, instant and 0 or 0.2)
		utility:Tween(selectedPage.button.Icon, {ImageTransparency = 0}, instant and 0 or 0.2)
		
		self.selectedPage = selectedPage
	end

	--[[
		Adds a section to the page
		@param ...: any - Section parameters
		@return: table - The created section
	]]
	function page:addSection(...)
		local section = section.new(self, ...)
		table.insert(self.sections, section)
		
		self.needsRefresh = true
		
		if self.library.selectedPage == self then
			self.library:SelectPage(self, true)
		end
		
		return section
	end
	
	--[[
		Sets a theme color for the library
		@param theme: string - Theme property to change
		@param color3: Color3 - Color value to set
	]]
	function library:setTheme(theme, color3)
		themes[theme] = color3

		for property, objects in pairs(objects[theme]) do
			for i, object in pairs(objects) do
				if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
					objects[i] = nil 
				else
					object[property] = color3
				end
			end
		end
	end

	--[[
		Toggles the visibility of the library UI
	]]
	function library:toggle()
		if self.toggling then
			return
		end

		self.toggling = true

		local container = self.container.Main
		local topbar = container.TopBar

		if self.position then
			utility:Tween(container, {
				Size = UISize,
				Position = self.position
			}, 0.2)
			wait(0.2)

			utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
			wait(0.2)

			container.ClipsDescendants = false
			self.position = nil
		else
			self.position = container.Position
			container.ClipsDescendants = true

			utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
			wait(0.2)

			utility:Tween(container, {
				Size = UDim2.new(0, container.AbsoluteSize.X, 0, 0),
				Position = self.position + UDim2.new(0, 0, 0, 428)
			}, 0.2)
			wait(0.2)
		end

		self.toggling = false
	end

	--[[
		Displays a notification with title, text, and callback
		@param title: string - Notification title
		@param text: string - Notification content
		@param callback: function - Function to call when buttons are clicked
	]]
	function library:Notify(title, text, callback)
		if self.activeNotification then
			self.activeNotification = self.activeNotification()
		end

		local notification = utility:Create("ImageLabel", {
			Name = "Notification",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 60),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ZIndex = 3,
			ClipsDescendants = true
		}, {
			utility:Create("ImageLabel", {
				Name = "Flash",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4641149554",
				ImageColor3 = themes.TextColor,
				ZIndex = 5
			}),
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.SourceSansSemibold,
				TextColor3 = themes.TextColor,
				TextSize = 16.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextLabel", {
				Name = "Text",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 1, -24),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.Gotham,
				TextColor3 = themes.TextColor,
				TextSize = 14.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
				Name = "Accept",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538259",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			}),
			utility:Create("ImageButton", {
				Name = "Decline",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 1, -24),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			})
		})

		utility:DraggingEnabled(notification)

		title = title or "Notification"
		text = text or ""

		notification.Title.Text = title
		notification.Text.Text = text

		local padding = 10
		local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

		notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
		notification.Size = UDim2.new(0, 0, 0, 60)

		utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
		wait(0.2)

		notification.ClipsDescendants = false
		utility:Tween(notification.Flash, {
			Size = UDim2.new(0, 0, 0, 60),
			Position = UDim2.new(1, 0, 0, 0)
		}, 0.2)

		local active = true
		local close = function()

			if not active then
				return
			end

			active = false
			notification.ClipsDescendants = true

			library.lastNotification = notification.Position
			notification.Flash.Position = UDim2.new(0, 0, 0, 0)
			utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)

			wait(0.2)
			utility:Tween(notification, {
				Size = UDim2.new(0, 0, 0, 60),
				Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
			}, 0.2)

			wait(0.2)
			notification:Destroy()
		end

		self.activeNotification = close

		notification.Accept.MouseButton1Click:Connect(function()

			if not active then 
				return
			end

			if callback then
				callback(true)
			end

			close()
		end)

		notification.Decline.MouseButton1Click:Connect(function()

			if not active then 
				return
			end

			if callback then
				callback(false)
			end

			close()
		end)
	end

	--[[
		Adds a button to the section
		@param title: string - Button text
		@param callback: function - Function called on button click
		@return: Instance - Created button object
	]]
	function section:addButton(title, callback)
		local button = utility:Create("ImageButton", {
			Name = "Button",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012
			})
		})

		table.insert(self.modules, button)

		local text = button.Title
		local debounce

		button.MouseButton1Click:Connect(function()

			if debounce then
				return
			end

			utility:Pop(button, 10)

			debounce = true
			utility:Tween(button.Title, {TextSize = 12}, 0.1)
			wait(0.1)
			utility:Tween(button.Title, {TextSize = 14}, 0.1)

			if callback then
				callback(function(...)
					self:updateButton(button, ...)
				end)
			end

			debounce = false
		end)

		return button
	end

	--[[
		Adds a toggle to the section
		@param title: string - Toggle label
		@param default: boolean - Initial state
		@param callback: function - Function called on state change
		@return: Instance - Created toggle object
	]]
	function section:addToggle(title, default, callback)
		local toggle = utility:Create("ImageButton", {
			Name = "Toggle",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -50, 0.5, -8),
				Size = UDim2.new(0, 40, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ImageLabel", {
					Name = "Frame",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 2, 0.5, -6),
					Size = UDim2.new(1, -22, 1, -4),
					ZIndex = 2,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.TextColor,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			})
		})

		table.insert(self.modules, toggle)

		local active = default
		self:updateToggle(toggle, nil, active)
	
		if callback and default ~= nil then
			task.defer(function()
				pcall(callback, active)
			end)
		end
	
		toggle.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, nil, active)
			if callback then
				pcall(callback, active)
			end
		end)
	
		return toggle
	end

	--[[
		Adds a textbox to the section
		@param title: string - Textbox label
		@param default: string - Initial text
		@param callback: function - Function called on text change
		@return: Instance - Created textbox object
	]]
	function section:addTextbox(title, default, callback)
		local textbox = utility:Create("ImageButton", {
			Name = "Textbox",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "Textbox", 
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 5, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.SourceSansSemibold,
					Text = default or "",
					TextColor3 = themes.TextColor,
					TextSize = 14
				})
			})
		})

		table.insert(self.modules, textbox)

		local button = textbox.Button
		local input = button.Textbox

		textbox.MouseButton1Click:Connect(function()

			if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
				return
			end

			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 200, 0, 16),
				Position = UDim2.new(1, -210, 0.5, -8)
			}, 0.2)

			wait()

			input.TextXAlignment = Enum.TextXAlignment.Left
			input:CaptureFocus()
		end)

		input:GetPropertyChangedSignal("Text"):Connect(function()

			if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
				utility:Pop(button, 10)
			end

			if callback then
				callback(input.Text, nil, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)

		input.FocusLost:Connect(function()

			input.TextXAlignment = Enum.TextXAlignment.Center

			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 100, 0, 16),
				Position = UDim2.new(1, -110, 0.5, -8)
			}, 0.2)

			if callback then
				callback(input.Text, true, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)

		return textbox
	end

	--[[
		Adds a keybind to the section
		@param title: string - Keybind label
		@param default: Enum.KeyCode - Initial keybind
		@param callback: function - Function called when key is pressed
		@param changedCallback: function - Function called when keybind changes
		@return: Instance - Created keybind object
	]]
	function section:addKeybind(title, default, callback, changedCallback)
		local keybind = utility:Create("ImageButton", {
			Name = "Keybind",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					Name = "Text",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.SourceSansSemibold,
					Text = default and default.Name or "None",
					TextColor3 = themes.TextColor,
					TextSize = 14
				})
			})
		})

		table.insert(self.modules, keybind)

		local text = keybind.Button.Text
		local button = keybind.Button

		local animate = function()
			if button.ImageTransparency == 0 then
				utility:Pop(button, 10)
			end
		end

		self.binds[keybind] = {callback = function()
			animate()

			if callback then
				callback(function(...)
					self:updateKeybind(keybind, ...)
				end)
			end
		end}

		if default and callback then
			self:updateKeybind(keybind, nil, default)
		end

		keybind.MouseButton1Click:Connect(function()

			animate()

			if self.binds[keybind].connection then 
				return self:updateKeybind(keybind)
			end

			if text.Text == "None" then 
				text.Text = "..."

				local key = utility:KeyPressed()

				self:updateKeybind(keybind, nil, key.KeyCode)
				animate()

				if changedCallback then
					changedCallback(key, function(...)
						self:updateKeybind(keybind, ...)
					end)
				end
			end
		end)

		return keybind
	end

	--[[
		Adds a color picker to the section
		@param title: string - Color picker label
		@param default: Color3 - Initial color
		@param callback: function - Function called on color change
		@return: Instance - Created color picker object
	]]
	function section:addColorPicker(title, default, callback)
		local colorpicker = utility:Create("ImageButton", {
			Name = "ColorPicker",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:Create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
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

		local tab = utility:Create("ImageLabel", {
			Name = "ColorPicker",
			Parent = self.page.library.container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.75, 0, 0.400000006, 0),
			Selectable = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 162, 0, 169),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298),
			Visible = false,
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 2,
				Font = Enum.Font.SourceSansSemibold,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("ImageButton", {
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor
			}), 
			utility:Create("Frame", {
				Name = "Container",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 32),
				Size = UDim2.new(1, -18, 1, -40)
			}, {
				utility:Create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6)
				}),
				utility:Create("ImageButton", {
					Name = "Canvas",
					BackgroundTransparency = 1,
					BorderColor3 = themes.LightContrast,
					Size = UDim2.new(1, 0, 0, 60),
					AutoButtonColor = false,
					Image = "rbxassetid://5108535320",
					ImageColor3 = Color3.fromRGB(255, 0, 0),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("ImageLabel", {
						Name = "White_Overlay",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 60),
						Image = "rbxassetid://5107152351",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:Create("ImageLabel", {
						Name = "Black_Overlay",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 60),
						Image = "rbxassetid://5107152095",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:Create("ImageLabel", {
						Name = "Cursor",
						BackgroundColor3 = themes.TextColor,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1.000,
						Size = UDim2.new(0, 10, 0, 10),
						Position = UDim2.new(0, 0, 0, 0),
						Image = "rbxassetid://5100115962",
						SliceCenter = Rect.new(2, 2, 298, 298)
					})
				}),
				utility:Create("ImageButton", {
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
					utility:Create("Frame", {
						Name = "Select",
						BackgroundColor3 = themes.TextColor,
						BorderSizePixel = 1,
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						ZIndex = 2
					}),
					utility:Create("UIGradient", { -- rainbow canvas
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
				utility:Create("Frame", {
					Name = "Inputs",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 158),
					Size = UDim2.new(1, 0, 0, 16)
				}, {
					utility:Create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 6)
					}),
					utility:Create("ImageLabel", {
						Name = "R",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "R:",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							PlaceholderColor3 = themes.DarkContrast,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						})
					}),
					utility:Create("ImageLabel", {
						Name = "G",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							ZIndex = 2,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							Font = Enum.Font.Gotham,
							Text = "G:",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						})
					}),
					utility:Create("ImageLabel", {
						Name = "B",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 2,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.DarkContrast,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "B:",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						}),
						utility:Create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 2,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 12.000
						})
					}),
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 2,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.DarkContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("TextLabel", {
						Name = "Text",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,
						Font = Enum.Font.Gotham,
						Text = "Submit",
						TextColor3 = themes.TextColor,
						TextSize = 12.000
					})
				})
			})
		})

		utility:DraggingEnabled(tab)
		table.insert(self.modules, colorpicker)

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

		self.colorpickers[colorpicker] = {
			tab = tab,
			callback = function(prop, value)
				rgb[prop] = value
				hue, sat, brightness = Color3:ToHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
			end
		}

		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateColorPicker(colorpicker, ...)
				end)
			end
		end

		utility:DraggingEnded(function()
			draggingColor, draggingCanvas = false, false
		end)

		if default then
			self:updateColorPicker(colorpicker, nil, default)

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
						hue, sat, brightness = Color3:ToHSV(color3)

						self:updateColorPicker(colorpicker, nil, color3)
						callback(color3)
					end
				end)
			end
		end

		canvas.MouseButton1Down:Connect(function()
			draggingCanvas = true

			while draggingCanvas do

				local x, y = mouse.X, mouse.Y

				sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
				brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)

				color3 = Color3.fromHSV(hue, sat, brightness)

				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end

				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness})
				utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1)

				callback(color3)
				utility:Wait()
			end
		end)

		color.MouseButton1Down:Connect(function()
			draggingColor = true

			while draggingColor do

				hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
				color3 = Color3.fromHSV(hue, sat, brightness)

				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end

				local x = hue 
				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) 
				utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1)

				callback(color3)
				utility:Wait()
			end
		end)

		-- click events
		local button = colorpicker.Button
		local toggle, debounce, animate

		lastColor = Color3.fromHSV(hue, sat, brightness)
		animate = function(visible, overwrite)

			if overwrite then

				if not toggle then
					return
				end

				if debounce then
					while debounce do
						utility:Wait()
					end
				end
			elseif not overwrite then
				if debounce then 
					return 
				end

				if button.ImageTransparency == 0 then
					utility:Pop(button, 10)
				end
			end

			toggle = visible
			debounce = true

			if visible then

				if self.page.library.activePicker and self.page.library.activePicker ~= animate then
					self.page.library.activePicker(nil, true)
				end

				self.page.library.activePicker = animate
				lastColor = Color3.fromHSV(hue, sat, brightness)

				local x1, x2 = button.AbsoluteSize.X / 2, 162
				local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y

				tab.ClipsDescendants = true
				tab.Visible = true
				tab.Size = UDim2.new(0, 0, 0, 0)

				tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
				utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)

				wait(0.2)
				tab.ClipsDescendants = false

				canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
				colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
			else
				utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
				tab.ClipsDescendants = true

				wait(0.2)
				tab.Visible = false
			end

			debounce = false
		end

		local toggleTab = function()
			animate(not toggle)
		end

		button.MouseButton1Click:Connect(toggleTab)
		colorpicker.MouseButton1Click:Connect(toggleTab)

		tab.Container.Button.MouseButton1Click:Connect(function()
			animate()
		end)

		tab.Close.MouseButton1Click:Connect(function()
			self:updateColorPicker(colorpicker, nil, lastColor)
			animate()
		end)

		return colorpicker
	end

	--[[
		Adds a slider to the section
		@param title: string - Slider label
		@param default: number - Initial value
		@param min: number - Minimum value
		@param max: number - Maximum value
		@param callback: function - Function called on value change
		@return: Instance - Created slider object
	]]
	function section:addSlider(title, default, min, max, callback)
		local slider = utility:Create("ImageButton", {
			Name = "Slider",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
			Size = UDim2.new(1, 0, 0, 50),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:Create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 6),
				Size = UDim2.new(0.5, 0, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:Create("TextBox", {
				Name = "TextBox",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -30, 0, 6),
				Size = UDim2.new(0, 20, 0, 16),
				ZIndex = 3,
				Font = Enum.Font.SourceSansSemibold,
				Text = default or min,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right
			}),
			utility:Create("TextLabel", {
				Name = "Slider",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 28),
				Size = UDim2.new(1, -20, 0, 16),
				ZIndex = 3,
				Text = "",
			}, {
				utility:Create("ImageLabel", {
					Name = "Bar",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.new(1, 0, 0, 4),
					ZIndex = 3,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.LightContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("ImageLabel", {
						Name = "Fill",
						BackgroundTransparency = 1,
						Size = UDim2.new(0.8, 0, 1, 0),
						ZIndex = 3,
						Image = "rbxassetid://5028857472",
						ImageColor3 = themes.TextColor,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:Create("ImageLabel", {
							Name = "Circle",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							ImageTransparency = 1.000,
							ImageColor3 = themes.TextColor,
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.new(0, 10, 0, 10),
							ZIndex = 3,
							Image = "rbxassetid://4608020054"
						})
					})
				})
			})
		})

		table.insert(self.modules, slider)

		local allowed = {
			[""] = true,
			["-"] = true
		}

		local textbox = slider.TextBox
		local circle = slider.Slider.Bar.Fill.Circle

		local value = default or min
		local dragging, last

		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateSlider(slider, ...)
				end)
			end
		end

		self:updateSlider(slider, nil, value, min, max)

		utility:DraggingEnded(function()
			dragging = false
		end)

		slider.MouseButton1Down:Connect(function(input)
			dragging = true

			while dragging do
				utility:Tween(circle, {ImageTransparency = 0}, 0.1)

				value = self:updateSlider(slider, nil, nil, min, max, value)
				callback(value)

				utility:Wait()
			end

			wait(0.5)
			utility:Tween(circle, {ImageTransparency = 1}, 0.2)
		end)

		textbox.FocusLost:Connect(function()
			if not tonumber(textbox.Text) then
				value = self:updateSlider(slider, nil, default or min, min, max)
				callback(value)
			end
		end)

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = textbox.Text

			if not allowed[text] and not tonumber(text) then
				textbox.Text = text:sub(1, #text - 1)
			elseif not allowed[text] then	
				value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
				callback(value)
			end
		end)

		return slider
	end

	--[[
		Adds a dropdown to the section
		@param title: string - Dropdown label
		@param list: table - List of options
		@param callback: function - Function called on selection
		@param default: string - Initial selected value
		@return: Instance - Created dropdown object
	]]
	function section:addDropdown(title, list, callback, default)
		local dropdown = utility:Create("Frame", {
			Name = "Dropdown",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:Create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 14,
					TextTransparency = 0.10000000149012,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:Create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ScrollingFrame", {
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
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:Create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				})
			})
		})

		table.insert(self.modules, dropdown)

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
				self:updateDropdown(dropdown, nil, list, callback)
			else
				self:updateDropdown(dropdown, nil, nil, callback)
			end
		end)

		search.TextBox.Focused:Connect(function()
			if search.Button.Rotation == 0 then
				self:updateDropdown(dropdown, nil, list, callback)
			end

			focused = true
		end)

		search.TextBox.FocusLost:Connect(function()
			focused = false
		end)

		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = utility:Sort(search.TextBox.Text, list)
				list = #list ~= 0 and list 

				self:updateDropdown(dropdown, nil, list, callback)
			end
		end)

		dropdown:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
		end)

		return dropdown
	end

	--[[
		Adds a multi-select dropdown to the section
		@param title: string - Dropdown label
		@param list: table - List of options
		@param callback: function - Function called on selection change
		@return: Instance - Created multi-dropdown object
	]]
	function section:addMultiDropdown(title, list, callback)
		local dropdown = utility:Create("Frame", {
			Name = "MultiDropdown",
			Parent = self.container.ScrollingFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:Create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 0),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 14,
					TextTransparency = 0.1,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				utility:Create("ImageButton", {
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:Create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("ScrollingFrame", {
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
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:Create("UIListLayout", {
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
			if next(selected) then
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
			-- Clear any previous options
			for _, child in pairs(dropdown.List.Frame:GetChildren()) do
				if child:IsA("ImageButton") then
					child:Destroy()
				end
			end
	
			local entries = 0
			-- If no filtered list is given, use the full list
			local optionsToDisplay = filteredList or allOptions
	
			for _, value in pairs(optionsToDisplay) do
				local isSelected = false
				for _, sel in pairs(selected) do
					if sel == value then
						isSelected = true
						break
					end
				end
	
				local optionButton = utility:Create("ImageButton", {
					Parent = dropdown.List.Frame,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 30),
					ZIndex = 2,
					Image = "rbxassetid://5028857472",
					ImageColor3 = themes.DarkContrast,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:Create("Frame", {
						Name = "Indicator",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(0, 5, 1, 0),
						Visible = isSelected,
						ZIndex = 4,
					}),
					utility:Create("ImageLabel", {
						Name = "Check",
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -20, 0.5, -8),
						Size = UDim2.new(0, 16, 0, 16),
						ZIndex = 3,
						Image = "rbxassetid://1234567890",
						Visible = isSelected,
					}),
					utility:Create("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0, 0),
						Size = UDim2.new(1, -40, 1, 0),
						ZIndex = 3,
						Font = Enum.Font.SourceSansSemibold,
						Text = value,
						TextColor3 = themes.TextColor,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTransparency = 0.1,
					})
				})
	
				optionButton.MouseButton1Click:Connect(function()
					-- Toggle selection of this option
					local found = false
					for idx, sel in pairs(selected) do
						if sel == value then
							table.remove(selected, idx)
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
					if callbackArg then
						callbackArg(selected)
					elseif callback then
						callback(selected)
					end
				end)
				entries = entries + 1
			end
	
			local frame = dropdown.List.Frame
			utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 5) * 34 + 38)}, 0.3)
			utility:Tween(dropdown.Search.Button, {Rotation = entries > 0 and 180 or 0}, 0.3)
	
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
				local sorted = utility:Sort(search.TextBox.Text, allOptions)
				sorted = (#sorted ~= 0 and sorted) or allOptions
				updateMultiDropdown(sorted, callback)
			end
		end)
	
		return dropdown
	end

	--[[
		Selects a page internally
		@param page: table - Page to select
		@param toggle: boolean - Whether to toggle selection
	]]
	function library:SelectPage(page, toggle)
		if toggle and self.focusedPage == page then
			return
		end

		local button = page.button

		if toggle then
			button.Title.TextTransparency = 0
			button.Title.Font = Enum.Font.SourceSansSemibold

			if button:FindFirstChild("Icon") then
				button.Icon.ImageTransparency = 0
			end

			local focusedPage = self.focusedPage
			self.focusedPage = page

			if focusedPage then
				self:SelectPage(focusedPage)
			end

			local existingSections = focusedPage and #focusedPage.sections or 0
			local sectionsRequired = #page.sections - existingSections

			page:Resize()

			for i, section in pairs(page.sections) do
				section.container.Parent.BackgroundTransparency = 0
			end

			if sectionsRequired < 0 then
				for i = existingSections, #page.sections + 1, -1 do
					local section = focusedPage.sections[i].container.Parent

					utility:Tween(section, {BackgroundTransparency = 1}, 0.1)
				end
			end

			wait(0.1)
			page.container.Visible = true

			if focusedPage then
				focusedPage.container.Visible = false
			end

			if sectionsRequired > 0 then
				for i = existingSections + 1, #page.sections do
					local section = page.sections[i].container.Parent

					section.BackgroundTransparency = 1
					utility:Tween(section, {BackgroundTransparency = 0}, 0.05)
				end
			end

			wait(0.05)

			for i, section in pairs(page.sections) do

				utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
				section:Resize(true)

				wait(0.05)
			end

			wait(0.05)
			page:Resize(true)
		else
			button.Title.Font = Enum.Font.Gotham
			button.Title.TextTransparency = 0.65

			if button:FindFirstChild("Icon") then
				button.Icon.ImageTransparency = 0.65
			end

			for i, section in pairs(page.sections) do	
				utility:Tween(section.container.Parent, {Size = UDim2.new(0.48, 0, 0, 240)}, 0.1)
				utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
			end

			wait(0.1)

			page.lastPosition = page.container.CanvasPosition.Y
			page:Resize()
		end
	end

	--[[
		Resizes the page layout
		@param scroll: boolean - Whether to scroll to last position
	]]
	function page:Resize(scroll)
		for i, section in pairs(self.sections) do
			section.container.Parent.Size = UDim2.new(0.48, 0, 0, 240)
			section.container.Parent.Position = UDim2.new(((i+1)%2)/2, 4, 0, 244*(math.floor((i+1)/2)-1))
		end

		self.container.CanvasSize = UDim2.new(0, 0, 0, 244*((#self.sections+1)/2))
		self.container.ScrollBarImageTransparency = 244*((#self.sections+1)/2) > self.container.AbsoluteSize.Y

		if scroll then
			utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
		end
	end

	--[[
		Resizes the section based on module sizes
		@param smooth: boolean - Whether to resize smoothly
	]]
	function section:Resize(smooth)
		if self.page.library.focusedPage ~= self.page then
			return
		end
		
		local size = 0;

		for i, module in pairs(self.modules) do
			size = size + module.AbsoluteSize.Y + 4
		end
		
		self.container.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,size)

	end

	--[[
		Gets a module by name or title
		@param info: string or Instance - Module name or instance
		@return: Instance - The module object
	]]
	function section:getModule(info)
		if table.find(self.modules, info) then
			return info
		end

		for i, module in pairs(self.modules) do
			if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
				return module
			end
		end

		error("No module found under "..tostring(info))
	end

	--[[
		Updates a button's title
		@param button: Instance - Button to update
		@param title: string - New title
	]]
	function section:updateButton(button, title)
		button = self:getModule(button)

		button.Title.Text = title
	end

	--[[
		Updates a toggle's state
		@param toggle: Instance - Toggle to update
		@param title: string - New title (optional)
		@param value: boolean - New state
	]]
	function section:updateToggle(toggle, title, value)
		toggle = self:getModule(toggle)

		local position = {
			In = UDim2.new(0, 2, 0.5, -6),
			Out = UDim2.new(0, 20, 0.5, -6)
		}

		local frame = toggle.Button.Frame
		value = value and "Out" or "In"

		if title then
			toggle.Title.Text = title
		end
		
		utility:Tween(frame, {
			Size = UDim2.new(1, -22, 1, -9),
			Position = position[value] + UDim2.new(0, 0, 0, 2.5)
		}, 0.2)
		
		if value == "Out" then
			utility:Tween(toggle.Button, {
				ImageColor3 = Color3.new(0.235294, 1, 0)
			}, 0.1)
		else
			utility:Tween(toggle.Button, {
				ImageColor3 = themes.LightContrast;
			}, 0.1)
		end

		wait(0.1)
		utility:Tween(frame, {
			Size = UDim2.new(1, -22, 1, -4),
			Position = position[value]
		}, 0.1)
	end

	--[[
		Updates a textbox's value
		@param textbox: Instance - Textbox to update
		@param title: string - New title (optional)
		@param value: string - New text value (optional)
	]]
	function section:updateTextbox(textbox, title, value)
		textbox = self:getModule(textbox)

		if title then
			textbox.Title.Text = title
		end

		if value then
			textbox.Button.Textbox.Text = value
		end

	end

	--[[
		Updates a keybind
		@param keybind: Instance - Keybind to update
		@param title: string - New title (optional)
		@param key: Enum.KeyCode - New key (optional)
	]]
	function section:updateKeybind(keybind, title, key)
		keybind = self:getModule(keybind)

		local text = keybind.Button.Text
		local bind = self.binds[keybind]

		if title then
			keybind.Title.Text = title
		end

		if bind.connection then
			bind.connection = bind.connection:UnBind()
		end

		if key then
			self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
			text.Text = key.Name
		else
			text.Text = "None"
		end
	end

	--[[
		Updates a color picker
		@param colorpicker: Instance - Color picker to update
		@param title: string - New title (optional)
		@param color: Color3 or table - New color value
	]]
	function section:updateColorPicker(colorpicker, title, color)
		colorpicker = self:getModule(colorpicker)

		local picker = self.colorpickers[colorpicker]
		local tab = picker.tab
		local callback = picker.callback

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

		utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
		utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)

		utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
		utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)

		for i, container in pairs(tab.Container.Inputs:GetChildren()) do
			if container:IsA("ImageLabel") then
				local value = math.clamp(color3[container.Name], 0, 1) * 255

				container.Textbox.Text = math.floor(value)
			end
		end
	end

	--[[
		Updates a slider's value
		@param slider: Instance - Slider to update
		@param title: string - New title (optional)
		@param value: number - New value (optional)
		@param min: number - Minimum value
		@param max: number - Maximum value
		@param lvalue: number - Last value for pop effect
		@return: number - Updated value
	]]
	function section:updateSlider(slider, title, value, min, max, lvalue)
		slider = self:getModule(slider)

		if title then
			slider.Title.Text = title
		end

		local bar = slider.Slider.Bar
		local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

		if value then
			percent = (value - min) / (max - min)
		end

		percent = math.clamp(percent, 0, 1)
		value = value or math.floor(min + (max - min) * percent)

		slider.TextBox.Text = value
		utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)

		if value ~= lvalue and slider.ImageTransparency == 0 then
			utility:Pop(slider, 10)
		end

		return value
	end

	--[[
		Updates a dropdown
		@param dropdown: Instance - Dropdown to update
		@param title: string - New title (optional)
		@param list: table - New list of options (optional)
		@param callback: function - Callback for selection
	]]
	function section:updateDropdown(dropdown, title, list, callback)
		dropdown = self:getModule(dropdown)

		if title then
			dropdown.Search.TextBox.Text = title
		end

		local entries = 0

		utility:Pop(dropdown.Search, 10)

		for i, button in pairs(dropdown.List.Frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		for i, value in pairs(list or {}) do
			local button = utility:Create("ImageButton", {
				Parent = dropdown.List.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:Create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.SourceSansSemibold,
					Text = value,
					TextColor3 = themes.TextColor,
					TextSize = 14,
					TextXAlignment = "Left",
					TextTransparency = 0.10000000149012
				})
			})

			button.MouseButton1Click:Connect(function()
				if callback then
					callback(value, function(...)
						self:updateDropdown(dropdown, ...)
					end)	
				end

				self:updateDropdown(dropdown, value, nil, callback)
			end)

			entries = entries + 1
		end

		local frame = dropdown.List.Frame

		utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 5) * 34 + 38)}, 0.3)
		utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)

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
end

return library
