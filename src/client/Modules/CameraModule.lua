local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Camera = workspace.CurrentCamera

local Player = game.Players.LocalPlayer

local CameraModule = {}
CameraModule.MouseFollowing = false
CameraModule.CameraPanId = "CAMERA_PAN"

CameraModule.Sensitivity = 0.6
CameraModule.Smoothness = 0.4

local character = Player.Character or Player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local currentLookAt = root.CFrame.Position
local emulatedLook = root.CFrame.LookVector

local emulatedLookAxisTarget = { 0, 0 }

function CameraModule:Start()
	CameraModule.MouseFollowing = true
	CameraModule.connection = RunService.Heartbeat:Connect(function(deltaTime)
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		character = Player.Character
		if not character and character.PrimaryPart then
			return
		end

		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CameraSubject = nil :: Instance

		local primaryPartCFrame = character:GetPrimaryPartCFrame()
		local cameraCFrame = CFrame.new(primaryPartCFrame.Position + Vector3.new(0, 5, 0) - emulatedLook * 10)
		currentLookAt = currentLookAt:Lerp(primaryPartCFrame.Position, (1 - math.exp(-60 * deltaTime)) * 0.1)
		currentLookAt = Vector3.new(currentLookAt.X, primaryPartCFrame.Y, currentLookAt.Z)

		local calculatedCFrame = Camera.CFrame:Lerp(
			CFrame.lookAt(cameraCFrame.Position, currentLookAt),
			1 - math.exp(-20 * deltaTime)
		)
		Camera.CFrame = calculatedCFrame
	end)

	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		self:HandleAction(input)
	end)
end

function CameraModule:HandleAction(input: InputObject)
	local delta = Vector2.new(input.Delta.x / self.Sensitivity, input.Delta.y / self.Sensitivity)
		* CameraModule.Smoothness

	if not self.MouseFollowing then
		return
	end

	local X = emulatedLookAxisTarget[1] - delta.y
	local Y = emulatedLookAxisTarget[2] + delta.x
	emulatedLookAxisTarget[1] = (if X > 140 then 140 else if X < 40 then 40 else X)
	emulatedLookAxisTarget[2] = (if Y > 360 then Y - 360 else if Y < 0 then Y + 360 else Y)

	emulatedLook = Vector3.new(
		1 * math.cos(math.rad(emulatedLookAxisTarget[2])) * math.sin(math.rad(emulatedLookAxisTarget[1])),
		-1 * math.cos(math.rad(emulatedLookAxisTarget[1])),
		1 * math.sin(math.rad(emulatedLookAxisTarget[2])) * math.sin(math.rad(emulatedLookAxisTarget[1])) --1 * math.cos(emulatedLookAxis[1])
	)
end

function CameraModule:Modal(enable: boolean)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	CameraModule.MouseFollowing = false
end

function CameraModule:Stop()
	CameraModule.MouseFollowing = false
	if CameraModule.connection then
		CameraModule.connection:Disconnect()
	end
end

CameraModule:Start()

return CameraModule
