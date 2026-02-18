local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local ClientReplicator = ReplicatedStorage.Remotes:WaitForChild("ClientReplicator")
local bulletTrailTemplate = ReplicatedStorage.BulletAssets:WaitForChild("BulletTrail")
local bulletTemplate = ReplicatedStorage.BulletAssets:WaitForChild("Bullet")

local player = Players.LocalPlayer

local BULLET_SPEED      = 30
local STRAIGHT_DISTANCE = 9999
local GRAVITY_PER_STUD  = 0.01
local MAX_GRAVITY       = 60

local HOMING_STRENGTH   = 8
local HOMING_MAX_ANGLE  = 30
local HOMING_LOCK_DIST  = 60

local function doRaycast(origin, direction, extraExclusions)
	local params = RaycastParams.new()
	local char = player.Character
	local exclusions = char and { char } or {}
	if extraExclusions then
		for _, v in ipairs(extraExclusions) do
			table.insert(exclusions, v)
		end
	end
	params.FilterDescendantsInstances = exclusions
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	return workspace:Raycast(origin, direction, params)
end

local function findHomingTarget(origin, unitDir)
	local params = RaycastParams.new()
	local char = player.Character
	params.FilterDescendantsInstances = char and { char } or {}
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, unitDir * HOMING_LOCK_DIST, params)
	if not result then return nil end

	local hitPart = result.Instance
	local model = hitPart and hitPart:FindFirstAncestorOfClass("Model")
	if not model then return nil end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end

	return hitPart
end

local function spawnProjectile(origin, unitDir, speed, range)
	if not origin or not unitDir or not speed or not range then return end

	local bullet = bulletTemplate:Clone()
	bullet.CFrame = CFrame.new(origin, origin + unitDir)
	bullet.Parent = workspace

	local position = origin
	local velocity = unitDir * speed
	local traveled = 0
	local gravityAccum = 0

	local homingTarget = findHomingTarget(origin, unitDir)
	local isHoming = homingTarget ~= nil
	local lostTarget = false

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if not bullet or not bullet.Parent then
			conn:Disconnect()
			return
		end

		if traveled > STRAIGHT_DISTANCE then
			local extraStuds = traveled - STRAIGHT_DISTANCE
			local gravityStrength = math.min(extraStuds * GRAVITY_PER_STUD * MAX_GRAVITY, MAX_GRAVITY)
			gravityAccum = gravityStrength
		end
		velocity = velocity + Vector3.new(0, -gravityAccum, 0) * dt

		if isHoming and not lostTarget then
			if homingTarget and homingTarget.Parent then
				local targetPos = homingTarget.Position
				local toTarget = (targetPos - position)
				local distToTarget = toTarget.Magnitude

				if distToTarget > 0.1 then
					local toTargetUnit = toTarget.Unit
					local currentDir = velocity.Unit

					local dot = currentDir:Dot(toTargetUnit)
					local angleDeg = math.deg(math.acos(math.clamp(dot, -1, 1)))

					if angleDeg <= HOMING_MAX_ANGLE then
						local newDir = currentDir:Lerp(toTargetUnit, HOMING_STRENGTH * dt)
						if newDir.Magnitude > 0 then
							velocity = newDir.Unit * speed
						end
					else
						lostTarget = true
					end
				end
			else
				lostTarget = true
			end
		end

		local step = velocity * dt
		local nextPos = position + step

		local result = doRaycast(position, nextPos - position)
		if result then
			bullet:Destroy()
			conn:Disconnect()
			return
		end

		local moveDir = velocity.Magnitude > 0 and velocity.Unit or unitDir
		bullet.CFrame = CFrame.new(nextPos, nextPos + moveDir)
		position = nextPos
		traveled += step.Magnitude

		if traveled >= range or position.Y < workspace.FallenPartsDestroyHeight then
			bullet:Destroy()
			conn:Disconnect()
		end
	end)
end

ClientReplicator.OnClientEvent:Connect(function(args)
	if not args or not args.effect then return end

	if args.effect == "BulletTrail" then
		local origin = args.origin
		local hitPos = args.hitPos
		if not origin or not hitPos then return end
		local dir = hitPos - origin
		local distance = dir.Magnitude
		if distance < 0.01 then return end
		spawnProjectile(origin, dir.Unit, BULLET_SPEED, distance + 10)

	elseif args.effect == "BulletShot" then
		spawnProjectile(
			args.origin,
			args.direction,
			BULLET_SPEED,
			args.range
		)
	end
end)