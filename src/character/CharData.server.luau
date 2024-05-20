--!nocheck

local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model

local function setup()
    ServerUtil:SetCollisionGroup(char, "Player")
end
setup()
