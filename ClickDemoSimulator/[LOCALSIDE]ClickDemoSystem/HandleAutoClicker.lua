local Player = game.Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local CDS_UIFolder: Folder = PlayerGui:WaitForChild("CDS_ClickCounterUIs")
local CDSEventFolder = game.ReplicatedStorage.CDS_Events
local CDSEvent = CDSEventFolder:WaitForChild("CDS_Start/Stop_AutoClicker")


local IsOn = false
if CDS_UIFolder then
	local ClickUi = CDS_UIFolder:WaitForChild("ClickGUI")
	local ClickFrame: Frame = ClickUi:WaitForChild("AutoClickerToggle")
	local ClickButton: TextButton = ClickFrame:WaitForChild("TextButton")
	local OpenButton:TextButton =CDS_UIFolder:WaitForChild("RebirthGUI"):WaitForChild("ButtonFrame"):WaitForChild("TextButton")
	
	if ClickUi then
		if ClickFrame then
			if ClickButton then
				ClickButton.BackgroundColor3 = Color3.new(1, 0.2, 0.211765)
				ClickButton.Text = "AutoClicker: Off"


				ClickButton.Activated:Connect(function()
					IsOn = not IsOn

					if Player:GetAttribute("OwnsAutoClicker") == true and IsOn then
						ClickButton.BackgroundColor3 = Color3.new(0.247059, 1, 0.0784314)
						ClickButton.Text = "AutoClicker: On"
						CDSEvent:FireServer(true, "On")
					elseif not IsOn then 
						ClickButton.BackgroundColor3 = Color3.new(1, 0.2, 0.211765)
						ClickButton.Text = "AutoClicker: Off"
						CDSEvent:FireServer(true, "Off")
					end
				end)
			end
		end
	end
end

