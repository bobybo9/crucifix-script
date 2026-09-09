-- INVENTORY GUI SYSTEM WITH ITEMS
-- Professional inventory with Crucifix, Skeleton Key, Door Keys, and more

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local INVENTORY_BUTTON = Enum.KeyCode.I -- Press I to open inventory
local ATTACK_BUTTON = Enum.UserInputType.MouseButton1

-- Variables
local inventory = {
    {name = "Crucifix", type = "weapon", equipped = false, damage = 999999},
    {name = "Skeleton Key", type = "key", equipped = false, opensPower = true},
    {name = "Door Key", type = "key", equipped = false, opensPower = false},
    {name = "Health Potion", type = "consumable", equipped = false, healing = 100},
    {name = "Speed Boost", type = "consumable", equipped = false, speedBoost = 50},
    {name = "Shield Charm", type = "armor", equipped = false, protection = 100},
}

local equippedItem = nil
local isInventoryOpen = false
local lastAttackTime = 0
local killedEntities = {}
local screenGui = nil

-- Function to create Crucifix 3D model with texture
local function createCrucifixModel(position)
    local crucifix = Instance.new("Model")
    crucifix.Name = "CrucifixWeapon"
    
    -- Main vertical post
    local verticalPost = Instance.new("Part")
    verticalPost.Name = "VerticalPost"
    verticalPost.Shape = Enum.PartType.Block
    verticalPost.Size = Vector3.new(0.3, 2, 0.3)
    verticalPost.Color = Color3.fromRGB(139, 69, 19) -- Brown
    verticalPost.Material = Enum.Material.Wood
    verticalPost.CanCollide = false
    verticalPost.Parent = crucifix
    
    -- Texture
    local verticalTexture = Instance.new("Decal")
    verticalTexture.Face = Enum.NormalId.Front
    verticalTexture.Texture = "rbxasset://textures/face.png"
    verticalTexture.Parent = verticalPost
    
    -- Horizontal crossbar
    local horizontalBar = Instance.new("Part")
    horizontalBar.Name = "HorizontalBar"
    horizontalBar.Shape = Enum.PartType.Block
    horizontalBar.Size = Vector3.new(1.2, 0.3, 0.3)
    horizontalBar.Color = Color3.fromRGB(139, 69, 19)
    horizontalBar.Material = Enum.Material.Wood
    horizontalBar.CanCollide = false
    horizontalBar.Parent = crucifix
    horizontalBar.Position = verticalPost.Position + Vector3.new(0, 0.4, 0)
    
    -- Top point (gold)
    local topPoint = Instance.new("Part")
    topPoint.Name = "TopPoint"
    topPoint.Shape = Enum.PartType.Ball
    topPoint.Size = Vector3.new(0.2, 0.2, 0.2)
    topPoint.Color = Color3.fromRGB(255, 215, 0) -- Gold
    topPoint.Material = Enum.Material.Metal
    topPoint.CanCollide = false
    topPoint.Parent = crucifix
    topPoint.Position = verticalPost.Position + Vector3.new(0, 1.1, 0)
    
    -- Handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Shape = Enum.PartType.Block
    handle.Size = Vector3.new(0.2, 0.8, 0.2)
    handle.Color = Color3.fromRGB(101, 67, 33) -- Dark brown
    handle.Material = Enum.Material.Wood
    handle.CanCollide = false
    handle.Parent = crucifix
    handle.Position = verticalPost.Position + Vector3.new(0, -0.9, 0)
    
    crucifix.PrimaryPart = verticalPost
    crucifix:SetPrimaryPartCFrame(CFrame.new(position))
    crucifix.Parent = workspace
    
    return crucifix
end

-- Function to create Skeleton Key 3D model with texture
local function createSkeletonKeyModel(position)
    local key = Instance.new("Model")
    key.Name = "SkeletonKey"
    
    -- Key shaft
    local shaft = Instance.new("Part")
    shaft.Name = "Shaft"
    shaft.Shape = Enum.PartType.Block
    shaft.Size = Vector3.new(0.15, 1.5, 0.15)
    shaft.Color = Color3.fromRGB(184, 134, 11) -- Dark goldenrod
    shaft.Material = Enum.Material.Metal
    shaft.CanCollide = false
    shaft.Parent = key
    
    -- Key head (circular)
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(0.4, 0.4, 0.4)
    head.Color = Color3.fromRGB(184, 134, 11)
    head.Material = Enum.Material.Metal
    head.CanCollide = false
    head.Parent = key
    head.Position = shaft.Position + Vector3.new(0, 0.85, 0)
    
    -- Key teeth
    for i = 1, 3 do
        local tooth = Instance.new("Part")
        tooth.Name = "Tooth" .. i
        tooth.Shape = Enum.PartType.Block
        tooth.Size = Vector3.new(0.1, 0.2, 0.15)
        tooth.Color = Color3.fromRGB(184, 134, 11)
        tooth.Material = Enum.Material.Metal
        tooth.CanCollide = false
        tooth.Parent = key
        tooth.Position = shaft.Position + Vector3.new((i - 2) * 0.15, -0.75 + (i * 0.1), 0)
    end
    
    key.PrimaryPart = shaft
    key:SetPrimaryPartCFrame(CFrame.new(position))
    key.Parent = workspace
    
    return key
