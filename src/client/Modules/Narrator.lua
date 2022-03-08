local RunService = game:GetService("RunService")

local Player = game:GetService("Players").LocalPlayer

local speed = 1
local amplitude = 2
local narrator = workspace:WaitForChild("Narrator") :: Model

local ThrowModule = require(script.Parent:WaitForChild("ThrowModule"))

local hit = script:WaitForChild("Part"):WaitForChild("Hit")

local Narrator = {}

function Narrator:StartBobbing()
	local originalCFrame = narrator:GetPrimaryPartCFrame()
	local phase = 0
	self.BobbingConnection = RunService.Heartbeat:Connect(function(deltaTime)
		phase += deltaTime * speed

		local cframe = originalCFrame * CFrame.new(0, math.sin(phase) * amplitude, 0)

		local character = Player.Character
		if character and character.PrimaryPart then
			local lookAt = CFrame.lookAt(cframe.Position, character:GetPrimaryPartCFrame().Position)
			narrator:SetPrimaryPartCFrame(lookAt)
		else
			narrator:SetPrimaryPartCFrame(cframe)
		end
	end)
end

function Narrator:TakeHit(data)
	if not data.Instance:IsDescendantOf(narrator) then
		return
	end

	self.BobbingConnection:Disconnect()

	local newHit = hit:Clone()
	newHit.CFrame = CFrame.new(data.Position):ToObjectSpace(data.Instance.CFrame)
	newHit.ParticleEmitter:Emit(10)
	newHit.Parent = narrator.PrimaryPart

	task.delay(2, function()
		newHit:Destroy()
		self:StartBobbing()
	end)
end

function Narrator:Start()
	Narrator:StartBobbing()

	ThrowModule.HitSomething:Connect(function(data, item)
		print(data, item)

		self:TakeHit(data)
	end)
end
Narrator:Start()

return Narrator
