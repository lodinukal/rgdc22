local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local CameraModule = require(Modules:WaitForChild("CameraModule"))
local PhysicsModule = require(Modules:WaitForChild("Physics"))
PhysicsModule:Start()

local DeathScreen = require(Gui:WaitForChild("DeathScreen"))
local PhysicsHighLight = require(Gui:WaitForChild("PhysicsHighLight"))

local Player = game.Players.LocalPlayer

local e = workspace:WaitForChild("scale")

while task.wait(3) do
	PhysicsModule:ChangeTarget(e)
	task.wait(3)
	PhysicsModule:ChangeTarget(nil :: BasePart)
end
