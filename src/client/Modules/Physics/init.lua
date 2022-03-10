local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("fusion"))

local Phys = {
	f_target = Fusion.Value(nil),
	CachedTarget = nil,
	TrackedTargets = {},
	ResizeSpeed = 0.5,

	Mode = "PushPull",
}

function Phys:Start()
	self.connection = RunService.Heartbeat:Connect(function(deltaTime)
		if self.Mode == "PushPull" then
			self:UpdatePushPull(deltaTime)
		end
	end)
end

function Phys:UpdatePushPull(dt)
	local target = self.Target :: BasePart
	if not target then
		return
	end

	local cache = self.TrackedTargets[target]

	local sizeShift = cache.direction * cache.delta

	target.Size = sizeShift + cache.size
	target.CFrame = cache.cframe * CFrame.new(sizeShift / 2)
end

function Phys:ChangeTarget(newTarget: BasePart)
	self.Target = newTarget;
	(self.f_target :: any):set(newTarget)
	if self.TrackedTargets[newTarget] or newTarget == nil then
		return
	end
	self.TrackedTargets[newTarget] = {
		cframe = newTarget.CFrame,
		size = newTarget.Size,
		delta = newTarget:GetAttribute("delta"),
		direction = newTarget:GetAttribute("direction") or Vector3.new(1, 0, 0),
	}
end

return Phys
