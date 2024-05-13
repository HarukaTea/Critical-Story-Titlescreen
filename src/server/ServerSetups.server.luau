--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")

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
	for _, mapPart: Instance in workspace:GetDescendants() do
		if mapPart:IsA("BasePart") or mapPart:IsA("UnionOperation") or mapPart:IsA("CornerWedgePart") then mapPart.CanTouch = false end
	end

	local sounds = newInstance("Folder")
	sounds.Name = "Sounds"
	sounds.Parent = workspace
	for _, sound: Sound in package.Sounds:GetChildren() do
		sound:Clone().Parent = sounds
	end
end
mainSetup()
