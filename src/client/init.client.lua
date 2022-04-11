local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local Modality = require(Modules:WaitForChild("Modality"))
Modality:Start()

local PhysicsSwitcher = require(Gui:WaitForChild("PhysicsSwitcher"))
-- DeathScreen
do
    local openEvent = Signal.new()
    local closeEvent = Signal.new()

    local function CharacterAdded(character)
        closeEvent:Fire()
        shared.physenabled:set(true)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            openEvent:Fire()
            shared.boss:set(false)
        end)
    end

    LocalPlayer.CharacterAdded:Connect(CharacterAdded)
    CharacterAdded(LocalPlayer.CharacterAdded:Wait())

    local DeathScreen = require(Gui:WaitForChild("DeathScreen"))
    DeathScreen {
        EventOpen = openEvent,
        EventClose = closeEvent
    }
    
end
local PhysicsHighLight = require(Gui:WaitForChild("PhysicsHighLight"))
local Dialogue = require(Gui:WaitForChild("Dialogue"))
local BossBattle = require(Gui:WaitForChild("BossBattle"))

local CameraModule = require(Modules:WaitForChild("CameraModule"))
local PhysicsModule = require(Modules:WaitForChild("Physics"))
PhysicsModule:Start()
local FirstPersonModule = require(Modules:WaitForChild("FirstPersonModule"))
FirstPersonModule:Start()
local Laser = require(Modules:WaitForChild("Laser"))

local Time = require(Modules:WaitForChild("Time"))
local Traps = require(Modules:WaitForChild("Traps"))
local Explosions = require(Modules:WaitForChild("Explosions"))

local LevelModule = require(Modules:WaitForChild("LevelModule"))
LevelModule:Start()

local Player = game.Players.LocalPlayer
