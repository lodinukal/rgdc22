local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("fusion"))
local RDL = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("RDL"))

local MIRROR_TAG = "wp_mirror"
local SOURCE_TAG = "wp_lasersource"
local RECEIVER_TAG = "wp_laserreceiver"

-- local LaserSound = script:WaitForChild("LaserSound")
-- local Beam = script:WaitForChild("Beam")
-- local BurnEffect = script:WaitForChild("BurnEffect")

local Player = game.Players.LocalPlayer

local Mouse = Player:GetMouse()

local LaserModule = {}
LaserModule.Radius = 0.5
LaserModule.ReflectLimit = 20
LaserModule.Distance = 100

LaserModule.CachedMirrors = {}
LaserModule.CachedSources = {}
LaserModule.ActiveLasers = {}
LaserModule.Receivers = {}

LaserModule.ReceiverIded = {}
LaserModule.Powered = {}
LaserModule.f_recievers = Fusion.Value(LaserModule.ReceiverIded)

local beamTemplate
do
	beamTemplate = Instance.new("Part")
	-- local sound = LaserSound:Clone()
	-- sound:Play()
	-- sound.Parent = part

	beamTemplate.Name = "Laser"
	beamTemplate.Anchored = true

	beamTemplate.Material = Enum.Material.Neon
	beamTemplate.Transparency = 0.2
	beamTemplate.Color = Color3.new(0.913725, 0.670588, 0.007843)

	-- part.CFrame = CFrame.lookAt(origin + direction/2 , origin)
	-- part.Size = Vector3.new(self.Radius, self.Radius, direction.Magnitude)

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "Attachment0"
	attachment0.Parent = beamTemplate
	-- attachment0.WorldPosition = origin

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "Attachment1"
	attachment1.Parent = beamTemplate
	-- attachment1.WorldPosition = origin + direction

	-- local burnEffect = BurnEffect:Clone()
	-- burnEffect.Parent = attachment1

	-- local beam = Beam:Clone()
	-- beam.Attachment0 = attachment0
	-- beam.Attachment1 = attachment1
	-- beam.Parent = part

	beamTemplate.CanCollide = false
	beamTemplate.Parent = workspace
end

LaserModule.LaserCache = {}
do
	local self = LaserModule.LaserCache
	self.Stored = {}
	self.Count = 0
	self.Using = 0

	local CF_REALLY_FAR_AWAY = CFrame.new(0, 10e8, 0)

	function self:GetPart()
		if (self.Using + 1) >= self.Count then
			for i = 1, 10, 1 do
				local clone = beamTemplate:Clone()
				clone.Parent = workspace
				clone.CFrame = CF_REALLY_FAR_AWAY
				self.Stored[self.Count + i] = clone
			end
			self.Count += 10
		end
		local obj = self.Stored[self.Count - self.Using]
		self.Using += 1
		return obj
	end

	function self:ReturnPart(obj)
		self.Using -= 1
		obj.CFrame = CF_REALLY_FAR_AWAY
		self.Stored[self.Count - self.Using] = obj
	end
end

local function reflect(lv, nv)
	return lv - 2 * nv * (lv:Dot(nv))
end

function LaserModule:IsMirror(part: Instance)
	return CollectionService:HasTag(part, MIRROR_TAG)
end

function LaserModule:IsReceiver(part: Instance)
	return CollectionService:HasTag(part, RECEIVER_TAG)
end

local increment = 1

function round(number)
	return math.floor((number / increment) + 0.5) * increment
end

function AngleFromAxis(axis, r)
	local relativeAngle = math.rad(round(math.deg(r)))

	return axis == Enum.Axis.X and { relativeAngle, 0, 0 }
		or axis == Enum.Axis.Y and { 0, relativeAngle, 0 }
		or axis == Enum.Axis.Z and { 0, 0, relativeAngle }
end

function LaserModule:Clear()
	for _, laser in pairs(self.ActiveLasers) do
		self.LaserCache:ReturnPart(laser)
	end
	self.ActiveLasers = {}
end

function LaserModule:ShowBeam(origin: Vector3, direction: Vector3)
	local laser = self.LaserCache:GetPart()
	laser.CFrame = CFrame.lookAt(origin + direction / 2, origin)
	laser.Size = Vector3.new(self.Radius, self.Radius, direction.Magnitude)

	laser.Attachment0.WorldPosition = origin
	laser.Attachment1.WorldPosition = origin + direction

	table.insert(self.ActiveLasers, laser)

	return laser
