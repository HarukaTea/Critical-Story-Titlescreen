--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Warp = require(RepS.Modules.Packages.Warp)

return {
	CreateHint = Warp("CreateHint"),
	DataWipe = Warp("DataWipe"),
	TeleportFailed = Warp("TeleportFailed"),
    TeleportPrompt = Warp("TeleportPrompt"),
}
