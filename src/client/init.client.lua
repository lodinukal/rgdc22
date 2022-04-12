local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local screen = require(Gui:WaitForChild("LoadingScreen"))

local Modality = require(Modules:WaitForChild("Modality"))
Modality:Start()

local coreCall do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService('StarterGui')
	local RunService = game:GetService('RunService')

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

local PhysicsSwitcher = require(Gui:WaitForChild("PhysicsSwitcher"))
local BossBattle = require(Gui:WaitForChild("BossBattle"))
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
            BossBattle.enabled:set(false)

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

local CameraModule = require(Modules:WaitForChild("CameraModule"))
local PhysicsModule = require(Modules:WaitForChild("Physics"))
PhysicsModule:Start()
local FirstPersonModule = require(Modules:WaitForChild("FirstPersonModule"))
FirstPersonModule:Start()
local Laser = require(Modules:WaitForChild("Laser"))

local Time = require(Modules:WaitForChild("Time"))
local Traps = require(Modules:WaitForChild("Traps"))
local Explosions = require(Modules:WaitForChild("Explosions"))

task.wait(3)
screen:Destroy()

assert(coreCall('SetCore', 'ResetButtonCallback', false))
local LevelModule = require(Modules:WaitForChild("LevelModule"))
LevelModule:Start()

local Player = game.Players.LocalPlayer
