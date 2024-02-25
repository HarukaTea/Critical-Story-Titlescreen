--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local HarukaFrameworkClient = require(RepS.Modules.HarukaFrameworkClient)

local AssetBook = HarukaFrameworkClient.AssetBook
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = HarukaFrameworkClient.Fusion

local SaveSlotFrame = require(RepS.Modules.UI.Views.SaveSlotsFrame)
local ServerSlotFrame = require(RepS.Modules.UI.Views.ServersFrame)

local Children, New, Tween, Computed, peek = Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed, Fusion.peek

local fromRGB = Color3.fromRGB
local ud2New, fromOffset, fromScale = UDim2.new, UDim2.fromOffset, UDim2.fromScale

local function ProfileFrame(self: table) : Frame
	return New("Frame")({
		Name = "Profile",
		BackgroundColor3 = fromRGB(),
		BackgroundTransparency = Tween(
			Computed(function(use)
				return use(self.backTrans)
			end),
			AssetBook.TweenInfos.one
		),
		Position = fromOffset(0, -58),
		Size = ud2New(1, 0, 1, 58),
		Visible = false,

		[Children] = {
			Components.ImageLabel({
				Name = "Logo",
				Position = Tween(
					Computed(function(use)
						return use(self.logoPos)
					end),
					AssetBook.TweenInfos.oneHalf
				),
				Size = fromScale(0.43, 0.495),
				Image = "rbxassetid://14404478139",

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 2.039 }),
				},
			}),
			Components.TextButton({
				Name = "Button",
				Position = Tween(
					Computed(function(use)
						return use(self.btnPos)
					end),
					AssetBook.TweenInfos.oneHalf
				),
				Size = fromScale(0.16, 0.06),
				Text = Computed(function(use)
					return use(self.btnText)
				end),

				[Fusion.OnEvent("MouseEnter")] = function()
					if not UIS.TouchEnabled then
						peek(self.UI).Profile.Button.UIStroke.Enabled = true
					end
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					if not UIS.TouchEnabled then
						peek(self.UI).Profile.Button.UIStroke.Enabled = false
					end
				end,
				[Fusion.OnEvent("MouseButton1Click")] = function()
					workspace.Sounds.SFXs.Click:Play()

					if peek(self.btnText) == "PLAY" then
						self.logoPos:set(fromScale(0.295, -0.8))
						self.btnPos:set(fromScale(0.43, 0.88))
						self.btnText:set("BACK")
						self.saveSlotPos:set(fromScale(0.5, 0.5))

					elseif peek(self.btnText) == "BACK" and not peek(self.saveSlotFrame):GetAttribute("SlotChosen") then
						self.saveSlotPos:set(fromScale(0.5, -0.5))
						self.logoPos:set(fromScale(0.295, 0.2))
						self.btnPos:set(fromScale(0.43, 0.8))
						self.btnText:set("PLAY")

					elseif peek(self.btnText) == "BACK" and peek(self.saveSlotFrame):GetAttribute("SlotChosen") then
						peek(self.saveSlotFrame):SetAttribute("SlotChosen", nil)
						self.slotPos[1]:set(fromScale(0.157, 0.165))
						self.slotPos[2]:set(fromScale(0.402, 0.165))
						self.slotPos[3]:set(fromScale(0.646, 0.165))
						self.serverPos:set(fromScale(1.5, 0.5))

						for _, element in peek(self.saveSlotFrame):GetChildren() do
							if element:IsA("Frame") then element.Visible = true end
						end
					end
				end,

				[Children] = {
					New("UIAspectRatioConstraint")({ AspectRatio = 6 }),
					Components.RoundUICorner(),
					Components.NormalUIPadding(),
					Components.UIStroke({
						Thickness = 3,
						Enabled = UIS.TouchEnabled and true or false,
					}),
				},
			}),

			SaveSlotFrame(self),
			ServerSlotFrame(self),

			Components.Frame({
				Name = "Teleport",
				BackgroundTransparency = 0.5,
				Visible = false,
				[Fusion.Ref] = self.teleportFrame,

				[Children] = {
					Components.CenterTextLabel({
						TextXAlignment = Enum.TextXAlignment.Center,
						Position = fromScale(0.5, 0.553),
						Size = fromScale(0.4, 0.06),
						Text = "Travelling to Critical Islands...",

						[Children] = {
							New("UITextSizeConstraint")({ MaxTextSize = 32 }),
						},
					}),
				},
			}),
		},
	})
end

return ProfileFrame
