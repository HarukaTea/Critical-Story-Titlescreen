--!nocheck

local playerStats = {
	Slot1 = {
		Stats = {
			Levels = 1,
			PlayTime = 0,

			Class = "Warrior",
			LastSeenLocation = "MonolithVillage",
			LastSeenWorld = "Mainworld",
			Cosmetic = "None",
		},

		Quests = {
			Main = 1,
			Side = {},
			Town = {}
		}
	}
}
playerStats.Slot2 = playerStats.Slot1
playerStats.Slot3 = playerStats.Slot1

return playerStats
