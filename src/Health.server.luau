--!nocheck

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local ServerUtil = require(SSS.Modules.Utils.ServerUtil)

local char = script.Parent :: Model
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait
local instanceNew = Instance.new

local function setup()
    repeat wait() until plr:GetAttribute("PlayerDataLoaded")

    char.Archivable = true
    char.Humanoid.WalkSpeed = 0

    ServerUtil:SetCollisionGroup(char, "Player")

    local folder = instanceNew("Folder")
    folder.Name = plr.Name
    folder.Parent = workspace.CharPlaces

    --- repeat wait until data is loaded
    plr:WaitForChild("PlayerData1", 999)
    plr:WaitForChild("PlayerData2", 999)
    plr:WaitForChild("PlayerData3", 999)

    local charHumanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
    local anim = instanceNew("Animation")
    anim.AnimationId = "rbxassetid://4937966609"

    for i = 1, 3 do
        local clonedChar = Players:CreateHumanoidModelFromDescription(charHumanoidDesc, Enum.HumanoidRigType.R6)

        clonedChar:PivotTo(workspace.CharPlaces["CharPart"..i].CFrame)
        clonedChar.Name = "Slot"..i
        clonedChar.Parent = folder
        clonedChar.Humanoid.Animator:LoadAnimation(anim):Play()
        clonedChar.Animate:Destroy()

        ServerUtil:EquipWeapon(clonedChar, true, plr["PlayerData"..i].Class.Value)
    end
end
setup()
