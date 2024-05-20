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
	data.Stats.LvPoints = (data.Stats.Levels - 1) * 2
end

local function setup(plr: Player)
	local ds, ds2, ds3 =
		DSS:GetDataStore(DATASTORES[1]),
		DSS:GetDataStore(DATASTORES[2]),
		DSS:GetDataStore(DATASTORES[3])

	local data1, data2, data3 =
		ds:GetAsync(plr.UserId),
		ds2:GetAsync(plr.UserId),
		ds3:GetAsync(plr.UserId)

	local datas = { data1 or TEMPLATE, data2 or TEMPLATE, data3 or TEMPLATE }

	_reconcile(datas[1], TEMPLATE)
	_reconcile(datas[2], TEMPLATE)
	_reconcile(datas[3], TEMPLATE)

	_oldDataTransfer(datas[1])
	_oldDataTransfer(datas[2])
	_oldDataTransfer(datas[3])

	plr:SetAttribute("PlayerDataLoaded", true)

	wait(5)
	local teleportOptions = instanceNew("TeleportOptions")
	teleportOptions:SetTeleportData(datas)

	TeleS:TeleportAsync(NEW_WORLD, { plr }, teleportOptions)
end

---// Setups
for _, plr: Player in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
