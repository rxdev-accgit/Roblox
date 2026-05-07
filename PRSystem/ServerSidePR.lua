local Players = game:GetService("Players")
local PRmanager = require(game.ServerScriptService.PlaytimeRewardsSystem.PRManager)
local DTS = game:GetService("DataStoreService")
local PRDatastore = DTS:GetDataStore("PR_DataSaving")
local PREvent = game.ReplicatedStorage.BindableEvents:WaitForChild("PRCommunication")

local ActivePRs = {} --OOP Issue handling

local function PR_Timer(Player: Player, PR)
	local Timer = 0

	while Timer <= 80 and Player.Parent do
		Timer += 1
		if Timer == 10 then
			PR:UpdatePR_Progress(Player, 1)
		elseif Timer == 20 and not PR.RewardsTable[2].IsProcessed then
			PR:UpdatePR_Progress(Player, 2)

		elseif Timer == 40 then
			PR:UpdatePR_Progress(Player, 4)
		elseif Timer == 50 then
			PR:UpdatePR_Progress(Player, 5)
		end

		if Timer == 70 then
			print("[SERVER SIDE]: initializing reset")
			PR:StartResetCountdown(Player)
			PR:SaveData(Player, {
				PRCount = Player:GetAttribute("PRCountAttribute"),
				Rewards = PR.RewardsTable,
				PlayerCoins = Player.leaderstats.Coins.Value,
				LastResetTime = PR.LastResetTime
			})
		end
		task.wait(1)
	end
end

local function I_Leaderstats(player:Player)
	local PR_GUI = player.PlayerGui:WaitForChild("PR_Reward"):WaitForChild("PR_RewardGUI")
	local PR_Template: Frame = player.PlayerGui:WaitForChild("PR_Reward"):WaitForChild("Templates"):WaitForChild("Container"):Clone()
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player




	--Coins
	local Coins = Instance.new("IntValue")
	Coins.Name = "Coins"
	Coins.Parent = leaderstats
	Coins.Value = 0
	
	
	local PR = PRmanager.InitializePR(player, PR_Template, PR_GUI:WaitForChild("MainFrame"))
	ActivePRs[player.UserId] = PR
	
	--Initialize PR
	

	PR:LoadData(player)
	task.spawn(PR_Timer, player, PR)
end

Players.PlayerAdded:Connect(I_Leaderstats)
Players.PlayerRemoving:Connect(function(player)
	ActivePRs[player.UserId] = nil
end)

PREvent.Event:Connect(function(plr)
	local PR = ActivePRs[plr.UserId]
	if PR then
		PR_Timer(plr, PR)
	end
end)
