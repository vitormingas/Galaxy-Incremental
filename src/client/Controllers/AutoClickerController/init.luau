-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)
local ClickerConfig = require(Configs.ClickersConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local bottomHud = mainScreenGui:WaitForChild("BottomHUD")
local autoClickerFrame = bottomHud:WaitForChild("AutoClicker")

local playerSettings = player:WaitForChild("Settings")
local activeCurrencyData: StringValue = playerSettings:WaitForChild("ActiveMainCurrency")
local activeAcButton: ImageButton = autoClickerFrame:WaitForChild("Active")

local clickEvent = BridgeNet2.ReferenceBridge("clickEvent")

local AutoClickerController = {}

--stylua: ignore
function AutoClickerController:init()
	self:SetupAutoClicker()

	activeCurrencyData.Changed:Connect(function(newCurrency)
		 self:UpdateAutoClicker(newCurrency) 
	end)

	activeAcButton.MouseButton1Click:Connect(function()
	 	clickEvent:Fire({activeCurrencyData.Value}) 
	end)
end

function AutoClickerController:SetupAutoClicker()
	local playerCurrencies = player:WaitForChild("Currencies")

	local playerWallet = playerCurrencies:WaitForChild(activeCurrencyData.Value)
	local activeConfig = ClickerConfig[activeCurrencyData.Value]

	if not playerWallet then return end
	if not activeConfig then return end

	activeAcButton.Image = activeConfig.Icon
end

function AutoClickerController:UpdateAutoClicker(newCurrency)
	local newCurrencyConfig = ClickerConfig[newCurrency]

	if not newCurrencyConfig then return end

	activeAcButton.Image = newCurrencyConfig.Icon
end

return AutoClickerController
