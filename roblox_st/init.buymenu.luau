local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- izveidoju ieroču krātuvi ReplicatedStorage (ja nav) — mans pads
local weaponStorage = ReplicatedStorage:FindFirstChild("WeaponStorage")
if not weaponStorage then
	weaponStorage = Instance.new("Folder")
	weaponStorage.Name = "WeaponStorage"
	weaponStorage.Parent = ReplicatedStorage
end


-- inventārs (es to lietoju tā)
local inventory = {
	pistol = nil,           -- 1 pistole atļauta
	primary = nil,          -- 1 šautene/smg/sniper/ieroču atļauta
	grenades = {},          -- Maks. 4 granātas kopā
	kevlar = nil,           -- 1 kevlar atļauts
	zeus = nil,             -- 1 zeus atļauts
}

-- granātu ierobežojumi (jebkuras vērtības)
local grenadeLimits = {
	HE = 1,        -- Maks. 1 HE granāta
	Flash = 2,     -- Maks. 2 gaismas granātas
	Smoke = 1,     -- Maks. 1 dūmu granāta
	Molotov = 1,   -- Maks. 1 molotova kokteilis
	Decoy = 1,     -- Maks. 1 mānīšanas granāta
}

-- funzione countGrenadeType (vienkārši saskaita)
local function countGrenadeType(grenadeType)
	local count = 0
	for _, grenade in pairs(inventory.grenades) do
		if grenade.type == grenadeType then
			count = count + 1
		end
	end
	return count
end

-- canAddGrenade: pārbaudu limits un kopējo skaitu
local function canAddGrenade(grenadeType)
	-- Pārbauda kopējo granātu skaitu
	if #inventory.grenades >= 4 then
		return false, "Maksimāli 4 granātas!"
	end

	-- Pārbauda konkrētā granātu veida ierobežojumu
	local currentCount = countGrenadeType(grenadeType)
	local limit = grenadeLimits[grenadeType] or 1

	if currentCount >= limit then
		return false, "Maksimāli " .. limit .. " " .. grenadeType .. "!"
	end

	return true
end

