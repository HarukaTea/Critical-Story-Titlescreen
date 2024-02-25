--!nocheck

local Players = game:GetService("Players")

local ServerUtil = require(game:GetService("ServerScriptService").Modules.HarukaFrameworkServer).ServerUtil

local CharacterSetups = {}
CharacterSetups.__index = CharacterSetups

local wait = task.wait
local instanceNew = Instance.new

--[[
    Actions when character spawns, apply attributes for UIs to use
]]
function CharacterSetups:Setup()
    local plr = self.plr :: Player

    self.char.Archivable = true
    self.humanoid.WalkSpeed = 0

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
        ServerUtil:EquipCosmetics(clonedChar, plr["PlayerData"..i].Cosmetic.Value)
    end
end

return function (char: Model)
    local self = setmetatable({}, CharacterSetups)

    self.char = char
    self.plr = Players:GetPlayerFromCharacter(char)
    self.humanoid = char:WaitForChild("Humanoid") :: Humanoid

    repeat wait() until self.plr:GetAttribute("PlayerDataLoaded")

    self:Setup()
end