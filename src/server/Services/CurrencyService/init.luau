-- services

-- references

-- modules
local ProfileStore = require(script.Parent.ProfileService)

local CurrencyService = {}

--stylua: ignore
function CurrencyService:init() 

end

function CurrencyService:AddCurrency(player: Player, path: {}, amount: number)
    --data
	local playerData = ProfileStore:GetData(player)
	if not playerData then return end
	if not path or #path == 0 then return end

	local currentTable = playerData

	for i = 1, #path - 1 do
		local key = path[i]

		if typeof(currentTable[key]) ~= "table" then return end
		currentTable = currentTable[key]
	end

	local amountKey = path[#path]
	if typeof(currentTable[amountKey]) ~= "number" then return end

	currentTable[amountKey] += amount

    -- folder
	local currencyInstance = player
	for i = 1, #path do
		local key = path[i]
		currencyInstance = currencyInstance:FindFirstChild(key)
		if not currencyInstance then return end
	end

	if currencyInstance:IsA("NumberValue") then
		currencyInstance.Value += amount
	end
end

function CurrencyService:RemoveCurrency(player: Player, path: {}, amount: number)
	self:AddCurrency(player, path, -amount)
end

function CurrencyService:GetCurrency(player: Player, path: {})
	local playerData = ProfileStore:GetData(player)
	if not playerData then return end
	if not path or #path == 0 then return end

	local currentTable = playerData

	for i = 1, #path do
		local key = path[i]

		if i == #path then
			if typeof(currentTable[key]) ~= "table" then return currentTable[key] end
		end

		if typeof(currentTable[key]) ~= "table" then return nil end
		currentTable = currentTable[key]
	end

	return nil
end

return CurrencyService
