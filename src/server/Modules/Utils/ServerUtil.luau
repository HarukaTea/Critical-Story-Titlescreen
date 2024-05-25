--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerUtil = {}

function ServerUtil:WeldPart(part: Part, welded: Model)
	local C = welded:GetChildren()
	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") or C[i]:IsA("CornerWedgePart") then
			local W = Instance.new("Weld")
			W.Part0 = welded.Middle
			W.Part1 = C[i]

			local CJ = CFrame.new(welded.Middle.Position)
			W.C0 = welded.Middle.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = welded.Middle
		end

		local Y = Instance.new("Weld")
		Y.Part0 = part
		Y.Part1 = welded.Middle
		Y.C0 = CFrame.new(Vector3.zero)
		Y.Parent = Y.Part0
	end

	local h = welded:GetChildren()
	for _, child in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then child.Anchored = false end
	end
end

function ServerUtil:EquipWeapon(char: Model, class: string)
	local styleFolder = ReplicatedStorage.Package.StyleWeapons[class] :: Folder

	for _, child: Instance in char:GetChildren() do
		if string.find(child.Name, "Weapon") then child:Destroy() end
	end

	local function _equipWeapon()
		local weapon = styleFolder.WeaponEquipped:Clone() :: Model
		local weldPos = if weapon:GetAttribute("Position") then weapon:GetAttribute("Position") else "Right Arm"

		ServerUtil:WeldPart(char[weldPos], weapon)

		weapon.Parent = char
	end

	_equipWeapon()
	if styleFolder:FindFirstChild("WeaponEquipped2") then _equipWeapon() end
end

function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") or object:IsA("UnionOperation") or object:IsA("CornerWedgePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do ServerUtil:SetCollisionGroup(child, group) end
end

return ServerUtil
