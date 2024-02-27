--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local ServerBottomBtn = require(RepS.Modules.UI.Components.ServerBottomBtn)
local FriendSlot = require(RepS.Modules.UI.Components.FriendSlot)

local fromRGB = Color3.fromRGB
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new

local function ServersFrame(self: table) : Frame
    return Components.Frame({
		Name = "Servers",
		Position = Fusion.Tween(
			Computed(function(use)
				return use(self.serverPos)
			end),
			AssetBook.TweenInfos.one
		),

		[Children] = {
			New("UIAspectRatioConstraint")({ AspectRatio = 2.344 }),
			Components.Frame({
				AnchorPoint = v2New(),
				BackgroundTransparency = 0.5,
				Position = fromScale(0.355, 0.165),
				Size = fromScale(0.55, 0.67),

				[Children] = {
					New("UICorner")({}),
					New("Frame")({
						Name = "Top",
						BackgroundColor3 = fromRGB(),
						Size = fromScale(1, 0.1),

						[Children] = {
							New("UICorner")({}),
							Components.TextLabel({
								Name = "Title",
								Size = fromScale(1, 1),
								Text = "Friends",

								[Children] = { Components.NormalUIPadding() },
							}),
						},
					}),
					Components.ScrollingFrame({
						Name = "List",
						Size = fromScale(1, 0.8),
						ScrollBarThickness = 6,
						ScrollingDirection = Enum.ScrollingDirection.Y,
						CanvasSize = Computed(function(use)
							return fromOffset(0, use(self.listAbSize).Y + 4 * (use(self.listAbSize).Y / use(self.friendFrameSize)))
						end),
						ClipsDescendants = true,

						[Fusion.Out("CanvasSize")] = self.scrollSize,
                        [Fusion.OnEvent("ChildAdded")] = function(child)
                            child.Avatar.Image = Players:GetUserThumbnailAsync(child:GetAttribute("Player"),
								Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
                        end,

						[Children] = {
							New("UIListLayout")({
								Padding = udNew(0, 4),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,

								[Fusion.Out("AbsoluteContentSize")] = self.listAbSize,
							}),
							New("Frame")({
								Name = "A-TopPadding",
								BackgroundTransparency = 1,
								Size = ud2New(1, 0, 0, 4),
							}),
							Fusion.ForValues(self.friends, function(use, friend)
								return FriendSlot(friend, self)
							end, Fusion.cleanup),
						},
					}),
					New("Frame")({
						Name = "Bottom",
						BackgroundColor3 = fromRGB(30, 30, 30),
						Position = fromScale(0, 0.9),
						Size = fromScale(1, 0.1),

						[Children] = {
							New("UICorner")({}),
							New("UIListLayout")({
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								Padding = udNew(0.012, 0),
								VerticalAlignment = Enum.VerticalAlignment.Center,
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							Components.TextBox({
								Name = "PrivateCode",
								Size = fromScale(0.2, 0.655),
								PlaceholderText = "Code",

								[Children] = { Components.RoundUICorner() },
								[Fusion.OnChange("Text")] = function(text)
									self.privateCode:set(text)
								end,
							}),

							ServerBottomBtn("Private", self),
							ServerBottomBtn("JoinPrivate", self),
							ServerBottomBtn("Join", self),
						},
					}),
					Components.TextLabel({
						Name = "Loading",
						Position = fromScale(0, 0.5),
						Size = fromScale(1, 0.08),
						TextTransparency = 0.5,
						Text = "Loading friends...",
						Visible = Computed(function(use)
							return if use(self.scrollSize).Y.Offset > 4 then false else true
						end),
					}),
				},
			}),
		},
	})
end

return ServersFrame