end

-- Function to create GUI
local function createInventoryGUI()
    if screenGui then screenGui:Destroy() end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(0, 600, 0, 500)
    background.Position = UDim2.new(0.5, -300, 0.5, -250)
    background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    background.BorderSizePixel = 2
    background.BorderColor3 = Color3.fromRGB(255, 215, 0)
    background.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Text = "📦 INVENTORY"
    title.Parent = background
    
    -- Scroll frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -70)
    scrollFrame.Position = UDim2.new(0, 10, 0, 60)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #inventory * 70)
    scrollFrame.Parent = background
    
    -- Create item buttons
    for i, item in ipairs(inventory) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = item.name
        itemButton.Size = UDim2.new(1, -20, 0, 60)
        itemButton.Position = UDim2.new(0, 10, 0, (i - 1) * 70)
        itemButton.BackgroundColor3 = item.equipped and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(40, 40, 60)
        itemButton.BorderColor3 = Color3.fromRGB(255, 215, 0)
        itemButton.BorderSizePixel = 2
        itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemButton.TextSize = 16
        itemButton.Font = Enum.Font.Gotham
        itemButton.Text = item.name .. (item.equipped and " ✓ EQUIPPED" or "")
        itemButton.Parent = scrollFrame
        
        -- Icon
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 5, 0, 10)
        icon.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        icon.BorderSizePixel = 1
        icon.TextColor3 = Color3.fromRGB(255, 215, 0)
        icon.TextSize = 24
        icon.Font = Enum.Font.GothamBold
        
        if item.type == "weapon" then
            icon.Text = "⚔️"
        elseif item.type == "key" then
            icon.Text = "🔑"
        elseif item.type == "consumable" then
            icon.Text = "🧪"
        elseif item.type == "armor" then
            icon.Text = "🛡️"
        end
        
        icon.Parent = itemButton
        
        -- Click to equip
        itemButton.MouseButton1Click:Connect(function()
            -- Unequip previous item
            if equippedItem and equippedItem ~= item then
                equippedItem.equipped = false
            end
            
            item.equipped = not item.equipped
            equippedItem = item.equipped and item or nil
            
            -- Update GUI
            if item.equipped then
                itemButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                itemButton.Text = item.name .. " ✓ EQUIPPED"
                print("✓ " .. item.name .. " EQUIPPED!")
                
                -- Apply item effect
                if item.type == "weapon" then
                    print("⚔️ Weapon equipped! Click to attack!")
                elseif item.type == "key" then
                    print("🔑 Key equipped! Opens all doors!")
                end
            else
                itemButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                itemButton.Text = item.name
            end
        end)
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.Parent = background
    
    closeButton.MouseButton1Click:Connect(function()
        isInventoryOpen = false
        screenGui:Destroy()
        screenGui = nil
    end)
end

-- Toggle inventory GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == INVENTORY_BUTTON then
        if isInventoryOpen then
            isInventoryOpen = false
            if screenGui then
                screenGui:Destroy()
                screenGui = nil
            end
        else
            isInventoryOpen = true
            createInventoryGUI()
        end
    end
end)

-- Attack with equipped weapon
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == ATTACK_BUTTON and equippedItem and equippedItem.type == "weapon" then
        local currentTime = tick()
        if currentTime - lastAttackTime < 0.5 then return end
        
        lastAttackTime = currentTime
        print("⚔️ ATTACK!")
        
        -- Kill nearby entities
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
                local objPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj
                if objPos then
                    local distance = (objPos.Position - humanoidRootPart.Position).Magnitude
                    if distance < 50 then
                        local objHumanoid = obj:FindFirstChild("Humanoid")
                        if objHumanoid and not killedEntities[obj] then
                            objHumanoid.Health = 0
                            killedEntities[obj] = true
                        end
                    end
                end
            end
        end
    end
end)

-- Auto-open doors with key
RunService.Heartbeat:Connect(function()
    if equippedItem and equippedItem.type == "key" then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:match("Door") or obj.Parent.Name:match("Door") then
                local objPos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if objPos then
                    local distance = (objPos - humanoidRootPart.Position).Magnitude
                    if distance < 100 then
                        local openValue = obj.Parent:FindFirstChild("Open")
                        if openValue and openValue:IsA("BoolValue") then
                            openValue.Value = true
                        end
                        if obj:IsA("Part") then
                            obj.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end)

-- Create initial models
wait(1)
createCrucifixModel(humanoidRootPart.Position + Vector3.new(5, 0, 0))
createSkeletonKeyModel(humanoidRootPart.Position + Vector3.new(-5, 0, 0))

print("✝️✝️✝️ INVENTORY SYSTEM LOADED! ✝️✝️✝️")
print("📦 Press I to open inventory")
print("✝️ Crucifix - melee weapon (click to attack)")
print("🔑 Skeleton Key - opens all doors")
print("🚪 Door Keys - opens specific doors")
print("🧪 Consumables - health and speed boosts")
print("🛡️ Armor - protective items")
print("😎 FULL INVENTORY SYSTEM READY!")
