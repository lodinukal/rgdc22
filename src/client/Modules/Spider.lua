local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enemies = ReplicatedStorage:WaitForChild("Enemies")

local spider = Enemies:WaitForChild("Spider")

local Spider = {}
Spider.__index = Spider

local WalkAnimation = Instance.new("Animation")
WalkAnimation.AnimationId = "rbxassetid://9071651045"

function Spider.new(model)
    return setmetatable({
        Model = model
    }, Spider)
end

function Spider:Destroy()
    self.Connection:Disconnect()
    self.Update:Destroy()
end

function Spider:init()
    self.Update = RunService.Heartbeat:Connect(function(deltaTime)
        print(deltaTime)
    end)
end

return Spider