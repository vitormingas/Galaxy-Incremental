-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages

-- modules
local BridgeNet2 = require(Packages.Bridgenet2)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local upgradesGui = playerGui:WaitForChild("Upgrades")

local upgradeEvent = BridgeNet2.ReferenceBridge("upgradeEvent")

local UpgradeController = {}

--stylua: ignore
function UpgradeController:init()
    upgradesGui.DescendantAdded:Connect(function(ui)
        self:LinkBuyButtons(ui)
    end)

    for _, ui in upgradesGui:GetDescendants() do
        self:LinkBuyButtons(ui)
	end
end

--stylua: ignore
function UpgradeController:BuyUpgrade(upgrade: {}, amount)
    if not (amount == 0 or amount == 1) then return end
    upgradeEvent:Fire({Upgrade = upgrade, Amount = amount})
end

--stylua: ignore
function UpgradeController:LinkBuyButtons(ui)
    if not ui:IsA("GuiButton") then return end
    if not (ui.Name == "BuyOne" or ui.Name == "BuyMax") then return end
    if ui:GetAttribute("UpgradeBuyLinked") then return end

    local upgFrame = ui.Parent
    if not upgFrame then return end 
    
    local currencyFolder = upgFrame:FindFirstAncestorWhichIsA("Folder")
    if not currencyFolder then return end

    local upgradeName = upgFrame.Name
    local currency = currencyFolder.Name

    local amount

    if ui.Name == "BuyOne" then
        amount = 1
    elseif ui.Name == "BuyMax" then 
        amount = 0
    end

    ui.MouseButton1Click:Connect(function()
	self:BuyUpgrade({ currency, upgradeName }, amount)
    end)
    
    ui:SetAttribute("UpgradeBuyLinked", true)
end

return UpgradeController
