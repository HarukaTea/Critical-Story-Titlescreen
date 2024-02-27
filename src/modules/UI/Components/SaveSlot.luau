--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local StoryBook = require(RepS.Modules.Data.StoryBook)

local Children, New, peek = Fusion.Children, Fusion.New, Fusion.peek

local udNew = UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local sFind, format = string.find, string.format
local delay = task.delay

local function Padding() : UIPadding
	return New("UIPadding")({
		PaddingLeft = udNew(0.08, 0),
		PaddingRight = udNew(0.08, 0),
	})
end

local function SaveSlot(id: number, self: table) : Frame
    local clicked = { 0, 0, 0 }
	local playTime = self.plr["PlayerData" .. id].PlayTime.Value

	return New("Frame")({
		Name = "Slot" .. id,
		BackgroundColor3 = fromRGB(30, 30, 30),
		Position = Fusion.Tween(
			Fusion.Computed(function(use)
				return use(self.slotPos[id])
			end),
			AssetBook.TweenInfos.one
		),
		Size = fromScale(0.217, 0.67),

		[Children] = {
			New("UICorner")({ CornerRadius = udNew(0.02, 0) }),
			Components.UIStroke({
				Thickness = 3,
				Enabled = true,
			}),
			Components.TextLabel({
				Name = "File",
				Text = "File #" .. id,
				Position = fromScale(0, 0.025),
				Size = fromScale(1, 0.1),
				TextXAlignment = Enum.TextXAlignment.Left,

				[Children] = Padding(),
			}),
			Components.TextLabel({
				Name = "Levels",
				Position = fromScale(0, 0.127),
				Size = fromScale(1, 0.07),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = fromRGB(255, 255, 127),
				Text = "Level " .. self.plr["PlayerData" .. id].Levels.Value,
				TextTransparency = playTime <= 1 and 1 or 0,

				[Children] = Padding(),
			}),
			Components.TextLabel({
				Name = "PlayTime",
				Position = fromScale(0, 0.127),
				Size = fromScale(1, 0.07),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = fromRGB(255, 255, 127),
				Text = if sFind(format("%.1f", playTime / 3600), ".0")
					then format("%.0f", playTime / 3600) .. " Hours"
					else format("%.1f", playTime / 3600) .. " Hours",
				TextTransparency = playTime <= 1 and 1 or 0,

				[Children] = Padding(),
			}),
			Components.TextLabel({
				Name = "LastSeen",
				Position = fromScale(0, 0.9),
				Size = fromScale(1, 0.07),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "Last Seen: " .. AssetBook.DimensionNames[self.plr["PlayerData" .. id].LastSeenLocation.Value],
				TextTransparency = playTime <= 1 and 1 or 0,

				[Children] = Padding(),
			}),
			Components.TextLabel({
				Name = "LastStory",
				Position = fromScale(0, 0.83),
				Size = fromScale(1, 0.07),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = fromRGB(170, 255, 255),
				Text = "Progress: " .. StoryBook.Series[self.plr["PlayerData" .. id].StoryId.Value],
				TextTransparency = playTime <= 1 and 1 or 0,

				[Children] = Padding(),
			}),
			Components.TextLabel({
				Name = "EmptySign",
				Position = fromScale(0, 0.45),
				Size = fromScale(1, 0.1),
				Text = "Empty",
				TextTransparency = 0.5,
				Visible = if playTime <= 1 then true else false,
			}),
			New("ImageLabel")({
				Name = "Class",
				BackgroundColor3 = fromRGB(),
				Position = fromScale(0.815, 0.031),
				Size = fromScale(0.12, 0.09),
				Image = AssetBook.Class[self.plr["PlayerData" .. id].Class.Value],
				Visible = if playTime <= 1 then false else true,

				[Children] = { Components.RoundUICorner() },
			}),
			Components.TextButton({
				Name = "EraseBtn",
				BackgroundColor3 = fromRGB(212, 71, 106),
				Position = fromScale(0.672, 0.03),
				Size = fromScale(0.12, 0.09),
				Text = "X",
				ZIndex = 2,
				Visible = if playTime <= 1 then false else true,

				[Children] = { Components.RoundUICorner() },
				[Fusion.OnEvent("MouseButton1Click")] = function()
					if clicked[id] <= 19 then
						clicked[id] += 1
						Signals.CreateHint:Fire("Click " .. (21 - clicked[id]) .. " times more to erase data!", "Error")

					elseif clicked[id] == 20 then
						Signals.CreateHint:Fire("Erasing data...", "Error")

						peek(self.saveSlotFrame)["Slot" .. id].EraseBtn.Visible = false
						Events.DataWipe:Fire("Slot" .. id)
					end
				end,
			}),
			New("ViewportFrame")({
				Name = "CharacterVPF",
				BackgroundTransparency = 1,
				Position = fromScale(0.074, 0.212),
				Size = fromScale(0.864, 0.618),
				Visible = if playTime <= 1 then false else true,

				[Children] = {
					New("Camera")({}),
				},
			}),
			Components.HoverImageButton({
				Name = "Hover",

				[Fusion.OnEvent("MouseButton1Click")] = function()
					if peek(self.saveSlotFrame):GetAttribute("SlotChosen") then return end

					workspace.Sounds.SFXs.Click:Play()
					peek(self.saveSlotFrame):SetAttribute("SlotChosen", true)

					for _, element in peek(self.saveSlotFrame):GetChildren() do
						if element:IsA("Frame") then element.Visible = false end
					end
					peek(self.saveSlotFrame)["Slot" .. id].Visible = true

					self.slotChosen:set("Slot" .. id)
					self.slotPos[id]:set(fromScale(0.1, 0.165))
					self.serverPos:set(fromScale(0.5, 0.5))

					if peek(self.saveSlotFrame):GetAttribute("FriendsLoaded") then return end
					peek(self.saveSlotFrame):SetAttribute("FriendsLoaded", true)
					self.friends:set(self.plr:GetFriendsOnline())

					--- there'll be issues if we don't have cooldown (I have already encountered)
					delay(31, function()
						peek(self.saveSlotFrame):SetAttribute("FriendsLoaded", false)
					end)
				end,
			}),
		},
	})
end

return SaveSlot