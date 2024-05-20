--!nocheck

local ServerUtil = {}

function ServerUtil:SetCollisionGroup(object: Instance, group: string)
	if object:IsA("BasePart") or object:IsA("UnionOperation") or object:IsA("CornerWedgePart") then object.CollisionGroup = group end

	for _, child: Instance in object:GetChildren() do ServerUtil:SetCollisionGroup(child, group) end
end

return ServerUtil
