local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Mirrors = workspace:WaitForChild("Mirrors")

local Start = Mirrors:WaitForChild("Start")

local LaserSound = script:WaitForChild("LaserSound")
local Beam = script:WaitForChild("Beam")
local BurnEffect = script:WaitForChild("BurnEffect")

local Player = game.Players.LocalPlayer

local Mouse = Player:GetMouse()

local LaserModule = {}
LaserModule.Radius = 0.5
LaserModule.Lasers = {}

function LaserModule:ShowBeam(origin, direction)
    local part = Instance.new("Part")
    local sound = LaserSound:Clone()
    sound:Play()
    sound.Parent = part

    part.Name = "Laser"
    part.Anchored = true
    
    part.Material = Enum.Material.Neon
    part.Transparency = 1
    
    part.CFrame = CFrame.lookAt(origin + direction/2 , origin)
    part.Size = Vector3.new(self.Radius, self.Radius, direction.Magnitude)

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "Attachment0"
    attachment0.Parent = part
    attachment0.WorldPosition = origin

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "Attachment1"
    attachment1.Parent = part
    attachment1.WorldPosition = origin + direction

    local burnEffect = BurnEffect:Clone()
    burnEffect.Parent = attachment1

    local beam = Beam:Clone()
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
	beam.Parent = part
	
    part.CanCollide = false
	part.Parent = workspace
    
    table.insert(self.Lasers, part)

    return part
end

local function reflect(lv, nv)
    return lv - 2 * nv * (lv:Dot(nv))
end

function LaserModule:IsMirror(part)
    for i, v in ipairs(Mirrors:GetChildren()) do
        if v ~= part then
            continue
        end

        return true
    end

    return false
end

local increment = 5

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
    for i, v in ipairs(self.Lasers) do
        v:Destroy()
    end
end

function LaserModule:Start()

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
    end, false, Enum.UserInputType.MouseButton1)

    RunService.Heartbeat:Connect(function(deltaTime)
        self:Clear()

        local direction = Start.CFrame.LookVector * 50
        local origin = Start.Position 
        local part = Start
        
        for reflections = 1, #Mirrors:GetChildren() do
            print(self.Lasers)

            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {self.Lasers, part}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist 

            local result = workspace:Raycast(origin, direction, raycastParams)
            local laser = self:ShowBeam(origin, result and result.Position - origin or direction)
            
            if not result then break end 
            
            local lightVector = (result.Position - laser.Position).Unit 
            local reflectionVector = reflect(lightVector, result.Normal)
            
            part = result.Instance
            origin = result.Position 
            direction = reflectionVector * 50
        end
    end)

end
LaserModule:Start()

return LaserModule