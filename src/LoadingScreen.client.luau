--!nocheck
--!optimize 2
--!native

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local RF = game:GetService("ReplicatedFirst")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer

local wait, spawn, delay = task.wait, task.spawn, task.delay
local udNew, fromScale = UDim.new, UDim2.fromScale
local newInstance, newTweenInfo = Instance.new, TweenInfo.new
local fromRGB = Color3.fromRGB
local v2New = Vector2.new
local cfNew = CFrame.new
local fontFromName = Font.fromName

local halfTween, sixTween = newTweenInfo(0.5), newTweenInfo(6)

local loadFinished = false

RF:RemoveDefaultLoadingScreen()
SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

--// Disable reset button
spawn(function()
    UIS.ModalEnabled = true

    local coreCall do
        local MAX_RETRIES = 99999

        function coreCall(method, ...)
            local result = {}
            for _ = 1, MAX_RETRIES do
                result = { pcall(SG[method], SG, ...) }
                if result[1] then break end
                RS.Stepped:Wait()
            end
            return unpack(result)
        end
    end
    coreCall("SetCore", "ResetButtonCallback", false)
end)

---// create a default blackscreen before fusion loads
local ui = newInstance("ScreenGui")
ui.Name = "Loading"
ui.ScreenInsets = Enum.ScreenInsets.None
ui.ClipToDeviceSafeArea = false
ui.DisplayOrder = 100
ui.Parent = plr.PlayerGui

local bg = newInstance("Frame")
bg.Name = "BG"
bg.BackgroundColor3 = fromRGB(30, 30, 30)
bg.AnchorPoint = v2New(0.5, 0.5)
bg.Size = fromScale(1, 1)
bg.Position = fromScale(0.5, 0.5)
bg.Parent = ui

local bottomBG = newInstance("Frame")
bottomBG.Name = "Bottom"
bottomBG.BackgroundTransparency = 1
bottomBG.AnchorPoint = v2New(0.5, 0.9)
bottomBG.Position = fromScale(0.5, 1)
bottomBG.Size = fromScale(1, 0.1)
bottomBG.Parent = bg

local uiAspect = newInstance("UIAspectRatioConstraint")
uiAspect.AspectRatio = 25.129
uiAspect.Parent = bottomBG

--- loading progress bar
local bar = newInstance("Frame")
bar.Name = "ProgressBar"
bar.BackgroundColor3 = fromRGB(217, 193, 144)
bar.Position = fromScale(0, -0.5)
bar.Size = fromScale(0, 0.1)
bar.Parent = bottomBG

--- loading text
local textLabel = newInstance("TextLabel")
textLabel.Name = "ProgressText"
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0, -1.3)
textLabel.Size = fromScale(1, 0.5)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = fromRGB(217, 193, 144)
textLabel.FontFace = fontFromName("Roboto", Enum.FontWeight.Bold)
textLabel.Parent = bottomBG

local textSizeConstraint = newInstance("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 36
textSizeConstraint.Parent = textLabel

--- classes
local classBG = newInstance("Frame")
classBG.AnchorPoint = v2New(0.5, 0)
classBG.BackgroundTransparency = 1
classBG.Position = fromScale(0.5, -0.2)
classBG.Size = fromScale(1, 0.75)
classBG.Parent = bottomBG

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
    "rbxassetid://15875390788",
    "rbxassetid://16654290906"
}
local classImages = {}
for index, class in classes do
    local image = newInstance("ImageLabel")
    image.BackgroundTransparency = 1
    image.Size = fromScale(1, 1)
    image.SizeConstraint = Enum.SizeConstraint.RelativeYY
    image.Image = class
    image.Parent = classBG

    classImages[index] = image
end

delay(9, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is taking longer than expected..."
end)
delay(20, function()
    if loadFinished then return end

    textLabel.Text = "Adventure is loading so hard with a high ping..."
end)

--- wait until data loads
TS:Create(bar, sixTween, { Size = fromScale(0.6, 0.1) }):Play()

repeat wait() until plr:GetAttribute("PlayerDataLoaded1")
repeat wait() until plr:GetAttribute("PlayerDataLoaded2")
repeat wait() until plr:GetAttribute("PlayerDataLoaded3")

textLabel.Text = "Adventure Data Loaded!"

loadFinished = true
print("Load Finished")

workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame = cfNew(-127.7, 82.6, -11.1, -0.2, 0, 0.9, 0, 0.9, 0, -0.9, 0, -0.2)
TS:Create(bar, halfTween, { Size = fromScale(1, 0.1), BackgroundTransparency = 1 }):Play()
TS:Create(textLabel, halfTween, { TextTransparency = 1 }):Play()
TS:Create(bg, halfTween, { BackgroundTransparency = 1 }):Play()
for _, class: ImageLabel in classImages do
    TS:Create(class, halfTween, { ImageTransparency = 1 }):Play()
end

wait(0.5)
workspace.Sounds.TitleScreen:Play()
ui:Destroy()
