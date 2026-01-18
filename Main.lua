-- Prime X AI Hub - Powered by Groq AI
-- Free AI-powered script generation and game analysis

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local API_URL = "https://primex-ai-hub.onrender.com" -- Your AI Hub API

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- AI Request Function
local function aiRequest(endpoint, data)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = API_URL .. endpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
    
    if success and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    else
        warn("AI Request failed:", response and response.StatusMessage or "Unknown error")
        return nil
    end
end

-- Create UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PrimeXAIHub"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🤖 Prime X AI Hub"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.3, 0, 0.5, 0)
    subtitle.Position = UDim2.new(0.7, 0, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "⚡ Powered by Groq AI"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Right
    subtitle.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -52, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.white
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 10)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 50)
    tabFrame.Position = UDim2.new(0, 10, 0, 70)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local tabs = {"Generate", "Analyze", "Deobfuscate", "Chat"}
    local currentTab = "Generate"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.24, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.25 + 0.005, 0, 0, 0)
        btn.BackgroundColor3 = tabName == "Generate" and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(35, 35, 40)
        btn.Text = tabName
        btn.TextColor3 = Color3.white
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 10)
        btnCorner.Parent = btn
        
        tabButtons[tabName] = btn
        
        btn.MouseButton1Click:Connect(function()
            for name, button in pairs(tabButtons) do
                button.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            currentTab = tabName
            updateContent(mainFrame, tabName)
        end)
    end
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 0, 360)
    contentFrame.Position = UDim2.new(0, 10, 0, 130)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentFrame
    
    screenGui.Parent = playerGui
    
    -- Initialize first tab
    updateContent(mainFrame, "Generate")
    
    return screenGui
end

