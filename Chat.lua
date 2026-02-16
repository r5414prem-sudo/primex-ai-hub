-- ═══════════════════════════════════════════════════════════
--  💬 UNIVERSAL CROSS-GAME CHAT - MOBILE OPTIMIZED
--  Version 3.1 - FIXED FOR MOBILE
-- ═══════════════════════════════════════════════════════════

print("🔄 Loading Universal Chat...")

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Wait for player to load
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ⚙️ CONFIGURATION
local CONFIG = {
    SERVER_URL = "https://roblox-chat-server-z35g.onrender.com",
    UPDATE_INTERVAL = 3,
    MAX_MESSAGE_LENGTH = 500,
}

-- Detect mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

print("📱 Mobile detected:", isMobile)

-- HTTP REQUEST CHECK
local httpRequest = (syn and syn.request) or (http and http.request) or 
                    http_request or (fluxus and fluxus.request) or request

if not httpRequest then
    warn("⚠️ HTTP not supported!")
    LocalPlayer:Kick("Your executor doesn't support HTTP requests!")
    return
end

print("✅ HTTP supported")

-- STATE
local State = {
    lastMessageTime = 0,
    isMinimized = false,
    currentGame = "Unknown Game"
}

-- Get game name
pcall(function()
    State.currentGame = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- ═══════════════════════════════════════════════════════════
--  🎨 CREATE GUI
-- ═══════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalChatMobile"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Try CoreGui first, fallback to PlayerGui
local success = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)

if not success or not screenGui.Parent then
    repeat task.wait() until LocalPlayer:FindFirstChild("PlayerGui")
    screenGui.Parent = LocalPlayer.PlayerGui
end

print("✅ GUI created in:", screenGui.Parent.Name)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = isMobile and UDim2.new(0.92, 0, 0.65, 0) or UDim2.new(0, 400, 0, 550)
mainFrame.Position = isMobile and UDim2.new(0.04, 0, 0.17, 0) or UDim2.new(0.5, -200, 0.5, -275)
mainFrame.AnchorPoint = isMobile and Vector2.new(0, 0) or Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, isMobile and 28 or 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

print("✅ Main frame created")

-- ═══════════════════════════════════════════════════════════
--  📱 TITLE BAR
-- ═══════════════════════════════════════════════════════════

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, isMobile and 80 or 60)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, isMobile and 28 or 20)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, isMobile and 20 or 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "💬 Universal Chat"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = isMobile and 24 or 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, isMobile and 60 or 40, 0, isMobile and 60 or 40)
closeBtn.Position = UDim2.new(1, isMobile and -70 or -50, 0.5, isMobile and -30 or -20)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = isMobile and 28 or 20
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, isMobile and 15 or 10)
closeBtnCorner.Parent = closeBtn

print("✅ Title bar created")

-- ═══════════════════════════════════════════════════════════
--  💬 CHAT AREA
-- ═══════════════════════════════════════════════════════════

local chatContainer = Instance.new("Frame")
chatContainer.Size = UDim2.new(1, -20, 1, isMobile and -180 or -150)
chatContainer.Position = UDim2.new(0, 10, 0, isMobile and 90 or 70)
chatContainer.BackgroundTransparency = 1
chatContainer.Parent = mainFrame

local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Size = UDim2.new(1, 0, 1, 0)
chatFrame.BackgroundTransparency = 1
chatFrame.BorderSizePixel = 0
chatFrame.ScrollBarThickness = isMobile and 8 : 6
chatFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 120, 220)
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatFrame.Parent = chatContainer

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, isMobile and 16 : 12)
chatLayout.Parent = chatFrame

print("✅ Chat area created")

-- ═══════════════════════════════════════════════════════════
--  ⌨️ INPUT AREA
-- ═══════════════════════════════════════════════════════════

local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(1, -20, 0, isMobile and 90 : 70)
inputContainer.Position = UDim2.new(0, 10, 1, isMobile and -100 : -80)
inputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
inputContainer.BorderSizePixel = 0
inputContainer.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, isMobile and 22 : 16)
inputCorner.Parent = inputContainer

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, isMobile and -100 : -80, 1, -20)
textBox.Position = UDim2.new(0, 15, 0, 10)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.PlaceholderText = "Type message..."
textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = isMobile and 18 : 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.Parent = inputContainer

-- Send Button
local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, isMobile and 70 : 60, 0, isMobile and 70 : 56)
sendBtn.Position = UDim2.new(1, isMobile and -80 : -68, 0.5, isMobile and -35 : -28)
sendBtn.BackgroundColor3 = Color3.fromRGB(100, 120, 220)
sendBtn.Text = "➤"
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = isMobile and 28 : 22
sendBtn.BorderSizePixel = 0
sendBtn.Parent = inputContainer

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, isMobile and 20 : 14)
sendCorner.Parent = sendBtn

