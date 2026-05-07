local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ShopUi")
local btn = workspace.ActivateShop:WaitForChild("btn")
local clickdetector = btn:WaitForChild("ClickDetector")
local TweenService = game:GetService("TweenService")
local TI = TweenInfo.new(.5, Enum.EasingStyle.Sine)
btn.Material = Enum.Material.Neon

clickdetector.MouseClick:Connect(function(plr)
	print("Clicked")
	ui:WaitForChild("MainFrame").Visible = true
	local goal = {
		Position = btn.Position + Vector3.new(0, -.5, 0),
		Color = Color3.fromRGB(78, 255, 78)
	}

	local TweenPlay = TweenService:Create(btn, TI, goal)
	TweenPlay:Play()
end)

ui.MainFrame:WaitForChild("Buttons"):WaitForChild("CloseButton").Activated:Connect(function(InputObj)
	if InputObj.UserInputType == Enum.UserInputType.MouseButton1 then
		local goal2 = {
			Position = btn.Position + Vector3.new(0, .5, 0),
			Color = Color3.fromRGB(255, 0, 0)
		}
		
		ui.MainFrame.Visible = false
		local TweenPlay2 = TweenService:Create(btn, TI, goal2)
		TweenPlay2:Play()
	end
end)
