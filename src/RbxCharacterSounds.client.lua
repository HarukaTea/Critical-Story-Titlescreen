--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer

require(RepS.Modules.Mechanics.ClientSetups)(plr)
