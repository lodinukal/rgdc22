local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Puzzle1 = workspace:WaitForChild("Puzzle1")

local Mirrors = Puzzle1:WaitForChild("Mirrors")
local LaserDoor1 = Puzzle1:WaitForChild("LaserDoor1")
local LaserDoor2 = Puzzle1:WaitForChild("LaserDoor2")

local LaserSound = script:WaitForChild("LaserSound")
local Beam = script:WaitForChild("Beam")
local BurnEffect = script:WaitForChild("BurnEffect")

local Player = game.Players.LocalPlayer

local Mouse = Player:GetMouse()

local LaserDoor = {}
LaserDoor.__index = LaserDoor

local Radius = 0.5
local Distance = 100

function LaserDoor.__new(startPart, endPart, door)
    return setmetatable({
        Start = startPart,
        End = endPart,
        Door = door,
        Lasers = {}
    }, LaserDoor)
end

local function reflect(lv, nv)
    return lv - 2 * nv * (lv:Dot(nv))
end

function LaserDoor:ShowBeam(origin, direction)
    local part = Instance.new("Part")
    local sound = LaserSound:Clone()
    sound:Play()
    sound.Parent = part

    part.Name = "Laser"
    part.Anchored = true
    
    part.Material = Enum.Material.Neon
    part.Transparency = 1
    
    part.CFrame = CFrame.lookAt(origin + direction/2 , origin)
    part.Size = Vector3.new(Radius, Radius, direction.Magnitude)

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "Attachment0"
    attachment0.Parent = part
    attachment0.WorldPosition = origin

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "Attachment1"
    attachment1.Parent = part
    attachment1.WorldPosition = origin + direction

    local burnEffect = BurnEffect:Clone()
    burnEffect.Enabled = true
    burnEffect.Parent = attachment1

    local beam = Beam:Clone()
    beam.Enabled = true
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
	beam.Parent = part
	
    part.CanCollide = false
	part.Parent = workspace
    
    table.insert(self.Lasers, part)

    return part
end

function LaserDoor.IsMirror(part)
    for i, v in ipairs(Mirrors:GetChildren()) do
        if v ~= part then
            continue
        end

        return true
    end

    return false
end

function LaserDoor:Clear()
    for i, v in ipairs(self.Lasers) do
        v:Destroy()
    end
end

function LaserDoor:Reflect()
    local direction = self.Start.CFrame.LookVector * Distance
    local origin = self.Start.Position 
    local part = self.Start

    local hitMirror = false
    for reflections = 1, (#Mirrors:GetChildren() + 1) do

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {self.Lasers, part}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist 

        local result = workspace:Raycast(origin, direction, raycastParams)
        local laser = self:ShowBeam(origin, result and result.Position - origin or direction)
        
        if result then
            if self.IsMirror(result.Instance) then
                local lightVector = (result.Position - laser.Position).Unit 
                local reflectionVector = reflect(lightVector, result.Normal)
                        
                part = result.Instance
                origin = result.Position 
                direction = reflectionVector * Distance

                self.Door.Transparency = 0
                self.Door.CanCollide = true
            elseif result.Instance == self.End and result.Normal == result.Instance.CFrame.LookVector then
                self.Door.Transparency = 1
                self.Door.CanCollide = false
                break
            end
        else
            self.Door.Transparency = 0
            self.Door.CanCollide = true

            break
        end
    end
end

function LaserDoor:init()
    RunService.Heartbeat:Connect(function(deltaTime)
        self:Clear()
        self:Reflect()
    end)
end

local laserDoors = {
    LaserDoor.__new(
        LaserDoor1:WaitForChild("Start"),
        LaserDoor1:WaitForChild("End"),
        LaserDoor1:WaitForChild("Door")
    ),
    LaserDoor.__new(
        LaserDoor2:WaitForChild("Start"),
        LaserDoor2:WaitForChild("End"),
        LaserDoor2:WaitForChild("Door")
    )
}
for i, v in ipairs(laserDoors) do
    v:init()
end

local increment = 0.01

function round(number)
	return math.floor((number / increment) + 0.5) * increment
end

function AngleFromAxis(axis, r)
	local relativeAngle = math.rad(round(math.deg(r)))
	
	return axis == Enum.Axis.X and {relativeAngle, 0, 0} 
		or axis == Enum.Axis.Y and {0, relativeAngle, 0} 
		or axis == Enum.Axis.Z and {0, 0, relativeAngle}
end

local function arcHandles(adornee)
    local handle = Instance.new("ArcHandles")
    handle.Adornee = adornee
    handle.Parent = Player:WaitForChild("PlayerGui")

    local lastCFrame = CFrame.new()
    handle.MouseDrag:Connect(function(axis, relativeAngle, delta)
        adornee.CFrame = lastCFrame * CFrame.Angles(unpack(AngleFromAxis(axis, relativeAngle)))
    end)

    handle.MouseButton1Down:Connect(function()
        lastCFrame = adornee.CFrame
    end)

    return handle
end

local function handles(adornee)
    local handle = Instance.new("Handles")
    handle.Adornee = adornee
    handle.Parent = Player:WaitForChild("PlayerGui")

    local lastCFrame = CFrame.new()
    handle.MouseDrag:Connect(function(face, distance)
        local newPosition = Vector3.fromNormalId(face) * distance

        adornee.CFrame = lastCFrame * CFrame.new(newPosition)
    end)

    handle.MouseButton1Down:Connect(function()
        lastCFrame = adornee.CFrame
    end)

    return handle
end

local handle
ContextActionService:BindAction("SelectMirror", function(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        local target = Mouse.Target

        if not LaserDoor.IsMirror(target) then
            print("Not mirror")
            return
        end

        if handle then
            handle:Destroy()

            if handle.Adornee == target then
                handle = nil
                return
            end
        end

        handle = arcHandles(target)

        ContextActionService:BindAction("ChangeTranslationMode", function(actionName, inputState, inputObject)
            if inputState == Enum.UserInputState.End then
                if handle:IsA("ArcHandles") then
                    handle:Destroy()
                    handle = handles(target)
                else
                    handle:Destroy()
                    handle = arcHandles(target)
                end
            end
        end, false, Enum.KeyCode.R)
    end
end, false, Enum.UserInputType.MouseButton1)

return LaserDoor