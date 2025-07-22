if not game:IsLoaded() then game.Loaded:Wait() end
local player = game:GetService("Players").LocalPlayer
local function getTimer()
    local hud = player.PlayerGui:FindFirstChild("HUD")
    if not hud then return nil end
    local frame = hud:FindFirstChild("Frame")
    if not frame then return nil end
    local rumbleHolder = frame:FindFirstChild("RumbleHolder")
    if not rumbleHolder then return nil end
    return rumbleHolder:FindFirstChild("Timer2")
end
-- lib stuff
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/NotHelkq/smth/refs/heads/main/idk.luau"))()
local Window  = library.new("Random Script")
local Main      = Window:addPage("Auto Farm", 5012544693, true)
local Settings  = Window:addPage("Settings", 5012544693)
local Farm      = Main:addSection("Auto Farm")
local settings  = Settings:addSection("Others")

-- Auto Farm 
Farm:addToggle("Auto Join Rumble", getgenv().Config.autoRumble, function(t)
    autorumble = t
    while autorumble and task.wait(1) do
        for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
            if gui.Name == "TourneyQ" then
                game:GetService("ReplicatedStorage"):WaitForChild("TourneyEvents"):WaitForChild("Enter"):FireServer()
                task.wait(3)
                gui:Destroy()
                break 
            end
        end
    end
end)

Farm:addToggle("Auto Reset", getgenv().Config.autoReset, function(t)
    autoreset = t
    local lastResetTime = 0
    local resetCooldown = false
    while autoreset and task.wait(0.1) do
        local currentTimer = getTimer()
        if currentTimer and currentTimer.Visible and currentTimer.Text == "1" then 
            if not resetCooldown then
                resetCooldown = true
                task.wait(10)
                if player and player.Character then
                    player.Character:BreakJoints()
                end
                task.wait(5) 
                resetCooldown = false
            end
        end
    end
end)

-- Settings
settings:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function() Window:toggle() end)
settings:addButton("Kill Hub", function()
    Window.container:Destroy()
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
