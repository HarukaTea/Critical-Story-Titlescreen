--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

local Net = Warp.Client

local Events = {
	CreateHint = Net("CreateHint"),
	ErrorDataStore = Net("ErrorDataStore"),
	TeleportFailed = Net("TeleportFailed"),
    TeleportPrompt = Net("TeleportPrompt"),
    DataWipe = Net("DataWipe")
}

return Events
