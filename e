if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId == 2202352383 then
    local Players           = game:GetService("Players")
    local Lighting          = game:GetService("Lighting")
    local Workspace         = game:GetService("Workspace")
    local RunService        = game:GetService("RunService")
    local HttpService       = game:GetService("HttpService")
    local VirtualUser       = game:GetService("VirtualUser")
    local TweenService      = game:GetService("TweenService")
    local UserInputService  = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpRequest       = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or (request)
    local Player            = Players.LocalPlayer
    local PlayerGui         = Player:WaitForChild("PlayerGui")
    local ScreenGui         = PlayerGui:WaitForChild("ScreenGui")
    local TokenBtn          = ScreenGui:WaitForChild("CurrentGemImgBtn"):WaitForChild("AmountTxtBtn")
    local RemoteEvent       = ReplicatedStorage:WaitForChild("RemoteEvent")
    local AnimFolder        = ReplicatedStorage:WaitForChild("AnimStorage")
    local Suffixes          = {K = 1e3, M = 1e6, B = 1e9, T = 1e12, QA = 1e15, QI = 1e18, SX = 1e21}

    -- ==========================================
    -- Data Tables
    -- ==========================================
    local MiscTeleports = {
        {name = "Teleport to Spawn", pos = Vector3.new(448, 250, 883)},
        {name = "Teleport to Leaderboards", pos = Vector3.new(-733, 250, 736)}
    }

    _G.MainLoopActive = false
    task.wait(0.2)
    _G.MainLoopActive = true

    -- ==========================================
    -- Functions
    -- ==========================================
    local Storage = ReplicatedStorage:FindFirstChild("Storage") or Instance.new("Folder", ReplicatedStorage)
    Storage.Name = "Storage"

    local function Create(class, parent, props)
        local obj = Instance.new(class)
        for prop, val in pairs(props) do 
            obj[prop] = val 
        end
        obj.Parent = parent
        return obj
    end

    local function setUIState(hide)
        local intro = PlayerGui:FindFirstChild("IntroGui") or Storage:FindFirstChild("IntroGui")
        local blur = Lighting:FindFirstChild("Blur") or Storage:FindFirstChild("Blur")
        
        if hide then
            if intro then 
                intro.Enabled = false
                intro.Parent = Storage 
            end
            if blur then 
                blur.Enabled = false
                blur.Parent = Storage 
            end
        else
            if intro then 
                intro.Enabled = false 
                intro.Parent = PlayerGui 
            end
            if blur then 
                blur.Enabled = false
                blur.Parent = Lighting 
            end
        end
    end

    local function formatWithCommas(num)
        if not num then return "0" end
        local formatted = tostring(math.floor(math.abs(num)))
        local k = 3
        while k < #formatted do
            formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
            k = k + 4
        end
        return (num < 0 and "-" or "") .. formatted
    end

    local function teleportTo(pos)
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos) end
    end

    local track1, track2
    local function loadAnims()
        local char = Player.Character
        local hum = char and char:WaitForChild("Humanoid", 5)
        if hum then
            track1 = hum:LoadAnimation(AnimFolder.Punch1Anim)
            track2 = hum:LoadAnimation(AnimFolder.Punch2Anim)
        end
    end
    Player.CharacterAdded:Connect(function() task.wait(1); loadAnims() end)
    loadAnims()

    local selectedPlayerCombat = Player.Name 
    local selectedPlayerStats = Player.Name 
    local selectedPlayerName = Player.Name
    local function GetPlayerDisplayNames()
        local displayNames = {}
        playerLookup = {} 
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player then 
                local displayText = p.DisplayName .. " (@" .. p.Name .. ")"
                table.insert(displayNames, displayText)
                playerLookup[displayText] = p.Name
            end
        end 
        return displayNames
    end

    local function respawn(savedPos)
        local oldCam = Workspace.CurrentCamera
        if oldCam then oldCam:Destroy() end
        
        RemoteEvent:FireServer({"Respawn"})

        local newCam = Workspace:WaitForChild("Camera", 10)    
        local newChar = Player.CharacterAdded:Wait()
        local hum = newChar:WaitForChild("Humanoid", 10)
        local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
        
        if newCam and hum then
            newCam.CameraType = Enum.CameraType.Custom
            newCam.CameraSubject = hum
        end
        
        if _G.rod or _G.deathTrainActive then
            setUIState(true)
            if ScreenGui then ScreenGui.Enabled = true end
        end

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

    local BlackoutGui = Create("ScreenGui", PlayerGui, {Name = "BlackoutUI", IgnoreGuiInset = true, DisplayOrder = -67, ResetOnSpawn = false, Enabled = false})
    local Frame = Create("Frame", BlackoutGui, {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), Active = false, BorderSizePixel = 0})

    _G.PerformanceKey = Enum.KeyCode.P 
    _G.PMActive = false

    local function togglePerformanceMode()
        _G.PMActive = not _G.PMActive
        RunService:Set3dRenderingEnabled(not _G.PMActive)
        BlackoutGui.Enabled = _G.PMActive
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == _G.PerformanceKey then
            togglePerformanceMode()
        end
    end)

    -- ==========================================
    -- Stat Tracking, AntiAFK
    -- ==========================================
    if _G.deathConn then _G.deathConn:Disconnect() end
    _G.deathConn = Player.CharacterAdded:Connect(function(char)
        if _G.rod or _G.deathTrainActive then 
            setUIState(true) 
        end
        
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            hum.Died:Connect(function()
                if _G.rod or _G.deathTrainActive then 
                    task.wait(0.01) 
                    respawn(_G.lastSavedPos) 
                end
            end)
        end
    end)

    _G.antiafk = true
    task.spawn(function()
        while not Player do task.wait() Player = game:GetService("Players").LocalPlayer end
        local function enableAntiAfk()
            if getconnections then
                for _, connection in pairs(getconnections(Player.Idled)) do
                    if connection["Disable"] then
                        connection["Disable"](connection)
                    elseif connection["Disconnect"] then
                        connection["Disconnect"](connection)
                    end
                end
            else
                Player.Idled:Connect(function()
                    if _G.antiafk then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end
                end)
            end
        end
        enableAntiAfk()
    end)

    -- ==========================================
    -- UI Creation
    -- ==========================================
    local Library      = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/Unknown%20UI%20v2.luau"))()
    local Window       = Library.new("SPTS : Classic", "Version: 2.0-rep")
    local Main         = Library:addPage("Auto Farm", 10723376114)
    local Settings     = Library:addPage("Settings", 10734950309)

    local Stats        = Window:PageAddSection(Main, "Stats", true)
    local tp           = Window:PageAddSection(Main, "RoD + Teleport", true)
    local Sett         = Window:PageAddSection(Settings, "Settings", true)

    -- Auto Farm Page
    tp:addToggle("Return On Death", false, function(t)
        _G.rod = t
        setUIState(t)
        if not t and not _G.deathTrainActive then setUIState(false) end
    end)

    local pd = Stats:addDropdown("Selected Player", GetPlayerDisplayNames(), "None", function(selectedDisplay)
        if selectedDisplay then
            local username = playerLookup[selectedDisplay]
            if username then selectedPlayerCombat = username end
        end
    end)
    Players.PlayerAdded:Connect(function() pd:Refresh(GetPlayerDisplayNames()) end)
    Players.PlayerRemoving:Connect(function(p) 
        pd:Refresh(GetPlayerDisplayNames()) 
        if selectedPlayerCombat == p.Name then selectedPlayerCombat = Player.Name end
    end)

    Stats:addToggle("Bring Selected Player", false, function(t) _G.bringplayer = t end)
    Stats:addToggle("Auto Punch", false, function(t) _G.autopunch = t end)
    Stats:addToggle("Auto Sphere", false, function(t) _G.autosphere = t end)

    -- ==========================================
    -- Main Loop
    -- ==========================================
    local lastSpherePunch = 0
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

            if _G.bringplayer then
                local target = Players:FindFirstChild(selectedPlayerCombat)
                if target and target.Character and hrp then
                    local offset = _G.autopunch and CFrame.new(0, 0, 0) or CFrame.new(0, 0, -3)
                    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then targetHrp.CFrame = hrp.CFrame * offset end
                end
            end

            if _G.autopunch then
                if Players:FindFirstChild(selectedPlayerCombat) then
                    RemoteEvent:FireServer({"Skill_Punch", punchSide})
                    punchSide = (punchSide == "Left" and "Right" or "Left")
                end
            end

            if _G.autosphere and (tick() - lastSpherePunch >= 0.25) then
                lastSpherePunch = tick()
                if hrp then
                    local lookVec = hrp.CFrame.LookVector
                    local targetPos = hrp.Position + (lookVec * 100)
                    RemoteEvent:FireServer({"Skill_SpherePunch", targetPos})
                end
            end

            if Player.Name == "Esil_HatesShowers" and (tick() - lastWebhookSent >= 60) then 
                lastWebhookSent = tick()
                sendWebhook()
            end
        end
    end)

    -- Webhook
    _G.WebhookURL = "https://discord.com/api/webhooks/1457786185480147178/_y-fLwD2muf9L79Bzq4PCbCknn_E4G-1tX3Yhq80MypbTk-RbSRqk-SzllRHEm_zbmYO"
    local function parseRep(text)
        local cleaned = text:match(":%s*(-?%d+)")
        return tonumber(cleaned) or 0
    end

    local initialRep = parseRep(Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text)

    function sendWebhook()
        if _G.WebhookURL == "" or _G.WebhookURL == "URL here" then return end

        local status = Player.leaderstats.Status.Value
        local repRawText = Player.PlayerGui.ScreenGui.MenuFrame.InfoFrame.RepTxt.Text
        local currentRep = parseRep(repRawText)
        
        local gain = currentRep - lastRecordedRep
        lastRecordedRep = currentRep

        local data = {
            ["embeds"] = {{
                ["title"] = "Status & Reputation Update",
                ["description"] = "Stats for **" .. Player.DisplayName .. "** (@" .. Player.Name .. ")",
                ["color"] = 0x7D7D7D,
                ["fields"] = {
                    {["name"] = "🎭 Status", ["value"] = "```" .. tostring(status) .. "```", ["inline"] = true},
                    {["name"] = "📈 Reputation", ["value"] = "```" .. repRawText .. "```", ["inline"] = true},
                    {["name"] = "⏱️ Gain (Last 1m)", ["value"] = "```" .. (gain > 0 and "+" or "") .. tostring(gain) .. "```", ["inline"] = true},
                },
                ["timestamp"] = DateTime.now():ToIsoDate()
            }}
        }

        HttpRequest({
            Url = _G.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end

    -- ==========================================
    -- Teleports & Settings
    -- ==========================================
    for _, data in ipairs(MiscTeleports) do
        tp:addButton(data.name, function() teleportTo(data.pos) end)
    end

    Sett:addToggle("Anti-AFK", true, function(t) _G.antiafk = t end)
    Sett:addSlider("FPS Limit", 10, 60, 60, function(t) setfpscap(t) end)
    Sett:addKeybind("Performance Mode", _G.PerformanceKey, function(t) _G.PerformanceKey = t end)
    Sett:addKeybind("Toggle Hub", Enum.KeyCode.RightControl, function() Window:ToggleUI() end)

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
