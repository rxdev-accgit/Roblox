local PRManager = {}
PRManager.__index = PRManager

--Services & Modules
local DRS = game:GetService("DataStoreService")
local PRDatastore = DRS:GetDataStore("PR_DataSaving")
local PlaytimeRewardsData = require(script.Parent.PlaytimeRewards)
--

--Remote/Bindable Events & Functions
local PREvent = game.ReplicatedStorage.BindableEvents:WaitForChild("PRCommunication")

--

--Userfull Functions
function PRManager:SaveData(Player: Player, InfoTable)
	local succes, err
	local tries = 0
	local key = "Player_"..Player.UserId
	
	repeat
		succes, err = pcall(function()
			PRDatastore:SetAsync(key, InfoTable)
			
		end)
		tries += 1
	until succes or tries >= 5
end
--


--Constructor Method
function PRManager.InitializePR(Player: Player, Template: Frame, TemplateParent: Frame)
	local self = setmetatable({}, PRManager)

	Player:SetAttribute("PRCountAttribute", 0)
	
	
	self.RewardsTable = {
		[1] = {Data = PlaytimeRewardsData.FirstReward, IsProcessed = false},
		[2] = {Data = PlaytimeRewardsData.SecondReward, IsProcessed = false},
		[3] = {Data = PlaytimeRewardsData.ThirdReward, IsProcessed = false},
		[4] = {Data = PlaytimeRewardsData.FourthReward, IsProcessed = false},
		[5] = {Data = PlaytimeRewardsData.FifthReward, IsProcessed = false},
	}
	self.Template = Template
	self.PRCountAttribute = Player:GetAttribute("PRCountAttribute")
	
	self.Template["1"].Amount.Text = tostring(PlaytimeRewardsData["FirstReward"].Coins).."x"
	self.Template["2"].Amount.Text = tostring(PlaytimeRewardsData["SecondReward"].Coins).."x"
	self.Template["4"].Amount.Text = tostring(PlaytimeRewardsData["FourthReward"].Coins).."x"
	self.Template["5"].Amount.Text = tostring(PlaytimeRewardsData["FifthReward"].Coins).."x"
	
	self.Template.Parent = TemplateParent
	return self
end

--Methods

function PRManager:GrantReward(Player: Player, RewardType:string, RewardName:string)
	local reward = self.RewardsTable[RewardName]
	local PlayerStats: Folder = Player:WaitForChild("leaderstats")

	if Player and reward and not reward.IsProcessed then
		reward.IsProcessed = true
		PlayerStats.Coins.Value += reward.Data.Coins
	end
end




function PRManager:UpdatePR_Progress(Player: Player, PRCount: number)
	if Player and PRCount then
		Player:SetAttribute("PRCountAttribute", PRCount)
		self:GrantReward(Player, "Currency", PRCount)
		self:SaveData(Player, {
			PRCount = PRCount,
			Rewards = self.RewardsTable,
			PlayerCoins = Player.leaderstats.Coins.Value,
			LastResetTime = self.LastResetTime
		})
		
		self.Template[PRCount]["Claim"].Text = "Claimed"
		self.Template[PRCount]["Claim"].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
end





local RESET_INTERVAL = 60 --12 hrs

function PRManager:GlobalReset(Player: Player, Data, NotInitialGR)
	print("[MODULE SIDE]: Global reset initialized, working...")
	local CurrentTime = os.time()
	local lastreset = Data and Data.LastResetTime or 0

	if CurrentTime - lastreset >= RESET_INTERVAL then  -- ← add this back
		Data = {
			PRCount = 0,
			Rewards = nil,
			PlayerCoins = Data and Data.PlayerCoins or nil,
			LastResetTime = CurrentTime
		}

		Player:SetAttribute("PRCountAttribute", 0)

		for _, reward in pairs(self.RewardsTable) do
			reward["IsProcessed"] = false
		end

		self.LastResetTime = Data.LastResetTime

		for i = 1, #self.RewardsTable do
			if i == 3 then continue end
			self.Template[i].Claim.Text = "Locked"
			self.Template[i].Claim.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end

		self:SaveData(Player, Data)
		if NotInitialGR then
			PREvent:Fire(Player)
		end
		
		print("[MODULE SIDE]: Global reset successful for player: "..Player.Name)
	end

	return Data
end

function PRManager:StartResetCountdown(Player: Player)
	if self.CountdownActive then return end -- guard
	self.CountdownActive = true

	task.delay(RESET_INTERVAL, function()
		self.CountdownActive = false -- release guard
		if not Player.Parent then return end

		local key = "Player_"..tostring(Player.UserId)
		local succes, data = pcall(function()
			return PRDatastore:GetAsync(key)
		end)

		if succes then
			data = self:GlobalReset(Player, data or {}, true)
			--self:SaveData(Player, data) (Unnessecary to prevent throttling the DTS)
		end
	end)
end

function PRManager:LoadData(Player: Player)
	local key = "Player_"..tostring(Player.UserId)
	local data
	local succes, err
	local tries = 0
	
	repeat
		succes, err = pcall(function()
			data = PRDatastore:GetAsync(key)
		end)
		tries += 1
	until succes or tries >= 5
	
	
	if not succes then
		warn("Failed to load data for player: "..Player.Name.." ("..Player.UserId..")")
		return
	end
	
	if not data then
		return
	end
	
	self.LastResetTime = data.LastResetTime
	
	
	local resetData = self:GlobalReset(Player, data or {}, false)
	if resetData then
		data = resetData
	end

	if not data then return end
	
	if data.PlayerCoins then
		Player.leaderstats.Coins.Value = data.PlayerCoins
	end
	
	if data.PRCount then
		Player:SetAttribute("PRCountAttribute", data.PRCount or 0)
	end
	
	if data.Rewards then
		for i, rewardinfo in pairs(data.Rewards) do
			if self.RewardsTable[i] then
				self.RewardsTable[i]["IsProcessed"] = rewardinfo["IsProcessed"]
			end
		end
	end
	
	
	local currentpr = Player:GetAttribute("PRCountAttribute") or 0
	
	
	for i = 1, #self.RewardsTable do
		if i ==3 then continue end

		if i <= currentpr then
			self.Template[i]["Claim"].Text = "Claimed"
			self.Template[i]["Claim"].BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			self.Template[i]["Claim"].Text = "Locked"
			self.Template[i]["Claim"].BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		end
		
	end
end






--

return PRManager


