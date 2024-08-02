--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
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

    local eraseStage = 1

    self.charSelfViews[index] = Fusion.Value(scope, New(scope, "ViewportFrame")({
        BackgroundTransparency = 1,
        Position = fromScale(0.076, 0.221),
        Size = fromScale(0.877, 0.583),

        Visible = Computed(scope, function(use: Fusion.Use)
            return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
        end),

        [Children] = {
            New(scope, "Camera")({})
        }
    }))

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

                Image = Computed(scope, function(use: Fusion.Use)
                    return AssetBook.Class[use(self.playerData["Slot"..index].Class) or ""]
                end),
                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
                end)
            }),
            Components.TextButton(scope, {
                Name = "Erase",
                Position = fromScale(0.676, 0.021),
                Size = fromScale(0.12, 0.092),
                Text = "X",
                BackgroundTransparency = 0,
                BackgroundColor3 = fromRGB(216, 72, 108),
                ZIndex = 5,

                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then use(self.saveSlotEraseVisible[index]) else false
                end),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    if eraseStage == 1 then
                        local action = HarukaLib:CreateConfirmPrompt(self.plr, "Are you sure you want to erase your data?"):Wait()

                        if action == "Confirmed" then
                            local action2 = HarukaLib:CreateConfirmPrompt(self.plr, "Are you <yellow>ABSOLUTELY</font> sure you want to erase your data?"):Wait()

                            if action2 == "Confirmed" then
                                eraseStage = 2

                                Signals.CreateHint:Fire("Erasing your data...")

                                Events.DataWipe.Fire({ SlotChosen = "Slot"..index })
                            end
                        end
                    end
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Levels",
                Position = fromScale(0, 0.13),
                Size = fromScale(1, 0.06),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(255, 255, 127),

                Text = Computed(scope, function(use: Fusion.Use)
                    return `Lv.{use(self.playerData["Slot"..index].Levels)}`
                end),
                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
                end),

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "PlayTime",
                Position = fromScale(0, 0.13),
                Size = fromScale(1, 0.06),
                TextXAlignment = Enum.TextXAlignment.Right,
                TextColor3 = fromRGB(255, 255, 127),

                Text = Computed(scope, function(use: Fusion.Use)
                    local formatedTime = format("%.2f", tostring(use(self.playerData["Slot"..index].PlayTime) / 3600) or 0)

                    return `{formatedTime} Hours`
                end),
                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
                end),

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "StoryProgress",
                Position = fromScale(0, 0.831),
                Size = fromScale(1, 0.06),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(170, 255, 255),

                Text = Computed(scope, function(use: Fusion.Use)
                    local progress = AssetBook.StorySeries[use(self.playerData["Slot"..index].StoryId)] or ""

                    return `Progress: {progress}`
                end),
                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
                end),

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "LastSeen",
                Position = fromScale(0, 0.9),
                Size = fromScale(1, 0.06),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = fromRGB(255, 170, 127),

                Text = Computed(scope, function(use: Fusion.Use)
                    local lastSeen = AssetBook.LocationInfo[use(self.playerData["Slot"..index].LastSeen)] or ""

                    return `Last Seen: {lastSeen}`
                end),
                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then true else false
                end),

                [Children] = { UIPadding(scope) }
            }),
            Components.TextLabel(scope, {
                Name = "Empty",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0, 0.5),
                Size = fromScale(1, 0.1),
                Text = "EMPTY",
                TextColor3 = fromRGB(136, 136, 136),

                Visible = Computed(scope, function(use: Fusion.Use)
                    return if use(self.playerData["Slot"..index].PlayTime) > 0 then false else true
                end)
            }),

            self.charSelfViews[index],

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
