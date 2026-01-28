
-- viewmodel prieks firspersona rīkiem Roblox 
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local camera = workspace.CurrentCamera

-- ViewModel Configuration
local ViewModel = {}
ViewModel.__index = ViewModel

-- Settings
local VIEWMODEL_FOV = 70
local SWAY_AMOUNT = 0.5
local BOB_AMOUNT = 0.2
local BOB_SPEED = 10
local LERP_SPEED = 0.2

-- Create ViewModel class
function ViewModel.new(toolModel: Model)
	local self = setmetatable({}, ViewModel)
	
	-- Clone the tool model for viewmodel
	self.model = toolModel:Clone()
	self.model.Parent = camera
	
	-- Disable collision for all parts
	for _, part in ipairs(self.model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
		end
	end
	
	-- Get the main part 
	self.primaryPart = self.model.PrimaryPart or self.model:FindFirstChild("Handle")
	
	-- Initialize variables
	self.offset = CFrame.new(0.5, -0.5, -1) -- Default offset from camera
	self.swayOffset = CFrame.new()
	self.bobOffset = CFrame.new()
	self.currentCFrame = CFrame.new()
	self.bobTime = 0
	self.lastMousePosition = UserInputService:GetMouseLocation()
	
	-- Animation tracks
	self.animations = {}
	self.currentAnimation = nil
	
	-- Setup animator if model has a humanoid
	local viewmodelHumanoid = self.model:FindFirstChildOfClass("Humanoid")
	if viewmodelHumanoid then
		self.animator = viewmodelHumanoid:FindFirstChildOfClass("Animator")
	end
	
	return self
end

-- Load animation
function ViewModel:LoadAnimation(animationId: string | Animation)
	if not self.animator then
		warn("No animator found in viewmodel")
		return nil
	end
	
	local animation
	if typeof(animationId) == "string" then
		animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://" .. animationId
	else
		animation = animationId
	end
	
	local track = self.animator:LoadAnimation(animation)
	return track
end

-- Play animation
function ViewModel:PlayAnimation(animationName: string, fadeTime: number?)
	if self.animations[animationName] then
		if self.currentAnimation then
			self.currentAnimation:Stop(fadeTime or 0.1)
		end
		
		self.currentAnimation = self.animations[animationName]
		self.currentAnimation:Play(fadeTime or 0.1)
	end
end

-- Stop animation
function ViewModel:StopAnimation(fadeTime: number?)
	if self.currentAnimation then
		self.currentAnimation:Stop(fadeTime or 0.1)
		self.currentAnimation = nil
	end
end

-- Calculate mouse sway
function ViewModel:CalculateSway(deltaTime: number)
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseDelta = mousePosition - self.lastMousePosition
	self.lastMousePosition = mousePosition
	
	-- Apply sway based on mouse movement
	local swayX = -mouseDelta.X * SWAY_AMOUNT * deltaTime
	local swayY = -mouseDelta.Y * SWAY_AMOUNT * deltaTime
	
	-- Lerp to smooth out the sway
	self.swayOffset = self.swayOffset:Lerp(
		CFrame.Angles(math.rad(swayY), math.rad(swayX), 0),
		LERP_SPEED
	)
	
	-- Gradually return to center
	self.swayOffset = self.swayOffset:Lerp(CFrame.new(), LERP_SPEED * 0.5)
end

-- Calculate walking bob
function ViewModel:CalculateBob(deltaTime: number)
	-- Only bob when moving
	if humanoid.MoveVector.Magnitude > 0 then
		self.bobTime = self.bobTime + deltaTime * BOB_SPEED
		
		local bobX = math.sin(self.bobTime) * BOB_AMOUNT
		local bobY = math.abs(math.cos(self.bobTime * 0.5)) * BOB_AMOUNT
		
		self.bobOffset = CFrame.new(bobX, bobY, 0)
	else
		-- Return to center when not moving
		self.bobTime = 0
		self.bobOffset = self.bobOffset:Lerp(CFrame.new(), LERP_SPEED)
	end
end

-- Update viewmodel position
function ViewModel:Update(deltaTime: number)
	if not self.primaryPart then return end
	
	-- Calculate effects
	self:CalculateSway(deltaTime)
	self:CalculateBob(deltaTime)
	
	-- Combine all transformations
	local targetCFrame = camera.CFrame * self.offset * self.swayOffset * self.bobOffset
	
	-- Smooth lerp to target position
	self.currentCFrame = self.currentCFrame:Lerp(targetCFrame, LERP_SPEED)
	
	-- Apply to model
	if self.model.PrimaryPart then
		self.model:SetPrimaryPartCFrame(self.currentCFrame)
	else
		self.primaryPart.CFrame = self.currentCFrame
	end
end

-- Set offset from camera
function ViewModel:SetOffset(offset: CFrame)
	self.offset = offset
end

-- Destroy viewmodel
function ViewModel:Destroy()
	if self.currentAnimation then
		self.currentAnimation:Stop()
	end
	
	self.model:Destroy()
end

-- Example usage function
function ViewModel:SetupExampleTool()
	-- Load animations (replace with your animation IDs)
	self.animations.Idle = self:LoadAnimation("1234567890") -- Replace with actual ID
	self.animations.Fire = self:LoadAnimation("1234567890") -- Replace with actual ID
	self.animations.Reload = self:LoadAnimation("1234567890") -- Replace with actual ID
	
	-- Play idle animation
	self:PlayAnimation("Idle")
end

-- Export
return ViewModel
