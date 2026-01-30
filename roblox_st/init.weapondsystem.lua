local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- gaidu, kamēr StartupMenu pazūd (play nospiests)
local startupMenu = playerGui:WaitForChild("StartupMenu")
startupMenu.AncestryChanged:Wait() -- gaidu iznīkšanu

-- gaidu characteru
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- izveidoju ScreenGui priekš mana HUD
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "GameHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = playerGui

-- galvenais HUD rāmis (apakšējais labais)
local hudContainer = Instance.new("Frame")
hudContainer.Name = "HUDContainer"
hudContainer.Size = UDim2.new(0, 300, 0, 150) -- Increased height for weapons
hudContainer.Position = UDim2.new(1, -320, 1, -170)
hudContainer.BackgroundTransparency = 1
hudContainer.Parent = hudGui

-- ==================== WEAPON DISPLAY ====================
local weaponContainer = Instance.new("Frame")
weaponContainer.Name = "WeaponContainer"
weaponContainer.Size = UDim2.new(1, 0, 0, 90)
weaponContainer.Position = UDim2.new(0, 0, 0, 0)
weaponContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
weaponContainer.BackgroundTransparency = 0.3
weaponContainer.BorderSizePixel = 0
weaponContainer.Parent = hudContainer

local weaponCorner = Instance.new("UICorner")
weaponCorner.CornerRadius = UDim.new(0, 8)
weaponCorner.Parent = weaponContainer

local weaponStroke = Instance.new("UIStroke")
weaponStroke.Color = Color3.fromRGB(150, 150, 200)
weaponStroke.Thickness = 2
weaponStroke.Transparency = 0.5
weaponStroke.Parent = weaponContainer

-- ierocis: ikona (viettura)
local weaponIcon = Instance.new("ImageLabel")
weaponIcon.Name = "WeaponIcon"
weaponIcon.Size = UDim2.new(0, 70, 0, 70)
weaponIcon.Position = UDim2.new(0, 10, 0.5, -35)
weaponIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
weaponIcon.BorderSizePixel = 0
weaponIcon.Image = "" -- Add weapon image IDs here later
weaponIcon.ScaleType = Enum.ScaleType.Fit
weaponIcon.Parent = weaponContainer

local weaponIconCorner = Instance.new("UICorner")
weaponIconCorner.CornerRadius = UDim.new(0, 6)
weaponIconCorner.Parent = weaponIcon

-- Viettura ikona (ja nav attēls)
local placeholderLabel = Instance.new("TextLabel")
placeholderLabel.Size = UDim2.new(1, 0, 1, 0)
placeholderLabel.BackgroundTransparency = 1
placeholderLabel.Text = "🔫"
placeholderLabel.Font = Enum.Font.GothamBold
placeholderLabel.TextSize = 40
placeholderLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
placeholderLabel.Parent = weaponIcon

-- Ierocis: nosaukums
local weaponName = Instance.new("TextLabel")
weaponName.Name = "WeaponName"
weaponName.Size = UDim2.new(1, -100, 0, 30)
weaponName.Position = UDim2.new(0, 90, 0, 10)
weaponName.BackgroundTransparency = 1
weaponName.Text = "AK-47"
weaponName.Font = Enum.Font.GothamBold
weaponName.TextSize = 22
weaponName.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponName.TextXAlignment = Enum.TextXAlignment.Left
weaponName.Parent = weaponContainer

-- Munīcijas rādītājs
local ammoLabel = Instance.new("TextLabel")
ammoLabel.Name = "AmmoLabel"
ammoLabel.Size = UDim2.new(1, -100, 0, 40)
ammoLabel.Position = UDim2.new(0, 90, 1, -45)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Text = "30 / 120"
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.TextSize = 28
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
ammoLabel.TextXAlignment = Enum.TextXAlignment.Left
ammoLabel.Parent = weaponContainer

-- sekundārā ikona (mazāka)
local secondaryWeapon = Instance.new("Frame")
secondaryWeapon.Name = "SecondaryWeapon"
secondaryWeapon.Size = UDim2.new(0, 50, 0, 50)
secondaryWeapon.Position = UDim2.new(1, -60, 0.5, -25)
secondaryWeapon.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
secondaryWeapon.BorderSizePixel = 0
secondaryWeapon.Parent = weaponContainer

local secondaryCorner = Instance.new("UICorner")
secondaryCorner.CornerRadius = UDim.new(0, 6)
secondaryCorner.Parent = secondaryWeapon

local secondaryStroke = Instance.new("UIStroke")
secondaryStroke.Color = Color3.fromRGB(100, 100, 120)
secondaryStroke.Thickness = 1
secondaryStroke.Transparency = 0.7
secondaryStroke.Parent = secondaryWeapon

local secondaryIcon = Instance.new("TextLabel")
secondaryIcon.Size = UDim2.new(1, 0, 1, 0)
secondaryIcon.BackgroundTransparency = 1
secondaryIcon.Text = "🔫"
secondaryIcon.Font = Enum.Font.GothamBold
secondaryIcon.TextSize = 24
secondaryIcon.TextColor3 = Color3.fromRGB(150, 150, 170)
secondaryIcon.Parent = secondaryWeapon

-- ==================== HP BAR ====================
local hpBarContainer = Instance.new("Frame")
hpBarContainer.Name = "HPBarContainer"
hpBarContainer.Size = UDim2.new(1, 0, 0, 50)
hpBarContainer.Position = UDim2.new(0, 0, 1, -50) -- Position at bottom of container
hpBarContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hpBarContainer.BackgroundTransparency = 0.3
hpBarContainer.BorderSizePixel = 0
hpBarContainer.Parent = hudContainer

