local Utils = require(script.Utils)

local DataConfig = {}

DataConfig.Template = {
	-- currencies
	Currencies = {
		Stardust = {
			Amount = 0,
		},
		Nebula = {
			Amount = 0,
		},
	},

	-- upgrades
	Upgrades = {
		Stardust = {
			MoreStardust = 0,
			FirstAutomation = 0,
			FastAutoClicker = 0,
		},
		Nebula = {},
	},

	-- stats
	Stats = {
		Playtime = 0, -- seconds
		Multipliers = {},
		Unlocks = {},
		Cooldowns = {},
	},

	-- settings
	Settings = {
		ActiveMainCurrency = "Stardust",
		AutoClickerEnabled = false,
	},
}

Utils:DeepFreeze(DataConfig)

return DataConfig
