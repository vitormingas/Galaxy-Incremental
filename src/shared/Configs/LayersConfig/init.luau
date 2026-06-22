local LayersConfig = {

	Nebula = {
		Cost = 100,
		Currency = "Stardust",
		Description = [[Resets <font color="rgb(152, 78, 255)">Stardust</font> balance, and all ]]
			.. [[<font color="rgb(152, 78, 255)">Stardust Upgrades</font> levels.]],
		Resets = {
			Currencies = {
				"Stardust",
			},

			Upgrades = {
				"Stardust",
			},

			Layers = {},
		},
	},
}

return LayersConfig
