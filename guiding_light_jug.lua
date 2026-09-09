-- GUIDING LIGHT JUG HOTBAR FOR HOTEL MINUS
-- Appears in hotbar, helps find and open doors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local HOTBAR_SLOT = 1 -- First slot in hotbar
local USE_JUG_BUTTON = Enum.KeyCode.One -- Press 1 to use jug
local DOOR_DETECT_RANGE = 500
local PATH_UPDATE_INTERVAL = 0.5

-- Variables
local lastPathUpdateTime = 0
local nearestDoor = nil
local pathLine = nil
local isJugActive = false

-- Function to create hotbar GUI
local function createHotbar()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Check if hotbar already exists
    if playerGui:FindFirstChild("HotbarGui") then
        return playerGui:FindFirstChild("HotbarGui")
    end
    
    local hotbarGui = Instance.new("ScreenGui")
    hotbarGui.Name = "HotbarGui"
    hotbarGui.ResetOnSpawn = false
    hotbarGui.Parent = playerGui
    
    -- Hotbar background
    local hotbarBackground = Instance.new("Frame")
    hotbarBackground.Name = "HotbarBackground"
    hotbarBackground.Size = UDim2.new(0, 400, 0, 80)
    hotbarBackground.Position = UDim2.new(0.5, -200, 1, -100)
    hotbarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    hotbarBackground.BorderColor3 = Color3.fromRGB(255, 215, 0)
    hotbarBackground.BorderSizePixel = 2
    hotbarBackground.Parent = hotbarGui
    
    -- Slot 1: Guiding Light Jug
    local jugSlot = Instance.new("Frame")
    jugSlot.Name = "JugSlot"
    jugSlot.Size = UDim2.new(0, 70, 0, 70)
    jugSlot.Position = UDim2.new(0, 10, 0, 5)
    jugSlot.BackgroundColor3 Color3.fromRGB(100, 60, 20)
    jugSlot.BorderColor3 = Color3.fromRGB(255, 215, 0)
    jugSlot.BorderSizePixel = 2
    jugSlot.Parent = hotbarBackground
    
    -- Jug icon
    local jugIcon = Instance.new("TextLabel")
    jugIcon.Name = "JugIcon"
    jugIcon.Size = UDim2.new(1, 0, 1, 0)
    jugIcon.BackgroundTransparency = 1
    jugIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
    jugIcon.TextSize = 40
    jugIcon.Font = Enum.Font.GothamBold
    jugIcon.Text = "🏺"
    jugIcon.Parent = jugSlot
    
    -- Item name
    local itemName = Instance.new("TextLabel")
    itemName.Name = "ItemName"
    itemName.Size = UDim2.new(0, 200, 0, 30)
    itemName.Position = UDim2.new(0, 90, 0, 10)
    itemName.BackgroundTransparency = 1
    itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemName.TextSize = 16
    itemName.Font = Enum.Font.Gotham
    itemName.TextXAlignment = Enum.TextXAlignment.Left
    itemName.Text = "Guiding Light Jug"
    itemName.Parent = hotbarBackground
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(0, 200, 0, 30)
    statusText.Position = UDim2.new(0, 90, 0, 40)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Text = "Press 1 to use • Find doors"
    statusText.Parent = hotbarBackground
    
    -- Click to use
    jugSlot.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            activateJug()
        end
    end)
    
    return hotbarGui
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
    pathLine.Size = Vector3.new(0.3, 0.3, (fromPos - toPos).Magnitude)
    pathLine.Color = Color3.fromRGB(255, 215, 0) -- Gold
    pathLine.Material = Enum.Material.Neon
    pathLine.CanCollide = false
    pathLine.CFrame = CFrame.new((fromPos + toPos) / 2, toPos)
    pathLine.Parent = workspace
    
    -- Remove after a few seconds
    game:GetService("Debris"):AddItem(pathLine, 2)
    
    return pathLine
end

-- Function to activate jug
function activateJug()
    if not isJugActive then
        isJugActive = true
        print("✨ Guiding Light Jug ACTIVATED!")
        print("🏺 Finding nearest door...")
    else
        isJugActive = false
        print("🏺 Guiding Light Jug DEACTIVATED!")
    end
end

-- Button to use jug
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == USE_JUG_BUTTON then
        activateJug()
    end
end)

-- Main loop for jug functionality
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart then return end
    
    if isJugActive then
        local currentTime = tick()
        if currentTime - lastPathUpdateTime >= PATH_UPDATE_INTERVAL then
            lastPathUpdateTime = currentTime
            
            -- Find nearest door
            nearestDoor = findNearestDoor()
            
            if nearestDoor then
                local doorPos = nearestDoor:IsA("Part") and nearestDoor.Position or (nearestDoor.PrimaryPart and nearestDoor.PrimaryPart.Position)
                
                if doorPos then
                    local distance = (doorPos - humanoidRootPart.Position).Magnitude
                    
                    -- Create path visualization
                    createPathLine(humanoidRootPart.Position, doorPos)
                    
                    -- Auto-open door
                    local openValue = nearestDoor.Parent:FindFirstChild("Open")
                    if openValue and openValue:IsA("BoolValue") then
                        openValue.Value = true
                    end
                    
                    -- Make door passable
                    if nearestDoor:IsA("Part") then
                        nearestDoor.CanCollide = false
                        nearestDoor.Transparency = 0.5
                    end
                    
                    print("🏺 Nearest door: " .. math.floor(distance) .. " studs away")
                    print("✨ Path shown with golden line")
                    print("🚪 Door opening...")
                end
            else
                print("🏺 No doors found within range!")
            end
        end
    end
end)

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    isJugActive = false
end)

-- Create hotbar
wait(0.5)
createHotbar()

print("🏺🏺🏺 GUIDING LIGHT JUG HOTBAR LOADED! 🏺🏺🏺")
print("✨ Hotbar appears at bottom of screen")
print("🏺 Press 1 to activate Guiding Light Jug")
print("✨ Shows golden path to nearest door")
print("🚪 Automatically opens and unblocks doors")
print("💡 Perfect for Hotel Minus!")
