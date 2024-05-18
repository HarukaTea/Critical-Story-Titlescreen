--!nocheck
--!optimize 2
--!native

return {
    StatsV2 = {
		Levels = 1,
		EXP = 0,
		Gold = 0,
		RP = 0,
		PlayTime = 0,

		Class = "Warrior",
		LastSeenLocation = "MonolithVillage",
		RespawnLocation = { "Vector3", 0, 0, 0 },

		LvPoints = 0,
		DMGPoints = 0,
		MagicPoints = 0,
		ManaPoints = 0,
		ShieldPoints = 0,
		HealthPoints = 0,

		V2Transfered = false
	},

	BanStats = {
		IsBanned = false,
		Duration = 0,
		BannedTime = 0,
		Reason = ""
	},

	InventoryV2 = {},

	QuestsV2 = {
		Main = 1,
		Town = {}
	}
}