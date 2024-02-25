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
local ud2New, fromOffset, fromScale = UDim2.new, UDim2.fromOffset, UDim2.fromScale
local newInstance, newColor3, newTweenInfo = Instance.new, Color3.new, TweenInfo.new
local fromHex = Color3.fromHex
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

local frame = newInstance("Frame")
frame.BackgroundColor3 = fromHex("#1e1e1e")
frame.Size = ud2New(1, 0, 1, 58)
frame.Position = fromOffset(0, -58)
frame.Parent = ui

local textLabel = newInstance("TextLabel")
textLabel.Text = "Loading Adventure..."
textLabel.Position = fromScale(0.02, 0.91)
textLabel.Size = fromScale(0.96, 0.05)
textLabel.BackgroundTransparency = 1
textLabel.TextScaled = true
textLabel.TextColor3 = newColor3(1, 1, 1)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
textLabel.Parent = frame

local textSizeConstraint = newInstance("UITextSizeConstraint")
textSizeConstraint.MaxTextSize = 32
textSizeConstraint.Parent = textLabel

delay(8, function()
    textLabel.Text = "Adventure is taking longer than expected..."
end)
delay(15, function()
    if loadFinished then return end

    require(RepS.Modules.HarukaFrameworkClient).Events.ErrorDataStore:Fire()
end)

--- wait until data loads
plr:WaitForChild("PlayerData1", 999)
plr:WaitForChild("PlayerData2", 999)
plr:WaitForChild("PlayerData3", 999)
textLabel.Text = "Travelling to Critical Dimensions..."

loadFinished = true
print("Load Finished")

local HarukaFrameworkClient = require(RepS:WaitForChild("Modules").HarukaFrameworkClient)
local TitleScreen = require(RepS.Modules.UI.TitleScreen)(plr)
local Events = HarukaFrameworkClient.Events
local peek = HarukaFrameworkClient.Fusion.peek

local camera = workspace.CurrentCamera

wait(3)
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cfNew(-164.18, 9.64, 37.89, 0, 0, 1, 0, 1, 0, -1, 0, 0)
TS:Create(frame, newTweenInfo(0.5), { BackgroundTransparency = 1 }):Play()

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
