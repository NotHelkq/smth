if not game:IsLoaded() then game.Loaded:Wait() end
local player = game:GetService("Players").LocalPlayer
local httpService = game:GetService("HttpService")
local httpRequest = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
local remoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent")
local rt = player.Character:FindFirstChild("HumanoidRootPart")

local function tp(d) return function(x,y,z)
    if rt then game:GetService("TweenService"):Create(rt, TweenInfo.new(d), {CFrame = CFrame.new(x,y,z)}):Play() end
end end

local tppos = tp(0)

local function getArea(value, vl)
    for i, v in ipairs(vl) do
        if value < v then return i end
    end
    return #vl + 1
end

local teleportData = {
    {section = "Teleport to Fist Strength Areas",
    buttons = {
        {"Teleport to Rock", 408, 272, 980},
        {"Teleport to Crystal", -2273, 1951, 1053},
        {"Teleport to Blue Star | 1b fs", 1177, 4785, -2294},
        {"Teleport to Green Star | 100b fs", 1379, 9276, 1648},
        {"Teleport to Red Star | 10t fs", -364, 15736, -5},
        {"Teleport to Black Ball | 10qa fs", -3264, 17715, 2505},
        }},
    {section = "Teleport to Body Toughness Areas",
    buttons = {
        {"Teleport to Ice Pool | 100 bt", 368, 250, -445},
        {"Teleport to Fire Pit | 10k bt", 355, 264, -493},
        {"Teleport to The Iceberg | 100k bt", 1635, 260, 2248},
        {"Teleport to The Tornado | 1m bt", -2295, 978, 1073},
        {"Teleport to The Volcano | 10m bt", -3223, 715, -2641},
        {"Teleport to Hellfire Pit | 1b bt", -250, 287, 980},
        {"Teleport to Green Acid Pool | 100b bt", -276, 282, 991},
        {"Teleport to Red Acid Pool | 10t bt", -277, 282, 1007},
        {"Teleport to Gas Station | 10qa bt", -185, 250, 1402},
        }},
    {
    section = "Teleport to Psychic Power Areas",
    buttons = {
        {"Teleport to Psychic Island | 1m pp", -2532, 5487, -534},
        {"Teleport to Psychic Island | 1b pp", -2562, 5502, -439},
        {"Teleport to Psychic Island | 100b pp", -2581, 5517, -502},
        {"Teleport to Psychic Island | 10t pp", -2545, 5412, -489},
        {"Teleport to Psychic Island | 10qa pp", -2667, 5580, -431}
        }},
    {section = "Teleport to ???",
    buttons = {
        {"Teleport to Spawn", 448, 250, 883},
        {"Teleport to Grim Reaper", -125, 250, 517},
        {"Teleport to Leaderboards", -733, 250, 736}
        }}
}

local fs = {1e9, 100e9, 10e12, 10e15}
local bt = {20, 1e3, 10e3, 100e3, 1e6, 100e6, 10e9, 1e12, 10e15}
local ms = {100, 5e3, 500e3, 10e6}
local jf = {5e3, 200e3, 2e6, 10e6}
local pp = {10e3, 1e6, 1e9, 100e9, 10e12, 10e15}

-- Webhook
local function fN(num)
    local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad"}
    local i = 1
    while num >= 1000 and i < #suffixes do
        num = num / 1000
        i = i + 1
    end
    if num % 1 == 0 then return string.format("%d%s", num, suffixes[i])
    else return string.format("%.3f%s", num, suffixes[i]) end
end

