if not game:IsLoaded() then game.Loaded:Wait() end
local player = game:GetService("Players").LocalPlayer
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local cg = require(game:GetService("ReplicatedStorage").Shared.Constants)
local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event")
local remoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function")
local httpRequest = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
local goldenPos, royalPos, plrPos, riftConnection, hatchConnection = nil, nil, nil, nil, nil
local petTitle, petChance, isShiny = "Unknown Pet Hatched", " Unknown", "Maybe"
local webhLink, webhrLink, rolePing, shinyStatus = "nothing", "nothing", "nothing", ""
local hatchingEggs = getgenv().Config.open_Amount
local royalChecked, goldenChecked = false, false
local riftsFolder = workspace.Rendered.Rifts
local allRifts = riftsFolder:GetChildren()
local validRifts = {}
local recentFrames = {}
local connections = {};
local rt = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local function tp(d) return function(x,y,z)
    if rt then game:GetService("TweenService"):Create(rt, TweenInfo.new(d), {CFrame = CFrame.new(x,y,z)}):Play() end
end end
local fallbackImage = "https://static.wikia.nocookie.net/bgs-infinity/images/7/73/Common_Pet.png"
local ttppos, tppos = tp(3), tp(10)
local function teleportTo(path) remoteEvent:FireServer("Teleport", path) end
local argspawn = function(tp) teleportTo("Workspace.Worlds.The Overworld.PortalSpawn") end
local argArea1 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn") end
local argArea2 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn") end
local argArea3 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn") end
local argArea4 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn") end
local argArea5 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn") end
local tpButtons = {{name = "Spawn", func = argspawn},{name = "Area 1 - Floating Island", func = argArea1},{name = "Area 2 - Outer Space", func = argArea2},{name = "Area 3 - Twilight", func = argArea3},{name = "Area 4 - The Void", func = argArea4},{name = "Area 5 - Zen", func = argArea5}}
local function playerPos()
    local rp = rt.Position
    local plPos = Vector3.new(math.floor(rp.X + 0.5), math.floor(rp.Y + 0.5), math.floor(rp.Z + 0.5))
    plrPos = Vector3.new(plPos.X, plPos.Y, plPos.Z)
end
local function handleArea(y)
    if y < 410 then return argArea1() or "a1"
    elseif y < 2650 then return argArea2() or "a2"
    elseif y < 6850 then return argArea3() or "a3"
    elseif y < 10130 then return argArea4() or "a4"
    elseif y <= 15960 then return argArea5() or "a5"
    else return nil end
end
local function checkChest(chestType, label)
    local pos = workspace.Rendered.Rifts[chestType].Chest.WorldPivot.Position
    local rounded = Vector3.new(math.floor(pos.X + 0.5), math.floor(pos.Y + 0.5), math.floor(pos.Z + 0.5))   
    handleArea(pos.Y)
    local position = Vector3.new(rounded.X, rounded.Y, rounded.Z)
    return position
