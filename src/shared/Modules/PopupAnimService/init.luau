local TweenService = game:GetService("TweenService")

local randomGenerator = Random.new()

local PopupAnimService = {}

local DEFAULT_VIEWPORT_SIZE = Vector2.new(1920, 1080)

local function getViewportSize()
	local camera = workspace.CurrentCamera

	if not camera then return DEFAULT_VIEWPORT_SIZE end

	return camera.ViewportSize
end

local function getScreenScale()
	local viewportSize = getViewportSize()
	local scale = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)

	return math.clamp(scale, 0.65, 1.15)
end

local function getTextScale(text)
	local length = #text

	if length <= 3 then return 1 end

	return math.clamp(1 - ((length - 3) * 0.08), 0.68, 1)
end

local function scaledRandomInteger(minValue, maxValue, scale)
	return math.round(randomGenerator:NextInteger(minValue, maxValue) * scale)
end

local function multiplyUDim2(size, multiplier)
	return UDim2.new(
		size.X.Scale * multiplier,
		size.X.Offset * multiplier,
		size.Y.Scale * multiplier,
		size.Y.Offset * multiplier
	)
end

local function screenPositionToScale(position, parent)
	if parent and parent:IsA("GuiObject") then
		local parentSize = parent.AbsoluteSize
		local parentPosition = parent.AbsolutePosition

		if parentSize.X <= 0 or parentSize.Y <= 0 then
			warn("PopupAnimService: Parent has invalid AbsoluteSize.")
			return Vector2.new(0.5, 0.5)
		end

		local relativePosition = position - parentPosition

		return Vector2.new(relativePosition.X / parentSize.X, relativePosition.Y / parentSize.Y)
	end

	local viewportSize = getViewportSize()

	return Vector2.new(position.X / viewportSize.X, position.Y / viewportSize.Y)
end

local function addOffsetToUDim2(position, offsetX, offsetY)
	return UDim2.new(position.X.Scale, position.X.Offset + offsetX, position.Y.Scale, position.Y.Offset + offsetY)
end

local function resolvePopupPosition(position, parent, fallbackPosition)
	if position == nil then return fallbackPosition or UDim2.fromScale(0.5, 0.5) end

	if typeof(position) == "UDim2" then return position end

	if typeof(position) == "Vector2" then
		local scalePosition = screenPositionToScale(position, parent)

		return UDim2.fromScale(scalePosition.X, scalePosition.Y)
	end

	warn("PopupAnimService: Position must be a Vector2, UDim2, or nil.")
	return nil
end

function PopupAnimService:init(config)
	config = config or {}

	self.PopupFrame = config.PopupFrame
	self.PopupsGui = config.PopupsGui
	self.CurrenciesAssets = config.CurrenciesAssets
	self.FormatService = config.FormatService

	self.SizeTweenInfo = config.SizeTweenInfo or TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	self.MoveTweenInfo = config.MoveTweenInfo or TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	self.FadeTweenInfo = config.FadeTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
end

