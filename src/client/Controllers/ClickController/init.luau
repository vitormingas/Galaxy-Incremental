-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- references
local Packages = ReplicatedStorage.Packages
local clickAssets = ReplicatedStorage.Assets.Clicks

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local popupsGui = playerGui:WaitForChild("Popups")

local playerSettings = player:WaitForChild("Settings")
local activeCurrencyData: StringValue = playerSettings:WaitForChild("ActiveMainCurrency")

local circleFrame: Frame = clickAssets:WaitForChild("CircleClick")
local circleSizeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local circleTranspTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local clickEvent = BridgeNet2.ReferenceBridge("clickEvent")

local activeEffects = {}

local ClickController = {}

--stylua: ignore
function ClickController:init()
	UserInputService.InputEnded:Connect(function(input, processed)
        self:ClickCurrency(input, processed)
        self:CircleEffect(input, processed)
	end)
end

--stylua: ignore
function ClickController:ClickCurrency(input: InputObject, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    clickEvent:Fire({activeCurrencyData.Value})
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

    effect.Size = UDim2.fromOffset(0, 0)
    effect.Position = UDim2.fromOffset(clickPos.X, clickPos.Y)
    effect.Parent = popupsGui

    local sizeProps = {Size = circleFrame.Size}
    local frameTranspProps = {BackgroundTransparency = 1}
    local uiStrokeTranspProps = {Transparency = 1}

    local sizeTween = TweenService:Create(effect, circleSizeTweenInfo, sizeProps)
    local frameTranspTween = TweenService:Create(effect, circleTranspTweenInfo, frameTranspProps)
    local StrokeTranspTween = TweenService:Create(effect.UIStroke, circleTranspTweenInfo, uiStrokeTranspProps)

    sizeTween:Play()
    frameTranspTween:Play()
    StrokeTranspTween:Play()
    frameTranspTween.Completed:Connect(function()
        local index = table.find(activeEffects, effect)
        if index then
            table.remove(activeEffects, index)
        end
        effect:Destroy()
    end)
end

return ClickController
