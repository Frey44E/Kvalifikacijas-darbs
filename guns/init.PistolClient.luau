--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// Events
local shootEvent = ReplicatedStorage.Remotes:WaitForChild("ShootEvent")

--// Tool setup
local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = nil

--// Settings
local automatic = false
local fireRate = 2           -- 2 rounds per second = 0.5s between shots
local fireDelay = 1 / fireRate
local maxAmmo = 30
local reloadTime = 3

--// Image IDs
local IMG_BLACK = "rbxassetid://137109417685047"
local IMG_WHITE = "rbxassetid://133385136128865"
local THRESHOLD_END = 0.17

--// States
local holding = false
local lastFire = 0
local ammo = maxAmmo
local reloading = false
local equipped = false

--// GUI refs
local ammoGui, ammoBar, ammoLabel
local reloadBarBG, reloadFill, reloadGunImage
local reloadConn

local function findGui()
	local gui = player.PlayerGui:FindFirstChild("AmmoGui")
	if not gui then return end
	ammoGui        = gui
	ammoBar        = gui:FindFirstChild("AmmoBar", true)
	ammoLabel      = gui:FindFirstChild("AmmoLabel", true)
	reloadBarBG    = gui:FindFirstChild("ReloadBarBG", true)
	reloadFill     = gui:FindFirstChild("ReloadFill", true)
	reloadGunImage = gui:FindFirstChild("ReloadGunImage", true)
end

local function updateAmmoDisplay()
	if ammoLabel then
		ammoLabel.Text = ammo .. "/" .. maxAmmo
	end
end

local function setReloadMode(isReloading)
	if ammoBar     then ammoBar.Visible     = not isReloading end
	if reloadBarBG then reloadBarBG.Visible = isReloading     end
end

local function startReloadAnimation()
	if not reloadFill then return end
	if reloadConn then reloadConn:Disconnect() reloadConn = nil end

	reloadFill.Size = UDim2.new(1, 0, 1, 0)
	if reloadGunImage then reloadGunImage.ImageColor3 = Color3.fromRGB(0, 0, 0) end

	local startTime = tick()

	reloadConn = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local pct = math.clamp(1 - (elapsed / reloadTime), 0, 1)

		reloadFill.Size = UDim2.new(pct, 0, 1, 0)

		if pct <= THRESHOLD_END then
			if reloadGunImage then reloadGunImage.ImageColor3 = Color3.fromRGB(255, 255, 255) end
		else
			if reloadGunImage then reloadGunImage.ImageColor3 = Color3.fromRGB(0, 0, 0) end
		end

		if elapsed >= reloadTime then
			reloadFill.Size = UDim2.new(0, 0, 1, 0)
			if reloadGunImage then reloadGunImage.ImageColor3 = Color3.fromRGB(255, 255, 255) end
			reloadConn:Disconnect()
			reloadConn = nil
		end
	end)
end


local function setupShootPart()
	local shootPart = tool:FindFirstChild("ShootPart")
	if not shootPart then
		shootPart = Instance.new("Part")
		shootPart.Name = "ShootPart"
		shootPart.Size = Vector3.new(0.05, 0.05, 0.05)
		shootPart.Transparency = 1
		shootPart.CanCollide = false
		shootPart.CastShadow = false
		shootPart.Parent = tool
	end
	for _, v in ipairs(shootPart:GetChildren()) do
		if v:IsA("WeldConstraint") then v:Destroy() end
	end
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = shootPart
	weld.Part1 = handle
	weld.Parent = shootPart
	return shootPart
end

local shootPart = setupShootPart()

local function getOrigin()
	return shootPart.Position
end

local function getAimPosition()
	if not mouse then return nil end
	local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { player.Character }
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.IgnoreWater = true
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
	return result and result.Position or (unitRay.Origin + unitRay.Direction * 1000)
end

local function playSound(name)
	local sound = handle:FindFirstChild(name)
	if not sound then return end
	local clone = sound:Clone()
	clone.Parent = handle
	clone:Play()
	game:GetService("Debris"):AddItem(clone, clone.TimeLength + 0.5)
end

local loadedAnimations = {}
local animations = {}

local function loadAnimations(humanoid)
	local animator = humanoid:WaitForChild("Animator")
	for name, id in pairs(animations) do
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		loadedAnimations[name] = animator:LoadAnimation(anim)
	end
end

local function fireSingleShot()
	if reloading or ammo <= 0 then return end
	local now = tick()
	if now - lastFire < fireDelay then return end
	lastFire = now
	local origin = getOrigin()
	local target = getAimPosition()
	if not origin or not target then return end
	if (target - origin).Magnitude < 0.01 then return end
	local ok, err = pcall(function()
		shootEvent:FireServer(tool, origin, target)
	end)
	if not ok then warn("ShootEvent error:", err) end
	ammo -= 1
	updateAmmoDisplay()
	if loadedAnimations.shoot then loadedAnimations.shoot:Play() end
end

local function autoFireLoop()
	while holding and equipped and not reloading and ammo > 0 do
		fireSingleShot()
		RunService.Heartbeat:Wait()
	end
end

local function startReload()
	if reloading or ammo >= maxAmmo then return end
	reloading = true
	playSound("Reload")
	setReloadMode(true)
	startReloadAnimation()
	if loadedAnimations.reload then loadedAnimations.reload:Play() end
	task.wait(reloadTime)
	ammo = maxAmmo
	reloading = false
	setReloadMode(false)
	updateAmmoDisplay()
end

local function onActivated()
	if ammo <= 0 then startReload() return end
	if automatic then
		holding = true
		task.spawn(autoFireLoop)
	else
		fireSingleShot()
	end
end

local function onDeactivated()
	holding = false
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.R then startReload() end
end)

local activatedConn, deactivatedConn

tool.Equipped:Connect(function()
	equipped = true
	mouse = player:GetMouse()
	playSound("Equip")
	task.wait(0.1)
	findGui()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	if not next(loadedAnimations) then loadAnimations(humanoid) end
	if loadedAnimations.idle then loadedAnimations.idle:Play() end
	updateAmmoDisplay()
	if reloadBarBG then reloadBarBG.Visible = false end
	if ammoBar then ammoBar.Visible = true end
	if ammoGui then ammoGui.Enabled = true end
	activatedConn = tool.Activated:Connect(onActivated)
	deactivatedConn = tool.Deactivated:Connect(onDeactivated)
end)

tool.Unequipped:Connect(function()
	equipped = false
	holding = false
	mouse = nil
	if reloadConn then reloadConn:Disconnect() reloadConn = nil end
	if ammoGui then ammoGui.Enabled = false end
	if loadedAnimations.idle then loadedAnimations.idle:Stop() end
	if activatedConn then activatedConn:Disconnect() end
	if deactivatedConn then deactivatedConn:Disconnect() end
end)