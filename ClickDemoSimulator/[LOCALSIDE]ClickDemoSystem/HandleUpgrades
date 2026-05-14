local Player:Player = game.Players.LocalPlayer
local UpgradeData = require(game.ReplicatedStorage.CDS_LocalModules:WaitForChild("UpgradeData"))
local CDSEvent = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_UpgradeEvent")

local CDS_UIFolder = Player.PlayerGui:WaitForChild("CDS_ClickCounterUIs")

if CDS_UIFolder then
	local MainUGUI = CDS_UIFolder:WaitForChild("ClickGUI")
	local UpgradeFrame: Frame = MainUGUI:WaitForChild("UpgradeFrame")
	local UpgradeList: ScrollingFrame = UpgradeFrame:WaitForChild("ScrollingFrame")

	local PlayerCurrentUD = UpgradeData[Player:GetAttribute("Rebirths")]
	local PurchasedUpgrades = {}

	local function CheckPurchaseable(Player: Player, UpgradeName: string)
		local UpgrateSubData = PlayerCurrentUD[UpgradeName]
		local PlayerClickAmount = Player:GetAttribute("Clicks")

		if PlayerClickAmount >= UpgrateSubData.Price then
			return true
		else 
			warn("Not enough clicks")
			return false
		end
	end

	local function ProcessPayment(Player: Player, UpgradeName: string)
		CDSEvent:FireServer(UpgradeName, true)
	end


	local function OnClick(Player, UpgradeName)
		if Player and UpgradeName then
			local CanBuy = CheckPurchaseable(Player, UpgradeName)
			if CanBuy then
				ProcessPayment(Player, UpgradeName)
			else
				--...
				warn("Something went wrong")
				return
			end
		end
	end

	
	for _, UpgradeFrame:Frame in pairs(UpgradeList:GetChildren()) do
		if UpgradeFrame:IsA("Frame") then
			for _, Items in pairs(UpgradeFrame:GetChildren()) do
				if Items:IsA("TextButton") then
					Items.Activated:Connect(function()
						OnClick(Player, UpgradeFrame.Name)
					end)
				end
			end
		end
	end

	
	task.spawn(function()
		while Player.Parent do
			PlayerCurrentUD = UpgradeData[Player:GetAttribute("Rebirths")]
			for _, UpgradeFrame:Frame in pairs(UpgradeList:GetChildren()) do
				if UpgradeFrame:IsA("Frame") then
					for _, Items in pairs(UpgradeFrame:GetChildren()) do
						if Items:IsA("TextLabel") and Items.Name == "Name" then
							Items.Text = PlayerCurrentUD[UpgradeFrame.Name].Name
						end
						if Items:IsA("TextLabel") and Items.Name == "Description" then
							Items.Text = PlayerCurrentUD[UpgradeFrame.Name].Description
						end
						if Items:IsA("TextLabel") and Items.Name == "Require" then
							Items.Text = PlayerCurrentUD[UpgradeFrame.Name].Price.." Clicks"
						end
					end
				end
			end
			task.wait(.5)
		end
	end)
end
