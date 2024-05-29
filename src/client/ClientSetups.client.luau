--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local camera = workspace.CurrentCamera
local plr = Players.LocalPlayer

--// Setups

local function blurSetup()
    local blur = Instance.new("BlurEffect")
    blur.Name = "UIBlur"
    blur.Size = 10
    blur.Parent = camera
end
blurSetup()

local function skyballSetup()
    local skyball = workspace:WaitForChild("Maps", 999).TimeDomain.Models.Skyball :: Model

    HarukaLib.Clock(0.01, function()
        skyball:PivotTo(skyball.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(0.1), 0))
    end)
end
skyballSetup()

local function clearDebris()
    repeat task.wait() until plr.PlayerGui:FindFirstChild("Freecam")

    task.wait()
    plr.PlayerGui.Freecam:Destroy()
end
clearDebris()
