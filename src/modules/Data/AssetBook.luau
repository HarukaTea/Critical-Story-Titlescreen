--!nocheck
--!optimize 2
--!native

local AssetBook = {}

local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

AssetBook.TweenInfos = {
	fourHalf = newTweenInfo(0.05),
	threeHalf = newTweenInfo(0.15),
	twiceHalf = newTweenInfo(0.2),
	onceHalf = newTweenInfo(0.3),
	half = newTweenInfo(0.5),
	halfBack = newTweenInfo(0.5, Enum.EasingStyle.Back),
	twiceHalfOne = newTweenInfo(0.75),
	threeHalfOne = newTweenInfo(0.9),
	one = newTweenInfo(1),
	oneHalf = newTweenInfo(1.5),
	two = newTweenInfo(2),
    four = newTweenInfo(4),
	six = newTweenInfo(6),
    fifteen = newTweenInfo(15, Enum.EasingStyle.Linear)
}

AssetBook.Class = {
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

AssetBook.friendsStatusColors = {
	[1] = fromRGB(0, 198, 96),
    [4] = fromRGB(0, 198, 96),
    [5] = fromRGB(0, 198, 96),

	[0] = fromRGB(85, 170, 255),
    [2] = fromRGB(85, 170, 255),

	[3] = fromRGB(255, 170, 0),
    [6] = fromRGB(255, 170, 0)
}

AssetBook.LocationInfo = {
    MonolithVillage = "Monolith Village",
    MonolithGrove = "Monolith Grove",
    MisniPort = "Misni Port",
    Highland = "Highland",

    InitusBay = "Initus Bay",
    PrimisField = "Primis Field",
    ThyrsusForest = "Thyrsus Woods",
    AlderForest = "Alder Forest",
    EnsisLake = "Ensis Lake",
    SonusCave = "Sonus Cave",
    EnsisCave = "Ensis Cave",
    Highlands = "Highlands",
    VenatorVillage = "Venator Village",
    EnsisRiver = "Ensis River",
    ClockTown = "Clock Town",
    AlderTown = "Alder Town",
    NiximEntrance = "Nixim Village",
    NiximCliff = "Nixim Cliff",
    NiximForest = "Nixim Forest",
    NorthernStronghold = "Northern Stronghold",
    AuraIsland = "Aura Islands",
    FirestoneIsland = "Firestone Islands",

    Tundra = "Tundra",
}

AssetBook.StorySeries = {
    "The Beginning",
    "Valiant Explorer",
    "First Step",
    "The Future",
    "The Abyss - Paho",
    "Initus Bay",
    "Slime Troubles",
    "The Next Journey",
    "Misni Port",
}

return AssetBook