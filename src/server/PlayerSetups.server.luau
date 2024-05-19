--!nocheck
--!optimize 2
--!native

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Promise = require(RepS.Modules.Packages.Promise)

local playerDatas = {}

local format, match = string.format, string.match
local tFind = table.find

local DATASTORES = require(SSS.Modules.Data.DataStoreTemplate)
local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)


local function _deepCopyTable(t: table) : table
	local copy = {}

	for k, v in pairs(t) do
		if type(v) == "table" then copy[k] = _deepCopyTable(v) else copy[k] = v end
	end

	return copy
end
local function _reconcile(data: table, template: table)
	for k, v in pairs(template) do
		if type(k) == "string" then --- only string keys will be reconciled
			if data[k] == nil then
				if type(v) == "table" then data[k] = _deepCopyTable(v) else data[k] = v end

			elseif type(data[k]) == "table" and type(v) == "table" then
				_reconcile(data[k], v)
			end
		end
	end
end
local function _oldDataTransfer(data: table)
	if not data.Stats then return end
	if data.StatsV2.V2Transfered then return end
	if data.Stats.PlayTime <= 0 then return end

	--// Stats
	data.StatsV2.Levels = data.Stats.Levels
	data.StatsV2.EXP = data.Stats.EXP
	data.StatsV2.Gold = data.Stats.Gold
	data.StatsV2.RP = data.Stats.RP
	data.StatsV2.PlayTime = data.Stats.PlayTime
	data.StatsV2.Class = data.Stats.Class
	data.StatsV2.LvPoints = (data.Stats.Levels - 1) * 2

	--// Inventory
	if data.Inventory then
		local inventoryV2 = {}
		for item, amount in data.Inventory do
			if amount <= 0 then continue end

			local info = {
				Amount = amount,
				Equipped = false,
				Pinned = false,
				Slot = "None"
			}
			inventoryV2[item] = info
		end
		data.InventoryV2 = inventoryV2
	end

	--// Done
	data.StatsV2.V2Transfered = true
end


local function setup(plr: Player)
	Promise.new(function(resolve)
		local ds, ds2, ds3 =
			DSS:GetDataStore(DATASTORES[1]),
			DSS:GetDataStore(DATASTORES[2]),
			DSS:GetDataStore(DATASTORES[3])

		local data1, data2, data3 =
			ds:GetAsync(plr.UserId),
			ds2:GetAsync(plr.UserId),
			ds3:GetAsync(plr.UserId)

		resolve(data1, data2, data3)

	end):andThen(function(data1: table, data2: table, data3: table)
		local datas = { data1 or TEMPLATE, data2 or TEMPLATE, data3 or TEMPLATE }

		_reconcile(datas[1], TEMPLATE)
		_reconcile(datas[2], TEMPLATE)
		_reconcile(datas[3], TEMPLATE)

		_oldDataTransfer(datas[1])
		_oldDataTransfer(datas[2])
		_oldDataTransfer(datas[3])

		playerDatas[plr.Name] = datas

		local blacklist = { "LastLeave", "V1Transfered",  }
		for index: number, data: table in datas do
			for attr: string, val: any in data.StatsV2 do
				if tFind(blacklist, attr) then continue end

				plr:SetAttribute("DATA"..index..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..index.."StoryId", data.QuestsV2.Main)

			--// Done
			plr:SetAttribute("PlayerDataLoaded"..index, true)
		end

		--// Check if banned
		for i = 1, 3 do
			if not datas[i] then return end

			local banInfo = datas[i].BanStats :: table
			if banInfo.IsBanned then
				local timeGap = (time() - banInfo.BannedTime) / 60 / 60

				if timeGap < banInfo.Duration then
					local durationLeft = format("%.1f", tostring(banInfo.Duration - timeGap))

					plr:Kick("You got banned! Reason: "..banInfo.Reason..", unban in "..durationLeft.." hours!")
				else
					--// unban
					datas[i].BanStats = TEMPLATE.BanStats
				end
			end
		end
	end)
end
local function clear(plr: Player)
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

	plr:Kick("You must rejoin after erasing data!")
end
Events.DataWipe:Connect(wipeData)
