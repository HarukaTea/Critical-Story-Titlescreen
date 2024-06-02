--!nocheck

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local ProfileService = require(ServerScriptService.Modules.Packages.ProfileService)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local profiles = {}

local TEMPLATE = require(ServerScriptService.Modules.Data.PlayerTemplate)

local function setup(plr: Player)
	local ds, ds2, ds3, ds4 =
		DataStoreService:GetDataStore("CS_DEV1599"),
		DataStoreService:GetDataStore("CS_DEV1599_S2"),
		DataStoreService:GetDataStore("CS_DEV1599_S3"),
		DataStoreService:GetDataStore("CS-DEV13")

	local newDS = ProfileService.GetProfileStore("CS_1599MKK", TEMPLATE)
	local profile = newDS:LoadProfileAsync("Player_"..plr.UserId)

	if not profile then plr:Kick("Data has already loaded on another server!") return end

	profile:AddUserId(plr.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		profiles[plr] = nil

		plr:Kick("Data has already loaded on another server!")
	end)

	if plr:IsDescendantOf(Players) then
		profiles[plr] = profile

		for i = 1, 3 do
			Promise.new(function(resolve)
				if profile.Data["Slot"..i].Stats.V9Transfered then resolve(profile.Data["Slot"..i]) return end

				local info = { Stats = {}, Inventory = {}, QuestsV3 = { Main = 1, Side = {}, Town = {} } }

				local data: table
				if i == 1 then data = ds:GetAsync(plr.UserId) or TEMPLATE["Slot1"] end
				if i == 2 then data = ds2:GetAsync(plr.UserId) or TEMPLATE["Slot1"] end
				if i == 3 then data = ds3:GetAsync(plr.UserId) or TEMPLATE["Slot1"] end

				--// v0.7 v1
				if data.Stats then
					info.Stats.Class = data.Stats.Class or "Warrior"
					info.Stats.EXP = data.Stats.EXP or 0
					info.Stats.Gold = data.Stats.Gold or 0
					info.Stats.Levels = data.Stats.Levels or 1
					info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
					info.Stats.PlayTime = data.Stats.PlayTime or 0
					info.Stats.RP = data.Stats.RP or 0
				end

				--// v0.7 v2
				if data.StatsV2 then
					info.Stats.Class = data.StatsV2.Class or "Warrior"
					info.Stats.EXP = data.StatsV2.EXP or 0
					info.Stats.Gold = math.max(data.StatsV2.Gold or 0, info.Stats.Gold or 0)
					info.Stats.Levels = math.max(data.StatsV2.Levels or 1, info.Stats.Levels or 0)
					info.Stats.LvPoints = (info.Stats.Levels - 1) * 2 or 0
					info.Stats.PlayTime = math.max(data.StatsV2.PlayTime or 0, info.Stats.PlayTime or 0)
					info.Stats.RP = data.StatsV2.RP or 0
				end

				--// v0.6
				if i == 1 then
					local data4 = ds4:GetAsync("Player_"..plr.UserId)

					if data4 and data4.Data then
						info.Stats.Gold += data4.Data.Gold or 0
						info.Stats.Levels += (data4.Data.Level - 1) or 0
						info.Stats.PlayTime += data4.Data.PlayTime or 0
					end
				end

				--// v0.7 inventory v1
				if data.Inventory then
					for item: string, amount: number in data.Inventory do
						local itemInfo = {
							Amount = amount or 0,
							Equipped = false,
							Pinned = false,
							Slot = "None"
						}

						info.Inventory[item] = itemInfo

						--- testers history issues...
						if type(amount) == "table" then
							itemInfo = {
								Amount = amount.Amount or 0,
								Equipped = false,
								Pinned = false,
								Slot = "None"
							}

							info.Inventory[item] = itemInfo
						end
					end
				end

				--// v0.7 inventory v2
				if data.InventoryV2 then
					for item: string, itemInfo: table in data.InventoryV2 do
						local newInfo = {
							Amount = itemInfo.Amount or 0,
							Equipped = itemInfo.Equipped or false,
							Pinned = itemInfo.Pinned or false,
							Slot = itemInfo.Slot or "None"
						}

						info.Inventory[item] = newInfo
					end
				end

				info.Stats.LastSeenLocation = "MonolithVillage"
				info.Stats.LastSeenWorld = "Mainworld"
				info.Stats.Cosmetic = "None"
				info.Stats.V9Transfered = true

				profile.Data["Slot"..i] = info

				resolve(info)

			end):Then(function(info: table)
				for attr: string, val: any in info.Stats do
					plr:SetAttribute("DATA"..i..""..attr, HarukaLib:Deserialize(val))
				end

				plr:SetAttribute("DATA"..i.."StoryId", info.QuestsV3.Main)

				--// Done
				plr:SetAttribute("PlayerDataLoaded"..i, true)

			end):Catch(function(err)
				warn("Save failed to transfer...")
				warn(err)
			end)
		end
	else
		profile:Release()
	end
end
local function clear(plr: Player)
	--- world existence
	local playerChars = workspace.MapComponents.PlayerChars :: Folder
	if playerChars:FindFirstChild(plr.Name) then playerChars[plr.Name]:Destroy() end

	--- profile cleanups
	if profiles[plr] ~= nil then profiles[plr]:Release() end
end

---// Setups
for _, plr: Player in Players:GetPlayers() do Spawn(setup, plr) end

--// Connections
Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(clear)


local function wipeData(plr: Player, slot: string)
	local profile = profiles[plr]
	if not profile then
		Events.CreateHint:Fire(plr, "Error occured when resetting your data!")
		return
	end

	local whiteList = { "Slot1", "Slot2", "Slot3" } --// avoid bypass
	if not table.find(whiteList, slot) then
		Events.CreateHint:Fire(plr, "Error occured when resetting your data!")
		return
	end

	profile.Data[slot] = TEMPLATE["Slot1"]
	profile.Data[slot].Stats.V9Transfered = true

	plr:Kick("Data has wiped, rejoin to continue!")
end
Events.DataWipe:Connect(wipeData)
