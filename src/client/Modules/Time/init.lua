local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local m_TimeScale = Fusion.Value(1) :: any

local Time = {}

local FieldOfViewTween = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0)
local computedTimeScaleToFOV = Fusion.Computed(function()
	return 70 * (1 + (1 - m_TimeScale:get()) / 5)
end)
local tweenedFieldOfView = Fusion.Tween(computedTimeScaleToFOV :: any, FieldOfViewTween)
Fusion.Hydrate(workspace.CurrentCamera)({
	FieldOfView = tweenedFieldOfView,
})

function Time:SetTimeScale(timeScale: number)
	if math.abs(m_TimeScale:get() - timeScale) < 0.1 then
		return
	end

	local scaleDiff = timeScale / m_TimeScale:get()
	workspace.Gravity *= scaleDiff

	-- Player stuff
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.WalkSpeed *= scaleDiff ^ (1 / 2)
		humanoid.JumpPower *= scaleDiff ^ (1 / 2)

		break
	end

	m_TimeScale:set(timeScale)
end

return Time
