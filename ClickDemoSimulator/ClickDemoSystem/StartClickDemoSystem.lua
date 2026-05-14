local ClickManager = require(script.Parent:WaitForChild("ClickManager"))
local UpgradeData = require(script.Parent:WaitForChild("UpgradeData"))

local CDSEvent = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_Client-ServerCommunication")
local CDSEvent2 = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_UpgradeEvent")
local CDSEvent3 = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_RebirthEvent")
local CDSEvent4 = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_Start/Stop_AutoClicker")
local CDSEvent5 = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_ResetEvent")

local PlayerSystems = {}

game.Players.PlayerAdded:Connect(function(Player)
	local ClickSystem = ClickManager.Initialize(Player)
	PlayerSystems[Player.UserId] = ClickSystem
	ClickSystem:LoadClicks(Player)
	

	local Clicks = Instance.new("IntValue")
	Clicks.Name = "Clicks"
	Clicks.Value = 0
	
	local leaderstats = Player:WaitForChild("leaderstats")
	if leaderstats then
		Clicks.Parent = leaderstats
	end
	
	Player:GetAttributeChangedSignal("Clicks"):Connect(function()
		Clicks.Value = Player:GetAttribute("Clicks")
	end)
	
	task.spawn(function()
		ClickSystem:StartAutoClicker(Player, false)
	end)
	
	if Player.PlayerGui.CDS_ClickCounterUIs.CounterGUI.Frame.TextLabel and Player:GetAttribute("Clicks") then
		Player.PlayerGui.CDS_ClickCounterUIs.CounterGUI.Frame.TextLabel.Text = "Clicks: "..Player:GetAttribute("Clicks")
	end
end)


game.Players.PlayerRemoving:Connect(function(Player)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem then
		ClickSystem:SaveData(Player)
		PlayerSystems[Player.UserId] = nil
	end
end)

CDSEvent.OnServerEvent:Connect(function(Player)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem then
		ClickSystem:AddClick(Player)
	end
end)

CDSEvent2.OnServerEvent:Connect(function(Player: Player, UpgradeName: string, Bought: boolean)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem then
		ClickSystem:Upgrade(Player, UpgradeName, Bought)
	end
end)

CDSEvent3.OnServerEvent:Connect(function(Player: Player, RebirthAmount: number)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem then
		ClickSystem:Rebirth(Player, RebirthAmount)
	end
end)


CDSEvent4.OnServerEvent:Connect(function(Player: Player, IsBought: boolean, OnOff:string)
	--print("[SERVER]: CDSEvent4 received — IsBought:", IsBought, "| Player:", Player.Name)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem and OnOff == "On"  then
		ClickSystem.AutoClicker["Player_"..Player.UserId].CanActivate = IsBought
		--print("[SERVER]: CanActivate set to:", ClickSystem.AutoClicker["Player_"..Player.UserId].CanActivate)
		
	elseif ClickSystem and OnOff == "Off" then
		ClickSystem:StopAutoClicker(Player)
		--print("[SERVER]: AutoClicker stopped for player:", Player.Name)
	end
end)

CDSEvent5.Event:Connect(function(Player: Player)
	local ClickSystem = PlayerSystems[Player.UserId]
	if ClickSystem then
		ClickSystem:ResetProgress(Player)
	end
end)


game:BindToClose(function()
	for UserId, ClickSystem in pairs(PlayerSystems) do
		
		local player = game.Players:GetPlayerByUserId(UserId)
		if player and ClickSystem then
			ClickSystem:SaveData(player)
		end
	end
	task.wait(2)
end)

