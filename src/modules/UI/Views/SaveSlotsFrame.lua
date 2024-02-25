--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = HarukaFrameworkClient.Fusion

local SaveSlot = require(RepS.Modules.UI.Components.SaveSlot)

local function SaveSlotsFrame(self: table) : Frame
	return Components.Frame({
		Name = "SaveSlots",
		Position = Fusion.Tween(
			Fusion.Computed(function(use)
				return use(self.saveSlotPos)
			end),
			AssetBook.TweenInfos.oneHalf
		),
		[Fusion.Ref] = self.saveSlotFrame,

		[Fusion.Children] = {
			Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 2.351 }),

			SaveSlot(1, self),
			SaveSlot(2, self),
			SaveSlot(3, self),
		},
	})
end

return SaveSlotsFrame
