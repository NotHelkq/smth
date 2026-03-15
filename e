if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId == 2202352383 then
    local Players           = game:GetService("Players")
    local Lighting          = game:GetService("Lighting")
    local Workspace         = game:GetService("Workspace")
    local RunService        = game:GetService("RunService")
    local HttpService       = game:GetService("HttpService")
    local CoreGui           = game:GetService("CoreGui")
    local TeleportService   = game:GetService("TeleportService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpRequest       = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
    local QueueTeleport     = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    local Player            = Players.LocalPlayer
    local PlayerGui         = Player:WaitForChild("PlayerGui")
    local ScreenGui         = PlayerGui:WaitForChild("ScreenGui")
    local RemoteEvent       = ReplicatedStorage:WaitForChild("RemoteEvent")
    local AnimFolder        = ReplicatedStorage:WaitForChild("AnimStorage")
    
    local TargetName        = "Esil_HatesShowers"
    local Storage           = ReplicatedStorage:FindFirstChild("Storage") or Instance.new("Folder", ReplicatedStorage)
    Storage.Name            = "Storage"

    _G.rod = _G.rod or false
    _G.killBots = _G.killBots or false

    local function Create(class, parent, props)
        local obj = Instance.new(class)
        for prop, val in pairs(props) do obj[prop] = val end
        obj.Parent = parent
        return obj
    end

    local function setUIState(hide)
        local intro = PlayerGui:FindFirstChild("IntroGui") or Storage:FindFirstChild("IntroGui")
        local blur = Lighting:FindFirstChild("Blur") or Storage:FindFirstChild("Blur")
        if hide then
            if intro then intro.Enabled = false; intro.Parent = Storage end
            if blur then blur.Enabled = false; blur.Parent = Storage end
        else
            if intro then intro.Enabled = false; intro.Parent = PlayerGui end
            if blur then blur.Enabled = false; blur.Parent = Lighting end
        end
    end

    local function teleportTo(pos)
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos) end
    end

    local function loadAnims()
        local char = Player.Character
        local hum = char and char:WaitForChild("Humanoid", 5)
        if hum then
            hum:LoadAnimation(AnimFolder.Punch1Anim)
            hum:LoadAnimation(AnimFolder.Punch2Anim)
        end
    end
    Player.CharacterAdded:Connect(function() task.wait(1); loadAnims() end)
    loadAnims()

    local function respawn(savedPos)
        local oldCam = Workspace.CurrentCamera
        if oldCam then oldCam:Destroy() end
        RemoteEvent:FireServer({"Respawn"})
        local newCam = Workspace:WaitForChild("Camera", 10)    
        local newChar = Player.CharacterAdded:Wait()
        local hum = newChar:WaitForChild("Humanoid", 10)
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
        if newCam and hum then newCam.CameraType = Enum.CameraType.Custom; newCam.CameraSubject = hum end
        if _G.rod then setUIState(true); if ScreenGui then ScreenGui.Enabled = true end end
        if newHrp and savedPos then
            task.spawn(function()
                local forceStart = tick()
                while tick() - forceStart < 7 do
                    if not newHrp or not newHrp.Parent then break end
                    newHrp.CFrame = savedPos
                    newHrp.Velocity = Vector3.zero
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end

    local function RejoinTP()  
        local pos = _G.lastSavedPos or Vector3.new(448, 250, 883)
        local posStr = "Vector3.new(" .. tostring(pos.Position.X) .. "," .. tostring(pos.Position.Y) .. "," .. tostring(pos.Position.Z) .. ")"
        
        local scriptToQueue = [[
            _G.rod = ]] .. tostring(_G.rod) .. [[
            _G.killBots = ]] .. tostring(_G.killBots) .. [[
            _G.lastSavedPos = CFrame.new(]] .. posStr .. [[)
            
            if not game:IsLoaded() then game.Loaded:Wait() end
            task.wait(5)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/e"))()
            task.wait(5)
            local p = game:GetService("Players").LocalPlayer
            local r = p.Character and p.Character:WaitForChild("HumanoidRootPart", 10)
            if r then r.CFrame = _G.lastSavedPos end
        ]]
        
        if QueueTeleport then QueueTeleport(scriptToQueue) end
        TeleportService:Teleport(game.PlaceId, Player)
    end

    local function ToggleRejoin(enable)
        if _G.RejoinConnection then _G.RejoinConnection:Disconnect() end
        if enable then
            _G.RejoinConnection = CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then task.wait(2); RejoinTP() end
            end)
        end
    end

    _G.WebhookURL = "https://discord.com/api/webhooks/1457786185480147178/_y-fLwD2muf9L79Bzq4PCbCknn_E4G-1tX3Yhq80MypbTk-RbSRqk-SzllRHEm_zbmYO"
    local function parseRep(text)
        local cleaned = text:match(":%s*(-?%d+)")
        return tonumber(cleaned) or 0
    end

    local lastRecordedRep = parseRep(Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text)
    local function sendWebhook()
        if _G.WebhookURL == "" then return end
        local status = Player.leaderstats.Status.Value
        local repRawText = Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text
        local currentRep = parseRep(repRawText)
        local gain = currentRep - lastRecordedRep
        lastRecordedRep = currentRep

        local data = {
            ["embeds"] = {{
                ["title"] = "Status & Reputation Update",
                ["description"] = "Stats for **" .. Player.DisplayName .. "** (@" .. Player.Name .. ")",
                ["color"] = 0x00FF00,
                ["fields"] = {
                    {["name"] = "🎭 Status", ["value"] = "```" .. tostring(status) .. "```", ["inline"] = true},
                    {["name"] = "📈 Reputation", ["value"] = "```" .. repRawText .. "```", ["inline"] = true},
                    {["name"] = "⏱️ Gain", ["value"] = "```" .. (gain > 0 and "+" or "") .. tostring(gain) .. "```", ["inline"] = true},
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }
        HttpRequest({Url = _G.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
    end

    if _G.deathConn then _G.deathConn:Disconnect() end
    _G.deathConn = Player.CharacterAdded:Connect(function(char)
        if _G.rod then setUIState(true) end
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.Died:Connect(function()
                if _G.rod then task.wait(0.01); respawn(_G.lastSavedPos) end
            end)
        end
    end)

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/Unknown%20UI%20v2.luau"))()
    local Window  = Library.new("SPTS : Classic", "Version: 2.0-rep")
    local Main    = Library:addPage("Auto Farm", 10723376114)
    local FarmSec = Window:PageAddSection(Main, "Combat Farm", true)
    local Utils   = Window:PageAddSection(Main, "Utilities", true)

    FarmSec:addToggle("Auto Kill", _G.killBots, function(t) 
        if Player.Name == TargetName then 
            _G.killBots = false
            return 
        end
        _G.killBots = t 
    end)

    FarmSec:addToggle("Return On Death", _G.rod, function(t) 
        _G.rod = t 
        setUIState(t) 
    end)

    FarmSec:addButton("Teleport to Spawn", function() teleportTo(Vector3.new(448, 250, 883)) end)
    FarmSec:addButton("Teleport to Leaderboards", function() teleportTo(Vector3.new(-733, 250, 736)) end)

    Utils:addToggle("Auto Rejoin", false, function(t) ToggleRejoin(t) end)
    Utils:addSlider("FPS Limit", 10, 60, 60, function(t) setfpscap(t) end)
    Utils:addKeybind("Toggle Hub", Enum.KeyCode.RightControl, function() Window:ToggleUI() end)

    _G.MainLoopActive = true
    local lastWebhookSent = 0
    local punchSide = "Left"

    task.spawn(function()
        while _G.MainLoopActive and task.wait(0.05) do
            local char = Player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
            if _G.rod and hum and hrp then
                if not ScreenGui.Enabled then ScreenGui.Enabled = true end
                if hum.Health > 1 then _G.lastSavedPos = hrp.CFrame end
                if hum.Health > 0 and hum.Health <= 51 then respawn(_G.lastSavedPos) end
            end

            if _G.killBots and Player.Name ~= TargetName then
                local target = Players:FindFirstChild(TargetName)
                local tChar = target and target.Character
                local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
                local tHum = tChar and tChar:FindFirstChild("Humanoid")

                if tHrp and tHum and tHum.Health > 0 and hrp then
                    tHrp.CFrame = hrp.CFrame
                    RemoteEvent:FireServer({"Skill_Punch", punchSide})
                    punchSide = (punchSide == "Left" and "Right" or "Left")
                end
            end

            if Player.Name == TargetName and (tick() - lastWebhookSent >= 60) then 
                lastWebhookSent = tick()
                sendWebhook()
            end
        end
    end)

    local function deactivateAllToggles()
        _G.MainLoopActive = false
        local t = {"rod", "killBots"}
        for _, v in ipairs(t) do _G[v] = false end
        if _G.deathConn then _G.deathConn:Disconnect(); _G.deathConn = nil end
        if _G.RejoinConnection then _G.RejoinConnection:Disconnect(); _G.RejoinConnection = nil end
        setUIState(false)
        setfpscap(60)
    end

    task.spawn(function()
        RemoteEvent:FireServer({"Respawn"})
        local intro = PlayerGui:FindFirstChild("IntroGui")
        local skill = ScreenGui:FindFirstChild("SkillHotkey_Frame")
        local blur  = Lighting:FindFirstChild("Blur")
        if intro then intro.Enabled = false end
        if blur then blur.Enabled = false end
        if ScreenGui then ScreenGui.Enabled = true end
        if skill then skill:Destroy() end
        if _G.rod then setUIState(true) end
    end)

    if Library and Library.Container then Library.Container.Destroying:Connect(deactivateAllToggles) end
endif not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId == 2202352383 then
    local Players           = game:GetService("Players")
    local Lighting          = game:GetService("Lighting")
    local Workspace         = game:GetService("Workspace")
    local RunService        = game:GetService("RunService")
    local HttpService       = game:GetService("HttpService")
    local CoreGui           = game:GetService("CoreGui")
    local TeleportService   = game:GetService("TeleportService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpRequest       = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
    local QueueTeleport     = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    local Player            = Players.LocalPlayer
    local PlayerGui         = Player:WaitForChild("PlayerGui")
    local ScreenGui         = PlayerGui:WaitForChild("ScreenGui")
    local RemoteEvent       = ReplicatedStorage:WaitForChild("RemoteEvent")
    local AnimFolder        = ReplicatedStorage:WaitForChild("AnimStorage")
    
    local TargetName        = "Esil_HatesShowers"
    local Storage           = ReplicatedStorage:FindFirstChild("Storage") or Instance.new("Folder", ReplicatedStorage)
    Storage.Name            = "Storage"

    local function Create(class, parent, props)
        local obj = Instance.new(class)
        for prop, val in pairs(props) do obj[prop] = val end
        obj.Parent = parent
        return obj
    end

    local function setUIState(hide)
        local intro = PlayerGui:FindFirstChild("IntroGui") or Storage:FindFirstChild("IntroGui")
        local blur = Lighting:FindFirstChild("Blur") or Storage:FindFirstChild("Blur")
        if hide then
            if intro then intro.Enabled = false; intro.Parent = Storage end
            if blur then blur.Enabled = false; blur.Parent = Storage end
        else
            if intro then intro.Enabled = false; intro.Parent = PlayerGui end
            if blur then blur.Enabled = false; blur.Parent = Lighting end
        end
    end

    local function teleportTo(pos)
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos) end
    end

    local function loadAnims()
        local char = Player.Character
        local hum = char and char:WaitForChild("Humanoid", 5)
        if hum then
            hum:LoadAnimation(AnimFolder.Punch1Anim)
            hum:LoadAnimation(AnimFolder.Punch2Anim)
        end
    end
    Player.CharacterAdded:Connect(function() task.wait(1); loadAnims() end)
    loadAnims()

    local function respawn(savedPos)
        local oldCam = Workspace.CurrentCamera
        if oldCam then oldCam:Destroy() end
        RemoteEvent:FireServer({"Respawn"})
        local newCam = Workspace:WaitForChild("Camera", 10)    
        local newChar = Player.CharacterAdded:Wait()
        local hum = newChar:WaitForChild("Humanoid", 10)
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
        if newCam and hum then newCam.CameraType = Enum.CameraType.Custom; newCam.CameraSubject = hum end
        if _G.rod then setUIState(true); if ScreenGui then ScreenGui.Enabled = true end end
        if newHrp and savedPos then
            task.spawn(function()
                local forceStart = tick()
                while tick() - forceStart < 7 do
                    if not newHrp or not newHrp.Parent then break end
                    newHrp.CFrame = savedPos
                    newHrp.Velocity = Vector3.zero
                    RunService.Heartbeat:Wait()
                end
            end)
        end
    end

    local function RejoinTP()  
        local pos = _G.lastSavedPos or Vector3.new(448, 250, 883)
        local posStr = "Vector3.new(" .. tostring(pos.Position.X) .. "," .. tostring(pos.Position.Y) .. "," .. tostring(pos.Position.Z) .. ")"
        
        local scriptToQueue = [[
            if not game:IsLoaded() then game.Loaded:Wait() end
            task.wait(5)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/e"))()
            task.wait(5)
            local p = game:GetService("Players").LocalPlayer
            local r = p.Character and p.Character:WaitForChild("HumanoidRootPart", 10)
            if r then r.CFrame = CFrame.new(]] .. posStr .. [[) end
        ]]
        
        if QueueTeleport then QueueTeleport(scriptToQueue) end
        TeleportService:Teleport(game.PlaceId, Player)
    end

    local function ToggleRejoin(enable)
        if _G.RejoinConnection then _G.RejoinConnection:Disconnect() end
        if enable then
            _G.RejoinConnection = CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then task.wait(2); RejoinTP() end
            end)
        end
    end

    local BlackoutGui = Create("ScreenGui", PlayerGui, {Name = "BlackoutUI", IgnoreGuiInset = true, DisplayOrder = -67, ResetOnSpawn = false, Enabled = false})
    Create("Frame", BlackoutGui, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Active = false, BorderSizePixel = 0})

    _G.PerformanceKey = Enum.KeyCode.P 
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == _G.PerformanceKey then
            _G.PMActive = not _G.PMActive
            RunService:Set3dRenderingEnabled(not _G.PMActive)
            BlackoutGui.Enabled = _G.PMActive
        end
    end)

    _G.WebhookURL = "https://discord.com/api/webhooks/1457786185480147178/_y-fLwD2muf9L79Bzq4PCbCknn_E4G-1tX3Yhq80MypbTk-RbSRqk-SzllRHEm_zbmYO"
    local function parseRep(text)
        local cleaned = text:match(":%s*(-?%d+)")
        return tonumber(cleaned) or 0
    end

    local lastRecordedRep = parseRep(Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text)
    local function sendWebhook()
        if _G.WebhookURL == "" then return end
        local status = Player.leaderstats.Status.Value
        local repRawText = Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text
        local currentRep = parseRep(repRawText)
        local gain = currentRep - lastRecordedRep
        lastRecordedRep = currentRep

        local data = {
            ["embeds"] = {{
                ["title"] = "Status & Reputation Update",
                ["description"] = "Stats for **" .. Player.DisplayName .. "** (@" .. Player.Name .. ")",
                ["color"] = 0x00FF00,
                ["fields"] = {
                    {["name"] = "🎭 Status", ["value"] = "```" .. tostring(status) .. "```", ["inline"] = true},
                    {["name"] = "📈 Reputation", ["value"] = "```" .. repRawText .. "```", ["inline"] = true},
                    {["name"] = "⏱️ Gain", ["value"] = "```" .. (gain > 0 and "+" or "") .. tostring(gain) .. "```", ["inline"] = true},
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }
        HttpRequest({Url = _G.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
    end

    if _G.deathConn then _G.deathConn:Disconnect() end
    _G.deathConn = Player.CharacterAdded:Connect(function(char)
        if _G.rod then setUIState(true) end
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.Died:Connect(function()
                if _G.rod then task.wait(0.01); respawn(_G.lastSavedPos) end
            end)
        end
    end)

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/Unknown%20UI%20v2.luau"))()
    local Window  = Library.new("SPTS : Classic", "Version: 2.0-rep")
    local Main    = Library:addPage("Auto Farm", 10723376114)
    local FarmSec = Window:PageAddSection(Main, "Combat Farm", true)
    local Utils   = Window:PageAddSection(Main, "Utilities", true)

    FarmSec:addToggle("Auto Kill", false, function(t) _G.killBots = t end)
    FarmSec:addToggle("Return On Death", false, function(t) _G.rod = t; setUIState(t) end)
    FarmSec:addButton("Teleport to Spawn", function() teleportTo(Vector3.new(448, 250, 883)) end)
    FarmSec:addButton("Teleport to Leaderboards", function() teleportTo(Vector3.new(-733, 250, 736)) end)

    Utils:addToggle("Auto Rejoin", false, function(t) ToggleRejoin(t) end)
    Utils:addSlider("FPS Limit", 10, 60, 60, function(t) setfpscap(t) end)
    Utils:addKeybind("Toggle Hub", Enum.KeyCode.RightControl, function() Window:ToggleUI() end)

    _G.MainLoopActive = true
    local lastWebhookSent = 0
    local punchSide = "Left"

    task.spawn(function()
        while _G.MainLoopActive and task.wait(0.05) do
            local char = Player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
            if _G.rod or _G.deathTrainActive then
                if not ScreenGui.Enabled then ScreenGui.Enabled = true end
                if hum and hum.Health > 1 and hrp then
                    _G.lastSavedPos = hrp.CFrame
                end
                if hum and hum.Health > 0 and hum.Health <= 51 then
                    respawn(_G.lastSavedPos)
                end
            end

            if _G.killBots then
                local target = Players:FindFirstChild(TargetName)
                if target and target.Character and hrp then
                    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then targetHrp.CFrame = hrp.CFrame end
                    RemoteEvent:FireServer({"Skill_Punch", punchSide})
                    punchSide = (punchSide == "Left" and "Right" or "Left")
                end
            end

            if Player.Name == TargetName and (tick() - lastWebhookSent >= 60) then 
                lastWebhookSent = tick()
                sendWebhook()
            end
        end
    end)

    local function deactivateAllToggles()
        _G.MainLoopActive = false

        local t = {
            "autofs", "autobt", "automs", "autojf", "autopp", "rod", "autoquest",
            "espActive", "WebhookActive", "deathTrainActive", "deathTrain", "antiafk", 
            "bringplayer", "bringall", "autosphere", "autopunch", "PMActive"
        }
        for _, varName in ipairs(t) do _G[varName] = false end

        local conns = {"deathConn", "ESPConn", "OnCE", "XpConnection"}
        for _, name in ipairs(conns) do
            if _G[name] then 
                _G[name]:Disconnect() 
                _G[name] = nil 
            end
        end
        
        local intro = PlayerGui:FindFirstChild("IntroGui")
        if intro then intro.Enabled = true end
        if Lighting:FindFirstChild("Blur") then Lighting.Blur.Enabled = true end
        
        _G.PMActive = false
        RunService:Set3dRenderingEnabled(true)
        if BlackoutGui then BlackoutGui:Destroy() end
        Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        setfpscap(60)
    end

    task.spawn(function()
        RemoteEvent:FireServer({"Respawn"})
        local intro = PlayerGui:FindFirstChild("IntroGui")
        local skill = ScreenGui:FindFirstChild("SkillHotkey_Frame")
        local blur  = Lighting:FindFirstChild("Blur")
        if intro then intro.Enabled = false end
        if blur then blur.Enabled = false end
        if ScreenGui then ScreenGui.Enabled = true end
        if skill then skill:Destroy() end
    end)

    if Library and Library.Container then Library.Container.Destroying:Connect(deactivateAllToggles) end
end
