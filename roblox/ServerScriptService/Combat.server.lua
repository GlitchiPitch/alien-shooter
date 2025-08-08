local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FireWeapon = Remotes:WaitForChild("FireWeapon")
local RenderTracer = Remotes:WaitForChild("RenderTracer")

local lastFireTimestampsByPlayer: {[Player]: number} = {}

local function performRaycast(origin: Vector3, directionUnit: Vector3, range: number, ignore: {Instance})
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	params.IgnoreWater = true
	return workspace:Raycast(origin, directionUnit * range, params)
end

FireWeapon.OnServerEvent:Connect(function(player: Player, mouseWorldPos: Vector3)
	local now = os.clock()
	local last = lastFireTimestampsByPlayer[player] or 0
	local minDelta = 1 / math.max(1, Config.Weapon.fireRatePerSecond)
	if now - last < minDelta then
		return
	end
	lastFireTimestampsByPlayer[player] = now

	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local origin = hrp.Position + Vector3.new(0, 1.5, 0)
	local direction = (mouseWorldPos - origin)
	if direction.Magnitude < 1e-3 then return end
	direction = direction.Unit

	local result = performRaycast(origin, direction, Config.Weapon.maxRange, {character})
	local hitPosition
	if result then
		hitPosition = result.Position
		local hitInstance = result.Instance
		local hitModel = hitInstance and hitInstance:FindFirstAncestorOfClass("Model")
		if hitModel then
			local humanoid = hitModel:FindFirstChildOfClass("Humanoid")
			if humanoid and CollectionService:HasTag(hitModel, "Enemy") then
				-- Attribute used by EnemyModule to award kills on Died
				humanoid:SetAttribute("LastHitBy", player.UserId)
				humanoid:TakeDamage(Config.Weapon.damagePerHit)
			end
		end
	else
		hitPosition = origin + direction * Config.Weapon.maxRange
	end

	RenderTracer:FireAllClients(origin, hitPosition, Config.Weapon.tracerColor, Config.Weapon.tracerLifetime)
end)

Players.PlayerRemoving:Connect(function(player)
	lastFireTimestampsByPlayer[player] = nil
end)