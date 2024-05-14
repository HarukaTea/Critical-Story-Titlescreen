--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local camera = workspace.CurrentCamera

local instanceNew = Instance.new
local cfAngles = CFrame.Angles
local rad = math.rad

--// Setups

local function blurSetup()
    local blur = instanceNew("BlurEffect")
    blur.Size = 10
    blur.Parent = camera
end
blurSetup()

local function skyballSetup()
    local skyball = workspace:WaitForChild("Maps").TimeDomain.Models.Skyball :: Model

    HarukaLib.Clock(0.01, function()
        skyball:PivotTo(skyball.PrimaryPart.CFrame * cfAngles(0, rad(0.1), 0))
    end)
end
skyballSetup()
