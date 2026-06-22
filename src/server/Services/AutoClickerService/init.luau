-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local Packages = ReplicatedStorage.Packages
local Services = ServerScriptService.Server.Services

-- modules
local BoostService = require("./BoostService")
local ProfileService = require(Services.ProfileService)
local ClickService = require(Services.ClickService)
local BridgeNet2 = require(Packages.Bridgenet2)

local toggleAutoClickerEvent = BridgeNet2.ReferenceBridge("toggleAutoClickerEvent")
local autoClickerPopupEvent = BridgeNet2.ReferenceBridge("autoClickerPopupEvent")

local runningLoops = {}

local AutoClickerService = {}

--stylua: ignore
function AutoClickerService:init()
    toggleAutoClickerEvent:Connect(function(player)
        self:ToggleAutoClicker(player)
    end)

	ProfileService.DataLoaded.Event:Connect(function(player)
		self:StartLoop(player)
	end)

	for _, player in Players:GetPlayers() do
		local playerData = ProfileService:GetData(player)
		if playerData then
			self:StartLoop(player)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		runningLoops[player] = nil
	end)
end

--stylua: ignore
function AutoClickerService:ToggleAutoClicker(player)
	local playerData = ProfileService:GetData(player)
	local togglePlayerData = playerData.Settings.AutoClickerEnabled

	local toggle = not togglePlayerData

	local playerSettings = player:WaitForChild("Settings")
	local toggleInstace = playerSettings:WaitForChild("AutoClickerEnabled")

	local activeCurrency = playerData.Settings.ActiveMainCurrency

	if not BoostService:HasStat(player, `{activeCurrency}AcUnlocked`) then
		player:WaitForChild("Stats"):WaitForChild("Unlocks"):WaitForChild(`{activeCurrency}AcUnlocked`).Value = false
		return
	end

	playerData.Settings.AutoClickerEnabled = toggle
	toggleInstace.Value = toggle

	if toggle == true then
		self:StartLoop(player)
	end
end

--stylua: ignore
function AutoClickerService:StartLoop(player)
	if runningLoops[player] then return end
	runningLoops[player] = true

	task.spawn(function()
		while runningLoops[player] do
			local playerData = ProfileService:GetData(player)
			if not playerData then break end

			if playerData.Settings.AutoClickerEnabled ~= true then
				break
			end

			local activeCurrency = playerData.Settings.ActiveMainCurrency

			if not BoostService:HasStat(player, `{activeCurrency}AcUnlocked`) then
				player:WaitForChild("Stats"):WaitForChild("Unlocks"):WaitForChild(`{activeCurrency}AcUnlocked`).Value = false
				break
			end

			ClickService:onButtonClick(player, { activeCurrency })
			autoClickerPopupEvent:Fire(player)

			local cooldown = BoostService:GetStat(player, `{activeCurrency}AcCooldown`)
			task.wait(cooldown)
		end

		runningLoops[player] = nil
	end)
end

return AutoClickerService
