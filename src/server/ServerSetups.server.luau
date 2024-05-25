--!nocheck

local PhysicsService = game:GetService("PhysicsService")

local function collisionRegister()
	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:RegisterCollisionGroup("ClonedCharacter")

	PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)
	PhysicsService:CollisionGroupSetCollidable("Player", "ClonedCharacter", false)
	PhysicsService:CollisionGroupSetCollidable("ClonedCharacter", "ClonedCharacter", false)
end
collisionRegister()
