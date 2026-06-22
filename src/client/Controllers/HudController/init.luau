-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- references
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local DataConfig = require(Configs.DataConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local UpgradesBoardController = require(script.Parent.UpgradesBoardController)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mainScreenGui = playerGui:WaitForChild("Main")
local leftHud = mainScreenGui:WaitForChild("LeftHUD")
local currenciesFrame = leftHud:WaitForChild("Currencies")

local dataTemplate = DataConfig.Template
local playerCurrencies = player:WaitForChild("Currencies")

local gainTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)

local randomGenerator = Random.new()

local frameSizes = {}
local animatingFrames = {}

local lastBalances = {}
local gainsPerSecond = {}

local HudController = {}

--stylua: ignore
function HudController:init()
	self:SetupCurrencies()

	for _, currencyFolder in playerCurrencies:GetChildren() do
		local currency = currencyFolder.Name
		if not dataTemplate.Currencies[currency] then continue end

		local playerWallet = currencyFolder:WaitForChild("Amount")
		if not playerWallet then continue end
		
		playerWallet.Changed:Connect(function(newValue)
			self:UpdateCurrency(currency, newValue)
			self:CalculateGain(currency, newValue)
			UpgradesBoardController:UpdateDisplay(currency, newValue)
			UpgradesBoardController:UpdateBuyMax(currency)
		end)
		self:GainLoop(currency)
	end
end

--stylua: ignore
function HudController:SetupCurrencies()
	for _, currencyFolder in playerCurrencies:GetChildren() do
		local currency = currencyFolder.Name
		if not dataTemplate.Currencies[currency] then continue end

		local currencyFrame = currenciesFrame:WaitForChild(currency)
		if not currencyFrame then continue end

		if not frameSizes[currency] then
			frameSizes[currency] = currencyFrame.Size
		end

		local textLabel: TextLabel = currencyFrame:WaitForChild("TextLabel")
		local playerWallet = playerCurrencies:WaitForChild(currency):WaitForChild("Amount")
		if not playerWallet then continue end

		lastBalances[currency] = playerWallet.Value
		gainsPerSecond[currency] = 0
		textLabel.Text = FormatService:Format(playerWallet.Value)
	end
end

--stylua: ignore
function HudController:UpdateCurrency(currency: string, amount: number)
	local currencyFrame = currenciesFrame:FindFirstChild(currency)
	local textLabel: TextLabel = currencyFrame:FindFirstChild("TextLabel")
	local textFlash: TextLabel = currencyFrame:FindFirstChild("TextFlash")
	if not currencyFrame or not textLabel then return end

	self:GainAnimation(currency, currencyFrame, textLabel, textFlash)
	textLabel.Text = FormatService:Format(amount)
	textFlash.Text = FormatService:Format(amount)
end

--stylua: ignore
function HudController:CalculateGain(currency: string, newValue: number)

	if not lastBalances[currency] then return end
	if not gainsPerSecond[currency] then return end 

	local gain = newValue - lastBalances[currency]
	lastBalances[currency] = newValue

	if gain > 0 then
		gainsPerSecond[currency] += gain
	end
end

--stylua: ignore
function HudController:GainLoop(currency)
	task.spawn(function()
		while true do 
			local currencyFrame = currenciesFrame:FindFirstChild(currency)
			local textGain: TextLabel = currencyFrame:FindFirstChild("Gains")
			if not currencyFrame or not textGain then return end

			local gain = gainsPerSecond[currency]
			gainsPerSecond[currency] = 0

	        textGain.Text = `{FormatService:Format(gain)}/s`

			task.wait(1)
		end
	end)
end

--stylua: ignore
function HudController:GainAnimation(currency, currencyFrame, textLabel, textFlash)
	if not animatingFrames[currency] then
		animatingFrames[currency] = true
		textFlash.Visible = true

		local baseSize = frameSizes[currency]
		local gainProps = { Size = baseSize + UDim2.fromScale(0.02, 0.015) }
		local gainTween = TweenService:Create(currencyFrame, gainTweenInfo, gainProps)

		local randomRot = randomGenerator:NextNumber(-5, 5)
		local jitterProps = { Rotation = randomRot }
		local jitterTweenLabel = TweenService:Create(textLabel, TweenInfo.new(0.05), jitterProps)
		local jitterTweenFlash = TweenService:Create(textFlash, TweenInfo.new(0.05), jitterProps)

		jitterTweenLabel:Play()
		jitterTweenFlash:Play()
		gainTween:Play()

		gainTween.Completed:Connect(function()
			animatingFrames[currency] = false
			textFlash.Visible = false
			textLabel.Rotation = 0
			textFlash.Rotation = 0
		end)
	end
end

return HudController
