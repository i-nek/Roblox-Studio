local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

local Tools = ReplicatedStorage.Tools 

local CameraModule = {}

local function GetInstance(String)
	local Table = string.split(String, ".")
	local Service = game

	local ObjectSoFar = Service
	for _, v in pairs(Table) do
		local Object = ObjectSoFar:FindFirstChild(v)
		if Object then
			ObjectSoFar = Object
		end
	end
	return ObjectSoFar
end

function CameraModule.CapturePhoto(player, cameraInfo, capturedParts)
	local newPicture = Tools.Picture:Clone()
	newPicture.Parent = player.Backpack
	newPicture.Paper.SurfaceGui.TextLabel.Text = "- " .. player.DisplayName

	local newCamera = Instance.new("Camera", newPicture.Paper)
	newCamera.CFrame = CFrame.new(cameraInfo.CameraPosition, cameraInfo.CameraLookVector)
	newPicture.Paper.SurfaceGui.Picture.CurrentCamera = newCamera

	for _, capturedPart in pairs(capturedParts) do
		local path = capturedPart.Path
		local concatPath = table.concat(path, ".")
		local currentParent = newPicture.Paper.SurfaceGui.Picture
		local originalPart = GetInstance(concatPath)

		if originalPart then
			local clonedPart = originalPart:Clone()
			clonedPart.Parent = currentParent
		else
			warn("Original part not found for path:", concatPath)
		end
	end
	for _, v in pairs(Players:GetPlayers()) do
		local newSurfaceGui = newPicture.Paper.SurfaceGui:Clone()
		newSurfaceGui.Parent = player.PlayerGui
	end
end

return CameraModule
