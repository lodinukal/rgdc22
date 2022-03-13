local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local setFrequency = RDL.setFrequency

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
    self.Update:Disconnect()
end

function Spider:init()
    setFrequency(10, function(...)
        print(...)
    end)
end

return Spider