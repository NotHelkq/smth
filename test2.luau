if not game:IsLoaded() then
    print("Waiting for game to load...")
    game.Loaded:Wait()
    print("Loaded Game")
end
local player = game:GetService("Players").LocalPlayer
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event")
local remoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function")
local cg = require(game:GetService("ReplicatedStorage").Shared.Constants)
local goldenPos, royalPos, plrPos, riftConnection, hatchConnection = nil, nil, nil, nil, nil
local hatchingEggs = 1
local recentFrames = {}
local connections = {};
local webhLink = "nothing"
local rolePing = "nothing"
local rt = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local function tp(d) return function(x,y,z)
    if rt then game:GetService("TweenService"):Create(rt, TweenInfo.new(d), {CFrame = CFrame.new(x,y,z)}):Play() end
end end
local ttppos, tppos = tp(3), tp(10)
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
        {name = "event-1",       url = "bunnyEgg.luau"    },
        {name = "event-2",       url = "pastelEgg.luau"   },
        {name = "event-3",       url = "throwbackEgg.luau"},
        {name = "aura-egg",      url = "auraEgg.luau"     },
        {name = "spikey-egg",    url = "spikeyEgg.luau"   },
        {name = "magma-egg",     url = "magmaEgg.luau"    },
        {name = "crystal-egg",   url = "crystalEgg.luau"  },
        {name = "lunar-egg",     url = "lunarEgg.luau"    },
        {name = "void-egg",      url = "voidEgg.luau"     },
        {name = "hell-egg",      url = "hellEgg.luau"     },
        {name = "nightmare-egg", url = "nightmareEgg.luau"},
        {name = "rainbow-egg",   url = "rainbowEgg.luau"  },
        {name = "golden-chest",  url = "goldenChest.luau" },
        {name = "royal-chest",   url = "royalChest.luau"  },
        {name = "bubble-rift",   url = "bubbleRift.luau"  }
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
    ["MAN FACE GOD"]            = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1b/MAN_FACE_GOD.png",
    ["The Overlord"]            = "https://static.wikia.nocookie.net/bgs-infinity/images/c/c0/The_Overlord.png",
    ["King Doggy"]              = "https://static.wikia.nocookie.net/bgs-infinity/images/a/a8/King_Doggy.png",
    -- Event Secret Pet List
    ["Godly Gem"]               = "https://static.wikia.nocookie.net/bgs-infinity/images/1/18/Godly_Gem.png",
    ["Dementor"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/5/58/Dementor.png",
    ["Giant Chocolate Chicken"] = "https://static.wikia.nocookie.net/bgs-infinity/images/e/ef/Giant_Chocolate_Chicken.png",
    ["Easter Basket"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/0/00/Easter_Basket.png",
    -- Legendary Pet List
    ["Emerald Golem"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/8/8f/Emerald_Golem.png",
    ["Inferno Dragon"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/0/06/Inferno_Dragon.png",
    ["Flying Pig"]              = "https://static.wikia.nocookie.net/bgs-infinity/images/1/18/Flying_Pig.png",
    ["Unicorn"]                 = "https://static.wikia.nocookie.net/bgs-infinity/images/7/7e/Unicorn.png",
    ["Lunar Serpent"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/5/50/Lunar_Serpent.png",
    ["Electra"]                 = "https://static.wikia.nocookie.net/bgs-infinity/images/a/a0/Electra.png",
    ["Dark Phoenix"]            = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1c/Dark_Phoenix.png",
    ["Neon Elemental"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/1/11/Neon_Elemental.png",
    ["NULLVoid"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/9/98/NULLVoid.png",
    ["Inferno Cube"]            = "https://static.wikia.nocookie.net/bgs-infinity/images/0/0d/Inferno_Cube.png",
    ["Virus"]                   = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1d/Virus.png",
    ["Green Hydra"]             = "https://static.wikia.nocookie.net/bgs-infinity/images/b/bc/Green_Hydra.png",
    ["Demonic Hydra"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/1/17/Demonic_Hydra.png",
    ["Hexarium"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/8/89/Hexarium.png",
    ["Rainbow Shock"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/c/c6/Rainbow_Shock.png",
    ["Sigma Serpent"]           = "https://static.wikia.nocookie.net/bgs-infinity/images/3/3d/Sigma_Serpent.png",
    ["Manarium"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/5/5d/Manarium.png",
    -- Event Legendary Pet List
    ["Seraphic Bunny"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/d/d7/Seraphic_Bunny.png",
    ["Ethereal Bunny"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/b/b9/Ethereal_Bunny.png",
    ["Cardinal Bunny"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/3/33/Cardinal_Bunny.png",
    ["Sweet Treat"]             = "https://static.wikia.nocookie.net/bgs-infinity/images/0/0e/Sweet_Treat.png",
    ["Rainbow Marshmellow"]     = "https://static.wikia.nocookie.net/bgs-infinity/images/1/14/Rainbow_Marshmellow.png",
    ["Easter Serpent"]          = "https://static.wikia.nocookie.net/bgs-infinity/images/c/cd/Easter_Serpent.png",
    ["Dualcorn"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/b/bc/Dualcorn.png",
    ["Holy Egg"]                = "https://static.wikia.nocookie.net/bgs-infinity/images/d/d7/Holy_Egg.png"
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
    ["MAN FACE GOD"]            = {Secret    = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    ["The Overlord"]            = {Secret    = {[false] = " 50,000,000",    [true] = " 2,000,000,000" },   Mythic = {[false] = " 5,000,000,000",   [true] = " 200,000,000,000"   }},
    ["King Doggy"]              = {Secret    = {[false] = " 100,000,000",   [true] = " 4,000,000,000" },   Mythic = {[false] = " 10,000,000,000",  [true] = " 400,000,000,000"   }},
    -- Event Secret Pet List
    ["Giant Chocolate Chicken"] = {Secret    = {[false] = " 50,000,000",    [true] = " 2,000,000,000" },   Mythic = {[false] = " 5,000,000,000",   [true] = " 200,000,000,000"   }},
    ["Easter Basket"]           = {Secret    = {[false] = " 100,000,000",   [true] = " 4,000,000,000" },   Mythic = {[false] = " 10,000,000,000",  [true] = " 400,000,000,000"   }},
    ["Godly Gem"]               = {Secret    = {[false] = " 250,000,000",   [true] = " 10,000,000,000"},   Mythic = {[false] = " 25,000,000,000",  [true] = " 1,000,000,000,000" }},
    ["Dementor"]                = {Secret    = {[false] = " 1,000,000,000", [true] = " 40,000,000,000"},   Mythic = {[false] = " 100,000,000,000", [true] = " 4,000,000,000,000" }},
    -- Legendary Pet List
    ["Emerald Golem"]           = {Legendary = {[false] = " 200",           [true] = " 8,000"         },   Mythic = {[false] = " 20,000",          [true] = " 800,000"           }},
    ["Inferno Dragon"]          = {Legendary = {[false] = " 400",           [true] = " 16,000"        },   Mythic = {[false] = " 40,000",          [true] = " 1,600,000"         }},
    ["Unicorn"]                 = {Legendary = {[false] = " 400",           [true] = " 16,000"        },   Mythic = {[false] = " 40,000",          [true] = " 1,600,000"         }},
    ["Lunar Serpent"]           = {Legendary = {[false] = " 400",           [true] = " 16,000"        },   Mythic = {[false] = " 40,000",          [true] = " 1,600,000"         }},
    ["Flying Pig"]              = {Legendary = {[false] = " 1,000",         [true] = " 40,000"        },   Mythic = {[false] = " 100,000",         [true] = " 4,000,000"         }},
    ["Electra"]                 = {Legendary = {[false] = " 1,000",         [true] = " 40,000"        },   Mythic = {[false] = " 100,000",         [true] = " 4,000,000"         }},
    ["Dark Phoenix"]            = {Legendary = {[false] = " 2,000",         [true] = " 80,000"        },   Mythic = {[false] = " 200,000",         [true] = " 8,000,000"         }},
    ["Inferno Cube"]            = {Legendary = {[false] = " 4,000",         [true] = " 160,000"       },   Mythic = {[false] = " 400,000",         [true] = " 16,000,000"        }},
    ["Neon Elemental"]          = {Legendary = {[false] = " 5,000",         [true] = " 200,000"       },   Mythic = {[false] = " 500,000",         [true] = " 20,000,000"        }},
    ["Sigma Serpent"]           = {Legendary = {[false] = " 10,000",        [true] = " 400,000"       },   Mythic = {[false] = " 1,000,000",       [true] = " 40,000,000"        }},
    ["Manarium"]                = {Legendary = {[false] = " 20,000",        [true] = " 800,000"       },   Mythic = {[false] = " 2,000,000",       [true] = " 80,000,000"        }},
    ["Green Hydra"]             = {Legendary = {[false] = " 25,000",        [true] = " 1,000,000"     },   Mythic = {[false] = " 2,500,000",       [true] = " 100,000,000"       }},
    ["Virus"]                   = {Legendary = {[false] = " 50,000",        [true] = " 2,000,000"     },   Mythic = {[false] = " 5,000,000",       [true] = " 200,000,000"       }},
    ["Demonic Hydra"]           = {Legendary = {[false] = " 100,000",       [true] = " 4,000,000"     },   Mythic = {[false] = " 10,000,000",      [true] = " 400,000,000"       }},
    ["Hexarium"]                = {Legendary = {[false] = " 100,000",       [true] = " 4,000,000"     },   Mythic = {[false] = " 10,000,000",      [true] = " 400,000,000"       }},
    ["Rainbow Shock"]           = {Legendary = {[false] = " 200,000",       [true] = " 8,000,000"     },   Mythic = {[false] = " 20,000,000",      [true] = " 800,000,000"       }},
    ["NULLVoid"]                = {Legendary = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    -- Event Legendary Pet List
    ["Easter Serpent"]          = {Legendary = {[false] = " 2,500",         [true] = " 100,000"       },   Mythic = {[false] = " 250,000",         [true] = " 10,000,000"        }},
    ["Seraphic Bunny"]          = {Legendary = {[false] = " 5,000",         [true] = " 200,000"       },   Mythic = {[false] = " 500,000",         [true] = " 20,000,000"        }},
    ["Sweet Treat"]             = {Legendary = {[false] = " 25,000",        [true] = " 1,000,000"     },   Mythic = {[false] = " 2,500,000",       [true] = " 100,000,000"       }},
    ["Dualcorn"]                = {Legendary = {[false] = " 50,000",        [true] = " 2,000,000"     },   Mythic = {[false] = " 5,000,000",       [true] = " 200,000,000"       }},
    ["Ethereal Bunny"]          = {Legendary = {[false] = " 100,000",       [true] = " 4,000,000"     },   Mythic = {[false] = " 10,000,000",      [true] = " 400,000,000"       }},
    ["Rainbow Marshmellow"]     = {Legendary = {[false] = " 125,000",       [true] = " 5,000,000"     },   Mythic = {[false] = " 12,500,000",      [true] = " 500,000,000"       }},
    ["Holy Egg"]                = {Legendary = {[false] = " 500,000",       [true] = " 20,000,000"    },   Mythic = {[false] = " 50,000,000",      [true] = " 2,000,000,000"     }},
    ["Cardinal Bunny"]          = {Legendary = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
}
local function sendWebhook(name, rarity, shiny, image)
    if name == "Emerald Golem" or name == "Inferno Dragon" or name == "Unicorn" or name == "Flying Pig" or name == "Lunar Serpent" or name == "Electra" or name == "Dark Phoenix" or name == "Inferno Cube" or name == "Easter Serpent" then
        rolePing = "1364988111549108234"
        webhLink = getgenv().Config.t1HatchWebhook
    elseif name == "Neon Elemental" or name == "Green Hydra" or name == "Sigma Serpent" or name == "Manarium" or name == "Sweet Treat" then
        rolePing = "1364988196521246782"
        webhLink = getgenv().Config.t2HatchWebhook
    elseif name == "NULLVoid" or name == "Virus" or name == "Demonic Hydra" or name == "Hexarium" or name == "Rainbow Shock" or name == "Ethereal Bunny" or name == "Cardinal Bunny" or name == "Rainbow Marshmellow" or name == "Dualcorn" or name == "Holy Egg" then
        rolePing = "1364988212115931236"
        webhLink = getgenv().Config.t3HatchWebhook
    elseif name == "King Doggy" or name == "The Overlord" or name == "MAN FACE GOD" or name == "Giant Chocolate Chicken" or name == "Easter Basket" or name == "Godly Gem" or name == "Dementor" then
        rolePing = "1364988235000057926"
        webhLink = getgenv().Config.t3HatchWebhook
    end
    local title, rarityLower = "🐾 Pet Hatched!", rarity:lower()
    isShiny = shiny and "Yes" or "No"
    local petType = table.find(petConfig.Secret, name) and "Secret" or table.find(petConfig.Legendary, name) and "Legendary"
    local isMythic = rarityLower:find("mythic")
    local emojis = {Secret = "🔥", Legendary = "⭐", Mythic = "💎", Shiny = "✨"}
    local parts = {}
    local shinyStatus = ""
    if isShiny == "Yes" then
        shinyStatus = "Shiny "
    else
        shinyStatus = ""
    end
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
        petTitle = table.concat(parts).." "..shinyStatus..(isMythic and " Mythic " or "")..petType.." Pet Hatched "..table.concat(reversedParts)
    end
    local time = os.time()
    petChance = chances[name] and chances[name][rarity] and chances[name][rarity][shiny] or petChance
    local desc = string.format("🐾 **Pet Name :** %s 🐾\n💎 **Rarity :** %s 💎\n❓ **Chance : **1 in%s ❓\n🕛 **Catch Date :** <t:%s:F>", name, rarity, petChance, time)
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
        ["content"] = "<@&" .. rolePing .. ">",
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
        Url = webhLink,
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

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()
local Window = library.new()
local Main = Window:addPage("Auto Farm", 5012544693)
local Farm = Main:addSection("Auto Farm")
Farm:addToggle("Auto Bubble", false, function(t)
    autobubbleRunning = t
    while autobubbleRunning do
        remoteEvent:FireServer("BlowBubble")
        task.wait(0.25)
    end
end)
Farm:addToggle("Auto Collect Coins/Gems", false, function(t)
    cg.DefaultPickupRadius = t and 9999999999999999999999 or 10
end)
Farm:addToggle("Auto Claim Void/Giant Chest", false, function(t)
    autovgcRunning = t
    while autovgcRunning do
        remoteEvent:FireServer("ClaimChest", "Void Chest", true)
        task.wait(1)
        remoteEvent:FireServer("ClaimChest", "Giant Chest", true)
        task.wait(5)
    end
end)
local function createShopToggle(name, shop, delay)
    Farm:addToggle("Auto Buy "..name, false, function(t)
        autobuymRunning = t
        while autobuymRunning do
            for i = 1, 3 do
                remoteEvent:FireServer("BuyShopItem", shop, i)
                task.wait(delay)
            end
        end
    end)
end
createShopToggle("Alien Merchant", "alien-shop", 0.75)
createShopToggle("Black Market", "shard-shop", 1.5)

local function teleportTo(path)
    remoteEvent:FireServer("Teleport", path)
end
local argspawn = function() teleportTo("Workspace.Worlds.The Overworld.PortalSpawn") end
local argArea1 = function() teleportTo("Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn") end
local argArea2 = function() teleportTo("Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn") end
local argArea3 = function() teleportTo("Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn") end
local argArea4 = function() teleportTo("Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn") end
local argArea5 = function() teleportTo("Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn") end
local argEaster = function() teleportTo("Workspace.Event.Portal.Spawn") end
local tpButtons = {{name = "Spawn", func = argspawn},{name = "Area 1 - Floating Island", func = argArea1},{name = "Area 2 - Outer Space", func = argArea2},{name = "Area 3 - Twilight", func = argArea3},{name = "Area 4 - The Void", func = argArea4},{name = "Area 5 - Zen", func = argArea5}}
local Teleport = Main:addSection("Teleport")
for _, btn in ipairs(tpButtons) do
    Teleport:addButton(btn.name, function() btn.func() end)
end

local eggData = {
    ["Infinity Egg"]  = {argspawn,  {-96, 10, -27    }},
    ["Throwback Egg"] = {argEaster, {-385, 12013, -58}},
    ["Bunny Egg"]     = {argEaster, {-396, 12013, -58}},
    ["Pastel Egg"]    = {argEaster, {-408, 12013, -58}},
    ["Common Egg"]    = {argspawn,  {-7, 11, -82     }},
    ["Spotted Egg"]   = {argspawn,  {-7, 11, -71     }},
    ["Iceshard Egg"]  = {argspawn,  {-7, 11, -60     }},
    ["Spikey Egg"]    = {argArea1,  {-8, 424, 158    }},
    ["Magma Egg"]     = {argArea2,  {-17, 2666, 9    }},
    ["Crystal Egg"]   = {argArea2,  {-19, 2666, 19   }},
    ["Lunar Egg"]     = {argArea3,  {-58, 6865, 81   }},
    ["Void Egg"]      = {argArea4,  {6, 10149, 188   }},
    ["Hell Egg"]      = {argArea4,  {-6, 10149, 192  }},
    ["Nightmare Egg"] = {argArea4,  {-20, 10149, 184 }},
    ["Rainbow Egg"]   = {argArea5,  {-35, 15974, 44  }}
}
local eggStuff = Window:addPage("Eggs", 5012544693)
local eggs = eggStuff:addSection("Hatch (You must be near egg!)")
eggs:addDropdown("Eggs", {"Infinity Egg","Throwback Egg","Bunny Egg","Pastel Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(e)
    selectedEgg = e
end)
eggs:addSlider("Open Amount", 1, 1, 6, function(n)
    hatchingEggs = n
end)
eggs:addToggle("Open Eggs", false, function(t)
    openingEggs = t
    while t and openingEggs do
        remoteEvent:FireServer("HatchEgg", selectedEgg, hatchingEggs)
        task.wait(0.1)
    end
end)
eggs:addToggle("Teleport to Egg", false, function(t)
    tpToEggs = t
    if not t or not eggData[selectedEgg] then return end
    eggData[selectedEgg][1]()
    task.wait(1.5)
    while tpToEggs do
        tppos(unpack(eggData[selectedEgg][2]))
        task.wait(1)
    end
end)
local function checkGiftsFolder(f)
    if not f then return print("Gifts folder missing") end
    local names = {}
    for _, child in ipairs(f:GetChildren()) do table.insert(names, child.Name) end
    print(#names > 0 and "Gifts found: "..table.concat(names, ", ") or "No gifts found")
    return #names > 0
end
local function playerPos()
    local rp = rt.Position
    local plPos = Vector3.new(math.floor(rp.X + 0.5), math.floor(rp.Y + 0.5), math.floor(rp.Z + 0.5))
    plrPos = Vector3.new(plPos.X, plPos.Y, plPos.Z)
    print("Player Position: X = " .. plrPos.X .. ", Y = " .. plrPos.Y .. ", Z = " .. plrPos.Z)
end
local function handleArea(y)
    if y < 410 then return argArea1() or "a1"
    elseif y < 2650 then return argArea2() or "a2"
    elseif y < 6850 then return argArea3() or "a3"
    elseif y < 10130 then return argArea4() or "a4"
    elseif y <= 15960 then return argArea5() or "a5"
    else
        return nil
    end
end
local function checkChest(chestType, label)
    local pos = workspace.Rendered.Rifts[chestType].Chest.WorldPivot.Position
    local rounded = Vector3.new(math.floor(pos.X + 0.5), math.floor(pos.Y + 0.5), math.floor(pos.Z + 0.5))   
    handleArea(pos.Y)
    local position = Vector3.new(rounded.X, rounded.Y, rounded.Z)
    return position
end
function goldenCheck() goldenPos = checkChest("golden-chest", "Golden") end
function royalCheck() royalPos = checkChest("royal-chest", "Royal") end

local chestConfigs = {{name = "Golden", type = "golden-chest", key = "Golden Key", check = goldenCheck, getPos = function() return goldenPos end, checkedVar = goldenChecked, autoVar = autoGoldenChest, waitTime = 5}, {name = "Royal", type = "royal-chest", key = "Royal Key", check = royalCheck, getPos = function() return royalPos end, checkedVar = royalChecked, autoVar = autoRoyalChest, waitTime = 3}}
local Misc = Window:addPage("Misc", 5012544693)
local misc = Misc:addSection("Misc")
misc:addButton("Unlock All Areas", function()
    for _, pos in ipairs({{-16,423,143}, {42,2663,-6}, {-78,6862,88}, {16,10146,152}, {36,15972,42}}) do
        ttppos(unpack(pos))
        task.wait(3)
    end
end)
misc:addToggle("Auto Claim Playtime Rewards", false, function(t)
    autoprRunning = t
    while autoprRunning do
        for i = 1, 9 do
            remoteFunction:InvokeServer("ClaimPlaytime", i)
            task.wait(3)
        end
    end
end)
misc:addToggle("Auto Claim Wheel Spin", false, function(t)
    autowpRunning = t
    while autowpRunning do
        remoteEvent:FireServer("ClaimFreeWheelSpin")
        task.wait(10)
    end
end)
for _, cfg in pairs(chestConfigs) do
    misc:addToggle("Auto Open "..cfg.name.." Chest", false, function(on)
        cfg.autoVar = on
        cfg.checkedVar = false
        task.spawn(function()
            while cfg.autoVar do
                local chest = workspace.Rendered.Rifts[cfg.type]:FindFirstChild("Chest")
                if not cfg.checkedVar and chest then
                    cfg.check()
                    local pos = cfg.getPos()
                    print(cfg.name.." Chest Position: X = "..pos.X..", Y = "..pos.Y..", Z = "..pos.Z)
                    wait(1)
                    playerPos()
                    tppos(pos.X, plrPos.Y, pos.Z)
                    wait(5)
                    tppos(pos.X, pos.Y + 10, pos.Z)
                    cfg.checkedVar = true
                end
                if chest then
                    remoteEvent:FireServer("UnlockRiftChest", cfg.type, false)
                    task.wait(cfg.waitTime)
                else
                    print(cfg.name..(chest and " Key missing!" or " Chest not found!"))
                    task.wait(10)
                    cfg.checkedVar = false
                end
            end
        end)
    end)
end
misc:addToggle("Auto Open Mystery Box (Not auto)", false, function(t)
    automboxRunning = t
    while automboxRunning do
        remoteEvent:FireServer("UseGift", "Mystery Box", 10)
        task.wait(2)
        if checkGiftsFolder(workspace.Rendered.Gifts) then
            -- script to click 5-10 times. later
        end
    end
end)

local Webhooks = Window:addPage("Webhook", 5012544693)
local webh = Webhooks:addSection("Webhooks")
webh:addToggle("Send Lucky Rift Webhooks", false, function(t)
    if t then
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
webh:addToggle("Send Rare Hatches Webhooks", false, function(t)
    if t then
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
SetSec2:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function()
	Window:toggle()
end)
SetSec2:addButton("Boost FPS", function(fps)
    _G.Settings = {Players = {["Ignore Me"] = true, ["Ignore Others"] = true}, Meshes = {Destroy = false, LowDetail = true}, Images = {Invisible = true, LowDetail = false, Destroy = false}, ["No Particles"] = true, ["No Camera Effects"] = true, ["No Explosions"] = true, ["No Clothes"] = true, ["Low Water Graphics"] = true, ["No Shadows"] = true, ["Low Rendering"] = true, ["Low Quality Parts"] = true}
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/boost.luau"))()
end)
SetSec2:addButton("Kill Hub", function()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    if hatchConnection then
        hatchConnection:Disconnect()
        hatchConnection = nil
    end
    if riftConnection then
        riftConnection:Disconnect()
        riftConnection = nil
    end
    autobubbleRunning = false
    autovgcRunning = false
    autobuymRunning = false
    openingEggs = false
    tpToEggs = false
    autoprRunning = false
    autowpRunning = false
    automboxRunning = false
    autoGoldenChest = false
    autoRoyalChest = false
    Window.container:Destroy()
end)
