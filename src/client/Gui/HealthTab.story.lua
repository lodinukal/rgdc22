local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local RDL = require(Common:WaitForChild("RDL"))
local Fusion = require(Common:WaitForChild("fusion"))

local BossBattle = require(script.Parent.BossBattle)

return function(parent)
    local aval = Fusion.Value(40)
    local d = BossBattle.HealthTab {
        Name = "Eggo",
        val = aval,
        max = Fusion.Value(90),
        darkened = {
            Color3.new(0.745098, 0.149019, 0.149019),
            Color3.new(0.149019, 0.427450, 0.745098)
        },
        light = {
            Color3.new(0.933333, 0.176470, 0.176470),
            Color3.new(0.176470, 0.529411, 0.933333),
        }
    }

    local t = task.spawn(function()
        while true do
            aval:set((aval:get() + 8 * task.wait()) % 90)
        end
    end)

    d.Parent = parent

    return function()
        task.cancel(t)
        d:Destroy()
    end
end