end
function goldenCheck() goldenPos = checkChest("golden-chest", "Golden") end
function royalCheck()  royalPos  = checkChest("royal-chest", "Royal") end
local eggData = {
    ["Infinity Egg"]  = {argspawn,  {-96, 10, -27    }},
    ["100M Egg"]      = {argspawn,  {16, 10, -4      }},
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
local function isRecentFrame(id)
    if recentFrames[id] and (tick() - recentFrames[id] < 5) then
        return true
    end
    recentFrames[id] = tick()
    return false
end
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
    else return tostring(number) end
end
local eggNames = {"spikey-egg", "magma-egg", "crystal-egg", "lunar-egg", "void-egg", "hell-egg", "nightmare-egg", "rainbow-egg"}
local eggColors = {["spikey-egg"] = 0x00FF00,["magma-egg"] = 0xFF4500,["crystal-egg"] = 0x00BFFF,["lunar-egg"] = 0x4B0082,["void-egg"] = 0x9400D3,["hell-egg"] = 0xFF0000,["nightmare-egg"] = 0x36393F,["rainbow-egg"] = 0xFF69B4}
local eggEmojis = {["spikey-egg"] = "🌵",["magma-egg"] = "🌋",["crystal-egg"] = "🔮",["lunar-egg"] = "🌙",["void-egg"] = "🌀",["hell-egg"] = "🔥",["nightmare-egg"] = "💀",["rainbow-egg"] = "🌈"}
local petConfig = {
    ["Secret"]    = {"King Doggy", "The Overlord", "Silly Doggy :)", "Silly Doggy", "Godly Gem", "Dementor", "Royal Trophy"},
    ["Legendary"] = {"Emerald Golem", "Inferno Dragon", "Unicorn", "Flying Pig", "Lunar Serpent", "Electra", "Dark Phoenix", "Neon Elemental", "NULLVoid", "Inferno Cube", "Virus", "Green Hydra", "Demonic Hydra", "Hexarium", "Rainbow Shock", "ROUND", "DOOF", "Easter Serpent", "Dualcorn", "Holy Egg", "Diamond Serpent", "Diamond Hexarium", "King Pufferfish"}
}
local chances = {
    -- Perm Pets
    -- Secret Pet List
    ["The Overlord"]            = {Secret    = {[false] = " 50,000,000",    [true] = " 2,000,000,000" },   Mythic = {[false] = " 5,000,000,000",   [true] = " 200,000,000,000"   }},
    ["King Doggy"]              = {Secret    = {[false] = " 100,000,000",   [true] = " 4,000,000,000" },   Mythic = {[false] = " 10,000,000,000",  [true] = " 400,000,000,000"   }},
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
    ["Green Hydra"]             = {Legendary = {[false] = " 25,000",        [true] = " 1,000,000"     },   Mythic = {[false] = " 2,500,000",       [true] = " 100,000,000"       }},
    ["Virus"]                   = {Legendary = {[false] = " 50,000",        [true] = " 2,000,000"     },   Mythic = {[false] = " 5,000,000",       [true] = " 200,000,000"       }},
    ["Demonic Hydra"]           = {Legendary = {[false] = " 100,000",       [true] = " 4,000,000"     },   Mythic = {[false] = " 10,000,000",      [true] = " 400,000,000"       }},
    ["Hexarium"]                = {Legendary = {[false] = " 100,000",       [true] = " 4,000,000"     },   Mythic = {[false] = " 10,000,000",      [true] = " 400,000,000"       }},
    ["Rainbow Shock"]           = {Legendary = {[false] = " 200,000",       [true] = " 8,000,000"     },   Mythic = {[false] = " 20,000,000",      [true] = " 800,000,000"       }},
    ["NULLVoid"]                = {Legendary = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    -- Event Pets
    -- Event Secret Pet List
    ["Silly Doggy"]             = {Secret    = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    ["Silly Doggy :)"]          = {Secret    = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    ["Royal Trophy"]            = {Secret    = {[false] = " 50,000,000",    [true] = " 2,000,000,000" },   Mythic = {[false] = " 5,000,000,000",   [true] = " 200,000,000,000"   }},
    -- Event Legendary Pet List
    ["Diamond Serpent"]         = {Legendary = {[false] = " 2,500",         [true] = " 100,000"       },   Mythic = {[false] = " 250,000",         [true] = " 10,000,000"        }},
    ["DOOF"]                    = {Legendary = {[false] = " 10,000",        [true] = " 400,000"       },   Mythic = {[false] = " 1,000,000",       [true] = " 40,000,000"        }},
    ["Diamond Hexarium"]        = {Legendary = {[false] = " 50,000",        [true] = " 2,000,000"     },   Mythic = {[false] = " 5,000,000",       [true] = " 200,000,000"       }},
    ["ROUND"]                   = {Legendary = {[false] = " 250,000",       [true] = " 10,000,000"    },   Mythic = {[false] = " 25,000,000",      [true] = " 1,000,000,000"     }},
    ["King Pufferfish"]         = {Legendary = {[false] = " 800,000",       [true] = " 32,000,000"    },   Mythic = {[false] = " 80,000,000",      [true] = " 3,200,000,000"     }},
}
local imageUrl = "https://static.wikia.nocookie.net/bgs-infinity/images/"
local petImages = {
    -- Secret Pet List
    ["The Overlord"]     = {Normal = imageUrl.."c/c0/The_Overlord.png",     Shiny = imageUrl.."e/ed/Shiny_The_Overlord.png",     Mythic = imageUrl.."a/aa/Mythic_The_Overlord.png",     ShinyMythic = imageUrl.."3/36/Shiny_Mythic_The_Overlord.png"     },
    ["King Doggy"]       = {Normal = imageUrl.."a/a8/King_Doggy.png",       Shiny = imageUrl.."5/5b/Shiny_King_Doggy.png",       Mythic = imageUrl.."7/78/Mythic_King_Doggy.png",       ShinyMythic = imageUrl.."5/52/Shiny_Mythic_King_Doggy.png"       },
    -- Legendary Pet List
    ["Emerald Golem"]    = {Normal = imageUrl.."8/8f/Emerald_Golem.png",    Shiny = imageUrl.."1/1a/Shiny_Emerald_Golem.png",    Mythic = imageUrl.."5/53/Mythic_Emerald_Golem.png",    ShinyMythic = imageUrl.."5/59/Shiny_Mythic_Emerald_Golem.png"    },
    ["Inferno Dragon"]   = {Normal = imageUrl.."0/06/Inferno_Dragon.png",   Shiny = imageUrl.."3/35/Shiny_Inferno_Dragon.png",   Mythic = imageUrl.."4/41/Mythic_Inferno_Dragon.png",   ShinyMythic = imageUrl.."c/cd/ShinyMythicInfernoDragon.png"      },
    ["Flying Pig"]       = {Normal = imageUrl.."1/18/Flying_Pig.png",       Shiny = imageUrl.."d/dd/Shiny_Flying_Pig.png",       Mythic = imageUrl.."4/45/Mythic_Flying_Pig.png",       ShinyMythic = imageUrl.."c/c6/Shiny_Mythic_Flying_Pig.png"       },
    ["Unicorn"]          = {Normal = imageUrl.."7/7e/Unicorn.png",          Shiny = imageUrl.."8/80/Shiny_Unicorn.png",          Mythic = imageUrl.."d/dc/Mythic_Unicorn.png",          ShinyMythic = imageUrl.."5/57/Shiny_Mythic_Unicorn.png"          },
    ["Lunar Serpent"]    = {Normal = imageUrl.."5/50/Lunar_Serpent.png",    Shiny = imageUrl.."9/93/Shiny_Lunar_Serpent.png",    Mythic = imageUrl.."f/f5/Mythic_Lunar_Serpent.png",    ShinyMythic = imageUrl.."0/08/Shiny_Mythic_Lunar_Serpent.png"    },
    ["Electra"]          = {Normal = imageUrl.."a/a0/Electra.png",          Shiny = imageUrl.."9/94/Shiny_Electra.png",          Mythic = imageUrl.."d/df/Mythic_Electra.png",          ShinyMythic = imageUrl.."3/38/Shiny_Mythic_Electra.png"          },
    ["Dark Phoenix"]     = {Normal = imageUrl.."1/1c/Dark_Phoenix.png",     Shiny = imageUrl.."c/cf/Shiny_Dark_Phoenix.png",     Mythic = imageUrl.."b/b0/Mythic_Dark_Phoenix.png",     ShinyMythic = imageUrl.."f/fc/Shiny_Mythic_Dark_Phoenix.png"     },
    ["Neon Elemental"]   = {Normal = imageUrl.."1/11/Neon_Elemental.png",   Shiny = imageUrl.."d/db/Shiny_Neon_Elemental.png",   Mythic = imageUrl.."b/ba/Mythic_Neon_Elemental.png",   ShinyMythic = imageUrl.."c/c1/Shiny_Mythic_Neon_Elemental.png"   },
    ["NULLVoid"]         = {Normal = imageUrl.."9/98/NULLVoid.png",         Shiny = imageUrl.."0/0c/Shiny_NULLVoid.png",         Mythic = imageUrl.."8/8e/Mythic_NULLVoid.png",         ShinyMythic = imageUrl.."1/18/Shiny_Mythic_NULLVoid.png"         },
    ["Inferno Cube"]     = {Normal = imageUrl.."0/0d/Inferno_Cube.png",     Shiny = imageUrl.."c/cc/Shiny_Inferno_Cube.png",     Mythic = imageUrl.."9/99/Mythic_Inferno_Cube.png",     ShinyMythic = imageUrl.."3/30/Shiny_Mythic_Inferno_Cube.png"     },
    ["Virus"]            = {Normal = imageUrl.."1/1d/Virus.png",            Shiny = imageUrl.."c/cf/Shiny_Virus.png",            Mythic = imageUrl.."7/71/Mythic_Virus.png",            ShinyMythic = imageUrl.."d/dd/Shiny_Mythic_Virus.png"            },
    ["Green Hydra"]      = {Normal = imageUrl.."b/bc/Green_Hydra.png",      Shiny = imageUrl.."4/40/Shiny_Green_Hydra.png",      Mythic = imageUrl.."6/6a/Mythic_Green_Hydra.png",      ShinyMythic = imageUrl.."0/06/Shiny_Mythic_Green_Hydra.png"      },
    ["Demonic Hydra"]    = {Normal = imageUrl.."1/17/Demonic_Hydra.png",    Shiny = imageUrl.."1/10/Shiny_Demonic_Hydra.png",    Mythic = imageUrl.."3/33/Mythic_Demonic_Hydra.png",    ShinyMythic = imageUrl.."f/f9/Shiny_Mythic_Demonic_Hydra.png"    },
    ["Hexarium"]         = {Normal = imageUrl.."8/89/Hexarium.png",         Shiny = imageUrl.."2/2f/Shiny_Hexarium.png",         Mythic = imageUrl.."0/02/Mythic_Hexarium.png",         ShinyMythic = imageUrl.."e/ea/Shiny_Mythic_Hexarium.png"         },
    ["Rainbow Shock"]    = {Normal = imageUrl.."c/c6/Rainbow_Shock.png",    Shiny = imageUrl.."8/8b/Shiny_Rainbow_Shock.png",    Mythic = imageUrl.."b/b8/Mythic_Rainbow_Shock.png",    ShinyMythic = imageUrl.."7/71/Shiny_Mythic_Rainbow_Shock.png"    },
    -- Event Secret Pet List
    ["Silly Doggy :)"]   = {Normal = imageUrl.."1/1d/Silly-doggy.png",      Shiny = imageUrl.."1/1d/Silly-doggy.png",            Mythic = imageUrl.."7/76/Mythic_Silly_Doggy.png",      ShinyMythic = imageUrl.."7/76/Mythic_Silly_Doggy.png"            },
    ["Silly Doggy"]      = {Normal = imageUrl.."1/1d/Silly-doggy.png",      Shiny = imageUrl.."1/1d/Silly-doggy.png",            Mythic = imageUrl.."7/76/Mythic_Silly_Doggy.png",      ShinyMythic = imageUrl.."7/76/Mythic_Silly_Doggy.png"            },
    ["Royal Trophy"]     = {Normal = imageUrl.."3/32/Royal_Trophy.png",     Shiny = imageUrl.."8/81/Shiny_Royal_Trophy.png",     Mythic = imageUrl.."1/16/Mythic_Royal_Trophy.png",     ShinyMythic = imageUrl.."6/6a/Shiny_Mythic_Royal_Trophy.png"     },
    -- Event Legendary Pet List
    ["DOOF"]             = {Normal = imageUrl.."3/34/DOOF.png",             Shiny = imageUrl.."7/77/Shiny_DOOF.png",             Mythic = imageUrl.."f/f1/Mythic_DOOF.png",             ShinyMythic = imageUrl.."1/1c/Shiny_Mythic_DOOF.png"             },
    ["ROUND"]            = {Normal = imageUrl.."2/24/ROUND.png",            Shiny = imageUrl.."f/fb/Shiny_ROUND.png",            Mythic = imageUrl.."b/b0/Mythic_ROUND.png",            ShinyMythic = imageUrl.."a/a6/Shiny_Mythic_ROUND.png"            },
    ["Diamond Serpent"]  = {Normal = imageUrl.."0/00/Diamond_Serpent.png",  Shiny = imageUrl.."d/d3/Shiny_Diamond_Serpent.png",  Mythic = imageUrl.."e/e2/Mythic_Diamond_Serpent.png",  ShinyMythic = imageUrl.."b/b8/Shiny_Mythic_Diamond_Serpent.png"  },
    ["Diamond Hexarium"] = {Normal = imageUrl.."2/2a/Diamond_Hexarium.png", Shiny = imageUrl.."8/86/Shiny_Diamond_Hexarium.png", Mythic = imageUrl.."8/8a/Mythic_Diamond_Hexarium.png", ShinyMythic = imageUrl.."b/b0/Shiny_Mythic_Diamond_Hexarium.png" },
    ["King Pufferfish"]  = {Normal = imageUrl.."c/c9/King_Pufferfish.png",  Shiny = imageUrl.."6/66/Shiny_King_Pufferfish.png",  Mythic = imageUrl.."2/2a/Mythic_King_Pufferfish.png",  ShinyMythic = imageUrl.."e/e0/Shiny_Mythic_King_Pufferfish.png"  }
}
local function getPetImage(name, isShiny, isMythic)
    local variants = petImages[name]
    if not variants then return fallbackImage end
    return variants.ShinyMythic and isShiny and isMythic and variants.ShinyMythic or variants.Mythic and isMythic and variants.Mythic or variants.Shiny and isShiny and variants.Shiny or variants.Normal or fallbackImage
end
local function sendWebhook(name, rarity, shiny, image)
    local tierMap = {
        ["Emerald Golem"]  = 1, ["Inferno Dragon"] = 1, ["Unicorn"]       = 1, ["Flying Pig"]  = 1, ["Lunar Serpent"]  = 1, ["Electra"]          = 1, ["Dark Phoenix"]    = 1, ["Inferno Cube"]     = 1, ["Diamond Serpent"] = 1,
        ["Neon Elemental"] = 2, ["Green Hydra"]    = 2, ["DOOF"]          = 2, 
        ["NULLVoid"]       = 3, ["Virus"]          = 3, ["Demonic Hydra"] = 3, ["Hexarium"]    = 3, ["Rainbow Shock"]  = 3, ["Diamond Hexarium"] = 3, ["King Pufferfish"] = 3,
        ["King Doggy"]     = 4, ["The Overlord"]   = 4, ["Royal Trophy"]  = 4, ["Silly Doggy"] = 4, ["Silly Doggy :)"] = 4
    }
    local tier = tierMap[name] or 3
    rolePing = ({"1364857484879073300", "1364857737485357067", "1364857776630923388", "1364881485827407912"})[tier]
    webhLink = getgenv().Config[({"t1HatchWebhook", "t2HatchWebhook", "t3HatchWebhook", "t3HatchWebhook"})[tier]]

    local title, rarityLower = "🐾 Pet Hatched!", rarity:lower()
    local emojis = {Secret = "🔥", Legendary = "⭐", Mythic = "💎", Shiny = "✨"}
    local petType = table.find(petConfig.Secret, name) and "Secret" or table.find(petConfig.Legendary, name) and "Legendary"
    local leaderstats,coinsHud = player:FindFirstChild("leaderstats"),player.PlayerGui.ScreenGui.HUD.Left.Currency.Coins:FindFirstChild("Frame")
    local totalHatches,currentCoins = "N/A","N/A"
    local isMythic = rarityLower:find("mythic")
    local isShiny = shiny and "Yes" or "No"
    local titleParts = {}

    if isShiny == "Yes" then shinyStatus = "Shiny " else shinyStatus = "" end
    if petType then
        local reversedParts = {}
        table.insert(titleParts, isMythic and emojis.Mythic or emojis[petType])
        if shiny then table.insert(titleParts, emojis.Shiny) end
        for i = #titleParts, 1, -1 do
            table.insert(reversedParts, titleParts[i])
        end
        petTitle = table.concat(titleParts).." "..shinyStatus..(isMythic and "Mythic " or "")..petType.." Pet Hatched "..table.concat(reversedParts)
    else petTitle = "🐾 Pet Hatched!" end
    if leaderstats then
        local hatches = leaderstats:FindFirstChild("🥚 Hatches")
        if hatches and hatches:IsA("IntValue") then
            totalHatches = formatNumber(hatches.Value)
        end
    end
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
            ["description"] = string.format("🐾 **Pet Name : **%s 🐾\n💎 **Pet Rarity : **%s 💎\n❓ **Chance : **1 in %s ❓\n🕛 **Hatch Date : **<t:%s:F> 🕛", name, rarity, chances[name] and chances[name][rarity] and chances[name][rarity][shiny] or "N/A", os.time()),
            ["color"] = 16711680,
            ["footer"] = {["text"] = "Pet Hatched By : " .. player.Name .. " | 🥚 Total Hatches : " .. totalHatches .. " | 💰 Coins Left : " .. currentCoins},
            ["thumbnail"] = {["url"] = getPetImage(name, shiny, isMythic) or fallbackImage}
        }}
    }
    httpRequest({Url = webhLink, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = httpService:JSONEncode(data)})
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
local function monitorRifts()
    local riftsFolder = workspace.Rendered.Rifts
    local riftList = {
        {name = "silly-egg",     url = "auraEgg.luau"     },
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
    local riftDict = {}
    for _, data in ipairs(riftList) do
        riftDict[data.name] = data
    end
    for _, rift in ipairs(riftsFolder:GetChildren()) do
        local riftData = riftDict[rift.Name]
        if riftData and rift:FindFirstChild("Output") then
            if not isRecentFrame(riftData.name) then
                local success, scriptContent = pcall(function()
                    return game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/" .. riftData.url)
                end)
                if success then
                    local loadedFunction = loadstring(scriptContent)
                    if type(loadedFunction) == "function" then
                        loadedFunction()
                        rift.Output:Destroy()
                    end
                end
            end
        end
    end
end
local function getRiftData(rift)
    local data = {}
    data.originalName = rift.Name 
    local nameParts = {}
    for part in rift.Name:gsub("-", " "):gmatch("%S+") do 
        table.insert(nameParts, part:sub(1,1):upper()..part:sub(2)) 
    end
    data.islandName = " "..table.concat(nameParts, " ")
    local platform = rift:FindFirstChild("EggPlatformSpawn")
    if not platform then return nil end
    local pos = platform.WorldPivot.Position
    data.rPos = Vector3.new(math.floor(pos.X + 0.5), math.floor(pos.Y + 0.5), math.floor(pos.Z + 0.5))
    local y = data.rPos.Y
    data.areaPos = if y >= 0 and y < 410 then "Area 0-1"
        elseif y >= 410 and y < 2650 then "Area 1-2"
        elseif y >= 2650 and y < 6850 then "Area 2-3"
        elseif y >= 6850 and y < 10130 then "Area 3-4"
        elseif y >= 10130 and y <= 15960 then "Area 4-5"
        else "Unknown Area"
    data.detectedTime = os.time()
    data.timeleft = "Unknown"
    local display = rift:FindFirstChild("Display")
    if display then
        local surfaceGui = display:FindFirstChild("SurfaceGui")
        if surfaceGui then
            data.luckText = surfaceGui:FindFirstChild("Icon") and surfaceGui.Icon:FindFirstChild("Luck")
            local timerText = surfaceGui:FindFirstChild("Timer")
            if timerText then
                data.timeleft = timerText.Text == "5".." Minutes" and "9".." minutes" or timerText.Text
            end
        end
    end
    return data
end
local function sendSingleEmbedWebhook(rifts)
    local embed = {title = "🥚 Active Egg Rifts 🥚",color = 0x00FFFF,description = string.format("**Total Rifts Found :** %d\n\n", #rifts),fields = {},}
    for _, riftData in ipairs(rifts) do
        local mainEmoji = eggEmojis[riftData.originalName:lower()] or "🥚"
        local fieldText = string.format("🍀 **Luck :** x%s 🍀\n".."❓ **Position :** %dm | %s ❓\n".."🕒 **Found :** <t:%d:T> 🕒\n".."⏳ **Despawn :** %s ⏳\n".."──────────────────────────",riftData.luckText and riftData.luckText.Text:gsub("x", "") or "??",riftData.rPos.Y,riftData.areaPos,riftData.detectedTime,riftData.timeleft)
        table.insert(embed.fields, {name = string.format("%s %s", mainEmoji, riftData.islandName),value = fieldText,inline = false})
    end
    if #rifts > 0 then embed.color = eggColors[rifts[1].originalName:lower()] or embed.color end
    local data = {["content"] = "",["embeds"] = {embed},}
    httpRequest({Url = webhrLink,Method = "POST",Headers = {["Content-Type"] = "application/json"},Body = httpService:JSONEncode(data)})
end
-- lib stuff
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()
local Window  = library.new("Bubble Gum Simulator Infinity")
local Main      = Window:addPage("Auto Farm", 5012544693, true)
local eggStuff  = Window:addPage("Eggs", 5012544693)
local MiscStuff = Window:addPage("Misc", 5012544693)
local Webhooks  = Window:addPage("Webhook", 5012544693)
local Settings  = Window:addPage("Settings", 5012544693)
local Farm      = Main:addSection("Auto Farm")
local Teleport  = Main:addSection("Teleport")
local eggs  = eggStuff:addSection("Hatch (You must be near egg!)")
local misc = MiscStuff:addSection("Misc")
local webh  = Webhooks:addSection("Webhooks")
local sett  = Settings:addSection("Others")
-- Auto Farm 
Farm:addToggle("Auto Bubble", getgenv().Config.auto_Bubble, function(t)
    autobubbleRunning = t
    while autobubbleRunning do
        remoteEvent:FireServer("BlowBubble")
        task.wait(0.25)
    end
end)
Farm:addToggle("Auto Collect Coins/Gems", getgenv().Config.auto_Collect_Coins, function(t)
    cg.DefaultPickupRadius = t and 9999999999999999999999 or 10
end)
Farm:addToggle("Auto Claim Void/Giant Chest", getgenv().Config.auto_Collect_Chests, function(t)
    autovgcRunning = t
    while autovgcRunning do
        remoteEvent:FireServer("ClaimChest", "Void Chest", true)
        task.wait(1)
        remoteEvent:FireServer("ClaimChest", "Giant Chest", true)
        task.wait(5)
    end
end)
Farm:addToggle("Auto Buy Alien Merchant", getgenv().Config.auto_Buy_Alien, function(t)
    autobuyAMRunning = t
    while autobuyAMRunning do
        for i = 1, 3 do
            remoteEvent:FireServer("BuyShopItem", "alien-shop", i)
            task.wait(1)
        end
    end
end)
Farm:addToggle("Auto Buy Black Market", getgenv().Config.auto_Buy_Black_Market, function(t)
    autobuyBMRunning = t
    while autobuyBMRunning do
        for i = 1, 3 do
            remoteEvent:FireServer("BuyShopItem", "shard-shop", i)
            task.wait(2)
        end
    end
end)
for _, btn in ipairs(tpButtons) do
    Teleport:addButton(btn.name, function() btn.func() end)
end
-- Eggs Stuff
eggs:addDropdown("Eggs", {"Infinity Egg","100M Egg","Common Egg","Spotted Egg","Iceshard Egg","Spikey Egg","Magma Egg","Crystal Egg","Lunar Egg","Void Egg","Hell Egg","Nightmare Egg","Rainbow Egg"}, function(e) selectedEgg = e end, getgenv().Config.open_Egg)
eggs:addSlider("Open Amount", getgenv().Config.open_Amount, 1, 6, function(n) hatchingEggs = n end)
eggs:addToggle("Open Eggs", getgenv().Config.auto_Open_Eggs, function(t)
    openingEggs = t
    while t and openingEggs do
        remoteEvent:FireServer("HatchEgg", selectedEgg, hatchingEggs)
        task.wait(0.1)
    end
end)
eggs:addToggle("Teleport to Egg", getgenv().Config.teleport_to_Egg, function(t)
    tpToEggs = t
    if not t or not eggData[selectedEgg] then return end
    eggData[selectedEgg][1](tp)
    task.wait(2)
    while tpToEggs do
        tppos(unpack(eggData[selectedEgg][2]))
        task.wait(1)
    end
end)
-- Misc Stuff
misc:addButton("Unlock All Areas", function()
    for i, v in next, game:GetService("Workspace").Worlds["The Overworld"].Islands:GetChildren() do
        firetouchinterest(v.Island.UnlockHitbox, player.Character.HumanoidRootPart, 0);
        task.wait();
        firetouchinterest(v.Island.UnlockHitbox, player.Character.HumanoidRootPart, 1);
        task.wait(0.3);
    end
end)
misc:addToggle("Auto Claim Playtime Rewards", getgenv().Config.auto_Claim_Playtime, function(t)
    autoprRunning = t
    while autoprRunning do
        for i = 1, 9 do
            remoteFunction:InvokeServer("ClaimPlaytime", i)
            task.wait(3)
        end
    end
end)
misc:addToggle("Auto Claim Wheel Spin", getgenv().Config.auto_Claim_Wheel_Spin, function(t)
    autowpRunning = t
    while autowpRunning do
        remoteEvent:FireServer("ClaimFreeWheelSpin")
        task.wait(10)
    end
end)
misc:addToggle("Auto Open Mystery Box", false, function(t)
    automboxRunning = t
    while automboxRunning do
        remoteEvent:FireServer("UseGift", "Mystery Box", 10)
        task.wait(2)
        for i, v in next, game:GetService("Workspace").Rendered.Gifts:GetChildren() do
            remoteEvent:FireServer("ClaimGift", v.Name);
            task.wait();
            v:Destroy();
        end;
    end
end)
misc:addToggle("Auto Open Golden Chest", false, function(t)
    autoGoldenChest = t
    goldenChecked = false
    wait(1)
    while autoGoldenChest do
        local gchest = workspace.Rendered.Rifts["golden-chest"]:FindFirstChild("Chest")
        if not goldenChecked and gchest then
            goldenCheck()
            wait(2)
            playerPos()
            tppos(goldenPos.X, plrPos.Y, goldenPos.Z)
            wait(5)
            tppos(goldenPos.X, goldenPos.Y + 10, goldenPos.Z)
            goldenChecked = true
        end
        if goldenChecked and gchest then
            remoteEvent:FireServer("UnlockRiftChest", "golden-chest", false)
            task.wait(2)
        else
            task.wait(10)
            goldenChecked = false
        end
    end
end)
misc:addToggle("Auto Open Royal Chest", false, function(t)
    autoGoldenChest = t
    royalChecked = false
    wait(1)
    while autoGoldenChest do
        local rchest = workspace.Rendered.Rifts["royal-chest"]:FindFirstChild("Chest")
        if not royalChecked and rchest then
            royalCheck()
            wait(2)
            playerPos()
            tppos(royalPos.X, plrPos.Y, royalPos.Z)
            wait(5)
            tppos(royalPos.X, royalPos.Y + 10, royalPos.Z)
            royalChecked = true
        end
        if royalChecked and rchest then
            remoteEvent:FireServer("UnlockRiftChest", "royal-chest", false)
            task.wait(2)
        else
            task.wait(10)
            royalChecked = false
        end
    end
end)
-- Webhooks
webh:addToggle("Send Current Rifts Webhooks", getgenv().Config.send_cRift_Webhook, function(t)
    sendCRW = t
    while sendCRW do
        for _, rift in ipairs(allRifts) do
            if table.find(eggNames, rift.Name) then
                local riftData = getRiftData(rift)
                if riftData then
                    table.insert(validRifts, riftData)
                end
            end
        end
        if #validRifts > 0 then
            sendSingleEmbedWebhook(validRifts)
        end
        wait(60)
    end
end)
webh:addToggle("Send Lucky Rift Webhooks", getgenv().Config.send_Rift_Webhook, function(t)
    if t then
        riftConnection = runService.RenderStepped:Connect(monitorRifts)
    else
        if riftConnection then
            riftConnection:Disconnect()
            riftConnection = nil
        end
    end
end)
webh:addToggle("Send Rare Hatches Webhooks", getgenv().Config.send_Hatch_Webhook, function(t)
    if t then
        hatchConnection = runService.RenderStepped:Connect(monitorHatch)
    else
        if hatchConnection then
            hatchConnection:Disconnect()
            hatchConnection = nil
        end
    end
end)
-- Settings
sett:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function()
	Window:toggle()
end)
sett:addButton("Boost FPS", function(fps)
    _G.Settings = {Players = {["Ignore Me"] = true, ["Ignore Others"] = true}, Meshes = {Destroy = false, LowDetail = true}, Images = {Invisible = true, LowDetail = false, Destroy = false}, ["No Particles"] = true, ["No Camera Effects"] = true, ["No Explosions"] = true, ["No Clothes"] = true, ["Low Water Graphics"] = true, ["No Shadows"] = true, ["Low Rendering"] = true, ["Low Quality Parts"] = true}
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/boost.luau"))()
end)
sett:addButton("Kill Hub", function()
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
    sendCRW           = false
    autobubbleRunning = false
    autovgcRunning    = false
    autobuyAMRunning  = false
    autobuyBMRunning  = false
    openingEggs       = false
    tpToEggs          = false
    autoprRunning     = false
    autowpRunning     = false
    automboxRunning   = false
    autoGoldenChest   = false
    autoRoyalChest    = false
    Window.container:Destroy()
end)
