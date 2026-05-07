local RE = game.ReplicatedStorage:WaitForChild("RE"):WaitForChild("MSCom")
local ToolCollection = game.ServerStorage:WaitForChild("Tools")
local prices = {
	["PC_case"] = 2000,
	["ComputerFans"] = 5000,
	["MotherBoard"] = 2000
}

local function HandlePartPurchase(Player, PartName)
	print(PartName, Player)
	local leaderstats = Player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins")
	
	if not prices[PartName] then
		print("Invalid PartName")
		return
	end
	
	
	
	if PartName and Player then
		if coins.Value >= prices[PartName] then
			local tool = ToolCollection:FindFirstChild(PartName)
			if not tool then
				warn("tool not found")
			end
			
			local clone = tool:Clone()
			clone.Parent = Player.Backpack
			coins.Value -= prices[PartName]
			
			
			
			--return Enum.ProductPurchaseDecision.PurchaseGranted
			
			print("Looking for tools:")
			for i, v in pairs(ToolCollection:GetChildren()) do
				print("toolinxd:"..i.."toolname"..v.Name)
			end
			
		else return end
	else
		print("Something Went Wrong")
	end
	
end

RE.OnServerEvent:Connect(HandlePartPurchase)
