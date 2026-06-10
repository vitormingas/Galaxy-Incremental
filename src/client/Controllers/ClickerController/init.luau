-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local ClickerConfig = require(Configs.Clickers)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local clicksButtonsFrame = mainScreenGui:WaitForChild("ClickButtons")

local playerSettings = player:WaitForChild("Settings")
local activeClicker = playerSettings:WaitForChild("ActiveClicker")

local ClickerController = {}

function ClickerController:init()
	self:SetupClicker()
	activeClicker.Changed:Connect(function(newCurrency) self:UpdateClicker(newCurrency) end)
end

function ClickerController:SetupClicker()
	local playerCurrencies = player:WaitForChild("Currencies")

	local playerWallet = playerCurrencies:WaitForChild(activeClicker)
	local activeConfig = ClickerConfig[activeClicker]

	if not playerWallet then return end
	if not activeConfig then return end

	local activeClickButton: ImageButton = clicksButtonsFrame:WaitForChild("Active")
	activeClickButton.Image = ClickerConfig[activeClicker].Icon
end

function ClickerController:UpdateClicker(newCurrency)
	local activeClickButton: ImageButton = clicksButtonsFrame:WaitForChild("Active")
	local newCurrencyConfig = ClickerConfig[newCurrency]

	if not newCurrencyConfig then return end

	activeClickButton.Image = newCurrencyConfig.Icon
end

return ClickerController
