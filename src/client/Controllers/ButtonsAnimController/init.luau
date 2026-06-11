-- services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

-- references
local UiSounds = SoundService:WaitForChild("Ui")

-- modules

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local clickSound: Sound = UiSounds:WaitForChild("ClickSound")
local hoverSound: Sound = UiSounds:WaitForChild("HoverSound")

local clickTweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local hoverTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local unHoverTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local ButtonsAnimController = {}

--stylua: ignore
function ButtonsAnimController:init()

    local function setupUI(ui)
        self:LinkButtonAnim(ui)
        self:LinkButtonSound(ui)
    end
	
    playerGui.DescendantAdded:Connect(function(ui)
        self:LinkButtonSound(ui)
        self:LinkButtonAnim(ui)
    end)

    for _, ui in playerGui:GetDescendants() do
        setupUI(ui)
	end
end

--stylua: ignore
function ButtonsAnimController:LinkButtonSound(ui)
    if not ui:IsA("GuiButton") then return end
    ui.MouseButton1Click:Connect(function()
        clickSound:Play()
    end)
    ui.MouseEnter:Connect(function()
        hoverSound:Play()
    end)
end

--stylua: ignore
function ButtonsAnimController:LinkButtonAnim(ui)
    if not ui:IsA("GuiButton") then return end
    local clickProps = {Size = ui.Size - UDim2.fromScale(0.08, 0.04)}
    local inProps = {Size = ui.Size + UDim2.fromScale(0.16, 0.08)}
    local outProps = {Size = ui.Size}

    local clickTween = TweenService:Create(ui, clickTweenInfo, clickProps)
    local hoverTween = TweenService:Create(ui, hoverTweenInfo, inProps)
    local unHoverTween = TweenService:Create(ui, unHoverTweenInfo, outProps)

    ui.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    ui.MouseLeave:Connect(function()
        unHoverTween:Play()
    end)
    ui.MouseButton1Down:Connect(function()
        clickTween:Play()
    end)
    ui.MouseButton1Up:Connect(function()
        hoverTween:Play()
    end)
end

return ButtonsAnimController
