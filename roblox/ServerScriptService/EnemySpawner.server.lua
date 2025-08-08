local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local EnemyModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EnemyModule"))

local currentWave = 0
local aliveEnemies = 0
ReplicatedStorage:SetAttribute("AliveEnemies", aliveEnemies)

local function setAlive(delta: number)
	aliveEnemies += delta
	if aliveEnemies < 0 then aliveEnemies = 0 end
	ReplicatedStorage:SetAttribute("AliveEnemies", aliveEnemies)
end

local function getRandomSpawnPositionNearAnyPlayer(): Vector3?
	local players = Players:GetPlayers()
	if #players == 0 then return nil end
	local anchorPlayer = players[math.random(1, #players)]
	local char = anchorPlayer.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local angle = math.random() * math.pi * 2
	local radius = math.random(Config.Spawn.minSpawnRadius, Config.Spawn.maxSpawnRadius)
	local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
	local basePos = hrp.Position + offset
	return Vector3.new(basePos.X, basePos.Y + 3, basePos.Z)
end

local function getWaveEnemyCount(waveIndex: number): number
	local base = Config.Spawn.enemiesPerWaveBase
	local growth = Config.Spawn.enemiesPerWaveGrowth
	return math.floor(base * (growth ^ (waveIndex - 1)))
end

local function beginNextWave()
	currentWave += 1
	ReplicatedStorage:SetAttribute("CurrentWave", currentWave)

	local toSpawn = getWaveEnemyCount(currentWave)
	while toSpawn > 0 do
		if aliveEnemies >= Config.Spawn.maxSimultaneousEnemies then
			wait(0.25)
		else
			local pos = getRandomSpawnPositionNearAnyPlayer()
			if pos then
				local enemy = EnemyModule.spawnEnemy(pos, currentWave)
				EnemyModule.startEnemyBrain(enemy)
				setAlive(1)
				local humanoid = enemy:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Died:Connect(function()
						setAlive(-1)
						-- Award kill/score if we know the last hitter
						local userId = humanoid:GetAttribute("LastHitBy")
						if userId then
							for _, plr in ipairs(Players:GetPlayers()) do
								if plr.UserId == userId then
									local stats = plr:FindFirstChild("leaderstats")
									if stats then
										local kills = stats:FindFirstChild("Kills")
										local score = stats:FindFirstChild("Score")
										if kills then kills.Value += 1 end
										if score then score.Value += 10 end
									end
								end
							end
						end
					end)
				end
				toSpawn -= 1
			end
			wait(0.15)
		end
	end
end

while task.wait(1) do
	if #Players:GetPlayers() == 0 then
		-- wait for players
	else
		if aliveEnemies == 0 then
			wait(Config.Spawn.timeBetweenWaves)
			if aliveEnemies == 0 then
				beginNextWave()
			end
		end
	end
end