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
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local DinoMachineService_RE = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("DinoMachineService_RE")


local BuyPetEgg = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg")
local EggData = ReplicatedStorage:FindFirstChild("Data") and ReplicatedStorage.Data:FindFirstChild("EggData")


local autoBuySeed = false
local autoBuyGear = false
local autoBuyEgg = false
local autoClaimDinoEgg = false


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
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.Name = "SmartPlantGui"
screenGui.ResetOnSpawn = false

-- Outer Frame (to hold ScrollingFrame and top buttons)
local outerFrame = Instance.new("Frame", screenGui)
outerFrame.Position = UDim2.new(1, -210, 0, 10)
outerFrame.Size = UDim2.new(0, 200, 0, 320) -- Increased size to fit scrolling area + buttons
outerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
outerFrame.Visible = true
outerFrame.BorderSizePixel = 0

-- ScrollingFrame
local scrollingFrame = Instance.new("ScrollingFrame", outerFrame)
scrollingFrame.Size = UDim2.new(1, 0, 1, -30) -- Leave space for hide/close buttons at the top
scrollingFrame.Position = UDim2.new(0, 0, 0, 30) -- Start below the top buttons
scrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Automatically adjust canvas height
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.BackgroundTransparency = 1 -- Make background transparent to blend with outerFrame

-- Layout for items in ScrollingFrame
local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
uiListLayout.FillDirection = Enum.FillDirection.Vertical
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.Padding = UDim.new(0, 5) -- Add padding between elements
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Title
local title = Instance.new("TextLabel", scrollingFrame)
title.Size = UDim2.new(1, 0, 0, 20)
title.Text = "Auto Farm By BmSky"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.LayoutOrder = 1 -- Order in layout

-- Input Jumlah
local amountBox = Instance.new("TextBox", scrollingFrame)
amountBox.Size = UDim2.new(0.9, 0, 0, 24) -- Adjusted size to fit within scrolling frame with padding
amountBox.Position = UDim2.new(0.5, 0, 0, 0) -- Centered by UIListLayout
amountBox.AnchorPoint = Vector2.new(0.5, 0)
amountBox.PlaceholderText = "Masukan jumlah tanam"
amountBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
amountBox.TextColor3 = Color3.new(1,1,1)
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 13
amountBox.LayoutOrder = 2

-- Tombol Start
local startBtn = Instance.new("TextButton", scrollingFrame)
startBtn.Size = UDim2.new(0.9, 0, 0, 24)
startBtn.Position = UDim2.new(0.5, 0, 0, 0)
startBtn.AnchorPoint = Vector2.new(0.5, 0)
startBtn.Text = "🌱 Start Plant"
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 13
startBtn.LayoutOrder = 3

-- SavePos & DelPos
local saveDelFrame = Instance.new("Frame", scrollingFrame)
saveDelFrame.Size = UDim2.new(0.9, 0, 0, 24)
saveDelFrame.BackgroundTransparency = 1
saveDelFrame.LayoutOrder = 4

local uiListLayoutSaveDel = Instance.new("UIListLayout", saveDelFrame)
uiListLayoutSaveDel.FillDirection = Enum.FillDirection.Horizontal
uiListLayoutSaveDel.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayoutSaveDel.Padding = UDim.new(0, 5)

local saveBtn = Instance.new("TextButton", saveDelFrame)
saveBtn.Size = UDim2.new(0.5, -2.5, 0, 24) -- Adjusted for padding
saveBtn.Text = "💾 SavePos"
saveBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 140)
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.Font = Enum.Font.Gotham
saveBtn.TextSize = 13

local delBtn = Instance.new("TextButton", saveDelFrame)
delBtn.Size = UDim2.new(0.5, -2.5, 0, 24) -- Adjusted for padding
delBtn.Text = "❌ DelPos"
delBtn.BackgroundColor3 = Color3.fromRGB(140, 60, 60)
delBtn.TextColor3 = Color3.new(1,1,1)
delBtn.Font = Enum.Font.Gotham
delBtn.TextSize = 13

-- Pos Status
local posLabel = Instance.new("TextLabel", scrollingFrame)
posLabel.Size = UDim2.new(0.9, 0, 0, 20)
posLabel.Position = UDim2.new(0.5, 0, 0, 0)
posLabel.AnchorPoint = Vector2.new(0.5, 0)
posLabel.Text = "📍 Pos: Tidak Ada Pos"
posLabel.TextColor3 = Color3.new(1,1,1)
posLabel.Font = Enum.Font.Gotham
posLabel.TextSize = 12
posLabel.BackgroundTransparency = 1
posLabel.LayoutOrder = 5

