local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("fusion"))
local Time = require(script.Parent:WaitForChild("Time"))

local TAG = "wp_scaleable"
local PUSH_PULL_BINDING = "wp_pushpull_tool"
local DISTANCE_CHECK = 16
local VIEW_CHECK = 0.7

local MORPH_SPEED = 9

local LocalPlayer = Players.LocalPlayer

local Phys = {
	f_target = Fusion.Value(nil),
	TrackedTargets = {},
	ResizeSpeed = 0.5,

	Mode = "PushPull",
	Extrusion = 0,
	Intrusion = 0,
}

function Phys:Start()
	self.connection = RunService.Heartbeat:Connect(function(deltaTime)
		if self.Mode ~= nil then
			self:ChangeTarget(self:FindDeformable())
		else
			self:ChangeTarget(nil :: BasePart)
		end
		if self.Mode == "PushPull" then
			self:TargetSetPushPull(deltaTime)
			self:UpdatePushPull(self.Target)
		end
	end)

	for _, object in ipairs(CollectionService:GetTagged(TAG)) do
		self:LoadTarget(object)
	end

	self.creationConnection = CollectionService:GetInstanceAddedSignal(TAG):Connect(function(object: BasePart)
		self:LoadTarget(object)
	end)

	ContextActionService:BindAction(PUSH_PULL_BINDING, function(...)
		self:ProcessPushPull(...)
	end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2)
end

function Phys:ProcessPushPull(actionName, inputState, inputObject)
	inputObject = inputObject :: InputObject

	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		self.Extrusion = if inputState == Enum.UserInputState.Begin then 1 else 0
	elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
		self.Intrusion = if inputState == Enum.UserInputState.Begin then -1 else 0
	end
end

function Phys:UpdatePushPull(target: BasePart)
	if not target then
		return
	end

	local cache = self.TrackedTargets[target]
	local sizeShift = cache.direction * cache.delta

	target.Size = sizeShift + cache.size
	target.CFrame = cache.cframe * CFrame.new(sizeShift / 2)
end

function Phys:TargetSetPushPull(delta: number)
	local dir = self.Extrusion + self.Intrusion

	if not self.Target then
		return
	end

	Time:SetTimeScale(if self.Extrusion ~= 0 or self.Intrusion ~= 0 then 0.1 else 1)

	local cache = self.TrackedTargets[self.Target]
	cache.delta = math.clamp(cache.delta + dir * delta * MORPH_SPEED, 1, cache.limit or 5)
end

function Phys:UnloadTarget(target: BasePart)
	if target == nil or not self.TrackedTargets[target] then
		return false
	end
	local cache = self.TrackedTargets[target]
	target.CFrame = cache.cframe
	target.Size = cache.size
	target:SetAttribute("delta", cache.delta)
	target:SetAttribute("direction", cache.direction)
	target:SetAttribute("limit", cache.limit)
	self.TrackedTargets[target] = nil
end

function Phys:LoadTarget(target: BasePart)
	if target == nil or self.TrackedTargets[target] then
		return
	end
	self.TrackedTargets[target] = {
		cframe = target.CFrame,
		size = target.Size,
		delta = target:GetAttribute("delta"),
		direction = target:GetAttribute("direction") or Vector3.new(1, 0, 0),
		limit = target:GetAttribute("limit") or 10,
	}
	self:UpdatePushPull(target)
end

function Phys:ChangeTarget(newTarget: BasePart)
	self:LoadTarget(newTarget)
	self.Target = newTarget;
	(self.f_target :: any):set(newTarget)
end

local function Phys_m_DeformableInArea(mat: CFrame, deformable: BasePart)
	if not deformable:IsA("BasePart") then
		return false
	end

	local vec = deformable.Position - mat.Position
	local dot = vec.Unit:Dot(mat.LookVector.Unit)

	if not (dot > VIEW_CHECK) then
		return false
	end

	return true, dot
end

function Phys:FindDeformable()
	local playerCharacter = LocalPlayer.Character
	if not playerCharacter then
		return nil
	end
	local greatest = nil
	local highest = -math.huge

	local mat = workspace.CurrentCamera.CFrame
	local partsInRadius = workspace:GetPartBoundsInRadius(mat.Position, DISTANCE_CHECK)

	for _, object in pairs(partsInRadius) do
		local valid, dot = Phys_m_DeformableInArea(mat, object)
		if CollectionService:HasTag(object, TAG) and valid and highest < dot then
			highest = dot
			greatest = object
		end
	end

	return greatest
end

return Phys
