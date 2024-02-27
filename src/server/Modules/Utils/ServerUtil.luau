--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cfNew, instanceNew = CFrame.new, Instance.new
local floor, random, rad = math.floor, math.random, math.rad
local cfAngles = CFrame.Angles

local ServerUtil = {}

--[[
	SuperWeld actually, a simple function to create weld between two parts
]]
function ServerUtil:WeldPart(part: Part, welded: Model, style: string?)
	local finalWeld = if style == "Orb" then welded.Base else welded.Middle

	local C = welded:GetChildren()
	for i = 1, #C do
		if C[i]:IsA("BasePart") or C[i]:IsA("UnionOperation") then
			local W = instanceNew("Weld")
			W.Part0 = finalWeld
			W.Part1 = C[i]
			local CJ = cfNew(finalWeld.Position)
			W.C0 = finalWeld.CFrame:Inverse() * CJ
			W.C1 = C[i].CFrame:Inverse() * CJ
			W.Parent = finalWeld
		end
		local Y = instanceNew("Weld")
		Y.Part0 = part
		Y.Part1 = finalWeld
		Y.C0 = cfNew(Vector3.zero)
		Y.Parent = Y.Part0
	end
	local h = welded:GetChildren()
	for _, child in h do
		if child:IsA("BasePart") or child:IsA("UnionOperation") then
			child.Anchored = false
		end
	end
end

--[[
	Equip player's weapon, you can only pass an class string to force equip
]]
function ServerUtil:EquipWeapon(char: Model, allowClearAction: boolean?, forceClass: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local class = forceClass or plr:GetAttribute("Class")

	for _, child in char:GetChildren() do
		if child:GetAttribute("Weapon") then child:Destroy() end
		if child.Name == "Head" and allowClearAction then
			if child:FindFirstChildWhichIsA("BillboardGui") then
				child:FindFirstChildWhichIsA("BillboardGui"):Destroy()
			end
		end
	end

	if class == "Alchemist" then
		local model = RepS.Package.StyleWeapons.Alchemist.WeaponEquipped:Clone() :: Model
		model.Parent = char

		ServerUtil:WeldPart(char["Right Arm"], model)
		ServerUtil:SetCollisionGroup(model, "NPC")

		local model2 = RepS.Package.StyleWeapons.Alchemist.WeaponEquipped2:Clone() :: Model
		model2.Parent = char

		ServerUtil:WeldPart(char["Left Arm"], model2)
		ServerUtil:SetCollisionGroup(model2, "NPC")
	else
		local model = RepS.Package.StyleWeapons[class].WeaponUnequip:Clone() :: Model
		model.Parent = char

		ServerUtil:WeldPart(char.Torso, model)
		ServerUtil:SetCollisionGroup(model, "NPC")
	end
end

--[[
	Equip cosmetics, just like equip weapons, you can pass a cosmetic to force equip
]]
function ServerUtil:EquipCosmetics(char: Model, forceCosmetic: string?)
	local plr = Players:GetPlayerFromCharacter(char)
	local cosmetic = forceCosmetic or plr:GetAttribute("Cosmetic")

	if cosmetic == "None" then return end

    if char.Humanoid.Health > 0 then
        if char:FindFirstChild("Armor") then char.Armor:Destroy() end
		for _, child in char:GetChildren() do
			if child:GetAttribute("Weapon") then child:Destroy() end
		end


		local armor = RepS.Package.Items.Cosmetics[cosmetic]:Clone() :: Model
        local equipList = { "Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

        --- wait character fully loads
        for _, part in equipList do char:WaitForChild(part, 999) end

		--- equip armor
        for _, part in equipList do
            for _, child in armor[part]:GetChildren() do
                if child.Name ~= "Middle" then
                    local weldC = instanceNew("WeldConstraint")
                    weldC.Part0 = child.Parent.Middle
                    weldC.Part1 = child
                    weldC.Parent = armor
                end
            end

            local weld = instanceNew("Weld")
            weld.Part0 = char:FindFirstChild(part)
            weld.Part1 = armor[part].Middle
            weld.Parent = armor
        end

        armor.Name = "Armor"
        armor.Parent = char

		local leftWeapon = armor.HandleLeft:Clone() :: Model
		leftWeapon:SetAttribute("Weapon", true)
		leftWeapon.Parent = char

		local rightWeapon = armor.HandleRight:Clone() :: Model
		rightWeapon:SetAttribute("Weapon", true)
		rightWeapon.Parent = char

		ServerUtil:WeldPart(char["Left Arm"], leftWeapon)
		ServerUtil:WeldPart(char["Right Arm"], rightWeapon)
    end
end

--[[
	Spawn a monster, with the given locator part, you can pass level in to force
	spawn strong monsters
]]
function ServerUtil:SetupMonster(locator: Part, forceLevel: number?) : Model
	local level = forceLevel or locator:GetAttribute("Levels")

	local monster = RepS.Package.MonsterModels[locator.Name]:Clone() :: Model
	monster:PivotTo(cfNew(locator.Position) * cfAngles(0, rad(random(1, 360)), 0))
	monster:SetAttribute("Levels", level)
	monster.Head.TierDisplay.Level.Text = "Level " .. level
	monster.Parent = locator
	if locator:GetAttribute("SubMonster") then
		monster.Head.TierDisplay.Enabled = false
		monster:SetAttribute("SubMonster", true)
	end

	monster:SetAttribute("MaxHealth", level ^ 2 + 59)
	monster:SetAttribute("Health", monster:GetAttribute("MaxHealth"))
	monster:SetAttribute("EXP", floor(level ^ 1.25) + 25)
	monster:SetAttribute("Damage", 5 * level)
	monster:SetAttribute("InCombat", false)
	monster:SetAttribute("IsMonster", true)

	locator.Transparency = 1
end

--[[
	A simple function to set a part's collision group
]]
function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") then
		object.CollisionGroup = group
	end

	for _, child in object:GetChildren() do
		ServerUtil:SetCollisionGroup(child, group)
	end
end

return ServerUtil
