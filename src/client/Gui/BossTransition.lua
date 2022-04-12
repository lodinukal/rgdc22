local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value

local state = Value(false)
local transparency = Computed(function()
    return if state:get() then 0 else 1
end)
local tweened = Tween(transparency, TweenInfo.new(0.8))

local screenGui = New "ScreenGui" {
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    DisplayOrder = 9998,
    IgnoreGuiInset = true,
    Name = "re",
    [Children] = {
        New "Frame" {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
            BackgroundTransparency = tweened
        }
    }
}

return state