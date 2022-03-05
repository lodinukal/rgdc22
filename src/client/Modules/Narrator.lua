local RunService = game:GetService("RunService")

local Player = game:GetService("Players").LocalPlayer

local speed = 1
local amplitude = 2
local narrator = workspace:WaitForChild("Narrator") :: Model

local Narrator = {}

function Narrator.BeginBobbing()
	local originalCFrame = narrator:GetPrimaryPartCFrame()
	local phase = 0
	RunService.Heartbeat:Connect(function(deltaTime)
		phase += deltaTime * speed

		local cframe = originalCFrame * CFrame.new(0, math.sin(phase) * amplitude, 0)

		local character = Player.Character
		if character then
			local lookAt = CFrame.lookAt(cframe.Position, character:GetPrimaryPartCFrame().Position)
			narrator:SetPrimaryPartCFrame(lookAt)
		else
			narrator:SetPrimaryPartCFrame(cframe)
		end
	end)
end

Narrator.BeginBobbing()

return Narrator
