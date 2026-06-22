local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Loader = require(Packages.Loader)
local Server = script.Parent

Loader.SpawnAll(Loader.LoadDescendants(Server), "init")
