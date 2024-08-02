--!nocheck

local MessagingService = game:GetService("MessagingService")
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
		task.wait(0.5)
		Promise.new(function()
			local slotChosen = tonumber(string.match(dataChosen, "%d"))
			local lastSeenWorld = plr:GetAttribute("DATA"..slotChosen.."LastSeenWorld") :: string

			if plr:GetAttribute("_WORLD_UNLOCK_"..lastSeenWorld) == true then
				TeleportService:TeleportAsync(lastSeenWorld, { plr }, teleportOptions)
			else
				Events.TeleportFailed.Fire(plr, {})
				Events.CreateHint.Fire(plr, { Hint = "You haven't unlocked this world yet!" })
				Events.CreateFullScreenHint.Fire(plr, { Hint = "", State = false })
			end

		end):catch(function(err)
			warn(`[Public Teleport]: {err}`)

			TeleportService:TeleportAsync(WORLDS.Mainworld, { plr }, teleportOptions)
		end)

	elseif option == "CreatePrivate" then
		task.wait(0.5)
		Promise.new(function()
			local code = TeleportService:ReserveServer(WORLDS.Mainworld)

			teleportOptions.ReservedServerAccessCode = code
			teleportOptions:SetTeleportData({ dataChosen, code })

			TeleportService:TeleportAsync(WORLDS.Mainworld, { plr }, teleportOptions)

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
				teleportOptions.ReservedServerAccessCode = message.Data[2]

				TeleportService:TeleportAsync(WORLDS.Mainworld, { plr }, teleportOptions)

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
			local placeId = message.Data[3] :: number
			if placeId ~= AssetBook.WorldInfo.Mainworld then return end

			if message.Data[1] == visitorId then
				teleportOptions.ServerInstanceId = message.Data[2]

				TeleportService:TeleportAsync(message.Data[3], { plr }, teleportOptions)

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
	Events.CreateFullScreenHint.Fire(plr, { Hint = "", State = false })
end)
