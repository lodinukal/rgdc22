local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage.SetNetworkOwner.OnServerEvent:Connect(function(plr, draggedPart)
	draggedPart:SetNetworkOwner(not(draggedPart:GetNetworkOwner()) and plr or nil)
end)

ReplicatedStorage.GetNetworkOwner.OnServerInvoke = function(plr, part: BasePart) return part:GetNetworkOwner() == plr end