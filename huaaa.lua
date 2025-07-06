if game.PlaceId ~= 126884695634066 then return end
while not game:IsLoaded() do game.Loaded:Wait() end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Backpack = Players.LocalPlayer:WaitForChild("Backpack")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local BuySeedRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
local BuyGearRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
local BuyEggRemote = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEgg")
local EggData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild("EggData")
local autoBuySeed = false
local autoBuyGear = false


local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SmartPlantGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui") -- << INI FIXNYA
screenGui.Name = "SmartPlantGui"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Position = UDim2.new(1, -210, 0, 10)
frame.Size = UDim2.new(0, 200, 0, 195) -- Adjusted size to accommodate AI Plant button
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Visible = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 20)
title.Text = "Auto Farm By BmSky"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13

-- Input Jumlah
local amountBox = Instance.new("TextBox", frame)
amountBox.Size = UDim2.new(1, -20, 0, 24)
amountBox.Position = UDim2.new(0, 10, 0, 24)
amountBox.PlaceholderText = "Masukan jumlah tanam"
amountBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
amountBox.TextColor3 = Color3.new(1,1,1)
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 13

-- Tombol Start
local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(1, -20, 0, 24)
startBtn.Position = UDim2.new(0, 10, 0, 54)
startBtn.Text = "🌱 Start Plant"
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13

-- SavePos & DelPos
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Size = UDim2.new(0.5, -12, 0, 24)
saveBtn.Position = UDim2.new(0, 10, 0, 84)
saveBtn.Text = "💾 SavePos"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 140)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 13

local delBtn = Instance.new("TextButton", frame)
delBtn.Size = UDim2.new(0.5, -12, 0, 24)
delBtn.Position = UDim2.new(0.5, 2, 0, 84)
delBtn.Text = "❌ DelPos"
delBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
delBtn.TextColor3 = Color3.new(1,1,1)
delBtn.Font = Enum.Font.Gotham
delBtn.TextSize = 13

-- Pos Status
local posLabel = Instance.new("TextLabel", frame)
posLabel.Size = UDim2.new(1, -20, 0, 20)
posLabel.Position = UDim2.new(0, 10, 0, 114)
posLabel.Text = "📍 Pos: Tidak Ada Pos"
posLabel.TextColor3 = Color3.new(1,1,1)
posLabel.Font = Enum.Font.Gotham
posLabel.TextSize = 12
posLabel.BackgroundTransparency = 1

--- Main Feature Flags ---
local autoFollow = false
local originalPos = nil -- Stores the position before auto follow starts

-- Tambahan: AI Plant Button dan Logic
local aiPlantActive = false

-- Data Seed dan Lokasi
local seedMap = {
    Tomato = {"Apple", "Grape", "Green Apple"},
    Carrot = {"Feijoa", "Dragon Fruit", "Coconut", "Loquat"},
    ["Orange Tulip"] = {"Pepper", "Beanstalk", "Lily of the Valley", "Cacao", "Bell Pepper", "Prickly Pear"},
    Rafflesia = {"Mushroom"},
    Bamboo = {"Cantaloupe"},
}

local function findFarmPositionByPlant(plantName)
    local farm = workspace:FindFirstChild("Farm")
    if not farm then return nil end

    for _, f in ipairs(farm:GetChildren()) do
        local imp = f:FindFirstChild("Important")
        if imp and imp:FindFirstChild("Data") and imp.Data.Owner.Value == LocalPlayer.Name then
            local plants = imp:FindFirstChild("Plants_Physical")
            if not plants then continue end
            for _, plant in ipairs(plants:GetChildren()) do
                if plant.Name == plantName then
                    return plant:GetPivot().Position
                end
            end
        end
    end
    return nil
end

local eggNames = {}

if EggData and EggData:IsA("ModuleScript") then
	local success, data = pcall(require, EggData)
	if success and type(data) == "table" then
		for name, _ in pairs(data) do
			table.insert(eggNames, name)
		end
	end
end

