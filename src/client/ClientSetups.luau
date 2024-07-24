--!nocheck

local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local function removeFreecam()
    plr.PlayerGui:WaitForChild("FreeCam", 999)

    task.wait()
    plr.PlayerGui.FreeCam:Destroy()
end
removeFreecam()
