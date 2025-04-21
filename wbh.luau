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
--// Limited Edition Pets | Will be removed after update over //
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
if recentFrames[id] and tick() - recentFrames[id] < 10 then
    return true
end
recentFrames[id] = tick()
return false
end

local petTitle = "Unknown Pet Hatched"
local petChance = " Unknown"
local isShiny = "Maybe"
local function sendWebhook(name, rarity, shiny, image, chance)
local title = "🐾 Pet Hatched!"
local rarityLower = rarity:lower()

if shiny == false then
    isShiny = "No"
elseif shiny == true then
    isShiny = "Yes"
end

if name == "King Doggy" and isShiny == "No" and rarity == "Secret" then
    petTitle = "🔥 Secret Pet Hatched 🔥"
elseif name == "King Doggy" and isShiny == "Yes" and rarity == "Secret" then
    petTitle = "🔥✨ Shiny Secret Pet Hatched ✨🔥"
elseif name == "King Doggy" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Mythic Secret Pet Hatched ✨💎🔥"
elseif name == "King Doggy" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Shiny Mythic Secret Pet Hatched ✨💎🔥"
elseif name == "Emerald Golem" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Emerald Golem" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Emerald Golem" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Emerald Golem" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Inferno Dragon" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Inferno Dragon" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Inferno Dragon" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Inferno Dragon" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Unicorn" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Unicorn" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Unicorn" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Unicorn" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Flying Pig" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Flying Pig" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Flying Pig" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Flying Pig" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Lunar Serpent" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Lunar Serpent" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Lunar Serpent" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Lunar Serpent" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Electra" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Electra" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Electra" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Electra" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Dark Phoenix" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Dark Phoenix" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Dark Phoenix" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Dark Phoenix" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Neon Elemental" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Neon Elemental" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Neon Elemental" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Neon Elemental" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "NULLVoid" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "NULLVoid" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "NULLVoid" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "NULLVoid" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Inferno Cube" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Inferno Cube" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Inferno Cube" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Inferno Cube" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Virus" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Virus" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Virus" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Virus" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Green Hydra" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Green Hydra" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Green Hydra" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Green Hydra" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Demonic Hydra" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Demonic Hydra" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Demonic Hydra" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Demonic Hydra" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "The Overlord" and isShiny == "No" and rarity == "Secret" then
    petTitle = "🔥 Secret Pet Hatched 🔥"
elseif name == "The Overlord" and isShiny == "Yes" and rarity == "Secret" then
    petTitle = "🔥✨ Shiny Secret Pet Hatched ✨🔥"
elseif name == "The Overlord" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "🔥💎 Mythic Secret Pet Hatched 💎🔥"
elseif name == "The Overlord" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Shiny Mythic Secret Pet Hatched ✨💎🔥"
elseif name == "Hexarium" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Hexarium" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Hexarium" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Hexarium" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Rainbow Shock" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Rainbow Shock" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Rainbow Shock" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Rainbow Shock" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Sigma Serpent" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Sigma Serpent" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Sigma Serpent" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Sigma Serpent" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Manarium" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Manarium" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Manarium" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Manarium" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "MAN FACE GOD" and isShiny == "No" and rarity == "Secret" then
    petTitle = "🔥 Secret Pet Hatched 🔥"
elseif name == "MAN FACE GOD" and isShiny == "Yes" and rarity == "Secret" then
    petTitle = "🔥✨ Shiny Secret Pet Hatched ✨🔥"
elseif name == "MAN FACE GOD" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "🔥💎 Mythic Secret Pet Hatched 💎🔥"
elseif name == "MAN FACE GOD" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Shiny Mythic Secret Pet Hatched ✨💎🔥"
elseif name == "Sweet Treat" and isShiny == "No" and rarity == "Legendary" then -- event pets
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Sweet Treat" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Sweet Treat" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Sweet Treat" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Rainbow Marshmellow" and isShiny == "No" and rarity == "Legendary" then 
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Rainbow Marshmellow" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Rainbow Marshmellow" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Rainbow Marshmellow" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Giant Chocolate Chicken" and isShiny == "No" and rarity == "Secret" then
    petTitle = "🔥 Secret Pet Hatched 🔥"
elseif name == "Giant Chocolate Chicken" and isShiny == "Yes" and rarity == "Secret" then
    petTitle = "🔥✨ Shiny Secret Pet Hatched ✨🔥"
elseif name == "Giant Chocolate Chicken" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "🔥💎 Mythic Secret Pet Hatched 💎🔥"
elseif name == "Giant Chocolate Chicken" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Shiny Mythic Secret Pet Hatched ✨💎🔥"
elseif name == "Seraphic Bunny" and isShiny == "No" and rarity == "Legendary" then 
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Seraphic Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Seraphic Bunny" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Seraphic Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Ethereal Bunny" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Ethereal Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Ethereal Bunny" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Ethereal Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Cardinal Bunny" and isShiny == "No" and rarity == "Legendary" then
    petTitle = "⭐ Legendary Pet Hatched ⭐"