local function sendWebhook(target)
    local n = game:GetService("Players"):FindFirstChild(target)
    local s = n:FindFirstChild("PrivateStats")
    local fsv, btv, msv, jfv, ppv = s.FistStrength.Value, s.BodyToughness.Value, s.MovementSpeed.Value, s.JumpForce.Value, s.PsychicPower.Value
    local Ffsv,Fbtv,Fmsv,Fjfv,Fppv = fN(fsv),fN(btv),fN(msv),fN(jfv),fN(ppv)
    local fsm, btm, msm, jfm, ppm = s.FSMulti.Value, s.BTMulti.Value, s.MSMulti.Value, s.JFMulti.Value, s.PPMulti.Value
    local Ffsm,Fbtm,Fmsm,Fjfm,Fppm = fN(fsm),fN(btm),fN(msm),fN(jfm),fN(ppm)
    local g, gm, gc, rb, t, rep, tpmv, tpm = s.Race.Value, s.Multiplier.Value, s.UniversalCoins.Value, s.RuneMultiplier.Value, s.Tokens.Value, s.Reputation.Value, s.TPMGained.Value, s.TPMGained.Value * s.Multiplier.Value + s.RuneMultiplier.Value
    local Fgc, Ft, Ftpmv, Ftpm, Frb = fN(gc), fN(t), fN(tpmv), fN(tpm), fN(rb)
    local status = n.leaderstats.Status.Value

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = target .. "'s Stats",
            ["color"] = 16711680,
            ["fields"] = {
                {["name"] = "Stats",
                    ["value"] = string.format(
                        "Fist Strength : %s\n Body Toughness : %s\n Movement Speed : %s\n Jump Force : %s\n Psychic Power : %s",
                        Ffsv, Fbtv, Fmsv, Fjfv, Fppv
                    ),
                    ["inline"] = true},
                {["name"] = "Multipliers",
                    ["value"] = string.format(
                        "Fist Strength : x%s\n Body Toughness : x%s\n Movement Speed : x%s\n Jump Force : x%s\n Psychic Power : x%s",
                        Ffsm, Fbtm, Fmsm, Fjfm, Fppm 
                    ),
                    ["inline"] = true},
                {["name"] = "Other",
                    ["value"] = string.format(
                        "Grade : %s | x%s\n Grade Coins : %s\n Rune Boost : +%s\n Tokens : %s\n TPM : %s (%s)\n Reputation : %s (%s)",
                        g, gm, Fgc, Frb, Ft, Ftpm, Ftpmv, status, rep
                    ),
                    ["inline"] = true}},
            ["footer"] = {["text"] = os.date("%m/%d/%Y %H:%M:%S")}
        }}
    }
    httpRequest({Url = _G.WebhookLink, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = httpService:JSONEncode(data)})
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()
local Window = Library.New("SPTS : Genesis")
local Main = Window:AddPage("Auto Farm", 5012544693, true)
local TeleportPage = Window:AddPage("Teleport", 5012544693)
local Settings = Window:AddPage("Settings", 5012544693)

local Farm = Window:PageAddSection(Main, "Auto Farm")
local Misc = Window:PageAddSection(Main, "Misc")
local Webh = Window:PageAddSection(Main, "Check Player's Stats | Kill Player")
local Sett = Window:PageAddSection(Settings, "Others")

-- Auto Farm
Window:SectionAddToggle(Farm, "Auto Fist Strength", false, function(t)
    autofs = t
    while autofs do
        local fsValue = player.PrivateStats.FistStrength.Value
        local area = getArea(fsValue, fs)
        local args = {{"+FS"..(area + 2)}}
        remoteEvent:FireServer(unpack(args))
        task.wait(0.5)
    end
end)

Window:SectionAddToggle(Farm, "Auto Body Toughness", false, function(t)
    autobt = t
    while autobt do
        local btValue = player.PrivateStats.BodyToughness.Value
        local area = getArea(btValue, bt)
        local args = {{"+BT"..area}}
        remoteEvent:FireServer(unpack(args))
        task.wait(0.5)
    end
end)

Window:SectionAddToggle(Farm, "Auto Movement Speed", false, function(t)
    automs = t
    while automs do
        local msValue = player.PrivateStats.MovementSpeed.Value
        local area = getArea(msValue, ms)
        local args = {{"+MS"..area}}
        remoteEvent:FireServer(unpack(args))
        task.wait(0.5)
    end
end)