end

function LaserModule:MirrorSet(mirror: Instance, mirrorConfine: string?)
	mirrorConfine = if mirrorConfine then mirrorConfine else true
	self.CachedMirrors[mirrorConfine] = if self.CachedMirrors[mirrorConfine]
		then self.CachedMirrors[mirrorConfine]
		else {}
	table.insert(self.CachedMirrors[mirrorConfine], mirror)
end

function LaserModule:DoLaserSim(source: BasePart)
	local direction = source.CFrame.LookVector * self.Distance

	local offset = source:GetAttribute("offset")
	local origin = source.Position
	if offset then
		origin += offset
	end
	local part = source

	for _ = 1, self.ReflectLimit do
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {
			self.ActiveLasers,
			self.CachedSources,
			source,
			Player.Character,
		} :: Array<Instance>
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

		local result = workspace:Raycast(origin, direction, raycastParams)
		local laser = self:ShowBeam(origin, result and result.Position - origin or direction)

		local object = result and result.Instance
		if not result or not result.Instance then
			return
		end

		if not self:IsMirror(object) then
			if self:IsReceiver(object) then
				local id = object:GetAttribute("Id") or object.Name

				if self.Powered[id] then
					for i, signal in pairs(self.Powered[id]) do
						signal:Fire()
						self.Powered[id][i] = nil
					end
				end

				self.Receivers[object] = true
				self.ReceiverIded[id] = true
			end
			return
		end

		local lightVector = (result.Position - laser.Position).Unit
		local reflectionVector = reflect(lightVector, result.Normal)

		part = object
		origin = result.Position
		direction = reflectionVector * self.Distance
	end
end

function LaserModule:Start()
	for _, mirror in ipairs(CollectionService:GetTagged(MIRROR_TAG)) do
		self:MirrorSet(mirror, mirror:GetAttribute("SourceConfine"))
	end
	CollectionService:GetInstanceAddedSignal(MIRROR_TAG):Connect(function(mirror: Instance)
		self:MirrorSet(mirror, mirror:GetAttribute("SourceConfine"))
	end)

	for _, source in ipairs(CollectionService:GetTagged(SOURCE_TAG)) do
		self.CachedSources[source] = true
	end
	CollectionService:GetInstanceAddedSignal(SOURCE_TAG):Connect(function(source: Instance)
		self.CachedSources[source] = true
	end)
	CollectionService:GetInstanceRemovedSignal(SOURCE_TAG):Connect(function(source: Instance)
		self.CachedSources[source] = nil
	end)

	-- local arcHandles
	-- ContextActionService:BindAction("SelectMirror", function(actionName, inputState, inputObject)
	-- 	if inputState == Enum.UserInputState.Begin then
	-- 		local target = Mouse.Target

	-- 		if not self:IsMirror(target) then
	-- 			return
	-- 		end

	-- 		-- if arcHandles then
	-- 		-- 	arcHandles:Destroy()
	-- 		-- 	if arcHandles.Adornee == target then
	-- 		-- 		arcHandles = nil
	-- 		-- 		return
	-- 		-- 	end
	-- 		-- end

	-- 		-- arcHandles = Instance.new("ArcHandles")
	-- 		-- arcHandles.Adornee = target
	-- 		-- arcHandles.Parent = Player:WaitForChild("PlayerGui")

	-- 		local lastCFrame = CFrame.new()
	-- 		-- arcHandles.MouseDrag:Connect(function(axis, relativeAngle, delta)
	-- 		-- 	target.CFrame = lastCFrame * CFrame.Angles(unpack(AngleFromAxis(axis, relativeAngle)))
	-- 		-- end)

	-- 		-- arcHandles.MouseButton1Down:Connect(function()
	-- 		-- 	lastCFrame = target.CFrame
	-- 		-- end)
	-- 	end
	-- end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)

	RunService.Heartbeat:Connect(function(deltaTime)
		self:Clear()

		self.Receivers = {}
		self.ReceiverIded = {}

		for source, _ in pairs(self.CachedSources) do
			if not workspace:IsAncestorOf(source) then
				continue
			end
			self:DoLaserSim(source)
		end
	end)
end

function LaserModule:Received(id: string)
	return self.ReceiverIded[id] ~= nil
end

function LaserModule:GetPowerSignal(id: string)
	self.Powered[id] = self.Powered[id] or {}
	local signal = RDL.Signal.new()
	table.insert(self.Powered[id], signal)
	return signal
end

LaserModule:Start()

return LaserModule
