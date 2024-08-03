--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local FriendSlot = require(RepS.Modules.UI.Components.FriendSlot)
local FriendListFuncButton = require(RepS.Modules.UI.Components.FriendListFuncButton)

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local upper = string.upper


local function _checkIsInCS(placeId: number) : (boolean, string)
    local found, currentWorld = false, "None"

    for worldId: string, world: number in AssetBook.WorldInfo do
        if placeId == world then
            found = true
            currentWorld = worldId
            break
        end
    end

    return found, currentWorld
end

local function FriendList(self: table) : Frame
    local scope = self.scope :: table

    self.friendListFrame = Fusion.Value(scope, Components.ScrollingFrame(scope, {
        Name = "FriendList",
        AnchorPoint = v2New(),
        Position = fromScale(0, 0.15),
        Size = fromScale(1, 0.73),
        ScrollingDirection = Enum.ScrollingDirection.Y,

        CanvasSize = Computed(scope, function(use)
            return if use(self.friendsAbsContentSize).Y > use(self.friendsAbsSize).Y then fromOffset(0, use(self.friendsAbsContentSize).Y) else fromOffset(0, 0)
        end),
        ScrollingEnabled = Computed(scope, function(use)
            return if use(self.friendsAbsContentSize).Y > use(self.friendsAbsSize).Y then true else false
        end),

        [Children] = {
            New(scope, "UIListLayout")({
                Padding = udNew(0, 6),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,

                [Fusion.Out("AbsoluteContentSize")] = self.friendsAbsContentSize,
            }),

            New(scope, "Frame")({
                Name = "AAA",
                Size = fromOffset(0, 1),
                BackgroundTransparency = 1
            }),

            Fusion.ForValues(scope, self.friends, function(_, localScope: table, info: table)
                local found, worldId = _checkIsInCS(info.PlaceId)

                if found then
                    info.IsInCS = true
                    info.LastLocation = `Exploring {worldId}`

                    return FriendSlot(info, self, localScope)
                end

                return nil
            end),
            Fusion.ForValues(scope, self.friends, function(_, localScope: table, info: table)
                local found = _checkIsInCS(info.PlaceId)

                if not found then
                    info.IsInCS = false
                    return FriendSlot(info, self, localScope)
                end

                return nil
            end),

            New(scope, "Frame")({
                Name = "ZZZ",
                Size = fromOffset(0, 1),
                BackgroundTransparency = 1
            })
        }
    }))

    return Components.Frame(scope, {
        Name = "FriendListFrame",
        Size = fromScale(0.6, 6),
        BackgroundTransparency = 0.5,

        Position = Fusion.Tween(scope, Computed(scope, function(use)
            return use(self.friendFramePos)
        end), AssetBook.TweenInfos.twiceHalfOne),
        Visible = Computed(scope, function(use)
            if use(self.isTeleporting) == true then return false
            else return use(self.friendListFrameVisible) end
        end),

        [Fusion.Out("AbsoluteSize")] = self.friendsAbsSize,

        [Children] = {
            New(scope, "UICorner")({ CornerRadius = udNew(0.05, 0) }),

            New(scope, "Frame")({
                Name = "TopBar",
                BackgroundColor3 = fromRGB(10, 10, 10),
                Size = fromScale(1, 0.15),

                [Children] = {
                    New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),

                    Components.TextLabel(scope, {
                        Name = "Title",
                        Size = fromScale(1, 1),
                        Text = "FRIENDS",

                        [Children] = {
                            New(scope, "UIPadding")({
                                PaddingBottom = udNew(0.15, 0),
                                PaddingTop = udNew(0.15, 0)
                            })
                        }
                    })
                }
            }),

            self.friendListFrame,

            New(scope, "Frame")({
                Name = "BottomBar",
                BackgroundColor3 = fromRGB(30, 30, 30),
                Position = fromScale(0, 0.88),
                Size = fromScale(1, 0.12),

                [Children] = {
                    New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
                    New(scope, "UIListLayout")({
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = udNew(0.012, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    }),

                    Components.TextBox(scope, {
                        Name = "CodeBox",
                        Position = fromScale(0.33, 0.7),
                        Size = fromScale(0.33, 0.7),
                        BackgroundTransparency = 0,
                        PlaceholderText = "PRIVATE CODE HERE",

                        Text = Computed(scope, function(use)
                            return upper(tostring(use(self.privateCode)))
                        end),

                        [Fusion.Out("Text")] = self.privateCode,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            New(scope, "UIPadding")({
                                PaddingBottom = udNew(0.05, 0),
                                PaddingTop = udNew(0.05, 0)
                            })
                        }
                    }),

                    FriendListFuncButton("CreatePrivate", self),
                    FriendListFuncButton("JoinPrivate", self),
                    FriendListFuncButton("JoinPublic", self)
                }
            }),

            Components.TextLabel(scope, {
                Name = "LoadingTip",
                AnchorPoint = v2New(0.5, 0.5),
                Position = fromScale(0.5, 0.5),
                Size = fromScale(1, 0.1),
                Text = "LOADING...",
                TextTransparency = 0.4,

                Visible = Computed(scope, function(use)
                    return if #use(self.friends) > 0 then false else true
                end)
            })
        }
    })
end

return FriendList
