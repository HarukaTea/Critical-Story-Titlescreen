--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local UIModules = RepS.Modules.UI
local requireList = {
    UIModules.PostStroke,
    UIModules.Hints,
	UIModules.TitleScreen
}
for _, module in requireList do
	Spawn(function()
		require(module)(Players.LocalPlayer)
	end)
end
