--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local function FriendListFuncButton(id: string, self: table) : TextButton
    local scope = self.scope :: table

    local texts = {
        JoinPublic = "JOIN PUBLIC",
        JoinPrivate = "JOIN PRIVATE",
        CreatePrivate = "CREATE PRIVATE"
    }
    local colors = {
        JoinPublic = fromRGB(66, 132, 98),
        JoinPrivate = fromRGB(204, 136, 102),
        CreatePrivate = fromRGB(0, 118, 177)
    }
    return Components.TextButton(scope, {
        Name = id,
        Size = fromScale(0.2, 0.7),
        Text = texts[id],
        BackgroundColor3 = colors[id],

        [Fusion.OnEvent("MouseButton1Click")] = function()
            self.isTeleporting:set(true)

            Signals.CreateFullScreenHint:Fire("TRAVELLING TO CRITICAL WORLDS...", true)

            Events.TeleportPrompt.Fire({
                Option = id,
                PrivateCode = Fusion.peek(self.privateCode),
                SlotChosen = self.slotChosen
            })

            workspace.Sounds.SFXs.Click:Play()
        end,

        [Fusion.Children] = {
            Components.RoundUICorner(scope),
            Fusion.New(scope, "UIPadding")({
                PaddingBottom = udNew(0.1, 0),
                PaddingTop = udNew(0.1, 0)
            })
        }
    })
end

return FriendListFuncButton
