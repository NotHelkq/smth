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

local islandName = " Throwback Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("event-3")
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
    lTitle = "1364827061767639050> | <@&1364675294014734439"
elseif luck == "x10" then
    lTitle = "1364827138452230225> | <@&1364675216537550918"
elseif luck == "x25" then
    lTitle = "1364827157926248558> | <@&1364675128818139146"
end

local function sendWebhook()
    local pos = rift.EggPlatformSpawn.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    local y = rPos.Y
    local areaPos = ""
    if y >= 0 and y < 410 then
        areaPos = "Area 0-1"
    elseif y >= 410 and y < 2650 then
        areaPos = "Area 1-2"
    elseif y >= 2650 and y < 6850 then
        areaPos = "Area 2-3"
    elseif y >= 6850 and y < 10130 then
        areaPos = "Area 3-4"
    elseif y >= 10130 and y <= 15960 then
        areaPos = "Area 4-5"
    else
        areaPos = ""
    end

    local desc = string.format("❓** Rift Position :** %dm | " .. areaPos .. " ❓\n", rPos.Y)

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
        ["content"] = "<@&1364826866980229213> | <@&" .. lTitle .. ">",
        ["embeds"] = {{
            ["title"] = "🍀 " .. title .. " 🍀",
            ["description"] = desc,
            ["color"] = 16711680,
            ["thumbnail"] = {
                ["url"] = "https://static.wikia.nocookie.net/bgs-infinity/images/8/86/Throwback_Egg.png/revision/latest?cb=20250424041119"
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
