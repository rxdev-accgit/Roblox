local Player = game.Players.LocalPlayer
local PlayerGUI = Player.PlayerGui
local CDS_UIFolder = PlayerGUI:WaitForChild("CDS_ClickCounterUIs")

local MPS = game:GetService("MarketplaceService")

if CDS_UIFolder then
	local MainUi = CDS_UIFolder:WaitForChild("RebirthGUI")
	local ButtonFrame = MainUi:WaitForChild("ButtonFrame")
	local ResetButton = ButtonFrame:WaitForChild("Reset")
	
	if MainUi then
		if ButtonFrame then
			if ResetButton then
				
				ResetButton.Activated:Connect(function()
					MPS:PromptProductPurchase(Player, 3592095766)
					MPS.PromptProductPurchaseFinished:Connect(function()
						print("[LOCALSIDE]: Product purchase finished, resetting...")
					end)
				end)
				
			end
		end
	end
