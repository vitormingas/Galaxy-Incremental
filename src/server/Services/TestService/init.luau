-- services
local Players = game:GetService("Players")

-- references

-- modules
local ProfileStore = require(script.Parent.ProfileService)

local TestService = {}

local part = workspace.Part :: Part

part.Touched:Connect(function(player: Player)
	local p = Players:GetPlayerFromCharacter(player.Parent)
	local data = ProfileStore:GetData(p)
	data.Currencies.StarDust.Amount += 1
	local value = p:WaitForChild("Currencies"):WaitForChild("StarDust"):WaitForChild("Amount")
	value.Value = data.Currencies.StarDust.Amount
end)

return TestService
