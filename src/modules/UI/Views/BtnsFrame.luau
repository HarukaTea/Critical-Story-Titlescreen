--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local peek = Fusion.peek

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local udNew = UDim.new

local function BtnsFrame(self: table) : Frame
    local scope = self.scope :: table

    local backBtnHovering = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = "BtnsFrame",

        [Fusion.Children] = {
            Components.TextButton(scope, {
                Name = "BackBtn",
                AnchorPoint = v2New(0.5, 0),
                Size = fromScale(0.13, 0.6),
                Text = "BACK",
                Position = fromScale(0.5, -0.5),

                Visible = Fusion.Computed(scope, function(use)
                    return use(self.backBtnVisible)
                end),

                [Fusion.OnEvent("MouseEnter")] = function()
                    backBtnHovering:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    backBtnHovering:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    workspace.Sounds.SFXs.Click:Play()

                    if peek(self.currentUI) == "SaveSlot" and peek(self.isChoosingSaveSlot) then
                        for _, element: any in self.saveSlotVisible do element:set(true) end
                        for _, element: any in self.saveSlotEraseVisible do element:set(false) end

                        self.saveSlotPos[1]:set(fromScale(0.139, 0.5))
                        self.saveSlotPos[2]:set(fromScale(0.393, 0.5))
                        self.saveSlotPos[3]:set(fromScale(0.646, 0.5))

                        self.isChoosingSaveSlot:set(false)
                        self.friendFramePos:set(fromScale(1.5, -0.7))

                        self.currentUI:set("SaveSlot")

                    else
                        self.saveSlotBGPos:set(fromScale(-0.5, -0.7))
                        self.clickTipVisible:set(true)
                        self.backBtnVisible:set(false)
                        self.currentUI:set("Title")

                        local check = false
                        local clickDetect = UserInputService.InputBegan:Connect(function(input, gpe)
                            if gpe then return end

                            if input.UserInputType == Enum.UserInputType.MouseButton1 then check = true end
                        end)
                        repeat RunService.RenderStepped:Wait() until check

                        if clickDetect then clickDetect:Disconnect() end

                        workspace.Sounds.SFXs.Click:Play()

                        self.backBtnVisible:set(true)
                        self.saveSlotBGPos:set(fromScale(0.5, -0.7))
                        self.currentUI:set("SaveSlot")
                        self.clickTipVisible:set(false)
                    end
                end,

                [Fusion.Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Enabled = true,
                        Thickness = 3,

                        Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
                            return if use(backBtnHovering) then 0.3 else 1
                        end), AssetBook.TweenInfos.twiceHalf),
                    }),
                    Fusion.New(scope, "UIPadding")({
                        PaddingTop = udNew(0.05, 0),
                        PaddingLeft = udNew(0.05, 0),
                        PaddingRight = udNew(0.05, 0),
                        PaddingBottom = udNew(0.05, 0),
                    })
                }
            }),

            Components.ImageLabel(scope, {
                Name = "Logo",
                AnchorPoint = v2New(0.5, 0),
                Position = fromScale(0.925, -1.1),
                Size = fromScale(0.15, 1.75),
                Image = "rbxassetid://14404478139"
            })
        }
    })
end

return BtnsFrame
