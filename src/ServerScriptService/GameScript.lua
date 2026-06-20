

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local CoinStore = DataStoreService:GetDataStore("PlayerCoins")


Players.PlayerAdded:Connect(function(player)

	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	
	local success, savedCoins = pcall(function()
		return CoinStore:GetAsync(player.UserId)
	end)

	if success and savedCoins ~= nil then
		coins.Value = savedCoins
		print(player.Name .. " loaded: " .. savedCoins .. " coins")
	else
		print(player.Name .. " is new or load failed — starting at 0")
	end
end)


Players.PlayerRemoving:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	pcall(function()
		CoinStore:SetAsync(player.UserId, coins.Value)
	end)
	print(player.Name .. " saved: " .. coins.Value)
end)


game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then continue end
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins then continue end
		pcall(function()
			CoinStore:SetAsync(player.UserId, coins.Value)
		end)
	end
end)



local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "CoinsFolder"
coinsFolder.Parent = workspace

local function spawnCoin(position)
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Ball
	coin.Size = Vector3.new(3, 3, 3)
	coin.BrickColor = BrickColor.new("Bright yellow")
	coin.Material = Enum.Material.Neon
	coin.Anchored = true
	coin.CanCollide = false
	coin.CFrame = CFrame.new(position)
	coin.Parent = coinsFolder

	
	local spinConnection = RunService.Heartbeat:Connect(function(dt)
		coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(90) * dt, 0)
	end)

	
	local pulseTween = TweenService:Create(
		coin,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Size = Vector3.new(3.6, 3.6, 3.6)}
	)
	pulseTween:Play()


	local collected = false

	coin.Touched:Connect(function(hit)
		if collected then return end

		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		collected = true

		
		spinConnection:Disconnect()
		pulseTween:Cancel()

		
		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then return end
		local playerCoins = leaderstats:FindFirstChild("Coins")
		if not playerCoins then return end

		playerCoins.Value += 10
		print(player.Name .. " collected a coin! Total: " .. playerCoins.Value)

		
		local collectTween = TweenService:Create(
			coin,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = Vector3.new(0, 0, 0), Transparency = 1}
		)
		collectTween:Play()

		collectTween.Completed:Connect(function()
			coin:Destroy()
		end)

		
		task.delay(5, function()
			local x = math.random(-40, 40)
			local z = math.random(-40, 40)
			spawnCoin(Vector3.new(x, 2, z))
		end)
	end)
end


local coinPositions = {
	Vector3.new(10, 2, 10),
	Vector3.new(-10, 2, 10),
	Vector3.new(10, 2, -10),
	Vector3.new(-10, 2, -10),
	Vector3.new(0, 2, 20),
}

for _, pos in ipairs(coinPositions) do
	spawnCoin(pos)
end



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyItem = ReplicatedStorage:WaitForChild("BuyItem")


local SHOP_ITEMS = {
	SpeedBoost = 50,
}

local speedBoostExpiry = {}
local BOOST_SPEED = 26
local DEFAULT_SPEED = 16
local BOOST_DURATION = 10

local function applySpeedBoost(player)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	humanoid.WalkSpeed = BOOST_SPEED
	speedBoostExpiry[player] = tick() + BOOST_DURATION
end


task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local expiry = speedBoostExpiry[player]
			if expiry and tick() > expiry then
				local character = player.Character
				if character then
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = DEFAULT_SPEED
					end
				end
				speedBoostExpiry[player] = nil
			end
		end
	end
end)


BuyItem.OnServerEvent:Connect(function(player, itemName)
	local price = SHOP_ITEMS[itemName]
	if not price then return end  

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	if coins.Value < price then
		BuyItem:FireClient(player, "fail", itemName)
		return
	end

	coins.Value -= price
	applySpeedBoost(player)
	BuyItem:FireClient(player, "success", itemName)
	print(player.Name .. " bought " .. itemName .. ". Coins left: " .. coins.Value)
end)


Players.PlayerRemoving:Connect(function(player)
	speedBoostExpiry[player] = nil
end)




local GetLeaderboard = ReplicatedStorage:WaitForChild("GetLeaderboard")

local function getLeaderboardData()
	local data = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local ls = p:FindFirstChild("leaderstats")
		if ls then
			local c = ls:FindFirstChild("Coins")
			if c then
				table.insert(data, {name = p.Name, coins = c.Value})
			end
		end
	end
	return data
end

GetLeaderboard.OnServerInvoke = function(player)
	local data = getLeaderboardData()
	table.sort(data, function(a, b)
		return a.coins > b.coins
	end)

	-- Trim to top 5 only
	local top5 = {}
	for i = 1, math.min(5, #data) do
		table.insert(top5, data[i])
	end

	return top5
end

local MAX_ALLOWED_SPEED = 30 

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.WalkSpeed > MAX_ALLOWED_SPEED then
					warn(player.Name .. " had WalkSpeed " .. humanoid.WalkSpeed .. " -- reset")
					humanoid.WalkSpeed = DEFAULT_SPEED
				end
			end
		end
	end
end)