-- updateHUD: sagatavoju datus un izsmeļ eventu (ja ir)
local function updateHUD()
	print("=== Iegādāties izvēlni: HUD atjaunināšana ===")

	-- Sagatavo ieroču datus attēlošanai
	local weaponData = {
		pistol = inventory.pistol and {name = inventory.pistol.displayName:sub(1, 6)} or nil,
		primary = inventory.primary and {name = inventory.primary.displayName:sub(1, 6)} or nil,
		grenades = {},
		kevlar = inventory.kevlar and {name = inventory.kevlar.displayName:find("Helmet") and "K+H" or "KEV"} or nil,
		zeus = inventory.zeus and {name = "ZEUS"} or nil
	}

	-- Pievieno granātas attēlošanas datiem
	for _, grenade in ipairs(inventory.grenades) do
		table.insert(weaponData.grenades, {
			type = grenade.type,
			name = grenade.item.displayName
		})
	end

	print("Ieroču dati sagatavoti:")
	print("  Pistole:", weaponData.pistol and weaponData.pistol.name or "nav")
	print("  Primārais:", weaponData.primary and weaponData.primary.name or "nav")
	print("  Granātas:", #weaponData.grenades)

	-- Izsauc atjaunināšanas notikumu ieroču attēlošanai
	local updateEvent = ReplicatedStorage:FindFirstChild("UpdateWeaponDisplay")
	if updateEvent and updateEvent:IsA("BindableEvent") then
		print("Izsauc UpdateWeaponDisplay notikumu...")
		updateEvent:Fire(weaponData)
		print("Notikums izsaukts!")
	else
		print("KĻŪDA: UpdateWeaponDisplay notikums netika atrasts!")
	end
end

-- GUI izveide — menu frame un elementi
-- Izveido ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Izveido galveno izvēlnes rāmi
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 700, 0, 500)
menuFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
menuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
menuFrame.BorderSizePixel = 0
menuFrame.Visible = false
menuFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.BorderSizePixel = 0
title.Text = "IEROCU IZVĒLNE - Nospiediet B, lai aizvērtu"
title.TextColor3 = Color3.fromRGB(255, 200, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = menuFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Kategoriju rāmis
local categoriesFrame = Instance.new("Frame")
categoriesFrame.Size = UDim2.new(0, 150, 1, -60)
categoriesFrame.Position = UDim2.new(0, 10, 0, 60)
categoriesFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
categoriesFrame.BorderSizePixel = 0
categoriesFrame.Parent = menuFrame

local catCorner = Instance.new("UICorner")
catCorner.CornerRadius = UDim.new(0, 8)
catCorner.Parent = categoriesFrame

-- Vienumu rāmis
local itemsFrame = Instance.new("Frame")
itemsFrame.Size = UDim2.new(0, 520, 1, -60)
itemsFrame.Position = UDim2.new(0, 170, 0, 60)
itemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemsFrame.BorderSizePixel = 0
itemsFrame.Parent = menuFrame

local itemsCorner = Instance.new("UICorner")
itemsCorner.CornerRadius = UDim.new(0, 8)
itemsCorner.Parent = itemsFrame

-- Ripojošais rāmis vienumiem
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = itemsFrame

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemsLayout.Padding = UDim.new(0, 5)
itemsLayout.Parent = scrollFrame

-- kategorijas + vienumi (CSGO stils, vietturis)
-- Vienumu dati (balstīts uz CSGO; viettura ierīču nosaukumi un tagi)
local itemCategories = {
	{
		name = "Pistoles",
		weaponType = "pistol",
		items = {
			{name = "Glock-18", toolName = "Pistol_Glock18", tag = "PISTOL_GLOCK", displayName = "Glock-18"},
			{name = "P250", toolName = "Pistol_P250", tag = "PISTOL_P250", displayName = "P250"},
			{name = "Desert Eagle", toolName = "Pistol_Deagle", tag = "PISTOL_DEAGLE", displayName = "Desert Eagle"},
			{name = "Five-SeveN", toolName = "Pistol_FiveSeven", tag = "PISTOL_FIVESEVEN", displayName = "Five-SeveN"},
		}
	},
	{
		name = "Šautenes",
		weaponType = "primary",
		items = {
			{name = "AK-47", toolName = "Rifle_AK47", tag = "RIFLE_AK47", displayName = "AK-47"},
			{name = "M4A4", toolName = "Rifle_M4A4", tag = "RIFLE_M4A4", displayName = "M4A4"},
			{name = "AWP", toolName = "Rifle_AWP", tag = "RIFLE_AWP", displayName = "AWP"},
			{name = "SG 553", toolName = "Rifle_SG553", tag = "RIFLE_SG553", displayName = "SG 553"},
			{name = "AUG", toolName = "Rifle_AUG", tag = "RIFLE_AUG", displayName = "AUG"},
		}
	},
	{
		name = "SMG",
		weaponType = "primary",
		items = {
			{name = "MP9", toolName = "SMG_MP9", tag = "SMG_MP9", displayName = "MP9"},
			{name = "MP7", toolName = "SMG_MP7", tag = "SMG_MP7", displayName = "MP7"},
			{name = "UMP-45", toolName = "SMG_UMP45", tag = "SMG_UMP45", displayName = "UMP-45"},
			{name = "P90", toolName = "SMG_P90", tag = "SMG_P90", displayName = "P90"},
		}
	},
	{
		name = "Smagie ieroči",
		weaponType = "primary",
		items = {
			{name = "Nova", toolName = "Heavy_Nova", tag = "HEAVY_NOVA", displayName = "Nova"},
			{name = "XM1014", toolName = "Heavy_XM1014", tag = "HEAVY_XM1014", displayName = "XM1014"},
			{name = "MAG-7", toolName = "Heavy_MAG7", tag = "HEAVY_MAG7", displayName = "MAG-7"},
			{name = "M249", toolName = "Heavy_M249", tag = "HEAVY_M249", displayName = "M249"},
		}
	},
	{
		name = "Granātas",
		weaponType = "grenade",
		items = {
			{name = "HE Granāta", toolName = "Grenade_HE", tag = "GRENADE_HE", grenadeType = "HE", displayName = "HE Granāta"},
			{name = "Gaismas granāta", toolName = "Grenade_Flash", tag = "GRENADE_FLASH", grenadeType = "Flash", displayName = "Gaismas granāta"},
			{name = "Dūmu granāta", toolName = "Grenade_Smoke", tag = "GRENADE_SMOKE", grenadeType = "Smoke", displayName = "Dūmu granāta"},
			{name = "Molotov", toolName = "Grenade_Molotov", tag = "GRENADE_MOLOTOV", grenadeType = "Molotov", displayName = "Molotov"},
			{name = "Mānīšanas granāta", toolName = "Grenade_Decoy", tag = "GRENADE_DECOY", grenadeType = "Decoy", displayName = "Mānīšanas granāta"},
		}
	},
	{
		name = "Aprīkojums",
		weaponType = "equipment",
		items = {
			{name = "Kevlar veste", toolName = "Equipment_Kevlar", tag = "EQUIP_KEVLAR", equipType = "kevlar", displayName = "Kevlar veste"},
			{name = "Kevlar + ķivere", toolName = "Equipment_KevlarHelmet", tag = "EQUIP_KEVLAR_HELMET", equipType = "kevlar", displayName = "Kevlar + ķivere"},
			{name = "Zeus x27", toolName = "Equipment_Zeus", tag = "EQUIP_ZEUS", equipType = "zeus", displayName = "Zeus x27"},
		}
	}
}

-- pogu izveide: hover, click, statuss (manis rakstīts)
-- Funkcija kategorijas pogas izveidei
local function createCategoryButton(categoryName, index)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 50)
	button.Position = UDim2.new(0, 5, 0, (index - 1) * 55 + 5)
	button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	button.Text = categoryName
	button.TextColor3 = Color3.fromRGB(200, 200, 200)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.Parent = categoriesFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)

	return button
