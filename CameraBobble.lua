local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Icon = require(ReplicatedStorage.Modules.Icon)
local IconController = require(ReplicatedStorage.Modules.Icon.IconController)

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local Camera = workspace.CurrentCamera
local CameraParts = workspace.Map.Cameras

local cameraBobbleIntensity = 0.1
local originalCameraCFrame = CameraParts.CaseCamera.CFrame
local mouseBobbleConnection

local function mouseBobble()
	local bobbleOffset = Vector3.new(mouse.X / mouse.ViewSizeX, mouse.Y / mouse.ViewSizeY, 0) * cameraBobbleIntensity
	Camera.CFrame = originalCameraCFrame * CFrame.new(bobbleOffset)
end

local function mouseBobbleDisconnect()
	Camera.CameraType = Enum.CameraType.Custom
	if mouseBobbleConnection then
		mouseBobbleConnection:Disconnect()
	end
end

local shop = Icon.new()
	:setImage(11385395241)
	:setLabel("Shop")
	:bindEvent("selected", function()
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CameraParts.CaseCamera.CFrame

		mouseBobbleConnection = UserInputService.InputChanged:Connect(function(input, gameProcessedEvent)
			if input.UserInputType == Enum.UserInputType.MouseMovement and not gameProcessedEvent then
			mouseBobble()
		end
		end)
	end)

	:bindEvent("deselected", function()
		mouseBobbleDisconnect()
	end)

local inventory = Icon.new()
	:setLabel("Inventory")

local setting = Icon.new()
	:setImage(1203479768)
