local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartCache = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("PartCache"))

local MIRROR_TAG = "PuzzleMirror"
local SOURCE_TAG = "PuzzleLaserSource"

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

local beamTemplate do
    beamTemplate = Instance.new("Part")
    -- local sound = LaserSound:Clone()
    -- sound:Play()
    -- sound.Parent = part

    beamTemplate.Name = "Laser"
    beamTemplate.Anchored = true

    beamTemplate.Material = Enum.Material.Neon
    beamTemplate.Transparency = 0.2

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

LaserModule.LaserCache = PartCache.new(beamTemplate, 1, workspace)

local function reflect(lv, nv)
    return lv - 2 * nv * (lv:Dot(nv))
end

function LaserModule:IsMirror(part: Instance)
    return CollectionService:HasTag(part, MIRROR_TAG)
end

local increment = 1

function round(number)
	return math.floor((number / increment) + 0.5) * increment
end

function AngleFromAxis(axis, r)
	local relativeAngle = math.rad(round(math.deg(r)))

	return axis == Enum.Axis.X and {relativeAngle, 0, 0} 
		or axis == Enum.Axis.Y and {0, relativeAngle, 0} 
		or axis == Enum.Axis.Z and {0, 0, relativeAngle}
end

function LaserModule:Clear()
    for _, laser in pairs(self.ActiveLasers) do
        self.LaserCache:ReturnPart(laser)
    end
    self.ActiveLasers = {}
end

function LaserModule:ShowBeam(origin: Vector3, direction: Vector3)
    local laser = self.LaserCache:GetPart()
    laser.CFrame = CFrame.lookAt(origin + direction/2 , origin)
    laser.Size = Vector3.new(self.Radius, self.Radius, direction.Magnitude)

    laser.Attachment0.WorldPosition = origin
    laser.Attachment1.WorldPosition = origin + direction

    table.insert(self.ActiveLasers, laser)

    return laser
end

function LaserModule:MirrorSet(mirror: Instance, mirrorConfine: string?)
    mirrorConfine = if mirrorConfine then mirrorConfine else true
    self.CachedMirrors[mirrorConfine] = if self.CachedMirrors[mirrorConfine] then self.CachedMirrors[mirrorConfine] else {}
    table.insert(self.CachedMirrors[mirrorConfine], mirror)
end

function LaserModule:DoLaserSim(source: Instance)
    local direction = source.CFrame.LookVector * self.Distance
    local origin = source.Position
    local part = source

    for _ = 1, self.ReflectLimit do

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {self.ActiveLasers, self.CachedSources}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local result = workspace:Raycast(origin, direction, raycastParams)
        local laser = self:ShowBeam(origin, result and result.Position - origin or direction)

        if not result or not self:IsMirror(result.Instance) then return end

        local lightVector = (result.Position - laser.Position).Unit 
        local reflectionVector = reflect(lightVector, result.Normal)

        part = result.Instance
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
        self.CachedSources[source.Name] = source
    end
    CollectionService:GetInstanceAddedSignal(SOURCE_TAG):Connect(function(source: Instance)
        self.CachedSources[source.Name] = source
    end)

    local arcHandles
    ContextActionService:BindAction("SelectMirror", function(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            local target = Mouse.Target

            if not self:IsMirror(target) then
                print("Not mirror")
                return
            end

            if arcHandles then
                arcHandles:Destroy()

                if arcHandles.Adornee == target then
                    arcHandles = nil
                    return
                end
            end

            arcHandles = Instance.new("ArcHandles")
            arcHandles.Adornee = target
            arcHandles.Parent = Player:WaitForChild("PlayerGui")

            local lastCFrame = CFrame.new()
            arcHandles.MouseDrag:Connect(function(axis, relativeAngle, delta)
                target.CFrame = lastCFrame * CFrame.Angles(unpack(AngleFromAxis(axis, relativeAngle)))
            end)

            arcHandles.MouseButton1Down:Connect(function()
                lastCFrame = target.CFrame
            end)
        end
    end, false, Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch)

    RunService.Heartbeat:Connect(function(deltaTime)
        self:Clear()

        for _, source in pairs(self.CachedSources) do
            self:DoLaserSim(source)
        end
    end)

end
LaserModule:Start()

return LaserModule