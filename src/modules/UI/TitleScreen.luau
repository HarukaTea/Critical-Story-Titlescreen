--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local ProfileFrame = require(RepS.Modules.UI.Views.ProfileFrame)

local Value = Fusion.Value

local TitleScreen = {}
TitleScreen.__index = TitleScreen

local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local v2New = Vector2.new

return function(plr: Player)
	local self = setmetatable({}, TitleScreen)

	self.plr = plr
	self.friends = Value({})
	self.UI, self.saveSlotFrame, self.teleportFrame = Value(), Value(), Value()
	self.backTrans = Value(1)
	self.logoPos, self.btnPos, self.btnText = Value(fromScale(0.295, -0.8)), Value(fromScale(0.42, 1.5)), Value("PLAY")
	self.saveSlotPos, self.slotPos, self.serverPos =
		Value(fromScale(0.5, -0.5)),
		{ Value(fromScale(0.157, 0.165)), Value(fromScale(0.402, 0.165)), Value(fromScale(0.646, 0.165)) },
		Value(fromScale(1.5, 0.5))
	self.listAbSize, self.friendFrameSize, self.scrollSize =
		Value(v2New()), Value(workspace.CurrentCamera.ViewportSize.Y), Value(fromOffset(0, 0))
	self.slotChosen, self.privateCode = Value("Slot1"), Value("")

	Components.ScreenGui({
		Name = "AdventureStart",
		Parent = plr.PlayerGui,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		[Fusion.Ref] = self.UI,

		[Fusion.Children] = { ProfileFrame(self) },
	})
	Fusion.New("BlurEffect")({
		Name = "UIBlur",
		Parent = workspace.CurrentCamera,
		Size = 8,
	})

	return self
end
