--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Promise = require(RepS.Modules.Packages.Promise)
local ProfileService = require(RepS.Modules.Packages.ProfileService)
local Spawn = require(RepS.Modules.Packages.Spawn)

local profiles = {}

local TEMPLATE = require(SSS.Modules.Data.PlayerTemplate)

local profileStore = ProfileService.GetProfileStore("CS_1599MKK40_VCA_TEST", TEMPLATE)

local function setup(plr: Player)
	Promise.new(function(resolve, reject)
		local profile = profileStore:LoadProfileAsync("Player_"..plr.UserId)

		if profile then resolve(profile) else reject("Profile is nil") end

	end):andThen(function(profile)
		profile:Reconcile()
		profile:AddUserId(plr.UserId)

		profile:ListenToRelease(function()
			profiles[plr] = nil
			plr:Kick("Data was loaded on another roblox server, please try again later?")
		end)

		if not plr:IsDescendantOf(Players) then
			profile:Release()
			return
		end

		profiles[plr] = profile
		print("Loaded data for player: "..plr.UserId)

		--// check from
		local from = plr:GetJoinData().SourcePlaceId :: number
		if from == 7523159032 then
			print("Starting to transfering data..."..plr.UserId)

			local dataTransfered = plr:GetJoinData().TeleportData :: table

			--- decomplie data
			if dataTransfered.Slot1 then --- if it's nil then it's not a transfered data
				Promise.new(function()
					for i = 1, 3 do
						profile.Data["Slot"..i].Stats.PlayTime = dataTransfered["Slot"..i]

						print(`[{plr.UserId}]: {dataTransfered["Slot"..i]}`)
					end

				end):catch(function(msg)
					plr:Kick("A error occured when transfering data, please try again later?")

					warn(`[DATA TRANSFER]: {msg}`)
				end)
			end
		end

		for i = 1, 3 do
			for attr: string, val: any in profile.Data["Slot"..i].Stats do
				plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..i.."StoryId", profile.Data["Slot"..i].Quests.Main)
			plr:SetAttribute("PlayerDataLoaded"..i, true)
		end

	end):catch(function(msg)
		plr:Kick("Your data failed to load, please try again later?")

		warn(`[DATA LOAD]: {msg}`)
	end)
end
local function clear(plr: Player)
	local profile = profiles[plr]

	--- profile cleanups
	if profile then
		profiles[plr] = nil

		profile:Release()
	end

	--- clear world existence
	local playerChars = workspace.MapComponents.PlayerChars :: Folder
	if playerChars:FindFirstChild(plr.Name) then playerChars[plr.Name]:Destroy() end
end

for _, player: Player in Players:GetPlayers() do
	Spawn(setup, player)
end
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)


Events.DataWipe.SetCallback(function(plr, data)
	local slot = data.SlotChosen
	local profile = profiles[plr]

	-- wipe
	Promise.new(function()
		if not profile.Data[slot] then
			Events.CreateHint.Fire(plr, { Hint = "Error occured when resetting your data!" })
			return
		end

		Events.CreateFullScreenHint.Fire(plr, { Hint = "WIPING DATA, PLEASE WAIT...", State = true })

		task.wait(1.599)
		profile.Data[slot] = TEMPLATE.Slot1

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
			for attr: string, val: any in profile.Data["Slot"..i].Stats do
				plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
			end

			plr:SetAttribute("DATA"..i.."StoryId", profile.Data["Slot"..i].Quests.Main)
		end

		task.wait(1)
		Events.CreateFullScreenHint.Fire(plr, { Hint = "...", State = false })

	end):catch(function(msg)
		warn(`[DATA RELOAD]: {msg}`)

		plr:Kick("A error occured when reloading your data, please rejoin!")
	end)
end)
