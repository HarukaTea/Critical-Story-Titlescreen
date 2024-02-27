--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local Signals = {
    CreateHint = Signal.new()
}

return Signals