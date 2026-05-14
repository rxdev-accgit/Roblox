local ClickManager = {}
ClickManager.__index = ClickManager

--Services & Datastores
local DTS = game:GetService("DataStoreService")
local ClicksDTS = DTS:GetDataStore("CLicks_DTS")
--

--Modules
local UpgradeData = require(script.Parent:WaitForChild("UpgradeData"))
--

-- Datastore Usefull Variables
local ATTEMPT_LIMIT = 5
--

--Events
local CDSEvent = game.ReplicatedStorage.CDS_Events:WaitForChild("CDS_InfoCommunication")
--


--Constructor Method
function ClickManager.Initialize(Player: Player)
	print("[CLICKMANAGER]: Initializing for player: "..Player.Name.." ("..Player.UserId..")")
	local self = setmetatable({}, ClickManager)

	self.ClickInfo = {
		["Player_"..Player.UserId] = {
			Clicks = 0,
			Multiplier = 1,
			RebirthMultiplier = 1,
			TotalClicksEver = 0,
			ClickPerTap = 1,
			--...
		},
	}

	self.Rebirths = 0

	self.AutoClicker = {
		["Player_"..Player.UserId] = {
			CanActivate = false,
			AutoClickRate = 0,
			ClicksPerSecond = 0,
		}
	}

	self.PurchasedUpgrades = {}

	Player:SetAttribute("Clicks", 0)
	Player:SetAttribute("Rebirths", 0)
	
	
	Player:SetAttribute("OwnsAutoClicker", false)
	print("[CLICKMANAGER]: OwnsAutoClicker set to:", Player:GetAttribute("OwnsAutoClicker"))

	print("[CLICKMANAGER]: Initialization complete for player: "..Player.Name)
	return self
end

--Methods
function ClickManager:LoadClicks(Player: Player)
	print("[CLICKMANAGER]: Attempting to load data for player: "..Player.Name)
	local succes, ClickInfoTable
	local tries = 0
	local key = "["..Player.Name.."]_"..tostring(Player.UserId)

	repeat
		print("[CLICKMANAGER]: DataStore fetch attempt "..tries + 1 .." for player: "..Player.Name)
		succes, ClickInfoTable = pcall(function()
			return ClicksDTS:GetAsync(key)
		end)
		tries += 1
	until succes and ClickInfoTable or tries >= ATTEMPT_LIMIT

	if not succes or not ClickInfoTable then
		warn("Failed to load data for player: "..Player.Name.." ("..Player.UserId.."), err: ", ClickInfoTable)
		print("[CLICKMANAGER]: Assigning default data for player: "..Player.Name)
		self.ClickInfo = {
			["Player_"..Player.UserId] = {
				Clicks = 0,
				Multiplier = 1,
				RebirthMultiplier = 1,
				TotalClicksEver = 0,
				ClickPerTap = 1
				--...
			},
		}
		self.Rebirths = 0

		self.AutoClicker = {
			["Player_"..Player.UserId] = {
				CanActivate = false,
				AutoClickRate = 0,
				ClicksPerSecond = 0,
			}
		}

		self.PurchasedUpgrades = {}


		Player:SetAttribute("Clicks", 0)
		Player:SetAttribute("Rebirths", 0)
		Player:SetAttribute("OwnsAutoClicker", false)
		return 
	end

	print("[CLICKMANAGER]: Data found, configuring state for player: "..Player.Name)

	--Configure ClickInfo
	self.ClickInfo["Player_"..Player.UserId].Clicks = ClickInfoTable.ClickInfo.Clicks
	self.ClickInfo["Player_"..Player.UserId].Multiplier = ClickInfoTable.ClickInfo.Multiplier
	self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier = ClickInfoTable.ClickInfo.RebirthMultiplier
	self.ClickInfo["Player_"..Player.UserId].TotalClicksEver = ClickInfoTable.ClickInfo.TotalClicksEver
	self.ClickInfo["Player_"..Player.UserId].ClickPerTap = ClickInfoTable.ClickInfo.ClickPerTap
	
	print("[CLICKMANAGER]: ClickInfo configured — Clicks:", self.ClickInfo["Player_"..Player.UserId].Clicks, "| Multiplier:", self.ClickInfo["Player_"..Player.UserId].Multiplier, "| RebirthMultiplier:", self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier, "| ClickPerTap:", self.ClickInfo["Player_"..Player.UserId].ClickPerTap)
	--

	--Configure Rebirth Counter
	self.Rebirths = ClickInfoTable.Rebirths
	print("[CLICKMANAGER]: Rebirths configured —", self.Rebirths)
	--

	--Configure AutoClicker
	self.AutoClicker["Player_"..Player.UserId].AutoClickRate = ClickInfoTable.AutoClicker.AutoClickRate
	self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond = ClickInfoTable.AutoClicker.ClicksPerSecond
	self.AutoClicker["Player_"..Player.UserId].CanActivate = false
	print("[CLICKMANAGER]: AutoClicker configured — ClicksPerSecond:", self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond, "| CanActivate:", self.AutoClicker["Player_"..Player.UserId].CanActivate)

	--Configure PurchaseUpgrades Table
	self.PurchasedUpgrades = ClickInfoTable.PurchasedUpgrades
	print("[CLICKMANAGER]: PurchasedUpgrades configured —", self.PurchasedUpgrades)
	--

	--Set Attribute
	Player:SetAttribute("Clicks", self.ClickInfo["Player_"..Player.UserId].Clicks)
	Player:SetAttribute("Rebirths", ClickInfoTable.Rebirths)
	Player:SetAttribute("OwnsAutoClicker", ClickInfoTable.OwnsAutoClicker)
	
	print("[CLICKMANAGER]: Load complete for player: "..Player.Name)
