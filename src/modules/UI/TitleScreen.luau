--!nocheck
--!optimize 2
--!native

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, New, Tween, Computed = Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed

local TitleScreenPinia = require(RepS.Modules.UI.Pinia.TitleScreenPinia)

local BtnsFrame = require(RepS.Modules.UI.Views.BtnsFrame)
local FriendListFrame = require(RepS.Modules.UI.Views.FriendList)

local SaveSlot = require(RepS.Modules.UI.Components.SaveSlot)

local TitleScreen = {}
TitleScreen.__index = TitleScreen
TitleScreen.__type = "TitleScreen"

local wait = task.wait
local v2New = Vector2.new
local fromScale = UDim2.fromScale
local cfNew = CFrame.new

return function(plr: Player)
	local self = setmetatable({}, TitleScreen)

	repeat wait() until plr:GetAttribute("PlayerDataLoaded1")
	repeat wait() until plr:GetAttribute("PlayerDataLoaded2")
	repeat wait() until plr:GetAttribute("PlayerDataLoaded3")

	self.plr = plr
	self.char = plr.Character or plr.CharacterAdded:Wait()

	TitleScreenPinia(self)

	local scope = self.scope :: table
	Components.ScreenGui(scope, {
		Name = "Titlescreen",
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.Frame(scope, {
				Name = "Bottom",
				AnchorPoint = v2New(0.5, 0.9),
				Size = fromScale(1, 0.1),

				Position = Tween(scope, Computed(scope, function(use)
					return use(self.bottomFramePos)
				end), AssetBook.TweenInfos.two),
				Visible = Computed(scope, function(use)
					return not use(self.isTeleporting)
				end),

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.129 }),

					BtnsFrame(self)
				}
			}),
			Components.Frame(scope, {
				Name = "Center",
				AnchorPoint = v2New(0.5, 0),
				Size = fromScale(1, 0.1),
				Position = fromScale(0.5, 0.5),

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.129 }),

					Components.TextLabel(scope, {
						Name = "Hint",
						AnchorPoint = v2New(0.5, 0.5),
						Position = fromScale(0.5, 0.5),
						Size = fromScale(1, 0.6),
						Text = "Travelling to Critical Worlds...",

						Visible = Computed(scope, function(use)
							return use(self.isTeleporting)
						end),

						[Children] = {
							Components.TextUIStroke(scope, { Thickness = 3 }),
							New(scope, "UITextSizeConstraint")({ MaxTextSize = 36 })
						}
					}),
					Components.Frame(scope, {
						Name = "SaveSlotsFrame",

						Visible = Computed(scope, function(use)
							return not use(self.isTeleporting)
						end),
						Position = Tween(scope, Computed(scope, function(use)
							return use(self.saveSlotBGPos)
						end), AssetBook.TweenInfos.oneHalf),

						[Children] = {
							SaveSlot(1, self),
							SaveSlot(2, self),
							SaveSlot(3, self)
						}
					}),

					FriendListFrame(self)
				}
			})
		},
	})

	--// Connections
	local function teleportFailed()
		self.isTeleporting:set(false)
	end
	Events.TeleportFailed:Connect(teleportFailed)

	--// Clear
	local function _onDead()
		self.Empty()

		Events.TeleportFailed:DisconnectAll()

		Fusion.doCleanup(self.scope)
	end
	self.char.Humanoid.Died:Once(_onDead)

	--// Setups
	wait(0.5)
	self.bottomFramePos:set(fromScale(0.5, 1))
	for i = 1, 3 do
		local charSelfViewSlot = Fusion.peek(self.charSelfViews[i]) :: ViewportFrame
		charSelfViewSlot.CurrentCamera = charSelfViewSlot:FindFirstChildOfClass("Camera")

		workspace.MapComponents.PlayerChars:WaitForChild(self.plr.Name, 999):WaitForChild("Slot"..i, 999)

		self.Add(RS.Heartbeat:Connect(function()
			if charSelfViewSlot:FindFirstChildOfClass("Model") then charSelfViewSlot:FindFirstChildOfClass("Model"):Destroy() end

			local clonedChar = workspace.MapComponents.PlayerChars[self.plr.Name]["Slot"..i]:Clone() :: Model
			local hrp = clonedChar.PrimaryPart
			charSelfViewSlot.CurrentCamera.CFrame = cfNew(hrp.Position + (hrp.CFrame.LookVector * 5), hrp.Position) * cfNew(0, -2, 0)

			clonedChar.Parent = charSelfViewSlot
		end))
	end
end
