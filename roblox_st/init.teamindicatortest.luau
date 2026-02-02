local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("Team Indicator script started - waiting for PLAY button...")

-- WAIT FOR STARTUP MENU TO BE DESTROYED (PLAY BUTTON PRESSED)
local startupMenu = playerGui:WaitForChild("StartupMenu")
startupMenu.AncestryChanged:Wait()

print("PLAY pressed, team indicator ready...")

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

-- Main container ar abām komandām
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 300, 0, 100)
mainContainer.Position = UDim2.new(0.5, -150, 0, 20)
mainContainer.BackgroundTransparency = 1
mainContainer.Visible = false
mainContainer.Parent = screenGui

-- RED TEAM Box (kreisā puse)
local redBox = Instance.new("Frame")
redBox.Name = "RedBox"
redBox.Size = UDim2.new(0, 140, 1, 0)
redBox.Position = UDim2.new(0, 0, 0, 0)
redBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
redBox.BorderSizePixel = 0
redBox.Parent = mainContainer

local redCorner = Instance.new("UICorner")
redCorner.CornerRadius = UDim.new(0, 10)
redCorner.Parent = redBox

local redStroke = Instance.new("UIStroke")
redStroke.Color = Color3.fromRGB(255, 100, 100)
redStroke.Thickness = 3
redStroke.Transparency = 0.5
redStroke.Parent = redBox

-- Red team avatar
local redAvatar = Instance.new("ImageLabel")
redAvatar.Name = "RedAvatar"
redAvatar.Size = UDim2.new(0, 80, 0, 80)
redAvatar.Position = UDim2.new(0.5, -40, 0.5, -40)
redAvatar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
redAvatar.BorderSizePixel = 0
redAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
redAvatar.Parent = redBox

local redAvatarCorner = Instance.new("UICorner")
redAvatarCorner.CornerRadius = UDim.new(0, 8)
redAvatarCorner.Parent = redAvatar

local redAvatarStroke = Instance.new("UIStroke")
redAvatarStroke.Color = Color3.fromRGB(255, 80, 80)
redAvatarStroke.Thickness = 2
redAvatarStroke.Parent = redAvatar

-- BLUE TEAM Box (labā puse)
local blueBox = Instance.new("Frame")
blueBox.Name = "BlueBox"
blueBox.Size = UDim2.new(0, 140, 1, 0)
blueBox.Position = UDim2.new(1, -140, 0, 0)
blueBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
blueBox.BorderSizePixel = 0
blueBox.Parent = mainContainer

local blueCorner = Instance.new("UICorner")
blueCorner.CornerRadius = UDim.new(0, 10)
blueCorner.Parent = blueBox

local blueStroke = Instance.new("UIStroke")
blueStroke.Color = Color3.fromRGB(100, 150, 255)
blueStroke.Thickness = 3
blueStroke.Transparency = 0.5
blueStroke.Parent = blueBox

-- Blue team avatar
local blueAvatar = Instance.new("ImageLabel")
blueAvatar.Name = "BlueAvatar"
blueAvatar.Size = UDim2.new(0, 80, 0, 80)
blueAvatar.Position = UDim2.new(0.5, -40, 0.5, -40)
blueAvatar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
blueAvatar.BorderSizePixel = 0
blueAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
blueAvatar.Parent = blueBox

local blueAvatarCorner = Instance.new("UICorner")
blueAvatarCorner.CornerRadius = UDim.new(0, 8)
blueAvatarCorner.Parent = blueAvatar

local blueAvatarStroke = Instance.new("UIStroke")
blueAvatarStroke.Color = Color3.fromRGB(80, 150, 255)
blueAvatarStroke.Thickness = 2
blueAvatarStroke.Parent = blueAvatar

-- Center separator with VS
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.Size = UDim2.new(0, 10, 0, 60)
separator.Position = UDim2.new(0.5, -5, 0.5, -30)
separator.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
separator.BorderSizePixel = 0
separator.Parent = mainContainer

local sepCorner = Instance.new("UICorner")
sepCorner.CornerRadius = UDim.new(0, 5)
sepCorner.Parent = separator

local vsLabel = Instance.new("TextLabel")
vsLabel.Size = UDim2.new(0, 40, 0, 30)
vsLabel.Position = UDim2.new(0.5, -20, 0.5, -15)
vsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
vsLabel.BorderSizePixel = 0
vsLabel.Text = "VS"
vsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
vsLabel.Font = Enum.Font.GothamBold
vsLabel.TextSize = 16
vsLabel.Parent = mainContainer

local vsCorner = Instance.new("UICorner")
vsCorner.CornerRadius = UDim.new(0, 8)
vsCorner.Parent = vsLabel

-- Function to get avatar for other team players
local function findOtherTeamPlayer(myTeam)
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer ~= player then
			local theirTeam = otherPlayer:FindFirstChild("Team")
			if theirTeam and theirTeam.Value ~= "" and theirTeam.Value ~= myTeam then
				return otherPlayer
			end
		end
	end
	return nil
end

-- updateTeamIndicator: uzstāda boju ikonu/krāsu + avatārus
local function updateTeamIndicator(teamName)
	print("Updating team indicator for " .. teamName .. " team")
	
	if teamName == "Red" then
		-- Player is on RED team
		redStroke.Thickness = 4
		redStroke.Transparency = 0
		redAvatarStroke.Thickness = 3
		
		blueStroke.Thickness = 3
		blueStroke.Transparency = 0.5
		blueAvatarStroke.Thickness = 2
		
		-- Try to find enemy player for blue side
		local enemyPlayer = findOtherTeamPlayer("Red")
		if enemyPlayer then
			blueAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. enemyPlayer.UserId .. "&w=150&h=150"
			print("Found enemy player: " .. enemyPlayer.Name)
		end
		
	elseif teamName == "Blue" then
		-- Player is on BLUE team
		blueStroke.Thickness = 4
		blueStroke.Transparency = 0
		blueAvatarStroke.Thickness = 3
		
		redStroke.Thickness = 3
		redStroke.Transparency = 0.5
		redAvatarStroke.Thickness = 2
		
		-- Try to find enemy player for red side
		local enemyPlayer = findOtherTeamPlayer("Blue")
		if enemyPlayer then
			redAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. enemyPlayer.UserId .. "&w=150&h=150"
			print("Found enemy player: " .. enemyPlayer.Name)
		end
	end
	
	-- Show with animation
	mainContainer.Visible = true
	mainContainer.Position = UDim2.new(0.5, -150, 0, -100)
	
	local slideIn = TweenService:Create(mainContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -150, 0, 20)
	})
	slideIn:Play()
	
	print("Team indicator visible!")
end

-- Listen for when other players join a team
Players.PlayerAdded:Connect(function(newPlayer)
	wait(1) -- Wait for their team to be set
	local myTeam = player:FindFirstChild("Team")
	if myTeam and myTeam.Value ~= "" then
		updateTeamIndicator(myTeam.Value)
	end
end)

-- klausos eventu un pārbaudu esošo Team vērtību
teamSelectedEvent.Event:Connect(updateTeamIndicator)

-- pārbaudu esošo komandu (ja nu kas pēc respawn)
local existingTeam = player:FindFirstChild("Team")
if existingTeam and existingTeam.Value ~= "" then
	updateTeamIndicator(existingTeam.Value)
end

print("Team Indicator loaded!")