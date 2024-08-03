--!nocheck

local MarketplaceService = game:GetService("MarketplaceService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local AssetBook = require(ReplicatedStorage.Modules.Data.AssetBook)
local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local WORLDS = AssetBook.WorldInfo

Events.TeleportPrompt.SetCallback(function(plr, data)
	local option, privateCode, dataChosen = data.Option, data.PrivateCode, data.SlotChosen

	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions:SetTeleportData({ dataChosen })

	if option == "JoinPublic" then
		task.wait(1)
		Promise.new(function()
			local slotChosen = tonumber(string.match(dataChosen, "%d"))
			local lastSeenWorld = plr:GetAttribute("DATA"..slotChosen.."LastSeenWorld") :: string

			if plr:GetAttribute("DATA"..slotChosen.."_WORLD_UNLOCK_"..lastSeenWorld) == true then
				TeleportService:TeleportAsync(AssetBook.WorldInfo[lastSeenWorld], { plr }, teleportOptions)

			else
				Events.TeleportFailed.Fire(plr, {})
				Events.CreateHint.Fire(plr, { Hint = "You haven't unlocked this world yet!" })
			end

		end):catch(function(err)
			warn(`[Public Teleport]: {err}`)

			TeleportService:TeleportAsync(WORLDS.Mainworld, { plr }, teleportOptions)
		end)

	elseif option == "CreatePrivate" then
		task.wait(1)
		Promise.new(function()
			local ownGamepass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, 881563847)
			local rank = plr:GetRankInGroup(16912246)

			if ownGamepass == true or plr:GetAttribute("OwnGamepassLocal") == true or rank >= 125 then
				local worldChosen = privateCode
				local worldId = AssetBook.WorldInfo[worldChosen]
				local code = TeleportService:ReserveServer(worldId)

				teleportOptions.ReservedServerAccessCode = code
				teleportOptions:SetTeleportData({ dataChosen, code })

				TeleportService:TeleportAsync(worldId, { plr }, teleportOptions)

			else
				MarketplaceService:PromptGamePassPurchase(plr, 881563847)

				Events.CreateHint.Fire(plr, { Hint = "You need to own gamepass to create a private server!" })
				Events.TeleportFailed.Fire(plr, {})
			end

		end):catch(function(err)
			Events.TeleportFailed.Fire(plr, {})
			Events.CreateHint.Fire(plr, { Hint = "Error occurred when creating private server!" })

			warn(`[Private Teleport]: {err}`)
			return
		end)

	elseif option == "JoinPrivate" then
		local connection: RBXScriptConnection

		Spawn(function()
			task.wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint.Fire(plr, { Hint = "Invalid code!" })
				Events.TeleportFailed.Fire(plr, {})
			end
		end)

		connection = MessagingService:SubscribeAsync("JoinPrivateCheck", function(message: table)
			if message.Data[1] == privateCode then
				local serverWorld = message.Data[3] :: string

				teleportOptions.ReservedServerAccessCode = message.Data[2]

				TeleportService:TeleportAsync(AssetBook.WorldInfo[serverWorld], { plr }, teleportOptions)

				connection:Disconnect()
			end
		end)

		MessagingService:PublishAsync("ReturnAllPrivateServers", privateCode)

	elseif option == "JoinFriend" then
		local visitorId = privateCode

		local connection: RBXScriptConnection
		Spawn(function()
			task.wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint.Fire(plr, { Hint = "Failed to join friend!" })
				Events.TeleportFailed.Fire(plr, {})
			end
		end)

		connection = MessagingService:SubscribeAsync("JoinFriendReturn", function(message: table)
			local slotChosen = tonumber(string.match(dataChosen, "%d"))
			local serverWorld = message.Data[3] :: string

			if not plr:GetAttribute("DATA"..slotChosen.."_WORLD_UNLOCK_"..serverWorld) then
				Events.TeleportFailed.Fire(plr, {})
				Events.CreateHint.Fire(plr, { Hint = "You haven't unlocked this world yet!" })

				connection:Disconnect()
				return
			end

			if message.Data[1] == visitorId then
				teleportOptions.ServerInstanceId = message.Data[2]

				TeleportService:TeleportAsync(AssetBook.WorldInfo[serverWorld], { plr }, teleportOptions)

				connection:Disconnect()
			end
		end)

		MessagingService:PublishAsync("JoinFriendRequest", visitorId)
	end
end)


Events.DataTransfer.SetCallback(function(plr: Player)
	task.wait(1)
	TeleportService:Teleport(7523159032, plr)
end)


TeleportService.TeleportInitFailed:Connect(function(plr: Player)
	Events.TeleportFailed.Fire(plr, {})
	Events.CreateHint.Fire(plr, { Hint = "Teleport failed!" })
end)


--// Local gamepass, ignore caching behavior of marketplace service
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr: Player, gamepassId: number, success: boolean)
	if gamepassId == 881563847 and success == true and plr:IsDescendantOf(Players) then
		plr:SetAttribute("OwnGamepassLocal", true)
	end
end)
