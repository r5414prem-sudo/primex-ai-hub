-- Simple AI Chat - Talk to AI in Roblox
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local API_URL = "https://primex-ai-hub.onrender.com"
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Detect mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AIChat"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = isMobile and UDim2.new(0.9, 0, 0.6, 0) or UDim2.new(0, 400, 0, 500)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.8, 0, 1, 0)
title.Position = UDim2.new(0.02, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🤖 AI Chat"
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.white
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Chat area
local chatScroll = Instance.new("ScrollingFrame")
chatScroll.Size = isMobile and UDim2.new(1, -20, 1, -130) or UDim2.new(1, -20, 0, 380)
chatScroll.Position = UDim2.new(0, 10, 0, 60)
chatScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
chatScroll.ScrollBarThickness = 6
chatScroll.BorderSizePixel = 0
chatScroll.Parent = main

local chatCorner = Instance.new("UICorner")
chatCorner.CornerRadius = UDim.new(0, 8)
chatCorner.Parent = chatScroll

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, 10)
chatLayout.Parent = chatScroll

-- Input box
local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -130, 0, 50)
input.Position = isMobile and UDim2.new(0, 10, 1, -60) or UDim2.new(0, 10, 0, 450)
input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
input.PlaceholderText = "Type your message..."
input.Text = ""
input.TextColor3 = Color3.white
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.TextXAlignment = Enum.TextXAlignment.Left
input.Parent = main

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = input

-- Send button
local sendBtn = Instance.new("TextButton")
sendBtn.Size = UDim2.new(0, 110, 0, 50)
sendBtn.Position = isMobile and UDim2.new(1, -120, 1, -60) or UDim2.new(1, -120, 0, 450)
sendBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
sendBtn.Text = "Send"
sendBtn.TextColor3 = Color3.white
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = 16
sendBtn.Parent = main

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 8)
sendCorner.Parent = sendBtn

-- Welcome message
local welcomeFrame = Instance.new("Frame")
welcomeFrame.Size = UDim2.new(1, -20, 0, 70)
welcomeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
welcomeFrame.BorderSizePixel = 0
welcomeFrame.Parent = chatScroll

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 8)
welcomeCorner.Parent = welcomeFrame

local welcomeText = Instance.new("TextLabel")
welcomeText.Size = UDim2.new(1, -20, 1, -20)
welcomeText.Position = UDim2.new(0, 10, 0, 10)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "🤖 AI: Hello! I'm your AI assistant. Ask me anything about Roblox scripting, exploiting, or game development!"
welcomeText.TextColor3 = Color3.fromRGB(100, 200, 255)
welcomeText.Font = Enum.Font.Gotham
welcomeText.TextSize = 13
welcomeText.TextWrapped = true
welcomeText.TextXAlignment = Enum.TextXAlignment.Left
welcomeText.TextYAlignment = Enum.TextYAlignment.Top
welcomeText.Parent = welcomeFrame

chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)

-- Add message function
local function addMessage(text, isUser)
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, -20, 0, 0)
    msgFrame.BackgroundColor3 = isUser and Color3.fromRGB(50, 100, 200) or Color3.fromRGB(35, 35, 40)
    msgFrame.BorderSizePixel = 0
    msgFrame.Parent = chatScroll
    
    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 8)
    msgCorner.Parent = msgFrame
    
    local msgText = Instance.new("TextLabel")
    msgText.Size = UDim2.new(1, -20, 1, -20)
    msgText.Position = UDim2.new(0, 10, 0, 10)
    msgText.BackgroundTransparency = 1
    msgText.Text = (isUser and "👤 You: " or "🤖 AI: ") .. text
    msgText.TextColor3 = Color3.white
    msgText.Font = Enum.Font.Gotham
    msgText.TextSize = 13
    msgText.TextWrapped = true
    msgText.TextXAlignment = Enum.TextXAlignment.Left
    msgText.TextYAlignment = Enum.TextYAlignment.Top
    msgText.Parent = msgFrame
    
    msgFrame.Size = UDim2.new(1, -20, 0, msgText.TextBounds.Y + 20)
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)
    chatScroll.CanvasPosition = Vector2.new(0, chatScroll.CanvasSize.Y.Offset)
end

-- Send message function
local function sendMessage()
    local msg = input.Text
    if msg == "" then return end
    
    addMessage(msg, true)
    input.Text = ""
    
    sendBtn.Text = "..."
    sendBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    
    -- Call AI
    local success, result = pcall(function()
        local response = HttpService:RequestAsync({
            Url = API_URL .. "/ai-chat",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({message = msg})
        })
        return HttpService:JSONDecode(response.Body)
    end)
    
    if success and result and result.success then
        addMessage(result.response, false)
    else
        addMessage("Error: Could not reach AI. Check your connection.", false)
    end
    
    sendBtn.Text = "Send"
    sendBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
end

sendBtn.MouseButton1Click:Connect(sendMessage)
input.FocusLost:Connect(function(enter)
    if enter then sendMessage() end
end)

print("✅ AI Chat loaded! Press X to close or just start chatting!")
