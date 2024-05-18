--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)

local wait = task.wait
local format = string.format

local DATASTORES = require(SSS.Modules.Data.DataStoreTemplate)
local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)

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
	print("6")

	--// Done
	data.StatsV2.V2Transfered = true
	print("7")
end
local function setup(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.new(DATASTORES[1], plr.UserId),
		SuphiDataStore.new(DATASTORES[2], plr.UserId),
		SuphiDataStore.new(DATASTORES[3], plr.UserId)

	local function _stateChanged(_: boolean, datastore: any)
		while datastore.State == false do
			if datastore:Open(TEMPLATE) ~= "Success" then wait(1) end
		end
	end
	ds.StateChanged:Connect(_stateChanged)
	ds2.StateChanged:Connect(_stateChanged)
	ds3.StateChanged:Connect(_stateChanged)
	_stateChanged(ds.State, ds)
	_stateChanged(ds2.State, ds2)
	_stateChanged(ds3.State, ds3)

	if ds and ds2 and ds3 then
		local datas = { ds.Value, ds2.Value, ds3.Value }

		_oldDataTransfer(datas[1])
		_oldDataTransfer(datas[2])
		_oldDataTransfer(datas[3])

		for index: number, data: table in datas do
			for attr: string, val: any in data.StatsV2 do
				if attr == "LastLeave" then continue end

				plr:SetAttribute("DATA"..index..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..index.."StoryId", data.QuestsV2.Main)

			--// Done
			plr:SetAttribute("PlayerDataLoaded"..index, true)
		end

		--// Check if banned
		for i = 1, 3 do
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
	else
		plr:Kick("Rblx datastore may be down rn, try to rejoin later!")
	end
end

local function clear(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.find(DATASTORES[1], plr.UserId),
		SuphiDataStore.find(DATASTORES[2], plr.UserId),
		SuphiDataStore.find(DATASTORES[3], plr.UserId)

    if ds then ds:Destroy() end
	if ds2 then ds2:Destroy() end
	if ds3 then ds3:Destroy() end
end

---// Setups
for _, plr: Player in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)


local function wipeData(plr: Player, slot: string)
	local ds
	if slot == "Slot2" then
		ds = SuphiDataStore.find(DATASTORES[2], plr.UserId)
	elseif slot == "Slot3" then
		ds = SuphiDataStore.find(DATASTORES[3], plr.UserId)
	else
		ds = SuphiDataStore.find(DATASTORES[1], plr.UserId)
	end
	if not ds then
		Events.CreateHint:Fire(plr, "Error occurred when attempting to wipe data...")
		return
	end

	ds.Value = nil

	plr:Kick("You must rejoin after erasing data!")
end
Events.DataWipe:Connect(wipeData)
