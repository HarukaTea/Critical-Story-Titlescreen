--!nocheck

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local function collisionRegister()
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:RegisterCollisionGroup("ClonedCharacter")

	PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "ClonedCharacter", false)
	PhysicsService:CollisionGroupSetCollidable("ClonedCharacter", "ClonedCharacter", false)
end
collisionRegister()


local function setup()
	ReplicatedStorage.Package.Sounds.Parent = workspace
end
setup()
