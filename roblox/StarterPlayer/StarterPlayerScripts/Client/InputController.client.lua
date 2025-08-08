local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FireWeapon = Remotes:WaitForChild("FireWeapon")
local RenderTracer = Remotes:WaitForChild("RenderTracer")

-- Movement state
local moveState = {
	up = false,
	down = false,
	left = false,
	right = false,
}

local function getCharacter()
	return player.Character
end

local function getHumanoid()
	local char = getCharacter()
	return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function getHRP()
	local char = getCharacter()
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

-- Movement input
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then moveState.up = true end
	if input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then moveState.down = true end
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then moveState.left = true end
	if input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then moveState.right = true end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.Up then moveState.up = false end
	if input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.Down then moveState.down = false end
	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then moveState.left = false end
	if input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then moveState.right = false end
end)

RunService.RenderStepped:Connect(function()
	local humanoid = getHumanoid()
	if not humanoid then return end
	local x = (moveState.right and 1 or 0) - (moveState.left and 1 or 0)
	local z = (moveState.down and 1 or 0) - (moveState.up and 1 or 0)
	local move = Vector3.new(x, 0, z)
	if move.Magnitude > 0 then
		move = move.Unit
	end
	humanoid:Move(move, false)
end)

-- Firing
local firing = false
local lastFire = 0
local minDelta = 1 / math.max(1, Config.Weapon.fireRatePerSecond)

local function getMouseWorldPositionOnPlane()
	local hrp = getHRP()
	if not hrp then return nil end
	local mouse = player:GetMouse()
	local hit = mouse.Hit
	if hit then
		local p = hit.p
		-- Project to the character's horizontal plane for consistent aim
		return Vector3.new(p.X, hrp.Position.Y, p.Z)
	end
	return nil
end

local function requestFire()
	local now = os.clock()
	if now - lastFire < minDelta then return end
	lastFire = now
	local p = getMouseWorldPositionOnPlane()
	if p then
		FireWeapon:FireServer(p)
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		firing = true
		requestFire()
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		firing = false
	end
end)

RunService.RenderStepped:Connect(function()
	if firing then
		requestFire()
	end
end)

-- Tracer visuals
local function drawTracer(origin: Vector3, destination: Vector3, color: Color3, lifetime: number)
	local dir = destination - origin
	local length = dir.Magnitude
	if length < 0.1 then return end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(0.15, 0.15, length)
	part.CFrame = CFrame.new(origin, destination) * CFrame.new(0, 0, -length / 2)
	part.Parent = workspace
	Debris:AddItem(part, lifetime)
end

RenderTracer.OnClientEvent:Connect(function(origin: Vector3, destination: Vector3, color: Color3, lifetime: number)
	drawTracer(origin, destination, color or Color3.new(1,1,0.6), lifetime or 0.08)
end)