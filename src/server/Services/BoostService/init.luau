-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local Services = ServerScriptService.Server.Services
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local UpgradesConfig = require(Configs.UpgradesConfig)
local UpgradesMathService = require(ReplicatedStorage.Shared.Modules.UpgradesMathService)
local ProfileService = require(Services.ProfileService)

local BoostService = {}

--stylua: ignore
function BoostService:init()
    Players.PlayerAdded:Connect(function(player)
        self:UpdateAllStats(player)
    end)

    for _, player in Players:GetPlayers() do 
        self:UpdateAllStats(player)
    end
end

function BoostService:GetStat(player, statName)
	local playerData = ProfileService:GetData(player)
	local stat = 1

	stat *= self:GetUpgradesStats(playerData, statName)
	return stat
end

--stylua: ignore
function BoostService:HasStat(player, statName)
	local playerData = ProfileService:GetData(player)
	if not playerData or not playerData.Upgrades then return false end

	for currency, upgList in UpgradesConfig do
		for upgName, upgData in upgList do
			if upgData.Stat ~= statName then continue end
			if upgData.Boost.Type ~= "Boolean" then continue end
			if not playerData.Upgrades[currency] then continue end

			local playerLevel = playerData.Upgrades[currency][upgName]
			if not playerLevel then continue end

			if playerLevel > 0 then 
				return true
			end
		end
	end

	return false
end

--stylua: ignore
function BoostService:UpdateStat(player, statName)
	local statsFolder = player:FindFirstChild("Stats")
	if not statsFolder then return end

	local playerStat = statsFolder:FindFirstChild(statName, true)
	if not playerStat then return end

	if playerStat:IsA("NumberValue") then
		local value = self:GetStat(player, playerStat.Name)
		if value == nil then return end
		playerStat.Value = value
	elseif playerStat:IsA("BoolValue") then 
		local value = self:HasStat(player, playerStat.Name)
		playerStat.Value = value
	end
end

--stylua: ignore
function BoostService:UpdateAllStats(player)
	local statsFolder = player:WaitForChild("Stats")
	if not statsFolder then return end

	for _, statValue in statsFolder:GetDescendants() do
		if statValue:IsA("NumberValue") then
			local value = self:GetStat(player, statValue.Name)
			if value == nil then continue end
			statValue.Value = value
		elseif statValue:IsA("BoolValue") then 
			local value = self:HasStat(player, statValue.Name)
			statValue.Value = value
		end
	end
end

-- extras
function BoostService:GetUpgradesStats(playerData, statName)
	local upgStat = 1

	if not playerData or not playerData.Upgrades then return 1 end

	for currency, upgList in UpgradesConfig do
		for upgName, upgData in upgList do
			if upgData.Stat ~= statName then continue end
			if upgData.Boost.Type == "Boolean" then continue end
			if not playerData.Upgrades[currency] then continue end

			local playerLevel = playerData.Upgrades[currency][upgName]
			if not playerLevel or playerLevel == 0 then continue end

			local playerBoost = UpgradesMathService:GetBoost(upgData, playerLevel)
			if not playerBoost then continue end

			upgStat *= playerBoost
		end
	end
	return upgStat
end

return BoostService
