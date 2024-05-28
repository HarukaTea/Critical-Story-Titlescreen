--!nocheck

local Chat = game:GetService("Chat")
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


local function clearChatModules()
	repeat task.wait() until Chat:FindFirstChildOfClass("Script")

	task.wait()
	Chat:ClearAllChildren()

	repeat task.wait() until ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

	task.wait()
	ReplicatedStorage.DefaultChatSystemChatEvents:Destroy()
end
clearChatModules()
