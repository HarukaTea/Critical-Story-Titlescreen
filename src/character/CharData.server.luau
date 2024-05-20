--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait
local instanceNew = Instance.new

local function setup()
    repeat wait() until plr:GetAttribute("PlayerDataLoaded1")
    repeat wait() until plr:GetAttribute("PlayerDataLoaded2")
    repeat wait() until plr:GetAttribute("PlayerDataLoaded3")

    char.Archivable = true

    ServerUtil:SetCollisionGroup(char, "Player")

    local container = instanceNew("Folder")
    container.Name = plr.Name
    container.Parent = workspace.MapComponents.PlayerChars

    local charHumanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
    for i = 1, 3 do
        local clonedChar = Players:CreateHumanoidModelFromDescription(charHumanoidDesc, Enum.HumanoidRigType.R6)

        clonedChar:PivotTo(workspace.MapComponents.SaveSlotLocators["Locator"..i].CFrame)
        clonedChar.Name = "Slot"..i

        ServerUtil:SetCollisionGroup(clonedChar, "ClonedCharacter")
        ServerUtil:EquipWeapon(clonedChar, plr:GetAttribute("DATA"..i.."Class"))

        clonedChar.Parent = container

        clonedChar.Animate:Destroy()
        clonedChar:WaitForChild("Humanoid"):LoadAnimation(RepS.Package.Idle):Play()
    end
end
setup()
