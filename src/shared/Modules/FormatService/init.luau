-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- references
local Packages = ReplicatedStorage.Packages

-- modules
local Formatnumber = require(Packages.Formatnumber).Main

-- stylua: ignore
local abbreviations = Formatnumber.Notation.compactWithSuffixThousands({
	"K", "M", "B", "T", "Qd", "Qn", "Sx", "Sp", "Oc", "No", "De"
})

local formatter = Formatnumber.NumberFormatter
	.with()
	:Notation(abbreviations)
	:Precision(Formatnumber.Precision.integer():WithMinDigits(3))

local FormatService = {}

function FormatService:Format(value)
	local n = tonumber(value)
	return formatter:Format(n)
end

return FormatService
