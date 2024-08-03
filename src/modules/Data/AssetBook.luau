--!nocheck

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
    Illusionist = "rbxassetid://15875390788",
    Juggernaut = "rbxassetid://16654290906",
    Reaper = "rbxassetid://17667241921",
    WindDancer = "rbxassetid://18423401512"
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
    InitusBay = "Initus Bay",
    PrimisField = "Primis Field",
    EnsisLake = "Ensis Lake",
    VenatorVillage = "Venator Village",
    EnsisRiver = "Ensis River",
    EasterIsland = "Easter Island",
    NorthernStronghold = "Northern Stronghold",

    --// Abandoned places
    Tundra = "Tundra",
    InitusVillage = "Monolith Village",
    MisniPort = "Misni Port",
    Highland = "Highland",
    AlderForest = "Alder Forest",
    SonusCave = "Sonus Cave",
    EnsisCave = "Ensis Cave",
    Highlands = "Highlands",
    ClockTown = "Clock Town",
    AlderTown = "Alder Town",
    ThyrsusForest = "Thyrsus Woods",

    --// Future places
    NiximEntrance = "Nixim Village",
    NiximCliff = "Nixim Cliff",
    NiximForest = "Nixim Forest",
    AuraIsland = "Aura Islands",
    FirestoneIsland = "Firestone Islands",

    --// ?
    DeepThyrsusWoods = "?",
    HigherLands = "?",
    ThyrsusWoods = "?",
    Baseplate = "?"
}

AssetBook.WorldInfo = {
	Mainworld = 17553948946, PrivateTest = 17553875545, NiximCavern = 18331826662,
	Everfrost = 18331688502, Stronghold = 18331688973, Arkus = 18331795211, LoneTown = 18331808756,
	SummerIsland = 18331781219, StrikeWorld = 18331860434
}
AssetBook.TeleportWorldInfo = {
    Mainworld = "MAIN WORLD",
    Stronghold = "NORTHERN STRONGHOLD"
}

AssetBook.StorySeries = {
    "The Beginning",
    "First Steps",
    "Valiant Explorer",
    "Critical Power",
    "The Future",
    "Encounter"
}

return AssetBook