--!nocheck

local PS = game:GetService("PhysicsService")

local function collisionRegister()
	PS:RegisterCollisionGroup("Player")

	PS:CollisionGroupSetCollidable("Player", "Player", false)
end
collisionRegister()
