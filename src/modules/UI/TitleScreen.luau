--!nocheck

local ContextActionService = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AssetBook = require(RepS.Modules.Data.AssetBook)
local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local Spawn = require(RepS.Modules.Packages.Spawn)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New, Tween, Computed = Fusion.Children, Fusion.New, Fusion.Tween, Fusion.Computed

local TitleScreenPinia = require(RepS.Modules.UI.Pinia.TitleScreenPinia)

local BtnsFrame = require(RepS.Modules.UI.Views.BtnsFrame)
local FriendListFrame = require(RepS.Modules.UI.Views.FriendList)
local WorldListFrame = require(RepS.Modules.UI.Views.WorldList)

local SaveSlot = require(RepS.Modules.UI.Components.SaveSlot)

local TitleScreen = {}
TitleScreen.__index = TitleScreen

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
	local isSelecting = Fusion.Value(scope, false)

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
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.627 }),

					BtnsFrame(self),

					Components.Frame(scope, {
						Name = "TipBG",
						Position = fromScale(0.5, 0),
						Size = fromScale(0.5, 0.5),
						BackgroundTransparency = 0,

						[Children] = {
							New(scope, "UIGradient")({
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
								}),

								Transparency = Tween(scope, Computed(scope, function(use)
									return if use(self.clickTipVisible) then
										NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(0.5, 0),
											NumberSequenceKeypoint.new(1, 1),
										})
									else NumberSequence.new(1, 1)
								end), AssetBook.TweenInfos.twiceHalf),
							}),

							Components.TextLabel(scope, {
								Name = "Tip",
								FontFace = Font.new(
									"rbxasset://fonts/families/GothamSSm.json",
									Enum.FontWeight.Bold,
									Enum.FontStyle.Normal
								),
								Text = "Click anywhere to continue...",
								Size = fromScale(1, 1),

								TextTransparency = Tween(scope, Computed(scope, function(use)
									return if use(self.clickTipVisible) then 0 else 1
								end), AssetBook.TweenInfos.twiceHalf),

								[Children] = {
									New(scope, "UIPadding")({
										Name = "UIPadding",
										PaddingBottom = UDim.new(0.15, 0),
										PaddingTop = UDim.new(0.15, 0),
									}),
								},
							}),
						},
					}),
					Components.TextButton(scope, {
						Name = "DataTransferBtn",
						Position = fromScale(0.02, -0.537),
						Size = fromScale(0.185, 0.592),
						Text = "DATA TRANSFER",

						Visible = Computed(scope, function(use: Fusion.Use)
							return use(self.backBtnVisible)
						end),

						[Fusion.OnEvent("MouseEnter")] = function()
							isSelecting:set(true)
						end,
						[Fusion.OnEvent("MouseLeave")] = function()
							isSelecting:set(false)
						end,
						[Fusion.OnEvent("MouseButton1Click")] = function()
							workspace.Sounds.SFXs.Click:Play()

							local action = HarukaLib:CreateConfirmPrompt(
								plr,
								[[<yellow>NOTE:</font> This will teleport you to LEGACY. Be aware that you <yellow>CAN ONLY TRANSFER</font> your play time, doing so will <yellow>OVERRIDE</font> your current progress.]]
							):Wait()

							if action == "Confirmed" then
								self.isTeleporting:set(true)

								Signals.CreateFullScreenHint:Fire("TELEPORTING TO LEGACY PLACE...", true)

								Events.DataTransfer.Fire({})
							end
						end,

						[Children] = {
							Components.RoundUICorner(scope),
							Components.UIStroke(scope, {
								Thickness = 3,
								Enabled = true,

								Transparency = Tween(scope, Computed(scope, function(use: Fusion.Use)
									return if use(isSelecting) then 0.3 else 1
								end), AssetBook.TweenInfos.twiceHalf)
							}),
							Fusion.New(scope, "UIPadding")({
								PaddingBottom = UDim.new(0.07, 0),
								PaddingTop = UDim.new(0.07, 0),
							})
						}
					}),

					Components.TextLabel(scope, {
						Name = "MapCredits",
						Position = fromScale(0, 0.4),
						Size = fromScale(1, 0.3),
						FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
						Text = "Map by MaxingPar - Ascension To Heaven",
						TextXAlignment = Enum.TextXAlignment.Left,

						[Children] = {
							New(scope, "UIPadding")({ PaddingLeft = UDim.new(0.01, 0) }),
							New(scope, "UITextSizeConstraint")({ MaxTextSize = 14 }),

							Components.TextUIStroke(scope, { Thickness = 2.5 })
						},
					}),
				},
			}),
			Components.Frame(scope, {
				Name = "Center",
				AnchorPoint = v2New(0.5, 0),
				Size = fromScale(1, 0.1),
				Position = fromScale(0.5, 0.5),

				[Children] = {
					New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.627 }),

					Components.Frame(scope, {
						Name = "SaveSlotsFrame",

						Visible = Computed(scope, function(use: Fusion.Use)
							return not use(self.isTeleporting)
						end),
						Position = Tween(scope, Computed(scope, function(use)
							return use(self.saveSlotBGPos)
						end), AssetBook.TweenInfos.oneHalf),

						[Children] = {
							SaveSlot(1, self),
							SaveSlot(2, self),
							SaveSlot(3, self),
						},
					}),

					FriendListFrame(self),
					WorldListFrame(self)
				},
			})
		},
	})

	--// Connections
	local function teleportFailed()
		self.isTeleporting:set(false)

		Signals.CreateFullScreenHint:Fire("...", false)
	end
	table.insert(scope, Events.TeleportFailed.On(teleportFailed))

	pcall(function()
		local listeners = {}
		for i = 1, 3 do
			listeners["Attr-DATA"..i.."Class"] = function(class: string)
				self.playerData["Slot"..i].Class:set(class)
			end
			listeners["Attr-DATA"..i.."PlayTime"] = function(playTime: number)
				self.playerData["Slot"..i].PlayTime:set(playTime)
			end
			listeners["Attr-DATA"..i.."Levels"] = function(levels: number)
				self.playerData["Slot"..i].Levels:set(levels)
			end
			listeners["Attr-DATA"..i.."LastSeenLocation"] = function(lastSeen: string)
				self.playerData["Slot"..i].LastSeen:set(lastSeen)
			end
			listeners["Attr-DATA"..i.."StoryId"] = function(storyId: number)
				self.playerData["Slot"..i].StoryId:set(storyId)
			end
		end

		table.insert(scope, HarukaLib:Hydrate(plr, listeners))
	end)


	--// Clear
	local function _onDead()
		Fusion.doCleanup(self.scope)
	end
	self.char.Humanoid.Died:Once(_onDead)

	--// Setups
	pcall(function()
		UserInputService.ModalEnabled = true

        ContextActionService:BindActionAtPriority("FreezeControl", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, unpack(Enum.PlayerActions:GetEnumItems()))
	end)

	wait(0.5)
	self.bottomFramePos:set(fromScale(0.5, 1))

	Spawn(function()
		workspace:WaitForChild("MapComponents", 999) --- low-end devices...
		workspace.MapComponents:WaitForChild("PlayerChars", 999)

		for i = 1, 3 do
			local charSelfViewSlot = Fusion.peek(self.charSelfViews[i]) :: ViewportFrame
			charSelfViewSlot.CurrentCamera = charSelfViewSlot:FindFirstChildOfClass("Camera")

			workspace.MapComponents.PlayerChars:WaitForChild(self.plr.Name, 999):WaitForChild("Slot"..i, 999)

			table.insert(scope, RS.Heartbeat:Connect(function()
				if charSelfViewSlot:FindFirstChildOfClass("Model") then charSelfViewSlot:FindFirstChildOfClass("Model"):Destroy() end
				if not workspace.MapComponents.PlayerChars:FindFirstChild(self.plr.Name) then return end
				if not workspace.MapComponents.PlayerChars[self.plr.Name]:FindFirstChild("Slot" .. i) then return end

				local clonedChar = workspace.MapComponents.PlayerChars[self.plr.Name]["Slot"..i]:Clone() :: Model
				local hrp = clonedChar.PrimaryPart
				if not hrp then return end

				charSelfViewSlot.CurrentCamera.CFrame = cfNew(hrp.Position + (hrp.CFrame.LookVector * 5), hrp.Position)

				clonedChar.Parent = charSelfViewSlot
			end))
		end
	end)

	wait(2)
	local check = false
	local clickDetect = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			check = true
		end
	end)
	repeat RS.RenderStepped:Wait() until check

	if clickDetect then clickDetect:Disconnect() end

	workspace.Sounds.SFXs.Click:Play()

	self.backBtnVisible:set(true)
	self.saveSlotBGPos:set(fromScale(0.5, -0.7))
	self.currentUI:set("SaveSlot")
	self.clickTipVisible:set(false)
end
