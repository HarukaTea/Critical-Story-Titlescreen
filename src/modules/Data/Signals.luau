--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal).new

local Signals = {
    CreateHint = Signal(),
    CreateFullScreenHint = Signal()
}

return Signals