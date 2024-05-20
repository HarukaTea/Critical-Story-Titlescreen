--!nocheck

local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local wait = task.wait

local function disableDefaultFreecam()
    repeat wait() until plr.PlayerGui:WaitForChild("Freecam", 999)

    plr.PlayerGui.Freecam:Destroy()
end
disableDefaultFreecam()