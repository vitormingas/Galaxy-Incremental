-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local DataConfig = require(Configs.DataConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local currenciesFrame = mainScreenGui:WaitForChild("Currencies")

local dataTemplate = DataConfig.Template
local playerCurrencies = player:WaitForChild("Currencies")

local HudController = {}

function HudController:init()
	self:SetupCurrencies()

	for _, currencyFolder in playerCurrencies:GetChildren() do
		local currency = currencyFolder.Name
		if not dataTemplate.Currencies[currency] then continue end

		local playerWallet = playerCurrencies:WaitForChild(currency):WaitForChild("Amount")
		if not playerWallet then continue end

		playerWallet.Changed:Connect(function(newValue) self:UpdateCurrency(currency, newValue) end)
	end
end

function HudController:SetupCurrencies()
	for _, currencyFolder in playerCurrencies:GetChildren() do
		local currency = currencyFolder.Name
		if not dataTemplate.Currencies[currency] then continue end

		local currencyFrame = currenciesFrame:WaitForChild(currency)
		if not currencyFrame then continue end

		local textLabel: TextLabel = currencyFrame:WaitForChild("TextLabel")
		local playerWallet = playerCurrencies:WaitForChild(currency):WaitForChild("Amount")
		if not playerWallet then continue end

		textLabel.Text = FormatService:Format(playerWallet.Value)
	end
end

function HudController:UpdateCurrency(currency: string, amount: number)
	local currencyFrame = currenciesFrame:WaitForChild(currency)
	if not currencyFrame then return end

	local textLabel: TextLabel = currencyFrame:WaitForChild("TextLabel")
	textLabel.Text = FormatService:Format(amount)
end

return HudController
