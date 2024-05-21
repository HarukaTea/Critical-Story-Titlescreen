--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New = Fusion.Children, Fusion.New

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local function FriendSlot(info: table, self: table, scope: table) : Frame
    return Components.Frame(scope, {
        Name = Fusion.Computed(scope, function()
            if AssetBook.friendsStatusColors[info.LocationType] == fromRGB(0, 198, 96) then
                return "B-InGame"
            elseif AssetBook.friendsStatusColors[info.LocationType] == fromRGB(85, 170, 255) then
                return "C-Online"
            else
                return "D-Studio"
            end
        end),
        Size = fromScale(0.98, 0.3),
        BackgroundColor3 = fromRGB(25, 25, 25),
        BackgroundTransparency = 0,

        [Fusion.Attribute("Friend")] = true,
        [Fusion.Attribute("UserId")] = info.VisitorId,

        [Children] = {
            New(scope, "UIAspectRatioConstraint")({ AspectRatio = 11.245 }),
            New(scope, "UICorner")({ CornerRadius = udNew(0.1, 0) }),

            Components.ImageLabel(scope, {
                Name = "Avatar",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.023, 0.5),
                Size = fromScale(0.8, 0.8),
                BackgroundTransparency = 0,
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    Components.RoundUICorner(scope),

                    New(scope, "ImageLabel")({
                        Name = "Status",
                        Position = fromScale(0.7, 0.6),
                        Size = fromScale(0.3, 0.3),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 2,
                        BackgroundColor3 = AssetBook.friendsStatusColors[info.LocationType],
                        BackgroundTransparency = 0,

                        [Children] = { Components.RoundUICorner(scope) }
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "PlayerName",
                Position = fromScale(0.11, 0.098),
                Size = fromScale(0.85, 0.35),
                RichText = true,
                Text = info.DisplayName..[[<font color="#999">]].." (@"..info.UserName..")</font>",
                TextXAlignment = Enum.TextXAlignment.Left,
            }),
            Components.TextLabel(scope, {
                Name = "Playing",
                Position = fromScale(0.11, 0.48),
                Size = fromScale(0.85, 0.35),
                Text = info.LastLocation,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = AssetBook.friendsStatusColors[info.LocationType],
            })
        }
    })
end

return FriendSlot
