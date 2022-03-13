local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("fusion"))

local Modules = script.Parent.Parent:WaitForChild("Modules")
local Physics = require(Modules:WaitForChild("Physics"))

local old = nil
local targetObject = Physics.f_target
local showHighlight = Fusion.Computed(function()
	return (targetObject :: Fusion.State<Instance>):get() ~= nil
end)

local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Cubic)

local surfaceTransparency = Fusion.Computed(function()
	return if (showHighlight :: Fusion.State<boolean>):get() then 0.8 else 1
end)
local tweenedSurfaceTransparency = Fusion.Tween(surfaceTransparency :: any, TWEEN_INFO)

local highlightTransparency = Fusion.Computed(function()
	return if (showHighlight :: Fusion.State<boolean>):get() then 0 else 1
end)
local tweenedHighlightTransparency = Fusion.Tween(highlightTransparency :: any, TWEEN_INFO)

local highlightInstance = Fusion.New("ScreenGui")({
	Name = "HighlightContainer",
	ResetOnSpawn = false,
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	[Fusion.Children] = {
		Fusion.New("SelectionBox")({
			Adornee = Fusion.Computed(function()
				local got = (targetObject :: any):get()
				if not got then
					return old
				end
				old = got
				return got
			end),
			Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

			Color3 = Color3.new(1, 1, 1),
			LineThickness = 0.01,
			SurfaceColor3 = Color3.new(0.090196, 0.243137, 0.921568),
			SurfaceTransparency = tweenedSurfaceTransparency,
			Transparency = tweenedHighlightTransparency,
		}),
	},
})

return highlightInstance
