--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local PS = game:GetService("PhysicsService")

local ServerUtil = require(SSS.Modules.HarukaFrameworkServer).ServerUtil

local package = RepS.Package

local ServerSetups = {}
ServerSetups.__index = ServerSetups

local newInstance = Instance.new

--[[
    Setups when server starts
]]
function ServerSetups:MainSetup()
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

	for _, child in package.MonsterModels:GetChildren() do
		for _, descendant in child:GetChildren() do
			if descendant:IsA("Part") and child:FindFirstChild(descendant.Name .. "Model") then
				ServerUtil:WeldPart(descendant, child:FindFirstChild(descendant.Name .. "Model"))
			end
		end
	end
	for _, locator in workspace.Monsters:GetDescendants() do
		if locator:GetAttribute("MonsterLocation") then ServerUtil:SetupMonster(locator) end
	end
end

--[[
	Create the collision groups, which are players, npcs and combat border
]]
function ServerSetups:CollisionRegister()
	PS:RegisterCollisionGroup("Player")
	PS:RegisterCollisionGroup("ClonedCharacter")

	PS:CollisionGroupSetCollidable("Player", "Player", false)
	PS:CollisionGroupSetCollidable("Player", "ClonedCharacter", false)
	PS:CollisionGroupSetCollidable("ClonedCharacter", "ClonedCharacter", false)
	PS:CollisionGroupSetCollidable("ClonedCharacter", "Player", false)
end

return function ()
    local self = setmetatable({}, ServerSetups)

	--// Connections
	Players.PlayerAdded:Connect(function(plr)
		if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
			plr.CharacterAdded:Connect(function(char)
				ServerUtil:SetCollisionGroup(char, "Player")
			end)
		end
	end)

	--// Setups
	self:CollisionRegister()
    self:MainSetup()

	require(script.Parent.PlayerSetups)()
end
