--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Modules.Packages.Signal)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local HarukaLib = {}

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
	Play a cutscene camera using bezier curve
]]
function HarukaLib:PlayCutscene(pointsFolder: Folder | Model, duration: number)
	local camera = workspace.CurrentCamera
	local signal = Signal()

	--// Private
	local function _getCF(points: table, t: number) : CFrame
		local copy = { unpack(points) }

		local n = #copy
		for j = 1, n - 1 do
			for k = 1, n - j do
				copy[k] = copy[k]:Lerp(copy[k + 1], t)
			end
		end
		return copy[1]
	end

	--- sort points
	local points = {}
	local instances = pointsFolder:GetChildren()

	table.sort(instances, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	for _, point: BasePart in ipairs(instances) do
		table.insert(points, point.CFrame)
	end

	--- play
	camera.CameraType = Enum.CameraType.Scriptable

	local priority = Enum.RenderPriority.Camera.Value + 1
	local start = os.clock()
	local passedTime = 0

	local ok, _ = pcall(function()
		RunService:BindToRenderStep("HarukaCutscene", priority, function()
			passedTime = os.clock() - start

			if passedTime <= duration then
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = _getCF(points, passedTime / duration)
			else
				RunService:UnbindFromRenderStep("HarukaCutscene")

				signal:Fire("Completed")
				signal:Destroy()
			end
		end)
	end)
	if not ok then
		RunService:UnbindFromRenderStep("HarukaCutscene")

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = workspace:WaitForChild("MapComponents", 999).IntroCutscene["4"].CFrame

		signal:Fire("Completed")
		signal:Destroy()
	end

	return signal
end

return HarukaLib
