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

local function monitorRifts()
    local bunnyEggRift = workspace.Rendered.Rifts:FindFirstChild("event-1")
    local pastelEggRift = workspace.Rendered.Rifts:FindFirstChild("event-2")
    local auraEggRift = workspace.Rendered.Rifts:FindFirstChild("aura-egg")
    local spikeyEggRift = workspace.Rendered.Rifts:FindFirstChild("spikey-egg")
    local magmaEggRift = workspace.Rendered.Rifts:FindFirstChild("magma-egg")
    local crystalEggRift = workspace.Rendered.Rifts:FindFirstChild("crystal-egg")
    local lunarEggRift = workspace.Rendered.Rifts:FindFirstChild("lunar-egg")
    local voidEggRift = workspace.Rendered.Rifts:FindFirstChild("void-egg")
    local hellEggRift = workspace.Rendered.Rifts:FindFirstChild("hell-egg")
    local nightmareEggRift = workspace.Rendered.Rifts:FindFirstChild("nightmare-egg")
    local rainbowEggRift = workspace.Rendered.Rifts:FindFirstChild("rainbow-egg")

    local bunnyEggCheck = bunnyEggRift.Output
    local pastelEggCheck = pastelEggRift.Output
    local auraEggCheck = auraEggRift.Output
    local spikeyEggCheck = spikeyEggRift.Output
    local magmaEggCheck = magmaEggRift.Output
    local crystalEggCheck = crystalEggRift.Output
    local lunarEggCheck = lunarEggRift.Output
    local voidEggCheck = voidEggRift.Output
    local hellEggCheck = hellEggRift.Output
    local nightmareEggCheck = nightmareEggRift.Output
    local rainbowEggCheck = rainbowEggRift.Output

    if bunnyEggRift and bunnyEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/bunnyEgg.luau"))
        bunnyEggRift.Output:Destroy()
    elseif pastelEggRift and pastelEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/pastelEgg.luau"))
        pastelEggRift.Output:Destroy()
    elseif auraEggRift and auraEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/auraEgg.luau"))
        auraEggRift.Output:Destroy()
    elseif spikeyEggRift and spikeyEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/spikeyEgg.luau"))
        spikeyEggRift.Output:Destroy()
    elseif magmaEggRift and magmaEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/magmaEgg.luau"))
        magmaEggRift.Output:Destroy()
    elseif crystalEggRift and crystalEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/crystalEgg.luau"))
        crystalEggRift.Output:Destroy()
    elseif lunarEggRift and lunarEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/lunarEgg.luau"))
        lunarEggRift.Output:Destroy()
    elseif voidEggRift and voidEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/voidEgg.luau"))
        voidEggRift.Output:Destroy()
    elseif hellEggRift and hellEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/hellEgg.luau"))
        hellEggRift.Output:Destroy()
    elseif nightmareEggRift and nightmareEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/nightmareEgg.luau"))
        nightmareEggRift.Output:Destroy()
    elseif rainbowEggRift and rainbowEggCheck then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/rainbowEgg.luau"))
        rainbowEggRift.Output:Destroy()
    end
end

runService.RenderStepped:Connect(monitorRifts)
print("Rifts Webhook turned on")