end

function ClickManager:SaveData(Player: Player)
	print("[CLICKMANAGER]: Attempting to save data for player: "..Player.Name)
	local key = "["..Player.Name.."]_"..tostring(Player.UserId)
	local succes, err
	local tries = 0

	repeat
		print("[CLICKMANAGER]: DataStore save attempt "..tries + 1 .." for player: "..Player.Name)
		succes, err = pcall(function()
			ClicksDTS:SetAsync(key, {
				ClickInfo = self.ClickInfo["Player_"..Player.UserId],
				Rebirths = self.Rebirths,
				AutoClicker = self.AutoClicker["Player_"..Player.UserId],
				PurchasedUpgrades = self.PurchasedUpgrades,
				OwnsAutoClicker = Player:GetAttribute("OwnsAutoClicker")
			})
		end)
		tries += 1		
	until succes or tries >= ATTEMPT_LIMIT

	if succes then
		return true, print("[MODULE SIDE]: Succesfully saved data for player: "..Player.Name)
	else
		return false, warn("[MODULE SIDE]: Couldnt save data for player: "..Player.Name..", err: ", err)
	end
end

function ClickManager:AddClick(Player: Player)
	local SendInfoVar = 0
	self.ClickInfo["Player_"..Player.UserId].TotalClicksEver += math.round((1 * self.ClickInfo["Player_"..Player.UserId].Multiplier * self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier) + (self.ClickInfo["Player_"..Player.UserId].ClickPerTap - 1))
	self.ClickInfo["Player_"..Player.UserId].Clicks += math.round((1 * self.ClickInfo["Player_"..Player.UserId].Multiplier * self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier) + (self.ClickInfo["Player_"..Player.UserId].ClickPerTap - 1))
	SendInfoVar += math.round((1 * self.ClickInfo["Player_"..Player.UserId].Multiplier * self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier) + (self.ClickInfo["Player_"..Player.UserId].ClickPerTap - 1))
	local NewClickAmount = self.ClickInfo["Player_"..Player.UserId].Clicks

	CDSEvent:FireClient(Player, SendInfoVar)
	
	--print("[CLICKMANAGER]: Click registered for "..Player.Name.." — Clicks:", NewClickAmount, "| TotalClicksEver:", self.ClickInfo["Player_"..Player.UserId].TotalClicksEver)

	Player:SetAttribute("Clicks", NewClickAmount)
	if Player.leaderstats.Clicks then
		Player.leaderstats.Clicks.Value = NewClickAmount
	end

	return self.ClickInfo["Player_"..Player.UserId]
end

function ClickManager:Rebirth(Player: Player, RebirthAmount: number)
	print("[CLICKMANAGER]: Rebirth attempted by "..Player.Name.." — RebirthAmount:", RebirthAmount, "| Current Clicks:", self.ClickInfo["Player_"..tostring(Player.UserId)].Clicks)
	if RebirthAmount == 0 then 
		print("[CLICKMANAGER]: Rebirth blocked — RebirthAmount is 0")
		return 
	end
	
	if self.Rebirths == RebirthAmount then --unnesecary but worth checking
		print("[CLICKMANAGER]: Rebirth blocked — Player already has the most recent rebirth")
		return
	end

	if self.ClickInfo["Player_"..tostring(Player.UserId)].Clicks >= UpgradeData[RebirthAmount].Requirements["ClicksNeeded"] then
		self.Rebirths += 1
		Player:SetAttribute("Rebirths", self.Rebirths)
		self.ClickInfo["Player_"..tostring(Player.UserId)].Clicks = 0
		self.ClickInfo["Player_"..tostring(Player.UserId)].RebirthMultiplier = UpgradeData[RebirthAmount].Requirements["RebirthMultiplier"]

		self.PurchasedUpgrades = {}

		Player:SetAttribute("Clicks", 0)

		print("[CLICKMANAGER]: Rebirth successful for "..Player.Name.." — Total Rebirths:", self.Rebirths, "| New RebirthMultiplier:", self.ClickInfo["Player_"..tostring(Player.UserId)].RebirthMultiplier)
		return true
	else
		warn("Player: "..Player.Name.." ("..Player.UserId..") tried to rebirth without enough clicks")
		print("[CLICKMANAGER]: Rebirth failed — Clicks needed:", UpgradeData[RebirthAmount].Requirements["ClicksNeeded"], "| Player has:", self.ClickInfo["Player_"..tostring(Player.UserId)].Clicks)
		return false
	end
