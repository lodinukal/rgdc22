local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Data = {
	Folder = Levels:WaitForChild("Level3"),
}

local doorOpen = false
local connection = nil

local function OnLoaded(self, map)
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		doorOpen = not not self.LaserModule.ReceiverIded["Level2Lights"]
	end)
end

local function OnUnloaded(self, map)
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function CanProceed(self)
	if not doorOpen then
		self.Requirements("The door is locked, illuminate the LASER receiver.")
	end
	return doorOpen
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed,
}
