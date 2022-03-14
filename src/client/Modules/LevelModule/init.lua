local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")
local LightOn = ReplicatedStorage:WaitForChild("LightOn")

local ZonePlus = require(Common:WaitForChild("ZonePlus"))
local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Player = game.Players.LocalPlayer

local PlayerScripts = Player:WaitForChild("PlayerScripts")

local Client = PlayerScripts:WaitForChild("Client")

local Gui = Client:WaitForChild("Gui")

local LevelTransition = require(Gui:WaitForChild("LevelTransition"))

local LaserModule = require(script.Parent.Laser)

local function LoadModuleWithDependenciesInjected(module: Instance)
	local success, req = pcall(require, module)
	if not success then
		warn(module.Name, "could not be required")
		return false
	end
	if typeof(req) == "table" then
		req.LaserModule = LaserModule
	end

	return req
end

local LevelModules = {
	["Level 1"] = LoadModuleWithDependenciesInjected(script:WaitForChild("Level1")),
	["Level 2"] = LoadModuleWithDependenciesInjected(script:WaitForChild("Level2")),
}

local LevelOrder = {
	"Level 1",
	"Level 2",
}

local LevelModule = {}

function LevelModule:Start()
	self.LevelledUp = Signal.new()
	self.Gui = LevelTransition({
		LevelledUp = self.LevelledUp,
	})
	self.CurrentLevelName = LevelOrder[1]

	local function CharacterAdded(character)
		local currentLevelFolder = self.CurrentLevelFolder
		if currentLevelFolder then
			self:UnloadLevel(currentLevelFolder)
		end

		if not character.PrimaryPart then
			character:GetPropertyChangedSignal("PrimaryPart"):Wait()
		end
		self:LoadLevel(self.CurrentLevelName)
	end

	Player.CharacterAdded:Connect(CharacterAdded)

	local character = Player.Character
	if character then
		CharacterAdded(character)
	end
end

function LevelModule:LoadLevel(levelName)
	local levelModule = LevelModules[levelName]
	if not levelModule then
		return
	end
	self.LevelModule = levelModule

	local clonedLevelFolder = levelModule.Data.Folder:Clone()
	local lightsFolder = clonedLevelFolder:FindFirstChild("lights")

	if lightsFolder then
		local lightsFolderChildren = lightsFolder:GetChildren()
		for _, set in ipairs(lightsFolderChildren) do
			for _, light in ipairs(set:GetDescendants()) do
				if not light:IsA("Light") then
					continue
				end
				light.Enabled = false
			end
		end

		table.sort(lightsFolderChildren, function(a, b)
			return a:GetFullName() < b:GetFullName()
		end)

		task.spawn(function()
			for _, set in ipairs(lightsFolderChildren) do
				task.wait(0.5)

				local clonedLightOn = LightOn:Clone() :: Sound
				clonedLightOn:Play()
				task.spawn(function()
					clonedLightOn.Ended:Wait()
					clonedLightOn:Destroy()
				end)
				clonedLightOn.Parent = set

				for _, light in ipairs(set:GetDescendants()) do
					if not light:IsA("Light") then
						continue
					end

					light.Enabled = true
				end
			end
		end)
	end

	clonedLevelFolder.Parent = workspace
	self.CurrentLevelFolder = clonedLevelFolder

	Player.Character:SetPrimaryPartCFrame(clonedLevelFolder.spawn.CFrame)

	self.LevelledUp:Fire(levelName)

	levelModule:OnLoaded(clonedLevelFolder)

	local exit = clonedLevelFolder:FindFirstChild("exit")
	if exit then
		-- local zone = ZonePlus.new(exit)
		-- local hrp = Player.Character:WaitForChild("HumanoidRootPart")
		-- zone:onItemEnter(hrp, function()
		-- 	local canProceed = levelModule.CanProceed()
		-- 	if not canProceed then
		-- 		return
		-- 	end

		-- 	local currentIndex = table.find(LevelOrder, levelName)
		-- 	local nextIndex = currentIndex + 1

		-- 	local nextLevelName = LevelOrder[nextIndex]

		-- 	if not nextLevelName then
		-- 		return
		-- 	end

		-- 	self:UnloadLevel(clonedLevelFolder)
		-- 	self:LoadLevel(nextLevelName)
		-- end)

		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Parent = exit
		proximityPrompt.ActionText = "Continue"
		proximityPrompt.ObjectText = exit:GetAttribute("altName") or "Exit"
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.F
		proximityPrompt.ClickablePrompt = true
		proximityPrompt.HoldDuration = 1.3

		local connection = nil
		connection = proximityPrompt.TriggerEnded:Connect(function()
			local canProceed = levelModule.CanProceed()
			if not canProceed then
				-- notify of objectives
				return
			end

			local currentIndex = table.find(LevelOrder, levelName)
			local nextIndex = currentIndex + 1

			local nextLevelName = LevelOrder[nextIndex]

			connection:Disconnect()
			if not nextLevelName then
				return
			end

			self:UnloadLevel(clonedLevelFolder)
			self:LoadLevel(nextLevelName)
		end)
	end
end

function LevelModule:UnloadLevel(map)
	self.LevelModule:OnUnloaded(map)

	map:Destroy()
end

return LevelModule
