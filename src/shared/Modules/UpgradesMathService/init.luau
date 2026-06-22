local UpgradesMathService = {}

function UpgradesMathService:GetCost(upgradeConfig, level)
	local upgInfos = upgradeConfig.Cost
	local cost = upgInfos.Base * (upgInfos.Growth ^ level)
	return math.floor(cost)
end

--stylua: ignore
function UpgradesMathService:GetBoost(upgradeConfig, level)
	local boostInfos = upgradeConfig.Boost

	if boostInfos.Type == "Boolean" then
		if level <= 0 then return false end
		if level > 0 then return true end
	end

	local value = boostInfos.Base

	if level == 0 then
		return value
	elseif boostInfos.Type == "+" then
		value = boostInfos.Base + (boostInfos.Increment * level)
	elseif boostInfos.Type == "*" then
		if boostInfos.Increment <= 1 then
			warn(`{upgradeConfig.Display.Name} increment is "*" but the rate is <= 1`)
			return value
		end
		value = boostInfos.Base * (boostInfos.Increment ^ level)
	else
		warn(`{upgradeConfig.Display.Name} is not a valid boost`)
	end

	if upgradeConfig.Display.Suffix == "s" then
		value = math.round(value * 1000) / 1000
	end

	return value
end

function UpgradesMathService:GetMaxBuy(upConfig, currentLevel, balance)
	local buyMax = 0
	local totalCost = 0
	local tempBalance = balance

	while true do
		local level = currentLevel + buyMax
		local cost = UpgradesMathService:GetCost(upConfig, level)

		if level >= upConfig.MaxLevel then break end
		if tempBalance < cost then break end

		tempBalance -= cost
		totalCost += cost
		buyMax += 1
	end

	return buyMax, totalCost
end

return UpgradesMathService
