local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer

local Camera = workspace.CurrentCamera

local FirstPersonModule = {}
FirstPersonModule.Speeds = {
	Normal = 3,
	Walking = 5,
}
FirstPersonModule.Intensities = {
	Normal = 0.5,
	Walking = 1,
}
FirstPersonModule.Smoothness = 0.2

function lerp(start, goal, alpha)
	return start + (goal - start) * alpha
end

function FirstPersonModule:Start()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	local Speeds = self.Speeds
	local Intensities = self.Intensities
	local Smoothness = self.Smoothness

	local Phase = 0
	local Speed = Speeds.Normal
	local Intensity = Intensities.Normal
	RunService:BindToRenderStep("FirstPerson", Enum.RenderPriority.Camera.Value, function(deltaTime)
		local magnitude = humanoid.MoveDirection.Magnitude

		local x
		local y
		local z

		if magnitude > 0 then
			Speed = lerp(Speed, Speeds.Walking, self.Smoothness)
			Phase += deltaTime * Speed

			Intensity = lerp(Intensity, Intensities.Walking, self.Smoothness)
			x = math.cos(Phase) * 0.5
			y = math.sin(Phase) * Intensity
			z = -10
		else
			Speed = lerp(Speed, Speeds.Normal, self.Smoothness)
			Phase += deltaTime * Speed

			Intensity = lerp(Intensity, Intensities.Normal, self.Smoothness)
			x = math.cos(Phase) * 0.5
			y = math.sin(Phase) * Intensity
			z = -10
		end

		local cf = CFrame.lookAt(Vector3.new(x, y, 0), Vector3.new(x * 0.95, y * 0.95, z)) + Camera.CFrame.Position
		Camera.CFrame = Camera.CFrame:Lerp(
			cf * (Camera.CFrame :: CFrame & { Rotation: CFrame }).Rotation,
			self.Smoothness
		)
	end)
end

function FirstPersonModule:Stop()
	RunService:UnbindFromRenderStep("FirstPerson")
end

return FirstPersonModule
