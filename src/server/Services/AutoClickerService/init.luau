-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local Packages = ReplicatedStorage.Packages
local Services = ServerScriptService.Server.Services
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local ProfileService = require(Services.ProfileService)
local ClickService = require(Services.ClickService)
local BridgeNet2 = require(Packages.Bridgenet2)
local ClicksConfig = require(Configs.ClicksConfig)

local toggleAutoClickerEvent = BridgeNet2.ReferenceBridge("toggleAutoClickerEvent")

local AutoClickerService = {}

--stylua: ignore
function AutoClickerService:init()
    toggleAutoClickerEvent:Connect(function(player)
        self:onButtonClick(player)
    end)

    self:Loop()
end

--stylua: ignore
function AutoClickerService:onButtonClick(player)
	local playerData = ProfileService:GetData(player)
	local togglePlayerData = playerData.Settings.AutoClicker

	local toggle = not togglePlayerData

	local playerSettings = player:WaitForChild("Settings")
	local toggleInstace = playerSettings:WaitForChild("AutoClicker")
	playerData.Settings.AutoClicker = toggle
	toggleInstace.Value = toggle
end

function AutoClickerService:Loop()
	local cooldown = ClicksConfig.Clicker.Cooldown
	task.spawn(function()
		while true do
			for _, p in Players:GetPlayers() do
				local playerData = ProfileService:GetData(p)

				if playerData and playerData.Settings.AutoClicker then
					ClickService:onButtonClick(p, { playerData.Settings.ActiveMainCurrency })
				end
			end
			task.wait(cooldown)
		end
	end)
end

return AutoClickerService
