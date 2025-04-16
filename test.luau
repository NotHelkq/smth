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

local autochewbubble = false
local autoSellBubbles = false
local autoChests = false
local autoAlienShop = false
local autoshardShop = false
local openingEggs = false
local tpToEggs = false
local autoPlaytime = false
local autotickets = false
local autoGoldenChest = false
local goldenChecked = false
local autoRoyalChest = false
local royalChecked = false
local automystery = false
local selectedEgg = nil
local selectedEnchant = nil
local islandpos = nil
local hatchingEggs = 1

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

local cg = require(game:GetService("ReplicatedStorage").Shared.Constants)
local autoCollectCoins = AutoFarm:addToggle("Auto Collect Coins/Gems", false, function(on)
    if on then 
        cg.DefaultPickupRadius = 9999999999999999999999
    else
        cg.DefaultPickupRadius = 10
    end
end)

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


local Autoopeneggs = Window:addPage("Eggs", 5012544693)
local eggstuff = Autoopeneggs:addSection("Hatch (You must be near egg!)")
local egg = eggstuff:addDropdown("Eggs", {"Infinity Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(selected)
    selectedEgg = selected
end)
local multiegg = eggstuff:addSlider("Open Amount", 1, 1, 6, function(multi)
    hatchingEggs = multi
end)

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

-----------------------------------

local Enchants = Window:addPage("Enchants", 5012544693)
local enchanting = Enchants:addSection("Enchanting")
local enchantlist = enchanting:addDropdown("Enchantment list", {"⚡ Team Up I","⚡ Team Up II","⚡ Team Up III","⚡ Team Up IV","⚡ Team Up V","💰 Looter I","💰 Looter II","💰 Looter III","💰 Looter IV","💰 Looter V","🫧 Bubbler I","🫧 Bubbler II","🫧 Bubbler III","🫧 Bubbler IV","🫧 Bubbler V","✨ Gleaming I","✨ Gleaming II", "✨ Gleaming III"}, function(eSelected)
    selectedEnchant = eSelected
end)

---------------------------------

local function checkGiftsFolder(folderPath)
    if folderPath then
        local children = folderPath:GetChildren()
        if #children > 0 then
            print("Gifts found:")
            for _, child in ipairs(children) do
                print("Object found: " .. child.Name)
            end
            return true
        else
            print("No gifts found in the folder.")
            return false
        end
    else
        print("The Gifts folder does not exist.")
        return false
    end
end

local function goldenCheck(gCheck)
    local pos = workspace.Rendered.Rifts["golden-chest"].Chest.WorldPivot.Position 
    local rgPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    ) 
    local y = pos.Y
    local area = nil
    if y >= 0 and y < 410 then
        area = "a0"
        argArea1()
    elseif y >= 410 and y < 2650 then
        area = "a1"
        argArea2()
    elseif y >= 2650 and y < 6850 then
        area = "a2"
        argArea3()
    elseif y >= 6850 and y < 10130 then
        area = "a3"
        argArea4()
    elseif y >= 10130 and y <= 15960 then
        area = "a4"
        argArea5()
    else
        area = nil
    end
    if area ~= nil then
        task.wait(2)
    end
    goldenPos = Vector3.new(pos.X, pos.Y, pos.Z)
end

local function royalCheck(rCheck)
    local pos = workspace.Rendered.Rifts["royal-chest"].Chest.WorldPivot.Position 
    local rrPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    ) 
    local y = pos.Y
    local area = nil
    if y >= 0 and y < 410 then
        area = "a1"
        argArea1()
    elseif y >= 410 and y < 2650 then
        area = "a2"
        argArea2()
    elseif y >= 2650 and y < 6850 then
        area = "a3"
        argArea3()
    elseif y >= 6850 and y < 10130 then
        area = "a4"
        argArea4()
    elseif y >= 10130 and y <= 15960 then
        area = "a5"
        argArea5()
    else
        area = nil
    end
    if area ~= nil then
        task.wait(2)
    end
    royalPos = Vector3.new(pos.X, pos.Y, pos.Z)
