local UserInputService = game:GetService("UserInputService")

local Player = game.Players.LocalPlayer

local DoubleJump = {}
DoubleJump.CanDoubleJump = false

function DoubleJump:Start()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    UserInputService.JumpRequest:Connect(function()
        if self.CanDoubleJump and not self.HasDoubleJumped then
            self.HasDoubleJumped = true
            humanoid.JumpPower = 100
            print(humanoid.JumpPower)
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            character.HumanoidRootPart:ApplyImpulse(character.HumanoidRootPart.CFrame.LookVector * 1000)
        end
    end)

    humanoid.StateChanged:Connect(function(old, new)
        print(old, new)

        if new == Enum.HumanoidStateType.Landed then
			self.CanDoubleJump = false
            self.HasDoubleJumped = false
            humanoid.JumpPower = 50
		elseif new == Enum.HumanoidStateType.Freefall then
            task.delay(.2, function()
                self.CanDoubleJump = true
            end)
		end
    end)
end
DoubleJump:Start()

return DoubleJump