local SoundService = game:GetService("SoundService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BattleFolder = workspace:WaitForChild("Boss")
local Invader = BattleFolder:WaitForChild("Invader")
local CameraPart = BattleFolder:WaitForChild("Camera")
local Projectile = BattleFolder:WaitForChild("Projectile")
local ShootPart = Invader:WaitForChild("ShootPart")
local BoundBox = BattleFolder:WaitForChild("BoundBox")

local Particles = ReplicatedStorage:WaitForChild("Particles")
local Hit = Particles:WaitForChild("Hit")

local Ship = BattleFolder:WaitForChild("Ship") :: Model

local BossTransition = require(script.Parent.Parent.Gui.BossTransition)
local Dialogue = require(script.Parent.Parent.Gui.Dialogue)
local BossBattle = require(script.Parent.Parent.Gui.BossBattle)

local Boundaries = {
    BattleFolder:WaitForChild("ShipEdgeL"),
    BattleFolder:WaitForChild("ShipEdgeU")
} :: {BasePart}

local BossRoar = SoundService:WaitForChild("Roar")

local oldfirstperson = nil
local FirstPerson = require(script.Parent.FirstPersonModule)
local originalCFrame = Invader.PrimaryPart.CFrame

local Cache = {}
local Started = false
local Projectiles = {}

local ShipPos = 0.5
local SHIP_SPEED_PER = 0.75

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
local actualbossPos = 0.5
local bossPos = 0.5
local function StartBossAnimation()
    local amplitude = 120
    local elapsed = 0
    local seed = math.random(1, 100)
    Bind("boss_mesh", Enum.RenderPriority.Camera.Value, function(delta)
        elapsed += delta
        -- Invader:SetPrimaryPartCFrame(originalCFrame + Vector3.new(math.cos(elapsed/2) * 2, math.sin(elapsed/2) * amplitude, 0))
        -- bossPos += math.noise(seed, 112, elapsed)
        bossPos = math.clamp(bossPos, -1, 1)
        actualbossPos = actualbossPos + (bossPos - actualbossPos) * 0.95 * delta
        Invader:SetPrimaryPartCFrame(originalCFrame + Vector3.new(0, actualbossPos * amplitude, 0))
        -- Invader:SetPrimaryPartCFrame(originalCFrame + Vector3.new(0, math.noise(seed, 112, elapsed) * 3, 0))
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

    task.spawn(function()
        for i = #Projectiles, 1, -1 do
            local projectile = Projectiles[i]
            local part = projectile.Part
            part:Destroy()
            table.remove(Projectiles, i)
        end
    end)

    RenderStepCleanup()
end

local function CleanupLate()
	workspace.CurrentCamera.CameraType = oldfirstperson
    FirstPerson:Start()
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

local function Move1()
    local newProjectile = Projectile:Clone()
    newProjectile.CFrame = ShootPart.CFrame
    newProjectile.Parent = BattleFolder
    newProjectile.CFrame *= CFrame.Angles(0, 0, math.rad(math.random(-10, 10)))

    table.insert(Projectiles, {
        Part = newProjectile
    })
end

local function Move1d2()
    local newProjectile = Projectile:Clone()
    newProjectile.CFrame = ShootPart.CFrame
    newProjectile.Parent = BattleFolder
    newProjectile.CFrame *= CFrame.Angles(0, 0, math.rad(math.random(-10, 10)))

    local newProjectile2 = Projectile:Clone()
    newProjectile2.CFrame = ShootPart.CFrame
    newProjectile2.Parent = BattleFolder
    newProjectile2.CFrame *= CFrame.Angles(0, 0, math.rad(math.random(-10, 10)))

    table.insert(Projectiles, {
        Part = newProjectile
    })
    table.insert(Projectiles, {
        Part = newProjectile2
    })
end

local function GetBulletRotation(arc, count, index)
    return math.rad((-arc/2) + (arc / count * (index - 1)))
end

local function Move2()
    for i = 1, 3 do
        local newProjectile = Projectile:Clone()
        -- newProjectile.CFrame = ShootPart.CFrame * CFrame.Angles(GetBulletRotation(40, 3, i), 0, 0)
        newProjectile.CFrame = ShootPart.CFrame * CFrame.new(0, -60 + (20 * (i - 1)), 0)
        newProjectile.Parent = BattleFolder
    
        table.insert(Projectiles, {
            Part = newProjectile
        })
    end
end

local function Move3()
    bossPos = 1
    task.wait(2)
    for i = 1, 5 do
        bossPos = 1 - 0.4 * i
        task.wait(1)
        Move1()
    end
end

local function Move4()
    for i = 1, 4 do
        bossPos = math.random(-1, 1)
        task.wait(1)
        Move1d2()
    end
end

local function Dodge()
    local x = math.sign(bossPos)

    bossPos += -x * (math.random(6, 12) / 10)
end

local recMode = false
local function Fire()
    if recMode then
        return
    end

    if BossBattle.bossPhase:get() == 1 and enabled then
        local random = math.random(1, 4)
        local dodgeRandom = math.random(1, 30)
        if random < 2 then
            Move1()
        elseif random < 3 then
            Move2()
        elseif random < 4 then
            Move3()
        end
        if dodgeRandom < 20 then
            Dodge()
        end
    else
        local random = math.random(1, 4)
        local dodgeRandom = math.random(1, 30)
        if random < 2 then
            Move2()
        elseif random < 3 then
            Move3()
        elseif random < 4 then
            Move4()
        end
        if dodgeRandom < 25 then
            Dodge()
        end
    end
end

local function BossDeath()
    Cleanup()
end

local function HitBoss()
    if recMode then
        return
    end
    BossBattle.bossHealth:set(BossBattle.bossHealth:get() - 4)
    if BossBattle.bossHealth:get() <= 0 then
        if BossBattle.bossPhase:get() == 1 then
            Dialogue.enabled:set(true)
            recMode = true
            Dialogue.event:Fire("Space Invader", {
                "This isn't over. Death is enshrined in your fortune.",
            })
            task.wait(1)
            -- TODO: Effects
            BossBattle.Phase2()
            Energise()
            Invader.PrimaryPart.Color = Color3.fromRGB(148, 20, 245)
            task.wait(2)
            Energise()
            task.wait(2)
            Energise()
            recMode = false
        else
            Dialogue.enabled:set(true)
            Dialogue.event:Fire("Space Invader", {
                "H|-||H|ow|, d|-d||id| y|o||u||, -",
            })
            recMode = true
            Energise()
            BossDeath()
            -- TODO: Death fx
            -- TODO: Congrats screen
        end
    end
end

local function HitUs()
    BossBattle.shipHealth:set(BossBattle.shipHealth:get() - 1)
    if BossBattle.shipHealth:get() <= 0 then
        Dialogue.enabled:set(true)
        Cleanup()
        Dialogue.event:Fire("Space Invader", {
            "Goodbye,| cosmonaut,| rest with your weak brethern.",
        })
        -- TODO: respawn
        Dialogue.completed:Wait()
        BossBattle.ResetBattleState()
        BossBattle.enabled:set(false)

        CleanupLate()
        task.wait()
        Players.LocalPlayer.Character.Humanoid.Health = 0

        -- task.wait(5)
		-- shared.Levels:ResetLevel()
    end
end

local function Simulate()
    Bind("bullet_checks", Enum.RenderPriority.Character.Value, function(deltaTime)
        for i = #Projectiles, 1, -1 do
            local projectile = Projectiles[i]
            if not projectile then
                return
            end
            local part = projectile.Part

            part.CFrame *= CFrame.new(0,0, -80*deltaTime)

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {Invader, if projectile.reflected then nil else Ship.Shield, BoundBox}
            params.FilterType = Enum.RaycastFilterType.Whitelist

            local result = workspace:Raycast(part.Position, part.CFrame.LookVector * 2, params)
            if not result then
                result = workspace:Raycast(part.Position, -part.CFrame.LookVector * 2, params)
            end
            if result then
                if result.Instance:IsDescendantOf(Invader) then
                    table.remove(Projectiles, i)
                    part:Destroy()
                    HitBoss()
                elseif result.Instance == Ship.Shield then
                    local d = part.CFrame.LookVector
                    local n = result.Normal
                    local reflectedNormal = d - (2 * d:Dot(n) * n)
                    part.CFrame = CFrame.lookAt(part.Position, part.Position + reflectedNormal)
                    projectile.reflected = true
                elseif result.Instance == BoundBox then
                    table.remove(Projectiles, i)
                    part:Destroy()
                    HitUs()
                end
            end
        end
    end)
end

local function Begin(self)
    if Started then
        Cleanup()
    end

    Invader.PrimaryPart.Color = Color3.fromRGB(245, 72, 20)

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

    

    while enabled and task.wait(if BossBattle.bossPhase:get() == 1 then 1 else 0.5) do
        Fire()
    end
end

return {
    Begin = Begin,
    Cleanup = Cleanup
}