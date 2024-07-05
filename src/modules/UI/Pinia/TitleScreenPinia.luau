--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local fromScale = UDim2.fromScale

local function TitleScreenPinia(self: table)
    self.scope = Fusion.scoped({})

    local function Value(val: any) : any
        return Fusion.Value(self.scope, val)
    end

    self.bottomFramePos = Value(fromScale(0.5, 1.5))

    self.currentUI = Value("Title")
    self.clickTipVisible = Value(true)

    self.backBtnVisible = Value(false)

    self.saveSlotBGPos = Value(fromScale(-0.5, -0.7))
    self.charSelfViews = { Value(), Value(), Value() }
    self.saveSlotPos = { Value(fromScale(0.139, 0.5)), Value(fromScale(0.393, 0.5)), Value(fromScale(0.646, 0.5)) }
    self.saveSlotVisible = { Value(true), Value(true), Value(true) }
    self.isChoosingSaveSlot = Value(false)
    self.slotChosen = "Slot1"
    self.saveSlotEraseVisible = { Value(false), Value(false), Value(false) }

    self.friendListFrame = Value()
    self.friendsRequestCD = false
    self.friendFramePos = Value(fromScale(1.5, -0.7))
    self.friends = Value({})
    self.friendsAbsContentSize, self.friendsAbsSize = Value(0), Value(0)
    self.privateCode = Value("")

    self.isTeleporting = Value(false)
end

return TitleScreenPinia
