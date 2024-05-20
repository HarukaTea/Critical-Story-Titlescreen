--!nocheck

local DSS = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)

local playerDatas = {}

local format, match = string.format, string.match
local tFind = table.find
local time = os.time

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

local function setup(plr: Player)
	local joinData = plr:GetJoinData().TeleportData :: table?

	local ds, ds2, ds3 =
		DSS:GetDataStore(DATASTORES[1]),
		DSS:GetDataStore(DATASTORES[2]),
		DSS:GetDataStore(DATASTORES[3])

	local data1, data2, data3 =
		ds:GetAsync(plr.UserId),
		ds2:GetAsync(plr.UserId),
		ds3:GetAsync(plr.UserId)

	local datas = { data1 or TEMPLATE, data2 or TEMPLATE, data3 or TEMPLATE }

	if joinData then
		if plr:GetJoinData().SourcePlaceId == 7523159032 then
			for i = 1, 3 do
				pcall(function()
					if not datas[i].Stats.V8Transfered then
						datas[i] = joinData[i]
						datas[i].Stats.V8Transfered = true
					end
				end)
			end
		end
	end

	_reconcile(datas[1], TEMPLATE)
	_reconcile(datas[2], TEMPLATE)
	_reconcile(datas[3], TEMPLATE)

	playerDatas[plr.Name] = datas

	local blacklist = { "LastLeave", "LastLocation", "V1Transfered", "V2Transfered", "V8Transfered", "V8Transfered2" }
	for index: number, data: table in datas do
		for attr: string, val: any in data.Stats do
			if tFind(blacklist, attr) then continue end

			plr:SetAttribute("DATA"..index..""..attr, HarukaLib:Deserialize(val))
		end

		plr:SetAttribute("DATA"..index.."StoryId", data.Quests.Main)

		--// Done
		plr:SetAttribute("PlayerDataLoaded"..index, true)
	end

	--// Check if banned
	Spawn(function()
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
	end)

	--// Check if transfered
	Spawn(function()
		local check = true
		for i = 1, 3 do
			if not datas[i].Stats.V8Transfered then check = false end
		end

		if not check then
			Events.CreateHint:Fire(plr, "Teleporting to legacy place...")

			TeleS:Teleport(7523159032, plr)
		end
	end)

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
	playerDatas[plr.Name][realSlot].Stats.V8Transfered = true

	plr:Kick("Data has wiped, rejoin to continue!")
end
Events.DataWipe:Connect(wipeData)