print("✅ Input area created")

-- ═══════════════════════════════════════════════════════════
--  🛠️ FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function createMessage(data, isOwn)
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, 0, 0, 0)
    msgFrame.BackgroundTransparency = 1
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.Parent = chatFrame
    
    local bubble = Instance.new("Frame")
    bubble.Size = UDim2.new(0.8, 0, 0, 0)
    bubble.Position = isOwn and UDim2.new(0.2, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
    bubble.BackgroundColor3 = isOwn and Color3.fromRGB(100, 120, 220) or Color3.fromRGB(45, 45, 55)
    bubble.AutomaticSize = Enum.AutomaticSize.Y
    bubble.BorderSizePixel = 0
    bubble.Parent = msgFrame
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(0, isMobile and 20 : 14)
    bubbleCorner.Parent = bubble
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, isMobile and 14 : 10)
    padding.PaddingBottom = UDim.new(0, isMobile and 14 : 10)
    padding.PaddingLeft = UDim.new(0, isMobile and 16 : 12)
    padding.PaddingRight = UDim.new(0, isMobile and 16 : 12)
    padding.Parent = bubble
    
    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(1, 0, 0, isMobile and 24 : 20)
    username.BackgroundTransparency = 1
    username.Text = data.username or "Unknown"
    username.TextColor3 = isOwn and Color3.fromRGB(200, 220, 255) or Color3.fromRGB(100, 220, 150)
    username.Font = Enum.Font.GothamBold
    username.TextSize = isMobile and 16 : 13
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = bubble
    
    local messageText = Instance.new("TextLabel")
    messageText.Size = UDim2.new(1, 0, 0, 0)
    messageText.Position = UDim2.new(0, 0, 0, isMobile and 26 : 22)
    messageText.BackgroundTransparency = 1
    messageText.Text = data.message or ""
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.Font = Enum.Font.Gotham
    messageText.TextSize = isMobile and 16 : 13
    messageText.TextWrapped = true
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.AutomaticSize = Enum.AutomaticSize.Y
    messageText.Parent = bubble
    
    task.wait(0.05)
    chatFrame.CanvasPosition = Vector2.new(0, chatFrame.AbsoluteCanvasSize.Y)
end

local function sendMessage(message)
    if #message == 0 or #message > CONFIG.MAX_MESSAGE_LENGTH then return end
    
    local success, result = pcall(function()
        return httpRequest({
            Url = CONFIG.SERVER_URL .. "/send",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                username = LocalPlayer.Name,
                message = message,
                game = State.currentGame,
                userId = tostring(LocalPlayer.UserId)
            })
        })
    end)
    
    if success and result.StatusCode == 200 then
        textBox.Text = ""
        print("✅ Message sent")
    else
        warn("❌ Failed to send message")
    end
end

local function fetchMessages()
    local success, result = pcall(function()
        return httpRequest({
            Url = CONFIG.SERVER_URL .. "/messages?since=" .. State.lastMessageTime,
            Method = "GET"
        })
    end)
    
    if success and result.StatusCode == 200 then
        local data = HttpService:JSONDecode(result.Body)
        
        if data.messages then
            for _, msg in ipairs(data.messages) do
                local timestamp = tonumber(msg.timestamp) or 0
                
                if timestamp > State.lastMessageTime then
                    local isOwn = msg.userId == tostring(LocalPlayer.UserId)
                    createMessage(msg, isOwn)
                    State.lastMessageTime = math.max(State.lastMessageTime, timestamp)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════
--  🎬 EVENTS
-- ═══════════════════════════════════════════════════════════

sendBtn.MouseButton1Click:Connect(function()
    sendMessage(textBox.Text)
end)

textBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and not isMobile then
        sendMessage(textBox.Text)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("💬 Chat closed")
end)

-- Dragging (Mobile & PC)
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🔄 UPDATE LOOP
-- ═══════════════════════════════════════════════════════════

print("🔄 Starting update loop...")

task.spawn(function()
    task.wait(1)
    fetchMessages()
end)

task.spawn(function()
    while screenGui.Parent do
        task.wait(CONFIG.UPDATE_INTERVAL)
        fetchMessages()
    end
end)

-- ═══════════════════════════════════════════════════════════
--  🎉 READY
-- ═══════════════════════════════════════════════════════════

print("═══════════════════════════════════════════════════════")
print("✅ UNIVERSAL CHAT LOADED!")
print("📱 Mobile Mode:", isMobile)
print("🎮 Game:", State.currentGame)
print("🌐 Server:", CONFIG.SERVER_URL)
print("═══════════════════════════════════════════════════════")

-- Make frame visible with animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = isMobile and UDim2.new(0.92, 0, 0.65, 0) or UDim2.new(0, 400, 0, 550),
    Position = isMobile and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
}):Play()

print("🎉 Chat interface shown!")
