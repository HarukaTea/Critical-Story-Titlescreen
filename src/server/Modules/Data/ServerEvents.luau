--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Events = {
	CreateHint = Warp(true, "CreateHint"),
	DataWipe = Warp(true, "DataWipe"),
	ErrorDataStore = Warp(true, "ErrorDataStore"),
	TeleportFailed = Warp(true, "TeleportFailed"),
    TeleportPrompt = Warp(true, "TeleportPrompt"),
}

return Events
