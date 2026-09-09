-- BARREL OF GUIDING LIGHT POTION ITEM
-- Inventory item that spawns automatically, drink to see doors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local DOOR_DETECT_RANGE = 500
local PATH_UPDATE_INTERVAL = 0.3
local POTION_EFFECT_DURATION = 30 -- seconds

-- Variables
local lastPathUpdateTime = 0
local nearestDoor = nil
local pathLine = nil
local potionActive = false
local potionEndTime = 0
local screenGui = nil

-- Inventory storage
local playerInventory = {
    {
        name = "Barrel of Guiding Light",
        type = "potion",
        icon = "✨",
        color = Color3.fromRGB(255, 215, 0),
        quantity = 1,
        effect = "reveals_doors"
    }
}

-- Function to create inventory GUI with potion
local function createInventoryBar()
    if screenGui then
        screenGui:Destroy()
    end
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PotionInventoryGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Inventory bar background
    local inventoryBar = Instance.new("Frame")
    inventoryBar.Name = "InventoryBar"
    inventoryBar.Size = UDim2.new(0, 120, 0, 100)
    inventoryBar.Position = UDim2.new(0, 20, 0.5, -50)
    inventoryBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    inventoryBar.BorderColor3 = Color3.fromRGB(255, 215, 0)
    inventoryBar.BorderSizePixel = 2
    inventoryBar.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
    title.BorderSizePixel = 0
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.Text = "INVENTORY"
    title.Parent = inventoryBar
    
    -- Potion item slot
    local potionSlot = Instance.new("Frame")
    potionSlot.Name = "PotionSlot"
    potionSlot.Size = UDim2.new(0, 80, 0, 60)
    potionSlot.Position = UDim2.new(0, 20, 0, 30)
    potionSlot.BackgroundColor3 = Color3.fromRGB(100, 60, 150)
    potionSlot.BorderColor3 = Color3.fromRGB(255, 215, 0)
    potionSlot.BorderSizePixel = 2
    potionSlot.Parent = inventoryBar
    
    -- Potion icon
    local potionIcon = Instance.new("TextLabel")
    potionIcon.Name = "PotionIcon"
    potionIcon.Size = UDim2.new(1, 0, 0.6, 0)
    potionIcon.Position = UDim2.new(0, 0, 0, 0)
    potionIcon.BackgroundTransparency = 1
    potionIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
    potionIcon.TextSize = 32
    potionIcon.Font = Enum.Font.GothamBold
    potionIcon.Text = "🏺"
    potionIcon.Parent = potionSlot
    
    -- Quantity indicator
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "Quantity"
    quantityLabel.Size = UDim2.new(1, 0, 0.4, 0)
    quantityLabel.Position = UDim2.new(0, 0, 0.6, 0)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    quantityLabel.TextSize = 10
    quantityLabel.Font = Enum.Font.Gotham
    quantityLabel.Text = "x" .. playerInventory[1].quantity
    quantityLabel.Parent = potionSlot
    
    -- Status indicator
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = potionActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 150, 150)
    statusLabel.TextSize = 10
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = potionActive and "ACTIVE ✓" or "CLICK TO USE"
    statusLabel.Parent = potionSlot
    
    -- Click to use potion
    potionSlot.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            usePotionBarrelOfGuidingLight()
            statusLabel.TextColor3 = potionActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(150, 150, 150)
            statusLabel.Text = potionActive and "ACTIVE ✓" or "CLICK TO USE"
        end
    end)
    
    return screenGui
end

-- Function to find nearest door
local function findNearestDoor()
    local nearestDoor = nil
    local nearestDistance = DOOR_DETECT_RANGE
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:match("Door") or obj.Name:match("door") or obj.Parent.Name:match("Door") then
            local objPos = obj:IsA("Part") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if objPos then
                local distance = (objPos - humanoidRootPart.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestDoor = obj
                end
            end
        end
    end
    
    return nearestDoor
end

-- Function to create path visualization
local function createPathLine(fromPos, toPos)
    if pathLine then
        pathLine:Destroy()
    end
    
    local pathLine = Instance.new("Part")
    pathLine.Name = "PathLine"
    pathLine.Shape = Enum.PartType.Block
    pathLine.Size = Vector3.new(0.5, 0.5, (fromPos - toPos).Magnitude)
    pathLine.Color = Color3.fromRGB(255, 215, 0) -- Gold
    pathLine.Material = Enum.Material.Neon
    pathLine.CanCollide = false
    pathLine.CFrame = CFrame.new((fromPos + toPos) / 2, toPos)
    pathLine.TopSurface = Enum.SurfaceType.Smooth
    pathLine.BottomSurface = Enum.SurfaceType.Smooth
    pathLine.Parent = workspace
    
    -- Remove after a few seconds
    game:GetService("Debris"):AddItem(pathLine, 2)
    
    return pathLine
end

-- Function to use Barrel of Guiding Light potion
function usePotionBarrelOfGuidingLight()
    if potionActive then
        potionActive = false
        print("🏺 Barrel of Guiding Light effect ended!")
    else
        potionActive = true
        potionEndTime = tick() + POTION_EFFECT_DURATION
        print("✨ You drank the Barrel of Guiding Light!")
        print("💡 Golden paths to doors revealed!")
    end
end

-- Main loop for potion effect
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Check if potion effect has expired
    if potionActive and tick() > potionEndTime then
        potionActive = false
        print("🏺 Barrel of Guiding Light effect wore off!")
    end
    
    if potionActive then
        local currentTime = tick()
        if currentTime - lastPathUpdateTime >= PATH_UPDATE_INTERVAL then
            lastPathUpdateTime = currentTime
            
            -- Find nearest door
            nearestDoor = findNearestDoor()
            
            if nearestDoor then
                local doorPos = nearestDoor:IsA("Part") and nearestDoor.Position or (nearestDoor.PrimaryPart and nearestDoor.PrimaryPart.Position)
                
                if doorPos then
                    local distance = (doorPos - humanoidRootPart.Position).Magnitude
                    
                    -- Create golden path visualization
                    createPathLine(humanoidRootPart.Position, doorPos)
                    
                    -- Auto-open door
                    local openValue = nearestDoor.Parent:FindFirstChild("Open")
                    if openValue and openValue:IsA("BoolValue") then
                        openValue.Value = true
                    end
                    
                    -- Make door passable
                    if nearestDoor:IsA("Part") then
                        nearestDoor.CanCollide = false
                        nearestDoor.Transparency = 0.3
                    end
                end
            end
        end
    end
end)

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    potionActive = false
end)

-- Create inventory bar on load
wait(0.5)
createInventoryBar()

print("🏺🏺🏺 BARREL OF GUIDING LIGHT LOADED! 🏺🏺🏺")
print("✨ Inventory item appears on left side")
print("🏺 CLICK the potion to drink it!")
print("💡 Golden paths to doors appear for 30 seconds")
print("🚪 Doors automatically open when active")
print("🎯 NO KEYBINDS - JUST CLICK THE ITEM!")
print("😎 Perfect for Hotel Minus navigation!")
