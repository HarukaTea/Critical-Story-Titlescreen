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

local CODE = { "MILKSHAKE", "GENSHIN", "FAKECW", "STRIKE", "TACO", "FALLEN" }
local WORLDS = {
	MainWorld = 17553948946, TestNormal = 17553875545
}

local instanceNew = Instance.new
local tFind = table.find
local wait = task.wait

local function _teleportPrivateTests(id: string, rankNeeded: number, plr: Player, tpOptions: TeleportOptions)
	local _, _, groups, rank = pcall(function()
		return GS:GetGroupsAsync(plr.UserId), 0
	end)

	for _, group: table in groups do
		if group.Id == 16912246 then rank = group.Rank end
	end

	if rank >= rankNeeded then
		TeleS:TeleportAsync(WORLDS[id], { plr }, tpOptions)
	else
		Events.CreateHint:Fire(plr, "You don't have the permission to join test place!", "Error")
		Events.TeleportFailed:Fire(plr)
	end
end
local function teleportHandler(plr: Player, option: string, privateCode: string, dataChosen: string)
	local teleportOptions = instanceNew("TeleportOptions")
	teleportOptions:SetTeleportData({ dataChosen })

	if option == "JoinPublic" then
		wait(0.5)
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
		_teleportPrivateTests("TestNormal", 2, plr, teleportOptions)

	elseif option == "JoinFriend" then
		local success, errorMsg = pcall(function()
			local visitorId = privateCode
			local ok, _, _, placeId, jobId = pcall(function()
				return TeleS:GetPlayerPlaceInstanceAsync(visitorId)
			end)

			if not ok then
				Events.CreateHint:Fire(plr, "Can't join your friend right now!")
				Events.CreateHint:Fire(plr, "Try again later!")

				Events.TeleportFailed:Fire(plr)
			end
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
