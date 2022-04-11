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

local function Cleanup()
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
    newProjectile.Anchored = false
    newProjectile.Parent = BattleFolder
    newProjectile:ApplyImpulse(ShootPart.CFrame.LookVector * math.random(150, 300))

    local connection
    connection = newProjectile.AncestryChanged:Connect(function(child, parent)
        connection:Disconnect()
        Projectiles[newProjectile] = nil
    end)

    Projectiles[newProjectile] = connection
end

local function OnHit(projectileCFrame)
    local newHit = Hit:Clone()
    newHit.CFrame = projectileCFrame
    newHit.Parent = BattleFolder

    task.spawn(function()
        for i, v in ipairs(newHit:GetChildren()) do
            v:Emit()
        end

        task.wait(2)

        newHit:Destroy()
    end)
end

local function HitDetection()
    RunService.Heartbeat:Connect(function(deltaTime)
        for i, v in pairs(Projectiles) do
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {Ship}
            params.FilterType = Enum.RaycastFilterType.Whitelist
            local result = workspace:Raycast(i.Position, i.CFrame.LookVector, params)
            if result then
                OnHit(i.CFrame)
                v:Disconnect()
                Projectiles[i] = nil
                i:Destroy()
            end
        end
    end)
end


local function Begin(self)
    if Started then
        Cleanup()
    end

    Started = true
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
    HitDetection()

    while task.wait(1) do
        Fire()
    end
end

return {
    Begin = Begin,
    Cleanup = Cleanup
}