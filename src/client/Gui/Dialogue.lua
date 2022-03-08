local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween

local function Dialogue(props)
    local maxVisibleGraphemes = Fusion.Value(0)
    local size = Fusion.Value(UDim2.fromScale(0, 0))
    local visible = Fusion.Value(false)
    local tween = Tween(size, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0))
    local text = Fusion.Value("")

    local dialogue = New "ScreenGui" {
        Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        [Children] = {
            New "Frame" {
                ZIndex = 1,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.2,
                Size = Computed(function()
                    return tween:get()
                end),
                

                [Children] = {
                    New "TextLabel" {
                        Size = UDim2.fromScale(1, 0.8),
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.fromScale(0, 1),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = Computed(function()
                            return text:get()
                        end),
                        Font = Enum.Font.Gotham,
                        TextSize = 20,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        MaxVisibleGraphemes = Computed(function()
                            return maxVisibleGraphemes:get()
                        end),
                        RichText = true
                    },
                    New "TextLabel" {
                        Size = UDim2.fromScale(1, 0.2),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = props.Name,
                        Font = Enum.Font.GothamBold,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextSize = 40,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Visible = Computed(function()
                            return visible:get()
                        end),
                        [Children] = {
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0, 8)
                            }
                        }
                    },
                    New "UICorner" {
                        CornerRadius = UDim.new(0, 8)
                    }
                }
            }
        }
    }

    props.Event:Connect(function()
        size:set(UDim2.fromScale(0.5, 0.3))
        task.wait(3)

        visible:set(true)

        for i, v in ipairs(props.Text:get()) do
            text:set(v.Text)

            local index = 0
            for first, last in utf8.graphemes(v.OriginalText or v.Text) do
                index += 1
                maxVisibleGraphemes:set(index)
                task.wait(0.05)
            end
            task.wait(v.FadeTime)
        end
    end)

    return dialogue
end

return Dialogue