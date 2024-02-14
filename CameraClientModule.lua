local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Animations = ReplicatedStorage.Animations.Camera
local Events = ReplicatedStorage.Events
local Sounds = ReplicatedStorage.Sounds
local Tools = ReplicatedStorage.Tools

local currentCamera = workspace.CurrentCamera

local ZOOM_Speed = 5
local DEFAULT_FOV = 70
local MIN_FOV = 90
local MAX_FOV = 10

local zoomConnection
local InCameraAnimConnection

local CameraIdleAnim

local CameraClientModule = {}

 	function GetPartPath(part)
		local path = {}
		local current = part

		while current.Parent do
			table.insert(path, current.Name)
			current = current.Parent
		end

		local reversedPath = {}

		for i = #path, 1, -1 do
			table.insert(reversedPath, path[i])
		end

		return reversedPath
	end

	function zoom(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local delta = input.Position.Z
			local currentFOV = currentCamera.FieldOfView
			local newFOV = currentFOV - delta * ZOOM_Speed
			newFOV = math.clamp(newFOV, MAX_FOV, MIN_FOV)
			currentCamera.FieldOfView = newFOV
		end
	end

	function CameraClientModule.EquipCamera(player, cameraTool)
		local Character = player.Character or player.CharacterAdded:Wait()
		local Humanoid = Character:FindFirstChild('Humanoid')

		CameraIdleAnim = Humanoid:LoadAnimation(Animations.CameraIdle)

		player.CameraMode = Enum.CameraMode.LockFirstPerson
		zoomConnection = UserInputService.InputChanged:Connect(zoom)
		player.PlayerGui.UiHandler.CameraOverlay.ImageTransparency = 0
		UserInputService.MouseIconEnabled = false

		for _, v in pairs(cameraTool:GetChildren()) do
			if v:IsA("UnionOperation") then
				v.Transparency = 1
			end
		end
		CameraIdleAnim:Play()
	end

	function CameraClientModule.UnequipCamera(player, cameraTool)
		player.CameraMode = Enum.CameraMode.Classic
		currentCamera.FieldOfView = DEFAULT_FOV
		player.PlayerGui.UiHandler.CameraOverlay.ImageTransparency = 1
		UserInputService.MouseIconEnabled = true

		for _, v in pairs(cameraTool:GetChildren()) do
			if v:IsA("Part") or v:IsA("UnionOperation") then
				v.Transparency = 0
			end
		end
		CameraIdleAnim:Stop()
		zoomConnection:Disconnect()
	end

	function CameraClientModule.capturePhoto(player)
		Sounds.CaptureImage:Play()
		local regionSize = Vector3.new(75, 75, 75)
		local regionPosition = player.Character:WaitForChild("Head").Position + player.Character:WaitForChild("Head").CFrame.LookVector

		local Region = Region3.new(regionPosition - (regionSize / 2), regionPosition + (regionSize / 2))

		local partsInRegion = workspace:FindPartsInRegion3(Region, nil, 1000)

		local capturedParts = {}
		for _, v in pairs(partsInRegion) do
			local isBodyPart = v:IsDescendantOf(player.Character)
			local isAccessory = v:IsA("Accessory") or v:IsA("Hat")

			if not isBodyPart and not isAccessory then
				table.insert(capturedParts, {
					Path = GetPartPath(v),
				})
			end
		end
		local cameraInfo = {
			CameraPosition = currentCamera.CFrame.Position,
			CameraLookVector = currentCamera.CFrame.LookVector,
			CameraOrientation = currentCamera.CFrame:PointToObjectSpace(Vector3.new(0, 0, 1)),
		}
		Events.Camera.CapturePhoto:FireServer(cameraInfo, capturedParts)
	end
	
return CameraClientModule