--- Main Feature Flags ---
local autoFollow = false
local originalPos = nil -- Stores the position before auto follow starts

-- Utility: Equip random tool (Pindah ke atas agar bisa diakses oleh startFollowLoop)
local function equipRandomTool()
	local tools = {}
	for _, tool in ipairs(Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(tools, tool)
		end
	end
	if #tools > 0 then
		local randomTool = tools[math.random(1, #tools)]
		Humanoid:EquipTool(randomTool)
	end
end

-- Follow Logic (Pindah ke atas agar bisa diakses oleh btnFollow.MouseButton1Click)
local function startFollowLoop()
	originalPos = HRP.Position -- Capture current position when follow begins

	-- Loop untuk mengikuti player
	task.spawn(function()
		while autoFollow do
			local players = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					table.insert(players, p)
				end
			end

			if #players == 0 then
				-- Jika tidak ada player, kembali ke posisi awal (farm)
				if originalPos then
					Humanoid:MoveTo(originalPos)
					repeat
						task.wait(1)
						-- Cek ulang player saat menunggu di posisi awal
						players = {}
						for _, p in ipairs(Players:GetPlayers()) do
							if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
								table.insert(players, p)
							end
						end
					until not autoFollow or #players > 0
				else
					-- Jika originalPos belum diatur, tunggu saja player muncul
					task.wait(2)
				end
			else
				local target = players[math.random(1, #players)] -- Pilih player acak
				local arrived = false

				-- Bergerak menuju player target
				repeat
					if not autoFollow then return end -- Berhenti jika auto follow dimatikan
					local tPos = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position
					if tPos then
						local distance = (HRP.Position - tPos).Magnitude
						if distance > 5 then -- Jika jauh, bergerak mendekat
							Humanoid:MoveTo(tPos)
						else -- Jika cukup dekat, anggap sudah sampai
							arrived = true
						end
					else
						-- Karakter player target menghilang, keluar dan cari target baru
						break
					end
					task.wait(0.1) -- Delay kecil untuk mencegah penggunaan CPU berlebihan
				until arrived or not autoFollow

				-- Setelah sampai, ikuti selama 10 detik
				local startFollowTime = tick()
				while tick() - startFollowTime < 10 and autoFollow do
					local tPos = target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character.HumanoidRootPart.Position
					if tPos then
						Humanoid:MoveTo(tPos)
					else
						-- Karakter player target menghilang saat mengikuti, keluar
						break
					end
					task.wait(0.1)
				end
			end
		end
	end)

	-- Gonta-ganti tool tiap 1 detik
	task.spawn(function()
		while autoFollow do
			equipRandomTool()
			task.wait(1)
		end
	end)
end

-- Function to stop auto follow and reset character position
local function stopAutoFollow()
	if autoFollow then
		autoFollow = false
		-- Pastikan tombol diperbarui statusnya di UI
		local btnFollow = scrollingFrame:FindFirstChild("btnFollow") -- Temukan tombol auto follow di scrollingFrame
		if btnFollow then
			btnFollow.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
			btnFollow.Text = "Auto Follow: OFF"
		end
		Humanoid:Move(Vector3.zero, false) -- Hentikan pergerakan humanoid
		if originalPos then
			-- Teleport kembali ke posisi awal (tempat follow dimulai)
			Character:PivotTo(CFrame.new(originalPos + Vector3.new(0, 2, 0)))
		end
	end
end

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
    while task.wait(2) do
        if autoBuyEgg then
            for i = 1, 3 do
                pcall(function()
                    BuyPetEgg:FireServer(i)
                end)
                task.wait(0.2) -- Delay kecil antar egg slot
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
	notify.Size = UDim2.new(0, 300, 0, 30) -- Lebih besar sedikit biar enak dilihat
	notify.Position = UDim2.new(0.5, 0, 0.2, 0) -- Tengah horizontal, agak atas
	notify.AnchorPoint = Vector2.new(0.5, 0.5) -- Supaya posisi benar-benar di tengah titik label
	notify.Text = "⚠ " .. text
	notify.TextColor3 = Color3.new(1, 1, 1)
	notify.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	notify.Font = Enum.Font.GothamBold
	notify.TextSize = 16
	notify.TextStrokeTransparency = 0.5
	notify.TextStrokeColor3 = Color3.new(0, 0, 0)
	notify.BackgroundTransparency = 0.2
	notify.BorderSizePixel = 0
	notify.ZIndex = 999

	-- Opsional: animasi masuk/keluar
	notify.Visible = true
	notify.TextTransparency = 1
	notify.BackgroundTransparency = 1
	notify:TweenSizeAndPosition(
		UDim2.new(0, 300, 0, 30),
		UDim2.new(0.5, 0, 0.2, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.25,
		true
	)
	
	-- Fade in
	for i = 1, 10 do
		notify.TextTransparency = 1 - i * 0.1
		notify.BackgroundTransparency = 1 - i * 0.08
		task.wait(0.01)
	end

	task.delay(2, function()
		if notify and notify.Parent then
			notify:Destroy()
		end
	end)
end
-- Tombol AI Plant
local aiBtn = Instance.new("TextButton", scrollingFrame)
aiBtn.Size = UDim2.new(0.9, 0, 0, 24)
aiBtn.Position = UDim2.new(0.5, 0, 0, 0)
aiBtn.AnchorPoint = Vector2.new(0.5, 0)
aiBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 170)
aiBtn.TextColor3 = Color3.new(1, 1, 1)
aiBtn.Font = Enum.Font.GothamBold
aiBtn.TextSize = 13
aiBtn.Text = "AI Plant: OFF"
aiBtn.LayoutOrder = 6

aiBtn.MouseButton1Click:Connect(function()
    aiPlantActive = not aiPlantActive
    aiBtn.Text = aiPlantActive and "AI Plant: ON" or "AI Plant: OFF"
    aiBtn.BackgroundColor3 = aiPlantActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(90, 90, 170)

    if aiPlantActive then
        task.spawn(checkAndPlantAI)
    end
end)

--- Auto Follow Button (Pastikan nama ini unik)
local btnFollow = Instance.new("TextButton", scrollingFrame)
btnFollow.Name = "btnFollow" -- Berikan nama agar mudah ditemukan nanti
btnFollow.Size = UDim2.new(0.9, 0, 0, 24)
btnFollow.Position = UDim2.new(0.5, 0, 0, 0)
btnFollow.AnchorPoint = Vector2.new(0.5, 0)
btnFollow.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
btnFollow.TextColor3 = Color3.new(1, 1, 1)
btnFollow.Font = Enum.Font.GothamBold
btnFollow.TextSize = 13
btnFollow.Text = "Auto Follow: OFF"
btnFollow.LayoutOrder = 7

-- Logika Toggle Auto Follow untuk btnFollow
btnFollow.MouseButton1Click:Connect(function()
    autoFollow = not autoFollow
    btnFollow.Text = autoFollow and "Auto Follow: ON" or "Auto Follow: OFF"
    btnFollow.BackgroundColor3 = autoFollow and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 120, 180)

    if autoFollow then
        startFollowLoop()
    else
        stopAutoFollow()
    end
end)

-- Tombol Auto Buy Seed & Gear ke GUI
local buySeedGearFrame = Instance.new("Frame", scrollingFrame)
buySeedGearFrame.Size = UDim2.new(0.9, 0, 0, 24)
buySeedGearFrame.BackgroundTransparency = 1
buySeedGearFrame.LayoutOrder = 8

local uiListLayoutBuy = Instance.new("UIListLayout", buySeedGearFrame)
uiListLayoutBuy.FillDirection = Enum.FillDirection.Horizontal
uiListLayoutBuy.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayoutBuy.Padding = UDim.new(0, 5)

local buySeedBtn = Instance.new("TextButton", buySeedGearFrame)
buySeedBtn.Size = UDim2.new(0.5, -2.5, 0, 24)
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

local buyGearBtn = Instance.new("TextButton", buySeedGearFrame)
buyGearBtn.Size = UDim2.new(0.5, -2.5, 0, 24)
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

-- Tombol GUI (letakkan ini di bawah tombol buy gear di GUI)
local buyEggBtn = Instance.new("TextButton", scrollingFrame)
buyEggBtn.Size = UDim2.new(0.9, 0, 0, 24)
buyEggBtn.Position = UDim2.new(0.5, 0, 0, 0)
buyEggBtn.AnchorPoint = Vector2.new(0.5, 0)
buyEggBtn.Text = "Buy Egg: OFF"
buyEggBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 60)
buyEggBtn.TextColor3 = Color3.new(1, 1, 1)
buyEggBtn.Font = Enum.Font.GothamBold
buyEggBtn.TextSize = 13
buyEggBtn.LayoutOrder = 9

buyEggBtn.MouseButton1Click:Connect(function()
	autoBuyEgg = not autoBuyEgg
	buyEggBtn.Text = autoBuyEgg and "Buy Egg: ON" or "Buy Egg: OFF"
	buyEggBtn.BackgroundColor3 = autoBuyEgg and Color3.fromRGB(0,170,0) or Color3.fromRGB(120, 120, 60)
end)
-- Tombol Claim Egg Dino
local claimEggBtn = Instance.new("TextButton", scrollingFrame)
claimEggBtn.Size = UDim2.new(0.9, 0, 0, 24)
claimEggBtn.Position = UDim2.new(0.5, 0, 0, 0)
claimEggBtn.AnchorPoint = Vector2.new(0.5, 0)
claimEggBtn.Text = "ClaimEggDino: OFF"
claimEggBtn.BackgroundColor3 = Color3.fromRGB(100, 80, 130)
claimEggBtn.TextColor3 = Color3.new(1, 1, 1)
claimEggBtn.Font = Enum.Font.GothamBold
claimEggBtn.TextSize = 13
claimEggBtn.LayoutOrder = 10

claimEggBtn.MouseButton1Click:Connect(function()
	autoClaimDinoEgg = not autoClaimDinoEgg
	claimEggBtn.Text = autoClaimDinoEgg and "ClaimEggDino: ON" or "ClaimEggDino: OFF"
	claimEggBtn.BackgroundColor3 = autoClaimDinoEgg and Color3.fromRGB(0,170,0) or Color3.fromRGB(100, 80, 130)
end)

-- Tombol Submit Pet Dino (sekali klik)
local submitPetBtn = Instance.new("TextButton", scrollingFrame)
submitPetBtn.Size = UDim2.new(0.9, 0, 0, 24)
submitPetBtn.Position = UDim2.new(0.5, 0, 0, 0)
submitPetBtn.AnchorPoint = Vector2.new(0.5, 0)
submitPetBtn.Text = "SubmitPetDino"
submitPetBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 60)
submitPetBtn.TextColor3 = Color3.new(1, 1, 1)
submitPetBtn.Font = Enum.Font.GothamBold
submitPetBtn.TextSize = 13
submitPetBtn.LayoutOrder = 11

submitPetBtn.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if not character then return end

	local heldTool = character:FindFirstChildOfClass("Tool")
	if not heldTool then
		showNotify("harap pegang pet atau apapun itu!")
		return
	end

	pcall(function()
		DinoMachineService_RE:FireServer("MachineInteract")
		showNotify("✅ Pet berhasil disubmit!")
	end)
end)

--__________
-- LOOP AUTO BUY EGG (3 SLOT)
task.spawn(function()
    while task.wait(2) do
        if autoBuyEgg then
            print("[AUTO BUY EGG] Mulai beli egg...")
            for i = 1, 3 do
                pcall(function()
                    BuyPetEgg:FireServer(i)
                end)
                task.wait(0.2)
            end
        end
    end
end)

task.spawn(function()
	while task.wait(10) do
		if autoClaimDinoEgg then
			pcall(function()
				DinoMachineService_RE:FireServer("ClaimReward")
				print("[AUTO CLAIM] Egg event claimed.")
			end)
		end
	end
end)
------------------------------

-- Toggle GUI (diletakkan di outerFrame)
local closeBtn = Instance.new("TextButton", outerFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -26, 0, 3) -- Adjusted position
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14

local toggleBtn = Instance.new("TextButton", outerFrame)
toggleBtn.Size = UDim2.new(0, 24, 0, 24)
toggleBtn.Position = UDim2.new(1, -52, 0, 3) -- Adjusted position
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
toggleBtn.Text = "○"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

toggleBtn.MouseButton1Click:Connect(function()
	scrollingFrame.Visible = not scrollingFrame.Visible
    -- closeBtn (X) hanya terlihat jika scrollingFrame terlihat
    closeBtn.Visible = scrollingFrame.Visible
    -- toggleBtn (O) selalu terlihat
    toggleBtn.Visible = true 
    
    if not scrollingFrame.Visible then
        outerFrame.Size = UDim2.new(0, 50, 0, 30) -- Ukuran kecil saat disembunyikan
        outerFrame.Position = UDim2.new(1, -55, 0, 10) -- Geser agar tombol O berada di posisi yang tepat
    else
        outerFrame.Size = UDim2.new(0, 200, 0, 320) -- Ukuran asli saat ditampilkan
        outerFrame.Position = UDim2.new(1, -210, 0, 10)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
	stopAutoFollow() -- Memastikan Auto Follow berhenti saat GUI ditutup
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
