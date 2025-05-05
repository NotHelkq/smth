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
local webhLink, rolePing, shinyStatus = "nothing", "nothing", ""
local hatchingEggs = getgenv().Config.open_Amount
local royalChecked, goldenChecked = false, false
local recentFrames = {}
local connections = {};
local rt = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local function tp(d) return function(x,y,z)
    if rt then game:GetService("TweenService"):Create(rt, TweenInfo.new(d), {CFrame = CFrame.new(x,y,z)}):Play() end
end end
local fallbackImage = "https://static.wikia.nocookie.net/bgs-infinity/images/2/2a/Pet_Placeholder.png"
local ttppos, tppos = tp(3), tp(10)
local function teleportTo(path) remoteEvent:FireServer("Teleport", path) end
local argspawn = function(tp) teleportTo("Workspace.Worlds.The Overworld.PortalSpawn") end
local argArea1 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn") end
local argArea2 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn") end
local argArea3 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn") end
local argArea4 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn") end
local argArea5 = function(tp) teleportTo("Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn") end
local arg2_spawn = function(tp) teleportTo("Workspace.Worlds.Minigame Paradise.PortalSpawn") end
local argArea2_1 = function(tp) teleportTo("Workspace.Worlds.Minigame Paradise.Islands.Dice Island.Island.Portal.Spawn") end
local argArea2_2 = function(tp) teleportTo("Workspace.Worlds.Minigame Paradise.Islands.Minecart Forest.Island.Portal.Spawn") end
local argArea2_3 = function(tp) teleportTo("Workspace.Worlds.Minigame Paradise.Islands.Robot Factory.Island.Portal.Spawn") end
local tpButtons  = {{name = "Spawn (World 1)", func = argspawn},{name = "Area 1 - Floating Island", func = argArea1},{name = "Area 2 - Outer Space", func = argArea2},{name = "Area 3 - Twilight", func = argArea3},{name = "Area 4 - The Void", func = argArea4},{name = "Area 5 - Zen", func = argArea5}}
local tpButtons2 = {{name = "Spawn (World 2)", func = arg2_spawn},{name = "Area 1 - Dice Island", func = argArea2_1},{name = "Area 2 - Minecart Forest", func = argArea2_2},{name = "Area 3 - Robot Factory", func = argArea2_3}}
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
    ["Rainbow Egg"]   = {argArea5,  {-35, 15974, 44  }},
    ["Showman Egg"]   = {arg2_spawn,{9941, 26, 211   }},
    ["Mining Egg"]    = {argArea2_2,{9920, 7682, 243 }},
    ["Cyber Egg"]     = {argArea2_3,{9914, 13410, 243}}
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
local petConfig = {
    ["Secret"]    = {"King Doggy", "The Overlord", "Silly Doggy :)", "Silly Doggy", "Mech Robot"},
    ["Legendary"] = {"Emerald Golem", "Inferno Dragon", "Unicorn", "Flying Pig", "Lunar Serpent", "Electra", "Dark Phoenix", "Neon Elemental", "NULLVoid", "Inferno Cube", "Virus", "Green Hydra", "Demonic Hydra", "Hexarium", "Rainbow Shock", "ROUND", "DOOF", "Cyborg Phoenix", "Crystal Unicorn", "Stone Gargoyle", "Space Invader", "Bionic Shard", "Game Master", "Jackpot"}
}
local chances = {
    -- Perm Pets
    -- World 1
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
    -- World 2
    -- Secret Pet List
    ["Mech Robot"]              = {Secret    = {[false] = " 66,666,667",    [true] = " 2,666,666,680" },   Mythic = {[false] = " 6,666,666,700",   [true] = " 266,666,668,000"   }},
    -- Legendary Pet List
    ["Crystal Unicorn"]         = {Legendary = {[false] = " 2,000",         [true] = " 80,000"        },   Mythic = {[false] = " 200,000",         [true] = " 8,000,000"         }},
    ["Cyborg Phoenix"]          = {Legendary = {[false] = " 2,500",         [true] = " 100,000"       },   Mythic = {[false] = " 250,000",         [true] = " 10,000,000"        }},
    ["Stone Gargoyle"]          = {Legendary = {[false] = " 20,000",        [true] = " 800,000"       },   Mythic = {[false] = " 2,000,000",       [true] = " 80,000,000"        }},
    ["Game Master"]             = {Legendary = {[false] = " 20,000",        [true] = " 800,000"       },   Mythic = {[false] = " 2,000,000",       [true] = " 80,000,000"        }},
    ["Space Invader"]           = {Legendary = {[false] = " 50,000",        [true] = " 2,000,000"     },   Mythic = {[false] = " 5,000,000",       [true] = " 200,000,000"       }},
    ["Bionic Shard"]            = {Legendary = {[false] = " 666,667",       [true] = " 26,666,680"    },   Mythic = {[false] = " 66,666,700",      [true] = " 2,666,668,000"     }},
    ["Game Master"]             = {Legendary = {[false] = " 20,000,000",    [true] = " 800,000,000"   },   Mythic = {[false] = " 2,000,000,000",   [true] = " 80,000,000,000"    }},
    -- Event Pets
    -- Event Secret Pet List
    ["Silly Doggy"]             = {Secret    = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    ["Silly Doggy :)"]          = {Secret    = {[false] = " 1,000,000",     [true] = " 40,000,000"    },   Mythic = {[false] = " 100,000,000",     [true] = " 4,000,000,000"     }},
    -- Event Legendary Pet List
    ["DOOF"]                    = {Legendary = {[false] = " 10,000",        [true] = " 400,000"       },   Mythic = {[false] = " 1,000,000",       [true] = " 40,000,000"        }},
    ["ROUND"]                   = {Legendary = {[false] = " 250,000",       [true] = " 10,000,000"    },   Mythic = {[false] = " 25,000,000",      [true] = " 1,000,000,000"     }},
}
local imageUrl = "https://static.wikia.nocookie.net/bgs-infinity/images/"
local petImages = {
    -- World 1
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
    -- World 2
    -- Secret Pet List
    ["Mech Robot"]       = {Normal = imageUrl.."1/1d/Mech_Robot.png",       Shiny = imageUrl.."4/4b/Shiny_Mech_Robot.png",       Mythic = imageUrl.."7/7b/Mythic_Mech_Robot.png",       ShinyMythic = imageUrl.."4/44/Shiny_Mythic_Mech_Robot.png"       },
    -- Legendary Pet List
    ["Crystal Unicorn"]  = {Normal = imageUrl.."a/a3/Crystal_Unicorn.png",  Shiny = imageUrl.."c/c4/Shiny_Crystal_Unicorn.png",  Mythic = imageUrl.."d/d5/Mythic_Crystal_Unicorn.png",  ShinyMythic = imageUrl.."4/4e/Shiny_Mythic_Crystal_Unicorn.png"  },
    ["Cyborg Phoenix"]   = {Normal = imageUrl.."7/76/Cyborg_Phoenix.png",   Shiny = imageUrl.."c/c8/Shiny_Cyborg_Phoenix.png",   Mythic = imageUrl.."7/76/Cyborg_Phoenix.png",          ShinyMythic = imageUrl.."c/c8/Shiny_Cyborg_Phoenix.png"          },
    ["Stone Gargoyle"]   = {Normal = imageUrl.."2/23/Stone_Gargoyle.png",   Shiny = imageUrl.."e/e6/Shiny_Stone_Gargoyle.png",   Mythic = imageUrl.."3/3c/Mythic_Stone_Gargoyle.png",   ShinyMythic = imageUrl.."b/b9/Shiny_Mythic_Stone_Gargoyle.png"   },
    ["Game Master"]      = {Normal = imageUrl.."4/46/Game_Master.png",      Shiny = imageUrl.."5/50/Shiny_Game_Master.png",      Mythic = imageUrl.."0/01/Mythic_Game_Master.png",      ShinyMythic = imageUrl.."0/00/Shiny_Mythic_Game_Master.png"      },
    ["Space Invader"]    = {Normal = imageUrl.."1/1d/Space_Invader.png",    Shiny = imageUrl.."6/6d/Shiny_Space_Invader.png",    Mythic = imageUrl.."d/df/Mythic_Space_Invader.png",    ShinyMythic = imageUrl.."f/fd/Shiny_Mythic_Space_Invader.png"    },
    ["Bionic Shard"]     = {Normal = imageUrl.."6/6c/Bionic_Shard.png",     Shiny = imageUrl.."8/8d/Shiny_Bionic_Shard.png",     Mythic = imageUrl.."6/6c/Bionic_Shard.png",            ShinyMythic = imageUrl.."8/8d/Shiny_Bionic_Shard.png"            },
    ["Jackpot"]          = {Normal = imageUrl.."1/10/Jackpot.png",          Shiny = imageUrl.."5/5e/Shiny_Jackpot.png",          Mythic = imageUrl.."6/6b/Mythic_Jackpot.png",          ShinyMythic = imageUrl.."f/fa/Shiny_Mythic_Jackpot.png"          },
    -- Event Secret Pet List
    ["Silly Doggy :)"]   = {Normal = imageUrl.."1/1d/Silly-doggy.png",      Shiny = imageUrl.."5/5c/Shiny_Silly_Doggy.png",      Mythic = imageUrl.."7/76/Mythic_Silly_Doggy.png",      ShinyMythic = imageUrl.."c/cc/Shiny_Mythic_Silly_Doggy.png"      },
    ["Silly Doggy"]      = {Normal = imageUrl.."1/1d/Silly-doggy.png",      Shiny = imageUrl.."5/5c/Shiny_Silly_Doggy.png",      Mythic = imageUrl.."7/76/Mythic_Silly_Doggy.png",      ShinyMythic = imageUrl.."c/cc/Shiny_Mythic_Silly_Doggy.png"      },
    -- Event Legendary Pet List
    ["DOOF"]             = {Normal = imageUrl.."3/34/DOOF.png",             Shiny = imageUrl.."7/77/Shiny_DOOF.png",             Mythic = imageUrl.."f/f1/Mythic_DOOF.png",             ShinyMythic = imageUrl.."1/1c/Shiny_Mythic_DOOF.png"             },
    ["ROUND"]            = {Normal = imageUrl.."2/24/ROUND.png",            Shiny = imageUrl.."f/fb/Shiny_ROUND.png",            Mythic = imageUrl.."b/b0/Mythic_ROUND.png",            ShinyMythic = imageUrl.."a/a6/Shiny_Mythic_ROUND.png"            }
}
local function getPetImage(name, isShiny, isMythic)
    local variants = petImages[name]
    if not variants then return fallbackImage end
    return variants.ShinyMythic and isShiny and isMythic and variants.ShinyMythic or variants.Mythic and isMythic and variants.Mythic or variants.Shiny and isShiny and variants.Shiny or variants.Normal or fallbackImage
end
local function sendWebhook(name, rarity, shiny, image)
    local tierMap = {
        ["Emerald Golem"]  = 1, ["Inferno Dragon"] = 1, ["Unicorn"]       = 1, ["Flying Pig"]      = 1, ["Lunar Serpent"]  = 1, ["Electra"]       = 1, ["Dark Phoenix"] = 1, ["Inferno Cube"] = 1, ["Cyborg Phoenix"] = 1,
        ["Neon Elemental"] = 2, ["Green Hydra"]    = 2, ["DOOF"]          = 2, ["Crystal Unicorn"] = 2, ["Stone Gargoyle"] = 2,
        ["NULLVoid"]       = 3, ["Virus"]          = 3, ["Demonic Hydra"] = 3, ["Hexarium"]        = 3, ["Rainbow Shock"]  = 3, ["Space Invader"] = 3, ["Bionic Shard"] = 3, ["Game Master"]  = 3, ["Jackpot"]        = 3,
        ["King Doggy"]     = 4, ["The Overlord"]   = 4, ["Silly Doggy"]   = 4, ["Silly Doggy :)"]  = 4, ["Mech Robot"]     = 4
    }
    local tier = tierMap[name] or 3
    rolePing = ({"1364988111549108234", "1364988196521246782", "1364988212115931236", "1364988235000057926"})[tier]
    webhLink = getgenv().Config[({"t1HatchWebhook", "t2HatchWebhook", "t3HatchWebhook", "t3HatchWebhook"})[tier]]

    local title, rarityLower = "🐾 Pet Hatched!", rarity:lower()
    local emojis = {Secret = "🔥", Legendary = "⭐", Mythic = "💎", Shiny = "✨"}
    local petType = table.find(petConfig.Secret, name) and "Secret" or table.find(petConfig.Legendary, name) and "Legendary"
    local leaderstats,coinsHud,ticketsHud = player:FindFirstChild("leaderstats"),player.PlayerGui.ScreenGui.HUD.Left.Currency.Coins:FindFirstChild("Frame"),game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.HUD.Left.Currency.Tickets:FindFirstChild("Frame")
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
    if ticketsHud then
        local tickets = ticketsHud:FindFirstChild("Label")
        if tickets and tickets:IsA("TextLabel") then
            local text = tickets.Text
            local numberPart, suffix = text:match("([%d,.]+)([%a]*)")
            if numberPart then
                local cleanedNumberPart = numberPart:gsub(",", "") 
                local rawNumber = tonumber(cleanedNumberPart)
                if suffix:lower() == "b" then
                    rawNumber = rawNumber * 1e9
                end
                currentTickets = abbreviateNumber(rawNumber)
            end
        end
    end


    local data = {
        ["content"] = "<@&" .. rolePing .. ">",
        ["embeds"] = {{
            ["title"] = petTitle,
            ["description"] = string.format("🐾 **Pet Name : **%s 🐾\n💎 **Pet Rarity : **%s 💎\n❓ **Chance : **1 in %s ❓\n🕛 **Hatch Date : **<t:%s:F> 🕛", name, rarity, chances[name] and chances[name][rarity] and chances[name][rarity][shiny] or "N/A", os.time()),
            ["color"] = 16711680,
            ["footer"] = {["text"] = "🥚 Total Hatches : " .. totalHatches .. " | 💰 Coins Left : " .. currentCoins .. " | 🎫 Tickets Left : " .. currentTickets .. "\nPet Hatched By : " .. player.Name},
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
        {name = "showman-egg",   url = "showmanEgg.luau"  },
        {name = "mining-egg",    url = "miningEgg.luau"   },
        {name = "cyber-egg",     url = "cyberEgg.luau"    },
        {name = "golden-chest",  url = "goldenChest.luau" },
        {name = "royal-chest",   url = "royalChest.luau"  },
        {name = "bubble-rift",   url = "bubbleRift.luau"  }
    }
    local riftDict = {}
    for _, data in ipairs(riftList) do
        riftDict[data.name] = data
    end
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
                    end
                end
                break
            end
        end
    end
end
-- lib stuff
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()
local Window  = library.new("Bubble Gum Simulator Infinity")
local Main      = Window:addPage("Auto Farm", 5012544693, true)
local eggStuff  = Window:addPage("Eggs", 5012544693)
local MiscStuff = Window:addPage("Misc", 5012544693)
local Webhooks  = Window:addPage("Webhook", 5012544693)
local Settings  = Window:addPage("Settings", 5012544693)
local Farm       = Main:addSection("Auto Farm")
local Teleport1  = Main:addSection("Teleport (World 1)")
local Teleport2  = Main:addSection("Teleport (World 2)")
local eggs   = eggStuff:addSection("Hatch (You must be near egg!)")
local misc  = MiscStuff:addSection("Misc")
local webh   = Webhooks:addSection("Webhooks")
local sett   = Settings:addSection("Others")
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
        task.wait(1)
        remoteEvent:FireServer("ClaimChest", "Ticket Chest", true)
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
Farm:addToggle("Auto Buy Dice Merchant", getgenv().Config.auto_Buy_Dice, function(t)
    autobuyBDRunning = t
    while autobuyBDRunning do
        for i = 1, 3 do
            remoteEvent:FireServer("BuyShopItem", "dice-shop", i)
            task.wait(2)
        end
    end
end)
for _, btn in ipairs(tpButtons) do
    Teleport1:addButton(btn.name, function() btn.func() end)
end
for _, btn in ipairs(tpButtons2) do
    Teleport2:addButton(btn.name, function() btn.func() end)
end
-- Eggs Stuff
eggs:addDropdown("Eggs", {"Infinity Egg","Cyber Egg","Mining Egg","Showman Egg","Rainbow Egg","Nightmare Egg","Hell Egg","Void Egg","Lunar Egg","Crystal Egg","Magma Egg","Spikey Egg","Iceshard Egg","Spotted Egg","Common Egg"}, function(e) selectedEgg = e end, getgenv().Config.open_Egg)
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
    for i, v in next, game:GetService("Workspace").Worlds["Minigame Paradise"].Islands:GetChildren() do
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
    autobubbleRunning = false
    autovgcRunning    = false
    autobuyAMRunning  = false
    autobuyBMRunning  = false
    autobuyBDRunning  = false
    openingEggs       = false
    tpToEggs          = false
    autoprRunning     = false
    autowpRunning     = false
    automboxRunning   = false
    autoGoldenChest   = false
    autoRoyalChest    = false
    Window.container:Destroy()
end)