local function getVisibleEggs()
	local foundEggs = {}
	local eggFolder = workspace:FindFirstChild("NPCS")
		and workspace.NPCS:FindFirstChild("Pet Stand")
		and workspace.NPCS["Pet Stand"]:FindFirstChild("EggLocations")

	if not eggFolder then return foundEggs end

	for _, eggModel in ipairs(eggFolder:GetChildren()) do
		if eggModel:IsA("Model") then
			table.insert(foundEggs, eggModel.Name)
		end
	end

	return foundEggs
end

-- Ambil daftar item seed & gear dari GUI toko
local function getAvailableItems()
    local items = {}

    local gearUI = PlayerGui:FindFirstChild("Gear_Shop")
    if gearUI and gearUI:FindFirstChild("Frame") and gearUI.Frame:FindFirstChild("ScrollingFrame") then
        for _, item in ipairs(gearUI.Frame.ScrollingFrame:GetChildren()) do
            local main = item:FindFirstChild("Main_Frame")
            if main and main:FindFirstChild("Stock_Text") then
                local stock = tonumber(main.Stock_Text.Text:match("%d+")) or 0
                if stock > 0 then
                    items[item.Name] = "Gear"
                end
            end
        end
    end

    local seedUI = PlayerGui:FindFirstChild("Seed_Shop")
    if seedUI and seedUI:FindFirstChild("Frame") and seedUI.Frame:FindFirstChild("ScrollingFrame") then
        for _, item in ipairs(seedUI.Frame.ScrollingFrame:GetChildren()) do
            local main = item:FindFirstChild("Main_Frame")
            if main and main:FindFirstChild("Stock_Text") then
                local stock = tonumber(main.Stock_Text.Text:match("%d+")) or 0
                if stock > 0 then
                    items[item.Name] = "Seed"
                end
            end
        end
    end

    return items
end

task.spawn(function()
	while task.wait(3) do
		if autoBuyEgg then
			local visibleEggs = getVisibleEggs()
			for _, visibleName in ipairs(visibleEggs) do
				for index, dataName in ipairs(eggNames) do
					if dataName == visibleName then
						BuyEggRemote:FireServer(index - 1)
						break
					end
				end
			end
		end
	end
end)

-- Loop pembelian otomatis
task.spawn(function()
    while task.wait(3) do -- refresh setiap 3 detik
        local availableItems = getAvailableItems()

        for name, category in pairs(availableItems) do
            if category == "Seed" and autoBuySeed then
                BuySeedRemote:FireServer(name)
            elseif category == "Gear" and autoBuyGear then
                BuyGearRemote:FireServer(name)
            end
        end
    end
end)

