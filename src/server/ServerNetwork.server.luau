--!nocheck

local GS = game:GetService("GroupService")
local MS = game:GetService("MessagingService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local TeleS = game:GetService("TeleportService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Spawn = require(RepS.Modules.Packages.Spawn)

local CODE = { "MILKSHAKE" }
local WORLDS = {
	MainWorld = 12343565896, TestNormal = 17444533020
}

local instanceNew = Instance.new
local tFind = table.find
local wait = task.wait

local function _teleportPrivateTests(id: string, rankNeeded: number, plr: Player, tpOptions: TeleportOptions)
	local groups, rank = GS:GetGroupsAsync(plr.UserId), 0

	for _, group: table in groups do
		if group.Id == 16912246 then rank = group.Rank end
	end

	if rank >= rankNeeded then
		TeleS:TeleportAsync(WORLDS[id], { plr }, tpOptions)
	else
		Events.CreateHint:Fire(plr, "You don't have the permission to join test place!")
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
	end
end
Events.TeleportPrompt:Connect(teleportHandler)


local function teleportFailed(plr: Player)
	Events.TeleportFailed:Fire(plr)
	Events.CreateHint:Fire(plr, "Teleport failed!")
end
TeleS.TeleportInitFailed:Connect(teleportFailed)