end

function ClickManager:Upgrade(Player: Player, Upgrade:string, Bought: boolean)
	print("[CLICKMANAGER]: Upgrade attempted by "..Player.Name.." — Upgrade:", Upgrade, "| Bought:", Bought)
	--...
	local UpgradeTable = UpgradeData[self.Rebirths] --Returns a list of upgrades depending on which rebirth number it is
	if UpgradeTable and not self.PurchasedUpgrades[Upgrade] and self.ClickInfo["Player_"..Player.UserId].Clicks >= UpgradeTable[Upgrade].Price and Bought then
		self.PurchasedUpgrades[Upgrade] = true
		self.ClickInfo["Player_"..Player.UserId].Clicks -= UpgradeTable[Upgrade].Price
		print("[CLICKMANAGER]: Upgrade claimed — "..Upgrade)

		if UpgradeTable[Upgrade].ClicksPerTap then
			self.ClickInfo["Player_"..Player.UserId].ClickPerTap = UpgradeTable[Upgrade].ClicksPerTap
			print("[CLICKMANAGER]: ClickPerTap updated —", self.ClickInfo["Player_"..Player.UserId].ClickPerTap)
		end

		if UpgradeTable[Upgrade].Multiplier then
			self.ClickInfo["Player_"..Player.UserId].Multiplier += UpgradeTable[Upgrade].Multiplier
			print("[CLICKMANAGER]: Multiplier updated —", self.ClickInfo["Player_"..Player.UserId].Multiplier)
		end

		if UpgradeTable[Upgrade].UpdateAutoClicker and UpgradeTable[Upgrade].ClicksPerSecond then
			Player:SetAttribute("OwnsAutoClicker", true)
			self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond = UpgradeTable[Upgrade].ClicksPerSecond
			print("[CLICKMANAGER]: AutoClicker ClicksPerSecond updated —", self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond)
		end
	else
		print("[CLICKMANAGER]: Upgrade blocked for "..Player.Name.." — Already purchased or invalid")
	end
end

function ClickManager:StartAutoClicker(Player:Player, IsBought: boolean)
	if IsBought then
		self.AutoClicker["Player_"..Player.UserId].CanActivate = true
		Player:SetAttribute("OwnsAutoClicker", true)
	end
	
	while Player.Parent do --Runs continiously while player is in game
		--print("[CLICKMANAGER]: AutoClicker Passive Activated")
		
		if self.AutoClicker["Player_"..Player.UserId].CanActivate then
			for i = 1, self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond do
				self:AddClick(Player)
				--print("[CLICKMANAGER]: AutoClicker Active In Action —", self.AutoClicker["Player_"..Player.UserId].ClicksPerSecond)
			end
		end
		
		task.wait(1)
	end
end

function ClickManager:StopAutoClicker(Player: Player)
	self.AutoClicker["Player_"..Player.UserId].CanActivate = false
end

function ClickManager:ResetProgress(Player: Player)
	self.ClickInfo["Player_"..Player.UserId].Clicks = 0
	self.ClickInfo["Player_"..Player.UserId].Multiplier = 1
	self.PurchasedUpgrades = {}
	self.ClickInfo["Player_"..Player.UserId].RebirthMultiplier = 1
	self.ClickInfo["Player_"..Player.UserId].ClickPerTap = 1
	self.ClickInfo["Player_"..Player.UserId].TotalClicksEver = 0
	self.Rebirths = 0
	self.AutoClicker["Player_"..Player.UserId] = {
		CanActivate = false,
		AutoClickRate = 0,
		ClicksPerSecond = 0,
	}
	
	Player:SetAttribute("Clicks", 0)
	Player:SetAttribute("Rebirths", 0)
	Player:SetAttribute("OwnsAutoClicker", false)
	
	print("[CLICKMANAGER]: Progress reset for player:", Player.Name)
end



return ClickManager
