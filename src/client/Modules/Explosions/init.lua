local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local EXPLOSIVE_TAG = "wp_explosive"
local BREAK_TAG = "wp_break_wall"
local ExplosiveTracking = {}

local EXPLOSIVE_DURATION = 4
local EXPLOSION_TIME = 2

local LaserModule = require(script.Parent.Laser)

local function GetTagFromId(tag)
    return "explosive_" .. tag
end

local function DealDamageToBreakable(wall: BasePart)
    local health = wall:GetAttribute("Health") or 1
    local maxHealth = wall:GetAttribute("MaxHealth") or 1
    health -= 1
    wall:SetAttribute("Health", health)
    wall.Transparency = 0.4 + 0.6 * (health / maxHealth)
    if health <= 0 then
        wall:Destroy()
        -- TODO: Add VFX for destruction
    end
end

local function Explode(explosive: BasePart)
    local explosion = Instance.new("Explosion")
    explosion.BlastRadius = 8
    explosion.BlastPressure = 10
    explosion.DestroyJointRadiusPercent = 0
    explosion.Position = explosive.Position + Vector3.new(0, 2, 0)
    explosion.Parent = workspace

    explosion.Hit:Connect(function(part, distance)
        if CollectionService:HasTag(part, BREAK_TAG) then
            DealDamageToBreakable(part)
        end
    end)

    explosive:Destroy()
end

local function ExplosiveAdded(explosive: BasePart)
    if not explosive:IsDescendantOf(workspace) then
        return
    end
    local explosiveId = explosive:GetAttribute("Id")
    if not explosiveId then
        return
    end
    local mesh = explosive:FindFirstChildOfClass("SpecialMesh")
    ExplosiveTracking[explosiveId] = 0
    local tagged = GetTagFromId(explosiveId)
    RunService:BindToRenderStep(tagged, Enum.RenderPriority.Last.Value, function(delta)
        local val = ExplosiveTracking[explosiveId]
        if val == nil or val >= EXPLOSIVE_DURATION then
            if val >= EXPLOSIVE_DURATION then
                Explode(explosive)
            end
            return
        end
        val = math.max(0, val + delta * (if (not not LaserModule.ReceiverIded[explosiveId]) then 1 else -1))
        if mesh then
            mesh.VertexColor = Vector3.new(1 + 2 * (val / EXPLOSIVE_DURATION), 1, 1)
        end
        ExplosiveTracking[explosiveId] = val
    end)
end

local function ExplosiveRemoved(explosive: BasePart)
    local explosiveId = explosive:GetAttribute("Id")
    if not explosiveId then
        return
    end
    ExplosiveTracking[explosiveId] = nil
    RunService:UnbindFromRenderStep(GetTagFromId(explosiveId))
end

for _, explosive in ipairs(CollectionService:GetTagged(EXPLOSIVE_TAG)) do
    task.spawn(ExplosiveAdded, explosive) 
end
CollectionService:GetInstanceAddedSignal(EXPLOSIVE_TAG):Connect(ExplosiveAdded)
CollectionService:GetInstanceRemovedSignal(EXPLOSIVE_TAG):Connect(ExplosiveRemoved)

return {}