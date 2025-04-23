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

local islandName = " Aura Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("aura-egg")
local luck = rift.Display.SurfaceGui.Icon.Luck.Text
local timer = rift.Display.SurfaceGui.Timer.Text
local title = islandName
local function sendWebhook()
    local pos = rift.EggPlatformSpawn.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    local desc = string.format("❓** Island Position : ** X = %d, Y = %d, Z = %d ❓\n", rPos.X, rPos.Y, rPos.Z)

    local time = os.time()
    desc = desc .. "🕛 **Time Found : ** <t:" .. time .. ":f> 🕛 \n"

    desc = desc .. "🕛 ** Despawn : **in " .. timer .. " 🕛"

    local data = {
        ["content"] = "@everyone",
        ["embeds"] = {{
            ["title"] = "🍀 " .. title .. " 🍀",
            ["description"] = desc,
            ["color"] = 16711680,
            ["thumbnail"] = {
                ["url"] = "https://static.wikia.nocookie.net/bgs-infinity/images/2/2e/Aura_Egg.png/revision/latest?cb=20250420102104"
            }
        }}
    }

    httpRequest({
        Url = getgenv().Config.x25RiftWebhookLink,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })
end

sendWebhook()