-- Cek dan Tanam Otomatis (versi fix: tanam semua seed + delay stabil)
local function checkAndPlantAI()
    while aiPlantActive do
        for location, seeds in pairs(seedMap) do
            local pos = findFarmPositionByPlant(location)
            if not pos then
                showNotify("Lokasi tanam tidak ditemukan: " .. location)
                continue
            end

            for _, seedName in ipairs(seeds) do
                -- Tanam semua tool seed dengan nama sesuai
                for _, tool in ipairs(Backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local pname = tool:FindFirstChild("Plant_Name")
                        local actualName = pname and pname.Value or tool.Name:match("^(.-) Seed")

                        if actualName == seedName then
                            Humanoid:EquipTool(tool)
                            task.wait(0.2)

                            -- Ambil jumlah seed dari nama tool (misal: Apple Seed [X5])
                            local jumlah = tonumber(tool.Name:match("%[X(%d+)%]")) or 1
                            if jumlah <= 0 then jumlah = 1 end

                            -- Simpan posisi awal
                            local origin = HRP.Position

                            -- Freeze kamera
                            Camera.CameraType = Enum.CameraType.Scriptable
                            Camera.CFrame = CFrame.new(origin + Vector3.new(0, 7, -10), origin)
                            RunService.RenderStepped:Wait()

                            -- Teleport ke posisi tanam
                            Character:PivotTo(CFrame.new(pos + Vector3.new(0, 2, 0)))
                            task.wait(0.3)

                            -- Tanam sebanyak jumlah yang ada
                            for i = 1, jumlah do
                                ReplicatedStorage.GameEvents.Plant_RE:FireServer(pos, seedName)
                                task.wait(0.3) -- delay per tanam biar tidak spam
                            end

                            -- Kembali ke posisi semula
                            Character:PivotTo(CFrame.new(origin + Vector3.new(0, 2, 0)))
                            Camera.CameraType = Enum.CameraType.Custom

                            task.wait(0.2)
                        end
                    end
                end
            end
        end
        task.wait(3) -- delay antar rotasi plant AI
    end
end

-- Notifikasi (Didefinisikan lebih awal karena digunakan oleh checkAndPlantAI)
local function showNotify(text)
	local notify = Instance.new("TextLabel", screenGui)
	notify.Size = UDim2.new(0, 200, 0, 24)
	notify.Position = UDim2.new(1, -210, 0, 210) -- Adjusted position
	notify.Text = "⚠ " .. text
	notify.TextColor3 = Color3.new(1,1,1)
	notify.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	notify.Font = Enum.Font.GothamBold
	notify.TextSize = 14
	task.delay(2, function() notify:Destroy() end)
end


-- Tombol AI Plant
local aiBtn = Instance.new("TextButton", frame)
aiBtn.Size = UDim2.new(1, -20, 0, 24)
aiBtn.Position = UDim2.new(0, 10, 0, 140) -- Positioned above Auto Follow
aiBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 170)
aiBtn.TextColor3 = Color3.new(1, 1, 1)
aiBtn.Font = Enum.Font.GothamBold
aiBtn.TextSize = 13
aiBtn.Text = "AI Plant: OFF"

aiBtn.MouseButton1Click:Connect(function()
    aiPlantActive = not aiPlantActive
    aiBtn.Text = aiPlantActive and "AI Plant: ON" or "AI Plant: OFF"
    aiBtn.BackgroundColor3 = aiPlantActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(90, 90, 170)

    if aiPlantActive then
        task.spawn(checkAndPlantAI)
    end
end)

-- Tombol Auto Buy Seed & Gear ke GUI
local buySeedBtn = Instance.new("TextButton", frame)
buySeedBtn.Size = UDim2.new(0.5, -12, 0, 24)
buySeedBtn.Position = UDim2.new(0, 10, 0, 200)
buySeedBtn.Text = "Buy Seed: OFF"
buySeedBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
buySeedBtn.TextColor3 = Color3.new(1,1,1)
buySeedBtn.Font = Enum.Font.Gotham
buySeedBtn.TextSize = 13

buySeedBtn.MouseButton1Click:Connect(function()
	autoBuySeed = not autoBuySeed
	buySeedBtn.Text = autoBuySeed and "Buy Seed: ON" or "Buy Seed: OFF"
	buySeedBtn.BackgroundColor3 = autoBuySeed and Color3.fromRGB(0,170,0) or Color3.fromRGB(60, 120, 60)
end)

local buyGearBtn = Instance.new("TextButton", frame)
buyGearBtn.Size = UDim2.new(0.5, -12, 0, 24)
buyGearBtn.Position = UDim2.new(0.5, 2, 0, 200)
buyGearBtn.Text = "Buy Gear OFF"
buyGearBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
buyGearBtn.TextColor3 = Color3.new(1,1,1)
buyGearBtn.Font = Enum.Font.Gotham
buyGearBtn.TextSize = 13

