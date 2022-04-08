local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Spider = require(Modules:WaitForChild("Spider"))

local Door = require(script.Parent.Door)
local Fusion = require(ReplicatedStorage:WaitForChild("Common").fusion)

local Data = {
	Folder = Levels:WaitForChild("Level4"),
}

local Enemies = {}
local gateState = Fusion.Value(false)
local connection = nil

local function OnLoaded(self, map)
	-- for i, v in ipairs(map.enemies:GetChildren()) do
	-- 	local spider = Spider.new(v)
	-- 	spider:init()
	-- end
	Door({
		instance = map:WaitForChild("Gate1"),
		dependingState = gateState :: any,
	})
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		(gateState :: any):set(not not self.LaserModule.ReceiverIded["Level4Gate"])
		map.LaserEnd.Attachment:GetChildren()[1].Color = if (gateState :: any):get()
			then Color3.fromRGB(68, 255, 43)
			else Color3.fromRGB(255, 43, 43)
	end)
end

local function OnUnloaded(self, map)
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function CanProceed(self)
	if not (gateState :: any):get() then
		self.Requirements("H-How did you get past the gate??.")
		return false
	end
	return true
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed,
}
