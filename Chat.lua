-- TINY TEST VERSION - PASTE THIS DIRECTLY INTO YOUR EXECUTOR

print("🔄 Starting chat test...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for player
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

print("✅ Player found:", LocalPlayer.Name)

-- Check HTTP
local httpRequest = (syn and syn.request) or (http and http.request) or 
                    http_request or (fluxus and fluxus.request) or request

if not httpRequest then
    print("❌ HTTP NOT SUPPORTED!")
    return
end

print("✅ HTTP supported")

-- Create simple GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChatTest"
screenGui.ResetOnSpawn = false

-- Try CoreGui first
pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)

-- Fallback to PlayerGui
if not screenGui.Parent then
    repeat task.wait() until LocalPlayer:FindFirstChild("PlayerGui")
    screenGui.Parent = LocalPlayer.PlayerGui
end

print("✅ GUI Parent:", screenGui.Parent.Name)

-- Simple frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(100, 200, 255)
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.Text = "💬 CHAT TEST"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = title

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 10)
titleFix.Position = UDim2.new(0, 0, 1, -10)
titleFix.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
titleFix.BorderSizePixel = 0
titleFix.Parent = title

-- Status text
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 100)
status.Position = UDim2.new(0, 10, 0, 60)
status.BackgroundTransparency = 1
status.Text = "✅ Chat is working!\n\nPlayer: " .. LocalPlayer.Name .. "\nHTTP: Ready"
status.TextColor3 = Color3.fromRGB(100, 255, 100)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 80, 0, 35)
closeBtn.Position = UDim2.new(0.5, -40, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Text = "CLOSE"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("💬 Test closed")
end)

print("✅ GUI CREATED AND VISIBLE!")
print("═══════════════════════════════════════")
print("If you see a blue box on screen, it works!")
print("═══════════════════════════════════════")
