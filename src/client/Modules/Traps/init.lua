local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local FIRE_TRAP_TAG = "wp_firetrap"
local FireTrapEnabled = {}
local FireTrapConnectionCache = {}
local FireTrapsHumanoidCache = {}

local function HandleHit(part: BasePart, trap)
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if FireTrapsHumanoidCache[humanoid] and FireTrapsHumanoidCache[humanoid][1] == trap then
			FireTrapsHumanoidCache[humanoid][2] = FireTrapsHumanoidCache[humanoid][2] + 1
		else
			FireTrapsHumanoidCache[humanoid] = { trap, 1 }
		end
	end
end

local function HandleUnhit(part: BasePart)
	local humanoid = part.Parent:FindFirstChildOfClass("Humanoid")
	if humanoid and FireTrapsHumanoidCache[humanoid] then
		FireTrapsHumanoidCache[humanoid][2] -= 1
		if FireTrapsHumanoidCache[humanoid][2] <= 0 then
			FireTrapsHumanoidCache[humanoid] = nil
		end
	end
end

local function SetFireTrap(fireTrap: Model, bool: boolean)
	FireTrapEnabled[fireTrap] = bool
	local src = fireTrap:WaitForChild("Source")
	for _, child in ipairs(src:GetChildren()) do
		(child :: any).Enabled = bool
	end
end

local function FireTrapAdded(fireTrap: Model)
	local delay = fireTrap:GetAttribute("Delay") or NumberRange.new(0)
	delay = math.random(delay.Min, delay.Max)
	local active = fireTrap:GetAttribute("DurationActive") or 2
	local durationRest = fireTrap:GetAttribute("DurationRest") or 3
	FireTrapConnectionCache[fireTrap] = {
		fireTrap.PrimaryPart.Touched:Connect(function(hit)
			HandleHit(hit, fireTrap)
		end),
		fireTrap.PrimaryPart.TouchEnded:Connect(function(hit)
			HandleUnhit(hit)
		end),
	}
	task.spawn(function()
		SetFireTrap(fireTrap, false)
		task.wait(delay)
		while FireTrapConnectionCache[fireTrap] and fireTrap:IsDescendantOf(workspace) and task.wait() do
			SetFireTrap(fireTrap, true)
			task.wait(active)
			SetFireTrap(fireTrap, false)
			task.wait(durationRest)
		end
	end)
end

local function FireTrapRemoved(fireTrap: Model)
	if FireTrapConnectionCache[fireTrap] then
		FireTrapEnabled[fireTrap] = nil
		FireTrapConnectionCache[fireTrap][1]:Disconnect()
		FireTrapConnectionCache[fireTrap][2]:Disconnect()
		FireTrapConnectionCache[fireTrap] = nil
	end
end

for _, fireTrap in ipairs(CollectionService:GetTagged(FIRE_TRAP_TAG)) do
	task.spawn(FireTrapAdded, fireTrap)
end
CollectionService:GetInstanceAddedSignal(FIRE_TRAP_TAG):Connect(FireTrapAdded)
CollectionService:GetInstanceRemovedSignal(FIRE_TRAP_TAG):Connect(FireTrapRemoved)

local FireTrapDamage = 80
RunService.Heartbeat:Connect(function(deltaTime)
	for humanoid: Humanoid, trap in pairs(FireTrapsHumanoidCache) do
		if FireTrapEnabled[trap[1]] then
			humanoid:TakeDamage(FireTrapDamage * deltaTime)
		end
	end
end)

return {}
