--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local OnEvent = Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new
local upper = string.upper

local function FuncButton(id: string, self: table) : TextButton
    local scope = self.scope :: table
    local isSelecting = Fusion.Value(scope, false)

    return Components.TextButton(scope, {
        Name = id.."Button",
        Size = fromScale(1, 1),
        Text = upper(id),

        [OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,
        [OnEvent("MouseButton1Click")] = function()
            workspace.Sounds.SFXs.Click:Play()

            Signals.CreateHint:Fire("Head to community dc server instead!")
        end,

        [Fusion.Children] = {
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Enabled = true,
                Thickness = 3,

                Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
                    return if use(isSelecting) then 0.3 else 1
                end), AssetBook.TweenInfos.twiceHalf)
            }),
            Fusion.New(scope, "UIPadding")({
                PaddingTop = udNew(0.05, 0),
                PaddingLeft = udNew(0.05, 0),
                PaddingRight = udNew(0.05, 0),
                PaddingBottom = udNew(0.05, 0),
            })
        }
    })
end

return FuncButton
