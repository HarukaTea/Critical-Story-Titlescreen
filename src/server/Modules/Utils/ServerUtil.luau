--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local ServerUtil = {}

--// Private
local function _optimizeModel(model: Model)
	for _, part: BasePart in model:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("UnionOperation") or part:IsA("CornerWedgePart") then
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Anchored = false
		end
	end
end
local function _equipWeapon(char: Model, weapon: Model, defaultPart: string)
	local weldPos = weapon:GetAttribute("Position") or defaultPart

	ServerUtil:WeldModel(char[weldPos], weapon)
	_optimizeModel(weapon)

	weapon.Parent = char
end

function ServerUtil:WeldModel(part: Part, welded: Model)
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
	for _, child: BasePart in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then child.Anchored = false end
	end
end


function ServerUtil:EquipWeapon(char: Model, class: string)
	local styleFolder = RepS.Package.ClassWeapons[class] :: Folder

	--- clear existing weapons
	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	--- equip weapon
	_equipWeapon(char, styleFolder.WeaponEquipped:Clone(), "Right Arm")
	_equipWeapon(char, styleFolder.WeaponEquipped2:Clone(), "Left Arm")
end


function ServerUtil:EquipArmor(char: Model, armorId: string)
	if char:FindFirstChild("Armor") then char.Armor:Destroy() end
	if not armorId then return end

	--- clear existing weapons
	for _, child: Instance in char:GetChildren() do
		if child:HasTag("Weapon") then child:Destroy() end
	end

	--- equip armor
	local armor = RepS.Package.Cosmetics[armorId]:Clone() :: Model
	local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg", "Extra" }

	--- wait character fully loads
	for _, part: string in equipList do
		if part == "Extra" then continue end

		char:WaitForChild(part, 999)
	end

	--- armor optimization
	_optimizeModel(armor)

	--- equip armor
	local function _equipArmorPart(part: string)
		for _, child: BasePart in armor[part]:GetChildren() do
			if child.Name ~= "Middle" then
				local weldC = Instance.new("WeldConstraint")
				weldC.Part0 = child.Parent.Middle
				weldC.Part1 = child
				weldC.Parent = armor
			end
		end

		local weld = Instance.new("Weld")
		weld.Part0 = char:FindFirstChild(if part == "Extra" then "Torso" else part)
		weld.Part1 = armor[part].Middle
		weld.Parent = armor
	end
	for _, part: string in equipList do
		if not armor:FindFirstChild(part) then continue end

		_equipArmorPart(part)
	end

	--- equip weapon
	local function _weldWeapon(weapon: string, part: string)
		if not armor:FindFirstChild(weapon) then return end

		local realWeapon = armor[weapon]:Clone() :: Model
		ServerUtil:WeldModel(char[part.." Arm"], realWeapon)

		realWeapon:AddTag("Weapon")
		realWeapon.Parent = char
	end
	_weldWeapon("HandleLeft", "Left")
	_weldWeapon("HandleRight", "Right")

	armor.Name = "Armor"
	armor.Parent = char
end


function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") or object:IsA("UnionOperation") or object:IsA("CornerWedgePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do ServerUtil:SetCollisionGroup(child, group) end
end

return ServerUtil
