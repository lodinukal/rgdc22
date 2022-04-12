local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage.Common

local Fusion = require(Common.fusion)
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value

local shipHealth = Value(40)
local bossHealth = Value(100)

local shipMaxHealth = Value(40)
local bossMaxHealth = Value(100)

local bossPhase = Value(1)
local bossMaxPhase = Value(2)

local function ResetBattleState()
    bossMaxHealth:set(100)
    shipHealth:set(shipMaxHealth:get())
    bossHealth:set(bossMaxHealth:get())

    bossPhase:set(1)
end

local enabled = Value(false)

local function HealthTab(props)
    return New "Frame" {
        AnchorPoint = props.AnchorPoint,
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Color3.new(0.890196, 0.890196, 0.890196),
        Size = UDim2.new(0.4, 0, 0.1, 0),
        Position = props.Position,

        [Children] = {
            New "UIPadding" {
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
            },
            New "TextLabel" {
                Size = UDim2.new(1, 0, 0.4, 0),
                Position = UDim2.new(0, 0, 0.05),
                BackgroundTransparency = 1,
                TextScaled = true,
                Font = Enum.Font.Highway,
                TextColor3 = Color3.new(0.9, 0.9, 0.9),
                TextStrokeTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = props.Name
            },
            New "Frame" {
                Size = UDim2.new(1, 0, 0.4, 0),
                Position = UDim2.new(0, 0, 0.55, 0),
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Computed(function()
                    return props.darkened[1]:Lerp(props.darkened[2], props.val:get() / props.max:get())
                end),
                [Children] = {
                    New "Frame" {
                        Size = Computed(function()
                            return UDim2.new(props.val:get() / props.max:get(), 0, 1, 0)
                        end),
                        BackgroundColor3 = Computed(function()
                            return props.light[1]:Lerp(props.light[2], props.val:get() / props.max:get())
                        end),
                        BackgroundTransparency = 0.2,
                    },
                    New "TextLabel" {
                        Size = UDim2.new(1, 0, 0.9, 0),
                        Position = UDim2.new(0, 5, 0.05),
                        BackgroundTransparency = 1,
                        TextScaled = true,
                        Font = Enum.Font.Highway,
                        TextColor3 = Color3.new(0.9, 0.9, 0.9),
                        TextStrokeTransparency = 0.5,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = Computed(function()
                            return math.round(props.val:get()) .. " / ".. math.round(props.max:get())
                        end)
                    }
                }
            }
        }
    }    
end

local screenGui = New "ScreenGui" {
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
    DisplayOrder = 9998,
    IgnoreGuiInset = true,
    Enabled = enabled,
    [Children] = {
        HealthTab {
            Name = "You",
            Position = UDim2.new(0.1, 0, 0, 20),
            val = shipHealth,
            max = shipMaxHealth,
            darkened = {
                Color3.new(0.745098, 0.149019, 0.149019),
                Color3.new(0.149019, 0.427450, 0.745098)
            },
            light = {
                Color3.new(0.933333, 0.176470, 0.176470),
                Color3.new(0.176470, 0.529411, 0.933333),
            }
        },
        HealthTab {
            Name = "Space Invader",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(0.9, 0, 1, -20),
            val = bossHealth,
            max = bossMaxHealth,
            darkened = {
                Color3.new(0.745098, 0.149019, 0.149019),
                Color3.new(0.745098, 0.388235, 0.149019)
            },  
            light = {
                Color3.new(0.933333, 0.176470, 0.176470),
                Color3.new(0.933333, 0.505882, 0.176470),
            }
        }
    }
}

local function Phase2()
    bossPhase:set(2)
    bossMaxHealth:set(200)
    bossHealth:set(bossMaxHealth:get())
end

ResetBattleState()

return {
    HealthTab = HealthTab,
    bossHealth = bossHealth,
    shipHealth = shipHealth,
    enabled = enabled,

    ResetBattleState = ResetBattleState,

    bossPhase = bossPhase,
    Phase2 = Phase2
}