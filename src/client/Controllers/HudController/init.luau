-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local DataConfig = require(Configs.DataConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")
local dataTemplate = DataConfig.Template

local HudController = {}

function HudController:init() self:SetupCurrencies() end

function HudController:SetupCurrencies()
	local playerCurrencies = player:WaitForChild("Currencies")

	for _, currencyFolder in playerCurrencies:GetChildren() do
		local currency = currencyFolder.Name
		if not dataTemplate.Currencies[currency] then continue end

		local currenciesFrame = playerGui:WaitForChild("Main"):WaitForChild("Currencies")
		local currencyFrame = currenciesFrame:WaitForChild(currency)
		if not currencyFrame then continue end

		local textLabel: TextLabel = currencyFrame:WaitForChild("TextLabel")
		local playerWallet = playerCurrencies:WaitForChild(currency):WaitForChild("Amount")
		if not playerWallet then continue end

		textLabel.Text = FormatService:Format(playerWallet.Value)
	end
end

return HudController
