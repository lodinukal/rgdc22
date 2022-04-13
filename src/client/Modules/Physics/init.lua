local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("fusion"))
local Time = require(script.Parent:WaitForChild("Time"))

local EXTRUSION_SIZE_TAG = "wp_scaleable"
local SHOVE_TAG = "wp_shoveable"

local PUSH_PULL_BINDING = "wp_pushpull_tool"
local DISTANCE_CHECK = 16
local VIEW_CHECK = 0.1

local MORPH_SPEED = 12
local SHOVE_SPEED = 3

local rotationSpeed = 15

UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
	-- if gameProcessedEvent then
	-- 	return
	-- end
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		-- rotationSpeed = math.clamp(rotationSpeed + input.Position.Z, 0, 30)
	end
end)

local LocalPlayer = Players.LocalPlayer

local Phys = {
	f_target = Fusion.Value(nil),
	f_mode = Fusion.Value("PushPull"),

	TrackedTargets = {},
	ResizeSpeed = 0.5,

	Mode = "PushPull",
	Extrusion = 0,
	Intrusion = 0,
}

local weldEffect = SoundService:WaitForChild("Welding") :: Sound

function Phys:Start()
	self.connection = RunService.Heartbeat:Connect(function(deltaTime)
		if self.Mode == nil then
			self:ChangeTarget(nil :: BasePart)
		end
		if self.Mode == "PushPull" then
			self:ChangeTarget(self:FindObject(EXTRUSION_SIZE_TAG))
			self:TargetSetPushPull(deltaTime)
			self:UpdatePushPull(self.Target)
		end
		if self.Mode == "Shove" then
			self:ChangeTarget(self:FindObject(SHOVE_TAG))
			self:DoShove(deltaTime)
		end
	end)

	for _, object in ipairs(CollectionService:GetTagged(EXTRUSION_SIZE_TAG)) do
		self:LoadTarget(object)
	end

	self.creationConnection = CollectionService
		:GetInstanceAddedSignal(EXTRUSION_SIZE_TAG)
		:Connect(function(object: BasePart)
			self:LoadTarget(object)
		end)

	ContextActionService:BindActionAtPriority(
		PUSH_PULL_BINDING,
		function(...)
			self:ProcessPushPull(...)
			return Enum.ContextActionResult.Pass
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.MouseButton2
	)
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
	local sizeShift: Vector3 = cache.direction * cache.delta

	target.Size = Vector3.new(math.abs(sizeShift.X), math.abs(sizeShift.Y), math.abs(sizeShift.Z)) + cache.size
	target.CFrame = cache.cframe * CFrame.new(sizeShift / 2)
end

function Phys:TargetSetPushPull(delta: number)
	local dir = self.Extrusion + self.Intrusion

	if not self.Target then
		Time:SetTimeScale(1)
		return
	end

	if not CollectionService:HasTag(self.Target, EXTRUSION_SIZE_TAG) then
		Time:SetTimeScale(1)
		self:ChangeTarget(nil);
		return
	end

	local active = self.Extrusion ~= 0 or self.Intrusion ~= 0

	Time:SetTimeScale(if active then 0.1 else 1)

	if active and not weldEffect.IsPlaying then
		weldEffect:Play()
	end
	if not active and weldEffect.Playing then
		weldEffect:Stop()
	end

	local cache = self.TrackedTargets[self.Target]
	cache.delta = math.clamp(cache.delta + dir * delta * MORPH_SPEED, 1, cache.limit or 5)
end

