-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local Services = ServerScriptService.Server.Services

-- modules
local ProfileService = require(Services.ProfileService)
local FormatTimeService = require(ReplicatedStorage.Shared.Modules.FormatTimeService)

local PlaytimeService = {}

--stylua: ignore
function PlaytimeService:init()
    self:Loop()
end

function PlaytimeService:Loop()
	task.spawn(function()
		while true do
			for _, p in Players:GetPlayers() do
				local playerData = ProfileService:GetData(p)
				local playtimeInstance = p:WaitForChild("Stats"):WaitForChild("Playtime")
				local playTimeLeaderStats = p:WaitForChild("leaderstats"):WaitForChild("Playtime")

				if playerData and playerData.Stats.Playtime then
					playerData.Stats.Playtime += 1
					playtimeInstance.Value = playerData.Stats.Playtime
					playTimeLeaderStats.Value = FormatTimeService:Format(playerData.Stats.Playtime)
				end
			end
			task.wait(1)
		end
	end)
end

return PlaytimeService
