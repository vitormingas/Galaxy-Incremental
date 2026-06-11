-- services
local Players = game:GetService("Players")

-- references

-- modules

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UiAnimController = {}

--stylua: ignore
function UiAnimController:init()

	for _, ui in playerGui:GetDescendants() do
        self:LinkButtonSound(ui)
	end

    playerGui.DescendantAdded:Connect(function(ui)
        self:LinkButtonSound(ui)
    end)
	
end

function UiAnimController:LinkButtonSound(ui)
    if typeof(ui) ~= "TextButton" or typeof(ui) ~= "ImageButton" then return end 
    ui.MouseButton1Click:Connect(function()
        
    end)
end

return UiAnimController
