-- komandu izvēle (manā veidā)
print("Hello world!")
-- Team Selection Menu
-- Place this in StarterGui as a LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("Team Selection Menu script started!")

-- gaidu characteru (pirms rādīt izvēli)
local character = player.Character or player.CharacterAdded:Wait()
print("Character loaded, showing team selection...")

-- izveidoju GUI rāmi un overlay
-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeamSelectionGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Enabled = true
screenGui.Parent = playerGui

print("Team Selection GUI created!")

-- Dark overlay
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.3
overlay.BorderSizePixel = 0
overlay.Parent = screenGui

-- Main container
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 500, 0, 300)
container.Position = UDim2.new(0.5, -250, 0.5, -150)
container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
container.BorderSizePixel = 0
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = container

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
title.BorderSizePixel = 0
title.Text = "SELECT TEAM"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.Parent = container

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Function to create team button
local function createTeamButton(teamName, color, position)
	local button = Instance.new("TextButton")
	button.Name = teamName .. "Button"
	button.Size = UDim2.new(0, 200, 0, 120)
	button.Position = position
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = container

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = button

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(255, 255, 255)
	btnStroke.Thickness = 2
	btnStroke.Transparency = 0.7
	btnStroke.Parent = button

	-- Team icon (placeholder)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 0, 60)
	icon.Position = UDim2.new(0, 0, 0, 10)
	icon.BackgroundTransparency = 1
	icon.Text = teamName == "Red" and "🔴" or "🔵"
	icon.TextSize = 48
	icon.Parent = button

	-- Team name
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 40)
	label.Position = UDim2.new(0, 0, 1, -50)
	label.BackgroundTransparency = 1
	label.Text = teamName:upper() .. " TEAM"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20
	label.Parent = button

	-- Hover effects
	button.MouseEnter:Connect(function()
		btnStroke.Transparency = 0
		button.BackgroundColor3 = Color3.fromRGB(
			math.min(color.R * 255 + 20, 255),
			math.min(color.G * 255 + 20, 255),
			math.min(color.B * 255 + 20, 255)
		)
	end)

	button.MouseLeave:Connect(function()
		btnStroke.Transparency = 0.7
		button.BackgroundColor3 = color
	end)

	return button
end

-- izveidoju pogas Red/Blue (hover efekti, mans)
-- Create team buttons
local redButton = createTeamButton("Red", Color3.fromRGB(200, 50, 50), UDim2.new(0, 30, 0, 100))
local blueButton = createTeamButton("Blue", Color3.fromRGB(50, 100, 200), UDim2.new(1, -230, 0, 100))

-- Function to join team
local function joinTeam(teamName)
	print("Joining team: " .. teamName)

	-- Create or get team value in player
	local teamValue = player:FindFirstChild("Team")
	if not teamValue then
		teamValue = Instance.new("StringValue")
		teamValue.Name = "Team"
		teamValue.Parent = player
	end
	teamValue.Value = teamName

	print("Team value set to: " .. teamValue.Value)
	print("Hiding team selection menu...")

	-- Hide team selection
	screenGui:Destroy()

	print("Team selection destroyed, firing event...")

	-- Fire event to update team indicator
	local teamSelectedEvent = ReplicatedStorage:FindFirstChild("TeamSelected")
	if not teamSelectedEvent then
		teamSelectedEvent = Instance.new("BindableEvent")
		teamSelectedEvent.Name = "TeamSelected"
		teamSelectedEvent.Parent = ReplicatedStorage
		print("Created TeamSelected event")
	end
	teamSelectedEvent:Fire(teamName)
	print("Team selection complete!")
end

-- joinTeam: uzstādīju player.Team un izsūtu eventu
-- Button connections
redButton.MouseButton1Click:Connect(function()
	print("RED button clicked!")
	joinTeam("Red")
end)

blueButton.MouseButton1Click:Connect(function()
	print("BLUE button clicked!")
	joinTeam("Blue")
end)

print("Team Selection Menu loaded!")