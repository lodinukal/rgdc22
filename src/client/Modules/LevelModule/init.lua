local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local LightOn = ReplicatedStorage:WaitForChild("LightOn")

local ZonePlus = require(Common:WaitForChild("ZonePlus"))
local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Gui = Client:WaitForChild("Gui")

local LevelTransition = require(Gui:WaitForChild("LevelTransition"))

local LevelModules = {
    ["Level 1"] = require(script:WaitForChild("Level1")),
    ["Level 2"] = require(script:WaitForChild("Level2"))
}

local LevelModule = {}

function LevelModule:Start()
    self.LevelledUp = Signal.new()
    self.Gui = LevelTransition {
        LevelledUp = self.LevelledUp
    }

    self.Character = Player.Character or Player.CharacterAdded:Wait()
    LevelModule:LoadLevel("Level 2")
end

function LevelModule:LoadLevel(levelName)
    local levelModule = LevelModules[levelName]
    if not levelModule then
        return
    end

    local clonedLevelFolder = levelModule.Data.Folder:Clone()
    local lightsFolder = clonedLevelFolder:FindFirstChild("lights")

    if lightsFolder then
        local lightsFolderChildren = lightsFolder:GetChildren()
        for _, set in ipairs(lightsFolderChildren) do
            for _, light in ipairs(set:GetDescendants()) do
                if not light:IsA("Light") then
                    continue
                end
                light.Enabled = false
            end
        end
    
        table.sort(lightsFolderChildren, function(a,b)
            return a:GetFullName() < b:GetFullName()
        end)

        task.spawn(function()
            for _, set in ipairs(lightsFolderChildren) do

                task.wait(1)

                local clonedLightOn = LightOn:Clone()
                clonedLightOn:Play()
                task.spawn(function()
                    clonedLightOn.Ended:Wait()
                    clonedLightOn:Destroy()
                end)
                clonedLightOn.Parent = set
        
                for _, light in ipairs(set:GetDescendants()) do
                    if not light:IsA("Light") then
                        continue
                    end
        
                    light.Enabled = true
                end
                
            end
        end)
    end

    clonedLevelFolder.Parent = workspace

    Player.Character:SetPrimaryPartCFrame(clonedLevelFolder.spawn.CFrame)

    self.LevelledUp:Fire(levelName)

    levelModule.OnLoaded(clonedLevelFolder)

    local zone = ZonePlus.new(clonedLevelFolder.exit)
    local hrp = self.Character:WaitForChild("HumanoidRootPart")
    zone:onItemEnter(hrp, function()
        print("Hit exit")
    end)
end

return LevelModule