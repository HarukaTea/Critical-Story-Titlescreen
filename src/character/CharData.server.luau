--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerUtil = require(ServerScriptService.Modules.Utils.ServerUtil)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local function setup()
    char.Archivable = true

    ServerUtil:SetCollisionGroup(char, "Player")

    repeat task.wait() until plr:GetAttribute("PlayerDataLoaded1")
    repeat task.wait() until plr:GetAttribute("PlayerDataLoaded2")
    repeat task.wait() until plr:GetAttribute("PlayerDataLoaded3")

    local container = Instance.new("Folder")
    container.Name = plr.Name
    container.Parent = workspace.MapComponents.PlayerChars

    local charHumanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
    for i = 1, 3 do
        local clonedChar = Players:CreateHumanoidModelFromDescription(charHumanoidDesc, Enum.HumanoidRigType.R6)

        clonedChar:PivotTo(workspace.MapComponents.SaveSlotLocators["Locator"..i].CFrame)
        clonedChar.Name = "Slot"..i
        clonedChar.PrimaryPart = clonedChar:WaitForChild("Humanoid", 999).RootPart

        ServerUtil:SetCollisionGroup(clonedChar, "ClonedCharacter")

        local cosmetic = plr:GetAttribute("DATA"..i.."Cosmetic") :: string
        local hasCosmetic = if not cosmetic or cosmetic == "None" then false else true
        if hasCosmetic then
            ServerUtil:EquipArmor(clonedChar, cosmetic)
        else
            ServerUtil:EquipWeapon(clonedChar, plr:GetAttribute("DATA"..i.."Class"))
        end

        clonedChar.Parent = container

        clonedChar:WaitForChild("Animate", 999):Destroy()
        clonedChar:WaitForChild("Humanoid", 999):LoadAnimation(ReplicatedStorage.Package.Animations.NPCIdle):Play()
    end
end
setup()
