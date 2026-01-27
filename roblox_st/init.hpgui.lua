
-- Place this in StarterGui as a separate LocalScript

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the startup menu to be destroyed (when PLAY is pressed)
local startupMenu = playerGui:WaitForChild("StartupMenu")
startupMenu.AncestryChanged:Wait() -- Wait until it's destroyed

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Create ScreenGui for HUD
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "GameHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = playerGui

-- Main HUD Container (bottom right)
local hudContainer = Instance.new("Frame")
hudContainer.Name = "HUDContainer"
hudContainer.Size = UDim2.new(0, 300, 0, 50)
hudContainer.Position = UDim2.new(1, -320, 1, -70)
hudContainer.BackgroundTransparency = 1
hudContainer.Parent = hudGui

-- HP Bar Container
local hpBarContainer = Instance.new("Frame")
hpBarContainer.Name = "HPBarContainer"
hpBarContainer.Size = UDim2.new(1, 0, 0, 50)
hpBarContainer.Position = UDim2.new(0, 0, 0, 0)
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

-- Update HP Bar
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

-- Listen for health changes
humanoid.HealthChanged:Connect(updateHPBar)

-- Initial update
updateHPBar()

-- Slide in animation
hudContainer.Position = UDim2.new(1, 50, 1, -70)
wait(0.2)
local slideIn = TweenService:Create(hudContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Position = UDim2.new(1, -320, 1, -70)
})
slideIn:Play()