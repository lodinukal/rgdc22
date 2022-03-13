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
local OnEvent = Fusion.OnEvent

local PhysicsModule = require(script.Parent.Parent.Modules:WaitForChild("Physics"))

local iconModeMapping = {
	PushPull = "rbxassetid://9088481403",
	Shove = "rbxassetid://9088472797",
}

local modeCycle = {
	PushPull = "Shove",
	Shove = "PushPull",
}

local function NextMode()
	PhysicsModule:SetMode(modeCycle[(PhysicsModule.f_mode :: any):get()])
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
					Name = "Botton",
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
