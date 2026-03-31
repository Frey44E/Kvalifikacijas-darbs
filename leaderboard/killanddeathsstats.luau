local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local statsDataStore = DataStoreService:GetDataStore("PlayerStats_v1")

local function onPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Value = 0
	kills.Parent = leaderstats

	local deaths = Instance.new("IntValue")
	deaths.Name = "Deaths"
	deaths.Value = 0
	deaths.Parent = leaderstats

	local success, data = pcall(function()
		return statsDataStore:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		kills.Value = data.Kills or 0
		deaths.Value = data.Deaths or 0
		print("[Leaderboard] Loaded data for " .. player.Name)
	elseif not success then
		warn("[Leaderboard] Failed to load data for " .. player.Name)
	end
end

local function savePlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local kills = leaderstats:FindFirstChild("Kills")
		local deaths = leaderstats:FindFirstChild("Deaths")

		if kills and deaths then
			local data = {
				Kills = kills.Value,
				Deaths = deaths.Value
			}

			local success, err = pcall(function()
				statsDataStore:SetAsync(tostring(player.UserId), data)
			end)

			if success then
				print("[Leaderboard] Saved data for " .. player.Name)
			else
				warn("[Leaderboard] Failed to save data for " .. player.Name .. ": " .. tostring(err))
			end
		end
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(savePlayerData)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

task.spawn(function()
	while true do
		task.wait(300)
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerData(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
	task.wait(2)
end)