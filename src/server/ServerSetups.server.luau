--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")

local function collisionRegister()
	PS:RegisterCollisionGroup("Player")
	PS:RegisterCollisionGroup("ClonedCharacter")

	PS:CollisionGroupSetCollidable("Player", "Player", false)
	PS:CollisionGroupSetCollidable("Player", "ClonedCharacter", false)
	PS:CollisionGroupSetCollidable("ClonedCharacter", "ClonedCharacter", false)
end
collisionRegister()

local function mainSetup()
	RepS.Package.Sounds.Parent = workspace
end
mainSetup()
