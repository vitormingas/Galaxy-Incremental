local Utils = require(script.Utils)

local DataConfig = {}

DataConfig.Template = {

	Currencies = {
		StarDust = {
			Amount = 0,
			Multiplier = 1,
		},
	},

	Stats = {
		Playtime = 0, -- seconds
	},

	Settings = {
		ActiveClicker = "StarDust",
	},
}

Utils:DeepFreeze(DataConfig)

return DataConfig
