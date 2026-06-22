-- stylua: ignore
local FormatTimeService = {}

function FormatTimeService:Format(seconds)
	local days = math.floor(seconds / 86400)
	local remainingSeconds = seconds % 86400

	local hours = math.floor(remainingSeconds / 3600)
	remainingSeconds = remainingSeconds % 3600

	local minutes = math.floor(remainingSeconds / 60)
	remainingSeconds = remainingSeconds % 60

	if days >= 1 then return `{days}d {hours}h` end
	if hours >= 1 then return `{hours}h {minutes}m` end
	if minutes >= 1 then return `{minutes}m {remainingSeconds}s` end
	return `{seconds}s`
end

return FormatTimeService
