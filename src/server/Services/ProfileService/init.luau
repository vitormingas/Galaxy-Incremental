-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local ServerPackages = ServerScriptService.ServerPackages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local UpgradesConfig = require(Configs.UpgradesConfig)
local ProfileStore = require(ServerPackages.ProfileStore)
local DataConfig = require(Configs.DataConfig)
local FormatService = require(ReplicatedStorage.Shared.Modules.FormatService)
local FormatTimeService = require(ReplicatedStorage.Shared.Modules.FormatTimeService)

local dataStoreName = "DataStore_1"
local templateData = DataConfig.Template

if RunService:IsStudio() then dataStoreName = "DataStore_Dev" end

local playerStore = ProfileStore.New(dataStoreName, templateData)
local profilesInCache: { [Player]: typeof(playerStore:StartSessionAsync()) } = {}

local ProfileService = {}

ProfileService.DataLoaded = Instance.new("BindableEvent")

--stylua: ignore
function ProfileService:init()
	for _, player in Players:GetPlayers() do
		task.spawn(function() self:LoadData(player) end)
	end
	
	Players.PlayerAdded:Connect(function(player: Player)
		 self:LoadData(player) 
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		 self:SaveData(player) 
	end)
end

-- data things
function ProfileService:LoadData(player: Player)
	local profile = playerStore:StartSessionAsync(`{player.UserId}`, {
		Cancel = function() return player.Parent ~= Players end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			profilesInCache[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			profilesInCache[player] = profile
			self:CreateClientReplica(player, profile.Data)
			self.DataLoaded:Fire(player)
			print(`{player.Name} data loaded.`)
		else
			profile:EndSession()
		end
	else
		player:Kick(`Profile load fail - Please rejoin`)
	end
end

function ProfileService:SaveData(player: Player)
	local profile = profilesInCache[player]
	if profile ~= nil then profile:EndSession() end
end

function ProfileService:GetData(player: Player)
	local profile = profilesInCache[player]
	if not profile then return end
	return profile.Data
end

-- folders
function ProfileService:CreateClientReplica(player, data)
	self:CreateFolders(player, data)
	self:CreateMultipliers(player, data)
	self:CreateUnlocks(player)
	self:CreateCooldowns(player)
	self:CreateLeaderStats(player)
end

function ProfileService:CreateFolders(parent, data)
	for k, v in data do
		local vType = typeof(v)

		if vType == "table" then
			local folder = Instance.new("Folder")
			folder.Name = k
			folder.Parent = parent
			self:CreateFolders(folder, v)
		end

		if vType == "number" then
			local valueInstance = Instance.new("NumberValue")
			valueInstance.Name = k
			valueInstance.Value = v
			valueInstance.Parent = parent
		end

		if vType == "string" then
			local valueInstance = Instance.new("StringValue")
			valueInstance.Name = k
			valueInstance.Value = v
			valueInstance.Parent = parent
		end

		if vType == "boolean" then
			local valueInstance = Instance.new("BoolValue")
			valueInstance.Name = k
			valueInstance.Value = v
			valueInstance.Parent = parent
		end
	end
end

function ProfileService:CreateMultipliers(player, data)
	local multipliersFolder = player:WaitForChild("Stats"):WaitForChild("Multipliers")

	for currencyName, _ in data.Currencies do
		if multipliersFolder:FindFirstChild(`{currencyName}Multiplier`) then continue end

		local multiplier = Instance.new("NumberValue")
		multiplier.Name = `{currencyName}Multiplier`
		multiplier.Value = 1
		multiplier.Parent = multipliersFolder
	end
end

function ProfileService:CreateUnlocks(player)
	local unlocksFolder = player:WaitForChild("Stats"):WaitForChild("Unlocks")

	for _, upgTypes in UpgradesConfig do
		for _, upgData in upgTypes do
			if upgData.Boost.Type ~= "Boolean" then continue end
			if unlocksFolder:FindFirstChild(upgData.Stat) then continue end

			local unlock = Instance.new("BoolValue")
			unlock.Name = upgData.Stat
			unlock.Value = false
			unlock.Parent = unlocksFolder
		end
	end
end

function ProfileService:CreateCooldowns(player)
	local cooldownsFolder = player:WaitForChild("Stats"):WaitForChild("Cooldowns")

	for _, upgTypes in UpgradesConfig do
		for _, upgData in upgTypes do
			if not upgData.Stat:match("Cooldown$") then continue end
			if cooldownsFolder:FindFirstChild(upgData.Stat) then continue end

			local cooldown = Instance.new("NumberValue")
			cooldown.Name = upgData.Stat
			cooldown.Value = 0
			cooldown.Parent = cooldownsFolder
		end
	end
end

function ProfileService:CreateLeaderStats(player)
	local playerData = self:GetData(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local stardust = Instance.new("StringValue")
	stardust.Name = "Stardust"
	stardust.Value = FormatService:Format(playerData.Currencies.Stardust.Amount)
	stardust.Parent = leaderstats

	local playTime = Instance.new("StringValue")
	playTime.Name = "Playtime"
	playTime.Value = FormatTimeService:Format(playerData.Stats.Playtime)
	playTime.Parent = leaderstats

	leaderstats.Parent = player
end

return ProfileService
