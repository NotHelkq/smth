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

local islandName = " Pastel Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("event-2")
local luck = rift.Display.SurfaceGui.Icon.Luck.Text
local timer = rift.Display.SurfaceGui.Timer.Text
local title = luck .. islandName

local webhooklink = "Nothing"
if luck == "x5" then
    webhooklink = getgenv().Config.x5RiftWebhookLink
elseif luck == "x10" then
    webhooklink = getgenv().Config.x10RiftWebhookLink
elseif luck == "x25" then 
    webhooklink = getgenv().Config.x25RiftWebhookLink
end

local lTitle = "0"
if luck == "x5" then
    lTitle = "1364578880630820864"
elseif luck == "x10" then
    lTitle = "1364578858162196490"
elseif luck == "x25" then
    lTitle = "1364575710768922654"
end

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
        ["content"] = "<@&1364568872518422571> | <@&" .. lTitle .. ">",
        ["embeds"] = {{
            ["title"] = "🍀 " .. title .. " 🍀",
            ["description"] = desc,
            ["color"] = 16711680
        }}
    }

    httpRequest({
        Url = webhooklink,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })
end

sendWebhook()
