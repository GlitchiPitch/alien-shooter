local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local EnemyModule = {}

local function getNearestPlayerPosition(fromPosition: Vector3)
	local nearestDist = math.huge
	local nearestHRP : BasePart? = nil
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if hrp and humanoid and humanoid.Health > 0 then
				local dist = (hrp.Position - fromPosition).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestHRP = hrp
				end
			end
		end
	end
	return nearestHRP, nearestDist
end

local function buildProceduralAlien(): Model
	local model = Instance.new("Model")
	model.Name = "Alien"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2, 2.2, 2.2)
	root.Color = Color3.fromRGB(70, 255, 110)
	root.Material = Enum.Material.SmoothPlastic
	root.CanCollide = true
	root.Anchored = false
	root.TopSurface = Enum.SurfaceType.Smooth
	root.BottomSurface = Enum.SurfaceType.Smooth
	root.Parent = model

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2.2, 2.2, 2.2)
	body.Color = Color3.fromRGB(60, 200, 90)
	body.Material = Enum.Material.SmoothPlastic
	body.CanCollide = true
	body.Anchored = false
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = body
	weld.Parent = root
	body.CFrame = root.CFrame

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.WalkSpeed = Config.Enemy.moveSpeed
	humanoid.AutoRotate = true
	humanoid.Parent = model

	model.PrimaryPart = root
	return model
end

local function getAlienTemplateFromServerStorage(): Model?
	local template = ServerStorage:FindFirstChild("Alien")
	if template and template:IsA("Model") then
		return template
	end
	return nil
end

local function createAlienModel(): Model
	local template = getAlienTemplateFromServerStorage()
	if template then
		return template:Clone()
	end
	return buildProceduralAlien()
end

local function setEnemyStats(model: Model, waveIndex: number)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local maxHealth = Config.Enemy.baseHealth + (math.max(0, waveIndex - 1) * Config.Enemy.healthGrowthPerWave)
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	humanoid.WalkSpeed = Config.Enemy.moveSpeed
end

local function tryDespawnFar(model: Model)
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local nearestHRP, dist = getNearestPlayerPosition(root.Position)
	if not nearestHRP then return false end
	if dist > Config.Enemy.despawnDistance then
		model:Destroy()
		return true
	end
	return false
end

function EnemyModule.spawnEnemy(spawnPosition: Vector3, waveIndex: number): Model
	local model = createAlienModel()
	model:SetAttribute("WaveIndex", waveIndex)
	model:PivotTo(CFrame.new(spawnPosition + Vector3.new(0, 4, 0)))
	setEnemyStats(model, waveIndex)
	CollectionService:AddTag(model, "Enemy")
	model.Parent = workspace
	return model
end

function EnemyModule.startEnemyBrain(model: Model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	task.spawn(function()
		local lastAttackTime = 0
		while model.Parent == workspace do
			if humanoid.Health <= 0 then break end
			if tryDespawnFar(model) then break end

			local targetHRP = getNearestPlayerPosition(root.Position)
			if targetHRP then
				local targetPos = targetHRP.Position
				humanoid:MoveTo(targetPos)
				-- Attack if close enough
				local distance = (targetPos - root.Position).Magnitude
				if distance < 3.6 then
					local now = os.clock()
					if now - lastAttackTime >= Config.Enemy.attackCooldown then
						lastAttackTime = now
						local targetModel = targetHRP.Parent
						if targetModel then
							local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")
							if targetHumanoid and targetHumanoid.Health > 0 then
								targetHumanoid:TakeDamage(Config.Enemy.damage)
							end
						end
					end
				end
			end
			wait(0.1)
		end
	end)
end

return EnemyModule