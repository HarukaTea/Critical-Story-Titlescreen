--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.Modules.Packages.Signal)

local Signals = {
    CreateHint = Signal()
}

return Signals