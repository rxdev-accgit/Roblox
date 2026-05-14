local CDSEvent = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_Client-ServerCommunication")
local Player = game.Players.LocalPlayer
local CDSEvent2 = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_InfoCommunication")

local TweenService = game:GetService("TweenService")
local TI = TweenInfo.new(.7, Enum.EasingStyle.Sine)


local CDSUIFolder = Player.PlayerGui:WaitForChild("CDS_ClickCounterUIs")

local CounterGUI = CDSUIFolder:WaitForChild("CounterGUI")
local ClickGUI = CDSUIFolder:WaitForChild("ClickGUI")
local VFX_GUI = CDSUIFolder:WaitForChild("VFXGUI")

local Templates = VFX_GUI:WaitForChild("Templates")

local CounterFrame = CounterGUI:WaitForChild("Frame")
local ClickFrame = ClickGUI:WaitForChild("Frame")
local SpawnerFrame = VFX_GUI:WaitForChild("SpawnerFrame")


local CounterLabel = CounterFrame:WaitForChild("TextLabel")
local ClickButton = ClickFrame:WaitForChild("TextButton")

local function HandleClicks(Player: Player)
	CDSEvent:FireServer()
end

ClickButton.Activated:Connect(function()
	HandleClicks()
	local ClickingVFX = Templates:WaitForChild("Clicking"):Clone()
	
	ClickingVFX.Parent = SpawnerFrame
	ClickingVFX.Position = UDim2.new(math.random(0, 1), 0, math.random(0, 1), 0)
	
	
	local ClickingVFXLabel = ClickingVFX:WaitForChild("TextLabel")
	ClickingVFXLabel.Position = UDim2.new(math.random(0, 523)/1000, 0, math.random(0, 500)/1000, 0)
	ClickingVFXLabel.Visible = true
	
	CDSEvent2.OnClientEvent:Connect(function(SIV)
		print(SIV)
		ClickingVFXLabel.Text = "+"..tostring(SIV)
	end)
	
	local goal = {
		TextTransparency = 1,
		Position = UDim2.new(ClickingVFXLabel.Position.X.Scale, 0, ClickingVFXLabel.Position.Y.Scale - .1, 0)
	}
	
	local Tween = TweenService:Create(ClickingVFXLabel, TI, goal)
	local Tween2 = TweenService:Create(ClickingVFXLabel.UIStroke, TI, {Transparency = 1})
	Tween:Play()
	Tween2:Play()
	
	Tween.Completed:Connect(function()
		ClickingVFX:Destroy()
	end)
end)

Player:GetAttributeChangedSignal("Clicks"):Connect(function()
	CounterLabel.Text = "Clicks: "..Player:GetAttribute("Clicks")
end)


--X = .523, Y = .5

--{0.523, 0},{0.5, 0}
