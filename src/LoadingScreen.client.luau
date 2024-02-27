--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local RF = game:GetService("ReplicatedFirst")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer

local wait, spawn, delay = task.wait, task.spawn, task.delay
local udNew, ud2New, fromOffset, fromScale = UDim.new, UDim2.new, UDim2.fromOffset, UDim2.fromScale
local newInstance, newTweenInfo = Instance.new, TweenInfo.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local cfNew = CFrame.new

local loadFinished = false

spawn(function()
    RF:RemoveDefaultLoadingScreen()
    SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    UIS.ModalEnabled = true

    local coreCall do
        local MAX_RETRIES = 9999

        function coreCall(method, ...)
            local result = {}
            for i = 1, MAX_RETRIES do
                result = { pcall(SG[method], SG, ...) }
                if result[1] then
                    break
                end
                RS.Stepped:Wait()
            end
            return unpack(result)
        end
    end
    coreCall('SetCore', 'ResetButtonCallback', false)
end)

--- create a default blackscreen before fusion loads
local ui = newInstance("ScreenGui")
ui.Name = "Temp"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.Parent = plr.PlayerGui

local bg = newInstance("Frame")
bg.BackgroundColor3 = fromRGB(30, 30, 30)
bg.Size = ud2New(1, 0, 1, 58)
bg.Position = fromOffset(0, -58)
bg.Parent = ui

--- center image
local imageCenter = newInstance("ImageLabel")
imageCenter.BackgroundTransparency = 1
imageCenter.Position = fromScale(0.449, 0.384)
imageCenter.Size = fromScale(0.1, 0.23)
imageCenter.ImageColor3 = fromRGB(129, 129, 129)
imageCenter.ImageTransparency = 0.8
imageCenter.Image = "rbxassetid://2970814599"
imageCenter.Parent = ui

local uiAspect = newInstance("UIAspectRatioConstraint")
uiAspect.AspectRatio = 1.002
uiAspect.Parent = imageCenter

local imageText = newInstance("TextLabel")
imageText.BackgroundTransparency = 1
imageText.Position = fromScale(0.85, -0.2)
imageText.Size = fromScale(0.6, 0.6)
imageText.Rotation = 10
imageText.Text = "?"
imageText.FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Bold)
imageText.TextColor3 = fromRGB(129, 129, 129)
imageText.TextTransparency = 0.7
imageText.Parent = imageCenter

--- loading text
local textLabel = newInstance("TextLabel")
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0, 0.811)
textLabel.Size = fromScale(1, 0.05)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = fromRGB(217, 193, 144)
textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
textLabel.Parent = bg

local textSizeConstraint = newInstance("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 28
textSizeConstraint.Parent = textLabel

--- loading progress bar
local bar = newInstance("Frame")
bar.AnchorPoint = v2New(0, 1)
bar.BackgroundColor3 = fromRGB(217, 193, 144)
bar.Position = fromScale(0, 0.89)
bar.Size = fromScale(0, 0.01)
bar.Parent = ui

--- classes
local classBG = newInstance("Frame")
classBG.AnchorPoint = v2New(0, 1)
classBG.BackgroundTransparency = 1
classBG.Position = fromScale(0, 0.98)
classBG.Size = fromScale(1, 0.96)
classBG.Parent = ui

local uiAspectClass = newInstance("UIAspectRatioConstraint")
uiAspectClass.AspectRatio = 38.342
uiAspectClass.Parent = classBG

local uiList = newInstance("UIListLayout")
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
    "rbxassetid://15875390788"
}
local classImages = {}
for index, class in classes do
    local image = newInstance("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = fromScale(0.026, 1)
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

delay(6, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is taking longer than expected..."
end)
delay(16, function()
    if loadFinished then return end

    textLabel.Text = "Adventure load failed...Datastore may be having issues right now..."

    wait(1)
    require(RepS.Modules.Data.Events).ErrorDataStore:Fire()
end)

--- wait until data loads
local halfTween, sixTween = newTweenInfo(0.5), newTweenInfo(6)
TS:Create(bar, sixTween, { Size = fromScale(0.6, 0.01) }):Play()

plr:WaitForChild("PlayerData1", 999)
plr:WaitForChild("PlayerData2", 999)
plr:WaitForChild("PlayerData3", 999)
textLabel.Text = "Travelling to Critical Dimensions..."

loadFinished = true
print("Load Finished")

local TitleScreen = require(RepS.Modules.UI.TitleScreen)(plr)
local Events = require(RepS.Modules.Data.Events)
local peek = require(RepS.Modules.Packages.Fusion).peek

local camera = workspace.CurrentCamera

wait(3)
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cfNew(-140.73, 98.19, -15.43, -0.325, -0.051, 0.944, -0, 0.998, 0.054, -0.945, 0.017, -0.324)
TS:Create(bar, halfTween, { Size = fromScale(1, 0.01), BackgroundTransparency = 1 }):Play()
TS:Create(textLabel, halfTween, { TextTransparency = 1 }):Play()
TS:Create(bg, halfTween, { BackgroundTransparency = 1 }):Play()
TS:Create(imageCenter, halfTween, { ImageTransparency = 1 }):Play()
TS:Create(imageText, halfTween, { TextTransparency = 1 }):Play()
for _, class in classImages do
    TS:Create(class, halfTween, { ImageTransparency = 1 }):Play()
end

wait(0.5)
workspace.Sounds.TitleScreen:Play()
ui:Destroy()

wait(0.5)
peek(TitleScreen.UI).Profile.Visible = true
TitleScreen.backTrans:set(0.7)
TitleScreen.logoPos:set(fromScale(0.295, 0.2))
TitleScreen.btnPos:set(fromScale(0.43, 0.8))

for _,child in peek(TitleScreen.saveSlotFrame):GetChildren() do
    if child:IsA("Frame") then
        child.CharacterVPF.CurrentCamera = child.CharacterVPF.Camera

        local clonedChar = workspace.CharPlaces:WaitForChild(plr.Name):WaitForChild(child.Name):Clone() :: Model
        local HRP = clonedChar.HumanoidRootPart :: Part

        child.CharacterVPF.Camera.CFrame = cfNew(HRP.Position + (HRP.CFrame.LookVector * 5), HRP.Position)
        clonedChar.Parent = child.CharacterVPF
    end
end

Events.TeleportFailed:Connect(function()
    for _, child in peek(TitleScreen.UI).Profile:GetChildren() do
        if child:IsA("GuiObject") then child.Visible = true end
    end
    peek(TitleScreen.teleportFrame).Visible = false
end)
