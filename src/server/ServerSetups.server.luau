--!nocheck

local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")


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

	TeleportService:SetTeleportGui(ReplicatedStorage.Package.Unloads.TeleportUI)
end
setup()
