local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Optional custom cursor (use any you like)
-- player:GetMouse().Icon = "rbxassetid://0" -- set your asset id here

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not humanoid then return end
	local mouse = player:GetMouse()
	if mouse and mouse.Hit then
		local target = mouse.Hit.p
		local facePos = Vector3.new(target.X, humanoidRootPart.Position.Y, target.Z)
		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, facePos)
	end
end)