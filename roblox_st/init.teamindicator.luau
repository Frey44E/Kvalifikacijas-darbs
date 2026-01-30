-- komandu indikators augšā (mans neliels GUI)
-- šo lieku StarterGui kā LocalScript

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- gaidu TeamSelected event (ja nav, uztaisu)
local teamSelectedEvent = ReplicatedStorage:FindFirstChild("TeamSelected")
if not teamSelectedEvent then
	teamSelectedEvent = Instance.new("BindableEvent")
	teamSelectedEvent.Name = "TeamSelected"
	teamSelectedEvent.Parent = ReplicatedStorage
end

-- izveidoju ScreenGui un rāmi (vienkārši indikators)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeamIndicatorGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Team indikatora kaste
local teamBox = Instance.new("Frame")
teamBox.Name = "TeamBox"
teamBox.Size = UDim2.new(0, 120, 0, 120)
teamBox.Position = UDim2.new(0.5, -60, 0, 20)
teamBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
teamBox.BackgroundTransparency = 0.3
teamBox.BorderSizePixel = 0
teamBox.Visible = false
teamBox.Parent = screenGui

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 10)
boxCorner.Parent = teamBox

local boxStroke = Instance.new("UIStroke")
boxStroke.Color = Color3.fromRGB(100, 100, 120)
boxStroke.Thickness = 3
boxStroke.Transparency = 0.5
boxStroke.Parent = teamBox

-- Poga/ikona/teksts — mainu atkarībā no team
local teamIcon = Instance.new("TextLabel")
teamIcon.Size = UDim2.new(1, 0, 0.7, 0)
teamIcon.Position = UDim2.new(0, 0, 0, 5)
teamIcon.BackgroundTransparency = 1
teamIcon.Text = "🔴"
teamIcon.TextSize = 60
teamIcon.Parent = teamBox

-- Team nosaukums
local teamLabel = Instance.new("TextLabel")
teamLabel.Size = UDim2.new(1, 0, 0.3, 0)
teamLabel.Position = UDim2.new(0, 0, 0.7, 0)
teamLabel.BackgroundTransparency = 1
teamLabel.Text = "RED"
teamLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
teamLabel.Font = Enum.Font.GothamBold
teamLabel.TextSize = 18
teamLabel.Parent = teamBox

-- updateTeamIndicator: uzstāda boju ikonu/krāsu
local function updateTeamIndicator(teamName)
	if teamName == "Red" then
		teamIcon.Text = "🔴"
		teamLabel.Text = "RED"
		boxStroke.Color = Color3.fromRGB(255, 100, 100)
		teamBox.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
	elseif teamName == "Blue" then
		teamIcon.Text = "🔵"
		teamLabel.Text = "BLUE"
		boxStroke.Color = Color3.fromRGB(100, 150, 255)
		teamBox.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	end

	teamBox.Visible = true
end

-- klausos eventu un pārbaudu esošo Team vērtību
teamSelectedEvent.Event:Connect(updateTeamIndicator)

-- pārbaudu esošo komandu (ja nu kas pēc respawn)
local existingTeam = player:FindFirstChild("Team")
if existingTeam and existingTeam.Value ~= "" then
	updateTeamIndicator(existingTeam.Value)
end

print("Team Indicator loaded!")
