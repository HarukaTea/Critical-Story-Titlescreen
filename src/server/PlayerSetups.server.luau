--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Events = require(SSS.Modules.Data.ServerEvents)
local Spawn = require(RepS.Modules.Packages.Spawn)
local SuphiDataStore = require(RepS.Modules.Packages.SuphiDataStore)

local wait = task.wait

local TEMPLATE = {
	Stats = {
		Levels = 1,
		PlayTime = 0,

		Class = "Warrior",
		LastSeenLocation = "InitusVillage",
	},
	Quests = {
		Main = 1,
		Town = {}
	}
}
local DS1, DS2, DS3 = "CS_DEV1599", "CS_DEV1599_S2", "CS_DEV1599_S3"


local function findDataStore(plr: Player, slot: string) : DataStore?
	local ds
	if slot == "Slot2" then
		ds = SuphiDataStore.find(DS2, plr.UserId)
	elseif slot == "Slot3" then
		ds = SuphiDataStore.find(DS3, plr.UserId)
	else
		ds = SuphiDataStore.find(DS1, plr.UserId)
	end

	return ds
end

local function setup(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.new(DS1, plr.UserId),
		SuphiDataStore.new(DS2, plr.UserId),
		SuphiDataStore.new(DS3, plr.UserId)

	local function _stateChanged(state: boolean, datastore: any)
		while datastore.State == false do
			if datastore:Open(TEMPLATE) ~= "Success" then wait(6) end
		end
	end
	ds.StateChanged:Connect(_stateChanged)
	ds2.StateChanged:Connect(_stateChanged)
	ds3.StateChanged:Connect(_stateChanged)
	_stateChanged(ds.State, ds)
	_stateChanged(ds2.State, ds2)
	_stateChanged(ds3.State, ds3)

	if ds and ds2 and ds3 then
		local data1, data2, data3 = ds.Value :: table, ds2.Value :: table, ds3.Value :: table

		for i = 1,3 do
			local folder = SS.PlayerData:Clone()
			folder.Name = "PlayerData"..i
			folder.Parent = plr
		end
		for i, v in TEMPLATE.Stats do
			plr.PlayerData1[i].Value = data1.Stats[i]
			plr.PlayerData2[i].Value = data2.Stats[i]
			plr.PlayerData3[i].Value = data3.Stats[i]
		end

		plr.PlayerData1.StoryId.Value = data1.Quests.Main
		plr.PlayerData2.StoryId.Value = data2.Quests.Main
		plr.PlayerData3.StoryId.Value = data3.Quests.Main
	else
		plr:Kick("Rblx datastore may be down rn, try to rejoin later!")
	end

	plr:SetAttribute("PlayerDataLoaded", true)
end

local function clear(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.find(DS1, plr.UserId),
		SuphiDataStore.find(DS2, plr.UserId),
		SuphiDataStore.find(DS3, plr.UserId)

    if ds then ds:Destroy() end
	if ds2 then ds2:Destroy() end
	if ds3 then ds3:Destroy() end
end

---// Setups
for _, plr in Players:GetPlayers() do
	Spawn(setup, plr)
end

--// Connections
local function _playerAdded(plr: Player)
	if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
		setup(plr)
	else
		warn(plr.Name.." joined the left instantly.")
	end
end
local function _playerLeft(plr: Player)
	clear(plr)
end
Players.PlayerAdded:Connect(_playerAdded)
Players.PlayerRemoving:Connect(_playerLeft)

local function wipeData(plr: Player, slot: string)
	local ds = findDataStore(plr, slot)

	if not ds then return end

	ds.Value = {}

	plr:Kick("You must rejoin after erasing data!")
end
Events.DataWipe:Connect(wipeData)
