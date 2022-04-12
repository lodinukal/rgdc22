local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value

local gfxPos = Value(0)
local computedGfxPosUDIM2 = Computed(function()
    return UDim2.new(0, 0, 0.3 + 0.7 * gfxPos:get())
end)
local tweened = Tween(computedGfxPosUDIM2, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut))

local screen = New "ScreenGui" {
    Name = "Loading",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 10000,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),

    [Children] = {
        New "Frame" {
            Name = "Frame",
            BackgroundColor3 = Color3.fromRGB(30, 37, 44),
            Size = UDim2.fromScale(1, 1),

            [Children] = {
                New "TextLabel" {
                    Name = "TextLabel",
                    Font = Enum.Font.Highway,
                    Text = "loading",
                    TextColor3 = Color3.fromRGB(221, 221, 221),
                    TextScaled = true,
                    TextSize = 14,
                    TextStrokeColor3 = Color3.fromRGB(248, 248, 248),
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundColor3 = Color3.fromRGB(170, 170, 170),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.95),
                    Size = UDim2.fromScale(1, 0.1),
                    ZIndex = 2,

                    [Children] = {
                        New "UIPadding" {
                            Name = "UIPadding",
                            PaddingLeft = UDim.new(0, 10),
                        },
                    }
                },

                New "Frame" {
                    Name = "Frame1",
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Color3.fromRGB(227, 227, 227),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(1, 0),
                    Size = UDim2.fromScale(0.02, 1),

                    [Children] = {
                        New "Frame" {
                            Name = "Frame2",
                            AnchorPoint = Vector2.new(0, 1),
                            BackgroundColor3 = Color3.fromRGB(227, 227, 227),
                            BorderSizePixel = 0,
                            Position = tweened,
                            Size = UDim2.fromScale(1, 0.3),
                        },
                    }
                },
            }
        },
    }
}

task.spawn(function()
    while screen and task.wait(2.5) do
        gfxPos:set(if gfxPos:get() == 1 then 0 else 1)
    end
end)

return screen