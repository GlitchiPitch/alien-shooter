local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Scriptable

local CAMERA_HEIGHT = 55

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local rootPos = hrp.Position
	local camPos = rootPos + Vector3.new(0, CAMERA_HEIGHT, 0)
	camera.CFrame = CFrame.new(camPos, rootPos)
end)