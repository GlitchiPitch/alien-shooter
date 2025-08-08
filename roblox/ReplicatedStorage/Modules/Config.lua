local Config = {}

Config.Weapon = {
	fireRatePerSecond = 6,
	maxRange = 220,
	damagePerHit = 25,
	tracerColor = Color3.fromRGB(255, 245, 160),
	tracerLifetime = 0.08,
}

Config.Enemy = {
	baseHealth = 100,
	healthGrowthPerWave = 15,
	moveSpeed = 12,
	damage = 12,
	attackCooldown = 1.0,
	despawnDistance = 800,
}

Config.Spawn = {
	enemiesPerWaveBase = 10,
	enemiesPerWaveGrowth = 1.30,
	minSpawnRadius = 70,
	maxSpawnRadius = 160,
	maxSimultaneousEnemies = 85,
	timeBetweenWaves = 6,
}

return Config