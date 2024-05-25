--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local UIModules = ReplicatedStorage.Modules.UI
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
