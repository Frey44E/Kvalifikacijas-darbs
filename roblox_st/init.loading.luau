-- startergui localscript (mans starta ekrāns)
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- izveidoju ScreenGui (starta izvēlne)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StartupMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- galvenais rāmis (fon rāmis)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0, 400, 0, 100)
titleLabel.Position = UDim2.new(0.15, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LAZER TAG"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 60
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextStrokeTransparency = 0.5
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Button Container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(0, 400, 0, 400)
buttonContainer.Position = UDim2.new(0, 50, 0.5, -50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

-- Content Frame (for credits and settings)
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(0, 500, 0, 400)
contentFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentFrame.BorderSizePixel = 0
contentFrame.Visible = false
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = contentFrame

local contentTitle = Instance.new("TextLabel")
contentTitle.Name = "ContentTitle"
contentTitle.Size = UDim2.new(1, -40, 0, 60)
contentTitle.Position = UDim2.new(0, 20, 0, 20)
contentTitle.BackgroundTransparency = 1
contentTitle.Text = "CONTENT"
contentTitle.Font = Enum.Font.GothamBold
contentTitle.TextSize = 32
contentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
contentTitle.TextXAlignment = Enum.TextXAlignment.Left
contentTitle.Parent = contentFrame

local contentText = Instance.new("TextLabel")
contentText.Name = "ContentText"
contentText.Size = UDim2.new(1, -40, 1, -140)
contentText.Position = UDim2.new(0, 20, 0, 90)
contentText.BackgroundTransparency = 1
contentText.Text = ""
contentText.Font = Enum.Font.Gotham
contentText.TextSize = 18
contentText.TextColor3 = Color3.fromRGB(200, 200, 200)
contentText.TextXAlignment = Enum.TextXAlignment.Left
contentText.TextYAlignment = Enum.TextYAlignment.Top
contentText.TextWrapped = true
contentText.Parent = contentFrame

local backButton = Instance.new("TextButton")
backButton.Name = "BackButton"
backButton.Size = UDim2.new(0, 120, 0, 40)
backButton.Position = UDim2.new(0.5, -60, 1, -60)
backButton.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
backButton.Text = "BACK"
backButton.Font = Enum.Font.GothamBold
backButton.TextSize = 18
backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
backButton.Parent = contentFrame

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 8)
backCorner.Parent = backButton

-- pogu dati (apgriezts: no apakšas uz augšu) — stilīga piezīme
local buttons = {
	{name = "CREDITS", color = Color3.fromRGB(20, 40, 60), icon = "</> ", position = 2},
	{name = "SETTINGS", color = Color3.fromRGB(20, 50, 40), icon = "⚙ ", position = 1},
	{name = "PLAY", color = Color3.fromRGB(30, 70, 40), icon = "▶ ", position = 0}
}

-- izveido animētu pogu (apgriezts stils, mani hover efekti)
local function createButton(data, index)
	local button = Instance.new("TextButton")
	button.Name = data.name .. "Button"
	button.Size = UDim2.new(0, 350, 0, 70)
	button.Position = UDim2.new(0, 0, 0, data.position * 100)
	button.BackgroundColor3 = data.color
	button.BorderSizePixel = 0
	button.Text = ""
	button.Font = Enum.Font.GothamBold
	button.TextSize = 28
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.ClipsDescendants = false
	button.AutoButtonColor = false
	button.BackgroundTransparency = 0.3
	button.Parent = buttonContainer

	-- Add stroke for outline
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 200, 255)
	stroke.Thickness = 3
	stroke.Transparency = 0.3
	stroke.Parent = button

	-- Icon label
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 60, 1, 0)
	iconLabel.Position = UDim2.new(0, 10, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = data.icon
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.TextSize = 36
	iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	iconLabel.TextXAlignment = Enum.TextXAlignment.Left
	iconLabel.Parent = button

	-- Text label
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -80, 1, 0)
	textLabel.Position = UDim2.new(0, 80, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = data.name
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 32
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = button

	-- Slide in animation from left
	button.Position = UDim2.new(0, -400, 0, data.position * 100)
	wait(index * 0.15)
	local slideIn = TweenService:Create(button, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, data.position * 100)
	})
	slideIn:Play()

	-- Hover effects
	button.MouseEnter:Connect(function()
		local hoverTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 380, 0, 75),
			BackgroundTransparency = 0.1
		})
		hoverTween:Play()

		local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.3), {
			Transparency = 0,
			Thickness = 4
		})
		strokeTween:Play()
	end)

	button.MouseLeave:Connect(function()
		local hoverTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 350, 0, 70),
			BackgroundTransparency = 0.3
		})
		hoverTween:Play()

		local strokeTween = TweenService:Create(stroke, TweenInfo.new(0.3), {
			Transparency = 0.3,
			Thickness = 3
		})
		strokeTween:Play()
	end)

	-- pogu klikšķi: play/darbojas/beidz GUI (mans)
	button.MouseButton1Click:Connect(function()
		if data.name == "PLAY" then
			-- Start game - remove GUI immediately
			screenGui:Destroy()

		elseif data.name == "CREDITS" then
			-- Credits button does nothing (no placeholder)

		elseif data.name == "SETTINGS" then
			-- Settings button does nothing (no placeholder)
		end
	end)

	return button
end

-- Create all buttons
for i, buttonData in ipairs(buttons) do
	createButton(buttonData, i)
end

-- back poga: samazinu saturu un paslēpu
backButton.MouseButton1Click:Connect(function()
	local hideTween = TweenService:Create(contentFrame, TweenInfo.new(0.3), {
		Size = UDim2.new(0, 0, 0, 0)
	})
	hideTween:Play()
	hideTween.Completed:Connect(function()
		contentFrame.Visible = false
		contentFrame.Size = UDim2.new(0, 500, 0, 400)
	end)
end)

backButton.MouseEnter:Connect(function()
	local hoverTween = TweenService:Create(backButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(90, 150, 255)
	})
	hoverTween:Play()
end)

backButton.MouseLeave:Connect(function()
	local hoverTween = TweenService:Create(backButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(70, 130, 255)
	})
	hoverTween:Play()
end)

-- virsraksta pulsēšanas efekts (vienkārši vizuāls)
spawn(function()
	while titleLabel and titleLabel.Parent do
		local pulseTween = TweenService:Create(titleLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextTransparency = 0.3
		})
		pulseTween:Play()
		pulseTween.Completed:Wait()

		local pulseTween2 = TweenService:Create(titleLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextTransparency = 0
		})
		pulseTween2:Play()
		pulseTween2.Completed:Wait()
	end
end)

-- plaukstošās daļiņas (vēl viena vizuāla lieta)
spawn(function()
	for i = 1, 15 do
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
		particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
		particle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
		particle.BackgroundTransparency = 0.7
		particle.BorderSizePixel = 0
		particle.Parent = mainFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = particle

		-- Animate particle
		spawn(function()
			while particle and particle.Parent do
				local randomY = math.random(-100, 100)
				local randomX = math.random(-50, 50)
				local duration = math.random(8, 15)

				local moveTween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = particle.Position + UDim2.new(0, randomX, 0, randomY)
				})
				moveTween:Play()
				moveTween.Completed:Wait()
			end
		end)
	end
end)
