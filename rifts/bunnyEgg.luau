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

local islandName = "Lucky Bunny Egg"
local rift = workspace.Rendered.Rifts:FindFirstChild("event-1")
local luck = rift.Display.SurfaceGui.Icon.Luck.Text
local timer = rift.Display.SurfaceGui.Timer.Text
local function sendWebhook()
    local desc = string.format("💎 **Island Name :** %s 💎 \n🍀 **Luck : ** %s 🍀 \n", islandName, luck)

    local pos = rift.EggPlatformSpawn.WorldPivot.Position
    local rPos = Vector3.new(
        math.floor(pos.X + 0.5),
        math.floor(pos.Y + 0.5),
        math.floor(pos.Z + 0.5)
    )
    desc = desc .. "❓ **Island Positon : **" .. "X =" .. rPos.X .. ", Y = " .. rPos.Y .. ", Z = " .. rPos.Z .. " ❓ \n"

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
        ["content"] = "<@" .. getgenv().Config.UserID .. ">",
        ["embeds"] = {{
            ["title"] = "Island Found!",
            ["description"] = desc,
            ["color"] = 16711680,
            ["footer"] = {
                ["text"] = "Found By : " .. player.Name
            }
        }}
    }

    httpRequest({
        Url = getgenv().Config.LuckyEggsWebhookLink,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = httpService:JSONEncode(data)
    })
end

sendWebhook()
