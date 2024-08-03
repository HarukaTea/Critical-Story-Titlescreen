--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local v2New = Vector2.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local function Padding(self: table, name: string) : Frame
    return New(self.scope, "Frame")({
        Name = name,
        Size = fromOffset(0, 1),
        BackgroundTransparency = 1
    })
end

local function WorldList(self: table) : Frame
    local scope = self.scope :: table

    return Components.Frame(scope, {
        Name = "WorldListFrame",
        Size = fromScale(0.6, 6),
        BackgroundTransparency = 0.5,
        Position = fromScale(0.65, -0.7),

        Visible = Computed(scope, function(use)
            if use(self.isTeleporting) == true then return false
            else return use(self.worldListFrameVisible) end
        end),

        [Fusion.Out("AbsoluteSize")] = self.worldListAbsSize,

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
                        Text = "WORLDS",

                        [Children] = {
                            New(scope, "UIPadding")({
                                PaddingBottom = udNew(0.15, 0),
                                PaddingTop = udNew(0.15, 0)
                            })
                        }
                    })
                }
            }),

            Components.ScrollingFrame(scope, {
                Name = "WorldList",
                AnchorPoint = v2New(),
                Position = fromScale(0, 0.15),
                Size = fromScale(1, 0.817),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                CanvasSize = Computed(scope, function(use)
                    return if use(self.worldListAbsContentSize).Y > use(self.worldListAbsSize).Y then fromOffset(0, use(self.worldListAbsContentSize).Y) else fromOffset(0, 0)
                end),
                ScrollingEnabled = Computed(scope, function(use)
                    return if use(self.worldListAbsContentSize).Y > use(self.worldListAbsSize).Y then true else false
                end),

                [Children] = {
                    New(scope, "UIListLayout")({
                        Padding = udNew(0, 6),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,

                        [Fusion.Out("AbsoluteContentSize")] = self.worldListAbsContentSize,
                    }),

                    Padding(self, "AAA"),

                    Fusion.ForPairs(scope, AssetBook.TeleportWorldInfo, function(_, localScope: Fusion.Scope, worldId: string, world: string)
                        local isSelecting = Fusion.Value(localScope, false)

                        return worldId, Components.Frame(localScope, {
                            Name = "B-WorldId-"..worldId,
                            Size = fromScale(0.98, 0.15),
                            BackgroundTransparency = 0,

                            [Children] = {
                                New(localScope, "UIAspectRatioConstraint")({ AspectRatio = 20.502 }),
                                Components.RoundUICorner(localScope),
                                Components.UIStroke(localScope, {
                                    Thickness = 2.5,
                                    Enabled = true,

                                    Transparency = Fusion.Tween(localScope, Fusion.Computed(localScope, function(use: Fusion.Use)
                                        return if use(isSelecting) then 0.3 else 1
                                    end), AssetBook.TweenInfos.twiceHalf)
                                }),

                                Components.HoverImageButton(localScope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        isSelecting:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        isSelecting:set(false)
                                    end
                                }),

                                Components.TextLabel(localScope, {
                                    Name = "WorldId",
                                    Size = fromScale(1, 1),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Text = world,

                                    [Children] = {
                                        New(localScope, "UIPadding")({
                                            PaddingBottom = udNew(0.17, 0),
                                            PaddingLeft = udNew(0.03, 0),
                                            PaddingRight = udNew(0.03, 0),
                                            PaddingTop = udNew(0.17, 0)
                                        })
                                    }
                                }),
                                Components.TextButton(localScope, {
                                    Name = "CreateBtn",
                                    AnchorPoint = v2New(0, 0.5),
                                    Size = fromScale(0.15, 0.7),
                                    BackgroundColor3 = fromRGB(0, 139, 208),
                                    Position = fromScale(0.835, 0.5),
                                    Text = "CREATE",

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        workspace.Sounds.SFXs.Click:Play()

                                        self.isTeleporting:set(true)

                                        Signals.CreateFullScreenHint:Fire("TRAVELLING TO CRITICAL WORLDS...", true)

                                        Events.TeleportPrompt.Fire({
                                            Option = "CreatePrivate",
                                            PrivateCode = worldId,
                                            SlotChosen = self.slotChosen
                                        })
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(localScope),
                                        New(localScope, "UIPadding")({
                                            PaddingTop = udNew(0.1, 0),
                                            PaddingBottom = udNew(0.1, 0)
                                        })
                                    }
                                })
                            }
                        })
                    end),

                    Padding(self, "ZZZ")
                }
            })
        }
    })
end

return WorldList
