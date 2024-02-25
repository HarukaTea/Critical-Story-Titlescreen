--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local FastNet2 = require(RepS.Modules.Packages.imezx_fastnet2.fastnet2)

local Net = FastNet2.new

local Events = {
	CreateHint = Net("CreateHint", false),
	ErrorDataStore = Net("ErrorDataStore"),
	TeleportFailed = FastNet2.new("TeleportFailed"),
    TeleportPrompt = FastNet2.new("TeleportPrompt"),
    DataWipe = FastNet2.new("DataWipe")
}

return Events
