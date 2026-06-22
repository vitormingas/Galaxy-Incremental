-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local UpgradesConfig = require(Configs.UpgradesConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local UpgradesMathService = require(ReplicatedStorage.Shared.Modules.UpgradesMathService)
local Utils = require(script.Utils)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerUpgrades = player:WaitForChild("Upgrades")
local playerCurrencies = player:WaitForChild("Currencies")

local upgradesGui = playerGui:WaitForChild("Upgrades")
local upgradesBoard = workspace:WaitForChild("Upgrades")
local upgradeTemplate: Frame = ReplicatedStorage.Assets.Upgrades.Template

local UpgradesBoardController = {}

--stylua: ignore
function UpgradesBoardController:init()
	self:SetupBoards()

	for _, upgrade in player:WaitForChild("Upgrades"):GetDescendants() do 
		if not upgrade:IsA("NumberValue") then continue end
		upgrade.Changed:Connect(function(newLevel)
			self:UpdateBoard(upgrade.Parent.Name, upgrade.Name, newLevel)
		end)
	end
end

--stylua: ignore
function UpgradesBoardController:SetupBoards()
	-- boards
	for _, currencyUpgradesFolder in playerUpgrades:GetChildren() do
		local currency = currencyUpgradesFolder.Name
		if not UpgradesConfig[currency] then continue end

		local currencyUpgrades = upgradesGui:WaitForChild(currency)
		if not currencyUpgrades then continue end

		local modelBoard = upgradesBoard:WaitForChild(currency)
		if not modelBoard then continue end

		local mainGui: SurfaceGui = currencyUpgrades:WaitForChild("Main")
		local currencyGui: SurfaceGui = currencyUpgrades:WaitForChild("Currency")

		local mainBoard = modelBoard:WaitForChild("Main")
		local currencyBoard = modelBoard:WaitForChild("Currency")

		mainGui.Adornee = mainBoard:WaitForChild("display")
		currencyGui.Adornee = currencyBoard:WaitForChild("display")

		local currencyAssets = ReplicatedStorage.Assets.Currencies[currency]
		local currencyIcon = currencyAssets:WaitForChild("Icon")
		local gradient = currencyAssets:WaitForChild("Gradient")

		local particle = mainBoard:WaitForChild("display"):WaitForChild("Particles")
		particle.Color = gradient.Color

		local bar = mainGui:WaitForChild("main"):WaitForChild("Bar")
		local barGradient = bar:WaitForChild("Gradient")
		barGradient.Color = gradient.Color

		local playerCurrency = playerCurrencies:WaitForChild(currency)
		local playerBalance = playerCurrency:WaitForChild("Amount")

		local currencyDisplay = currencyGui:WaitForChild("main"):WaitForChild("display")
		local displayIcon = currencyDisplay:WaitForChild("Icon")
		local displayText = currencyDisplay:WaitForChild("TextLabel")

		displayText.Text = FormatService:Format(playerBalance.Value)
		displayText:WaitForChild("Gradient").Color = gradient.Color
		displayIcon.Image = currencyIcon.Image

		local titleText = mainGui:WaitForChild("main"):WaitForChild("Title"):WaitForChild("TextLabel")
		titleText.Text = `{currency} Upgrades`
		titleText:WaitForChild("Gradient").Color = gradient.Color

		-- frames
		for _, upgradeInstace in currencyUpgradesFolder:GetChildren() do 
			local upgradeName = upgradeInstace.Name
			local upgradeConfig = UpgradesConfig[currency][upgradeName]
			if not upgradeConfig then continue end

			local newFrame = upgradeTemplate:Clone()
			local scrollingFrame = mainGui:WaitForChild("main"):WaitForChild("ScrollingFrame")

			local playerLevel = upgradeInstace.Value

			newFrame.Name = upgradeName
			newFrame.Parent = scrollingFrame
			newFrame.LayoutOrder = upgradeConfig.Order

			local upgName = newFrame:WaitForChild("Name")
			local upgIcon = newFrame:WaitForChild("Icon")
			local upgLevel = newFrame:WaitForChild("Level")

			local upgBoostFrame = newFrame:WaitForChild("Boost")
			local upgActualBoost = upgBoostFrame:WaitForChild("ActualBoost")
			local upgNextBoost = upgBoostFrame:WaitForChild("NextBoost")

			local upgCostFrame = newFrame:WaitForChild("Cost")
			local upgCost = upgCostFrame:WaitForChild("Cost")
			local upgCostCurrency = upgCostFrame:WaitForChild("Currency")

			local upgMaxed = newFrame:WaitForChild("Maxed")
			upgMaxed:WaitForChild("Gradient").Color = gradient.Color

			upgName.Text = upgradeConfig.Display.Name
			upgName:WaitForChild("Gradient").Color = gradient.Color 
			upgIcon.Image = upgradeConfig.Display.Icon
			upgCostCurrency:WaitForChild("Gradient").Color = gradient.Color

			upgLevel.Text = `{FormatService:Format(playerLevel)}/{FormatService:Format(upgradeConfig.MaxLevel)}`
			upgActualBoost.Text = Utils:GetBoostText(upgradeConfig, playerLevel)

			if playerLevel >= upgradeConfig.MaxLevel then 
				self:SetMaxedDisplay(newFrame, upgradeConfig)
				continue
			end

			upgNextBoost.Text = Utils:GetBoostText(upgradeConfig, playerLevel + 1)

			local cost = UpgradesMathService:GetCost(upgradeConfig, playerLevel)
			upgCost.Text  = `Cost: {FormatService:Format(cost)}`
			upgCostCurrency.Text = currency
		end
		self:UpdateBuyMax(currency)
	end
end

--stylua: ignore
function UpgradesBoardController:UpdateBoard(currency, upg, newLevel)
	local upgradeConfig = UpgradesConfig[currency][upg]
	if not upgradeConfig then return end

	local mainGui = upgradesGui:WaitForChild(currency):WaitForChild("Main")
	local scrollingFrame = mainGui:WaitForChild("main"):WaitForChild("ScrollingFrame")
	local upgFrame = scrollingFrame:WaitForChild(upg)

	local upgLevel = upgFrame:WaitForChild("Level")

	local upgBoostFrame = upgFrame:WaitForChild("Boost")
	local upgActualBoost = upgBoostFrame:WaitForChild("ActualBoost")
	local upgNextBoost = upgBoostFrame:WaitForChild("NextBoost")
	
	local upgCostFrame = upgFrame:WaitForChild("Cost")
	local upgCost = upgCostFrame:WaitForChild("Cost")
	local upgCostCurrency = upgCostFrame:WaitForChild("Currency")

	upgLevel.Text = `{FormatService:Format(newLevel)}/{FormatService:Format(upgradeConfig.MaxLevel)}`
	upgActualBoost.Text = Utils:GetBoostText(upgradeConfig, newLevel)

	if newLevel >= upgradeConfig.MaxLevel then 
		self:SetMaxedDisplay(upgFrame, upgradeConfig)
		return
	end

	upgNextBoost.Text = Utils:GetBoostText(upgradeConfig, newLevel + 1)

	local cost = UpgradesMathService:GetCost(upgradeConfig, newLevel)
	upgCost.Text  = `Cost: {FormatService:Format(cost)}`
	upgCostCurrency.Text = currency
end

--stylua: ignore
function UpgradesBoardController:UpdateDisplay(currency, newValue)
	local currencyUpgrades = upgradesGui:WaitForChild(currency)
	local currencyGui: SurfaceGui = currencyUpgrades:WaitForChild("Currency")

	local currencyDisplay = currencyGui:WaitForChild("main"):WaitForChild("display")
	local displayText = currencyDisplay:WaitForChild("TextLabel")

	displayText.Text = FormatService:Format(newValue)
end

--stylua: ignore
function UpgradesBoardController:UpdateBuyMax(currency)
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

function UpgradesBoardController:SetMaxedDisplay(upgFrame, upgradeConfig)
	local upgBoostFrame = upgFrame:WaitForChild("Boost")
	local upgNextBoost = upgBoostFrame:WaitForChild("NextBoost")

	local upgCostFrame = upgFrame:WaitForChild("Cost")
	local maxed = upgFrame:WaitForChild("Maxed")
	local maxedLayer = upgFrame:WaitForChild("MaxedLayer")

	upgFrame.LayoutOrder = 99998 + upgradeConfig.Order

	upgNextBoost.Text = "MAX"
	upgCostFrame.Visible = false
	maxed.Visible = true
	maxedLayer.Visible = true

	upgFrame:WaitForChild("BuyOne").Visible = false
	upgFrame:WaitForChild("BuyMax").Visible = false
end

return UpgradesBoardController
