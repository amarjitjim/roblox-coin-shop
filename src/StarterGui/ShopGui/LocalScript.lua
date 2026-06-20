

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local BuyItem = ReplicatedStorage:WaitForChild("BuyItem")



local screenGui = script.Parent


local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(0, 120, 0, 40)
shopButton.Position = UDim2.new(0, 20, 0, 20)
shopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopButton.TextColor3 = Color3.new(1, 1, 1)
shopButton.Text = "Shop"
shopButton.Font = Enum.Font.GothamBold
shopButton.TextScaled = true
shopButton.Parent = screenGui


local shopPanel = Instance.new("Frame")
shopPanel.Name = "ShopPanel"
shopPanel.Size = UDim2.new(0, 200, 0, 180)
shopPanel.Position = UDim2.new(1, 20, 0.3, 0)  -- off-screen right
shopPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
shopPanel.BorderSizePixel = 0
shopPanel.Parent = screenGui


local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "SHOP"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextScaled = true
titleLabel.BorderSizePixel = 0
titleLabel.Parent = shopPanel


local buyButton = Instance.new("TextButton")
buyButton.Name = "BuyButton"
buyButton.Size = UDim2.new(0.8, 0, 0, 50)
buyButton.Position = UDim2.new(0.1, 0, 0, 60)
buyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
buyButton.TextColor3 = Color3.new(1, 1, 1)
buyButton.Text = "Speed Boost\n50 coins / 10 sec"
buyButton.Font = Enum.Font.GothamBold
buyButton.TextScaled = true
buyButton.BorderSizePixel = 0
buyButton.Parent = shopPanel


local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, 120)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
statusLabel.Text = ""
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.Parent = shopPanel


local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BorderSizePixel = 0
closeButton.Parent = shopPanel


local OPEN_POS  = UDim2.new(0.72, 0, 0.3, 0)
local CLOSED_POS = UDim2.new(1, 20, 0.3, 0)
local slideInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

shopButton.Activated:Connect(function()
	TweenService:Create(shopPanel, slideInfo, {Position = OPEN_POS}):Play()
end)

closeButton.Activated:Connect(function()
	TweenService:Create(shopPanel, slideInfo, {Position = CLOSED_POS}):Play()
end)



local debounce = false

buyButton.Activated:Connect(function()
	if debounce then return end
	debounce = true
	buyButton.Text = "Buying..."
	BuyItem:FireServer("SpeedBoost")
end)


BuyItem.OnClientEvent:Connect(function(result, itemName)
	debounce = false

	if result == "success" then
		buyButton.Text = "Speed Boost\n50 coins / 10 sec"
		statusLabel.Text = "Boost active!"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		buyButton.Text = "Speed Boost\n50 coins / 10 sec"
		statusLabel.Text = "Not enough coins"
		statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end

	
	task.delay(2, function()
		statusLabel.Text = ""
	end)
end)
