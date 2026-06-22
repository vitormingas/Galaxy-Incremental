local UpgradesConfig = {}

UpgradesConfig.Stardust = {
	MoreStardust = {
		Order = 1,
		Stat = "StardustMultiplier",
		MaxLevel = 100,

		Display = {
			Name = "More Stardust",
			Icon = "rbxassetid://134969655551707",
			Suffix = "x",
			SuffixPos = "Front",
		},

		Cost = {
			Currency = "Stardust",
			Base = 10,
			Growth = 1.25,
		},

		Boost = {
			Type = "*", --> * | + | Boolean
			Base = 1,
			Increment = 1.25,
		},
	},

	FirstAutomation = {
		Order = 2,
		Stat = "StardustAcUnlocked",
		MaxLevel = 1,

		Display = {
			Name = "First Automation",
			Icon = "rbxassetid://87719981020942",
			Suffix = "",
			SuffixPos = "",
		},

		Cost = {
			Currency = "Stardust",
			Base = 100,
			Growth = 1,
		},

		Boost = {
			Type = "Boolean", --> * | + | Boolean
		},
	},

	FastAutoClicker = {
		Order = 3,
		Stat = "StardustAcCooldown",
		MaxLevel = 9,

		Display = {
			Name = "Fast Auto Clicker",
			Icon = "rbxassetid://74868692770791",
			Suffix = "s",
			SuffixPos = "Back",
		},

		Cost = {
			Currency = "Stardust",
			Base = 10,
			Growth = 1.25,
		},

		Boost = {
			Type = "+", --> * | + | Boolean
			Base = 1,
			Increment = -0.1,
		},
	},
}

return UpgradesConfig
