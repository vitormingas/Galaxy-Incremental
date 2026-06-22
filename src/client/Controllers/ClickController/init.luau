-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- references
local Packages = ReplicatedStorage.Packages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local PopupAnimService = require(ReplicatedStorage.Shared.Modules.PopupAnimService)
local ClicksConfig = require(Configs.ClicksConfig)
local BridgeNet2 = require(Packages.Bridgenet2)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local popupsGui = playerGui:WaitForChild("Popups")

local playerSettings = player:WaitForChild("Settings")
local activeCurrencyData: StringValue = playerSettings:WaitForChild("ActiveMainCurrency")
local toggleAutoClicker: StringValue = playerSettings:WaitForChild("AutoClickerEnabled")

local clickAssets = ReplicatedStorage.Assets.Clicks
local currenciesAssets = ReplicatedStorage.Assets.Currencies

local circleFrame: Frame = clickAssets:WaitForChild("CircleClick")
local circleSizeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local circleTranspTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local popupFrame: Frame = clickAssets:WaitForChild("PopupGainScreen")

local textPopupSizeTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local textPopupPosTweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local textPopupTranspTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

local clickEvent = BridgeNet2.ReferenceBridge("clickEvent")

local activeEffects = {}

local ClickController = {}

--stylua: ignore
function ClickController:init()
	UserInputService.InputEnded:Connect(function(input, processed)
        self:ClickCurrency(input, processed)
        self:CircleEffect(input)
	end)

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
end

--stylua: ignore
function ClickController:ClickCurrency(input: InputObject, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if toggleAutoClicker.Value then return end

    local playerMultipliersFolder = player:WaitForChild("Stats"):WaitForChild("Multipliers")

    local baseAmount = ClicksConfig.Clicker.BaseValue
    local playerMulti = playerMultipliersFolder:WaitForChild(`{activeCurrencyData.Value}Multiplier`).Value
    local gain = baseAmount * playerMulti
    
    clickEvent:Fire({activeCurrencyData.Value})
    
    --anim
    PopupAnimService:ScreenCurrency({
        Gain = gain,
        Currency = activeCurrencyData.Value,
	    Position = UserInputService:GetMouseLocation(),
        PopupFrame = popupFrame,
        Parent = popupsGui,
        SpreadScale = 1,
        TextSize = 36,
    })
end
   
--stylua: ignore
function ClickController:CircleEffect(input: InputObject)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if #activeEffects >= 2 then
        local oldestEffect = table.remove(activeEffects, 1)
        if oldestEffect and oldestEffect.Parent then
            oldestEffect:Destroy()
        end
    end

    local clickPos = UserInputService:GetMouseLocation()
    local effect = circleFrame:Clone()

    table.insert(activeEffects, effect)

    effect.Size = UDim2.fromScale(0, 0)
    effect.Position = UDim2.fromOffset(clickPos.X, clickPos.Y)
    effect.Parent = popupsGui

    local sizeProps = {Size = circleFrame.Size}
    local frameTranspProps = {BackgroundTransparency = 1}
    local uiStrokeTranspProps = {Transparency = 1}

    local sizeTween = TweenService:Create(effect, circleSizeTweenInfo, sizeProps)
    local frameTranspTween = TweenService:Create(effect, circleTranspTweenInfo, frameTranspProps)
    local strokeTranspTween = TweenService:Create(effect.UIStroke, circleTranspTweenInfo, uiStrokeTranspProps)

    sizeTween:Play()
    frameTranspTween:Play()
    strokeTranspTween:Play()
    frameTranspTween.Completed:Connect(function()
        local index = table.find(activeEffects, effect)
        if index then
            table.remove(activeEffects, index)
        end
        effect:Destroy()
    end)
end

return ClickController
