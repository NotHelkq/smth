if not game:IsLoaded() then game.Loaded:Wait() end
local player = game:GetService("Players").LocalPlayer
local timer = player.PlayerGui.HUD.Frame.RumbleHolder.Timer2
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
    while autoreset and task.wait(0.1) do
        if timer.Text == "1" then
            task.wait(11)
            player.Character:BreakJoints()
        end
    end
end)

-- Settings
settings:addKeybind("Toggle Hub", Enum.KeyCode.LeftControl, function() Window:toggle() end)
settings:addButton("Kill Hub", function()
    Window.container:Destroy()
end)
