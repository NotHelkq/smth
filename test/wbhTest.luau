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

local petImages = {
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
    ["MAN FACE GOD"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/1b/MAN_FACE_GOD.png/revision/latest?cb=20250414020316",
    ["The Overlord"] = "https://static.wikia.nocookie.net/bgs-infinity/images/c/c0/The_Overlord.png/revision/latest?cb=20250413130318",
    ["King Doggy"] = "https://static.wikia.nocookie.net/bgs-infinity/images/a/a8/King_Doggy.png/revision/latest?cb=20250412152038",
    -- Event Pets
    ["Seraphic Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/d/d7/Seraphic_Bunny.png/revision/latest/scale-to-width-down/130?cb=20250418234258",
    ["Ethereal Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/b/b9/Ethereal_Bunny.png/revision/latest/scale-to-width-down/130?cb=20250419000116",
    ["Cardinal Bunny"] = "https://static.wikia.nocookie.net/bgs-infinity/images/3/33/Cardinal_Bunny.png/revision/latest/scale-to-width-down/130?cb=20250419014509",
    ["Easter Basket"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/00/Easter_Basket.png/revision/latest/scale-to-width-down/130?cb=20250419001802",
    ["Sweet Treat"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/0e/Sweet_Treat.png/revision/latest/scale-to-width-down/130?cb=20250418233529",
    ["Rainbow Marshmellow"] = "https://static.wikia.nocookie.net/bgs-infinity/images/1/14/Rainbow_Marshmellow.png/revision/latest/scale-to-width-down/130?cb=20250418232506",
    ["Giant Chocolate Chicken"] = "https://static.wikia.nocookie.net/bgs-infinity/images/e/ef/Giant_Chocolate_Chicken.png/revision/latest/scale-to-width-down/130?cb=20250419001410"
}
local fallbackImage = "https://static.wikia.nocookie.net/bgs-infinity/images/7/73/Common_Pet.png"

local recentFrames = {}
local function isRecentFrame(frame)
    local id = tostring(frame)
    if recentFrames[id] and tick() - recentFrames[id] < 5 then
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
        table.insert(parts, reversed:sub(i, math.min(i + 2, #reversed)))
    end
    return table.concat(parts, ","):reverse()
end

local function abbreviateNumber(number)
    if number >= 1e9 then
        return string.format("%.1fb", number / 1e9):gsub("%.0b", "b")
    elseif number >= 1e6 then
        return string.format("%.1fm", number / 1e6):gsub("%.0m", "m")
    elseif number >= 1e3 then
        return string.format("%.1fk", number / 1e3):gsub("%.0k", "k")
    else
        return tostring(number)
    end
end

local secretPets = {
    ["King Doggy"] = true,
    ["The Overlord"] = true,
    ["MAN FACE GOD"] = true,
    ["Giant Chocolate Chicken"] = true,
    ["Easter Basket"] = true,
}

local function getPetTitle(name, rarity, shiny)
    if secretPets[name] then
        if rarity == "Mythic" then
            return shiny and "🔥💎✨ Mythic Secret Pet Hatched ✨💎🔥" or "🔥💎 Mythic Secret Pet Hatched 💎🔥"
        else
            return shiny and "🔥✨ Shiny Secret Pet Hatched ✨🔥" or "🔥 Secret Pet Hatched 🔥"
        end
    else
        if rarity == "Mythic" then
            return shiny and "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐" or "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
        else
            return shiny and "⭐✨ Shiny Legendary Pet Hatched ✨⭐" or "⭐ Legendary Pet Hatched ⭐"
        end
    end
end

local chanceLookup = {
    ["King Doggy"] = {
        Secret = { [false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000" },
        Mythic = { [false] = " 1 in 10,000,000,000", [true] = " 1 in 400,000,000,000" },
    },
    ["Emerald Golem"] = {
        Legendary = { [false] = " 1 in 200", [true] = " 1 in 8,000" },
        Mythic = { [false] = " 1 in 20,000", [true] = " 1 in 400,000" },
    },
    ["Inferno Dragon"] = {
        Legendary = { [false] = " 1 in 400", [true] = " 1 in 16,000" },
        Mythic = { [false] = " 1 in 40,000", [true] = " 1 in 800,000" },
    },
    ["Unicorn"] = {
        Legendary = { [false] = " 1 in 400", [true] = " 1 in 16,000" },
        Mythic = { [false] = " 1 in 40,000", [true] = " 1 in 800,000" },
    },
    ["Flying Pig"] = {
        Legendary = { [false] = " 1 in 1,000", [true] = " 1 in 40,000" },
        Mythic = { [false] = " 1 in 100,000", [true] = " 1 in 4,000,000" },
    },
    ["Lunar Serpent"] = {
        Legendary = { [false] = " 1 in 400", [true] = " 1 in 16,000" },
        Mythic = { [false] = " 1 in 40,000", [true] = " 1 in 800,000" },
    },
    ["Electra"] = {
        Legendary = { [false] = " 1 in 1,000", [true] = " 1 in 40,000" },
        Mythic = { [false] = " 1 in 100,000", [true] = " 1 in 4,000,000" },
    },
    ["Dark Phoenix"] = {
        Legendary = { [false] = " 1 in 2,000", [true] = " 1 in 80,000" },
        Mythic = { [false] = " 1 in 200,000", [true] = " 1 in 8,000,000" },
    },
    ["Neon Elemental"] = {
        Legendary = { [false] = " 1 in 5,000", [true] = " 1 in 200,000" },
        Mythic = { [false] = " 1 in 500,000", [true] = " 1 in 20,000,000" },
    },
    ["NULLVoid"] = {
        Legendary = { [false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000" },
        Mythic = { [false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000" },
    },
    ["Inferno Cube"] = {
        Legendary = { [false] = " 1 in 4,000", [true] = " 1 in 160,000" },
        Mythic = { [false] = " 1 in 400,000", [true] = " 1 in 16,000,000" },
    },
    ["Virus"] = {
        Legendary = { [false] = " 1 in 50,000", [true] = " 1 in 2,000,000" },
        Mythic = { [false] = " 1 in 5,000,000", [true] = " 1 in 200,000,000" },
    },
    ["Green Hydra"] = {
        Legendary = { [false] = " 1 in 25,000", [true] = " 1 in 1,000,000" },
        Mythic = { [false] = " 1 in 2,500,000", [true] = " 1 in 100,000,000" },
    },
    ["Demonic Hydra"] = {
        Legendary = { [false] = " 1 in 100,000", [true] = " 1 in 4,000,000" },
        Mythic = { [false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000" },
    },
    ["The Overlord"] = {
        Secret = { [false] = " 1 in 50,000,000", [true] = " 1 in 2,000,000,000" },
        Mythic = { [false] = " 1 in 5,000,000,000", [true] = " 1 in 200,000,000,000" },
    },
    ["Hexarium"] = {
        Legendary = { [false] = " 1 in 100,000", [true] = " 1 in 4,000,000" },
        Mythic = { [false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000" },
    },
    ["Rainbow Shock"] = {
        Legendary = { [false] = " 1 in 200,000", [true] = " 1 in 8,000,000" },
        Mythic = { [false] = " 1 in 20,000,000", [true] = " 1 in 800,000,000" },
    },
    ["Sigma Serpent"] = {
        Legendary = { [false] = " 1 in 10,000", [true] = " 1 in 400,000" },
        Mythic = { [false] = " 1 in 2,000,000", [true] = " 1 in 40,000,000" },
    },
    ["Manarium"] = {
        Legendary = { [false] = " 1 in 20,000", [true] = " 1 in 800,000" },
        Mythic = { [false] = " 1 in 10,000,000", [true] = " 1 in 80,000,000" },
    },
    ["MAN FACE GOD"] = {
        Secret = { [false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000" },
        Mythic = { [false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000" },
    },
    ["Sweet Treat"] = {
        Legendary = { [false] = " 1 in 25,000", [true] = " 1 in 1,000,000" },
        Mythic = { [false] = " 1 in 2,500,000", [true] = " 1 in 100,000,000" },
    },
    ["Rainbow Marshmellow"] = {
        Legendary = { [false] = " 1 in 125,000", [true] = " 1 in 5,000,000" },
        Mythic = { [false] = " 1 in 12,500,000", [true] = " 1 in 500,000,000" },
    },
    ["Seraphic Bunny"] = {
        Legendary = { [false] = " 1 in 5,000", [true] = " 1 in 200,000" },
        Mythic = { [false] = " 1 in 500,000", [true] = " 1 in 20,000,000" },
    },
    ["Ethereal Bunny"] = {
        Legendary = { [false] = " 1 in 100,000", [true] = " 1 in 4,000,000" },
        Mythic = { [false] = " 1 in 10,000,000", [true] = " 1 in 400,000,000" },
    },
    ["Cardinal Bunny"] = {
        Legendary = { [false] = " 1 in 1,000,000", [true] = " 1 in 40,000,000" },
        Mythic = { [false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000" },
    },
    ["Easter Basket"] = {
        Secret = { [false] = " 1 in 100,000,000", [true] = " 1 in 4,000,000,000" },
        Mythic = { [false] = " 1 in 10,000,000,000", [true] = " 1 in 400,000,000,000" },
    },
}

local function getPetChance(name, rarity, shiny)
    local petData = chanceLookup[name]
    if petData then
        local tierData = petData[rarity]
        if tierData then
            return tierData[shiny] or ""
        end
    end
    return ""
end

local function sendWebhook(name, rarity, shiny, image, hasChance)
    local petTitle = getPetTitle(name, rarity, shiny)
    local petChance = hasChance and getPetChance(name, rarity, shiny) or ""
    local desc = string.format(" 🐾 **Pet Name :** %s 🐾 \n 💎 **Pet Rarity : ** %s 💎 \n", name, rarity)
    if petChance ~= "" then
        desc = desc .. " ❓ ** Chance :**" .. petChance .. " ❓ \n"
    end
    local timeNow = os.time()
    desc = desc .. " 🕛** Catch Date : ** <t:" .. timeNow .. ":F> 🕛"
    
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
                local rawNumber = tonumber(numberPart:gsub(",", ""))
                if suffix:lower() == "b" then rawNumber = rawNumber * 1e9 end
                currentCoins = abbreviateNumber(rawNumber)
            end
        end
    end

    local data = {
        content = "<@" .. getgenv().Config.UserID .. ">",
        embeds = {{
            title = petTitle,
            description = desc,
            color = 16711680,
            footer = {
                text = "Pet Hatched By : " .. player.Name .. " | 🥚 Total Hatches : " .. totalHatches .. " | 💰 Coins Left : " .. currentCoins
            },
            thumbnail = { url = image or fallbackImage }
        }}
    }

    httpRequest({
        Url = getgenv().Config.HatchWebhookLink,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
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

            local rl = rarity:lower()
            if rl:find("legendary") or rl:find("secret") or rl:find("mythic") then
                if not isRecentFrame(frame) then
                    local image = petImages[name] or fallbackImage
                    sendWebhook(name, rarity, shiny, image, chance)
                end
            end
        end
    end
end

runService.RenderStepped:Connect(monitorHatch)
print("Hatches Webhook turned on")
