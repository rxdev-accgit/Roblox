local MorphManager = require(script.Parent.Core:WaitForChild("MorphManager"))

local MorphEventFolder = game.ReplicatedStorage:WaitForChild("MorphSystemEvents")

MorphEventFolder["MS_MorphPlayer"].OnServerEvent:Connect(function(Player: Player, MorphName: string, CanOverride: boolean)
	MorphManager:MorphPlayer(Player, MorphName, CanOverride)
end)

MorphEventFolder["MS_DeleteMorph"].Event:Connect(function(Player: Player, MorphName:string, IsPlayerAllowed: boolean)
	if IsPlayerAllowed then
		MorphManager:DeleteMorph(Player, MorphName)
	end
end)

