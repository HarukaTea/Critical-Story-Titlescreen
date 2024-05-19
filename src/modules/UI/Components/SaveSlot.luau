--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Computed = Fusion.Children, Fusion.New, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new
local format = string.format
local wait = task.wait
local fromRGB = Color3.fromRGB

local function UIPadding(scope: table) : UIPadding
    return New(scope, "UIPadding")({
        PaddingLeft = udNew(0.07, 0),
        PaddingRight = udNew(0.07, 0)
    })
end

local function SaveSlot(index: number, self: table) : Frame
    local scope = self.scope :: table
    local plr = self.plr :: Player

    local eraseConfirmed = 10

    return Components.Frame(scope, {
        Name = "SaveSlot"..index,
        AnchorPoint = v2New(0, 0.5),
        Size = fromScale(0.214, 7),
        BackgroundTransparency = 0,

        Position = Fusion.Tween(scope, Computed(scope, function(use)
            return use(self.saveSlotPos[index])
        end), AssetBook.TweenInfos.twiceHalfOne),
        Visible = Computed(scope, function(use)
            return use(self.saveSlotVisible[index])
        end),

        [Children] = {
            New(scope, "UICorner")({ CornerRadius = udNew(0.03, 0) }),
            Components.UIStroke(scope, {
                Thickness = 3,
                Enabled = true
            }),

            Components.TextLabel(scope, {
                Name = "File",
                Position = fromScale(0, 0.02),
                Size = fromScale(1, 0.1),
                Text = "File #"..index,
                TextXAlignment = Enum.TextXAlignment.Left,

                [Children] = { UIPadding(scope) }
            }),
            Components.ImageLabel(scope, {
                Name = "Class",
                Position = fromScale(0.825, 0.018),
                Size = fromScale(0.128, 0.1),
                Image = AssetBook.Class[plr:GetAttribute("DATA"..index.."Class")],

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false
            }),
            Components.TextButton(scope, {
                Name = "Erase",
                Position = fromScale(0.676, 0.021),
                Size = fromScale(0.12, 0.092),
                Text = "X",
                BackgroundTransparency = 0,
                BackgroundColor3 = fromRGB(216, 72, 108),
                ZIndex = 5,

                Visible = Computed(scope, function(use)
                    return if plr:GetAttribute("DATA"..index.."PlayTime") <= 0 then false else use(self.saveSlotEraseVisible[index])
                end),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    if eraseConfirmed > 0 then
                        eraseConfirmed -= 1

                        Signals.CreateHint:Fire("Click "..eraseConfirmed.." times more to confirm your action!")
                        return
                    else
                        Signals.CreateHint:Fire("Erasing your data...")

                        wait(1)
                        Events.DataWipe:Fire("Slot"..index)
                    end
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Levels",
                Position = fromScale(0, 0.13),
                Size = fromScale(1, 0.06),
                Text = "Lv."..plr:GetAttribute("DATA"..index.."Levels"),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(255, 255, 127),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false,

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "PlayTime",
                Position = fromScale(0, 0.13),
                Size = fromScale(1, 0.06),
                Text = format("%.1f", tostring(plr:GetAttribute("DATA"..index.."PlayTime") / 3600)).." Hours",
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = fromRGB(255, 255, 127),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false,

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "StoryProgress",
                Position = fromScale(0, 0.831),
                Size = fromScale(1, 0.06),
                Text = "Progress: "..AssetBook.StorySeries[plr:GetAttribute("DATA"..index.."StoryId")],
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(170, 255, 255),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false,

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "LastSeen",
                Position = fromScale(0, 0.9),
                Size = fromScale(1, 0.06),
                Text = "Last Seen: "..AssetBook.LocationInfo[plr:GetAttribute("DATA"..index.."LastSeenLocation")],
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(255, 170, 127),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false,

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Empty",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0, 0.5),
                Size = fromScale(1, 0.1),
                Text = "EMPTY",
                TextColor3 = fromRGB(136, 136, 136),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then false else true,
            }),

            New(scope, "ViewportFrame")({
                BackgroundTransparency = 1,
                Position = fromScale(0.076, 0.221),
                Size = fromScale(0.877, 0.583),

                Visible = if plr:GetAttribute("DATA"..index.."PlayTime") > 0 then true else false,

                [Fusion.Ref] = self.charSelfViews[index],

                [Children] = {
                    New(scope, "Camera")({})
                }
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    self.saveSlotPos[index]:set(fromScale(0.1, 0.5))

                    for _, element: any in self.saveSlotVisible do element:set(false) end
                    for _, element: any in self.saveSlotEraseVisible do element:set(false) end
                    self.saveSlotVisible[index]:set(true)
                    self.saveSlotEraseVisible[index]:set(true)

                    self.isChoosingSaveSlot:set(true)
                    self.friendFramePos:set(fromScale(0.65, -0.7))
                    self.slotChosen = "Slot"..index

                    if not self.friendsRequestCD then
                        self.friendsRequestCD = true

                        pcall(function()
                            self.friends:set(self.plr:GetFriendsOnline())
                        end)

                        Spawn(function()
                            for _, element: Frame in Fusion.peek(self.friendListFrame):GetChildren() do
                                if not element:GetAttribute("Friend") then continue end

                                Spawn(function()
                                    element.Avatar.Image = Players:GetUserThumbnailAsync(element:GetAttribute("UserId"), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                                end)
                            end
                        end)

                        wait(31)
                        self.friendsRequestCD = false
                    end
                end
            })
        }
    })
end

return SaveSlot