end

local Misc = Window:addPage("Misc", 5012544693)
local miscstuff = Misc:addSection("Misc")

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

local autoClaimTickets = miscstuff:addToggle("Auto Claim Wheel Spin", false, function(on)
    if on then
        autotickets = true
        task.spawn(function()
            while autotickets do
                local args = {
                    [1] = "ClaimFreeWheelSpin"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                task.wait(5)
            end
        end)
    else
        autotickets = false
    end
end)

local autogChest = miscstuff:addToggle("Auto Open Golden Chest (broken)", false, function(on)
    if on then
        autoGoldenChest = true
        task.spawn(function()
            while autoGoldenChest do
                local gchest = workspace.Rendered.Rifts["golden-chest"]:FindFirstChild("Chest") 
                local goldenKey = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Items.Main.ScrollingFrame.Powerups.Items:FindFirstChild("Golden Key")
                if not goldenChecked and gchest and goldenKey.Visible then
                    goldenCheck() 
                    print("Golden Chest Position: X=" .. goldenPos.X .. ", Y=" .. goldenPos.Y .. ", Z=" .. goldenPos.Z)
                    tppos(goldenPos.X, goldenPos.Y + 10, goldenPos.Z) 
                    goldenChecked = true
                end
                if rchest and goldenKey.Visible then
                    local args = {
                        [1] = "UnlockRiftChest",
                        [2] = "golden-chest"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    task.wait(3) 
                else
                    print("Golden Chest or Golden Key missing!")
                    goldenChecked = false 
                    task.wait(5)
                end
            end
        end)
    else
        autoGoldenChest = false
        goldenChecked = false 
    end
end)

local autorChest = miscstuff:addToggle("Auto Open Royal Chest (broken)", false, function(on)
    if on then
        autoRoyalChest = true
        task.spawn(function()
            while autoRoyalChest do
                local rchest = workspace.Rendered.Rifts["royal-chest"]:FindFirstChild("Chest")
                local royalKey = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Items.Main.ScrollingFrame.Powerups.Items:FindFirstChild("Royal Key")
                if not royalChecked and rchest and royalKey.Visible then
                    islandCheck()
                    print("Royal Chest Position: X=" .. royalPos.X .. ", Y=" .. royalPos.Y .. ", Z=" .. royalPos.Z)
                    tppos(royalPos.X, royalPos.Y + 10, royalPos.Z)
                    royalChecked = true 
                end
                if rchest and royalKey.Visible then
                    local args = {
                        [1] = "UnlockRiftChest",
                        [2] = "royal-chest"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    print("Royal Chest unlocked!")
                    task.wait(3)
                else
                    print("Royal Chest or Royal Key missing!")
                    task.wait(5) 
                    royalChecked = false 
                end
            end
        end)
    else
        autoRoyalChest = false
        royalChecked = false
    end
end)

local autombox = miscstuff:addToggle("Auto Open Mystery Box (Not auto)", false, function(on)
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
                print("Mystery box used!")
                task.wait(3)
                if checkGiftsFolder(workspace.Rendered.Gifts) then
                    -- nothing 
                end
            end
        end)
    else
        automystery = false
    end
end)


local Settings = Window:addPage("Settings", 5012544693)
local SetSec2 = Settings:addSection("Others")

local fpsboost = SetSec2:addButton("Boost FPS", function(fps)
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

SetSec2:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function()
	Window:toggle()
end)

SetSec2:addButton("Kill Hub", function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end

    autochewbubble         = false
    autoSellBubbles        = false
    autoChests             = false
    autoAlienShop          = false
    autoshardShop          = false
    openingEggs            = false
    tpToEggs               = false
    autoPlaytime           = false
    autotickets            = false
    autoGoldenChest        = false
    autoRoyalChest         = false
    royalChecked           = false
    goldenChecked          = false
    automystery            = false
    selectedEgg            = nil
    selectedEnchant        = nil
    islandpos              = nil
    hatchingEggs           = 1
    cg.DefaultPickupRadius = 10

    Window.container:Destroy()
end)
