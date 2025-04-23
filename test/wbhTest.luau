local runService = game:GetService("RunService")

local function monitorRifts()
    local riftsFolder = workspace.Rendered.Rifts
    local riftList = {
        {name = "event-1", url = "bunnyEgg.luau"},
        {name = "event-2", url = "pastelEgg.luau"},
        {name = "aura-egg", url = "auraEgg.luau"},
        {name = "spikey-egg", url = "spikeyEgg.luau"},
        {name = "magma-egg", url = "magmaEgg.luau"},
        {name = "crystal-egg", url = "crystalEgg.luau"},
        {name = "lunar-egg", url = "lunarEgg.luau"},
        {name = "void-egg", url = "voidEgg.luau"},
        {name = "hell-egg", url = "hellEgg.luau"},
        {name = "nightmare-egg", url = "nightmareEgg.luau"},
        {name = "rainbow-egg", url = "rainbowEgg.luau"}
    }

    for _, riftData in ipairs(riftList) do
        local rift = riftsFolder:FindFirstChild(riftData.name)
        if rift and rift:FindFirstChild("Output") then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/rifts/" .. riftData.url))()
            rift.Output:Destroy()
            break 
        end
    end
end

runService.RenderStepped:Connect(monitorRifts)
print("Rifts Webhook turned on")
