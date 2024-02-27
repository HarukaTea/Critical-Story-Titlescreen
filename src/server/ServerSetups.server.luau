--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local PS = game:GetService("PhysicsService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local package = RepS.Package

local newInstance = Instance.new

local function collisionRegister()
	PS:RegisterCollisionGroup("Player")
	PS:RegisterCollisionGroup("ClonedCharacter")

	PS:CollisionGroupSetCollidable("Player", "Player", false)
	PS:CollisionGroupSetCollidable("Player", "ClonedCharacter", false)
	PS:CollisionGroupSetCollidable("ClonedCharacter", "ClonedCharacter", false)
end
collisionRegister()

local function mainSetup()
	for _, mapPart in workspace:GetDescendants() do
		if mapPart:IsA("BasePart") then
			mapPart.CanTouch = false
			mapPart.CanQuery = false
		end
	end

	local sounds = newInstance("Folder")
	sounds.Name = "Sounds"
	sounds.Parent = workspace
	for _, sound in package.Sounds:GetChildren() do
		sound:Clone().Parent = sounds
	end
end
mainSetup()
