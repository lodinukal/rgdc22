local RunService = game:GetService("RunService")

local Player = game.Players.LocalPlayer

local Camera = workspace.CurrentCamera

local FirstPersonModule = {}
FirstPersonModule.Speeds = {
    Normal = 3,
    Walking = 6
}
FirstPersonModule.Intensities = {
    Normal = 0.5,
    Walking = 0.75
}
FirstPersonModule.Smoothness = 0.2

function FirstPersonModule:Start()
    local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

    local Speeds = self.Speeds
    local Intensities = self.Intensities
    local Smoothness = self.Smoothness

    local IdlePhase = 0
    local WalkingPhase = 0
    RunService:BindToRenderStep("FirstPerson", Enum.RenderPriority.Camera.Value, function(deltaTime) 
        local magnitude = humanoid.MoveDirection.Magnitude

        local x
        local y
        local z

        if magnitude > 0 then
            WalkingPhase += deltaTime * Speeds.Walking

            x = math.cos(WalkingPhase) * 0.5
            y = math.sin(WalkingPhase) * Intensities.Walking
            z = -10
        else
            IdlePhase += deltaTime * Speeds.Normal

            x = math.cos(IdlePhase) * 0.5
            y = math.sin(IdlePhase) * Intensities.Normal
            z = -10
        end

        local cf = CFrame.lookAt(Vector3.new(x, y, 0), Vector3.new(x*0.95, y*0.95, z)) + Camera.CFrame.Position
        Camera.CFrame = Camera.CFrame:Lerp(cf * Camera.CFrame.Rotation, self.Smoothness)
    end)
end

return FirstPersonModule