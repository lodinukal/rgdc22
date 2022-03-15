local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Modules = Client:WaitForChild("Modules")

local Spider = require(Modules:WaitForChild("Spider"))

local Data = {
	Folder = Levels:WaitForChild("Level2"),
}

local connection
local lightsOn = false
local cached = false
local spiders = {}

local tweenIndo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential)

local function OnLoaded(self, map)
	local lights = map._lights:GetChildren()

	for i, v in ipairs(map.enemies:GetChildren()) do
		local spider = Spider.new(v)
		spider:init()
		table.insert(spiders, spider)
	end

	connection = RunService.Heartbeat:Connect(function(deltaTime)
		lightsOn = not not self.LaserModule.ReceiverIded["Level2Lights"]
		if lightsOn then
			if cached == lightsOn then
				return
			end
			cached = lightsOn
			for _, lightPart in ipairs(lights) do
				TweenService
					:Create(lightPart.PointLight, tweenIndo, {
						Brightness = 2.5,
						Color = Color3.new(0.862745, 0.886274, 0.968627),
					})
					:Play()
				TweenService
					:Create(lightPart.SurfaceLight, tweenIndo, {
						Brightness = 2.5,
						Color = Color3.new(0.862745, 0.886274, 0.968627),
					})
					:Play()
			end
		else
			for _, lightPart in ipairs(lights) do
				lightPart.PointLight.Brightness = 0.4 + 0.34 * math.sin(os.clock() / 2.5)
			end
			if cached == lightsOn then
				return
			end
			cached = lightsOn
			for _, lightPart in ipairs(lights) do
				TweenService
					:Create(lightPart.PointLight, tweenIndo, {
						Brightness = 0.4,
						Color = Color3.new(0.721568, 0.027450, 0.027450),
					})
					:Play()
				TweenService
					:Create(lightPart.SurfaceLight, tweenIndo, {
						Brightness = 0.4,
						Color = Color3.new(0.721568, 0.027450, 0.027450),
					})
					:Play()
			end
		end
	end)
end

local function OnUnloaded(self, map)
	for i, v in ipairs(spiders) do
		v:Destroy()
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function CanProceed(self)
	if not lightsOn then
		self.Requirements("You need to turn on the lights!")
	end
	return lightsOn
end

return {
	Data = Data,
	OnLoaded = OnLoaded,
	OnUnloaded = OnUnloaded,
	CanProceed = CanProceed,
}
