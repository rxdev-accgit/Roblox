local datastore = game:GetService("DataStoreService"):GetDataStore("ToolSave")
local ATTEMPT_LIMIT = 5


local function LeaderStats(Player)
	local Leaderstats = Instance.new("Folder")
	Leaderstats.Name = "leaderstats"
	Leaderstats.Parent = Player
	
	
	local Cash = Instance.new("IntValue")
	Cash.Name = "Coins"
	local scs, data
	local tries = 0
	Cash.Value = 50000
	
	Cash.Parent = Leaderstats
end

local function givecoins(Player)
	local key = "Player_"..tostring(Player.UserId)
	local scs, data
	local tries = 0
	
	repeat
		tries += 1
		scs, data = pcall(datastore.GetAsync, datastore, key)
	until scs or tries >= 5

	if not scs or data == nil then 
		warn("Something went wrong while retreiving the data of plr:  ", Player.Name)
	elseif scs then 
		print("succesfully retrieved data")
		print(tostring(data.Coins))
	end

	if data then
		Player:WaitForChild("leaderstats"):WaitForChild("Coins").Value = data.Coins
	end
end

game.Players.PlayerAdded:Connect(LeaderStats)
game.ReplicatedStorage:WaitForChild("BDE"):WaitForChild("DTS").Event:Connect(givecoins)
