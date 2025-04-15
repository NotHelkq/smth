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

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()

local Window = library.new()

local Main = Window:addPage("Auto Farm", 5012544693)
local AutoFarm = Main:addSection("Auto Farm")

local autoCollectCoins = AutoFarm:addButton("Auto Collect Coins/Gems", function(cg)
    local c = require(game:GetService("ReplicatedStorage").Shared.Constants)
    c.DefaultPickupRadius = 9999999999999999999999
end)

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

local autoChests = false
local autocollectChests = AutoFarm:addToggle("Auto Claim Void/Giant Chest", false, function(on)
    if on then
        autoChests = true
        task.spawn(function()
            while autoChests do
                local args = {
                    [1] = "ClaimChest",
                    [2] = "Void Chest",
                    [3] = true
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                task.wait(1)
                local args = {
                    [1] = "ClaimChest",
                    [2] = "Giant Chest",
                    [3] = true
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                task.wait(5)
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
                    task.wait(0.75)
                end              
            end
        end)
    else
        autoAlienShop = false
    end
end)

local autoshardShop = false
local autoBuyShard = AutoFarm:addToggle("Auto Buy Black Market", false, function(on)
    if on then
        autoshardShop = true
        task.spawn(function()
            while autoshardShop do
                for i = 1, 3 do
                    local args = {
                        [1] = "BuyShopItem",
                        [2] = "shard-shop",
                        [3] = i
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    task.wait(1.5)
                end              
            end
        end)
    else
        autoshardShop = false
    end
end)


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



local selectedEgg = nil
local hatchingEggs = 1
local Autoopeneggs = Window:addPage("Eggs", 5012544693)
local eggstuff = Autoopeneggs:addSection("Hatch (You must be near egg!)")
local egg = eggstuff:addDropdown("Eggs", {"Infinity Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(selected)
    selectedEgg = selected
end)
local multiegg = eggstuff:addSlider("Open Amount", 1, 1, 6, function(multi)
    hatchingEggs = multi
end)



local openingEggs = false
local openEgg = eggstuff:addToggle("Open Eggs", false, function(on)
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

local tpToEggs = false
local tpEgg = eggstuff:addToggle("Teleport to Egg", false, function(on)
    if on then 
        tpToEggs = true
        if selectedEgg == "Infinity Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-96, 10, -27)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Common Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-7, 11, -82)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Spotted Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-7, 11, -71)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Iceshard Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-7, 11, -60)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Spikey Egg" then
            argArea1()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-8, 424, 158)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Magma Egg" then
            argArea2()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-17, 2666, 9)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Crystal Egg" then
            argArea2()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-19, 2666, 19)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Lunar Egg" then
            argArea3()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-58, 6865, 81)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Void Egg" then
            argArea4()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(6, 10149, 188)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Hell Egg" then
            argArea4()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-6, 10149, 192)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Nightmare Egg" then
            argArea4()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-20, 10149, 184)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Rainbow Egg" then
            argArea5()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-35, 15974, 44)
                    task.wait(1)
                end
            end)
        else
            print("Egg is not selected")
            task.wait(1)
        end
    else
        tpToEggs = false
    end
end)



local Misc = Window:addPage("Misc", 5012544693)
local miscstuff = Misc:addSection("Misc")
local fpsboost = miscstuff:addButton("Boost FPS", function(fps)
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true, 
            ["Ignore Others"] = true
        },
        Meshes = {
            Destroy = false,
            LowDetail = true 
        },
        Images = {
            Invisible = true, 
            LowDetail = false,
            Destroy = false, 
        },
        ["No Particles"] = true, 
        ["No Camera Effects"] = true, 
        ["No Explosions"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true, 
        ["No Shadows"] = true, 
        ["Low Rendering"] = true, 
        ["Low Quality Parts"] = true 
    }
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/boost.luau"))()
end)

local allAreas = miscstuff:addButton("Unlock All Areas", function(tp)
    ttppos(-16, 423, 143)
    task.wait(3)
    ttppos(42, 2663, -6)
    task.wait(3)
    ttppos(-78, 6862, 88)
    task.wait(3)
    ttppos(16, 10146, 152)
    task.wait(3)
    ttppos(36, 15972, 42)
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

local autotickets = false
local autoClaimTickets = miscstuff:addToggle("Auto Claim Wheel Spin", false, function(on)
    if on then
        autotickets = true
        task.spawn(function()
            while autotickets do
                local args = {
                    [1] = "ClaimFreeWheelSpin"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
            end
        end)
    else
        autotickets = false
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



-- workspace.Rendered.Gifts

-- local args = {
--     [1] = "UnlockRiftChest",
--     [2] = "golden-chest"
-- }
-- game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

-- workspace.Rendered.Rifts["golden-chest"].Chest
