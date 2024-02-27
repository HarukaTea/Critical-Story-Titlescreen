
local assets = {}

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

assets.Class = {
    Warrior = "rbxassetid://2965862892",
    Archer = "rbxassetid://2965863905",
    Wizard = "rbxassetid://2965863231",
    Knight = "rbxassetid://2965863677",
    Rogue = "rbxassetid://12284961892",
    Repeater = "rbxassetid://12190533959",
    Striker = "rbxassetid://12190535870",
    Alchemist = "rbxassetid://12236618949",
    Illusionist = "rbxassetid://15875390788"
}
assets.TweenInfos = {
    threeHalf = newTweenInfo(0.15),
	twiceHalf = newTweenInfo(0.2),
	onceHalf = newTweenInfo(0.3),
	half = newTweenInfo(0.5),
	halfBack = newTweenInfo(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = newTweenInfo(0.75),
	one = newTweenInfo(1),
	oneHalf = newTweenInfo(1.5),
	two = newTweenInfo(2),
}
assets.friendsStatusColors = {
	[1] = fromRGB(0, 198, 96),
    [4] = fromRGB(0, 198, 96),
    [5] = fromRGB(0, 198, 96),

	[0] = fromRGB(85, 170, 255),
    [2] = fromRGB(85, 170, 255),

	[3] = fromRGB(255, 170, 0),
    [6] = fromRGB(255, 170, 0)
}
assets.DimensionNames = {
    InitusVillage = "Initus Village",
    MonolithGrove = "Monolith Grove",
    InitusBay = "Initus Bay",
    PrimisField = "Primis Field",
    SonusCave = "Sonus Cave",
    MisniPort = "Misni Port",
    Highland = "High Lands",
    Tundra = "Tundra"
}

return assets