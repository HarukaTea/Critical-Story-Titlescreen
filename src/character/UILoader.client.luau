--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local UIModules = RepS.Modules.UI
local requireList = {
    UIModules.Hints,
	UIModules.TitleScreen
}

local function setup()
	for _, module: ModuleScript in requireList do
		Spawn(function() require(module)(plr) end)
	end
end
setup()
