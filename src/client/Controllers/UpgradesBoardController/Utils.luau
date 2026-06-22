local FormatService = require("@game/ReplicatedStorage/Shared/Modules/FormatService")
local UpgradesMathService = require("@game/ReplicatedStorage/Shared/Modules/UpgradesMathService")

local Utils = {}

-- stylua: ignore
function Utils:GetBoostText(upgradeConfig, level)
	local boost = UpgradesMathService:GetBoost(upgradeConfig, level)
    local suffix = upgradeConfig.Display.Suffix
    local suffixPos = upgradeConfig.Display.SuffixPos


	if typeof(boost) == "number" then
        if suffixPos == "Front" or suffixPos == "" then 
            return `{suffix}{FormatService:Format(boost)}`
        elseif suffixPos == "Back" then
            return `{FormatService:Format(boost)}{suffix}`
        end
		
	end

	if typeof(boost) == "boolean" then
		if boost then
			return "Active"
		else
			return "Off"
		end
	end

	return ""
end

return Utils
