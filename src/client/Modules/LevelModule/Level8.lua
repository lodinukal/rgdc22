local RunService = game:GetService("RunService")
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
	Folder = Levels:WaitForChild("Level8"),
}

local BossHealth = Fusion.Value(100)

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
	CanProceed = CanProceed,
}
