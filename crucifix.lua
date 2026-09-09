-- CRUCIFIX ANYTHING SCRIPT
-- Crucify all entities with ultimate power

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Settings
local CRUCIFIX_BUTTON = Enum.KeyCode.X -- Press X to crucifix nearby
local MASS_CRUCIFIX_BUTTON = Enum.KeyCode.C -- Press C for mass crucifix
local CRUCIFIX_RANGE = 300 -- Range for single crucifix
local MASS_CRUCIFIX_RANGE = 9999 -- Range for mass crucifix (entire map)
local AUTO_CRUCIFIX = true -- Auto-crucifix on spawn

-- Table to track crucified entities
local crucifiedEntities = {}

-- Function to crucifix entity
local function crucifyEntity(entity)
    if not entity or not entity.Parent or crucifiedEntities[entity] then return end
    
    local entityHumanoid = entity:FindFirstChild("Humanoid")
    if not entityHumanoid then return end
    
    -- Kill the entity
    entityHumanoid.WalkSpeed = 0
    entityHumanoid.JumpPower = 0
    entityHumanoid.Health = 0
    
    -- Visual effect - make them dark red (crucified)
    for _, part in pairs(entity:GetDescendants()) do
        if part:IsA("Part") then
            part.Color = Color3.fromRGB(139, 0, 0) -- Dark red
            part.CanCollide = false
        end
    end
    
    -- Add glow effect
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(139, 0, 0)
    light.Brightness = 2
    light.Range = 20
    light.Parent = entity:FindFirstChild("Head") or entity:FindFirstChildOfClass("Part")
    
    crucifiedEntities[entity] = true
    print("✝️ Entity " .. entity.Name .. " CRUCIFIED!")
end

-- Function to crucifix all nearby entities
local function crucifyNearby(range)
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:FindFirstChild("Humanoid") and obj.Parent ~= character then
            local objPos = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj
            if objPos then
                local distance = (objPos.Position - humanoidRootPart.Position).Magnitude
                if distance < range then
                    crucifyEntity(obj)
                    count = count + 1
                end
            end
        end
    end
    print("✝️ CRUCIFIED " .. count .. " ENTITIES!")
end

-- Function to mass crucify everything
local function massCrucifyAll()
    print("✝️✝️✝️ MASS CRUCIFY ACTIVATED! ✝️✝️✝️")
    crucifyNearby(MASS_CRUCIFIX_RANGE)
end

-- Function to crucifix on command
local function singleCrucifix()
    print("✝️ Crucifying nearby entities...")
    crucifyNearby(CRUCIFIX_RANGE)
end

-- Crucifix button (press X for nearby)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CRUCIFIX_BUTTON then
        singleCrucifix()
    elseif input.KeyCode == MASS_CRUCIFIX_BUTTON then
        massCrucifyAll()
    end
end)

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    crucifiedEntities = {}
end)

-- Auto-crucifix on spawn
if AUTO_CRUCIFIX then
    wait(1)
    print("✝️ Auto-crucifying all entities on spawn...")
    massCrucifyAll()
end

-- Continuous crucifix loop
RunService.Heartbeat:Connect(function()
    if not character or not humanoidRootPart then return end
    
    -- Keep crucified entities dead
    for entity, _ in pairs(crucifiedEntities) do
        if entity and entity.Parent then
            local entityHumanoid = entity:FindFirstChild("Humanoid")
            if entityHumanoid and entityHumanoid.Health > 0 then
                entityHumanoid.Health = 0
            end
        end
    end
end)

print("✝️✝️✝️ CRUCIFIX SCRIPT LOADED! ✝️✝️✝️")
print("✝️ Press X to crucifix nearby entities (300 stud range)")
print("✝️ Press C for MASS CRUCIFY (entire map!)")
print("✝️ Auto-crucify on spawn enabled!")
print("✝️ ALL ENTITIES WILL BE CRUCIFIED!")
