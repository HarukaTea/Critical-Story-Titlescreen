--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Clock = require(RepS.Modules.Packages.Clock)
local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local cfAngles = CFrame.Angles
local rad = math.rad

local UIModules = RepS.Modules.UI
local requireList = {
    UIModules.PostStroke,
    UIModules.Hints
}
for _, module in requireList do
	Spawn(function()
		require(module)(plr)
	end)
end

local skyball = workspace:WaitForChild("Maps").Bossfight.Terrain.Skyball :: Model
Clock(0.01, function()
	skyball:PivotTo(skyball.PrimaryPart.CFrame * cfAngles(0, rad(0.1), 0))
end)