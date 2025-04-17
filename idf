if not game:IsLoaded() then
    print("Waiting for game to load...")
    game.Loaded:Wait()
    print("Loaded Game")
end

local Player = game:GetService("Players").LocalPlayer

Player.Idled:connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) 
end)

local connections = {};
local ttppos = function(x, y, z)
	local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if r then game:GetService("TweenService"):Create(r, TweenInfo.new(3), {CFrame = CFrame.new(x, y, z)}):Play() end
end

local tppos = function(x, y, z)
	local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if r then game:GetService("TweenService"):Create(r, TweenInfo.new(10), {CFrame = CFrame.new(x, y, z)}):Play() end
end

local argspawn = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.PortalSpawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local argArea1 = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local argArea2 = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local argArea3 = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local argArea4 = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local argArea5 = function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idktest.luau"))()

local Window = library.new()

local testing = Window:addPage("Test Features", 5012544693)
local test = testing:addSection("Hatch (You must be near egg!)")
local multiegg = test:addSlider("Open Amount", 1, 1, 6, function(multi)
    hatchingEggs = multi
end)

local openEgg = test:addToggle("Open Eggs", false, function(on)
    if on then 
        openingEggs = true
        task.spawn(function()
            while openingEggs do
                local args = {
                    [1] = "HatchEgg",
                    [2] = selectedEgg,
                    [3] = hatchingEggs
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))   
                task.wait(0.2)
            end
        end)
    else
        openingEggs = false
    end
end)

local egg = test:addDropdown("Eggs", {"Aura Egg", "Infinity Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(selected)
    selectedEgg = selected
end)

local test1 = testing:addSection("Auto Lucky Eggs")
local tests2 = test1:addButton("test 1", function(on)
    print("test 1")
end)

local tests3 = test1:addButton("test 2", function(on)
    print("test 2")
end)

local tests4 = test1:addButton("test 3", function(on)
    print("test 3")
end)

local tests5 = test1:addButton("test 4", function(on)
    print("test 4")
end)

local tests6 = test1:addButton("test 5", function(on)
    print("test 5")
end)

local tests7 = test1:addButton("test 6", function(on)
    print("test 6")
end)



local Settings = Window:addPage("Settings", 5012544693)
local SetSec2 = Settings:addSection("Others")

SetSec2:addButton("Kill Hub", function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    Window.container:Destroy()
end)
