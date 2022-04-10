local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local DeathScreen = require(Gui:WaitForChild("DeathScreen"))
local PhysicsHighLight = require(Gui:WaitForChild("PhysicsHighLight"))
local PhysicsSwitcher = require(Gui:WaitForChild("PhysicsSwitcher"))

local CameraModule = require(Modules:WaitForChild("CameraModule"))
local LevelModule = require(Modules:WaitForChild("LevelModule"))
LevelModule:Start()
local PhysicsModule = require(Modules:WaitForChild("Physics"))
PhysicsModule:Start()
local FirstPersonModule = require(Modules:WaitForChild("FirstPersonModule"))
FirstPersonModule:Start()
local Laser = require(Modules:WaitForChild("Laser"))

local Time = require(Modules:WaitForChild("Time"))
local Traps = require(Modules:WaitForChild("Traps"))
local Explosions = require(Modules:WaitForChild("Explosions"))
local Modality = require(Modules:WaitForChild("Modality"))
Modality:Start()

local Player = game.Players.LocalPlayer
