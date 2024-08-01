--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Components = require(RepS.Modules.UI.Vanilla)

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signal = require(RepS.Modules.Packages.Signal)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children = Fusion.Children

local HarukaLib = {}


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


function HarukaLib:Hydrate(obj: Instance, props: table)
	local Add, Empty = HarukaLib.Bin()

	for prop, func in props do
		if string.find(prop, "Attr") then
			local _, endPos = string.find(prop, "Attr")
			local attr = string.sub(prop, endPos + 2)

			func(obj:GetAttribute(attr))

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif string.find(prop, "Prop") then
			local _, endPos = string.find(prop, "Prop")
			local propName = string.sub(prop, endPos + 2)

			func(obj[propName])

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	return Empty
end


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


function HarukaLib:PlayCutscene(pointsFolder: Folder | Model, duration: number)
	local camera = workspace.CurrentCamera
	local signal = Signal.new()

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

	pcall(function()
		RunService:BindToRenderStep("HarukaCutscene", priority, function()
			passedTime = os.clock() - start

			if passedTime <= duration then
				camera.CFrame = _getCF(points, passedTime / duration)
			else
				RunService:UnbindFromRenderStep("HarukaCutscene")

				signal:Fire("Completed")
				signal:Destroy()
			end
		end)
	end)

	return signal
end


function HarukaLib:RichTextify(text: string) : string
	local colorList = {
		["<blue>"] = [[<font color="#70a1ff">]],
		["<purple>"] = [[<font color="#5352ed">]],
		["<red>"] = [[<font color="#ff4757">]],
		["<orange>"] = [[<font color="#ffa502">]],
		["<yellow>"] = [[<font color="#ffda79">]],
		["<green>"] = [[<font color="#7bed9f">]],
	}

	for oriTag: string, rbxColorTag: string in colorList do
		text = string.gsub(text, oriTag, rbxColorTag)
	end

	return text
end


function HarukaLib:CreateConfirmPrompt(plr: Player, hint: string)
	local scope = Fusion.scoped({})
	local signal = Signal.new()

	local initialTrans = Fusion.Value(scope, 1)
	local initialSize = Fusion.Value(scope, UDim2.fromScale(1, 0))
	local absTextBGSize = Fusion.Value(scope, Vector2.new())

	Components.ScreenGui(scope, {
		Name = "ConfirmUI",
		DisplayOrder = 100,
		Parent = plr:FindFirstChildOfClass("PlayerGui"),

		[Children] = {
			Components.Frame(scope, {
				Name = "BG",
				BackgroundTransparency = 0,

				Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
					return use(initialSize)
				end), AssetBook.TweenInfos.fourHalf),

				[Children] = {
					Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 8.365 }),
					Components.UIStroke(scope, {
						Thickness = 3,
						Enabled = true
					}),

					Components.TextLabel(scope, {
						Name = "Hint",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.1),
						Size = UDim2.fromScale(0.5, 0.4),
						TextScaled = false,
						TextWrapped = true,
						Text = HarukaLib:RichTextify(hint),
						RichText = true,

						TextSize = Fusion.Computed(scope, function(use: Fusion.Use)
							return math.ceil(use(absTextBGSize).Y / 2.47)
						end),

						[Fusion.Out("AbsoluteSize")] = absTextBGSize,
					}),
					Components.Frame(scope, {
						Name = "BtnsFrame",
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.672),
						Size = UDim2.fromScale(0.5, 0.186),

						[Children] = {
							Fusion.New(scope, "UIListLayout")({
								Padding = UDim.new(0.03, 0),
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
							}),

							Components.TextButton(scope, {
								Name = "ConfirmBtn",
								BackgroundColor3 = Color3.new(1, 1, 1),
								Size = UDim2.fromScale(0.35, 1),
								Text = "CONFIRM",
								TextColor3 = Color3.new(),

								[Fusion.OnEvent("MouseButton1Click")] = function()
									workspace.Sounds.SFXs.Click:Play()

									signal:Fire("Confirmed")
								end,

								[Children] = {
									Components.RoundUICorner(scope),
									Fusion.New(scope, "UIPadding")({
										PaddingBottom = UDim.new(0.05, 0),
										PaddingTop = UDim.new(0.05, 0)
									})
								}
							}),
							Components.TextButton(scope, {
								Name = "CancelBtn",
								BackgroundColor3 = Color3.new(),
								Size = UDim2.fromScale(0.35, 1),
								Text = "CANCEL",

								[Fusion.OnEvent("MouseButton1Click")] = function()
									workspace.Sounds.SFXs.Click:Play()

									signal:Fire("Canceled")
								end,

								[Children] = {
									Components.RoundUICorner(scope),
									Components.UIStroke(scope, {
										Thickness = 2.5,
										Enabled = true
									}),
									Fusion.New(scope, "UIPadding")({
										PaddingBottom = UDim.new(0.05, 0),
										PaddingTop = UDim.new(0.05, 0)
									})
								}
							}),
						}
					})
				}
			}),
			Components.Frame(scope, {
				Name = "GlobalShadows",
				ZIndex = 0,
				Active = true,

				BackgroundTransparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
					return use(initialTrans)
				end), AssetBook.TweenInfos.onceHalf)
			})
		}
	})

	initialSize:set(UDim2.fromScale(1, 0.3))
	initialTrans:set(0.3)

	--// clear on close
	signal:Once(function()
		Fusion.doCleanup(scope)

		signal:Destroy()
	end)

	return signal
end

return HarukaLib
