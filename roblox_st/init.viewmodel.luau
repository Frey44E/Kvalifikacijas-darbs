-- viewmodel priekš first-person (mans piezīmju skripts)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local camera = workspace.CurrentCamera

-- viewmodel konfig
local ViewModel = {}
ViewModel.__index = ViewModel

-- iestatījumi (pielāgo sev)
local VIEWMODEL_FOV = 70
local SWAY_AMOUNT = 0.5
local BOB_AMOUNT = 0.2
local BOB_SPEED = 10
local LERP_SPEED = 0.2

-- izveido ViewModel klasi
function ViewModel.new(toolModel: Model)
	local self = setmetatable({}, ViewModel)
	
	-- klonēju tool modeli viewmodel'ī
	self.model = toolModel:Clone()
	self.model.Parent = camera
	
	-- atslēdzu kolīzijas uz visu parts
	for _, part in ipairs(self.model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
		end
	end
	
	-- galvenā daļa 
	self.primaryPart = self.model.PrimaryPart or self.model:FindFirstChild("Handle")
	
	-- sākotnējie mainīgie (offsets utt)
	self.offset = CFrame.new(0.5, -0.5, -1) -- Noklusējuma attālums no kameras
	self.swayOffset = CFrame.new()
	self.bobOffset = CFrame.new()
	self.currentCFrame = CFrame.new()
	self.bobTime = 0
	self.lastMousePosition = UserInputService:GetMouseLocation()
	
	-- animāciju sliedes
	self.animations = {}
	self.currentAnimation = nil
	
	-- uzstādīt animatoru, ja modelim ir humanoids
	local viewmodelHumanoid = self.model:FindFirstChildOfClass("Humanoid")
	if viewmodelHumanoid then
		self.animator = viewmodelHumanoid:FindFirstChildOfClass("Animator")
	end
	
	return self
end

-- ielādēt animāciju (ja vajag)
function ViewModel:LoadAnimation(animationId: string | Animation)
	if not self.animator then
		warn("Nav atrasts neviens animators viewmodel'ā")
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

-- atskaņot animāciju
function ViewModel:PlayAnimation(animationName: string, fadeTime: number?)
	if self.animations[animationName] then
		if self.currentAnimation then
			self.currentAnimation:Stop(fadeTime or 0.1)
		end
		
		self.currentAnimation = self.animations[animationName]
		self.currentAnimation:Play(fadeTime or 0.1)
	end
end

-- apstādināt animāciju
function ViewModel:StopAnimation(fadeTime: number?)
	if self.currentAnimation then
		self.currentAnimation:Stop(fadeTime or 0.1)
		self.currentAnimation = nil
	end
end

-- aprēķinu mouse sway
function ViewModel:CalculateSway(deltaTime: number)
	local mousePosition = UserInputService:GetMouseLocation()
	local mouseDelta = mousePosition - self.lastMousePosition
	self.lastMousePosition = mousePosition
	
	-- pielāgo sway, balstoties uz peles kustību
	local swayX = -mouseDelta.X * SWAY_AMOUNT * deltaTime
	local swayY = -mouseDelta.Y * SWAY_AMOUNT * deltaTime
	
	-- Lerp, lai izlīdzinātu sway efektu
	self.swayOffset = self.swayOffset:Lerp(
		CFrame.Angles(math.rad(swayY), math.rad(swayX), 0),
		LERP_SPEED
	)
	
	-- pakāpeniski atgriezties centrā
	self.swayOffset = self.swayOffset:Lerp(CFrame.new(), LERP_SPEED * 0.5)
end

-- aprēķinu bob (staigāšanas efekts)
function ViewModel:CalculateBob(deltaTime: number)
	-- tikai kustības gadījumā
	if humanoid.MoveVector.Magnitude > 0 then
		self.bobTime = self.bobTime + deltaTime * BOB_SPEED
		
		local bobX = math.sin(self.bobTime) * BOB_AMOUNT
		local bobY = math.abs(math.cos(self.bobTime * 0.5)) * BOB_AMOUNT
		
		self.bobOffset = CFrame.new(bobX, bobY, 0)
	else
		-- atgriezties centrā, ja nekustas
		self.bobTime = 0
		self.bobOffset = self.bobOffset:Lerp(CFrame.new(), LERP_SPEED)
	end
end

-- atjaunot pozīciju katru kadru
function ViewModel:Update(deltaTime: number)
	if not self.primaryPart then return end
	
	-- aprēķināt efektus
	self:CalculateSway(deltaTime)
	self:CalculateBob(deltaTime)
	
	-- apvienot visas transformācijas
	local targetCFrame = camera.CFrame * self.offset * self.swayOffset * self.bobOffset
	
	-- gluda pāreja uz mērķa pozīciju
	self.currentCFrame = self.currentCFrame:Lerp(targetCFrame, LERP_SPEED)
	
	-- piemērot modelim
	if self.model.PrimaryPart then
		self.model:SetPrimaryPartCFrame(self.currentCFrame)
	else
		self.primaryPart.CFrame = self.currentCFrame
	end
end

-- offseta setter un destroy
function ViewModel:SetOffset(offset: CFrame)
	self.offset = offset
end

-- iznīcināt viewmodel
function ViewModel:Destroy()
	if self.currentAnimation then
		self.currentAnimation:Stop()
	end
	
	self.model:Destroy()
end

-- piemēra izmantošana
function ViewModel:SetupExampleTool()
	-- ielādēt animācijas (aizstāj ar savām animāciju ID)
	self.animations.Idle = self:LoadAnimation("1234567890") -- Aizstāj ar reālo ID
	self.animations.Fire = self:LoadAnimation("1234567890") -- Aizstāj ar reālo ID
	self.animations.Reload = self:LoadAnimation("1234567890") -- Aizstāj ar reālo ID
	
	-- atskaņot neaktivitātes animāciju
	self:PlayAnimation("Idle")
end

-- eksports
return ViewModel
