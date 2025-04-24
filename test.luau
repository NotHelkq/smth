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


local httpRequest =
    (syn and syn.request) or
    (http and http.request) or
    (http_request) or
    (fluxus and fluxus.request) or
    (request)

if not httpRequest then
    warn("⚠️ No supported HTTP request method found!")
    return
end

local player = game.Players.LocalPlayer
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local recentFrames = {}

local function isRecentFrame(id)
    if recentFrames[id] and (tick() - recentFrames[id] < 5) then
        return true
    end
    recentFrames[id] = tick()
    return false
end

local function monitorRifts()
    local riftsFolder = workspace.Rendered.Rifts
    local riftList = {
        {name = "event-1", url = "bunnyEgg.luau"},
        {name = "event-2", url = "pastelEgg.luau"},
        {name = "event-3", url = "throwbackEgg.luau"},
        {name = "aura-egg", url = "auraEgg.luau"},
        {name = "spikey-egg", url = "spikeyEgg.luau"},
        {name = "magma-egg", url = "magmaEgg.luau"},
        {name = "crystal-egg", url = "crystalEgg.luau"},
        {name = "lunar-egg", url = "lunarEgg.luau"},
        {name = "void-egg", url = "voidEgg.luau"},
        {name = "hell-egg", url = "hellEgg.luau"},
        {name = "nightmare-egg", url = "nightmareEgg.luau"},
        {name = "rainbow-egg", url = "rainbowEgg.luau"}
    }

    for _, riftData in ipairs(riftList) do
        local rift = riftsFolder:FindFirstChild(riftData.name)
        if rift and rift:FindFirstChild("Output") then
            if not isRecentFrame(riftData.name) then
                local success, scriptContent = pcall(function()
                    return game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/" .. riftData.url)
                end)
                if success then
                    local loadedFunction = loadstring(scriptContent)
                    if type(loadedFunction) == "function" then
                        loadedFunction()
                        rift.Output:Destroy()
                    else
                        warn("Failed to send webhook for", riftData.name)
                    end
                else
                    warn("Failed to fetch script for", riftData.name, ":", scriptContent)
                end
                break
            end
        end
    end
end

