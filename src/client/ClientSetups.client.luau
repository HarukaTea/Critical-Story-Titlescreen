--!nocheck

local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local function removeFreecam()
    plr.PlayerGui:WaitForChild("Freecam", 999)

    task.wait()
    plr.PlayerGui.Freecam:Destroy()
end
removeFreecam()
