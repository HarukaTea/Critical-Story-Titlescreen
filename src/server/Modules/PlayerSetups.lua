--!nocheck

local Players = game:GetService("Players")
local SS = game:GetService("ServerStorage")

local HarukaFrameworkServer = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer)

local FastSpawn = HarukaFrameworkServer.FastSpawn
local SuphiDataStore = HarukaFrameworkServer.SuphiDataStore

local wait = task.wait

local PlayerSetups = {}
PlayerSetups.__index = PlayerSetups

--[[
	Finds the datastore with the given `player` object
]]
function PlayerSetups:FindDataStore(plr: Player, slot: string) : DataStore?
	local ds
	if slot == "Slot2" then
		ds = SuphiDataStore.find(self.DS2, plr.UserId)
	elseif slot == "Slot3" then
		ds = SuphiDataStore.find(self.DS3, plr.UserId)
	else
		ds = SuphiDataStore.find(self.DS1, plr.UserId)
	end

	return ds
end

--[[
	Load the data from DataStore and apply attributes to player
]]
function PlayerSetups:Setup(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.new(self.DS1, plr.UserId),
		SuphiDataStore.new(self.DS2, plr.UserId),
		SuphiDataStore.new(self.DS3, plr.UserId)

	local function stateChanged(state: boolean, datastore: any)
		while datastore.State == false do
			if datastore:Open(self.TEMPLATE) ~= "Success" then wait(6) end
		end
	end
	ds.StateChanged:Connect(stateChanged)
	ds2.StateChanged:Connect(stateChanged)
	ds3.StateChanged:Connect(stateChanged)
	stateChanged(ds.State, ds)
	stateChanged(ds2.State, ds2)
	stateChanged(ds3.State, ds3)

	local function oldClassTransform(datastore)
		local data = datastore.Value.Stats
		if not data.CombatStyle then return end

		if data.CombatStyle == "Combo" then data.Class = "Warrior" end
		if data.CombatStyle == "Stack" then data.Class = "Archer" end
		if data.CombatStyle == "Staff" then data.Class = "Wizard" end
		if data.CombatStyle == "Guard" then data.Class = "Knight" end
		if data.CombatStyle == "Knife" then data.Class = "Rogue" end
		if data.CombatStyle == "Creation" then data.Class = "Alchemist" end
		if data.CombatStyle == "Repeater" then data.Class = "Repeater" end
		if data.CombatStyle == "Striker" then data.Class = "Striker" end
	end

	if ds and ds2 and ds3 then
		oldClassTransform(ds)
		oldClassTransform(ds2)
		oldClassTransform(ds3)

		local data1, data2, data3 = ds.Value, ds2.Value, ds3.Value

		for i = 1,3 do
			local folder = SS.PlayerData:Clone()
			folder.Name = "PlayerData"..i
			folder.Parent = plr
		end
		for i,v in self.TEMPLATE.Stats do
			plr.PlayerData1[i].Value = data1.Stats[i]
			plr.PlayerData2[i].Value = data2.Stats[i]
			plr.PlayerData3[i].Value = data3.Stats[i]
		end
	else
		plr:Kick("Rblx datastore may be down rn, try to rejoin later!")
	end

	plr:SetAttribute("PlayerDataLoaded", true)
end

--[[
	Actions when player left, save the data, and clear the existence of world
]]
function PlayerSetups:Clear(plr: Player)
	local ds, ds2, ds3 =
		SuphiDataStore.find(self.DS1, plr.UserId),
		SuphiDataStore.find(self.DS2, plr.UserId),
		SuphiDataStore.find(self.DS3, plr.UserId)

    if ds then ds:Destroy() end
	if ds2 then ds2:Destroy() end
	if ds3 then ds3:Destroy() end
end

--[[
	Wipe player data, cuz they already made choices
]]
function PlayerSetups:WipeData(plr: Player, slot: string)
	local ds = self:FindDataStore(plr, slot)

	if not ds then return end
	local data = ds.Value

	data.Stats = {}
	data.Inventory = {}
	data.EquippedItems = {}
	data.PinnedItems = {}

	plr:Kick("You must rejoin after erasing data!")
end

return function ()
    local self = setmetatable({}, PlayerSetups)

    self.TEMPLATE = {
		Stats = {
			Levels = 1,
			PlayTime = 0,
			StoryId = 0,
			Class = "Warrior",
			LastSeen = "MainWorld",
			Cosmetic = "None",
			Companion = "None",
		},
		Inventory = {},
		EquippedItems = {},
		PinnedItems = {}
	}
	self.DS1, self.DS2, self.DS3 = "CSTORY_DEV20", "CSTORY_DEV20_S2", "CSTORY_DEV20_S3"

	--// Connections
	local function _playerAdded(plr: Player)
		if plr:IsDescendantOf(Players) then --- in case player joins and left very quickly
			self:Setup(plr)
		else
			warn(plr.Name.." joined the left instantly.")
		end
	end
	local function _playerLeft(plr: Player)
		self:Clear(plr)
	end
	Players.PlayerAdded:Connect(_playerAdded)
	Players.PlayerRemoving:Connect(_playerLeft)

	--- in case player joined before server starts
	for _, plr in Players:GetPlayers() do
		FastSpawn(function()
			self:Setup(plr)
		end)
	end
end