buyGearBtn.MouseButton1Click:Connect(function()
	autoBuyGear = not autoBuyGear
	buyGearBtn.Text = autoBuyGear and "Buy Gear: ON" or "Buy Gear: OFF"
	buyGearBtn.BackgroundColor3 = autoBuyGear and Color3.fromRGB(0,170,0) or Color3.fromRGB(120, 60, 60)
end)
-- Follow Logic - This function will run the auto follow behavior
local function startFollowLoop()
	originalPos = HRP.Position -- Capture current position when follow begins

	task.spawn(function()
		while autoFollow do
			local players = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					table.insert(players, p)
				end
			end

			if #players == 0 then
				-- If no players, return to the original position (farm area)
				if originalPos then
					Humanoid:MoveTo(originalPos)
					repeat
						task.wait(1)
						-- Recheck for players while waiting at original position
						players = {}
						for _, p in ipairs(Players:GetPlayers()) do
							if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
								table.insert(players, p)
							end
						end
					until not autoFollow or #players > 0
				else
					-- If originalPos isn't set, just wait for players to appear
					task.wait(2)
				end
			else
				local target = players[math.random(1, #players)] -- Pick a random player
				local arrived = false

				-- Move towards the target player
				repeat
					if not autoFollow then return end -- Stop if auto follow is turned off
					local tPos = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position
					if tPos then
						local distance = (HRP.Position - tPos).Magnitude
						if distance > 5 then -- If far, move closer
							Humanoid:MoveTo(tPos)
						else -- If close enough, consider arrived
							arrived = true
						end
					else
						-- Target player's character disappeared, break and find new target
						break
					end
					task.wait(0.1) -- Small delay to prevent excessive CPU usage
				until arrived or not autoFollow

				-- Once arrived, follow for 10 seconds
				local startFollowTime = tick()
				while tick() - startFollowTime < 10 and autoFollow do
					local tPos = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position
					if tPos then
						Humanoid:MoveTo(tPos)
					else
						-- Target player's character disappeared during follow, break
						break
					end
					task.wait(0.1)
				end
			end
		end
	end)

	-- Removed equipRandomTool from here as per request
end

-- Function to stop auto follow and reset character position
local function stopAutoFollow()
	if autoFollow then
		autoFollow = false
		btnFollow.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
		btnFollow.Text = "Auto Follow: OFF"
		Humanoid:Move(Vector3.zero, false) -- Stop humanoid movement
		if originalPos then
			-- Teleport back to the original position (where follow started)
			Character:PivotTo(CFrame.new(originalPos + Vector3.new(0, 2, 0)))
		end
	end
end

-- Auto Follow Button (Position adjusted)
local autoBuyEgg = false

-- Tombol GUI (letakkan ini di bawah tombol buy gear di GUI)
local buyEggBtn = Instance.new("TextButton", frame)
buyEggBtn.Size = UDim2.new(1, -20, 0, 24)
buyEggBtn.Position = UDim2.new(0, 10, 0, 230)
buyEggBtn.Text = "Buy Egg: OFF"
buyEggBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 60)
buyEggBtn.TextColor3 = Color3.new(1, 1, 1)
buyEggBtn.Font = Enum.Font.GothamBold
buyEggBtn.TextSize = 13

buyEggBtn.MouseButton1Click:Connect(function()
	autoBuyEgg = not autoBuyEgg
	buyEggBtn.Text = autoBuyEgg and "Buy Egg: ON" or "Buy Egg: OFF"
	buyEggBtn.BackgroundColor3 = autoBuyEgg and Color3.fromRGB(0,170,0) or Color3.fromRGB(120, 120, 60)
end)
local btnFollow = Instance.new("TextButton", frame)
btnFollow.Size = UDim2.new(1, -20, 0, 24)
btnFollow.Position = UDim2.new(0, 10, 0, 170) -- Adjusted position
btnFollow.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
btnFollow.TextColor3 = Color3.new(1, 1, 1)
btnFollow.Font = Enum.Font.GothamBold
btnFollow.TextSize = 13
btnFollow.Text = "Auto Follow: OFF"

btnFollow.MouseButton1Click:Connect(function()
	autoFollow = not autoFollow
	btnFollow.Text = autoFollow and "Auto Follow: ON" or "Auto Follow: OFF"
	btnFollow.BackgroundColor3 = autoFollow and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 120, 180)

	if autoFollow then
		startFollowLoop() -- Call the original startFollowLoop
	else
		Humanoid:Move(Vector3.zero, false) -- Stop movement immediately
		if originalPos then
			Character:PivotTo(CFrame.new(originalPos + Vector3.new(0, 2, 0))) -- Go back to original spot
		end
	end
end)

