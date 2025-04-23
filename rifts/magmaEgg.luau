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

local islandName = " Magma Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("magma-egg")
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

    local despawntime = 0
    local numStr, unit = string.match(timer, "^(%d+)[%s%p]*(%a*)")
    if numStr then
        local num = tonumber(numStr)
        unit = unit and unit:lower() or ""  
        if unit:find("minute") or unit == "" then
            despawntime = num * 60
        else
            despawntime = 0
        end
    else
        despawntime = 0
    end
    local despawn = time + despawntime
    desc = desc .. "🕛 ** Despawns : ** <t:" .. despawn .. ":f> 🕛"

    local data = {
        ["content"] = "<@&1364569281890750484>",
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