local targetOldAnchor = {}
function Phys:DoShove(delta)
	if not self.Target then
		if targetOldAnchor and targetOldAnchor[1] then
			targetOldAnchor[1].Anchored = targetOldAnchor[2]
			targetOldAnchor = {}
		end
		Time:SetTimeScale(1)
		return
	end

	if not CollectionService:HasTag(self.Target, SHOVE_TAG) then
		Time:SetTimeScale(1)
		self:ChangeTarget(nil);
		return
	end

	local active = self.Extrusion ~= 0 or self.Intrusion ~= 0
	Time:SetTimeScale(if active then 0.1 else 1)

	local target = self.Target :: BasePart
	if targetOldAnchor[1] ~= target then
		if targetOldAnchor and targetOldAnchor[1] then
			targetOldAnchor[1].Anchored = targetOldAnchor[2]
			targetOldAnchor = {}
		end
		targetOldAnchor[1] = target
		targetOldAnchor[2] = target.Anchored
	end

	target.Anchored = if self.Extrusion ~= 0 then false else targetOldAnchor[2]

	target.AssemblyLinearVelocity = Vector3.new(0, target.AssemblyLinearVelocity.Y, 0)
	target.CFrame += workspace.CurrentCamera.CFrame.LookVector * SHOVE_SPEED * delta * (if self.Extrusion ~= 0
		then 1
		else 0)
	target.CFrame *= CFrame.fromEulerAnglesXYZ(
		0,
		math.rad(delta * rotationSpeed * self.Intrusion * (if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then -1 else 1)),
		0
	)
	if target:GetAttribute("specialvert") and not target:FindFirstChildOfClass("BodyGyro") then
		local bg = Instance.new("BodyGyro")
		bg.Parent = target
		bg.D = 0
		bg.MaxTorque = Vector3.new(10000, 0, 10000)
		bg.P = 999
		bg.CFrame = CFrame.new()
	end
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
		delta = math.max(target:GetAttribute("delta") or 0, 1),
		direction = target:GetAttribute("direction") or Vector3.new(1, 0, 0),
		limit = target:GetAttribute("limit") or 10,
	}
	if CollectionService:HasTag(target, EXTRUSION_SIZE_TAG) then
		self:UpdatePushPull(target)
	end
end

function Phys:ChangeTarget(newTarget: BasePart)
	self:LoadTarget(newTarget)
	self.Target = newTarget;
	(self.f_target :: any):set(newTarget)
end

local function Phys_m_ObjectInArea(mat: CFrame, object: BasePart)
	if not object:IsA("BasePart") then
		return false
	end

	local vec = object.Position - mat.Position
	local dot = mat.LookVector.Unit:Dot(vec.Unit)

	if dot < VIEW_CHECK then
		return false
	end

	return true, dot, vec.Magnitude
end

local old = nil
function Phys:FindObject(tag)
	tag = tag or EXTRUSION_SIZE_TAG
	local playerCharacter = LocalPlayer.Character
	if not playerCharacter or not playerCharacter.Parent or not playerCharacter.PrimaryPart then
		return nil
	end

	local mat = workspace.CurrentCamera.CFrame
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { playerCharacter }
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(mat.Position, mat.LookVector * DISTANCE_CHECK, params)

	if result and CollectionService:HasTag(result.Instance, tag) then
		old = result.Instance
		return result.Instance
	end

	local greatest = nil
	local highest = math.huge
	mat = playerCharacter.PrimaryPart.CFrame
		* (workspace.CurrentCamera.CFrame :: CFrame & { Rotation: CFrame }).Rotation

	local partsInRadius = workspace:GetPartBoundsInRadius(mat.Position, DISTANCE_CHECK)

	if self.Extrusion ~= 0 or self.Intrusion ~= 0 then
		if table.find(partsInRadius, old) then
			return old
		end
	end

	for _, object in pairs(partsInRadius) do
		local valid, dot, distance = Phys_m_ObjectInArea(mat, object)
		if CollectionService:HasTag(object, tag) and valid and highest > distance then
			highest = distance
			greatest = object
		end
	end

	old = greatest
	return greatest
end

function Phys:SetMode(newMode: string)
	self.Mode = newMode;
	(self.f_mode :: any):set(newMode)
end

return Phys
