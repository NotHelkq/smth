if not _G.Ignore then _G.Ignore = {} end
_G.WaitPerAmount = _G.WaitPerAmount or 500
_G.SendNotifications = _G.SendNotifications or false
_G.ConsoleLogs = _G.ConsoleLogs or false

repeat task.wait() until game:IsLoaded()

if not _G.Settings then
    _G.Settings = {
        Players = {["Ignore Me"]=true,["Ignore Others"]=true,["Ignore Tools"]=true},
        Meshes = {NoMesh=false,NoTexture=false,Destroy=false},
        Images = {Invisible=true,Destroy=false},
        Explosions = {Smaller=true,Invisible=false,Destroy=false},
        Particles = {Invisible=true,Destroy=false},
        TextLabels = {LowerQuality=false,Invisible=false,Destroy=false},
        MeshParts = {LowerQuality=true,Invisible=false,NoTexture=false,NoMesh=false,Destroy=false},
        Other = {["FPS Cap"]=240,["No Camera Effects"]=true,["No Clothes"]=true,
                ["Low Water Graphics"]=true,["No Shadows"]=true,["Low Rendering"]=true,
                ["Low Quality Parts"]=true,["Low Quality Models"]=true,["Reset Materials"]=true,
                ["Lower Quality MeshParts"]=true}
    }
end

local Players, Lighting, StarterGui, MaterialService = game:GetService("Players"), game:GetService("Lighting"), game:GetService("StarterGui"), game:GetService("MaterialService")
local ME, CanBeEnabled = Players.LocalPlayer, {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Instance)
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Instance:IsDescendantOf(v.Character) then return true end
    end
    return false
end

local function DescendantOfIgnore(Instance)
    for i, v in pairs(_G.Ignore) do
        if Instance:IsDescendantOf(v) then return true end
    end
    return false
end

