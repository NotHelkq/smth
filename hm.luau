wait(1)

local Player = game:GetService("Players").LocalPlayer

Player.Idled:connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame) 
end)

local version = "v1.0.0"
local connections = {};
local tppos = function(x, y, z)
	local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if r then game:GetService("TweenService"):Create(r, TweenInfo.new(3), {CFrame = CFrame.new(x, y, z)}):Play() end
end

local egglist = {
    "Infinity Egg",
    "Common Egg",
    "Spotted Egg",
    "Iceshard Egg",
    "Spikey Egg",
    "Magma Egg",
    "Crystal Egg",
    "Lunar Egg",
    "Void Egg",
    "Hell Egg",
    "Nightmare Egg",
    "Rainbow Egg"
}

local enchantments = {
    "⚡ Team Up I",
    "⚡ Team Up II",
    "⚡ Team Up III",
    "⚡ Team Up IV",
    "⚡ Team Up V",
    "💰 Looter I",
    "💰 Looter II",
    "💰 Looter III",
    "💰 Looter IV",
    "💰 Looter V",
    "🫧 Bubbler I",
    "🫧 Bubbler II",
    "🫧 Bubbler III",
    "🫧 Bubbler IV",
    "🫧 Bubbler V",
    "✨ Gleaming I",
    "✨ Gleaming II",
    "✨ Gleaming III"
}

local potions = {
    "Speed",
    "Lucky",
    "Coins",
    "Mythic"
}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/JennyLib"))()

local Window = library.new()

local Main = Window:addPage("Auto Farm", 5012544693)
local AutoFarm = Main:addSection("Auto Farm")

local autochewbubble = false
local autobubble = AutoFarm:addToggle("Auto Bubble", false, function(on)
    if on then
        autochewbubble = true
        task.spawn(function()
            while autochewbubble do
                local args = {
                    [1] = "BlowBubble"
                }
                    
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

                task.wait(0.25)
            end
        end)
    else
        autochewbubble = false
    end
end)

local autoSellBubbles = false
local autosellbubble = AutoFarm:addToggle("Auto Sell Bubble", false, function(on)
    if on then
        autoSellBubbles = true
        task.spawn(function()
            while autoSellBubbles do
                local args = {
                    [1] = "SellBubble"
                }
                    
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

                task.wait(1)
            end
        end)
    else
        autoSellBubbles = false
    end
end)

local coinsCollected = 0
local autoPickupCoins = false
local pickables = game:GetService('Workspace').Rendered:GetChildren()[12]
local autoCollectCoins = AutoFarm:addToggle("Auto Collect Coins/Gems", false, function(on)
    if on then
        autoPickupCoins = true
        print("Auto Collect Coins turned on")
        task.spawn(function()
            while autoPickupCoins do
                for _, v in next, pickables:GetChildren() do
                    if v:IsA("Model") then
                        local part = v:FindFirstChildWhichIsA("Part") or v:FindFirstChildWhichIsA("MeshPart")
                        if part then
                            game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                            task.wait(0.15)
                        end
                    end
                end
                task.wait(1)
                coinsCollected = coinsCollected + 1
                print(" Collected Coins : " .. coinsCollected)
            end
        end)
    else
        autoPickupCoins = false
        print("Auto Collect Coins turned off")
    end
end)

local autoChests = false
local autocollectChests = AutoFarm:addToggle("Auto Claim Void/Giant Chest", false, function(on)
    if on then
        autoChests = true
        task.spawn(function()
            while autoChests do
                local args = {
                    [1] = "ClaimChest",
                    [2] = "Void Chest"
                }              
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                task.wait(1)
                local args = {
                    [1] = "ClaimChest",
                    [2] = "Giant Chest"
                }              
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                task.wait(15)
            end
        end)
    else
        autoChests = false
    end
end)

local autoAlienShop = false
local autoBuyAlien = AutoFarm:addToggle("Auto Buy Alien Merchant", false, function(on)
    if on then
        autoAlienShop = true
        task.spawn(function()
            while autoAlienShop do
                for i = 1, 3 do
                    local args = {
                        [1] = "BuyShopItem",
                        [2] = "alien-shop",
                        [3] = i
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    task.wait(3)
                end              
            end
        end)
    else
        autoAlienShop = false
    end
end)



local Teleport = Main:addSection("Teleport")
local spawn = Teleport:addButton("Spawn", function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.PortalSpawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end)

local area1 = Teleport:addButton("Area 1 - Floating Island", function(tp) 
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end)

local area2 = Teleport:addButton("Area 2 - Outer Space", function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end)

local area3 = Teleport:addButton("Area 3 - Twilight", function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))    
end)

local area4 = Teleport:addButton("Area 4 - The Void", function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))    
end)

local area5 = Teleport:addButton("Area 5 - Zen", function(tp)
    local args = {
        [1] = "Teleport",
        [2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))    
end)




local Autoopeneggs = Window:addPage("Eggs", 5012544693)
local eggstuff = Misc:addSection("Auto Open Eggs")
local egg = 


local Misc = Window:addPage("Misc", 5012544693)
local miscstuff = Misc:addSection("Misc")
local allAreas = miscstuff:addButton("Unlock All Areas", function(tp)
    tppos(-16, 423, 143)
    task.wait(3)
    tppos(42, 2663, -6)
    task.wait(3)
    tppos(-78, 6862, 88)
    task.wait(3)
    tppos(16, 10146, 152)
    task.wait(3)
    tppos(36, 15972, 42)
    task.wait(3)
end)

local autoPlaytime = false
local autoRewards = miscstuff:addToggle("Auto Claim Playtime Rewards", false, function(on)
    if on then
        autoPlaytime = true
        task.spawn(function()
            while autoPlaytime do
                for i = 1, 9 do
                    local args = {
                        [1] = "ClaimPlaytime",
                        [2] = i
                    }            
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer(unpack(args))
                    task.wait(3)
                end
            end
        end)
    else
        autoPlaytime = false
    end
end)

local automystery = false
local autombox = miscstuff:addToggle("Auto Open Mystery Box", false, function(on)
    if on then
        automystery = true
        task.spawn(function()
            while automystery do
                local args = {
                    [1] = "UseGift",
                    [2] = "Mystery Box",
                    [3] = 10
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))                    
                task.wait(3)
                -- script to click 8-10 times after gifts was used to make it auto
            end
        end)
    else
        automystery = false
    end
end)



local Settings = Window:addPage("Settings", 5012544693)
local SetSec2 = Settings:addSection("Others")

SetSec2:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function()
	Window:toggle()
end)
SetSec2:addButton("Kill Hub", function()
	for i,v in pairs(connections) do
		v:Disconnect();
		autoeggRoll = false
	end
	Window.container:Destroy()
end)

Window:SelectPage(Window.pages[1], true)
