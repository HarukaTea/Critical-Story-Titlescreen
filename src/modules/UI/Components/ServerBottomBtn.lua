--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local Components = require(RepS.Modules.UI.Vanilla)
local Events = HarukaFrameworkClient.Events
local Fusion = HarukaFrameworkClient.Fusion

local peek = Fusion.peek

local fromRGB = Color3.fromRGB
local fromScale = UDim2.fromScale
local upper = string.upper

local TEXTS = {
    Private = "Create Private",
    Join = "Play Solo",
    JoinPrivate = "Join Private"
}
local COLORS = {
	Private = fromRGB(65, 131, 97),
	Join = fromRGB(69, 139, 208),
	JoinPrivate = fromRGB(188, 125, 94),
}

local function ServerBottomBtn(id: string, self: table) : TextButton
    return Components.TextButton({
		Name = id,
		Size = fromScale(0.245, 0.655),
		Text = TEXTS[id],
		BackgroundColor3 = COLORS[id],
		TextStrokeTransparency = 0.6,

		[Fusion.Children] = { Components.RoundUICorner() },
		[Fusion.OnEvent("MouseButton1Click")] = function()
			for _, child in peek(self.UI).Profile:GetChildren() do
				if child:IsA("GuiObject") then child.Visible = false end
			end

			workspace.Sounds.SFXs.Click:Play()
			peek(self.teleportFrame).Visible = true

			if id == "Join" then
				Events.TeleportPrompt:Fire("Solo", nil, peek(self.slotChosen))

			elseif id == "Private" then
				Events.TeleportPrompt:Fire("CreatePrivate", nil, peek(self.slotChosen))

			elseif id == "JoinPrivate" then
				Events.TeleportPrompt:Fire("JoinPrivate", upper(peek(self.privateCode)), peek(self.slotChosen))
			end
		end,
	})
end

return ServerBottomBtn
