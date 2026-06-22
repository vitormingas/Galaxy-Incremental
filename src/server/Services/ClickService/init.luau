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
local ClicksConfig = require(Configs.ClicksConfig)
local ProfileService = require(Services.ProfileService)
local BoostService = require(Services.BoostService)

local cooldowns = {}

local clickEvent = BridgeNet2.ReferenceBridge("clickEvent")

local ClickService = {}

--stylua: ignore
function ClickService:init()
    clickEvent:Connect(function(player, currency)
        self:onButtonClick(player, currency)
    end)

    Players.PlayerRemoving:Connect(function(p)
        self:CooldownsClear(p)
    end)
end

function ClickService:onButtonClick(player, currency)
	local currencyName = currency[1]
	if typeof(currencyName) ~= "string" or not ClicksConfig.Icons[currencyName] then return end

	local playerData = ProfileService:GetData(player)
	if not playerData then return end

	local currentTime = os.clock()
	local lastClickTime = cooldowns[player] or 0
	local cooldown = ClicksConfig.Clicker.Cooldown

	if currentTime - lastClickTime < cooldown then return end

	cooldowns[player] = currentTime

	local currencyPath = { "Currencies", currencyName, "Amount" }

	local clickBase = ClicksConfig.Clicker.BaseValue
	local playerMultiplier = BoostService:GetStat(player, `{currencyName}Multiplier`)

	local amount = clickBase * playerMultiplier

	CurrencyService:AddCurrency(player, currencyPath, amount)
end

function ClickService:CooldownsClear(player)
	if not cooldowns[player] then return end
	cooldowns[player] = nil
end

return ClickService
