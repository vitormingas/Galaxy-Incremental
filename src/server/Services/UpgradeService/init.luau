-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local Packages = ReplicatedStorage.Packages
local Services = ServerScriptService.Server.Services
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local CurrencyService = require(Services.CurrencyService)
local BridgeNet2 = require(Packages.Bridgenet2)
local UpgradesConfig = require(Configs.UpgradesConfig)
local ProfileService = require(Services.ProfileService)
local BoostService = require(Services.BoostService)
local UpgradesMathService = require(ReplicatedStorage.Shared.Modules.UpgradesMathService)

local cooldowns = {}

local upgradeEvent = BridgeNet2.ReferenceBridge("upgradeEvent")

local UpgradeService = {}

--stylua: ignore
function UpgradeService:init()
    upgradeEvent:Connect(function(player, upgData)
        self:UpgradeBuy(player, upgData)
    end)

    Players.PlayerRemoving:Connect(function(p)
        self:CooldownsClear(p)
    end)
end

--stylua: ignore
function UpgradeService:UpgradeBuy(player, upgData) -- 1 -> buy one | 0 -> buy max
	local upgrade = upgData.Upgrade
	local amount = upgData.Amount

	local currency = upgrade[1]
	local upgradeName = upgrade[2]
	if typeof(upgradeName) ~= "string" or typeof(currency) ~= "string" or typeof(amount) ~= "number" then return end

	local upgConfig = UpgradesConfig[currency][upgradeName]
	if not upgConfig then return end

	local playerData = ProfileService:GetData(player)
	if not playerData then return end

	local currentTime = os.clock()
	local lastClickTime = cooldowns[player] or 0
	local cooldown = 0.1

	if currentTime - lastClickTime < cooldown then return end

	cooldowns[player] = currentTime

	local upgradePath = { "Upgrades", currency, upgradeName }
	local currencyPath = { "Currencies", currency, "Amount" }

	local playerUpgrades = playerData.Upgrades
	local playerLevel = playerUpgrades[currency][upgradeName]
	local playerBalance = playerData.Currencies[currency].Amount

	local statName = upgConfig.Stat

	if playerLevel >= upgConfig.MaxLevel then 
		playerData.Upgrades[currency][upgradeName] = upgConfig.MaxLevel
		return
	end

	if amount == 1 then
		local cost = UpgradesMathService:GetCost(upgConfig, playerLevel)
		if playerBalance < cost then return end

		CurrencyService:RemoveCurrency(player, currencyPath, cost)
		CurrencyService:AddCurrency(player, upgradePath, 1)
	elseif amount == 0 then
		local buyMax, totalCost = UpgradesMathService:GetMaxBuy(upgConfig, playerLevel, playerBalance)
		if buyMax <= 0 then return end

		CurrencyService:RemoveCurrency(player, currencyPath, totalCost)
		CurrencyService:AddCurrency(player, upgradePath, buyMax)
	end
	BoostService:UpdateStat(player, statName)
end

function UpgradeService:CooldownsClear(player)
	if not cooldowns[player] then return end
	cooldowns[player] = nil
end

return UpgradeService
