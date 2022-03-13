local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local New = Fusion.New
local Computed = Fusion.Computed
local Children = Fusion.Children
local Tween = Fusion.Tween
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent

local Modality = {}

local isModal = Value(false)
local modalUI = New("ScreenGui")({
	Name = "Modality",
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	ResetOnSpawn = false,

	[Children] = {
		New("TextButton")({
			Name = "Context",
			Modal = isModal,
		}),
	},
})

function Modality:Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if
			input.UserInputType == Enum.UserInputType.Keyboard
			and (input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt)
		then
			(isModal :: any):set(not (isModal :: any):get())
		end
	end)
end

return Modality
