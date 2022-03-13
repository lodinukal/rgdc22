local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Data = {
	Folder = Levels:WaitForChild("Level2"),
}

local function OnLoaded(self, map)
	print("I loaded!")
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
}
