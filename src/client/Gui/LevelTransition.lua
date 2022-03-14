local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value

local levelHint = Value(false)

ContextActionService:BindAction("Hint", function(actionName, state, inputObject)
	if state ~= Enum.UserInputState.Begin then
		return
	end
	levelHint:set(not levelHint:get())
end, false, Enum.KeyCode.H)

local levelHints = {
	["Level 1"] = "Hint - Try extruding the pipe.",
	["Level 2"] = "Hint - Try rotating the laser beam generator to face the receiver on the wall. To get rotate tool press E, and to reverse the rotation direction hold Left Shift while rotating.",
	["Level 3"] = "Hint - The scaffolding is really bendy, and those barrels are reflective, so maybe we could unlock the door like that.",
}

local function LevelTransition(props)
	local levelName = Value("Level 1")
	local anchorPoint = Value(Vector2.new(0.5, 0))

	local popUp = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
	local popDown = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)

	local levelHintTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
	local tempLevelTween = Computed(function()
		return if levelHint:get() then 0 else 1
	end)
	local levelHintTweened = Tween(tempLevelTween, levelHintTweenInfo)

	local bulbColor = Computed(function()
		if levelHint:get() then
			return Color3.new(1, 0.917647, 0.196078)
		else
			return Color3.new(1, 1, 1)
		end
	end)
	local bulbColorTweened = Tween(bulbColor, levelHintTweenInfo)

	local tweenInfo = Value(popUp)
	local tween = Tween(
		anchorPoint,
		Computed(function()
			return tweenInfo:get()
		end)
	)

	local gui = New("ScreenGui")({
		IgnoreGuiInset = true,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
		[Children] = {
			New("TextLabel")({
				AnchorPoint = Computed(function()
					return tween:get()
				end),
				Position = UDim2.fromScale(0.5, 1),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0.1),
				Text = Computed(function()
					return levelName:get()
				end),
				Font = Enum.Font.GothamSemibold,
				TextSize = 40,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}),

			New("Frame")({
				Name = "Frame",
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(1, 1),
				Size = UDim2.fromScale(0.25, 0.322),

				[Children] = {
					New("ImageButton")({
						Name = "ImageLabel",
						Image = "rbxassetid://9100535930",
						AnchorPoint = Vector2.new(1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.9, 0.9),
						Size = UDim2.fromScale(0.2, 0.2),
						SizeConstraint = Enum.SizeConstraint.RelativeXX,
						ImageColor3 = bulbColorTweened,
						[Fusion.OnEvent("Activated")] = function()
							levelHint:set(not levelHint:get())
						end,

						[Children] = {
							New("TextLabel")({
								Name = "KeyboardPrompt",
								Font = Enum.Font.Highway,
								RichText = true,
								Text = "H",
								TextColor3 = Color3.fromRGB(213, 213, 213),
								TextScaled = true,
								TextSize = 14,
								TextStrokeTransparency = 0,
								TextWrapped = true,
								AnchorPoint = Vector2.new(1, 0.2),
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1,
								Position = UDim2.fromScale(0.5, 0),
								Size = UDim2.fromScale(0.588, 0.516),
							}),
						},
					}),

					New("UIAspectRatioConstraint")({
						Name = "UIAspectRatioConstraint",
						AspectRatio = 1.5,
					}),

					New("TextLabel")({
						Name = "Hint",
						Font = Enum.Font.Highway,
						RichText = true,
						Text = Computed(function()
							return levelHints[levelName:get()] or "no hints for this level, sorry!"
						end),
						TextColor3 = Color3.fromRGB(213, 213, 213),
						TextSize = 40,
						TextTransparency = levelHintTweened,
						TextStrokeTransparency = levelHintTweened,
						TextWrapped = true,
						TextYAlignment = Enum.TextYAlignment.Bottom,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(-0.032, -1.29),
						Size = UDim2.fromScale(0.9, 1.96),

						[Children] = {
							New("UIPadding")({
								Name = "UIPadding",
								PaddingBottom = UDim.new(0.1, 0),
								PaddingTop = UDim.new(0.2, 0),
							}),
						},
					}),
				},
			}),
		},
	})

	props.LevelledUp:Connect(function(name)
		levelName:set(name)
		tweenInfo:set(popUp)
		anchorPoint:set(Vector2.new(0.5, 1))
		task.wait(3)
		tweenInfo:set(popDown)
		anchorPoint:set(Vector2.new(0.5, 0))
	end)

	return gui
end

return LevelTransition
