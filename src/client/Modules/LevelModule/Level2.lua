local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Spider = require(Modules:WaitForChild("Spider"))

local Data = {
	Folder = Levels:WaitForChild("Level2"),
}

local Enemies = {}

local function OnLoaded(self, map)
	for i, v in ipairs(map.enemies:GetChildren()) do
		local spider = Spider.new()
		spider:init()
	end
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