elseif name == "Cardinal Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petTitle = "⭐✨ Shiny Legendary Pet Hatched ✨⭐"
elseif name == "Cardinal Bunny" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "⭐💎 Mythic Legendary Pet Hatched 💎⭐"
elseif name == "Cardinal Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "⭐💎✨ Mythic Legendary Pet Hatched ✨💎⭐"
elseif name == "Easter Basket" and isShiny == "No" and rarity == "Secret" then
    petTitle = "🔥 Secret Pet Hatched 🔥"
elseif name == "Easter Basket" and isShiny == "Yes" and rarity == "Secret" then
    petTitle = "🔥✨ Shiny Secret Pet Hatched ✨🔥"
elseif name == "Easter Basket" and isShiny == "No" and rarity == "Mythic" then
    petTitle = "🔥💎 Mythic Secret Pet Hatched 💎🔥"
elseif name == "Easter Basket" and isShiny == "Yes" and rarity == "Mythic" then
    petTitle = "🔥💎✨ Shiny Mythic Secret Pet Hatched ✨💎🔥"
end

local desc = string.format(" 🐾 **Pet Name :** %s 🐾 \n 💎 **Pet Rarity : ** %s 💎 \n", name, rarity)
if name == "King Doggy" and isShiny == "No" and rarity == "Secret" then
    petChance = " 1 in 100,000,000"
elseif name == "King Doggy" and isShiny == "Yes" and rarity == "Secret" then
    petChance = " 1 in 4,000,000,000"
elseif name == "King Doggy" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000,000"
elseif name == "King Doggy" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000,000,000"
elseif name == "Emerald Golem" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 200"
elseif name == "Emerald Golem" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 8,000"
elseif name == "Emerald Golem" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 20,000"
elseif name == "Emerald Golem" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000"
elseif name == "Inferno Dragon" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 400"
elseif name == "Inferno Dragon" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 16,000"
elseif name == "Inferno Dragon" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 40,000"
elseif name == "Inferno Dragon" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 800,000"
elseif name == "Unicorn" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 400"
elseif name == "Unicorn" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 16,000"
elseif name == "Unicorn" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 40,000"
elseif name == "Unicorn" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 800,000"
elseif name == "Flying Pig" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 1,000"
elseif name == "Flying Pig" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 40,000"
elseif name == "Flying Pig" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 100,000"
elseif name == "Flying Pig" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 4,000,000"
elseif name == "Lunar Serpent" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 400"
elseif name == "Lunar Serpent" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 16,000"
elseif name == "Lunar Serpent" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 40,000"
elseif name == "Lunar Serpent" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 800,000"
elseif name == "Electra" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 1,000"
elseif name == "Electra" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 40,000"
elseif name == "Electra" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 100,000"
elseif name == "Electra" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 4,000,000"
elseif name == "Dark Phoenix" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 2,000"
elseif name == "Dark Phoenix" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 80,000"
elseif name == "Dark Phoenix" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 200,000"
elseif name == "Dark Phoenix" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 8,000,000"
elseif name == "Neon Elemental" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 5,000"
elseif name == "Neon Elemental" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 200,000"
elseif name == "Neon Elemental" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 500,000"
elseif name == "Neon Elemental" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 20,000,000"
elseif name == "NULLVoid" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 1,000,000"
elseif name == "NULLVoid" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 40,000,000"
elseif name == "NULLVoid" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 100,000,000"
elseif name == "NULLVoid" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 4,000,000,000"
elseif name == "Inferno Cube" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 4,000"
elseif name == "Inferno Cube" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 160,000"
elseif name == "Inferno Cube" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 400,000"
elseif name == "Inferno Cube" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 16,000,000"
elseif name == "Virus" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 50,000"
elseif name == "Virus" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 2,000,000"
elseif name == "Virus" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 5,000,000"
elseif name == "Virus" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 200,000,000"
elseif name == "Green Hydra" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 25,000"
elseif name == "Green Hydra" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 1,000,000"
elseif name == "Green Hydra" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 2,500,000"
elseif name == "Green Hydra" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 100,000,000"
elseif name == "Demonic Hydra" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 100,000"
elseif name == "Demonic Hydra" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 4,000,000"
elseif name == "Demonic Hydra" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000"
elseif name == "Demonic Hydra" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000,000"
elseif name == "The Overlord" and isShiny == "No" and rarity == "Secret" then
    petChance = " 1 in 50,000,000"
elseif name == "The Overlord" and isShiny == "Yes" and rarity == "Secret" then
    petChance = " 1 in 2,000,000,000"
