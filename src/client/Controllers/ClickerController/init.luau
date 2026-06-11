-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)
local ClickerConfig = require(Configs.Clickers)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local clickersButtonsFrame = mainScreenGui:WaitForChild("ClickerButtons")

local playerSettings = player:WaitForChild("Settings")
local activeClickerData: StringValue = playerSettings:WaitForChild("ActiveClicker")
local activeClickerButton: ImageButton = clickersButtonsFrame:WaitForChild("Active")

local clickEvent = BridgeNet2.ReferenceBridge("clickEvent")

local ClickerController = {}

--stylua: ignore
function ClickerController:init()
	self:SetupClicker()

	activeClickerData.Changed:Connect(function(newCurrency)
		 self:UpdateClicker(newCurrency) 
	end)

	activeClickerButton.MouseButton1Click:Connect(function()
	 clickEvent:Fire({ activeClickerData.Value }) 
	end)
end

function ClickerController:SetupClicker()
	local playerCurrencies = player:WaitForChild("Currencies")

	local playerWallet = playerCurrencies:WaitForChild(activeClickerData.Value)
	local activeConfig = ClickerConfig[activeClickerData.Value]

	if not playerWallet then return end
	if not activeConfig then return end

	activeClickerButton.Image = activeConfig.Icon
end

function ClickerController:UpdateClicker(newCurrency)
	local newCurrencyConfig = ClickerConfig[newCurrency]

	if not newCurrencyConfig then return end

	activeClickerButton.Image = newCurrencyConfig.Icon
end

return ClickerController
