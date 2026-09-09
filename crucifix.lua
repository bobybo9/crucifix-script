-- CRUCIFIX ITEM SCRIPT
-- Physical crucifix weapon with model, animation, and one-hit kill

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local EQUIP_BUTTON = Enum.KeyCode.E -- Press E to equip
local ATTACK_BUTTON = Enum.UserInputType.MouseButton1 -- Click to attack
local ATTACK_RANGE = 50
local ATTACK_COOLDOWN = 0.5
local CRUCIFIX_DAMAGE = 999999

-- Variables
local crucifixItem = nil
local isEquipped = false
local lastAttackTime = 0
local killedEntities = {}

-- Function to create crucifix model
local function createCrucifixModel(position)
    local crucifix = Instance.new("Model")
    crucifix.Name = "CrucifixWeapon"
    
    -- Main vertical post
    local verticalPost = Instance.new("Part")
    verticalPost.Name = "VerticalPost"
    verticalPost.Shape = Enum.PartType.Block
    verticalPost.Size = Vector3.new(0.3, 2, 0.3)
    verticalPost.Color = Color3.fromRGB(139, 69, 19) -- Brown
    verticalPost.CanCollide = false
    verticalPost.Parent = crucifix
    
    -- Horizontal crossbar
    local horizontalBar = Instance.new("Part")
    horizontalBar.Name = "HorizontalBar"
    horizontalBar.Shape = Enum.PartType.Block
    horizontalBar.Size = Vector3.new(1.2, 0.3, 0.3)
    horizontalBar.Color = Color3.fromRGB(139, 69, 19)
    horizontalBar.CanCollide = false
    horizontalBar.Parent = crucifix
    horizontalBar.Position = verticalPost.Position + Vector3.new(0, 0.4, 0)
    
    -- Top point (decorative)
    local topPoint = Instance.new("Part")
    topPoint.Name = "TopPoint"
    topPoint.Shape = Enum.PartType.Ball
    topPoint.Size = Vector3.new(0.2, 0.2, 0.2)
    topPoint.Color = Color3.fromRGB(255, 215, 0) -- Gold
    topPoint.CanCollide = false
    topPoint.Parent = crucifix
    topPoint.Position = verticalPost.Position + Vector3.new(0, 1.1, 0)
    
    -- Handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Shape = Enum.PartType.Block
    handle.Size = Vector3.new(0.2, 0.8, 0.2)
    handle.Color = Color3.fromRGB(101, 67, 33) -- Dark brown
    handle.CanCollide = false
    handle.Parent = crucifix
    handle.Position = verticalPost.Position + Vector3.new(0, -0.9, 0)
    
    -- Set primary part
    crucifix.PrimaryPart = verticalPost
    crucifix:SetPrimaryPartCFrame(CFrame.new(position))
    crucifix.Parent = workspace
    
    return crucifix
end

-- Function to equip crucifix
local function equipCrucifix()
    if isEquipped then
        print("✝️ Crucifix already equipped!")
        return
    end
    
    -- Create crucifix if it doesn't exist
    if not crucifixItem or not crucifixItem.Parent then
        crucifixItem = createCrucifixModel(humanoidRootPart.Position + Vector3.new(2, 0, 0))
    end
    
    -- Weld crucifix to player's hand
    local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if rightHand then
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = rightHand
        weld.Part1 = crucifixItem.PrimaryPart
        weld.Parent = crucifixItem.PrimaryPart
        
        isEquipped = true
        print("✝️ Crucifix EQUIPPED!")
    end
end

-- Function to unequip crucifix
local function unequipCrucifix()
    if not isEquipped then return end
    
    -- Remove weld
    for _, weld in pairs(crucifixItem.PrimaryPart:FindFirstChildOfClass("WeldConstraint") or {}) do
        weld:Destroy()
    end
    
    -- Drop crucifix
    crucifixItem.PrimaryPart.CanCollide = true
    isEquipped = false
    print("✝️ Crucifix UNEQUIPPED!")
end

-- Function to attack with crucifix
local function attackWithCrucifix()
    local currentTime = tick()
    if currentTime - lastAttackTime < ATTACK_COOLDOWN then return end
    
    if not isEquipped or not crucifixItem then return end
    
    lastAttackTime = currentTime
    
    print("✝️ CRUCIFIX ATTACK!")
    
    -- Swing animation
    local originalCFrame = crucifixItem.PrimaryPart.CFrame
    for i = 1, 5 do
        crucifixItem.PrimaryPart.CFrame = originalCFrame * CFrame.Angles(math.rad(20), 0, 0)
        wait(0.05)
    end
    crucifixItem.PrimaryPart.CFrame = originalCFrame
    
    -- Check for nearby entities to kill
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local objPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj
            if objPos then
                local distance = (objPos.Position - crucifixItem.PrimaryPart.Position).Magnitude
                if distance < ATTACK_RANGE then
                    local objHumanoid = obj:FindFirstChild("Humanoid")
                    if objHumanoid and not killedEntities[obj] then
                        objHumanoid.Health = 0
                        killedEntities[obj] = true
                        print("✝️ Entity CRUCIFIED by weapon!")
                        
                        -- Visual effect
                        for _, part in pairs(obj:GetDescendants()) do
                            if part:IsA("Part") then
                                part.Color = Color3.fromRGB(139, 0, 0)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Equip button (press E)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == EQUIP_BUTTON then
        if isEquipped then
            unequipCrucifix()
        else
            equipCrucifix()
        end
    end
end)

-- Attack button (click mouse)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == ATTACK_BUTTON then
        if isEquipped then
            attackWithCrucifix()
        end
    end
end)

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    isEquipped = false
    killedEntities = {}
    
    -- Respawn crucifix in world
    if crucifixItem and crucifixItem.Parent then
        crucifixItem.Parent = nil
    end
    crucifixItem = createCrucifixModel(humanoidRootPart.Position + Vector3.new(2, 0, 0))
end)

-- Spawn initial crucifix
wait(0.5)
crucifixItem = createCrucifixModel(humanoidRootPart.Position + Vector3.new(2, 0, 0))

print("✝️✝️✝️ CRUCIFIX ITEM SCRIPT LOADED! ✝️✝️✝️")
print("✝️ Press E to equip/unequip the crucifix weapon")
print("✝️ Click (Mouse Button 1) to attack with the crucifix")
print("✝️ Crucifix appears in the world - walk over it to pick it up!")
print("✝️ Swing animation on every attack")
print("✝️ One-hit KILL anything within 50 studs")
print("✝️ Entities turn dark red when crucified!")
print("😎 YOU HAVE A CRUCIFIX WEAPON NOW!")
