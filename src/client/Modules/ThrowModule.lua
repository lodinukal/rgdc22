local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))

local ThrowModule = {}
ThrowModule.HoldDistance = 30
ThrowModule.ThrowPower = 50
ThrowModule.Throwable = {
	workspace:WaitForChild("Wrench"),
}
ThrowModule.ItemCFrame = Fusion.Value(CFrame.new()) :: Fusion.State<CFrame>
local ITEM_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
ThrowModule.SpringItemCFrame = Fusion.Tween(ThrowModule.ItemCFrame, ITEM_TWEEN)

Fusion.Observer(ThrowModule.SpringItemCFrame):onChange(function()
	if ThrowModule.Item then
		ThrowModule.Item:SetPrimaryPartCFrame(ThrowModule.SpringItemCFrame:get())
	end
end)

function ThrowModule.IsThrowable(part)
	for i, v in ipairs(ThrowModule.Throwable) do
		if not part:IsDescendantOf(v) then
			continue
		end

		return v
	end

	return nil
end

function ThrowModule.Hold()
	local mouseLocation = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * ThrowModule.HoldDistance, params)
	if not result then
		warn("nil")
		return
	end
	local Item = ThrowModule.IsThrowable(result.Instance)
	if not Item then
		warn("not a throwable")
		return
	end
	Item.PrimaryPart.Anchored = true
	ThrowModule.Item = Item
	ThrowModule.HoldConnection = RunService.Heartbeat:Connect(function(deltaTime)
		ThrowModule.ItemCFrame:set(camera.CFrame + camera.CFrame.LookVector * 5)
	end)
end

function ThrowModule.LetGo()
	if ThrowModule.HoldConnection then
		ThrowModule.HoldConnection:Disconnect()
	end
	local item = ThrowModule.Item
	if item then
		ThrowModule.Item = nil
		item.PrimaryPart.Anchored = false
		item.PrimaryPart:ApplyImpulse(camera.CFrame.LookVector * ThrowModule.ThrowPower)
	end
end

ContextActionService:BindAction("HoldItem", function(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		print("Held")
		ThrowModule.Hold()
	elseif inputState == Enum.UserInputState.End then
		print("Let go")
		ThrowModule.LetGo()
	end
end, false, Enum.UserInputType.MouseButton1)

return ThrowModule