end

-- Funkcija vienuma pogas izveidei
local function createItemButton(item, weaponType, index)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 60)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderSizePixel = 0

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = button

	local itemLabel = Instance.new("TextLabel")
	itemLabel.Size = UDim2.new(0.6, 0, 1, 0)
	itemLabel.Position = UDim2.new(0, 10, 0, 0)
	itemLabel.BackgroundTransparency = 1
	itemLabel.Text = item.name
	itemLabel.Font = Enum.Font.Gotham
	itemLabel.TextSize = 18
	itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	itemLabel.TextXAlignment = Enum.TextXAlignment.Left
	itemLabel.Parent = button

	local tagLabel = Instance.new("TextLabel")
	tagLabel.Size = UDim2.new(0.4, -10, 0.5, 0)
	tagLabel.Position = UDim2.new(0.6, 0, 0, 0)
	tagLabel.BackgroundTransparency = 1
	tagLabel.Text = item.tag
	tagLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	tagLabel.Font = Enum.Font.Code
	tagLabel.TextSize = 12
	tagLabel.TextXAlignment = Enum.TextXAlignment.Right
	tagLabel.Parent = button

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(0.4, -10, 0.5, 0)
	statusLabel.Position = UDim2.new(0.6, 0, 0.5, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Noklikšķiniet, lai ekipētu"
	statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 14
	statusLabel.TextXAlignment = Enum.TextXAlignment.Right
	statusLabel.Parent = button

	-- Atjaunina statusa etiķeti, pamatojoties uz inventāru
	local function updateStatus()
		if weaponType == "pistol" then
			if inventory.pistol and inventory.pistol.toolName == item.toolName then
				statusLabel.Text = "EQUIPPED"
				statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			elseif inventory.pistol then
				statusLabel.Text = "Aizstāt pistoli"
				statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
			else
				statusLabel.Text = "Noklikšķiniet, lai ekipētu"
				statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
			end
		elseif weaponType == "primary" then
			if inventory.primary and inventory.primary.toolName == item.toolName then
				statusLabel.Text = "EQUIPPED"
				statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			elseif inventory.primary then
				statusLabel.Text = "Aizstāt primāro"
				statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
			else
				statusLabel.Text = "Noklikšķiniet, lai ekipētu"
				statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
			end
		elseif weaponType == "grenade" then
			local count = countGrenadeType(item.grenadeType)
			local limit = grenadeLimits[item.grenadeType]
			statusLabel.Text = count .. "/" .. limit .. " pieder"
			if count >= limit then
				statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			else
				statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
			end
		elseif weaponType == "equipment" then
			if item.equipType == "kevlar" then
				if inventory.kevlar and inventory.kevlar.toolName == item.toolName then
					statusLabel.Text = "EQUIPPED"
					statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
				elseif inventory.kevlar then
					statusLabel.Text = "Aizstāt kevlaru"
					statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
				else
					statusLabel.Text = "Noklikšķiniet, lai ekipētu"
					statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
				end
			elseif item.equipType == "zeus" then
				if inventory.zeus then
					statusLabel.Text = "EQUIPPED"
					statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
				else
					statusLabel.Text = "Noklikšķiniet, lai ekipētu"
					statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
				end
			end
		end
	end

	updateStatus()

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end)

	button.MouseButton1Click:Connect(function()
		local canEquip = true
		local errorMsg = ""

		-- Pārbauda inventāra ierobežojumus atkarībā no ieroša veida
		if weaponType == "grenade" then
			canEquip, errorMsg = canAddGrenade(item.grenadeType)
		end

		if not canEquip then
			-- Rāda kļūdu
			button.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			statusLabel.Text = errorMsg
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			wait(1)
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			updateStatus()
			return
		end

		-- Vizuāla atgriezeniskā saite
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		wait(0.1)
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

		-- Vispirms mēģina atrast rīku WeaponStorage
		local tool = weaponStorage:FindFirstChild(item.toolName)

		if not tool then
			-- Izveido viettura rīku
			tool = Instance.new("Tool")
			tool.Name = item.toolName
			tool.RequiresHandle = false

			-- Pievieno tagu
			local tagValue = Instance.new("StringValue")
			tagValue.Name = "WeaponTag"
			tagValue.Value = item.tag
			tagValue.Parent = tool

			-- Pievieno ieroša tipu
			local typeValue = Instance.new("StringValue")
			typeValue.Name = "WeaponType"
			typeValue.Value = weaponType
			typeValue.Parent = tool

			-- Pievieno piezīmi
			local noteValue = Instance.new("StringValue")
			noteValue.Name = "Note"
			noteValue.Value = "VIEGLA - Aizstāt ar reālo ieroču modeli"
			noteValue.Parent = tool

			-- Izveido 'Handle' daļu
			local handle = Instance.new("Part")
			handle.Name = "Handle"
			handle.Size = Vector3.new(0.5, 1, 2)
			handle.BrickColor = BrickColor.new("Dark stone grey")
			handle.Parent = tool

			-- Saglabā krātuvē
			local storedTool = tool:Clone()
			storedTool.Parent = weaponStorage
		end

		-- Apstrādā ekipēšanu atkarībā no tipa
		if weaponType == "pistol" then
			-- Noņem veco pistoli
			if inventory.pistol then
				local oldTool = player.Character:FindFirstChild(inventory.pistol.toolName)
				if oldTool then oldTool:Destroy() end
			end

			-- Aprīko jaunu pistoli
			inventory.pistol = item
			local toolClone = weaponStorage:FindFirstChild(item.toolName):Clone()
			toolClone.Parent = player.Character
			print("Ekipēta pistole: " .. item.displayName)

		elseif weaponType == "primary" then
			-- Noņem veco primāro ieroci
			if inventory.primary then
				local oldTool = player.Character:FindFirstChild(inventory.primary.toolName)
				if oldTool then oldTool:Destroy() end
			end

			-- Aprīko jaunu primāro ieroci
			inventory.primary = item
			local toolClone = weaponStorage:FindFirstChild(item.toolName):Clone()
			toolClone.Parent = player.Character
			player.Character.Humanoid:EquipTool(toolClone)
			print("Ekipēts primārais: " .. item.displayName)

		elseif weaponType == "grenade" then
			-- Pievieno granātu inventāram
			table.insert(inventory.grenades, {type = item.grenadeType, item = item})
			local toolClone = weaponStorage:FindFirstChild(item.toolName):Clone()
			toolClone.Parent = player.Character
			print("Pievienota granāta: " .. item.displayName .. " (" .. #inventory.grenades .. "/4)")

		elseif weaponType == "equipment" then
			if item.equipType == "kevlar" then
			-- Noņem veco kevlaru
				if inventory.kevlar then
					local oldTool = player.Character:FindFirstChild(inventory.kevlar.toolName)
					if oldTool then oldTool:Destroy() end
				end

			-- Aprīko jaunu kevlaru
				inventory.kevlar = item
				local toolClone = weaponStorage:FindFirstChild(item.toolName):Clone()
				toolClone.Parent = player.Character
				print("Ekipēts: " .. item.displayName)

			elseif item.equipType == "zeus" then
				-- Noņem veco zeusu
				if inventory.zeus then
					local oldTool = player.Character:FindFirstChild(inventory.zeus.toolName)
					if oldTool then oldTool:Destroy() end
				end

			-- Aprīko zeusu
				inventory.zeus = item
				local toolClone = weaponStorage:FindFirstChild(item.toolName):Clone()
				toolClone.Parent = player.Character
				print("Ekipēts: " .. item.displayName)
			end
		end

		-- Atjaunina HUD
		updateHUD()

		-- Atjaunina visas pogas pašreizējā kategorijā
		for _, btn in pairs(scrollFrame:GetChildren()) do
			if btn:IsA("TextButton") and btn:FindFirstChild("StatusLabel") then
				-- Šeit notiktu atsvaidzināšana
			end
		end

		updateStatus()
	end)

	button.Parent = scrollFrame
	return button
end

-- Funkcija kategorijas vienumu attēlošanai
local function displayCategory(categoryIndex)
	-- Notīra pašreizējos vienumus
	for _, child in pairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	-- Pievieno jaunus vienumus
	local category = itemCategories[categoryIndex]
	for i, item in ipairs(category.items) do
		createItemButton(item, category.weaponType, i)
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #category.items * 65)
end

-- Izveido kategoriju pogas
for i, category in ipairs(itemCategories) do
	local button = createCategoryButton(category.name, i)
	button.MouseButton1Click:Connect(function()
		displayCategory(i)
	end)
end

-- Pēc noklusējuma attēlo pirmo kategoriju
displayCategory(1)

-- pārslēgšana ar B taustiņu (vienkārši toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.B then
		menuFrame.Visible = not menuFrame.Visible
	end
end)

print("CSGO Ieroču izvēlne ielādēta! Nospiediet B, lai atvērtu/aizvērtu")
print("Vietturierīces tiks izveidotas automātiski.")
print("Aizstājiet tās ReplicatedStorage > WeaponStorage ar saviem reālajiem ieročiem!")