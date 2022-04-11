local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local SoundService = game:GetService("SoundService")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value
local Observer = Fusion.Observer
local OnEvent = Fusion.OnEvent

local PAUSE_TIMES = {
    [","] = 0.1,
    ["."] = 0.3
}

local sound = SoundService:WaitForChild("Speech") :: Sound

local PROGRESS_TIME = 0.05
local PIPE_PAUSE = 0.2
local BETWEEN = 0.6
local skipped = false

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.F then
        skipped = true
    end
end)

local function StartGraphemes(textState, out)
    local text = textState:get()
    local compiled = ""
    skipped = false
    sound:Play()
    for i, c in utf8.codes(text) do
        local char = utf8.char(c)
        if char == "|" then
            if not skipped then
                task.wait(PIPE_PAUSE)
            end
        else
            compiled ..= char
            if not skipped then
                task.wait(PAUSE_TIMES[char] or PROGRESS_TIME)
            end
        end
        out:set(compiled)
    end
    sound:Pause()
end

local newDialogue = RDL.Signal.new()
local completed = RDL.Signal.new()

function Dialogue(props: {enabled: Fusion.State<boolean>}) : Instance

    local speakerName = Value("")
    local dialogueText = Value("")
    local outputText = Value("")
    local blocking = false

    local bin = {}

    RunService:BindToRenderStep("wp_dialogue", Enum.RenderPriority.Input.Value, function(delta)
        if not bin[1] then
            props.enabled:set(false)
            return
        end
        if not props.enabled:get() or blocking then
            return
        end
        blocking = true
        local name = bin[1].name
        local textList = bin[1].textList
        speakerName:set(name)
        for _, text in ipairs(textList) do
            dialogueText:set(text)
            StartGraphemes(dialogueText, outputText)
            task.wait(BETWEEN)
        end
        task.wait(0.4)
        table.remove(bin, 1)
        completed:Fire()
        blocking = false
    end)

    newDialogue:Connect(function(name, textList)
        table.insert(bin, {name = name, textList = textList})
    end)

    local computedTransparency = Computed(function()
        return if props.enabled:get() then 0 else 1
    end)
    local tweenedTransparency = Tween(computedTransparency, TweenInfo.new(0.3))

    return New "ScreenGui" {
        ResetOnSpawn = false,
        Enabled = true,
        [Children] = {
            New "Frame" {
                Size = UDim2.new(1, 0, 0.2, 0),
                BackgroundColor3 = Color3.new(0.172549, 0.274509, 0.345098),
                BackgroundTransparency = Computed(function()
                    return 1 - 0.4 * (1 - tweenedTransparency:get())
                end),
                Position = UDim2.new(0, 0, 0.6, 0),
                [OnEvent "InputBegan"] = function(inputObject: InputObject)
                    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                        skipped = true
                    end
                end,

                [Children] = {
                    New "UIPadding" {
                        Name = "UIPadding",
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0.1, 0),
                        PaddingRight = UDim.new(0.1, 0),
                        PaddingTop = UDim.new(0, 10),
                    },
                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        TextScaled = true,
                        Font = Enum.Font.Highway,
                        TextColor3 = Color3.new(0.9, 0.9, 0.9),
                        TextStrokeTransparency = tweenedTransparency,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTransparency = tweenedTransparency,
                        Text = speakerName,
                        Size = UDim2.new(1, 0, 0.25, 0)
                    },
                    New "TextLabel" {
                        BackgroundTransparency = 1,
                        TextSize = 19,
                        Font = Enum.Font.Highway,
                        TextColor3 = Color3.new(0.9, 0.9, 0.9),
                        TextStrokeTransparency = tweenedTransparency,
                        TextTransparency = tweenedTransparency,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        Text = outputText,
                        Position = UDim2.new(0, 0, 0.3, 0),
                        Size = UDim2.new(1, 0, 0.7, 0),
                        [Children] = {
                            New("TextLabel")({
                                Name = "KeyboardPrompt",
                                Font = Enum.Font.Highway,
                                RichText = true,
                                Text = "F to skip",
                                TextColor3 = Color3.fromRGB(213, 213, 213),
                                TextScaled = true,
                                TextSize = 14,
                                TextStrokeTransparency = tweenedTransparency,
                                TextTransparency = tweenedTransparency,
                                TextWrapped = true,
                                AnchorPoint = Vector2.new(1, 0.2),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BackgroundTransparency = 1,
                                Position = UDim2.fromScale(0.3, 1),
                                Size = UDim2.fromScale(0.4, 0.3),
    
                                [Children] = {
                                    New("UIAspectRatioConstraint")({
                                        Name = "UIAspectRatioConstraint",
                                        AspectRatio = 4,
                                    }),
                                },
                            })
                        }
                    }
                }
            },
        }
    }
end

local enabled = Value(false)

local d = Dialogue {
    enabled = enabled
}
d.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

return {
    Component = Dialogue,
    event = newDialogue,
    enabled = enabled,
    completed = completed
}