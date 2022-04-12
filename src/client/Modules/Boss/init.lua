local SoundService = game:GetService("SoundService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleFolder = workspace:WaitForChild("Boss")
local Invader = BattleFolder:WaitForChild("Invader")
local CameraPart = BattleFolder:WaitForChild("Camera")
local Projectile = BattleFolder:WaitForChild("Projectile")
local ShootPart = Invader:WaitForChild("ShootPart")
local Ship = BattleFolder:WaitForChild("Ship")

local Particles = ReplicatedStorage:WaitForChild("Particles")
local Hit = Particles:WaitForChild("Hit")

local Ship = BattleFolder:WaitForChild("Ship") :: Model

local Dialogue = require(script.Parent.Parent.Gui.Dialogue)
local BossBattle = require(script.Parent.Parent.Gui.BossBattle)

local Boundaries = {
    BattleFolder:WaitForChild("ShipEdgeL"),
    BattleFolder:WaitForChild("ShipEdgeU")
} :: {BasePart}

local BossRoar = SoundService:WaitForChild("Roar")

local oldfirstperson = nil
local FirstPerson = require(script.Parent.FirstPersonModule)

local Cache = {}
local Started = false
local Projectiles = {}

local ShipPos = 0.5
local SHIP_SPEED_PER = 0.5

local function RenderStepCleanup()
    for id, _ in pairs(Cache) do
        RunService:UnbindFromRenderStep(id)
    end
end

local function Bind(id: string, priority: number, fnc: (deltaTime: number) -> nil)
    Cache[id] = true
    RunService:BindToRenderStep(id, priority, fnc)
end

-- Loop
local function StartBossAnimation()
    local amplitude = 60
    local elapsed = 0
    local originalCFrame = Invader.PrimaryPart.CFrame
    Bind("boss_mesh", Enum.RenderPriority.Camera.Value, function(delta)
        elapsed += delta
        Invader:SetPrimaryPartCFrame(originalCFrame + Vector3.new(math.cos(elapsed/2) * 2, math.sin(elapsed/2) * amplitude, 0))
    end)
end

local function CameraSwivels()
    local elapsed = 0
    local camera = workspace.CurrentCamera
    Bind("boss_camera", Enum.RenderPriority.Camera.Value, function(delta)
        elapsed += delta
        camera.CFrame = CameraPart.CFrame + Vector3.new(0, math.sin(elapsed) * 3, 0)
    end)
end

local function UpdateShipPosition()
    Bind("boss_ship", Enum.RenderPriority.Input.Value, function(deltaTime)
        local dir = (if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then -1 else 0) +
            (if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then 1 else 0)

        ShipPos = math.clamp(ShipPos + SHIP_SPEED_PER * dir * deltaTime, 0, 1)
        local lerpedPosition = Boundaries[1].Position:Lerp(Boundaries[2].Position, ShipPos)
        Ship:SetPrimaryPartCFrame(Boundaries[1].CFrame.Rotation + lerpedPosition)
    end)
end

local function StartLoopingAnimations()
    StartBossAnimation()
    CameraSwivels()
    UpdateShipPosition()
end

-- Start

local function OrganiseStartup()
end

local enabled = false
local function Cleanup()
    enabled = false
	workspace.CurrentCamera.CameraType = oldfirstperson
    FirstPerson:Start()
    RenderStepCleanup()
end

local bodyfx = Invader:WaitForChild("Body"):WaitForChild("FX")
local function Energise()
    BossRoar:Play()
    for _, particle: Instance in ipairs(bodyfx:GetChildren()) do
        if particle:IsA("ParticleEmitter") then
            (particle :: ParticleEmitter):Emit()
        end
    end
end

local function Fire()
    local newProjectile = Projectile:Clone()
    newProjectile.CFrame = ShootPart.CFrame
    newProjectile.Parent = BattleFolder

    table.insert(Projectiles, {
        Part = newProjectile,
        MovingBackwards = false
    })
end

local function HitBoss()
    print("Hit!")
end

local function Simulate()
    RunService.Heartbeat:Connect(function(deltaTime)
        for i = #Projectiles, 1, -1 do
            local projectile = Projectiles[i]
            local part = projectile.Part
            local movingBackwards = projectile.MovingBackwards

            part.CFrame *= CFrame.new(0,0, movingBackwards and 60*deltaTime or -60*deltaTime)

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {movingBackwards and Invader or Ship.Shield}
            params.FilterType = Enum.RaycastFilterType.Whitelist

            local result = workspace:Raycast(part.Position, movingBackwards and -part.CFrame.LookVector or part.CFrame.LookVector, params)
            if result then
                if movingBackwards then
                    table.remove(Projectiles, i)
                    part:Destroy()
                    HitBoss()
                else
                    projectile.MovingBackwards = true
                end
            end
        end
    end)
end

local function Begin(self)
    if Started then
        Cleanup()
    end

    Started = true
    enabled = true
    oldfirstperson = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	FirstPerson:Stop()

    OrganiseStartup()
    StartLoopingAnimations()

    BossBattle.enabled:set(true)

    -- Taunt
    task.wait(1)
    Dialogue.enabled:set(true)
	Dialogue.event:Fire("Space Invader", {
		"P|R|E|P|A|R|E| T|O| P|E|R|I|S|H.",
	})
    task.wait(0.4)
    Energise()
    Simulate()

    while task.wait(1) and enabled do
        Fire()
    end
end

return {
    Begin = Begin,
    Cleanup = Cleanup
}