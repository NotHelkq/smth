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

local islandName = " Golden Chest"
local rift = workspace.Rendered.Rifts:FindFirstChild("golden-chest")
local timer = rift.Display.SurfaceGui.Timer.Text
local title = luck .. islandName

local webhooklink = getgenv().Config.randomRiftWebhook
local function sendWebhook()
    local pos = rift.Chest.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    local desc = string.format("❓** Rift Position : ** Y = %d ❓\n", rPos.Y)

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
        ["content"] = "<@&1364899593514385408>",
        ["embeds"] = {{
            ["title"] = "💎 " .. title .. " 💎",
            ["description"] = desc,
            ["color"] = 16711680,
            ["thumbnail"] = {
                ["url"] = "https://static.wikia.nocookie.net/bgs-infinity/images/5/58/Void_Egg.png/revision/latest?cb=20250412180803"
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
