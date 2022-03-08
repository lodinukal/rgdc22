local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local SetNetworkOwner = ReplicatedStorage:WaitForChild("SetNetworkOwner")
local GetNetworkOwner = ReplicatedStorage:WaitForChild("GetNetworkOwner")

local camera = workspace.CurrentCamera
local Common = ReplicatedStorage:WaitForChild("Common")

local Fusion = require(Common:WaitForChild("fusion"))
local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local holdGrip = script:WaitForChild("HoldGrip")

local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

local attachment = Instance.new("Attachment")

local mouse = game.Players.LocalPlayer:GetMouse()

local ThrowModule = {}
ThrowModule.HoldDistance = 8
ThrowModule.ThrowPowerTime = 5
ThrowModule.MinThrowPower = 3
ThrowModule.MaxThrowPower = 30
ThrowModule.MinThrowStudsOffset = 0
ThrowModule.MaxThrowStudsOffset = 4
ThrowModule.HitSomething = Signal.new()
ThrowModule.Throwable = {
	workspace:WaitForChild("Wrench"),
}

function ThrowModule:IsThrowable(part)
	for i, v in ipairs(self.Throwable) do
		if not (part:IsDescendantOf(v)) then
			continue
		end

		return v
	end

	return nil
end

function ThrowModule:Get3DMouse()
	local mouseLocation = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { game.Players.LocalPlayer.Character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * ThrowModule.HoldDistance, params)
	return result
end

local function Lerp(min, max, alpha)
	return (min + ((max - min) * alpha))
end

function ThrowModule:HitDetection(throwPower)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {self.Item, self.HoldGrip, self.Attachment0}

	local result = workspace:Raycast(self.Item:GetPrimaryPartCFrame().Position, camera.CFrame.LookVector * throwPower, params)
	
	if result then
		self.HitSomething:Fire(result, self.Item)
	end
end

function ThrowModule:Hold()
	local target = mouse.Target
	local hit = mouse.Hit

	if not target then
		return
	end
	local model = ThrowModule:IsThrowable(target)
	if not model then
		return
	end
	self.Item = model

	if not GetNetworkOwner:InvokeServer(self.Item.PrimaryPart) then
		SetNetworkOwner:FireServer(self.Item.PrimaryPart)
	end

	self.HoldGrip = holdGrip:Clone()
	self.HoldGrip.Position = character.Head.Position + ((mouse.Hit.Position - character.Head.Position).Unit * self.HoldDistance)
	self.HoldGrip.Parent = workspace

	self.Attachment0 = attachment:Clone()
	self.Attachment0.CFrame = target.CFrame:ToObjectSpace(hit)
	self.Attachment0.Name = "DragAttachment"
	self.Attachment0.Visible = true
	self.Attachment0.Parent = target
	local gripAlignPosition = self.HoldGrip.GripAlignPosition
	gripAlignPosition.Attachment0 = self.Attachment0

	local alpha = 0
	ContextActionService:BindAction("ThrowItem", function(actionName, inputState, inputObj)
		if inputState == Enum.UserInputState.Begin then
			local time = 0
			self.IncreasingForce = RunService.Heartbeat:Connect(function(deltaTime)
				time += deltaTime
				alpha = math.min(1, time/self.ThrowPowerTime)
			end)
		elseif inputState == Enum.UserInputState.End then
			self.IncreasingForce:Disconnect()
			local throwPower = Lerp(self.MinThrowPower, self.MaxThrowPower, alpha)
			print(throwPower)
			model.PrimaryPart:ApplyImpulse(camera.CFrame.LookVector * throwPower)

			self:HitDetection(throwPower)

			self:LetGo()
		end
	end, false, Enum.KeyCode.E)

	self.HoldConnection = RunService.Heartbeat:Connect(function(deltaTime)
		local studsOffset = Lerp(self.MinThrowStudsOffset, self.MaxThrowStudsOffset, alpha)
		self.HoldGrip.Position = character.Head.Position + ((mouse.Hit.Position - character.Head.Position).Unit * (self.HoldDistance - studsOffset))
	end)

end

function ThrowModule:LetGo()
	ContextActionService:UnbindAction("ThrowItem")
	
	if self.IncreasingForce then
		self.IncreasingForce:Disconnect()
		self.IncreasingForce = nil
	end
	
	if self.Item then
		--SetNetworkOwner:FireServer(self.Item.PrimaryPart)
		self.Item = nil
	end

	if self.HoldConnection then
		self.HoldConnection:Disconnect()
		self.HoldConnection = nil
	end

	if self.HoldGrip then
		self.HoldGrip:Destroy()
		self.HoldGrip = nil
	end

	if self.Attachment0 then
		self.Attachment0:Destroy()
		self.Attachment0 = nil
	end
end

function ThrowModule:Start()
	ContextActionService:BindAction("HoldItem", function(actionName, inputState, inputObj)
		if inputState == Enum.UserInputState.Begin then
			ThrowModule:Hold()
		elseif inputState == Enum.UserInputState.End then
			ThrowModule:LetGo()
		end
	end, false, Enum.UserInputType.MouseButton1)
end
ThrowModule:Start()

return ThrowModule
