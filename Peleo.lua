local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local connections = {}

local WalkSpeed = 16
local JumpHeight = 7.2
local GodMode = false

local function notify(text)
    print(text)  -- Mira en F9!
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = text; Color = Color3.fromRGB(0, 255, 0); Font = Enum.Font.Code; FontSize = Enum.FontSize.Size18;
        })
    end)
end

local function applyToHumanoid(humanoid)
    -- Limpia viejos connections
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    -- Fuerza JumpHeight moderno
    humanoid.UseJumpPower = false
    humanoid.JumpHeight = JumpHeight
    humanoid.JumpPower = 50 * math.sqrt(JumpHeight / 7.2)  -- Compat legacy
    
    if GodMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        -- God PRO: Reset si te dañan
        local healthConn = humanoid.HealthChanged:Connect(function(health)
            if health < math.huge then
                humanoid.Health = math.huge
            end
        end)
        table.insert(connections, healthConn)
    end
    
    -- Loop ANTI-RESET: Stepped (stealth)
    local steppedConn = RunService.Stepped:Connect(function()
        if not humanoid.Parent then return end
        humanoid.WalkSpeed = WalkSpeed
        humanoid.JumpHeight = JumpHeight
        humanoid.JumpPower = 50 * math.sqrt(JumpHeight / 7.2)
        if GodMode then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end)
    table.insert(connections, steppedConn)
    
    notify("✅ Aplicado! Speed: " .. WalkSpeed .. " | Salto: " .. JumpHeight .. " | God: " .. tostring(GodMode))
end

local function onCharacterAdded(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if humanoid then
        applyToHumanoid(humanoid)
    end
end

-- Actual
if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Teclas (mismas)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Equals then
        WalkSpeed = math.max(16, WalkSpeed + 4)
        notify("🚀 Speed: " .. WalkSpeed)
    elseif input.KeyCode == Enum.KeyCode.Minus then
        WalkSpeed = math.max(16, WalkSpeed - 4)
        notify("🐌 Speed: " .. WalkSpeed)
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        JumpHeight = JumpHeight + 1
        notify("🦘 Salto: " .. JumpHeight)
    elseif input.KeyCode == Enum.KeyCode.LeftBracket then
        JumpHeight = math.max(7.2, JumpHeight - 1)
        notify("⬇️ Salto: " .. JumpHeight)
    elseif input.KeyCode == Enum.KeyCode.G then
        GodMode = not GodMode
        notify("🛡️ God: " .. (GodMode and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.R then
        WalkSpeed = 16
        JumpHeight = 7.2
        GodMode = false
        notify("🔄 Reset!")
    end
end)

notify("🎮 V2 CARGADO! F9 para debug. = - [ ] G R")
