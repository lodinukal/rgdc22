local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Data = {
	Folder = Levels:WaitForChild("Level1"),
}

local function OnLoaded(self, map)

end

local function OnUnloaded(self, map)

end

local function CanProceed()
	return true
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed
}
