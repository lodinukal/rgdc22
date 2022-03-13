local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Data = {
	Folder = Levels:WaitForChild("Level2"),
}

local Enemies = {}

local function OnLoaded(self, map)

end

local function OnUnloaded(self, map)
	
end

local function CanProceed()
	return (#Enemies == 0)
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed
}
