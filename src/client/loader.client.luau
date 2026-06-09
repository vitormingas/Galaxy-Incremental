local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Loader = require(Packages.Loader)
local Client = script.Parent

Loader.SpawnAll(Loader.LoadDescendants(Client), "init")