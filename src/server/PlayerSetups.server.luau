--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local DataKeep = require(RepS.Modules.Packages.DataKeep)
local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local Spawn = require(RepS.Modules.Packages.Spawn)

local profiles = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)

local dataKeepStore = DataKeep.GetStore("CS_1599MKK40_VCA_TEST", TEMPLATE)

local function setup(plr: Player)
	dataKeepStore:LoadKeep("Player_"..plr.UserId, function()
		plr:Kick("Data is locked, maybe try again later?")

		return dataKeepStore.LoadMethods.Cancel

	end):andThen(function(keep)
		if keep == nil then
			plr:Kick("Data is locked, maybe try again later?")
		end

		keep:Reconcile()
		keep:AddUserId(plr.UserId)

		if not plr:IsDescendantOf(Players) then
			keep:Release()
			return
		end

		profiles[plr] = keep
		print("Loaded data for player: "..plr.UserId)

		--// check from
		local from = plr:GetJoinData().SourcePlaceId :: number
		if from == 7523159032 then
			print("Starting to transfering data..."..plr.UserId)

			local dataTransfered = plr:GetJoinData().TeleportData :: table

			--- decomplie data
			Promise.new(function()
				for i = 1, 3 do
					keep.Data["Slot"..i].Stats.PlayTime = dataTransfered["Slot"..i] or 0
				end

				keep:Save():await()

			end):catch(function(msg)
				plr:Kick("A error occured when transfering data, please try again later?")

				warn(`[DATA TRANSFER]: {msg}`)
			end)
		end

		for i = 1, 3 do
			for attr: string, val: any in keep.Data["Slot"..i].Stats do
				plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..i.."StoryId", keep.Data["Slot"..i].Quests.Main)
			plr:SetAttribute("PlayerDataLoaded"..i, true)
		end

	end):catch(function(msg)
		plr:Kick("Your data failed to load, please try again later?")

		warn(`[DATA LOAD]: {msg}`)
	end)
end

dataKeepStore:andThen(function(store)
	dataKeepStore = store

	for _, player: Player in Players:GetPlayers() do
		Spawn(setup, player)
	end
	Players.PlayerAdded:Connect(setup)
end)

local function clear(plr: Player)
	local keep = profiles[plr]

	--- profile cleanups
	if keep then
		profiles[plr] = nil

		keep:Save():await()
		keep:Release()
	end

	--- clear world existence
	local playerChars = workspace.MapComponents.PlayerChars :: Folder
	if playerChars:FindFirstChild(plr.Name) then playerChars[plr.Name]:Destroy() end
end
Players.PlayerRemoving:Connect(clear)


Events.DataWipe.SetCallback(function(plr, data)
	local slot = data.SlotChosen
	local keep = profiles[plr]

	-- wipe
	Promise.new(function()
		if not keep.Data[slot] then
			Events.CreateHint.Fire(plr, { Hint = "Error occured when resetting your data!" })
			return
		end

		Events.CreateFullScreenHint.Fire(plr, { Hint = "WIPING DATA, PLEASE WAIT...", State = true })

		task.wait(1.599)
		keep.Data[slot] = TEMPLATE.Slot1
		keep:Save():await()

	end):catch(function(msg)
		warn(`[DATA WIPE]: {msg}`)

		Events.CreateHint.Fire(plr, { Hint = "Error occured when resetting your data!" })
		Events.CreateFullScreenHint.Fire(plr, { Hint = "...", State = false })
	end)

	-- reload
	Promise.new(function()
		task.wait(4)
		Events.CreateFullScreenHint.Fire(plr, { Hint = "DATA WIPED!", State = true })

		task.wait(1)
		for i = 1, 3 do
			for attr: string, val: any in keep.Data["Slot"..i].Stats do
				plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..i.."StoryId", keep.Data["Slot"..i].Quests.Main)
		end

		task.wait(1)
		Events.CreateFullScreenHint.Fire(plr, { Hint = "...", State = false })

	end):catch(function(msg)
		warn(`[DATA RELOAD]: {msg}`)

		plr:Kick("A error occured when reloading your data, please rejoin!")
	end)
end)