local function CheckIfBad(Instance)
    if not Instance:IsDescendantOf(Players) and (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Instance) or not _G.Settings.Players["Ignore Others"]) and (_G.Settings.Players["Ignore Me"] and ME.Character and not Instance:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) and (_G.Settings.Players["Ignore Tools"] and not Instance:IsA("BackpackItem") and not Instance:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"]) and (_G.Ignore and not table.find(_G.Ignore, Instance) and not DescendantOfIgnore(Instance) or (not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0)) then
        if Instance:IsA("DataModelMesh") then
            if _G.Settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then Instance.MeshId = "" end
            if _G.Settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then Instance.TextureId = "" end
            if _G.Settings.Meshes.Destroy or _G.Settings["No Meshes"] then Instance:Destroy() end
        elseif Instance:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then Instance.Transparency = 1 Instance.Shiny = 1 end
            if _G.Settings.Images.LowDetail then Instance.Shiny = 1 end
            if _G.Settings.Images.Destroy then Instance:Destroy() end
        elseif Instance:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then Instance.Graphic = "" end
            if _G.Settings.Images.Destroy then Instance:Destroy() end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if _G.Settings["Invisible Particles"] or _G.Settings["No Particles"] or (_G.Settings.Other and _G.Settings.Other["Invisible Particles"]) or (_G.Settings.Particles and _G.Settings.Particles.Invisible) then Instance.Enabled = false end
            if (_G.Settings.Other and _G.Settings.Other["No Particles"]) or (_G.Settings.Particles and _G.Settings.Particles.Destroy) then Instance:Destroy() end
        elseif Instance:IsA("PostEffect") and (_G.Settings["No Camera Effects"] or (_G.Settings.Other and _G.Settings.Other["No Camera Effects"])) then Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if _G.Settings["Smaller Explosions"] or (_G.Settings.Other and _G.Settings.Other["Smaller Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Smaller) then Instance.BlastPressure = 1 Instance.BlastRadius = 1 end
            if _G.Settings["Invisible Explosions"] or (_G.Settings.Other and _G.Settings.Other["Invisible Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Invisible) then Instance.BlastPressure = 1 Instance.BlastRadius = 1 Instance.Visible = false end
            if _G.Settings["No Explosions"] or (_G.Settings.Other and _G.Settings.Other["No Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Destroy) then Instance:Destroy() end
        elseif (Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap")) and (_G.Settings["No Clothes"] or (_G.Settings.Other and _G.Settings.Other["No Clothes"])) then Instance:Destroy()
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") and (_G.Settings["Low Quality Parts"] or (_G.Settings.Other and _G.Settings.Other["Low Quality Parts"])) then Instance.Material = Enum.Material.Plastic Instance.Reflectance = 0
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if _G.Settings["Lower Quality TextLabels"] or (_G.Settings.Other and _G.Settings.Other["Lower Quality TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.LowerQuality) then Instance.Font = Enum.Font.SourceSans Instance.TextScaled = false Instance.RichText = false Instance.TextSize = 14 end
            if _G.Settings["Invisible TextLabels"] or (_G.Settings.Other and _G.Settings.Other["Invisible TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.Invisible) then Instance.Visible = false end
            if _G.Settings["No TextLabels"] or (_G.Settings.Other and _G.Settings.Other["No TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.Destroy) then Instance:Destroy() end
        elseif Instance:IsA("Model") and (_G.Settings["Low Quality Models"] or (_G.Settings.Other and _G.Settings.Other["Low Quality Models"])) then Instance.LevelOfDetail = 1
        elseif Instance:IsA("MeshPart") then
            if _G.Settings["Low Quality MeshParts"] or (_G.Settings.Other and _G.Settings.Other["Low Quality MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.LowerQuality) then Instance.RenderFidelity = 2 Instance.Reflectance = 0 Instance.Material = Enum.Material.Plastic end
            if _G.Settings["Invisible MeshParts"] or (_G.Settings.Other and _G.Settings.Other["Invisible MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.Invisible) then Instance.Transparency = 1 Instance.RenderFidelity = 2 Instance.Reflectance = 0 Instance.Material = Enum.Material.Plastic end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoTexture then Instance.TextureID = "" end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoMesh then Instance.MeshId = "" end
            if _G.Settings["No MeshParts"] or (_G.Settings.Other and _G.Settings.Other["No MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.Destroy) then Instance:Destroy() end
        end
    end
end

local function ApplyGlobalSetting(condition, action, logMessage)
    if condition then
        coroutine.wrap(pcall)(action)
        if _G.ConsoleLogs and logMessage then warn(logMessage) end
    end
end

ApplyGlobalSetting(_G.Settings["Low Water Graphics"] or (_G.Settings.Other and _G.Settings.Other["Low Water Graphics"]), function()
    repeat task.wait() until workspace:FindFirstChildOfClass("Terrain")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    Terrain.WaterWaveSize, Terrain.WaterWaveSpeed, Terrain.WaterReflectance, Terrain.WaterTransparency = 0,0,0,0
    if sethiddenproperty then sethiddenproperty(Terrain, "Decoration", false) else warn("sethiddenproperty not supported") end
end, "Low Water Graphics Enabled")

ApplyGlobalSetting(_G.Settings["No Shadows"] or (_G.Settings.Other and _G.Settings.Other["No Shadows"]), function()
    Lighting.GlobalShadows, Lighting.FogEnd, Lighting.ShadowSoftness = false, 9e9, 0
    if sethiddenproperty then sethiddenproperty(Lighting, "Technology", 2) else warn("sethiddenproperty not supported") end
end, "No Shadows Enabled")

ApplyGlobalSetting(_G.Settings["Low Rendering"] or (_G.Settings.Other and _G.Settings.Other["Low Rendering"]), function()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
end, "Low Rendering Enabled")

ApplyGlobalSetting(_G.Settings["Reset Materials"] or (_G.Settings.Other and _G.Settings.Other["Reset Materials"]), function()
    for i, v in pairs(MaterialService:GetChildren()) do v:Destroy() end
    MaterialService.Use2022Materials = false
end, "Reset Materials Enabled")

ApplyGlobalSetting(_G.Settings["FPS Cap"] or (_G.Settings.Other and _G.Settings.Other["FPS Cap"]), function()
    if setfpscap then
        local cap = _G.Settings["FPS Cap"] or (_G.Settings.Other and _G.Settings.Other["FPS Cap"])
        if type(cap) == "string" or type(cap) == "number" then setfpscap(tonumber(cap)) warn("FPS Capped to "..tostring(cap))
        elseif cap == true then setfpscap(1e6) warn("FPS Uncapped") end
    else warn("FPS Cap Failed") end
end)

game.DescendantAdded:Connect(function(value) task.wait(_G.LoadedWait or 1) CheckIfBad(value) end)

local Descendants = game:GetDescendants()
if _G.ConsoleLogs then warn("Checking "..#Descendants.." Instances...") end

local WaitNumber, StartNumber = _G.WaitPerAmount, _G.WaitPerAmount
for i, v in pairs(Descendants) do
    CheckIfBad(v)
    if i == WaitNumber then
        task.wait()
        if _G.ConsoleLogs then print("Loaded "..i.."/"..#Descendants) end
        WaitNumber = WaitNumber + StartNumber
    end
end

warn("FPS Booster Loaded!")