local petImages = {
    -- Secret Pet List
    ["MAN FACE GOD"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1b/MAN_FACE_GOD.png/revision/latest?cb=20250414020316",
    ["The Overlord"] = "https://static.wikia.nocookie.net/bgs-infinity/images/c/c0/The_Overlord.png/revision/latest?cb=20250413130318",
    ["King Doggy"] = "https://static.wikia.nocookie.net/bgs-infinity/images/a/a8/King_Doggy.png/revision/latest?cb=20250412152038",
    -- Event Secret Pet List
    ["Godly Gem"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/18/Godly_Gem.png/revision/latest?cb=20250424031626",
    ["Dementor"] = "https://static.wikia.nocookie.net/bgs-infinity/images/5/58/Dementor.png/revision/latest?cb=20250424030933",
    ["Giant Chocolate Chicken"] = "https://static.wikia.nocookie.net/bgs-infinity/images/e/ef/Giant_Chocolate_Chicken.png/revision/latest?cb=20250419001410",
    ["Easter Basket"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/00/Easter_Basket.png/revision/latest?cb=20250419001802",
    -- Legendary Pet List
    ["Emerald Golem"] = "https://static.wikia.nocookie.net/bgs-infinity/images/8/8f/Emerald_Golem.png/revision/latest?cb=20250412234012",
    ["Inferno Dragon"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/06/Inferno_Dragon.png/revision/latest?cb=20250412205317",
    ["Flying Pig"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/18/Flying_Pig.png/revision/latest?cb=20250412142625",
    ["Unicorn"] = "https://static.wikia.nocookie.net/bgs-infinity/images/7/7e/Unicorn.png/revision/latest?cb=20250412233524",
    ["Lunar Serpent"] = "https://static.wikia.nocookie.net/bgs-infinity/images/5/50/Lunar_Serpent.png/revision/latest?cb=20250413002818",
    ["Electra"] = "https://static.wikia.nocookie.net/bgs-infinity/images/a/a0/Electra.png/revision/latest?cb=20250412204328",
    ["Dark Phoenix"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1c/Dark_Phoenix.png/revision/latest?cb=20250413001114",
    ["Neon Elemental"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/11/Neon_Elemental.png/revision/latest?cb=20250413001526",
    ["NULLVoid"] = "https://static.wikia.nocookie.net/bgs-infinity/images/9/98/NULLVoid.png/revision/latest?cb=20250413001555",
    ["Inferno Cube"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/0d/Inferno_Cube.png/revision/latest?cb=20250413010729",
    ["Virus"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1d/Virus.png/revision/latest?cb=20250412214808",
    ["Green Hydra"] = "https://static.wikia.nocookie.net/bgs-infinity/images/b/bc/Green_Hydra.png/revision/latest?cb=20250412170659",
    ["Demonic Hydra"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/17/Demonic_Hydra.png/revision/latest?cb=20250412170659",
    ["Hexarium"] = "https://static.wikia.nocookie.net/bgs-infinity/images/8/89/Hexarium.png/revision/latest?cb=20250413010434",
    ["Rainbow Shock"] = "https://static.wikia.nocookie.net/bgs-infinity/images/c/c6/Rainbow_Shock.png/revision/latest?cb=20250413010157",
    ["Sigma Serpent"] = "https://static.wikia.nocookie.net/bgs-infinity/images/3/3d/Sigma_Serpent.png/revision/latest?cb=20250414121909",
    ["Manarium"] = "https://static.wikia.nocookie.net/bgs-infinity/images/5/5d/Manarium.png/revision/latest?cb=20250414121813",
    -- Event Legendary Pet List
    ["Seraphic Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/d/d7/Seraphic_Bunny.png/revision/latest?cb=20250418234258",
    ["Ethereal Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/b/b9/Ethereal_Bunny.png/revision/latest?cb=20250419000116",
    ["Cardinal Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/3/33/Cardinal_Bunny.png/revision/latest?cb=20250419014509",
    ["Sweet Treat"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/0e/Sweet_Treat.png/revision/latest?cb=20250418233529",
    ["Rainbow Marshmellow"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/14/Rainbow_Marshmellow.png/revision/latest?cb=20250419011325",
    ["Easter Serpent"] = "https://static.wikia.nocookie.net/bgs-infinity/images/c/cd/Easter_Serpent.png/revision/latest?cb=20250423223156",
    ["Dualcorn"] = "https://static.wikia.nocookie.net/bgs-infinity/images/b/bc/Dualcorn.png/revision/latest?cb=20250423223401",
    ["Holy Egg"] = "https://static.wikia.nocookie.net/bgs-infinity/images/d/d7/Holy_Egg.png/revision/latest?cb=20250423223522"
}

local fallbackImage = "https://static.wikia.nocookie.net/bgs-infinity/images/7/73/Common_Pet.png"

local function formatNumber(number)
    local str = tostring(number)
    local reversed = str:reverse()
    local parts = {} 
    for i = 1, #reversed, 3 do
        local part = reversed:sub(i, math.min(i + 2, #reversed))
        table.insert(parts, part)
    end  
    return table.concat(parts, ","):reverse()
end

local function abbreviateNumber(number)
    if number >= 1e9 then
        local value = number / 1e9
        return string.format("%.1fb", value):gsub("%.0b", "b") 
    elseif number >= 1e6 then 
        local value = number / 1e6
        return string.format("%.1fm", value):gsub("%.0m", "m")
    elseif number >= 1e3 then 
        local value = number / 1e3
        return string.format("%.1fk", value):gsub("%.0k", "k")
    else
        return tostring(number) 
    end
end

local petTitle, petChance, isShiny = "Unknown Pet Hatched", " Unknown", "Maybe"
local petConfig = {
    ["Secret"] = {"King Doggy", "The Overlord", "MAN FACE GOD", "Giant Chocolate Chicken", "Easter Basket", "Godly Gem", "Dementor"},
    ["Legendary"] = {"Emerald Golem", "Inferno Dragon", "Unicorn", "Flying Pig", "Lunar Serpent", "Electra", "Dark Phoenix", "Neon Elemental", "NULLVoid", "Inferno Cube", "Virus", "Green Hydra", "Demonic Hydra", "Hexarium", "Rainbow Shock", "Sigma Serpent", "Manarium", "Seraphic Bunny", "Ethereal Bunny", "Cardinal Bunny", "Sweet Treat", "Rainbow Marshmellow", "Easter Serpent", "Dualcorn", "Holy Egg"}
}

local chances = {
    -- Secret Pet List
    ["King Doggy"] = {Secret = {[false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000"}, Mythic = {[false] = " 1 in 10,000,000,000", [true] = " 1 in 400,000,000,000"}},
    ["The Overlord"] = {Secret = {[false] = " 1 in 50,000,000", [true] = " 1 in 2,000,000,000"}, Mythic = {[false] = " 1 in 5,000,000,000", [true] = " 1 in 200,000,000,000"}},
    ["MAN FACE GOD"] = {Secret = {[false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000"}, Mythic = {[false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000"}},
    -- Event Secret Pet List
    ["Giant Chocolate Chicken"] = {Secret = {[false] = " 1 in 50,000,000", [true] = " 1 in 2,000,000,000"}, Mythic = {[false] = " 1 in 5,000,000,000", [true] = " 1 in 200,000,000,000"}},
    ["Easter Basket"] = {Secret = {[false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000"}, Mythic = {[false] = " 1 in 10,000,000,000", [true] = " 1 in 400,000,000,000"}},
    ["Godly Gem"] = {Secret = {[false] = " 1 in 250,000,000", [true] = " 1 in 10,000,000,000"}, Mythic = {[false] = " 1 in 25,000,000,000", [true] = " 1 in 1,000,000,000,000"}},
    ["Dementor"] = {Secret = {[false] = " 1 in 1,000,000,000", [true] = " 1 in 40,000,000,000"}, Mythic = {[false] = " 1 in 100,000,000,000", [true] = " 1 in 4,000,000,000,000"}},
    -- Legendary Pet List
    ["Emerald Golem"] = {Legendary = {[false] = " 1 in 200", [true] = " 1 in 8,000"}, Mythic = {[false] = " 1 in 20,000", [true] = " 1 in 800,000"}},
    ["Inferno Dragon"] = {Legendary = {[false] = " 1 in 400", [true] = " 1 in 16,000"}, Mythic = {[false] = " 1 in 40,000", [true] = " 1 in 1,600,000"}},
    ["Unicorn"] = {Legendary = {[false] = " 1 in 400", [true] = " 1 in 16,000"}, Mythic = {[false] = " 1 in 40,000", [true] = " 1 in 1,600,000"}},
    ["Flying Pig"] = {Legendary = {[false] = " 1 in 1,000", [true] = " 1 in 40,000"}, Mythic = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}},
    ["Lunar Serpent"] = {Legendary = {[false] = " 1 in 400", [true] = " 1 in 16,000"}, Mythic = {[false] = " 1 in 40,000", [true] = " 1 in 1,600,000"}},
    ["Electra"] = {Legendary = {[false] = " 1 in 1,000", [true] = " 1 in 40,000"}, Mythic = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}},
    ["Dark Phoenix"] = {Legendary = {[false] = " 1 in 2,000", [true] = " 1 in 80,000"}, Mythic = {[false] = " 1 in 200,000", [true] = " 1 in 8,000,000"}},
    ["Neon Elemental"] = {Legendary = {[false] = " 1 in 5,000", [true] = " 1 in 200,000"}, Mythic = {[false] = " 1 in 500,000", [true] = " 1 in 20,000,000"}},
    ["NULLVoid"] = {Legendary = {[false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000"}, Mythic = {[false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000"}},
    ["Inferno Cube"] = {Legendary = {[false] = " 1 in 4,000", [true] = " 1 in 160,000"}, Mythic = {[false] = " 1 in 400,000", [true] = " 1 in 16,000,000"}},
    ["Virus"] = {Legendary = {[false] = " 1 in 50,000", [true] = " 1 in 2,000,000"}, Mythic = {[false] = " 1 in 5,000,000", [true] = " 1 in 200,000,000"}},
    ["Green Hydra"] = {Legendary = {[false] = " 1 in 25,000", [true] = " 1 in 1,000,000"}, Mythic = {[false] = " 1 in 2,500,000", [true] = " 1 in 100,000,000"}},
    ["Demonic Hydra"] = {Legendary = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}, Mythic = {[false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000"}},
    ["Hexarium"] = {Legendary = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}, Mythic = {[false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000"}},
    ["Rainbow Shock"] = {Legendary = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}, Mythic = {[false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000"}},
    ["Sigma Serpent"] = {Legendary = {[false] = " 1 in 10,000", [true] = " 1 in 400,000"}, Mythic = {[false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000"}},
    ["Manarium"] = {Legendary = {[false] = " 1 in 10,000", [true] = " 1 in 400,000"}, Mythic = {[false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000"}},
    -- Event Legendary Pet List
    ["Seraphic Bunny"] = {Legendary = {[false] = " 1 in 5,000", [true] = " 1 in 200,000"}, Mythic = {[false] = " 1 in 500,000", [true] = " 1 in 20,000,000"}},
    ["Ethereal Bunny"] = {Legendary = {[false] = " 1 in 100,000", [true] = " 1 in 4,000,000"}, Mythic = {[false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000"}},
    ["Cardinal Bunny"] = {Legendary = {[false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000"}, Mythic = {[false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000"}},
    ["Sweet Treat"] = {Legendary = {[false] = " 1 in 25,000", [true] = " 1 in 1,000,000"}, Mythic = {[false] = " 1 in 2,500,000", [true] = " 1 in 100,000,000"}},
    ["Rainbow Marshmellow"] = {Legendary = {[false] = " 1 in 125,000", [true] = " 1 in 5,000,000"}, Mythic = {[false] = " 1 in 12,500,000", [true] = " 1 in 500,000,000"}},
    ["Easter Serpent"] = {Legendary = {[false] = " 1 in 2,500", [true] = " 1 in 100,000"}, Mythic = {[false] = " 1 in 250,000", [true] = " 1 in 10,000,000"}},
    ["Dualcorn"] = {Legendary = {[false] = " 1 in 50,000", [true] = " 1 in 2,000,000"}, Mythic = {[false] = " 1 in 5,000,000", [true] = " 1 in 200,000,000"}},
    ["Holy Egg"] = {Legendary = {[false] = " 1 in 500,000", [true] = " 1 in 20,000,000"}, Mythic = {[false] = " 1 in 50,000,000", [true] = " 1 in 2,000,000,000"}},
}

local function sendWebhook(name, rarity, shiny, image)
    local title, rarityLower = "🐾 Pet Hatched!", rarity:lower()
    isShiny = shiny and "Yes" or "No"
    
    local petType = table.find(petConfig.Secret, name) and "Secret" or table.find(petConfig.Legendary, name) and "Legendary"
    local isMythic = rarityLower:find("mythic")
    local emojis = {Secret = "🔥", Legendary = "⭐", Mythic = "💎", Shiny = "✨"}
    local parts = {}

    if petType then
        if isMythic then
            table.insert(parts, emojis.Mythic)
        else
            table.insert(parts, emojis[petType])
        end
        if shiny then
            table.insert(parts, emojis.Shiny)
        end
        local reversedParts = {}
        for i = #parts, 1, -1 do
            table.insert(reversedParts, parts[i])
        end
        petTitle = table.concat(parts).." "..petType..
                   (isMythic and " Mythic" or "")..
                   " Pet Hatched "..table.concat(reversedParts)
    end

    local time = os.time()
    petChance = chances[name] and chances[name][rarity] and chances[name][rarity][shiny] or petChance
    local desc = string.format("🐾 **Pet Name :** %s 🐾\n💎 **Rarity :** %s 💎\n❓ **Chance :**%s ❓\n🕛 **Catch Date :** <t:%s:F>", name, rarity, petChance, time)

    local totalHatches = "N/A"
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local hatches = leaderstats:FindFirstChild("🥚 Hatches")
        if hatches and hatches:IsA("IntValue") then
            totalHatches = formatNumber(hatches.Value)
        end
    end

    local currentCoins = "N/A"
    local coinsHud = player.PlayerGui.ScreenGui.HUD.Left.Currency.Coins:FindFirstChild("Frame")
    if coinsHud then
        local coins = coinsHud:FindFirstChild("Label")
        if coins and coins:IsA("TextLabel") then
            local text = coins.Text
            local numberPart, suffix = text:match("([%d,.]+)([%a]*)")
            if numberPart then
                local cleanedNumberPart = numberPart:gsub(",", "") 
                local rawNumber = tonumber(cleanedNumberPart)
                if suffix:lower() == "b" then
                    rawNumber = rawNumber * 1e9
                end
                currentCoins = abbreviateNumber(rawNumber)
            end
        end
    end
    
    local data = {
        ["content"] = "<@" .. getgenv().Config.UserID .. ">",
        ["embeds"] = {{
            ["title"] = petTitle,
            ["description"] = desc,
            ["color"] = 16711680,
            ["footer"] = {
                ["text"] = "Pet Hatched By : " .. player.Name .. " | 🥚 Total Hatches : " .. totalHatches .. " | 💰 Coins Left : " .. currentCoins
            },
            ["thumbnail"] = {
                ["url"] = image or fallbackImage
            }
        }}
    }

    httpRequest({
        Url = getgenv().Config.HatchWebhookLink,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })
end

local function monitorHatch()
    local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("ScreenGui")
    if not gui then return end

    local hatch = gui:FindFirstChild("Hatching")
    if not hatch then return end

    for _, frame in ipairs(hatch:GetChildren()) do
        if frame:IsA("Frame") and frame:FindFirstChild("Label") and frame:FindFirstChild("Rarity") then
            local name = frame.Label.Text
            local rarity = frame.Rarity.Text
            local shiny = frame.Shiny.Visible
            local chance = frame:FindFirstChild("Chance") and frame.Chance.Text or nil
            local rarityLower = rarity:lower()

            if rarityLower:find("legendary") or rarityLower:find("secret") or rarityLower:find("mythic") then
                if not isRecentFrame(frame) then
                    local image = petImages[name] or fallbackImage
                    sendWebhook(name, rarity, shiny, image, chance)
                end
            end
        end
    end
end

local autochewbubble         = false
local autoChests             = false
local autoAlienShop          = false
local autoshardShop          = false
local openingEggs            = false
local tpToEggs               = false
local autoPlaytime           = false
local autotickets            = false
local selectedEgg            = nil
local hatchingEggs           = 1
local plrPos = nil
local autoGoldenChest        = false
local goldenChecked          = false
local goldenPos              = nil
local autoRoyalChest         = false
local royalChecked           = false
local royalPos               = nil

local automystery            = false

local selectedEnchant        = nil

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
    argspawn() 
end)

local area1 = Teleport:addButton("Area 1 - Floating Island", function(tp) 
    argArea1() 
end)

local area2 = Teleport:addButton("Area 2 - Outer Space", function(tp)
    argArea2() 
end)

local area3 = Teleport:addButton("Area 3 - Twilight", function(tp)
    argArea3()   
end)

local area4 = Teleport:addButton("Area 4 - The Void", function(tp)
    argArea4()    
end)

local area5 = Teleport:addButton("Area 5 - Zen", function(tp)
    argArea5() 
end)


local Autoopeneggs = Window:addPage("Eggs", 5012544693)
local eggstuff = Autoopeneggs:addSection("Hatch (You must be near egg!)")
local egg = eggstuff:addDropdown("Eggs", {"Infinity Egg","Throwback Egg","Bunny Egg","Pastel Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(selected)
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
                task.wait(0.1)
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
        elseif selectedEgg == "Bunny Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-405, 12013, -59)
                    task.wait(1)
                end
            end)
        elseif selectedEgg == "Pastel Egg" then
            argspawn()
            task.wait(1.5)
            task.spawn(function()
                while tpToEggs do
                    tppos(-390, 12013, -59)
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

--local Enchants = Window:addPage("Enchants", 5012544693)
--local enchanting = Enchants:addSection("Enchanting")
--local enchantlist = enchanting:addDropdown("Enchantment list", {"⚡ Team Up I","⚡ Team Up II","⚡ Team Up III","⚡ Team Up IV","⚡ Team Up V","💰 Looter I","💰 Looter II","💰 Looter III","💰 Looter IV","💰 Looter V","🫧 Bubbler I","🫧 Bubbler II","🫧 Bubbler III","🫧 Bubbler IV","🫧 Bubbler V","✨ Gleaming I","✨ Gleaming II", "✨ Gleaming III"}, function(eSelected)
--    selectedEnchant = eSelected
--end)

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

local rtPart = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local function playerPos(plrCheck)
    local plarPos = rtPart.Position
    local plPos = Vector3.new(
        math.floor(plarPos.X + 0.5),
        math.floor(plarPos.Y + 0.5),
        math.floor(plarPos.Z + 0.5)
    )
    plrPos = Vector3.new(plPos.X, plPos.Y, plPos.Z)
    print("Player Position: X=" .. plrPos.X .. ", Y=" .. plrPos.Y .. ", Z=" .. plrPos.Z)
end

local goldenPos = nil
local function goldenCheck(gCheck)
    local pos = workspace.Rendered.Rifts["golden-chest"].Chest.WorldPivot.Position 
    local gPos = Vector3.new(
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
        print("Position not within defined area ranges.")
    end
    if area ~= nil then
        task.wait(2)
    end
    goldenPos = Vector3.new(gPos.X, gPos.Y, gPos.Z)
    print("Golden Chest Position: X=" .. goldenPos.X .. ", Y=" .. goldenPos.Y .. ", Z=" .. goldenPos.Z)
end

local royalPos = nil
local function royalCheck(rCheck)
    local pos = workspace.Rendered.Rifts["golden-chest"].Chest.WorldPivot.Position 
    local rPos = Vector3.new(
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
        print("Position not within defined area ranges.")
    end
    if area ~= nil then
        task.wait(2)
    end
    royalPos = Vector3.new(rPos.X, rPos.Y, rPos.Z)
    print("Royal Chest Position: X=" .. royalPos.X .. ", Y=" .. royalPos.Y .. ", Z=" .. royalPos.Z)
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

local autogChest = miscstuff:addToggle("Auto Open Golden Chest", false, function(on)
    if on then
        autoGoldenChest = true
        task.spawn(function()
            while autoGoldenChest do
                local gchest = workspace.Rendered.Rifts["golden-chest"]:FindFirstChild("Chest")
                local goldenKey = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Items.Main.ScrollingFrame.Powerups.Items:FindFirstChild("Golden Key")
                if not goldenChecked and gchest and goldenKey.Visible then
                    goldenCheck()
                    print("Golden Chest Position: X=" .. goldenPos.X .. ", Y=" .. goldenPos.Y .. ", Z=" .. goldenPos.Z)
                    playerPos()
                    tppos(goldenPos.X, plrPos.Y, goldenPos.Z)
                    wait(5)
                    tppos(goldenPos.X, goldenPos.Y + 10, goldenPos.Z)
                    goldenChecked = true
                end
                if gchest and goldenKey.Visible then
                    local args = {
                        [1] = "UnlockRiftChest",
                        [2] = "golden-chest",
                        [3] = false
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    task.wait(5)
                else
                    print("Chest not found or no Golden Key")
                    task.wait(10)
                    goldenChecked = false
                end
            end
        end)
    else
        autoGoldenChest = false
        goldenChecked = false
    end
end)

local autorChest = miscstuff:addToggle("Auto Open Royal Chest", false, function(on)
    if on then
        autoRoyalChest = true
        task.spawn(function()
            while autoRoyalChest do
                local rchest = workspace.Rendered.Rifts["royal-chest"]:FindFirstChild("Chest")
                local royalKey = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Items.Main.ScrollingFrame.Powerups.Items:FindFirstChild("Royal Key")
                if not royalChecked and rchest and royalKey.Visible then
                    royalCheck()
                    print("Royal Chest Position: X=" .. royalPos.X .. ", Y=" .. royalPos.Y .. ", Z=" .. royalPos.Z)
                    playerPos()
                    tppos(royalPos.X, plrPos.Y, royalPos.Z)
                    wait(5)
                    tppos(royalPos.X, royalPos.Y + 10, royalPos.Z)
                    royalChecked = true 
                end
                if rchest and royalKey.Visible then
                    local args = {
                        [1] = "UnlockRiftChest",
                        [2] = "royal-chest",
                        [3] = false
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    print("Royal Chest unlocked!")
                    task.wait(3)
                else
                    print("Royal Chest or Royal Key missing!")
                    task.wait(10) 
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
                    -- make it click 10 times after gifts r uses.
                end
            end
        end)
    else
        automystery = false
    end
end)

local riftConnection = nil
local hatchConnection = nil
local Webhooks = Window:addPage("Webhook", 5012544693)
local webh = Webhooks:addSection("Webhooks")
local webletoggle = webh:addToggle("Send Lucky Rift Webhooks", false, function(on)
    if on then
        riftConnection = runService.RenderStepped:Connect(monitorRifts)
        print("Rifts Webhook turned on")
    else
        if riftConnection then
            riftConnection:Disconnect()
            riftConnection = nil
        end
        print("Rifts Webhook turned off")
    end
end)

local webhtoggle = webh:addToggle("Send Rare Hatches Webhooks", false, function(on)
    if on then
        hatchConnection = runService.RenderStepped:Connect(monitorHatch)
        print("Hatches Webhook turned on")
    else
        if hatchConnection then
            hatchConnection:Disconnect()
            hatchConnection = nil
        end
        print("Hatches Webhook turned off")
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
    autoChests             = false
    autoAlienShop          = false
    autoshardShop          = false
    openingEggs            = false
    tpToEggs               = false
    autoPlaytime           = false
    autotickets            = false
    selectedEgg            = nil
    hatchingEggs           = 1
    cg.DefaultPickupRadius = 10
    plrPos = nil
    autoGoldenChest        = false
    goldenChecked          = false
    goldenPos              = nil
    autoRoyalChest         = false
    royalChecked           = false
    royalPos               = nil

    automystery            = false

    Window.container:Destroy()
end)
