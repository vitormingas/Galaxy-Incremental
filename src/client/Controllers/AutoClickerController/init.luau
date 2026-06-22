-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)
local ClicksConfig = require(Configs.ClicksConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local PopupAnimService = require(ReplicatedStorage.Shared.Modules.PopupAnimService)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local popupsGui = playerGui:WaitForChild("Popups")
local bottomHud = mainScreenGui:WaitForChild("BottomHUD")
local autoClickerFrame: Frame = bottomHud:WaitForChild("AutoClicker")

local playerSettings = player:WaitForChild("Settings")
local playerStats = player:WaitForChild("Stats")

local activeCurrencyData: StringValue = playerSettings:WaitForChild("ActiveMainCurrency")
local toggleData: BoolValue = playerSettings:WaitForChild("AutoClickerEnabled")

local unlocksFolder = playerStats:WaitForChild("Unlocks")

local activeAcButton = autoClickerFrame:WaitForChild("Active") :: ImageButton
local toggleImage = activeAcButton:WaitForChild("Toggle") :: ImageLabel
local lockedImage = autoClickerFrame:WaitForChild("Locked")

local clickAssets = ReplicatedStorage.Assets.Clicks
local currenciesAssets = ReplicatedStorage.Assets.Currencies
local popupFrame: Frame = clickAssets:WaitForChild("PopupGainAutoClicker")
local popupContainer: Frame = popupsGui:WaitForChild("AutoClicker"):WaitForChild("AutoClickerContainer")

local textPopupSizeTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local textPopupPosTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local textPopupTranspTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local toggleAutoClickerEvent = BridgeNet2.ReferenceBridge("toggleAutoClickerEvent")
local autoClickerPopupEvent = BridgeNet2.ReferenceBridge("autoClickerPopupEvent")

local AutoClickerController = {}

--stylua: ignore
function AutoClickerController:init()
	self:SetupAutoClicker()

	activeAcButton.MouseButton1Click:Connect(function()
		if not self:HasCurrencyAutoClicker(activeCurrencyData.Value) then return end
		toggleAutoClickerEvent:Fire()
	end)

	activeCurrencyData.Changed:Connect(function(newCurrency)
		 self:UpdateAutoClicker(newCurrency) 
	end)

	toggleData.Changed:Connect(function(newState)
		self:UpdateToggleImage(newState)
	end)

	for _, unlockedAc in unlocksFolder:GetChildren() do 
		if not unlockedAc:IsA("BoolValue") then continue end
		if not unlockedAc.Name:match("AcUnlocked$") then continue end

		unlockedAc.Changed:Connect(function()
			self:UpdateAutoClicker(activeCurrencyData.Value)
		end)
	end

	--anim
	PopupAnimService:init({
		PopupFrame = popupFrame,
		PopupsGui = popupsGui,
		CurrenciesAssets = currenciesAssets,
		FormatService = FormatService,
		SizeTweenInfo = textPopupSizeTweenInfo,
		MoveTweenInfo = textPopupPosTweenInfo,
		FadeTweenInfo = textPopupTranspTweenInfo,
	})

	autoClickerPopupEvent:Connect(function()
		self:Popup()
	end)
end

--stylua: ignore
function AutoClickerController:SetupAutoClicker()
	local playerCurrencies = player:WaitForChild("Currencies")

	local playerWallet = playerCurrencies:WaitForChild(activeCurrencyData.Value)
	local activeIcon = ClicksConfig.Icons[activeCurrencyData.Value]
	local toggleIcon

	if self:HasCurrencyAutoClicker(activeCurrencyData.Value) == false then 
		activeAcButton.Visible = false
		lockedImage.Visible = true
		return
	end
	
	activeAcButton.Visible = true
	lockedImage.Visible = false

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

	if self:HasCurrencyAutoClicker(newCurrency) == false then
		activeAcButton.Visible = false
		lockedImage.Visible = true
		return
	end

	activeAcButton.Visible = true
	lockedImage.Visible = false

	if not newCurrencyIcon then return end

	activeAcButton.Image = newCurrencyIcon

	self:UpdateToggleImage(toggleData.Value)
end

function AutoClickerController:UpdateToggleImage(newState)
	local toggleIcon = ClicksConfig.Icons.Toggle.Off

	if newState == true then toggleIcon = ClicksConfig.Icons.Toggle.On end

	toggleImage.Image = toggleIcon
end

--stylua: ignore
--anim
function AutoClickerController:Popup()
	local currencyName = activeCurrencyData.Value
	if toggleData.Value == true and self:HasCurrencyAutoClicker(currencyName) == true then
		local playerMultipliersFolder = player:WaitForChild("Stats"):WaitForChild("Multipliers")
		local multiplier = playerMultipliersFolder:WaitForChild(`{currencyName}Multiplier`).Value
		local gain = ClicksConfig.Clicker.BaseValue * multiplier
		if not gain then return end

		PopupAnimService:ScreenCurrency({
			Gain = gain,
			Currency = currencyName,
			Position = popupFrame.Position,
			PopupFrame = popupFrame,
			Parent = popupContainer,
			SpreadScale = 0.65,
			TextSize = 24,
		})
	end
end

-- extras
function AutoClickerController:HasCurrencyAutoClicker(currency)
	local hasCurrencyAutoclicker = unlocksFolder:FindFirstChild(`{currency}AcUnlocked`)

	if not hasCurrencyAutoclicker then return false end
	return hasCurrencyAutoclicker.Value == true
end

return AutoClickerController
