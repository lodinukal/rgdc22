local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local RDL = require(Common:WaitForChild("RDL"))
local Fusion = require(Common:WaitForChild("fusion"))

local Dialogue = require(script.Parent.Dialogue)

return function(parent)
    local enabled = Fusion.Value(false)

    local d = Dialogue.Component {
        enabled = enabled
    }
    d.Parent = parent

    Dialogue.event:Fire("spog", {
        "Hi boo!",
        "How are you?",
        "Good?| Well I'm good as well."
    })

    task.spawn(function()
        task.wait(5)
        enabled:set(true)
    end)

    return function()
        d:Destroy()
    end
end