--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local ProfileService = require(ReplicatedStorage.Modules.Packages.ProfileService)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local profiles = {}

local TEMPLATE = require(ServerScriptService.Modules.Data.PlayerTemplate)

local profileStore = ProfileService.GetProfileStore("CS_1599MKK40_OLD2", TEMPLATE)

local function setup(plr: Player)
	local profile = profileStore:LoadProfileAsync("Player_"..plr.UserId)

	if profile == nil then
		plr:Kick("Data loaded failed! This is a rare error, please try again later.")
		return
	end

	profile:Reconcile()
	profile:AddUserId(plr.UserId)
	profile:ListenToRelease(function()
		profiles[plr] = nil
		plr:Kick("Your session has been released, maybe rejoin later?")
	end)

	if not plr:IsDescendantOf(Players) then
		profile:Release()
		return
	end

	--// Check if not transfered
	local transfered = true
	for i = 1, 3 do
		if profile.Data["Slot"..i].DataTransferedV3 == false then transfered = false break end
	end

	--// check from
	local from = plr:GetJoinData().SourcePlaceId :: number
	if from == 7523159032 and not transfered then
		print("Starting to transfering data...")

		transfered = true
		local dataTransfered = plr:GetJoinData().TeleportData :: table

		--- decomplie data
		Promise.new(function()
			for i = 1, 3 do
				profile.Data["Slot"..i].Inventory = dataTransfered["Slot"..i].Inventory or {}

				for attr: string, val: any in profile.Data["Slot"..i].Stats do
					profile.Data["Slot"..i].Stats[attr] = dataTransfered["Slot"..i].Stats[attr] or val
				end

				profile.Data["Slot"..i].DataTransferedV3 = true
			end

		end):Catch(function()
			plr:Kick("A error occured when transfering data, please try again later?")
		end)
	end

	--// Check if not transfered
	if not transfered then
		TeleportService:Teleport(7523159032, plr)
		return
	end

	--- load profile
	profiles[plr] = profile

	for i = 1, 3 do
		for attr: string, val: any in profile.Data[`Slot{i}`].Stats do
			plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
		end

		plr:SetAttribute("DATA"..i.."StoryId", profile.Data[`Slot{i}`].Quests.Main)

		--// Done
		plr:SetAttribute("PlayerDataLoaded"..i, true)
	end
end

for _, player: Player in Players:GetPlayers() do
	Spawn(setup, player)
end
Players.PlayerAdded:Connect(setup)


local function clear(plr: Player)
	--- world existence
	local playerChars = workspace.MapComponents.PlayerChars :: Folder
	if playerChars:FindFirstChild(plr.Name) then playerChars[plr.Name]:Destroy() end

	--- profile cleanups
	if profiles[plr] then
		profiles[plr]:Save()
		profiles[plr]:Release()
	end
end
Players.PlayerRemoving:Connect(clear)


Events.DataWipe.SetCallback(function(plr, data)
	local slot = data.SlotChosen

	local profile = profiles[plr]
	if not profile then
		Events.CreateHint.Fire(plr, { Hint = "Error occured when resetting your data!" })
		return
	end

	local whiteList = { "Slot1", "Slot2", "Slot3" } --// avoid bypass
	if not table.find(whiteList, slot) then
		Events.CreateHint.Fire(plr, { Hint = "Error occured when resetting your data!" })
		return
	end

	local oriTemplate = TEMPLATE
	oriTemplate.Slot1.DataTransferedV3 = true

	profile.Data[slot] = oriTemplate.Slot1

	plr:Kick("Data has wiped, rejoin to continue!")
end)
