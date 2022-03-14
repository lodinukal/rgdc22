local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local setFrequency = RDL.setFrequency

local Player = game.Players.LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()

local AlignOrientation = Instance.new("AlignOrientation")
AlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
AlignOrientation.RigidityEnabled = true
AlignOrientation.Parent = Character:WaitForChild("HumanoidRootPart")

local WalkAnimation = Instance.new("Animation")
WalkAnimation.AnimationId = "rbxassetid://9071651045"

local Spider = {}
Spider.__index = Spider

function Spider.new(model)
	return setmetatable({
		Model = model,
	}, Spider)
end

function Spider:Destroy()
	self.Update:Disconnect()
end

local partRaycasts = {}

local function showRaycast(origin, direction)
	local midpoint = origin + direction / 2

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false

	part.Material = Enum.Material.Neon
	part.BrickColor = BrickColor.new("Really red")

	part.CFrame = CFrame.lookAt(midpoint, origin)
	part.Size = Vector3.new(0.5, 0.5, direction.Magnitude)
	part.Parent = workspace

	table.insert(partRaycasts, part)
end

function Spider:AngleRaycast(amount, angleDiff, origin, direction, distance)
	local hitCharacter = false

	for i = 1, amount, 1 do
		local angle = (i - (amount + 1) * 0.5) * angleDiff

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = { self.Model, partRaycasts }

		local directionOffset = (direction + Vector3.new(math.rad(angle), 0, 0)) * distance
		local result = workspace:Raycast(origin, directionOffset, params)
		--showRaycast(origin, result and result.Position - origin or directionOffset)
		if not result or not result.Instance:IsDescendantOf(Player.Character) then
			continue
		end

		hitCharacter = true
		break
	end

	return hitCharacter
end

function Spider:init()
	local head = self.Model.Head
	AlignOrientation.Attachment0 = head.Attachment

	setFrequency(10, function()
		if #partRaycasts > 0 then
			for i, v in ipairs(partRaycasts) do
				v:Destroy()
			end
		end

		local hitCharacter = self:AngleRaycast(6, 20, head.Position, head.CFrame.LookVector, 15)
		if not hitCharacter then
			return
		end
	end)
end

return Spider
