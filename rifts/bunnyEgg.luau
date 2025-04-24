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

local islandName = " Bunny Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("event-1")
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
    lTitle = "1364574758364254280> | <@&1364675294014734439"
elseif luck == "x10" then
    lTitle = "1364574727447777300> | <@&1364675216537550918"
elseif luck == "x25" then
    lTitle = "1364574687387979817> | <@&1364675128818139146"
end

local function sendWebhook()
    local pos = rift.EggPlatformSpawn.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    local desc = string.format("❓** Rift Position : ** X = %d, Y = %d, Z = %d ❓\n", rPos.X, rPos.Y, rPos.Z)

    local time = os.time()
    desc = desc .. "🕛 **Time Found :** <t:" .. time .. ":f> 🕛\n"

    local timeleft = "Nothing"
    local time2 = timer
    if time2 == "5" .. " Minutes" then
        wait(1)
        timeleft = "9" .. " minutes"
    else
        timeleft = rift.Display.SurfaceGui.Timer.Text
    end
    desc = desc .. "🕛 ** Despawn : **in " .. timeleft .. " 🕛"

    local data = {
        ["content"] = "<@&1364511383487774720> | <@&" .. lTitle .. ">",
        ["embeds"] = {{
            ["title"] = "🍀 " .. title .. " 🍀",
            ["description"] = desc,
            ["color"] = 16711680,
            ["thumbnail"] = {
                ["url"] = "https://static.wikia.nocookie.net/bgs-infinity/images/4/4d/Bunny_Egg.png/revision/latest?cb=20250419195943"
            }
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
