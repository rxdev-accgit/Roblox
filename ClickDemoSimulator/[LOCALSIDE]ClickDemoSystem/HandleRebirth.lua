local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local CDS_UIFolder: Folder = PlayerGui:WaitForChild("CDS_ClickCounterUIs")
local UpgradeData = require(game.ReplicatedStorage.CDS_LocalModules:WaitForChild("UpgradeData"))
local CDSEvent = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_RebirthEvent")

local PlayerCurrentUD = UpgradeData[Player:GetAttribute("Rebirths")]



if CDS_UIFolder then
	local RebirthGUI:ScreenGui = CDS_UIFolder:WaitForChild("RebirthGUI")
	local RebirthMainFrame = RebirthGUI:WaitForChild("MainFrame")
	local RebirthInfoFrame:Frame = RebirthMainFrame:WaitForChild("Frame")
	local RebirthButton: TextButton = RebirthInfoFrame:WaitForChild("TextButton")
	local OpenButton:TextButton = RebirthGUI:WaitForChild("ButtonFrame"):WaitForChild("TextButton")
	
	OpenButton.Activated:Connect(function()
		RebirthMainFrame.Visible = not RebirthMainFrame.Visible
	end)
	
	
	spawn(function()
		while Player.Parent do
			PlayerCurrentUD = UpgradeData[Player:GetAttribute("Rebirths") + 1]
			--Ui Configurations:
			if PlayerCurrentUD and PlayerCurrentUD.Requirements then
				RebirthInfoFrame.RebirthAmount.Text = (Player:GetAttribute("Rebirths") + 1)
				RebirthInfoFrame.Require.Text = tostring(PlayerCurrentUD.Requirements.ClicksNeeded).." Clicks"
			else
				RebirthInfoFrame.Require.Text = "N/A"
				RebirthInfoFrame.RebirthAmount.Text = "N/A"
				RebirthInfoFrame.TextLabel.Text = "You have Reached The Max Amount Of Rebirths Possible Or You cannot Rebirth Yet!"
				
				continue
			end
			task.wait(.5)
		end
	end)
	
	
	
	local function CheckAndProcessRebirth(Player: Player, RebirthAmount: number)
		CDSEvent:FireServer(RebirthAmount)
	end
	
	
	local function OnClick(Player: Player)
		CheckAndProcessRebirth(Player, Player:GetAttribute("Rebirths") + 1)
	end
	
	RebirthButton.Activated:Connect(function()
		OnClick(Player)
	end)
end
