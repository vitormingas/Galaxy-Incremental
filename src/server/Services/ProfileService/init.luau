-- services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- references
local ServerPackages = ServerScriptService.ServerPackages
local Configs = ReplicatedStorage.Shared.Configs

-- modules
local ProfileStore = require(ServerPackages.ProfileStore)
local DataConfig = require(Configs.DataConfig)

local dataStoreName = "DataStore_1"
local templateData = DataConfig.Template

if RunService:IsStudio() then dataStoreName = "DataStore_Dev" end

local playerStore = ProfileStore.New(dataStoreName, templateData)
local profilesInCache: { [Player]: typeof(playerStore:StartSessionAsync()) } = {}

local ProfileService = {}

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
			ProfileService:CreateFolders(player, profile.Data)
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

return ProfileService
