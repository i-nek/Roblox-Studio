local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") 

local camera = workspace.CurrentCamera

local Animations = ReplicatedStorage.Animations.Picture
local Events = ReplicatedStorage.Events.Picture

local PictureHoldAnim
local PlacePictureConnection
local PlacementConnection

local paperPreview
local previewPosition
local previewData

local canPlace

local PictureClientModule = {}

function CreatePreview(mouse, tool)
	for _, v in pairs(workspace.Temp:GetChildren()) do
		v:Destroy()
	end

	if tool:IsA("Tool") then
		for _, part in pairs(tool:GetChildren()) do
			if part.Name == "Paper" then
				paperPreview = ReplicatedStorage.Tools.Paper:Clone()
				paperPreview.Parent = workspace.Temp
				paperPreview.Transparency = 0.8

				PlacePictureConnection = UserInputService.InputBegan:Connect(function(input, processed)
					if not processed and input.KeyCode == Enum.KeyCode.F then
						part.Transparency = 1
						HandlePaperPlacement(paperPreview, mouse, tool)
					end
				end)
			end
		end
	end
end

function HandlePaperPlacement(preview, mouse, tool)
	if preview then
		if PlacementConnection then
			PlacementConnection:Disconnect()
		end
		PlacementConnection = RunService.RenderStepped:Connect(function()
			UpdatePreviewPosition(preview, mouse)
		end)
		PlacePictureConnection = UserInputService.InputBegan:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and canPlace then
				PlacePreview(preview, tool)
			end
		end)
	end
end

function UpdatePreviewPosition(preview, mouse)
	local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local rayStart = camera.CFrame.Position
	local rayDirection = (mouse.Hit.p - rayStart).unit

	local raycastParams = RaycastParams.new()

	local raycastResult = game.Workspace:Raycast(rayStart, rayDirection * 100, raycastParams)
	if raycastResult then
		local hitPart = raycastResult.Instance
		local hitPosition = raycastResult.Position
		local hitNormal = raycastResult.Normal

		local lookVector = -rayDirection
		local upVector = hitNormal
		local rightVector = upVector:Cross(Vector3.new(0, 1, 0))

		local rotationMatrix = CFrame.fromMatrix(Vector3.new(), rightVector, upVector)
		if upVector == Vector3.new(0, 1, 0) then
			preview.CFrame = CFrame.new(mouse.Hit.Position)
		else
			preview.CFrame = CFrame.new(hitPosition) * rotationMatrix * CFrame.Angles(0, math.rad(90), 0)
		end
		previewPosition = preview.CFrame
		if CollectionService:HasTag(hitPart, "Placeable") then
			canPlace = true
			preview.Color = Color3.fromRGB(0, 170, 0)
		else
			preview.Color = Color3.fromRGB(255, 0, 0)
			canPlace = false
		end
	end
end

function PlacePreview(preview, tool)
	Events.PlacePicture:FireServer(previewPosition, previewData)
	tool:Destroy()
	PictureHoldAnim:Stop()
end

function PictureClientModule.Equip(player, mouse, tool)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild('Humanoid')
	
	tool.Paper.Transparency = 0
	PictureHoldAnim = humanoid:LoadAnimation(Animations.PictureHold)
	tool.Paper.SurfaceGui.Enabled = true
	PictureHoldAnim:Play()

	previewData = character.Picture.Paper.SurfaceGui
	CreatePreview(mouse, tool)
end

function PictureClientModule.Unequip()
	PictureHoldAnim:Stop()
	if PlacePictureConnection then
		PlacePictureConnection:Disconnect()
	end
	if PlacementConnection then
		PlacementConnection:Disconnect()
	end
	if paperPreview then
		paperPreview:Destroy()
	end
end

return PictureClientModule
