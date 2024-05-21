--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local playerDatas = {}

local match = string.match
local tFind = table.find
local max = math.max

local DATASTORES = require(SSS.Modules.Data.DataStoreTemplate)
local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)

local function setup(plr: Player)
	local ds, ds2, ds3, ds4 =
		DSS:GetDataStore(DATASTORES[1]),
		DSS:GetDataStore(DATASTORES[2]),
		DSS:GetDataStore(DATASTORES[3]),
		DSS:GetDataStore(DATASTORES[4])

	local data1, data2, data3, data4 =
		ds:GetAsync(plr.UserId) or TEMPLATE,
		ds2:GetAsync(plr.UserId) or TEMPLATE,
		ds3:GetAsync(plr.UserId) or TEMPLATE,
		ds4:GetAsync("Player_"..plr.UserId)

	---// save1
	local ok, errorMsg = pcall(function()
		if not data1.Stats.V9Transfered then
			local info = { Stats = {}, Inventory = {}, QuestsV2 = { Main = 1, Town = {} } }

			--// v0.7 v1
			if data1.Stats then
				info.Stats.Class = data1.Stats.Class or "Warrior"
				info.Stats.EXP = data1.Stats.EXP or 0
				info.Stats.Gold = data1.Stats.Gold or 0
				info.Stats.Levels = data1.Stats.Levels or 1
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = data1.Stats.PlayTime or 0
				info.Stats.RP = data1.Stats.RP or 0
			end

			--// v0.7 v2
			if data1.StatsV2 then
				info.Stats.Class = data1.StatsV2.Class or "Warrior"
				info.Stats.EXP = data1.StatsV2.EXP or 0
				info.Stats.Gold = max(data1.StatsV2.Gold or 0, info.Stats.Gold or 0)
				info.Stats.Levels = max(data1.StatsV2.Levels or 1, info.Stats.Levels or 0)
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = max(data1.StatsV2.PlayTime or 0, info.Stats.PlayTime or 0)
				info.Stats.RP = data1.StatsV2.RP or 0
			end

			--// v0.6
			if data4 and data4.Data then
				info.Stats.Gold += data4.Data.Gold or 0
				info.Stats.Levels += (data4.Data.Level - 1) or 0
				info.Stats.PlayTime += data4.Data.PlayTime or 0
			end

			--// v0.7 inventory v1
			if data1.Inventory then
				for item: string, amount: number in data1.Inventory do
					local itemInfo = {
						Amount = amount or 0,
						Equipped = false,
						Pinned = false,
						Slot = "None"
					}

					info.Inventory[item] = itemInfo
				end
			end

			--// v0.7 inventory v2
			if data1.InventoryV2 then
				for item: string, itemInfo: table in data1.InventoryV2 do
					local newInfo = {
						Amount = itemInfo.Amount or 0,
						Equipped = itemInfo.Equipped or false,
						Pinned = itemInfo.Pinned or false,
						Slot = itemInfo.Slot or "None"
					}

					info.Inventory[item] = newInfo
				end
			end

			info.Stats.LastSeenLocation = "MonolithVillage"
			info.Stats.V9Transfered = true
			data1 = info
		end
	end)
	if not ok then warn("S1: "..errorMsg) end

	---// save2
	ok, errorMsg = pcall(function()
		if not data2.Stats.V9Transfered then
			local info = { Stats = {}, Inventory = {}, QuestsV2 = { Main = 1, Town = {} } }

			--// v0.7 v1
			if data2.Stats then
				info.Stats.Class = data2.Stats.Class or "Warrior"
				info.Stats.EXP = data2.Stats.EXP or 0
				info.Stats.Gold = data2.Stats.Gold or 0
				info.Stats.Levels = data2.Stats.Levels or 1
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = data2.Stats.PlayTime or 0
				info.Stats.RP = data2.Stats.RP or 0
			end

			--// v0.7 v2
			if data2.StatsV2 then
				info.Stats.Class = data2.StatsV2.Class or "Warrior"
				info.Stats.EXP = data2.StatsV2.EXP or 0
				info.Stats.Gold = max(data2.StatsV2.Gold or 0, info.Stats.Gold or 0)
				info.Stats.Levels = max(data2.StatsV2.Levels or 1, info.Stats.Levels or 0)
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = max(data2.StatsV2.PlayTime or 0, info.Stats.PlayTime or 0)
				info.Stats.RP = data2.StatsV2.RP or 0
			end

			--// v0.7 inventory v1
			if data2.Inventory then
				for item: string, amount: number in data2.Inventory do
					local itemInfo = {
						Amount = amount or 0,
						Equipped = false,
						Pinned = false,
						Slot = "None"
					}

					info.Inventory[item] = itemInfo
				end
			end

			--// v0.7 inventory v2
			if data2.InventoryV2 then
				for item: string, itemInfo: table in data2.InventoryV2 do
					local newInfo = {
						Amount = itemInfo.Amount or 0,
						Equipped = itemInfo.Equipped or false,
						Pinned = itemInfo.Pinned or false,
						Slot = itemInfo.Slot or "None"
					}

					info.Inventory[item] = newInfo
				end
			end

			info.Stats.LastSeenLocation = "MonolithVillage"
			info.Stats.V9Transfered = true
			data2 = info
		end
	end)
	if not ok then warn("S2: "..errorMsg) end

	---// save3
	ok, errorMsg = pcall(function()
		if not data3.Stats.V9Transfered then
			local info = { Stats = {}, Inventory = {}, QuestsV2 = { Main = 1, Town = {} } }

			--// v0.7 v1
			if data3.Stats then
				info.Stats.Class = data3.Stats.Class or "Warrior"
				info.Stats.EXP = data3.Stats.EXP or 0
				info.Stats.Gold = data3.Stats.Gold or 0
				info.Stats.Levels = data3.Stats.Levels or 1
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = data3.Stats.PlayTime or 0
				info.Stats.RP = data3.Stats.RP or 0
			end

			--// v0.7 v2
			if data3.StatsV2 then
				info.Stats.Class = data3.StatsV2.Class or "Warrior"
				info.Stats.EXP = data3.StatsV2.EXP or 0
				info.Stats.Gold = max(data3.StatsV2.Gold or 0, info.Stats.Gold or 0)
				info.Stats.Levels = max(data3.StatsV2.Levels or 1, info.Stats.Levels or 0)
				info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
				info.Stats.PlayTime = max(data3.StatsV2.PlayTime or 0, info.Stats.PlayTime or 0)
				info.Stats.RP = data3.StatsV2.RP or 0
			end

			--// v0.7 inventory v1
			if data3.Inventory then
				for item: string, amount: number in data3.Inventory do
					local itemInfo = {
						Amount = amount or 0,
						Equipped = false,
						Pinned = false,
						Slot = "None"
					}

					info.Inventory[item] = itemInfo
				end
			end

			--// v0.7 inventory v2
			if data3.InventoryV2 then
				for item: string, itemInfo: table in data3.InventoryV2 do
					local newInfo = {
						Amount = itemInfo.Amount or 0,
						Equipped = itemInfo.Equipped or false,
						Pinned = itemInfo.Pinned or false,
						Slot = itemInfo.Slot or "None"
					}

					info.Inventory[item] = newInfo
				end
			end

			info.Stats.LastSeenLocation = "MonolithVillage"
			info.Stats.V9Transfered = true
			data3 = info
		end
	end)
	if not ok then warn("S3: "..errorMsg) end

	--// Transfer done
	playerDatas[plr.Name] = { data1, data2, data3 }

	local blacklist = { "V9Transfered" }
	for index: number, data: table in playerDatas[plr.Name] do
		for attr: string, val: any in data.Stats do
			if tFind(blacklist, attr) then continue end

			pcall(function()
				plr:SetAttribute("DATA"..index..""..attr, HarukaLib:Deserialize(val))
			end)
		end

		plr:SetAttribute("DATA"..index.."StoryId", data.QuestsV2.Main)

		--// Done
		plr:SetAttribute("PlayerDataLoaded"..index, true)
	end
end
local function clear(plr: Player)
	if not playerDatas[plr.Name] then return end

	local datas = playerDatas[plr.Name] :: table

	pcall(function()
		DSS:GetDataStore(DATASTORES[1]):SetAsync(plr.UserId, datas[1])
	end)
	pcall(function()
		DSS:GetDataStore(DATASTORES[2]):SetAsync(plr.UserId, datas[2])
	end)
	pcall(function()
		DSS:GetDataStore(DATASTORES[3]):SetAsync(plr.UserId, datas[3])
	end)

	playerDatas[plr.Name] = nil

	if workspace.MapComponents.PlayerChars:FindFirstChild(plr.Name) then
		workspace.MapComponents.PlayerChars[plr.Name]:Destroy()
	end
end

---// Setups
for _, plr: Player in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)


local function wipeData(plr: Player, slot: string)
	local realSlot = tonumber(match(slot, "%d"))

	if not realSlot then
		Events.CreateHint:Fire(plr, "Error occured when wiping data!")
		return
	end

	playerDatas[plr.Name][realSlot] = TEMPLATE
	playerDatas[plr.Name][realSlot].Stats.V9Transfered = true

	plr:Kick("Data has wiped, rejoin to continue!")
end
Events.DataWipe:Connect(wipeData)
