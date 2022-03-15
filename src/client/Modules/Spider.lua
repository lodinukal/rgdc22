local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local setFrequency = RDL.setFrequency

local Player = game.Players.LocalPlayer

local WalkAnimation = Instance.new("Animation")
WalkAnimation.AnimationId = "rbxassetid://9071651045"

local AttackAnimation = Instance.new("Animation")
AttackAnimation.AnimationId = "rbxassetid://9104526544"

local Spider = {}
Spider.__index = Spider

function Spider.new(model)
	return setmetatable({
		Model = model,
		Damage = 20,
		AttackInterval = 1.25,
		AttackDistance = 5
	}, Spider)
end

function Spider:Destroy()
	self.Update:Disconnect()
	self.Model:Destroy()
end

function Spider:DetectPlayer(amount, angleDiff, origin, direction, distance)
	local hitCharacter = false

	for i = 1, amount, 1 do
		local angle = (i - (amount + 1) * 0.5) * angleDiff

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = { self.Model }

		local directionOffset = (direction + Vector3.new(math.rad(angle), 0, 0)) * distance
		local result = workspace:Raycast(origin, directionOffset, params)
		if not result or not result.Instance:IsDescendantOf(Player.Character) then
			continue
		end

		hitCharacter = true
		break
	end

	return hitCharacter
end

function Spider:Attack()
	local model = self.Model
	local hrp = model.PrimaryPart

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { self.Model }

	local result = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * self.AttackDistance, params)
	if not result or not result.Instance:IsDescendantOf(Player.Character) then
		return
	end

	Player.Character.Humanoid:TakeDamage(self.Damage)
end

function Spider:init()
	local model = self.Model
	local hrp = model.PrimaryPart
	local alignOrientation = hrp.AlignOrientation
	local humanoid = model.Humanoid

	local attachment1 = Instance.new("Attachment")
	alignOrientation.Attachment1 = attachment1

    local walkTrack = humanoid.Animator:LoadAnimation(WalkAnimation)
	local attackTrack = humanoid.Animator:LoadAnimation(AttackAnimation)

	local time = 0
	self.Update = setFrequency(30, function(deltaTime)
		local hitCharacter = self:DetectPlayer(10, 18, hrp.Position, hrp.CFrame.LookVector, 10)
		if not hitCharacter then
			time -= time
			if walkTrack.IsPlaying then
				walkTrack:Stop()
			end
			attachment1.Parent = nil
			return
		end
		time += deltaTime

		if time >= self.AttackInterval then
			time -= self.AttackInterval

			attackTrack:Play()
			self:Attack()
		end

		if not walkTrack.IsPlaying then
			walkTrack:Play()
		end

		attachment1.Parent = Player.Character.PrimaryPart

        local CharacterCFrame = Player.Character:GetPrimaryPartCFrame()
        humanoid:MoveTo(CharacterCFrame.Position + CharacterCFrame.LookVector * 5)
	end)
end

return Spider
