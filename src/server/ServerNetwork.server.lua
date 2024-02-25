--!nocheck

local GS = game:GetService("GroupService")
local MS = game:GetService("MessagingService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TeleportService")

local HarukaFrameworkServer = require(SSS.Modules.HarukaFrameworkServer)

local Events = HarukaFrameworkServer.Events
local FastSpawn = HarukaFrameworkServer.FastSpawn

local WORLD_ID, GROUP_ID, TEST_WORLD_ID, V1_WORLD_ID, V2_WORLD_ID, V3_WORLD_ID =
	12343565896, 16912246, 12003361010, 12294239008, 12373229403, 13970315225
local CODE = {"MILKSHAKE", "GENSHIN", "FAMILIAR", "SUMMIT"}

local instanceNew = Instance.new
local tFind = table.find
local wait = task.wait

local function teleportHandler(plr: Player, option: string, privateCode: string, dataChosen: string)
	local teleportOptions = instanceNew("TeleportOptions")
	teleportOptions:SetTeleportData({dataChosen})

	if option == "Solo" then
		TS:TeleportAsync(WORLD_ID, {plr}, teleportOptions)

	elseif option == "CreatePrivate" then
		local code, id = TS:ReserveServer(WORLD_ID)

		teleportOptions.ReservedServerAccessCode = code
		teleportOptions:SetTeleportData({dataChosen, code})

		TS:TeleportAsync(WORLD_ID, {plr}, teleportOptions)

	elseif option == "JoinPrivate" and not tFind(CODE, privateCode) then
		local connection

		FastSpawn(function()
			wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint:Fire(plr, "Invalid Code!")
				Events.TeleportFailed:Fire(plr)
			end
		end)

		connection = MS:SubscribeAsync("JoinPrivateCheck", function(message)
			if message.Data[1] == privateCode then
				teleportOptions.ReservedServerAccessCode = message.Data[2]

				TS:TeleportAsync(WORLD_ID, {plr}, teleportOptions)

				connection:Disconnect()
			end
		end)

		MS:PublishAsync("ReturnAllPrivateServers", privateCode)

	elseif option == "JoinPrivate" and privateCode == "MILKSHAKE" then
		local groups, rank = GS:GetGroupsAsync(plr.UserId), 0

		for _, group in groups do
			if group.Id == GROUP_ID then rank = group.Rank end
		end

		if rank >= 2 then
			TS:TeleportAsync(TEST_WORLD_ID, {plr}, teleportOptions)

		else
			Events.CreateHint:Fire(plr, "You don't have the permission to join test place!")
			Events.TeleportFailed:Fire(plr)
		end

	elseif option == "JoinPrivate" and privateCode == "GENSHIN" then
		TS:Teleport(V1_WORLD_ID, plr)

	elseif option == "JoinPrivate" and privateCode == "SAVIOR" then
		TS:Teleport(V2_WORLD_ID, plr)

	elseif option == "JoinPrivate" and privateCode == "SUMMIT" then
		TS:Teleport(V3_WORLD_ID, plr)

	elseif option == "JoinFriend" then
		local connection

		FastSpawn(function()
			wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint:Fire(plr, "Failed to teleport to your friend!")
				Events.TeleportFailed:Fire(plr)
			end
		end)

		connection = MS:SubscribeAsync("JoinFriendCheck", function(message)
			teleportOptions.ServerInstanceId = message.Data

			TS:TeleportAsync(WORLD_ID, {plr}, teleportOptions)

			connection:Disconnect()
		end)

		MS:PublishAsync("ReturnFriendLocation", privateCode)
	end
end
Events.TeleportPrompt:Connect(teleportHandler)

local function teleportFailed(plr: Player)
	Events.TeleportFailed:Fire(plr)
end
TS.TeleportInitFailed:Connect(teleportFailed)

--- once everything is done, we start the server
require(SSS.Modules.ServerSetups)()
