local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Spider = require(Modules:WaitForChild("Spider"))

local Door = require(script.Parent.Door)
local LaserColourUtils = require(script.Parent.LaserColourUtils)
local Fusion = require(ReplicatedStorage:WaitForChild("Common").fusion)

local Data = {
	Folder = Levels:WaitForChild("Level7"),
}

local Enemies = {}
local armouryUnlocked = Fusion.Value(false)

local function OnLoaded(self, map)
	Door {
		instance = map:WaitForChild("Border1"),
		dependingState = armouryUnlocked
	}
	Door {
		instance = map:WaitForChild("Border2"),
		dependingState = armouryUnlocked
	}
	Door {
		instance = map:WaitForChild("Border3"),
		dependingState = armouryUnlocked
	}
end

local function OnUnloaded(self, map) end

local function CanProceed()
	return (#Enemies == 0)
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed,
}
