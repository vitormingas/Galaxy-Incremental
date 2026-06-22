-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local LayersConfig = require(Configs.LayersConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local UpgradesMathService = require(ReplicatedStorage.Shared.Modules.UpgradesMathService)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerUpgrades = player:WaitForChild("Upgrades")
local playerCurrencies = player:WaitForChild("Currencies")

local layersGui = playerGui:WaitForChild("Layers")
local layersBoard = workspace:WaitForChild("Layers")
local upgradeTemplate: Frame = ReplicatedStorage.Assets.Upgrades.Template

local LayersBoardController = {}

--stylua: ignore
function LayersBoardController:init()
	self:SetupBoards()
end

--stylua: ignore
function LayersBoardController:SetupBoards()
	-- boards
	for layer, config in LayersConfig do
		local layerGui = layersGui:WaitForChild(layer):WaitForChild("Main")
		if not layerGui then continue end

		local modelBoard = layersBoard:WaitForChild(layer)
		if not modelBoard then continue end

		local mainBoard = modelBoard:WaitForChild("Main")

		layerGui.Adornee = mainBoard:WaitForChild("display")
		
		local layerAssets = ReplicatedStorage.Assets.Currencies[layer]
		local gradient = layerAssets:WaitForChild("Gradient")
		local icon = layerAssets:WaitForChild("Icon")

		local titleText = layerGui:WaitForChild("main"):WaitForChild("Title"):WaitForChild("TextLabel")
		titleText.Text = layer
		titleText:WaitForChild("Gradient").Color = gradient.Color

		local particle = mainBoard:WaitForChild("display"):WaitForChild("Particles")
		particle.Color = gradient.Color

		local bar = layerGui:WaitForChild("main"):WaitForChild("Bar")
		local barGradient = bar:WaitForChild("Gradient")
		barGradient.Color = gradient.Color
		
		local costCurrency = config.Currency
		local cost = config.Cost

		local costAssets = ReplicatedStorage.Assets.Currencies[costCurrency]
		local costGradient = costAssets:WaitForChild("Gradient")
		
		local playerCostBalance = playerCurrencies:WaitForChild(costCurrency):WaitForChild("Amount")
		local playerLayerBalance = playerCurrencies:WaitForChild(layer):WaitForChild("Amount")

		local mainFrame = layerGui:WaitForChild("main"):WaitForChild("Frame")

		local descriptionText = mainFrame:WaitForChild("Description")
		descriptionText.Text = config.Description
		
		local costFrame = mainFrame:WaitForChild("Cost")
		local costText = costFrame:WaitForChild("Cost")
		local costCurrencyText = costFrame:WaitForChild("Currency")

		costText.Text = `Cost: {FormatService:Format(cost)}`
		costCurrencyText.Text = costCurrency
		costCurrencyText:WaitForChild("Gradient").Color = costGradient.Color

		local balanceFrame = mainFrame:WaitForChild("Balance")
		local balanceIcon = balanceFrame:WaitForChild("Icon")
		local balanceText = balanceFrame:WaitForChild("TextLabel")

		balanceIcon.Image = icon.Image
		balanceText.Text = FormatService:Format(playerLayerBalance.Value)
		balanceText:WaitForChild("Gradient").Color = gradient.Color

		--self:UpdateBuyMax(currency)
	end
end

--stylua: ignore

--stylua: ignore
function LayersBoardController:UpdateDisplay(currency, newValue)
	local currencyUpgrades = upgradesGui:WaitForChild(currency)
	local currencyGui: SurfaceGui = currencyUpgrades:WaitForChild("Currency")

	local currencyDisplay = currencyGui:WaitForChild("main"):WaitForChild("display")
	local displayText = currencyDisplay:WaitForChild("TextLabel")

	displayText.Text = FormatService:Format(newValue)
end

--stylua: ignore
function LayersBoardController:UpdateBuyMax(currency)
	local currencyUpgradesGui = upgradesGui:WaitForChild(currency)
	if not currencyUpgradesGui then return end

	local playerUpgradesData = playerUpgrades:WaitForChild(currency)
	if not playerUpgradesData then return end

	local playerBalance = playerCurrencies:WaitForChild(currency):WaitForChild("Amount").Value
	if not playerBalance then return end
		
	local upgContainer: SurfaceGui = currencyUpgradesGui:WaitForChild("Main"):WaitForChild("main"):WaitForChild("ScrollingFrame")

	for _, upgradeInstance in playerUpgradesData:GetChildren() do 
		if not upgradeInstance:IsA("NumberValue") then continue end

		local upgradeName = upgradeInstance.Name
		local upgradeConfig =  UpgradesConfig[currency][upgradeName]
		if not upgradeConfig then continue end

		local upgFrame = upgContainer:WaitForChild(upgradeName)
		if not upgFrame then continue end

		local buyMaxButton = upgFrame:WaitForChild("BuyMax")
		if not buyMaxButton then continue end

		if upgradeInstance.Value >= upgradeConfig.MaxLevel then
			continue
		end

		local buyMax = UpgradesMathService:GetMaxBuy(upgradeConfig, upgradeInstance.Value, playerBalance)

		buyMaxButton.TextLabel.Text = `Buy Max ({FormatService:Format(buyMax)}x)`
	end
end

return LayersBoardController
