--!nocheck

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local HarukaLib = {}

--[[
	Convert a number to string with abbr, for example, `10000` -> `10K`
]]
function HarukaLib:NumberConvert(number: number, type: string) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = math.floor(math.floor(math.log10(number)) / 3)

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return string.format(type, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		end
	end

	return tostring(number)
end

--[[
	Get player's current device, may not accurate
]]
function HarukaLib:GetDevice() : "PC" | "Mobile" | "Console" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then device = "Console" end
	if UserInputService.TouchEnabled then device = "Mobile" end
	if UserInputService.VREnabled then device = "VR" end

	return device
end

--[[
	Get more accurate device, instead of a type
]]
function HarukaLib:GetAccurateDevice() : "PC" | "Tablet" | "Phone" | "Xbox" | "PlayStation" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then
		local key = Enum.KeyCode.ButtonA

		if UserInputService:GetStringForKeyCode(key) == "ButtonA" then device = "Xbox" end
		if UserInputService:GetStringForKeyCode(key) == "ButtonCross" then device = "PlayStation" end
	end
	if UserInputService.TouchEnabled then
		local screenSize = workspace.CurrentCamera.ViewportSize

		if screenSize.X < screenSize.Y then
			if screenSize.X < 600 then device = "Phone" else device = "Tablet" end

		elseif screenSize.X > screenSize.Y then
			if screenSize.Y < 600 then device = "Phone" else device = "Tablet" end
		end
	end
	if UserInputService.VREnabled then device = "VR" end

	return device
end

--[[
	A simple serializer for datastore
]]
function HarukaLib:Deserialize(val: table) : any
	if typeof(val) ~= "table" then return val end

	local valType = val[1] :: string

	if valType == "CFrame" then
		return CFrame.new(unpack(val, 2, #val))

	elseif valType == "Vector3" then
		return Vector3.new(unpack(val, 2, #val))

	elseif valType == "Color3" then
		return Color3.fromRGB(unpack(val, 2, #val))

	else
		return valType
	end
end

--[[
	A custom remade of `Bin`
]]
function HarukaLib.Bin()
	local bin = {}

	return function (item: any)
		bin[#bin + 1] = item

		return item

	end, function()
		for _, item: any in bin do
			if typeof(item) == "Instance" then
				item:Destroy()

			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()

			elseif typeof(item) == "function" then
				Spawn(item)

			elseif typeof(item) == "thread" then
				if item then task.cancel(item) end
			end
		end

		table.clear(bin)
	end
end

--[[
	A custom remade of `Clock`, provides a callback to disconnect
]]
function HarukaLib.Clock(tickTime: number, func: () -> ())
	local nowTime = 0
	local dropTime = tickTime * 10

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		nowTime += deltaTime

		if nowTime > dropTime then
			nowTime = 0
			func()

		elseif nowTime > tickTime then
			nowTime -= tickTime

			func()
		end
	end)

	return function ()
		connection:Disconnect()
	end
end

return HarukaLib
