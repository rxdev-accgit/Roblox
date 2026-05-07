local PBModule = require(game.ReplicatedStorage:WaitForChild("ProbabilityModule"))
local ChosenPartsTable = PBModule.Func1()
local ui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ShopUi")
local uilabels = ui.MainFrame:WaitForChild("Labels")
local BDE = game.ReplicatedStorage:WaitForChild("RE").ShopCommunication
local RE = game.ReplicatedStorage:WaitForChild("RE"):WaitForChild("MSCom") --Main Event
local buttons = ui.MainFrame:WaitForChild("Buttons")
--labels
local TL1 = uilabels:WaitForChild("TL1")
local TL2 = uilabels:WaitForChild("TL2")
local TL3 = uilabels:WaitForChild("TL3")
local Main = uilabels:WaitForChild("Main")

local CheckWetherAmountExsists = {}

local player = game.Players.LocalPlayer

local function selectparts()
	local ChosenPartsTable = PBModule.Func1()
	
	for i, v in pairs(ChosenPartsTable) do
		print(i, v)
	end

	if ChosenPartsTable["PC_case"] then
		TL1.Text = string.format("Stock: %d", ChosenPartsTable["PC_case"].Amount)
	else
		TL1.Text = "Stock: 0"
	end
	
	if ChosenPartsTable["PC_Fans"] then
		TL3.Text = string.format("Stock: %d", ChosenPartsTable["PC_Fans"].Amount)
		
	else
		TL3.Text = "Stock: 0"
	end
	
	if ChosenPartsTable["MotherBoard"] then
		TL2.Text = string.format("Stock: %d", ChosenPartsTable["MotherBoard"].Amount)
	else
		TL2.Text = "Stock: 0"
	end
	
	CheckWetherAmountExsists = ChosenPartsTable
end


selectparts()--inital choice
----------------------------------------

if BDE then
	BDE.OnClientEvent:Connect(function(var)
		
		if var and var == "Reset_Shop" then
			selectparts() --reset
		end
		
		if var and typeof(var) == "number" then
			Main.Text = string.format("PC part shop (Resets in: %d)", var)
		end
	end)
end

local BC1 = false
local BC2 = false
local BC3 = false

buttons.BuyCase.MouseButton1Click:Connect(function()
	if CheckWetherAmountExsists["PC_case"].Amount == 0 then
		TL1.Text = "NO STOCK"
		task.wait(1)
		TL1.Text = "Stock: 0"
	end
	
	if CheckWetherAmountExsists["PC_case"] == nil then
		TL1.Text = "NO STOCK"
		task.wait(1)
		TL1.Text = "Stock: 0"
	else
		if BC1 == false then
			if CheckWetherAmountExsists["PC_case"].Amount == 0 then return end
			
			BC1 = true
			RE:FireServer("PC_case")
			CheckWetherAmountExsists["PC_case"].Amount -= 1
			TL1.Text = string.format("Stock: %d", CheckWetherAmountExsists["PC_case"].Amount)
			
			task.wait(2)
			BC1 = false
		end
	end
end)

buttons.BuyFans.MouseButton1Click:Connect(function()
	if CheckWetherAmountExsists["PC_Fans"].Amount == 0 then
		TL3.Text = "NO STOCK"
		task.wait(1)
		TL3.Text = "Stock: 0"
	end
	
	if CheckWetherAmountExsists["PC_Fans"] == nil then
		TL3.Text = "NO STOCK"
		task.wait(1)
		TL3.Text = "Stock: 0"
	else
		if BC2 == false then
			
			if CheckWetherAmountExsists["PC_Fans"].Amount == 0 then return end
			BC2 = true
			RE:FireServer("ComputerFans")
			CheckWetherAmountExsists["PC_Fans"].Amount -= 1
			TL3.Text = string.format("Stock: %d", CheckWetherAmountExsists["PC_Fans"].Amount)

			task.wait(2)
			BC2 = false
		end
	end
end)

buttons.BuyMotherboard.MouseButton1Click:Connect(function()
	if CheckWetherAmountExsists["MotherBoard"].Amount == 0 then
		TL2.Text = "NO STOCK"
		task.wait(1)
		TL2.Text = "Stock: 0"
	end

	if CheckWetherAmountExsists["MotherBoard"] == nil then
		TL2.Text = "NO STOCK"
		task.wait(1)
		TL2.Text = "Stock: 0"
	else
		if BC3 == false then
			if CheckWetherAmountExsists["MotherBoard"].Amount == 0 then return end
			
			BC3 = true
			RE:FireServer("MotherBoard")
			CheckWetherAmountExsists["MotherBoard"].Amount -= 1
			TL2.Text = string.format("Stock: %d", CheckWetherAmountExsists["MotherBoard"].Amount)
			
			task.wait(2)
			BC3 = false
		end
	end
end)

for i, v in pairs(CheckWetherAmountExsists) do
	print(i, v)
end
