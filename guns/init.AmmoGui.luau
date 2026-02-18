local GUN_IMAGE_ID = "rbxassetid://133385136128865"

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AmmoGui"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local TEXT_SIZE = 22
local BAR_SIZE = UDim2.new(0, 220, 0, 44)
local BAR_POS  = UDim2.new(0, 20, 1, -80)

local ammoBar = Instance.new("Frame")
ammoBar.Name = "AmmoBar"
ammoBar.Size = BAR_SIZE
ammoBar.Position = BAR_POS
ammoBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ammoBar.BorderSizePixel = 0
ammoBar.Visible = true
ammoBar.Parent = screenGui

local ammoGunImage = Instance.new("ImageLabel")
ammoGunImage.Name = "AmmoGunImage"
ammoGunImage.Size = UDim2.new(0, 40, 0, 32)
ammoGunImage.Position = UDim2.new(0, 6, 0.5, -16)
ammoGunImage.BackgroundTransparency = 1
ammoGunImage.Image = GUN_IMAGE_ID
ammoGunImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
ammoGunImage.ScaleType = Enum.ScaleType.Fit
ammoGunImage.Parent = ammoBar

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Name = "AmmoLabel"
ammoLabel.Size = UDim2.new(1, -56, 1, 0)
ammoLabel.Position = UDim2.new(0, 54, 0, 0)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Text = "30/30"
ammoLabel.TextScaled = false
ammoLabel.TextSize = TEXT_SIZE
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLabel.TextXAlignment = Enum.TextXAlignment.Left
ammoLabel.TextYAlignment = Enum.TextYAlignment.Center
ammoLabel.Parent = ammoBar

local reloadBarBG = Instance.new("Frame")
reloadBarBG.Name = "ReloadBarBG"
reloadBarBG.Size = BAR_SIZE
reloadBarBG.Position = BAR_POS
reloadBarBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
reloadBarBG.BorderSizePixel = 0
reloadBarBG.Visible = false
reloadBarBG.Parent = screenGui

local reloadFill = Instance.new("Frame")
reloadFill.Name = "ReloadFill"
reloadFill.Size = UDim2.new(1, 0, 1, 0)
reloadFill.Position = UDim2.new(0, 0, 0, 0)
reloadFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
reloadFill.BorderSizePixel = 0
reloadFill.Parent = reloadBarBG

local reloadGunImage = Instance.new("ImageLabel")
reloadGunImage.Name = "ReloadGunImage"
reloadGunImage.Size = UDim2.new(0, 40, 0, 32)
reloadGunImage.Position = UDim2.new(0, 6, 0.5, -16)
reloadGunImage.BackgroundTransparency = 1
reloadGunImage.Image = GUN_IMAGE_ID
reloadGunImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
reloadGunImage.ScaleType = Enum.ScaleType.Fit
reloadGunImage.ZIndex = 2
reloadGunImage.Parent = reloadBarBG