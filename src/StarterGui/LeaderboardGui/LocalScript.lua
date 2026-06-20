

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetLeaderboard = ReplicatedStorage:WaitForChild("GetLeaderboard")

local screenGui = script.Parent


local boardFrame = Instance.new("Frame")
boardFrame.Name = "BoardFrame"
boardFrame.Size = UDim2.new(0, 220, 0, 190)
boardFrame.Position = UDim2.new(1, -240, 0, 20)
boardFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
boardFrame.BackgroundTransparency = 0.1
boardFrame.BorderSizePixel = 0
boardFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
title.BorderSizePixel = 0
title.Text = "🏆 TOP 5"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = boardFrame

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, 0, 1, -30)
listFrame.Position = UDim2.new(0, 0, 0, 30)
listFrame.BackgroundTransparency = 1
listFrame.Parent = boardFrame

local function refreshLeaderboard()
	local data = GetLeaderboard:InvokeServer()

	
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	
	for i, entry in ipairs(data) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, 0, 0, 32)
		row.Position = UDim2.new(0, 0, 0, (i - 1) * 32)
		row.BackgroundTransparency = 1
		row.TextColor3 = (i == 1) and Color3.fromRGB(255, 215, 0) or Color3.new(1, 1, 1)
		row.Font = Enum.Font.Gotham
		row.TextScaled = true
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Text = "  " .. i .. ". " .. entry.name .. " — " .. entry.coins
		row.Parent = listFrame
	end
end

refreshLeaderboard()


while true do
	task.wait(5)
	refreshLeaderboard()
end
