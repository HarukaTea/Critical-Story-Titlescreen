--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")

local Spawn = require(RepS.Modules.Packages.Spawn)

local DATASTORES = require(SSS.Modules.Data.DataStoreTemplate)
local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)

local instanceNew = Instance.new
local wait = task.wait

local NEW_WORLD = 17553728743

local function setup(plr: Player)
	local ds, ds2, ds3, ds4 =
		DSS:GetDataStore(DATASTORES[1]),
		DSS:GetDataStore(DATASTORES[2]),
		DSS:GetDataStore(DATASTORES[3]),
		DSS:GetDataStore(DATASTORES[4])

	local data1, data2, data3, data4 =
		ds:GetAsync(plr.UserId),
		ds2:GetAsync(plr.UserId),
		ds3:GetAsync(plr.UserId),
		ds4:GetAsync("Player_"..plr.UserId)

	local datas = { data1 or TEMPLATE, data2 or TEMPLATE, data3 or TEMPLATE, data4 }
	local realDatas = { TEMPLATE, TEMPLATE, TEMPLATE }
	--- v0.7 v1
	for i = 1, 3 do
		realDatas[i].Stats.Class = datas[i].Stats.Class or "Warrior"
		realDatas[i].Stats.DmgPoints = datas[i].Stats.DmgPoints or 0
		realDatas[i].Stats.EXP = datas[i].Stats.EXP or 0
		realDatas[i].Stats.Gold = datas[i].Stats.Gold or 0
		realDatas[i].Stats.HealthPoints = datas[i].Stats.HealthPoints or 0
		realDatas[i].Stats.Levels = datas[i].Stats.Levels or 1
		realDatas[i].Stats.LvPoints = datas[i].Stats.LvPoints or 0
		realDatas[i].Stats.MagicPoints = datas[i].Stats.MagicPoints or 0
		realDatas[i].Stats.ManaPoints = datas[i].Stats.ManaPoints or 0
		realDatas[i].Stats.PlayTime = datas[i].Stats.PlayTime or 0
		realDatas[i].Stats.RP = datas[i].Stats.RP or 0
		realDatas[i].Stats.ShieldPoints = datas[i].Stats.ShieldPoints or 0
	end
	--- v0.7 v2
	for i = 1, 3 do
		if not datas[i].StatsV2 then continue end

		realDatas[i].Stats.Class = datas[i].StatsV2.Class or "Warrior"
		realDatas[i].Stats.DmgPoints = datas[i].StatsV2.DMGPoints or 0
		realDatas[i].Stats.EXP = datas[i].StatsV2.EXP or 0
		realDatas[i].Stats.Gold = datas[i].StatsV2.Gold or 0
		realDatas[i].Stats.HealthPoints = datas[i].StatsV2.HealthPoints or 0
		realDatas[i].Stats.Levels = datas[i].StatsV2.Levels or 1
		realDatas[i].Stats.LvPoints = datas[i].StatsV2.LvPoints or 0
		realDatas[i].Stats.MagicPoints = datas[i].StatsV2.MagicPoints or 0
		realDatas[i].Stats.ManaPoints = datas[i].StatsV2.ManaPoints or 0
		realDatas[i].Stats.PlayTime = datas[i].StatsV2.PlayTime or 0
		realDatas[i].Stats.RP = datas[i].StatsV2.RP or 0
		realDatas[i].Stats.ShieldPoints = datas[i].StatsV2.ShieldPoints or 0
	end
	--- v0.6 old
	pcall(function()
		if datas[4] and datas[4].Data then
			realDatas[1].Stats.Gold += datas[4].Data.Gold
			realDatas[1].Stats.Levels += datas[4].Data.Level
			realDatas[1].Stats.PlayTime += datas[4].Data.PlayTime
		end
	end)

	--- v0.7 inventory
	for i = 1, 3 do
		if not datas[i].Inventory then continue end

		for item: string, amount: number in datas[i].Inventory do
			local info = {
				Amount = amount,
				Equipped = false,
				Pinned = false,
				Slot = "None"
			}
			realDatas[i].Inventory[item] = info
		end
	end
	--- v0.7 v2 inventory
	for i = 1, 3 do
		if not datas[i].InventoryV2 then continue end

		for item: string, info: table in datas[i].InventoryV2 do
			local newInfo = {
				Amount = info.Amount,
				Equipped = info.Equipped,
				Pinned = info.Pinned,
				Slot = info.Slot
			}
			realDatas[i].Inventory[item] = newInfo
		end
	end

	plr:SetAttribute("PlayerDataLoaded", true)

	wait(5)
	local teleportOptions = instanceNew("TeleportOptions")
	teleportOptions:SetTeleportData(realDatas)

	TeleS:TeleportAsync(NEW_WORLD, { plr }, teleportOptions)
end

---// Setups
for _, plr: Player in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