local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 8)
hpCorner.Parent = hpBarContainer

local hpStroke = Instance.new("UIStroke")
hpStroke.Color = Color3.fromRGB(100, 200, 100)
hpStroke.Thickness = 2
hpStroke.Transparency = 0.5
hpStroke.Parent = hpBarContainer

-- HP Label
local hpLabel = Instance.new("TextLabel")
hpLabel.Name = "HPLabel"
hpLabel.Size = UDim2.new(0, 60, 1, 0)
hpLabel.Position = UDim2.new(0, 10, 0, 0)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "HP"
hpLabel.Font = Enum.Font.GothamBold
hpLabel.TextSize = 20
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.TextXAlignment = Enum.TextXAlignment.Left
hpLabel.Parent = hpBarContainer

-- HP Bar Background
local hpBarBg = Instance.new("Frame")
hpBarBg.Name = "HPBarBg"
hpBarBg.Size = UDim2.new(1, -150, 0, 20)
hpBarBg.Position = UDim2.new(0, 70, 0.5, -10)
hpBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = hpBarContainer

local hpBarBgCorner = Instance.new("UICorner")
hpBarBgCorner.CornerRadius = UDim.new(0, 10)
hpBarBgCorner.Parent = hpBarBg

-- HP Bar Fill
local hpBarFill = Instance.new("Frame")
hpBarFill.Name = "HPBarFill"
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.Position = UDim2.new(0, 0, 0, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
hpBarFill.BorderSizePixel = 0
hpBarFill.Parent = hpBarBg

local hpBarFillCorner = Instance.new("UICorner")
hpBarFillCorner.CornerRadius = UDim.new(0, 10)
hpBarFillCorner.Parent = hpBarFill

-- HP Bar Gradient
local hpGradient = Instance.new("UIGradient")
hpGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 200, 100))
}
hpGradient.Rotation = 90
hpGradient.Parent = hpBarFill

-- HP Percentage Text
local hpPercentage = Instance.new("TextLabel")
hpPercentage.Name = "HPPercentage"
hpPercentage.Size = UDim2.new(0, 70, 1, 0)
hpPercentage.Position = UDim2.new(1, -80, 0, 0)
hpPercentage.BackgroundTransparency = 1
hpPercentage.Text = "100%"
hpPercentage.Font = Enum.Font.GothamBold
hpPercentage.TextSize = 18
hpPercentage.TextColor3 = Color3.fromRGB(255, 255, 255)
hpPercentage.TextXAlignment = Enum.TextXAlignment.Right
hpPercentage.Parent = hpBarContainer

-- ==================== UPDATE FUNCTIONS ====================
-- atjaunināt HP joslu (mans kods)
local function updateHPBar()
	local healthPercent = humanoid.Health / humanoid.MaxHealth
	local percentage = math.floor(healthPercent * 100)
	
	-- Update bar size
	local barTween = TweenService:Create(hpBarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		Size = UDim2.new(healthPercent, 0, 1, 0)
	})
	barTween:Play()
	
	-- Update percentage text
	hpPercentage.Text = percentage .. "%"
	
	-- Change color based on health
	if healthPercent > 0.6 then
		hpBarFill.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
		hpStroke.Color = Color3.fromRGB(100, 200, 100)
	elseif healthPercent > 0.3 then
		hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		hpStroke.Color = Color3.fromRGB(255, 180, 50)
	else
		hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		hpStroke.Color = Color3.fromRGB(255, 100, 100)
	end
end

-- updateWeaponDisplay: viettura funkcija, savieno ar ieroču sistēmu
local function updateWeaponDisplay(weaponData)
	-- Example weaponData format:
	-- {
	--   name = "AK-47",
	--   ammoInClip = 30,
	--   ammoReserve = 120,
	--   iconId = "rbxassetid://1234567890", -- Optional
	--   secondaryName = "Glock-18",
	--   secondaryIcon = "rbxassetid://0987654321" -- Optional
	-- }
	
	if weaponData then
		weaponName.Text = weaponData.name or "Unknown"
		ammoLabel.Text = (weaponData.ammoInClip or 0) .. " / " .. (weaponData.ammoReserve or 0)
		
		-- Update weapon icon if provided
		if weaponData.iconId and weaponData.iconId ~= "" then
			weaponIcon.Image = weaponData.iconId
			placeholderLabel.Visible = false
		else
			weaponIcon.Image = ""
			placeholderLabel.Visible = true
		end
		
		-- Animate weapon switch
		local switchTween = TweenService:Create(weaponContainer, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
			Size = UDim2.new(1, 0, 0, 95)
		})
		switchTween:Play()
		switchTween.Completed:Connect(function()
			TweenService:Create(weaponContainer, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = UDim2.new(1, 0, 0, 90)
			}):Play()
		end)
	end
end

-- klausos veselības izmaiņas
humanoid.HealthChanged:Connect(updateHPBar)

-- sākotnējais atjauninājums un animācija
updateHPBar()

-- Slide in animation
hudContainer.Position = UDim2.new(1, 50, 1, -170)
wait(0.2)
local slideIn = TweenService:Create(hudContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.new(1, -320, 1, -170)
})
slideIn:Play()


-- Example: Call this function when weapon changes
-- updateWeaponDisplay({
--     name = "M4A1",
--     ammoInClip = 25,
--     ammoReserve = 75,
--     iconId = "rbxassetid://YOUR_IMAGE_ID"
-- })

-- You can also listen for events from your weapon system
-- Example if you have a RemoteEvent or BindableEvent:
-- game.ReplicatedStorage.WeaponChanged.OnClientEvent:Connect(updateWeaponDisplay)