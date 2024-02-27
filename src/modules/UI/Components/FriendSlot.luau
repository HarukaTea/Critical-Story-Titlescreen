--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, peek = Fusion.Children, Fusion.peek

local fromScale = UDim2.fromScale
local tFind = table.find
local fromRGB = Color3.fromRGB

local STATUS = {
    InGame = { 1, 4, 5 },
    Online = { 0, 2 },
    Studio = { 3, 6 }
}

local function FriendSlot(friend: Player, self: table) : Frame
    return Components.Frame({
        BackgroundTransparency = 0,
        Name = if tFind(STATUS.InGame, friend.LocationType)
            then "B-InGame"
            elseif tFind(STATUS.Online, friend.LocationType) then "C-Online"
            elseif tFind(STATUS.Studio, friend.LocationType) then "D-Studio"
            else "Undefined",
        Size = fromScale(0.96, 0.263),
        [Fusion.Attribute("Player")] = friend.VisitorId,

        [Children] = {
            Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 8.415 }),
            Fusion.New("UICorner")({}),

            Components.ImageLabel({
                Name = "Avatar",
                BackgroundTransparency = 0,
                Position = fromScale(0.025, 0.092),
                Size = fromScale(0.095, 0.797),

                [Children] = {
                    Components.RoundUICorner(),
                    Components.ImageLabel({
                        Name = "Status",
                        BackgroundTransparency = 0,
                        Position = fromScale(0.694, 0.694),
                        Size = fromScale(0.3, 0.3),
                        BackgroundColor3 = AssetBook.friendsStatusColors[friend.LocationType],

                        [Children] = { Components.RoundUICorner() },
                    }),
                },
            }),
            Components.TextLabel({
                Name = "PlayerName",
                Position = fromScale(0.148, 0.208),
                Size = fromScale(0.724, 0.316),
                RichText = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = if friend.UserName == friend.DisplayName
                    then friend.UserName
                    else friend.DisplayName
                        .. " <font color='#999'>(@"
                        .. friend.UserName
                        .. ")</font>",
            }),
            Components.TextLabel({
                Name = "PlayerStatus",
                Position = fromScale(0.148, 0.51),
                Size = fromScale(0.724, 0.276),
                Text = friend.LastLocation,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = AssetBook.friendsStatusColors[friend.LocationType],
            }),
            Components.TextButton({
                BackgroundColor3 = fromRGB(59, 118, 87),
                Name = "JoinBtn",
                Visible = if friend.PlaceId == 12343565896 then true else false,
                Position = fromScale(0.81, 0.355),
                Size = fromScale(0.166, 0.287),
                Text = "Join",

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    for _, child in peek(self.UI).Profile:GetChildren() do
                        if child:IsA("GuiObject") then child.Visible = false end
                    end

                    workspace.Sounds.SFXs.Click:Play()
                    peek(self.teleportFrame).Visible = true

                    Events.TeleportPrompt:Fire("JoinFriend", friend.VisitorId, peek(self.slotChosen))
                end,

                [Children] = { Components.RoundUICorner() }
            }),
        },
    })
end

return FriendSlot
