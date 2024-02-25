--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local modules = RepS.Modules
local ui = modules.UI

return function (plr: Player)
    require(ui.Hints)(plr)
    require(ui.PostStroke)(plr)
end