Window:SectionAddToggle(Farm, "Auto Jump Force", false, function(t)
    autojf = t
    while autojf do
        local jfValue = player.PrivateStats.JumpForce.Value
        local area = getArea(jfValue, jf)
        local args = {{"+JF"..area}}
        remoteEvent:FireServer(unpack(args))
        task.wait(0.5)
    end
end)

Window:SectionAddToggle(Farm, "Auto Psychic Power", false, function(t)
    autopp = t
    while autopp do
        local ppValue = player.PrivateStats.PsychicPower.Value
        local area = getArea(ppValue, pp)
        local args = {{"+PP"..(area)}}
        remoteEvent:FireServer(unpack(args))
        task.wait(0.5)
    end
end)

Window:SectionAddToggle(Farm, "Auto Roll Grade 7/8/9/10", false, function(t)
    autorollgrade = t
    while autorollgrade do
        local buff = game:GetService("Players").LocalPlayer.PrivateStats.Multiplier.Value
        if buff < 2.1 then
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("SpinGrade"):InvokeServer()
        else autorollgrade = false end
        task.wait(0.1)
    end
end)

-- Misc
Window:SectionAddButton(Misc, "Quick Roll Grade", function() 
    local buff = game:GetService("Players").LocalPlayer.PrivateStats.Multiplier.Value
    if buff < 2.1 then
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("SpinGrade"):InvokeServer() 
    else warn("You can't quick roll with grade 7/8/9/10") end
end)

local username = player.Name
local multiplierFolder = game:GetService("ReplicatedStorage").Multipliers
for _, mult in ipairs({"FS", "BT", "MS", "JF", "PP"}) do
    local remote = multiplierFolder["Upgrade"..mult]
    Window:SectionAddToggle(Misc, "Auto "..mult.." Multiplier", false, function(t)
        _G["auto"..mult.."multi"] = t
        while _G["auto"..mult.."multi"] do
            remote:FireServer(username)
            task.wait(2)
        end
    end)
end

-- Webhook/kill
local usernameTextbox = Window:SectionAddTextbox(Webh, "Username", "", function(text) end)
Window:SectionAddButton(Webh, "Send Webhook", function()
    local u = usernameTextbox.Button.Textbox.Text
    local user = game:GetService("Players"):FindFirstChild(u)
    if user then 
        sendWebhook(u)
        local closeNotification = Window:ShowNotification("Success", "Webhook Sent")
        delay(3, function() if closeNotification then closeNotification() end end)
    else
        local closeNotification = Window:ShowNotification("Error", "Player Doesn't Exist")
        delay(3, function() if closeNotification then closeNotification() end end)
    end
end)
Window:SectionAddButton(Webh, "Kill Player", function()
    local u = usernameTextbox.Button.Textbox.Text
    local user = game:GetService("Players"):FindFirstChild(u)
    if user then 
        local args = {{"Skill_SoulReap",game:GetService("Players"):WaitForChild(u)}}
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
        local closeNotification = Window:ShowNotification("Success", "Player Killed")
        delay(3, function() if closeNotification then closeNotification() end end)
    else 
        local closeNotification = Window:ShowNotification("Error", "Player Doesn't Exist")
        delay(3, function() if closeNotification then closeNotification() end end)
    end
end)

-- Teleport
for _, sectionData in ipairs(teleportData) do
    local tpSection = Window:PageAddSection(TeleportPage, sectionData.section)
    for _, buttonData in ipairs(sectionData.buttons) do
        Window:SectionAddButton(tpSection, buttonData[1], function()
            tppos(buttonData[2], buttonData[3], buttonData[4])
        end)
    end
end

-- Settings 
Window:SectionAddKeybind(Sett, "Toggle Hub", Enum.KeyCode.RightControl, function() Window:ToggleVisibility() end)
Window:SectionAddButton(Sett, "Unload Script", function()
    for _, v in ipairs({"fs", "bt", "ms", "jf", "pp", "fsmulti", "btmulti", "msmulti", "jfmulti", "ppmulti", "rollgrade"}) do
        _G["auto"..v] = false
    end
    Window.Container:Destroy()
end)
