--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children, New = Fusion.Children, Fusion.New

local wait = task.wait
local v2New, udNew = Vector2.new, UDim.new
local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local insert, remove, tFind = table.insert, table.remove, table.find

return function(plr: Player)
	local hintsList = Fusion.Value({})

	Components.ScreenGui({
		Name = "Hints",
		DisplayOrder = 5,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.Frame({
				Name = "BG",
				Position = fromScale(0.5, 0.511),
				Size = fromScale(1, 0.979),
				ZIndex = 999,

				[Children] = {
					New("UIListLayout")({
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					New("UIPadding")({ PaddingTop = udNew(0, 10) }),

					Fusion.ForValues(hintsList, function(use, text: string)
						return Components.TextButton({
							Name = "Hint",
							AnchorPoint = v2New(0.5, 0.5),
							AutomaticSize = Enum.AutomaticSize.X,
							Size = fromOffset(0, 27),
							Text = text,
							FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold),
							TextScaled = false,

							[Children] = {
								New("UICorner")({ CornerRadius = udNew(0.25, 0) }),
								New("UIPadding")({
									PaddingLeft = udNew(0, 11),
									PaddingRight = udNew(0, 11),
								}),
							},
						})
					end, Fusion.cleanup)
				},
			}),

		},
	})

	local function _createHint(text: string, envir: string)
		local past = Fusion.peek(hintsList)
		insert(past, text)

		hintsList:set(past)

		if envir == "Error" then
			workspace.Sounds.SFXs.Error:Play()

		elseif envir == "Hint" then
			workspace.Sounds.SFXs.NewInfo:Play()
		end

		wait(3)
		local now = Fusion.peek(hintsList)
		remove(now, tFind(now, text))

		hintsList:set(now)
	end
	Events.CreateHint:Connect(_createHint)
	Signals.CreateHint:Connect(_createHint)
end
