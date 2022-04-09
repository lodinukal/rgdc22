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
	Folder = Levels:WaitForChild("Level6"),
}

local Enemies = {}
local jumpStart = Fusion.Value(false)
local final = Fusion.Value(false)
local connection = nil

local function OnLoaded(self, map)
	-- for i, v in ipairs(map.enemies:GetChildren()) do
	-- 	local spider = Spider.new(v)
	-- 	spider:init()
	-- end
	Door({
		instance = map:WaitForChild("Sec1"),
		dependingState = final :: any,
	})
	Door({
		instance = map:WaitForChild("Sec2"),
		dependingState = final :: any,
	})
	Door({
		instance = map:WaitForChild("Sec3"),
		dependingState = jumpStart :: any,
	})
	Door({
		instance = map:WaitForChild("Sec4"),
		dependingState = jumpStart :: any,
	})
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		if jumpStart:get() == false then
			(jumpStart :: any):set(not not self.LaserModule.ReceiverIded["Level6Jump"])
			-- TODO: Play Zap sound effect
		else
			(final :: any):set(not not self.LaserModule.ReceiverIded["Level6Unlock"])
		end

		LaserColourUtils:SetColouration(map.LaserEnd1, jumpStart)
		LaserColourUtils:SetColouration(map.LaserEnd2, final)
	end)
end

local function OnUnloaded(self, map)
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function CanProceed(self)
	if not (final :: any):get() then
		self.Requirements("Security gates are still locked.")
		return false
	end
	if not (jumpStart :: any):get() then
		self.Requirements("The reactor is still offline.")
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
