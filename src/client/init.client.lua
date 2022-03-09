local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local WindLines = require(Modules:WaitForChild("WindLines"))
--local CameraModule = require(Modules:WaitForChild("CameraModule"))

local DeathScreen = require(Gui:WaitForChild("DeathScreen"))

local Player = game.Players.LocalPlayer

WindLines:Init({
	Direction = Vector3.new(1,0,0.3);
	Speed = 20;
	Lifetime = 1.5;
	SpawnRate = 11;
})