------------------------------

-- Toggle GUI
local closeBtn = Instance.new("TextButton", screenGui)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -26, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 24, 0, 24)
toggleBtn.Position = UDim2.new(1, -52, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
toggleBtn.Text = "○"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	closeBtn.Visible = frame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	stopAutoFollow() -- Ensure Auto Follow stops when GUI is closed
	screenGui:Destroy()
end)

-- Pos logic
local savedPosition = nil
local function updatePosLabel()
	if savedPosition then
		posLabel.Text = "📍 Pos: Saved Pos"
	else
		local tulip = workspace:FindFirstChild("Farm")
		local found = false
		if tulip then
			for _, f in ipairs(tulip:GetChildren()) do
				local imp = f:FindFirstChild("Important")
				if imp and imp:FindFirstChild("Data") and imp.Data.Owner.Value == LocalPlayer.Name then
					local plants = imp:FindFirstChild("Plants_Physical")
					if not plants then continue end
					for _, p in ipairs(plants:GetChildren()) do
						if p.Name == "Orange Tulip" then
							found = true
							break
						end
					end
				end
			end
		end
		posLabel.Text = found and "📍 Pos: Orange Tulip" or "📍 Pos: Tidak Ada Pos"
	end
end

saveBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		savedPosition = char.HumanoidRootPart.Position
		updatePosLabel()
	end
end)

delBtn.MouseButton1Click:Connect(function()
	savedPosition = nil
	updatePosLabel()
end)

-- Dapatkan posisi Orange Tulip
local function getOrangeTulipPos()
	local farm = workspace:FindFirstChild("Farm")
	if not farm then return nil end

	for _, f in ipairs(farm:GetChildren()) do
		local imp = f:FindFirstChild("Important")
		if imp and imp:FindFirstChild("Data") and imp.Data.Owner.Value == LocalPlayer.Name then
			local plants = imp:FindFirstChild("Plants_Physical")
			if not plants then continue end
			for _, plant in ipairs(plants:GetChildren()) do
				if plant.Name == "Orange Tulip" then
					return plant:GetPivot().Position
				end
			end
		end
	end
end

-- Ambil nama & jumlah seed
local function getHeldSeed()
	local char = LocalPlayer.Character
	if not char then return nil, 0 end

	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return nil, 0 end

	local name = tool:FindFirstChild("Plant_Name")
	name = name and name.Value or tool.Name:match("^(.-) Seed") or tool.Name
	local jumlah = tonumber(tool.Name:match("%[X(%d+)%]")) or 1

	return name, jumlah
end

-- Tanam
local function plantSeed()
	local seedName, count = getHeldSeed()
	if not seedName then
		showNotify("Harap pegang seed")
		return
	end

	local jumlah = tonumber(amountBox.Text)
	if not jumlah or jumlah <= 0 then
		showNotify("Masukkan jumlah valid")
		return
	end

	if jumlah > count then
		showNotify("Seed kamu tidak cukup (punya: "..count..")")
		return
	end

	local pos = savedPosition or getOrangeTulipPos()
	if not pos then
		showNotify("Tanaman Orange Tulip tidak ada di kebunmu!")
		return
	end

	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Stop auto follow before planting
	stopAutoFollow()

	local origin = root.Position
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CFrame.new(origin + Vector3.new(0, 7, -10), origin)

	RunService.RenderStepped:Wait()
	char:PivotTo(CFrame.new(pos + Vector3.new(0, 2, 0)))
	task.wait(0.4)

	for i = 1, jumlah do
		ReplicatedStorage.GameEvents.Plant_RE:FireServer(pos, seedName)
		task.wait(0.2)
	end

	char:PivotTo(CFrame.new(origin + Vector3.new(0, 2, 0)))
	Camera.CameraType = Enum.CameraType.Custom
end

startBtn.MouseButton1Click:Connect(plantSeed)

-- Init
updatePosLabel()
