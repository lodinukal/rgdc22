local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage:WaitForChild("Common")

local RDL = require(Common:WaitForChild("RDL"))
local Signal = RDL.Signal

local Fusion = require(Common:WaitForChild("fusion"))

local Modules = script:WaitForChild("Modules")
local Gui = script:WaitForChild("Gui")

local WindLines = require(Modules:WaitForChild("WindLines"))
--local CameraModule = require(Modules:WaitForChild("CameraModule"))

local Dialogue = require(Gui:WaitForChild("Dialogue"))
local DeathScreen = require(Gui:WaitForChild("DeathScreen"))

local Player = game.Players.LocalPlayer

--[[
WindLines:Init({
	Direction = Vector3.new(1,0,0.3);
	Speed = 20;
	Lifetime = 1.5;
	SpawnRate = 11;
})
--]]

local eventOpen = Signal.new()
local eventClose = Signal.new()
DeathScreen {
    EventOpen = eventOpen,
    EventClose = eventClose
}

local function CharacterAdded(character)
    eventClose:Fire()
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        eventOpen:Fire()
    end)
end
Player.CharacterAdded:Connect(function(character)
    CharacterAdded(character)
end)
local Character = Player.Character
if Character then
    CharacterAdded(Character)
end

task.wait(2)

local lines = {
    {Text = "Hello, Test Subject #"..tostring(game.Players.LocalPlayer.UserId).."!", FadeTime = 3},
    {Text = "Welcome to <font color='rgb(255,0,0)'>R.</font> <font color='rgb(0,255,0)'>G.</font> <font color='rgb(0,0,255)'>B.</font>", OriginalText = "Welcome to R. G. B.", FadeTime = 2},
    {Text = "That stands for,", FadeTime = 2.5},
    {Text = "<font color='rgb(255,0,0)'>Red</font> <font color='rgb(0,255,0)'>Green</font> <font color='rgb(0,0,255)'>Blue</font>", OriginalText = "Red Green Blue", FadeTime = 2},
    {Text = "Wait no, it's-", FadeTime = 2},
    {Text = "Rational Greymatter Bootcamp", FadeTime = 2.5},
    {Text = "<font size='35'><font color='rgb(255,0,0)'>WHAT??</font></font>", OriginalText = "WHAT??", FadeTime = 2},
    {Text = "It doesn't sound..", FadeTime = 1.5},
    {Text = "silly..", FadeTime = 2},
    {Text = ":'(", FadeTime = 5},
    {Text = "<b><font size='35'>JUST</font></b>", FadeTime = 1},
    {Text = "Follow me..", FadeTime = 2},
    {Text = "You're already.. making me angry. You know?", FadeTime = 2}
}

local signal = Signal.new()
Dialogue {
    Name = "???",
    Text = Fusion.Value(lines),
    Event = signal
}

signal:Fire()