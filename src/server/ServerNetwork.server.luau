--!nocheck

local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local AssetBook = require(ReplicatedStorage.Modules.Data.AssetBook)
local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local CODE = { "MILKSHAKE", "CE", "PAHO" }
local WORLDS = AssetBook.WorldInfo

local function _teleportPrivateTests(id: string, rankNeeded: number, plr: Player, tpOptions: TeleportOptions)
	local rank = plr:GetRankInGroup(16912246)

	if rank >= rankNeeded then
		TeleportService:TeleportAsync(WORLDS[id], { plr }, tpOptions)
	else
		Events.CreateHint:Fire(plr, "You don't have the permission to join test place!")
		Events.TeleportFailed:Fire(plr)
	end
end
local function teleportHandler(plr: Player, option: string, privateCode: string, dataChosen: string)
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions:SetTeleportData({ dataChosen })

	if option == "JoinPublic" then
		task.wait(0.5)
		Promise.new(function()
			local slotChosen = tonumber(string.match(dataChosen, "%d"))
			local lastSeenWorld = plr:GetAttribute("DATA"..slotChosen.."LastSeenWorld") :: string

			TeleportService:TeleportAsync(WORLDS[lastSeenWorld], { plr }, teleportOptions)

		end):Catch(function(err)
			warn("[Public Teleport]: "..err)

			TeleportService:TeleportAsync(WORLDS.Mainworld, { plr }, teleportOptions)
		end)

	elseif option == "CreatePrivate" then
		task.wait(0.5)
		Promise.new(function()
			local slotChosen = tonumber(string.match(dataChosen, "%d"))
			local lastSeenWorld = plr:GetAttribute("DATA"..slotChosen.."LastSeenWorld") :: string

			local code = TeleportService:ReserveServer(WORLDS[lastSeenWorld])

			teleportOptions.ReservedServerAccessCode = code
			teleportOptions:SetTeleportData({ dataChosen, code })

			TeleportService:TeleportAsync(WORLDS[lastSeenWorld], { plr }, teleportOptions)

		end):Catch(function(err)
			Events.TeleportFailed:Fire(plr)
			Events.CreateHint:Fire(plr, "Error occurred when creating private server!")

			warn("[Private Create]: "..err)
			return
		end)

	elseif option == "JoinPrivate" and not table.find(CODE, privateCode) then
		local connection: RBXScriptConnection

		Spawn(function()
			task.wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint:Fire(plr, "Invalid code!")
				Events.TeleportFailed:Fire(plr)
			end
		end)

		connection = MessagingService:SubscribeAsync("JoinPrivateCheck", function(message: table)
			if message.Data[1] == privateCode then
				teleportOptions.ReservedServerAccessCode = message.Data[2]

				TeleportService:TeleportAsync(message.Data[3], { plr }, teleportOptions)

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

				Events.CreateHint:Fire(plr, "Failed to join friend!")
				Events.TeleportFailed:Fire(plr)
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

	elseif option == "JoinPrivate" and privateCode == "MILKSHAKE" then
		_teleportPrivateTests("PrivateTest", 2, plr, teleportOptions)

	elseif option == "JoinPrivate" and privateCode == "PAHO" then
		_teleportPrivateTests("TimeDomain", 2, plr, teleportOptions)

	elseif option == "JoinPrivate" and privateCode == "CE" then
		TeleportService:Teleport(WORLDS.CE, plr)
	end
end
Events.TeleportPrompt:Connect(teleportHandler)


local function teleportFailed(plr: Player)
	Events.TeleportFailed:Fire(plr)
	Events.CreateHint:Fire(plr, "Teleport failed!")
end
TeleportService.TeleportInitFailed:Connect(teleportFailed)
