local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createLabel(name: string, position: UDim2)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = Vector2.new(0, 0)
	label.Position = position
	label.Size = UDim2.new(0, 250, 0, 24)
	label.BackgroundTransparency = 0.35
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = screenGui
	return label
end

local waveLabel = createLabel("WaveLabel", UDim2.new(0, 12, 0, 12))
local aliveLabel = createLabel("AliveLabel", UDim2.new(0, 12, 0, 40))
local killsLabel = createLabel("KillsLabel", UDim2.new(0, 12, 0, 68))
local scoreLabel = createLabel("ScoreLabel", UDim2.new(0, 12, 0, 96))

local function updateWave()
	local wave = ReplicatedStorage:GetAttribute("CurrentWave") or 0
	waveLabel.Text = "Wave: " .. tostring(wave)
end

local function updateAlive()
	local alive = ReplicatedStorage:GetAttribute("AliveEnemies") or 0
	aliveLabel.Text = "Aliens Alive: " .. tostring(alive)
end

local function updateStats()
	local stats = player:FindFirstChild("leaderstats")
	local kills = stats and stats:FindFirstChild("Kills")
	local score = stats and stats:FindFirstChild("Score")
	killsLabel.Text = "Kills: " .. tostring(kills and kills.Value or 0)
	scoreLabel.Text = "Score: " .. tostring(score and score.Value or 0)
end

ReplicatedStorage:GetAttributeChangedSignal("CurrentWave"):Connect(updateWave)
ReplicatedStorage:GetAttributeChangedSignal("AliveEnemies"):Connect(updateAlive)

player.CharacterAdded:Connect(function()
	updateStats()
end)

local function connectLeaderstats()
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end
	local kills = stats:FindFirstChild("Kills")
	local score = stats:FindFirstChild("Score")
	if kills then kills:GetPropertyChangedSignal("Value"):Connect(updateStats) end
	if score then score:GetPropertyChangedSignal("Value"):Connect(updateStats) end
end

player.ChildAdded:Connect(function(child)
	if child.Name == "leaderstats" then
		connectLeaderstats()
		updateStats()
	end
end)

-- Initialize
updateWave()
updateAlive()
connectLeaderstats()
updateStats()