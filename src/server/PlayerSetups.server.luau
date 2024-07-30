--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local DataKeep = require(ReplicatedStorage.Modules.Packages.DataKeep)
local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local profiles = {}

local TEMPLATE = require(ServerScriptService.Modules.Data.PlayerTemplate)

local dataKeepStore = DataKeep.GetStore("CS_1599MKK40_OLD", TEMPLATE)

local function setup(plr: Player)
	dataKeepStore:LoadKeep("Player_"..plr.UserId):andThen(function(keep)
		if keep == nil then
			plr:Kick("Data loaded failed! This is a rare error, please try again later.")
		end

		keep:Reconcile()
		keep:AddUserId(plr.UserId)

		keep.Releasing:Connect(function(state)
			state:andThen(function()
				plr:Kick("Your session has been released, maybe rejoin later?")
			end)
		end)

		if not plr:IsDescendantOf(Players) then
			keep:Release()
			return
		end

		--// Check if not transfered
		local transfered = true
		for i = 1, 3 do
			if keep.Data["Slot"..i].DataTransferedV1 == false then transfered = false break end
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
					keep.Data["Slot"..i].Inventory = dataTransfered["Slot"..i].Inventory or {}

					for attr: string, val: any in keep.Data["Slot"..i].Stats do
						keep.Data["Slot"..i].Stats[attr] = dataTransfered["Slot"..i].Stats[attr] or val
					end

					keep.Data["Slot"..i].DataTransferedV1 = true
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
		profiles[plr] = keep

		for i = 1, 3 do
			for attr: string, val: any in keep.Data[`Slot{i}`].Stats do
				plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..i.."StoryId", keep.Data[`Slot{i}`].Quests.Main)

			--// Done
			plr:SetAttribute("PlayerDataLoaded"..i, true)
		end

	end):catch(function()
		plr:Kick("Data loaded failed! This is an internal error, please try rejoin again.")
	end)
end
local function clear(plr: Player)
	--- world existence
	local playerChars = workspace.MapComponents.PlayerChars :: Folder
	if playerChars:FindFirstChild(plr.Name) then playerChars[plr.Name]:Destroy() end

	--- profile cleanups
	if profiles[plr] then profiles[plr]:Release() end

	profiles[plr] = nil
end
Players.PlayerRemoving:Connect(clear)

--- in case player joined before server starts
dataKeepStore:andThen(function(store)
	dataKeepStore = store

	for _, player: Player in Players:GetPlayers() do
		Spawn(setup, player)
	end

	Players.PlayerAdded:Connect(setup)
end)


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

	profile.Data[slot] = TEMPLATE["Slot1"]

	plr:Kick("Data has wiped, rejoin to continue!")
end)
