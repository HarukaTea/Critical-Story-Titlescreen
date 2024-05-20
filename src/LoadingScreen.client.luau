--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RF = game:GetService("ReplicatedFirst")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer

local wait, delay = task.wait, task.delay
local udNew, fromScale = UDim.new, UDim2.fromScale
local instanceNew, tweenInfoNew = Instance.new, TweenInfo.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local fontFromName, fontFromEnum = Font.fromName, Font.fromEnum

local halfTween, sixTween = tweenInfoNew(0.5), tweenInfoNew(6)

local loadFinished = false

RF:RemoveDefaultLoadingScreen()
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

---// create a default blackscreen before fusion loads
local ui = instanceNew("ScreenGui")
ui.Name = "Loading"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 100
ui.Parent = plr.PlayerGui

local bg = instanceNew("Frame")
bg.Name = "BG"
bg.BackgroundColor3 = fromRGB(30, 30, 30)
bg.AnchorPoint = v2New(0.5, 0.5)
bg.Size = fromScale(1, 1)
bg.Position = fromScale(0.5, 0.5)
bg.Parent = ui

local bottomBG = instanceNew("Frame")
bottomBG.Name = "Bottom"
bottomBG.BackgroundTransparency = 1
bottomBG.AnchorPoint = v2New(0.5, 0.9)
bottomBG.Position = fromScale(0.5, 1)
bottomBG.Size = fromScale(1, 0.1)
bottomBG.Parent = bg

local uiAspect = instanceNew("UIAspectRatioConstraint")
uiAspect.AspectRatio = 25.129
uiAspect.Parent = bottomBG

--- loading progress bar
local bar = instanceNew("Frame")
bar.Name = "ProgressBar"
bar.BackgroundColor3 = fromRGB(217, 193, 144)
bar.Position = fromScale(0, -0.5)
bar.Size = fromScale(0, 0.1)
bar.Parent = bottomBG

--- loading text
local textLabel = instanceNew("TextLabel")
textLabel.Name = "ProgressText"
textLabel.Text = "Loading History..."
textLabel.Position = fromScale(0, -1.3)
textLabel.Size = fromScale(1, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = fromRGB(217, 193, 144)
textLabel.FontFace = fontFromName("Roboto", Enum.FontWeight.Bold)
textLabel.Parent = bottomBG

local textSizeConstraint = instanceNew("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 36
textSizeConstraint.Parent = textLabel

--- classes
local classBG = instanceNew("Frame")
classBG.AnchorPoint = v2New(0.5, 0)
classBG.BackgroundTransparency = 1
classBG.Position = fromScale(0.5, -0.2)
classBG.Size = fromScale(1, 0.75)
classBG.Parent = bottomBG

local uiList = instanceNew("UIListLayout")
uiList.Padding = udNew(0.003, 0)
uiList.FillDirection = Enum.FillDirection.Horizontal
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.Parent = classBG

local classes = {
    "rbxassetid://2965862892",
    "rbxassetid://2965863905",
    "rbxassetid://2965863231",
    "rbxassetid://2965863677",
    "rbxassetid://12284961892",
    "rbxassetid://12190533959",
    "rbxassetid://12190535870",
    "rbxassetid://12236618949",
    "rbxassetid://15875390788",
    "rbxassetid://16654290906"
}
local classImages = {}
for index, class in classes do
    local image = instanceNew("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = fromScale(1, 1)
    image.SizeConstraint = Enum.SizeConstraint.RelativeYY
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

delay(9, function()
    if loadFinished then return end

    textLabel.Text = "History is loading longer than expected..."
end)
delay(20, function()
    if loadFinished then return end

    textLabel.Text = "History is loading so hard with a high ping..."
end)

--- wait until data loads
TS:Create(bar, sixTween, { Size = fromScale(0.6, 0.1) }):Play()

repeat wait() until plr:GetAttribute("PlayerDataLoaded")

textLabel.Text = "History Loaded!"

loadFinished = true
print("Load Finished")

Debris:AddItem(ui, 0.5)
TS:Create(bar, halfTween, { Size = fromScale(1, 0.1), BackgroundTransparency = 1 }):Play()
TS:Create(textLabel, halfTween, { TextTransparency = 1 }):Play()
TS:Create(bg, halfTween, { BackgroundTransparency = 1 }):Play()
for _, class: ImageLabel in classImages do
    TS:Create(class, halfTween, { ImageTransparency = 1 }):Play()
end

--// Loading tip
local tempUI = instanceNew("ScreenGui")
tempUI.Name = "Temp"
tempUI.DisplayOrder = 100
tempUI.Parent = plr.PlayerGui

local hint = instanceNew("TextLabel")
hint.Name = "LoadingHint"
hint.AnchorPoint = v2New(0.5, 1)
hint.Position = fromScale(0.5, 0.9)
hint.BackgroundTransparency = 1
hint.Size = fromScale(1, 0.05)
hint.FontFace = fontFromEnum(Enum.Font.SourceSansBold)
hint.Text = "Transferring Data..."
hint.TextScaled = true
hint.TextColor3 = fromRGB(255, 255, 255)
hint.Parent = tempUI

local uiTextSizeLimit = instanceNew("UITextSizeConstraint")
uiTextSizeLimit.MaxTextSize = 35
uiTextSizeLimit.Parent = hint

local textStroke = instanceNew("UIStroke")
textStroke.Thickness = 3
textStroke.Transparency = 0.3
textStroke.Parent = hint
