--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer

local loadFinished = false

ReplicatedFirst:RemoveDefaultLoadingScreen()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
UserInputService.ModalEnabled = true

---// create a default blackscreen before fusion loads
local ui = Instance.new("ScreenGui")
ui.Name = "Loading"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 100
ui.Parent = plr.PlayerGui

local bg = Instance.new("Frame")
bg.Name = "BG"
bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bg.AnchorPoint = Vector2.new(0.5, 0.5)
bg.Size = UDim2.fromScale(1, 1)
bg.Position = UDim2.fromScale(0.5, 0.5)
bg.Parent = ui

local bottomBG = Instance.new("Frame")
bottomBG.Name = "Bottom"
bottomBG.BackgroundTransparency = 1
bottomBG.AnchorPoint = Vector2.new(0.5, 0.9)
bottomBG.Position = UDim2.fromScale(0.5, 1)
bottomBG.Size = UDim2.fromScale(1, 0.1)
bottomBG.Parent = bg

local uiAspect = Instance.new("UIAspectRatioConstraint")
uiAspect.AspectRatio = 25.129
uiAspect.Parent = bottomBG

--- loading progress bar
local bar = Instance.new("Frame")
bar.Name = "ProgressBar"
bar.BackgroundColor3 = Color3.fromRGB(217, 193, 144)
bar.Position = UDim2.fromScale(0, -0.5)
bar.Size = UDim2.fromScale(0, 0.1)
bar.Parent = bottomBG

--- loading text
local textLabel = Instance.new("TextLabel")
textLabel.Name = "ProgressText"
textLabel.Text = "Loading Adventure..."
textLabel.Position = UDim2.fromScale(0, -1.3)
textLabel.Size = UDim2.fromScale(1, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = Color3.fromRGB(217, 193, 144)
textLabel.FontFace = Font.fromName("Roboto", Enum.FontWeight.Bold)
textLabel.Parent = bottomBG

local textSizeConstraint = Instance.new("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 36
textSizeConstraint.Parent = textLabel

--- classes
local classBG = Instance.new("Frame")
classBG.AnchorPoint = Vector2.new(0.5, 0)
classBG.BackgroundTransparency = 1
classBG.Position = UDim2.fromScale(0.5, -0.2)
classBG.Size = UDim2.fromScale(1, 0.75)
classBG.Parent = bottomBG

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0.003, 0)
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
    "rbxassetid://16654290906",
    "rbxassetid://17667241921"
}
local classImages = {}
for index, class in classes do
    local image = Instance.new("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = UDim2.fromScale(1, 1)
    image.SizeConstraint = Enum.SizeConstraint.RelativeYY
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

task.delay(9, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is taking longer than expected..."
end)
task.delay(20, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is loading so hard with a high ping..."
end)

--- wait until data loads
TweenService:Create(bar, TweenInfo.new(6), { Size = UDim2.fromScale(0.6, 0.1) }):Play()

repeat RunService.Heartbeat:Wait() until plr:GetAttribute("PlayerDataLoaded1")
repeat RunService.Heartbeat:Wait() until plr:GetAttribute("PlayerDataLoaded2")
repeat RunService.Heartbeat:Wait() until plr:GetAttribute("PlayerDataLoaded3")

textLabel.Text = "Adventure Data Loaded!"

loadFinished = true
print("Load Finished")

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame = CFrame.new(-127.7, 82.6, -11.1, -0.2, 0, 0.9, 0, 0.9, 0, -0.9, 0, -0.2)

--- fade out
local halfTween = TweenInfo.new(0.5)

TweenService:Create(bar, halfTween, { Size = UDim2.fromScale(1, 0.1), BackgroundTransparency = 1 }):Play()
TweenService:Create(textLabel, halfTween, { TextTransparency = 1 }):Play()
TweenService:Create(bg, halfTween, { BackgroundTransparency = 1 }):Play()
for _, class: ImageLabel in classImages do
    TweenService:Create(class, halfTween, { ImageTransparency = 1 }):Play()
end
Debris:AddItem(ui, 0.5)

workspace.Sounds.TitleScreen:Play()