elseif name == "The Overlord" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 5,000,000,000"
elseif name == "The Overlord" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 200,000,000,000"
elseif name == "Hexarium" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 100,000"
elseif name == "Hexarium" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 4,000,000"
elseif name == "Hexarium" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000"
elseif name == "Hexarium" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000,000"
elseif name == "Rainbow Shock" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 200,000"
elseif name == "Rainbow Shock" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 8,000,000"
elseif name == "Rainbow Shock" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 20,000,000"
elseif name == "Rainbow Shock" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 800,000,000"
elseif name == "Sigma Serpent" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 10,000"
elseif name == "Sigma Serpent" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 400,000"
elseif name == "Sigma Serpent" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 2,000,000"
elseif name == "Sigma Serpent" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 40,000,000"
elseif name == "Manarium" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 20,000"
elseif name == "Manarium" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 800,000"
elseif name == "Manarium" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000"
elseif name == "Manarium" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 80,000,000"
elseif name == "MAN FACE GOD" and isShiny == "No" and rarity == "Secret" then
    petChance = " 1 in 1,000,000"
elseif name == "MAN FACE GOD" and isShiny == "Yes" and rarity == "Secret" then
    petChance = " 1 in 40,000,000"
elseif name == "MAN FACE GOD" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 100,000,000"
elseif name == "MAN FACE GOD" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 4,000,000,000"
elseif name == "Sweet Treat" and isShiny == "No" and rarity == "Legendary" then -- event pets
    petChance = " 1 in 25,000"
elseif name == "Sweet Treat" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 1,000,000"
elseif name == "Sweet Treat" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 2,500,000"
elseif name == "Sweet Treat" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 100,000,000"
elseif name == "Rainbow Marshmellow" and isShiny == "No" and rarity == "Legendary" then 
    petChance = " 1 in 125,000"
elseif name == "Rainbow Marshmellow" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 5,000,000"
elseif name == "Rainbow Marshmellow" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 12,500,000"
elseif name == "Rainbow Marshmellow" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 500,000,000"
elseif name == "Giant Chocolate Chicken" and isShiny == "No" and rarity == "Secret" then
    petChance = " 1 in 50,000,000"
elseif name == "Giant Chocolate Chicken" and isShiny == "Yes" and rarity == "Secret" then
    petChance = " 1 in 2,000,000,000"
elseif name == "Giant Chocolate Chicken" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 5,000,000,000"
elseif name == "Giant Chocolate Chicken" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 200,000,000,000"
elseif name == "Seraphic Bunny" and isShiny == "No" and rarity == "Legendary" then 
    petChance = " 1 in 5,000"
elseif name == "Seraphic Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 200,000"
elseif name == "Seraphic Bunny" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 500,000"
elseif name == "Seraphic Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 20,000,000"
elseif name == "Ethereal Bunny" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 100,000"
elseif name == "Ethereal Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 4,000,000"
elseif name == "Ethereal Bunny" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000"
elseif name == "Ethereal Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000,000"
elseif name == "Cardinal Bunny" and isShiny == "No" and rarity == "Legendary" then
    petChance = " 1 in 1,000,000"
elseif name == "Cardinal Bunny" and isShiny == "Yes" and rarity == "Legendary" then
    petChance = " 1 in 40,000,000"
elseif name == "Cardinal Bunny" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 100,000,000"
elseif name == "Cardinal Bunny" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 4,000,000,000"
elseif name == "Easter Basket" and isShiny == "No" and rarity == "Secret" then
    petChance = " 1 in 100,000,000"
elseif name == "Easter Basket" and isShiny == "Yes" and rarity == "Secret" then
    petChance = " 1 in 4,000,000,000"
elseif name == "Easter Basket" and isShiny == "No" and rarity == "Mythic" then
    petChance = " 1 in 10,000,000,000"
elseif name == "Easter Basket" and isShiny == "Yes" and rarity == "Mythic" then
    petChance = " 1 in 400,000,000,000"
end
if chance and chance ~= "" then
    desc = desc .. " ❓ ** Chance :**" .. petChance .. " ❓ \n"
end
local time = os.time()
desc = desc .. " 🕛** Catch Date : ** <t:" .. time .. ":F> 🕛"
local eggsOpened = "0"
eggsOpened = player.leaderstats["🥚 Hatches"].Value

local data = {
    ["content"] = "<@" .. getgenv().Config.UserID .. ">",
    ["embeds"] = {{
        ["title"] = petTitle,
        ["description"] = desc,
        ["color"] = 16711680,
        ["footer"] = {
            ["text"] = "Pet Hatched By : " .. player.Name .. " | 🥚 Total Hatches : " .. eggsOpened
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

runService.RenderStepped:Connect(monitorHatch)
print("Hatches Webhook turned on")
