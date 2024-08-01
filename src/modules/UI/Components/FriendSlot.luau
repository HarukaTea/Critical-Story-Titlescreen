--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local function FriendSlot(info: table, self: table, scope: table) : Frame
    return Components.Frame(scope, {
        Name = Computed(scope, function()
            if info.IsInCS then return "AAAB-InCS-"..info.UserName end

            if AssetBook.friendsStatusColors[info.LocationType] == fromRGB(0, 198, 96) then
                return "B-InGame-"..info.UserName
            elseif AssetBook.friendsStatusColors[info.LocationType] == fromRGB(85, 170, 255) then
                return "C-Online-"..info.UserName
            else
                return "D-Studio-"..info.UserName
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
                        Position = fromScale(0.7, 0.7),
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
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Computed(scope, function()
                    local displayName, userName = info.DisplayName :: string, info.UserName :: string

                    if displayName == userName then
                        return displayName
                    else
                        return displayName..[[<font color="#999">]].." (@"..userName..")</font>"
                    end
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Playing",
                Position = fromScale(0.11, 0.48),
                Size = fromScale(0.85, 0.35),
                Text = info.LastLocation,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = AssetBook.friendsStatusColors[info.LocationType],
            }),

            Components.TextButton(scope, {
                Name = "JoinBtn",
                BackgroundColor3 = fromRGB(71, 143, 106),
                Position = fromScale(0.83, 0.5),
                Size = fromScale(0.15, 0.4),
                AnchorPoint = v2New(0, 0.5),
                Text = "JOIN",

                Visible = Computed(scope, function()
                    local found = false
                    for _, world in AssetBook.WorldInfo do
                        if info.PlaceId == world then found = true break end
                    end

                    return found
                end),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    self.isTeleporting:set(true)

                    Signals.CreateFullScreenHint:Fire("TRAVELLING TO CRITICAL WORLDS...", true)

                    Events.TeleportPrompt.Fire({
                        Option = "JoinFriend",
                        PrivateCode = info.VisitorId,
                        SlotChosen = Fusion.peek(self.slotChosen)
                    })

                    workspace.Sounds.SFXs.Click:Play()
                end,

                [Children] = {
                    Components.RoundUICorner(scope),
                    New(scope, "UIPadding")({
                        PaddingBottom = udNew(0.1, 0),
                        PaddingTop = udNew(0.1, 0)
                    })
                }
            })
        }
    })
end

return FriendSlot