-- Generate Tab
function createGenerateTab(parent)
    parent:ClearAllChildren()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "What script do you want to generate?"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 80)
    inputBox.Position = UDim2.new(0, 10, 0, 45)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputBox.PlaceholderText = "e.g., 'ESP script with rainbow colors' or 'Auto-farm script for fruits'"
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.white
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.TextWrapped = true
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Top
    inputBox.ClearTextOnFocus = false
    inputBox.MultiLine = true
    inputBox.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    local generateBtn = Instance.new("TextButton")
    generateBtn.Size = UDim2.new(0, 200, 0, 45)
    generateBtn.Position = UDim2.new(0.5, -100, 0, 135)
    generateBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    generateBtn.Text = "🤖 Generate Script"
    generateBtn.TextColor3 = Color3.white
    generateBtn.Font = Enum.Font.GothamBold
    generateBtn.TextSize = 16
    generateBtn.Parent = parent
    
    local genBtnCorner = Instance.new("UICorner")
    genBtnCorner.CornerRadius = UDim.new(0, 10)
    genBtnCorner.Parent = generateBtn
    
    local outputScroll = Instance.new("ScrollingFrame")
    outputScroll.Size = UDim2.new(1, -20, 0, 160)
    outputScroll.Position = UDim2.new(0, 10, 0, 190)
    outputScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    outputScroll.ScrollBarThickness = 8
    outputScroll.BorderSizePixel = 0
    outputScroll.Visible = false
    outputScroll.Parent = parent
    
    local outputCorner = Instance.new("UICorner")
    outputCorner.CornerRadius = UDim.new(0, 8)
    outputCorner.Parent = outputScroll
    
    local outputText = Instance.new("TextLabel")
    outputText.Size = UDim2.new(1, -10, 1, 0)
    outputText.Position = UDim2.new(0, 5, 0, 5)
    outputText.BackgroundTransparency = 1
    outputText.Text = ""
    outputText.TextColor3 = Color3.fromRGB(100, 255, 100)
    outputText.Font = Enum.Font.Code
    outputText.TextSize = 12
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Parent = outputScroll
    
    generateBtn.MouseButton1Click:Connect(function()
        local desc = inputBox.Text
        if desc == "" then
            outputText.Text = "Please enter a description!"
            outputText.TextColor3 = Color3.fromRGB(255, 100, 100)
            outputScroll.Visible = true
            return
        end
        
        generateBtn.Text = "⏳ Generating..."
        generateBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local result = aiRequest("/generate-script", {
            description = desc,
            game = game.Name
        })
        
        if result and result.success then
            outputText.Text = result.script
            outputText.TextColor3 = Color3.fromRGB(100, 255, 100)
            outputScroll.Visible = true
            outputScroll.CanvasSize = UDim2.new(0, 0, 0, outputText.TextBounds.Y + 10)
            
            -- Copy to clipboard
            setclipboard(result.script)
            generateBtn.Text = "✅ Copied to Clipboard!"
            wait(2)
        else
            outputText.Text = "Error: Failed to generate script. Check API connection."
            outputText.TextColor3 = Color3.fromRGB(255, 100, 100)
            outputScroll.Visible = true
        end
        
        generateBtn.Text = "🤖 Generate Script"
        generateBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Chat Tab
function createChatTab(parent)
    parent:ClearAllChildren()
    
    local chatScroll = Instance.new("ScrollingFrame")
    chatScroll.Size = UDim2.new(1, -20, 1, -70)
    chatScroll.Position = UDim2.new(0, 10, 0, 10)
    chatScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    chatScroll.ScrollBarThickness = 8
    chatScroll.BorderSizePixel = 0
    chatScroll.Parent = parent
    
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0, 8)
    chatCorner.Parent = chatScroll
    
    local chatLayout = Instance.new("UIListLayout")
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 10)
    chatLayout.Parent = chatScroll
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -120, 0, 50)
    inputBox.Position = UDim2.new(0, 10, 1, -55)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputBox.PlaceholderText = "Ask AI anything about exploiting..."
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.white
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    local sendBtn = Instance.new("TextButton")
    sendBtn.Size = UDim2.new(0, 100, 0, 50)
    sendBtn.Position = UDim2.new(1, -110, 1, -55)
    sendBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sendBtn.Text = "Send"
    sendBtn.TextColor3 = Color3.white
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 16
    sendBtn.Parent = parent
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 8)
    sendCorner.Parent = sendBtn
    
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
        msgText.Size = UDim2.new(1, -20, 1, 0)
        msgText.Position = UDim2.new(0, 10, 0, 10)
        msgText.BackgroundTransparency = 1
        msgText.Text = (isUser and "You: " or "AI: ") .. text
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
    
    local function sendMessage()
        local msg = inputBox.Text
        if msg == "" then return end
        
        addMessage(msg, true)
        inputBox.Text = ""
        
        sendBtn.Text = "..."
        
        local result = aiRequest("/ai-chat", {message = msg})
        
        if result and result.success then
            addMessage(result.response, false)
        else
            addMessage("Error: Could not reach AI", false)
        end
        
        sendBtn.Text = "Send"
    end
    
    sendBtn.MouseButton1Click:Connect(sendMessage)
    inputBox.FocusLost:Connect(function(enter)
        if enter then sendMessage() end
    end)
end

-- Update Content
function updateContent(gui, tab)
    local contentFrame = gui:FindFirstChild("ContentFrame")
    if not contentFrame then return end
    
    if tab == "Generate" then
        createGenerateTab(contentFrame)
    elseif tab == "Chat" then
        createChatTab(contentFrame)
    elseif tab == "Analyze" then
        contentFrame:ClearAllChildren()
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Game Analyzer - Coming Soon!"
        label.TextColor3 = Color3.white
        label.Font = Enum.Font.GothamBold
        label.TextSize = 20
        label.Parent = contentFrame
    else
        contentFrame:ClearAllChildren()
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Deobfuscator - Coming Soon!"
        label.TextColor3 = Color3.white
        label.Font = Enum.Font.GothamBold
        label.TextSize = 20
        label.Parent = contentFrame
    end
end

-- Initialize
local function init()
    print("🚀 Prime X AI Hub Loading...")
    print("🤖 Powered by Groq AI (Llama 3.1)")
    
    if playerGui:FindFirstChild("PrimeXAIHub") then
        playerGui:FindFirstChild("PrimeXAIHub"):Destroy()
        wait(0.5)
    end
    
    createUI()
    
    print("✅ Prime X AI Hub Loaded!")
    print("💡 Generate scripts, chat with AI, and more!")
end

init()
