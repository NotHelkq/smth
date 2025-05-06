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

local islandName = " Dice Chest"
local rift = workspace.Rendered.Rifts:FindFirstChild("dice-rift")
local timer = rift.Display.SurfaceGui.Timer.Text
local title = islandName

local webhooklink = getgenv().Config.randomRiftWebhook
local function sendWebhook()
    local pos = rift.Chest.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    local y = rPos.Y
    local areaPos = ""
    if y >= 0 and y < 2835 then
        areaPos = "Area 0-1 (World 2)"
    elseif y >= 2835 and y < 7600 then
        areaPos = "Area 1-2 (World 2)"
    elseif y >= 7600 and y < 13330 then
        areaPos = "Area 2-3 (World 2)"
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
        ["content"] = "<@&1369252394197848095>",
        ["embeds"] = {{
            ["title"] = "💎" .. title .. " 💎",
            ["description"] = desc,
            ["color"] = 16711680,
            ["thumbnail"] = {
                ["url"] = "https://static.wikia.nocookie.net/bgs-infinity/images/0/05/Manny.png/revision/latest?cb=20250415141638"
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