function PopupAnimService:ScreenCurrency(data)
	data = data or {}

	local selectedPopupFrame = data.PopupFrame or self.PopupFrame

	if not selectedPopupFrame then
		warn("PopupAnimService: PopupFrame is nil. Pass PopupFrame or call PopupAnimService:init({...}) first.")
		return
	end

	if typeof(selectedPopupFrame) ~= "Instance" or not selectedPopupFrame:IsA("GuiObject") then
		warn("PopupAnimService: PopupFrame must be a GuiObject.")
		return
	end

	if not self.CurrenciesAssets then
		warn("PopupAnimService: CurrenciesAssets is nil.")
		return
	end

	if not self.FormatService then
		warn("PopupAnimService: FormatService is nil.")
		return
	end

	local gain = data.Gain
	local currency = data.Currency
	local popupPositionData = data.Position
	local spreadScale = data.SpreadScale or 1
	local popupParent = data.Parent or self.PopupsGui
	local popupSize = data.PopupSize

	if not popupParent then
		warn("PopupAnimService: Parent is nil.")
		return
	end

	if typeof(popupParent) ~= "Instance" then
		warn("PopupAnimService: Parent must be an Instance.")
		return
	end

	if gain == nil then
		warn("PopupAnimService: Gain is nil.")
		return
	end

	if not currency then
		warn("PopupAnimService: Currency is nil.")
		return
	end

	if popupSize and typeof(popupSize) ~= "UDim2" then
		warn("PopupAnimService: PopupSize must be a UDim2.")
		return
	end

	local currencyAssets = self.CurrenciesAssets:FindFirstChild(currency)
	if not currencyAssets then
		warn("PopupAnimService: Currency assets not found:", currency)
		return
	end

	local currencyIcon = currencyAssets:FindFirstChild("Icon")
	local currencyText = currencyAssets:FindFirstChild("TextLabel")

	if not currencyText then
		warn("PopupAnimService: TextLabel not found for currency:", currency)
		return
	end

	local screenScale = getScreenScale()
	local movementScale = screenScale * spreadScale

	local resolvedPopupPosition = resolvePopupPosition(popupPositionData, popupParent, selectedPopupFrame.Position)

	if not resolvedPopupPosition then return end

	local popup = selectedPopupFrame:Clone()
	popup.AnchorPoint = Vector2.new(0.5, 0.5)

	if popupSize then popup.Size = popupSize end

	popup.Position = addOffsetToUDim2(
		resolvedPopupPosition,
		scaledRandomInteger(-5, 5, movementScale),
		scaledRandomInteger(-5, 5, movementScale)
	)

	popup.Rotation = 0
	popup.ClipsDescendants = false
	popup.Parent = popupParent

	local formattedGain = "+" .. self.FormatService:Format(gain)

	local textScale = getTextScale(formattedGain)

	local baseTextSize = data.TextSize or currencyText.TextSize
	local textFinalSize = baseTextSize * textScale
	local shadowFinalTextSize = baseTextSize * 1.38 * textScale

	local baseXOffset = scaledRandomInteger(-35, 35, movementScale)
	local baseYOffset = scaledRandomInteger(-90, -60, movementScale)

	local shadowXOffset = baseXOffset + scaledRandomInteger(-6, 6, movementScale)
	local shadowYOffset = baseYOffset - scaledRandomInteger(18, 30, movementScale)

	local iconSide = 1
	if randomGenerator:NextInteger(1, 2) == 1 then iconSide = -1 end

	local iconXOffset = baseXOffset + iconSide * scaledRandomInteger(65, 105, movementScale)
	local iconYOffset = baseYOffset + scaledRandomInteger(-35, 5, movementScale)

	local popupIcon
	local popupIconFinalSize
	local popupIconFadeTween

	if currencyIcon then
		popupIcon = currencyIcon:Clone()
		popupIcon.Name = "Icon"
		popupIcon.ZIndex = 1
		popupIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		popupIcon.Parent = popup
		popupIcon.Position = UDim2.fromScale(0.5, 0.35)
		popupIcon.Rotation = randomGenerator:NextNumber(-12, 12)

		popupIconFinalSize = multiplyUDim2(currencyIcon.Size, 0.5)
		popupIcon.Size = UDim2.fromScale(0, 0)

		if popupIcon:IsA("ImageLabel") or popupIcon:IsA("ImageButton") then
			popupIcon.ImageTransparency = 0.15

			popupIconFadeTween = TweenService:Create(popupIcon, self.FadeTweenInfo, {
				ImageTransparency = 1,
			})
		end
	end

	local popupShadow = currencyText:Clone()
	popupShadow.Name = "Shadow"
	popupShadow.ZIndex = 2
	popupShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	popupShadow.Parent = popup
	popupShadow.Text = formattedGain
	popupShadow.Size = multiplyUDim2(currencyText.Size, 1.38)
	popupShadow.Position = UDim2.new(0.5, 0, 0.35, scaledRandomInteger(-8, -8, movementScale))
	popupShadow.Rotation = randomGenerator:NextNumber(-3, 3)
	popupShadow.TextTransparency = 0.72
	popupShadow.TextScaled = false
	popupShadow.TextSize = 0

	local popupShadowStroke = popupShadow:FindFirstChildOfClass("UIStroke")
	if popupShadowStroke then popupShadowStroke.Transparency = 0.78 end

	local popupText = currencyText:Clone()
	popupText.Name = "Main"
	popupText.ZIndex = 3
	popupText.AnchorPoint = Vector2.new(0.5, 0.5)
	popupText.Parent = popup
	popupText.Text = formattedGain
	popupText.Size = currencyText.Size
	popupText.Position = UDim2.fromScale(0.5, 0.35)
	popupText.Rotation = randomGenerator:NextNumber(-2, 2)
	popupText.TextTransparency = 0
	popupText.TextScaled = false
	popupText.TextSize = 0

	local popupTextStroke = popupText:FindFirstChildOfClass("UIStroke")
	if popupTextStroke then popupTextStroke.Transparency = 0 end

	local popupTextSizeTween = TweenService:Create(popupText, self.SizeTweenInfo, {
		TextSize = textFinalSize,
	})

	local popupShadowSizeTween = TweenService:Create(popupShadow, self.SizeTweenInfo, {
		TextSize = shadowFinalTextSize,
	})

	local popupTextMoveTween = TweenService:Create(popupText, self.MoveTweenInfo, {
		Position = UDim2.new(0.5, baseXOffset, 0.35, baseYOffset),
		Rotation = popupText.Rotation + randomGenerator:NextNumber(-5, 5),
	})

	local popupShadowMoveTween = TweenService:Create(popupShadow, self.MoveTweenInfo, {
		Position = UDim2.new(0.5, shadowXOffset, 0.35, shadowYOffset),
		Rotation = popupShadow.Rotation + randomGenerator:NextNumber(-4, 4),
	})

	local popupTextFadeTween = TweenService:Create(popupText, self.FadeTweenInfo, {
		TextTransparency = 1,
	})

	local popupShadowFadeTween = TweenService:Create(popupShadow, self.FadeTweenInfo, {
		TextTransparency = 1,
	})

	local popupTextStrokeFadeTween
	if popupTextStroke then
		popupTextStrokeFadeTween = TweenService:Create(popupTextStroke, self.FadeTweenInfo, {
			Transparency = 1,
		})
	end

	local popupShadowStrokeFadeTween
	if popupShadowStroke then
		popupShadowStrokeFadeTween = TweenService:Create(popupShadowStroke, self.FadeTweenInfo, {
			Transparency = 1,
		})
	end

	popupShadowSizeTween:Play()
	popupTextSizeTween:Play()
	popupShadowMoveTween:Play()
	popupTextMoveTween:Play()

	if popupIcon and popupIconFinalSize then
		local popupIconSizeTween = TweenService:Create(popupIcon, self.SizeTweenInfo, {
			Size = popupIconFinalSize,
		})

		local popupIconMoveTween = TweenService:Create(popupIcon, self.MoveTweenInfo, {
			Position = UDim2.new(0.5, iconXOffset, 0.35, iconYOffset),
			Rotation = popupIcon.Rotation + randomGenerator:NextNumber(-45, 45),
		})

		popupIconSizeTween:Play()
		popupIconMoveTween:Play()
	end

	task.delay(0.38, function()
		if not popup.Parent then return end

		popupTextFadeTween:Play()
		popupShadowFadeTween:Play()

		if popupIconFadeTween then popupIconFadeTween:Play() end

		if popupTextStrokeFadeTween then popupTextStrokeFadeTween:Play() end

		if popupShadowStrokeFadeTween then popupShadowStrokeFadeTween:Play() end
	end)

	task.delay(1.05, function()
		if popup then popup:Destroy() end
	end)
end

return PopupAnimService
