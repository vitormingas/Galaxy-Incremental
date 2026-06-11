-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)
local ClicksConfig = require(Configs.ClicksConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local bottomHud = mainScreenGui:WaitForChild("BottomHUD")
local autoClickerFrame = bottomHud:WaitForChild("AutoClicker")

local playerSettings = player:WaitForChild("Settings")
local activeCurrencyData: StringValue = playerSettings:WaitForChild("ActiveMainCurrency")
local toggleData: BoolValue = playerSettings:WaitForChild("AutoClicker")

local activeAcButton: ImageButton = autoClickerFrame:WaitForChild("Active")
local toggleImage = activeAcButton:WaitForChild("Toggle") :: ImageLabel

local toggleAutoClickerEvent = BridgeNet2.ReferenceBridge("toggleAutoClickerEvent")

local AutoClickerController = {}

--stylua: ignore
function AutoClickerController:init()
	self:SetupAutoClicker()

	activeAcButton.MouseButton1Click:Connect(function()
		toggleAutoClickerEvent:Fire()
	end)

	activeCurrencyData.Changed:Connect(function(newCurrency)
		 self:UpdateAutoClicker(newCurrency) 
	end)

	toggleData.Changed:Connect(function(newState)
		self:UpdateToggleImage(newState)
	end)
end

--stylua: ignore
function AutoClickerController:SetupAutoClicker()
	local playerCurrencies = player:WaitForChild("Currencies")

	local playerWallet = playerCurrencies:WaitForChild(activeCurrencyData.Value)
	local activeIcon = ClicksConfig.Icons[activeCurrencyData.Value]
	local toggleIcon

	if toggleData.Value == true then 
		toggleIcon = ClicksConfig.Icons.Toggle.On
	else
		toggleIcon = ClicksConfig.Icons.Toggle.Off
	end

	if not playerWallet then return end
	if not activeIcon then return end

	activeAcButton.Image = activeIcon
	toggleImage.Image = toggleIcon
end

function AutoClickerController:UpdateAutoClicker(newCurrency)
	local newCurrencyIcon = ClicksConfig.Icons[newCurrency]

	if not newCurrencyIcon then return end

	activeAcButton.Image = newCurrencyIcon
end

function AutoClickerController:UpdateToggleImage(newState)
	local toggleIcon = ClicksConfig.Icons.Toggle.Off

	if newState == true then toggleIcon = ClicksConfig.Icons.Toggle.On end

	toggleImage.Image = toggleIcon
end

return AutoClickerController
