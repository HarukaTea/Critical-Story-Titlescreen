--!nocheck
--!optimize 2
--!native

local GS = game:GetService("GroupService")
local MS = game:GetService("MessagingService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Spawn = require(RepS.Modules.Packages.Spawn)

local CODE = { "MILKSHAKE", "GENSHIN", "FAKECW", "STRIKE", "TACO", "HAII" }
local WORLDS = {
	MainWorld = 12343565896, TestNormal = 12003361010, FakeCW = 12373196969,
	CSCA = 1043446942, V1World = 12294239008, TestDeep = 6605778811,
	TestPastel = 17444533020
}

local instanceNew = Instance.new
local tFind = table.find
local wait = task.wait

local function teleportHandler(plr: Player, option: string, privateCode: string, dataChosen: string)
	local teleportOptions = instanceNew("TeleportOptions")
	teleportOptions:SetTeleportData({ dataChosen })

	if option == "Solo" then
		TeleS:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

	elseif option == "CreatePrivate" then
		local code
		local success = pcall(function()
			code = TeleS:ReserveServer(WORLDS.MainWorld)
		end)
		if not success then
			Events.TeleportFailed:Fire(plr)

			Events.CreateHint:Fire(plr, "Error occurred when creating private server!")
			return
		end

		teleportOptions.ReservedServerAccessCode = code
		teleportOptions:SetTeleportData({ dataChosen, code })

		TeleS:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

	elseif option == "JoinPrivate" and not tFind(CODE, privateCode) then
		local connection

		Spawn(function()
			wait(5)
			if connection then
				connection:Disconnect()

				Events.CreateHint:Fire(plr, "Invalid code!")
				Events.TeleportFailed:Fire(plr)
			end
		end)

		connection = MS:SubscribeAsync("JoinPrivateCheck", function(message: table)
			if message.Data[1] == privateCode then
				teleportOptions.ReservedServerAccessCode = message.Data[2]

				TeleS:TeleportAsync(WORLDS.MainWorld, { plr }, teleportOptions)

				connection:Disconnect()
			end
		end)

		MS:PublishAsync("ReturnAllPrivateServers", privateCode)

	elseif option == "JoinPrivate" and privateCode == "MILKSHAKE" then
		local groups, rank = GS:GetGroupsAsync(plr.UserId), 0

		for _, group: table in groups do
			if group.Id == 16912246 then rank = group.Rank end
		end

		if rank >= 2 then
			TeleS:TeleportAsync(WORLDS.TestNormal, { plr }, teleportOptions)
		else
			Events.CreateHint:Fire(plr, "You don't have the permission to join test place!", "Error")
			Events.TeleportFailed:Fire(plr)
		end

	elseif option == "JoinPrivate" and privateCode == "GENSHIN" then
		TeleS:Teleport(WORLDS.V1World, plr)

	elseif option == "JoinPrivate" and privateCode == "FAKECW" then
		TeleS:TeleportAsync(WORLDS.FakeCW, { plr }, teleportOptions)

	elseif option == "JoinPrivate" and privateCode == "STRIKE" then
		TeleS:TeleportAsync(WORLDS.CSCA, { plr }, teleportOptions)

	elseif option == "JoinPrivate" and privateCode == "TACO" then
		local groups, rank = GS:GetGroupsAsync(plr.UserId), 0

		for _, group: table in groups do
			if group.Id == 16912246 then rank = group.Rank end
		end

		if rank >= 3 then
			TeleS:TeleportAsync(WORLDS.TestDeep, { plr }, teleportOptions)
		else
			Events.CreateHint:Fire(plr, "You don't have the permission to join test place!", "Error")
			Events.TeleportFailed:Fire(plr)
		end

	elseif option == "JoinPrivate" and privateCode == "HAII" then
		local whiteList = { 875015360, 304008764 }

		if tFind(whiteList, plr.UserId) then
			TeleS:TeleportAsync(WORLDS.TestPastel, { plr }, teleportOptions)
		else
			Events.CreateHint:Fire(plr, "You don't have the permission to join test place!", "Error")
			Events.TeleportFailed:Fire(plr)
		end

	elseif option == "JoinFriend" then
		local success, errorMsg = pcall(function()
			local visitorId = privateCode
			local result = TeleS:GetPlayerPlaceInstanceAsync(visitorId)

			if not result[1] then
				Events.CreateHint:Fire(plr, "Can't join your friend right now!")
				Events.CreateHint:Fire(plr, "Try again later!")

				Events.TeleportFailed:Fire(plr)
			end

			local placeId, jobId = result[3], result[4]
			teleportOptions.ServerInstanceId = jobId

			TeleS:TeleportAsync(placeId, { plr }, teleportOptions)
		end)

		if not success then
			Events.CreateHint:Fire(plr, "Error occurred when attempting to join your friend!")
			Events.TeleportFailed:Fire(plr)
		end

		warn(errorMsg)
	end
end
Events.TeleportPrompt:Connect(teleportHandler)


local function teleportFailed(plr: Player)
	Events.TeleportFailed:Fire(plr)
	Events.CreateHint:Fire(plr, "Teleport failed!")
end
TeleS.TeleportInitFailed:Connect(teleportFailed)
