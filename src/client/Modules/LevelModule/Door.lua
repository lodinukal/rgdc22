local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))

local DOOR_SOUND = SoundService:WaitForChild("Gateway") :: Sound
local DOOR_SPEED = 1 / 7

return function(props: { instance: BasePart, dependingState: Fusion.State<boolean> })
	local instance = props.instance
	if not instance then
		return nil
	end
	local dependingState = props.dependingState
	if not dependingState then
		return nil
	end

	local openPosition = instance.Position
	local closedPosition = instance.Position + (instance:GetAttribute("Offset") or Vector3.new(0, 10, 0))

	local info = TweenInfo.new((closedPosition - openPosition).Magnitude * DOOR_SPEED)
	local positionComputed = Fusion.Computed(function()
		return if dependingState:get() == true then openPosition else closedPosition
	end)
	Fusion.Observer(dependingState):onChange(function()
		DOOR_SOUND:Play()
	end)
	local tweened = Fusion.Tween(positionComputed :: any, info)
	Fusion.Hydrate(instance)({
		Position = tweened,
	})
end
