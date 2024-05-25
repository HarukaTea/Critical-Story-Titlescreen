--!nocheck

local GroupService = game:GetService("GroupService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TeleportService = game:GetService("TeleportService")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local CODE = { "MILKSHAKE" }
local WORLDS = {
	MainWorld = 12343565896, TestNormal = 17444533020
}

local function _teleportPrivateTests(id: string, rankNeeded: number, plr: Player, tpOptions: TeleportOptions)
	local groups, rank = GroupService:GetGroupsAsync(plr.UserId), 0

	for _, group: table in groups do
		if group.Id == 16912246 then rank = group.Rank end
	end

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
		TeleportService:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

	elseif option == "CreatePrivate" then
		local code
		local success = pcall(function()
			code = TeleportService:ReserveServer(WORLDS.MainWorld)
		end)
		if not success then
			Events.TeleportFailed:Fire(plr)

			Events.CreateHint:Fire(plr, "Error occurred when creating private server!")
			return
		end

		teleportOptions.ReservedServerAccessCode = code
		teleportOptions:SetTeleportData({ dataChosen, code })

		TeleportService:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

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

				TeleportService:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

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
			if message.Data[1] == visitorId then
				teleportOptions.ServerInstanceId = message.Data[2]

				TeleportService:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

				connection:Disconnect()
			end
		end)

		MessagingService:PublishAsync("JoinFriendRequest", visitorId)

	elseif option == "JoinPrivate" and privateCode == "MILKSHAKE" then
		_teleportPrivateTests("TestNormal", 2, plr, teleportOptions)
	end
end
Events.TeleportPrompt:Connect(teleportHandler)


local function teleportFailed(plr: Player)
	Events.TeleportFailed:Fire(plr)
	Events.CreateHint:Fire(plr, "Teleport failed!")
end
TeleportService.TeleportInitFailed:Connect(teleportFailed)
