local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value

local function LevelTransition(props)
    local levelName = Value("Level 1")
    local anchorPoint = Value(Vector2.new(0.5, 0))

    local popUp = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
    local popDown = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)

    local tweenInfo = Value(popUp)
    local tween = Tween(anchorPoint, Computed(function()
        return tweenInfo:get()
    end))

    local gui = New "ScreenGui" {
        IgnoreGuiInset = true,
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        [Children] = {
            New "TextLabel" {
                AnchorPoint = Computed(function()
                    return tween:get()
                end),
                Position = UDim2.fromScale(0.5, 1),
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.1),
                Text = Computed(function()
                    return levelName:get()
                end),
                Font = Enum.Font.GothamSemibold,
                TextSize = 40,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }
        }
    }

    props.LevelledUp:Connect(function(name)
        levelName:set(name)
        tweenInfo:set(popUp)
        anchorPoint:set(Vector2.new(0.5, 1))
        task.wait(2)
        tweenInfo:set(popDown)
        anchorPoint:set(Vector2.new(0.5, 0))
    end)

    return gui
end

return LevelTransition