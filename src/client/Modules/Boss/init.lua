local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local BattleFolder = workspace:WaitForChild("Boss")
local Invader = BattleFolder:WaitForChild("Invader")
local CameraPart = BattleFolder:WaitForChild("Camera")
local Projectile = BattleFolder:WaitForChild("Projectile")
local ShootPart = Invader:WaitForChild("ShootPart")

local Dialogue = require(script.Parent.Parent.Gui.Dialogue)

local BossRoar = SoundService:WaitForChild("Roar")

local Cache = {}
local Started = false

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

local function StartLoopingAnimations()
    StartBossAnimation()
    CameraSwivels()
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
    newProjectile:ApplyImpulse(ShootPart.CFrame.LookVector * 100)
end

local function Begin(self)
    if Started then
        Cleanup()
    end

    Started = true
    OrganiseStartup()
    StartLoopingAnimations()

    -- Taunt
    task.wait(1)
    Dialogue.enabled:set(true)
	Dialogue.event:Fire("Space Invader", {
		"P|R|E|P|A|R|E| T|O| P|E|R|I|S|H.",
	})
    task.wait(0.4)
    Energise()

    while task.wait(math.random(3, 6)) do
        Fire()
    end
end

return {
    Begin = Begin,
    Cleanup = Cleanup
}