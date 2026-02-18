local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local GunTemplates = require(ServerStorage.GunTemplates)

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name)
	local remote = Remotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = Remotes
		warn("Created missing RemoteEvent: " .. name)
	end
	return remote
end

local shootEvent = getOrCreateRemote("ShootEvent")
local clientReplicator = getOrCreateRemote("ClientReplicator")

local FIRE_RATE_LIMIT_MS = 50

local playerState = {}

local function getState(player)
	if not playerState[player] then
		playerState[player] = { lastShot = 0 }
	end
	return playerState[player]
end

local function playSound(soundName, gun)
	local handle = gun:FindFirstChild("Handle")
	if not handle then return end

	local soundTemplate = handle:FindFirstChild(soundName)
	if not soundTemplate then return end

	local sound = soundTemplate:Clone()
	sound.Parent = handle
	sound:Play()
	Debris:AddItem(sound, sound.TimeLength + 0.5)
end

local function doRaycast(player, origin, direction)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { player.Character }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, params)
	local hitPos = result and result.Position or (origin + direction)

	return hitPos, result
end

local function applyDamage(player, gunStats, rayResult)
	if not rayResult then return end

	local hitPart = rayResult.Instance
	if not hitPart then return end

	local model = hitPart:FindFirstAncestorOfClass("Model")
	if not model then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if model == player.Character then return end

	local damage = gunStats.damage
	if hitPart.Name == "Head" then
		damage = damage * gunStats.headshotMultiplier
	end

	humanoid:TakeDamage(damage)
end

shootEvent.OnServerEvent:Connect(function(player, gun, origin, targetPos)
	if not player or not gun or not origin or not targetPos then return end
	if not gun:IsA("Tool") then return end

	local state = getState(player)
	local now = tick() * 1000
	if now - state.lastShot < FIRE_RATE_LIMIT_MS then return end
	state.lastShot = now

	local gunStats = GunTemplates[gun.Name]
	if not gunStats then
		warn("No GunTemplate found for: " .. tostring(gun.Name))
		return
	end

	playSound("Pistol Fire", gun)

	local direction = targetPos - origin
	local distance = direction.Magnitude
	if distance < 0.01 then return end
	local unitDir = direction.Unit

	if not gunStats.bulletSpeed then
		local rayDir = unitDir * math.min(distance, gunStats.range)
		local hitPos, rayResult = doRaycast(player, origin, rayDir)
		applyDamage(player, gunStats, rayResult)

		clientReplicator:FireAllClients({
			effect = "BulletTrail",
			origin = origin,
			hitPos = hitPos
		})
		return
	end

	local bulletSpeed = gunStats.bulletSpeed
	local stepTime = 0.05
	local stepDist = bulletSpeed * stepTime
	local traveled = 0
	local pos = origin

	clientReplicator:FireAllClients({
		effect = "BulletShot",
		origin = origin,
		direction = unitDir,
		bulletSpeed = bulletSpeed,
		range = gunStats.range
	})

	while traveled < gunStats.range do
		local nextDir = unitDir * stepDist
		local hitPos, rayResult = doRaycast(player, pos, nextDir)

		if rayResult then
			applyDamage(player, gunStats, rayResult)
			break
		end

		pos = pos + nextDir
		traveled += stepDist
		task.wait(stepTime)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerState[player] = nil
end)