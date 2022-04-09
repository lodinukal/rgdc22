local LaserColourUtils = {}

function LaserColourUtils:SetColouration(laser: MeshPart, state)
    laser.Attachment:GetChildren()[1].Color = if (state:get()) then
        Color3.fromRGB(68, 255, 43) else
        Color3.fromRGB(255, 43, 43)
end

return LaserColourUtils