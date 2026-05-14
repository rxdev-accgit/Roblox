return {
	[0] = {
		["Upgrade1"] = {
			Name = "Swift Fingers",
			--UpgradeClaimed = false,
			Price = 50,
			ClicksPerTap = 2,
			Description = "Click Faster, earn more"
		},
		["Upgrade2"] = {
			Name = "Coin Magnet",
			--UpgradeClaimed = false,
			Description = "Boost Your Click Multiplier",
			Multiplier = 1.2,
			Price = 100,
		},
		["Upgrade3"] = { --Initial autoclicker!
			Name = "Rookie Bot",
			UpdateAutoClicker = true,
			--UpgradeClaimed = false,
			Description = "Auto Clicker",
			ClicksPerSecond = 1,
			Price = 200
		}
	},
	[1] = {
		Requirements = {
			ClicksNeeded = 1000,
			MoneyNeeded = 5000,
			RebirthMultiplier = 2 
		},
		["Upgrade1"] = {
			Name = "Turbo Tap",
			--UpgradeClaimed = false,
			Description = "Supercharged clicks",
			ClicksPerTap = 10,
			Price = 500
		},
		["Upgrade2"] = {
			Name = "Wealth Engine",
			--UpgradeClaimed = false,
			Description = "Serious multiplier boost",
			Multiplier = 2,
			Price = 1000,
		},
		["Upgrade3"] = {
			Name = "Click Drone",
			--UpgradeClaimed = false,
			UpdateAutoClicker = true,
			Description = "Faster auto clicking",
			ClicksPerSecond = 8,
			Price = 2000
		}
	},
	[2] = {
		Requirements = {
			ClicksNeeded = 10000,
			MoneyNeeded = 10000,
			RebirthMultiplier = 4
		},
		["Upgrade1"] = {
			Name = "Hands Of Agility Itself",
			--UpgradeClaimed = false,
			Description = "Clicks that hit different",
			ClicksPerTap = 75,
			Price = 5000
		},
		["Upgrade2"] = {
			Name = "Infinity Engine",
			--UpgradeClaimed = false,
			Description = "Unstoppable multiplier",
			Multiplier = 5,
			Price = 10000,
		},
		["Upgrade3"] = {
			Name = "Click Army",
			--UpgradeClaimed = false,
			Description = "An army clicking for you",
			UpdateAutoClicker = true,
			ClicksPerSecond = 30,
			Price = 25000
		}
	}
}
