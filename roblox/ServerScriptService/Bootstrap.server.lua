local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreate(parent: Instance, className: string, name: string)
	local inst = parent:FindFirstChild(name)
	if inst and inst.ClassName == className then
		return inst
	end
	inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local remotesFolder = getOrCreate(ReplicatedStorage, "Folder", "Remotes")
getOrCreate(remotesFolder, "RemoteEvent", "FireWeapon")
getOrCreate(remotesFolder, "RemoteEvent", "RenderTracer")

-- Shared game state attributes for lightweight UI hooks
if ReplicatedStorage:GetAttribute("CurrentWave") == nil then
	ReplicatedStorage:SetAttribute("CurrentWave", 0)
end
if ReplicatedStorage:GetAttribute("AliveEnemies") == nil then
	ReplicatedStorage:SetAttribute("AliveEnemies", 0)
end