local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent

local PhysicsModule = require(script.Parent.Parent.Modules:WaitForChild("Physics"))

local buttonSound = SoundService:WaitForChild("ButtonSound") :: Sound

local iconModeMapping = {
	PushPull = "rbxassetid://9088481403",
	Shove = "rbxassetid://9088472797",
}

local modeCycle = {
	PushPull = "Shove",
	Shove = "PushPull",
}

local text = {
	PushPull = {
		{
			Text = "Extrude",
			Icon = "rbxassetid://9099342070",
		},
		{
			Text = "Intrude",
			Icon = "rbxassetid://9099341910",
		},
	},
	Shove = {
		{
			Text = "Shove",
			Icon = "rbxassetid://9099342070",
		},
		{
			Text = "Rotate",
			Icon = "rbxassetid://9099341910",
		},
	},
}

local function NextMode()
	PhysicsModule:SetMode(modeCycle[(PhysicsModule.f_mode :: any):get()])
	buttonSound:Play()
end

local ACTION_NAME = "wp_physics_switch_action"
ContextActionService:BindAction(ACTION_NAME, function(name, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		NextMode()
	end
end, false, Enum.KeyCode.E)

local icon = Computed(function()
	local currentmode = (PhysicsModule.f_mode :: any):get()
	return iconModeMapping[currentmode] or ""
end)

PhysicsSwitcher = New("ScreenGui")({
	Name = "PhysicsSwitcher",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

	[Children] = {
		New("Frame")({
			Name = "Container",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(0.25, 0.322),

			[Children] = {
				New("ImageButton")({
					Name = "Button",
					Image = "rbxassetid://9088290164",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.127, 0.16),
					Size = UDim2.fromScale(0.333, 0.5),

					[Children] = {
						New("Frame")({
							Name = "Image",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 0.5,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.85, 0.85),

							[Children] = {
								New("UICorner")({
									Name = "UICorner",
									CornerRadius = UDim.new(0.5, 0),
								}),
							},
						}),

						New("UIAspectRatioConstraint")({
							Name = "UIAspectRatioConstraint",
						}),

						New("ImageLabel")({
							Name = "ImageLabel",
							Image = icon,
							ImageColor3 = Color3.fromRGB(58, 58, 58),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.9, 0.9),
							ZIndex = 2,
						}),

						New("TextLabel")({
							Name = "KeyboardPrompt",
							Font = Enum.Font.Highway,
							RichText = true,
							Text = "E",
							TextColor3 = Color3.fromRGB(213, 213, 213),
							TextScaled = true,
							TextSize = 14,
							TextStrokeTransparency = 0,
							TextWrapped = true,
							AnchorPoint = Vector2.new(1, 0.2),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(1, 0),
							Size = UDim2.fromScale(0.353, 0.31),

							[Children] = {
								New("UIAspectRatioConstraint")({
									Name = "UIAspectRatioConstraint",
									AspectRatio = 1.14,
								}),
							},
						}),

						New("Frame")({
							Name = "1",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(1, -0.2),
							Rotation = -10,
							Size = UDim2.fromScale(2, 0.5),

							[Children] = {
								New("TextLabel")({
									Name = "TextLabel",
									Font = Enum.Font.Highway,
									Text = Computed(function()
										return text[PhysicsModule.f_mode:get()][1].Text
									end),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextScaled = true,
									TextSize = 14,
									TextStrokeTransparency = 0,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.7, 0.5),
									Size = UDim2.fromScale(0.7, 0.7),
								}),

								New("ImageLabel")({
									Name = "ImageLabel",
									Image = Computed(function()
										local m = text[PhysicsModule.f_mode:get()][1]
										return if m then text[PhysicsModule.f_mode:get()][1].Icon else ""
									end),
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = Computed(function()
										local m = text[PhysicsModule.f_mode:get()][1]
										return if not not m then 0.9 else 1
									end),
									Position = UDim2.fromScale(0.15, 0.5),
									Size = UDim2.fromScale(0.25, 0.25),
									SizeConstraint = Enum.SizeConstraint.RelativeXX,
									Visible = Computed(function()
										return not not text[PhysicsModule.f_mode:get()][1]
									end),
								}),
							},
						}),

						New("Frame")({
							Name = "2",
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(1, 0.65),
							Rotation = 8,
							Size = UDim2.fromScale(2, 0.5),

							[Children] = {
								New("TextLabel")({
									Name = "TextLabel",
									Font = Enum.Font.Highway,
									Text = Computed(function()
										local m = text[PhysicsModule.f_mode:get()][2]
										return if m then text[PhysicsModule.f_mode:get()][2].Text else ""
									end),
									TextColor3 = Color3.fromRGB(255, 255, 255),
									TextScaled = true,
									TextSize = 14,
									TextStrokeTransparency = 0,
									TextWrapped = true,
									TextXAlignment = Enum.TextXAlignment.Left,
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(0.7, 0.5),
									Size = UDim2.fromScale(0.7, 0.7),
								}),

								New("ImageLabel")({
									Name = "ImageLabel",
									Image = Computed(function()
										local m = text[PhysicsModule.f_mode:get()][2]
										return if m then text[PhysicsModule.f_mode:get()][2].Icon else ""
									end),
									AnchorPoint = Vector2.new(0.5, 0.5),
									BackgroundColor3 = Color3.fromRGB(255, 255, 255),
									BackgroundTransparency = Computed(function()
										local m = text[PhysicsModule.f_mode:get()][2]
										return if not not m then 0.9 else 1
									end),
									Position = UDim2.fromScale(0.15, 0.5),
									Size = UDim2.fromScale(0.25, 0.25),
									SizeConstraint = Enum.SizeConstraint.RelativeXX,
									Visible = Computed(function()
										return not not text[PhysicsModule.f_mode:get()][1]
									end),
								}),
							},
						}),
					},

					[OnEvent("Activated")] = NextMode,
				}),

				New("UIAspectRatioConstraint")({
					Name = "UIAspectRatioConstraint1",
					AspectRatio = 1.5,
				}),
			},
		}),
	},
})

return PhysicsSwitcher
