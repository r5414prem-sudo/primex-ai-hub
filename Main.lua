local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(0, 200, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 45)
    scanBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    scanBtn.Text = "📡 Scan Remotes"
    scanBtn.TextColor3 = Color3.white
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = parent
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanBtn
    
    local aiAnalyzeBtn = Instance.new("TextButton")
    aiAnalyzeBtn.Size = UDim2.new(0, 200, 0, 40)
    aiAnalyzeBtn.Position = UDim2.new(0, 220, 0, 45)
    aiAnalyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    aiAnalyzeBtn.Text = "🤖 AI Find Remotes"
    aiAnalyzeBtn.TextColor3 = Color3.white
    aiAnalyzeBtn.Font = Enum.Font.GothamBold
    aiAnalyzeBtn.TextSize = 14
    aiAnalyzeBtn.Parent = parent
    
    local aiCorner = Instance.new("UICorner")
    aiCorner.CornerRadius = UDim.new(0, 8)
    aiCorner.Parent = aiAnalyzeBtn
    
    local resultScroll = Instance.new("ScrollingFrame")
    resultScroll.Size = UDim2.new(1, -20, 0, 310)
    resultScroll.Position = UDim2.new(0, 10, 0, 95)
    resultScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    resultScroll.ScrollBarThickness = 8
    resultScroll.BorderSizePixel = 0
    resultScroll.Parent = parent
    
    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 8)
    resultCorner.Parent = resultScroll
    
    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(1, -10, 1, 0)
    resultText.Position = UDim2.new(0, 5, 0, 5)
    resultText.BackgroundTransparency = 1
    resultText.Text = "Click 'Scan Remotes' to find all RemoteEvents and RemoteFunctions..."
    resultText.TextColor3 = Color3.fromRGB(180, 180, 180)
    resultText.Font = Enum.Font.Code
    resultText.TextSize = 12
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.TextYAlignment = Enum.TextYAlignment.Top
    resultText.TextWrapped = true
    resultText.Parent = resultScroll
    
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "🔍 Scanning..."
        
        local remotes = scanRemotes()
        local report = "=== REMOTE SCAN RESULTS ===\n\n"
        
        report = report .. "RemoteEvents Found: " .. #remotes.events .. "\n"
        report = report .. "RemoteFunctions Found: " .. #remotes.functions .. "\n\n"
        
        if #remotes.events > 0 then
            report = report .. "--- RemoteEvents ---\n"
            for i, remote in ipairs(remotes.events) do
                report = report .. i .. ". " .. remote .. "\n"
            end
            report = report .. "\n"
        end
        
        if #remotes.functions > 0 then
            report = report .. "--- RemoteFunctions ---\n"
            for i, remote in ipairs(remotes.functions) do
                report = report .. i .. ". " .. remote .. "\n"
            end
            report = report .. "\n"
        end
        
        if #remotes.events == 0 and #remotes.functions == 0 then
            report = report .. "⚠️ No remotes found. They might be:\n"
            report = report .. "  • Protected/hidden\n"
            report = report .. "  • Created at runtime\n"
            report = report .. "  • In a different location\n\n"
            report = report .. "Try using Remote Spy for real-time monitoring!"
        else
            report = report .. "💡 Use Remote Spy to monitor these remotes in action!"
        end
        
        resultText.Text = report
        resultText.TextColor3 = Color3.fromRGB(100, 255, 100)
        resultScroll.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 10)
        
        scanBtn.Text = "📡 Scan Remotes"
    end)
    
    aiAnalyzeBtn.MouseButton1Click:Connect(function()
        aiAnalyzeBtn.Text = "⏳ AI Analyzing..."
        aiAnalyzeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local gameInfo = getGameInfo()
        local result = aiRequest("/find-remotes", {
            game_type = gameInfo.name,
            features = {"combat", "currency", "items", "admin"}
        })
        
        if result and result.success then
            resultText.Text = "=== AI REMOTE PREDICTIONS ===\n\n" .. result.remotes
            resultText.TextColor3 = Color3.fromRGB(100, 200, 255)
            resultScroll.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 10)
        else
            resultText.Text = "❌ Failed to get AI predictions."
            resultText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        aiAnalyzeBtn.Text = "🤖 AI Find Remotes"
        aiAnalyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Chat Tab (Enhanced)
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
    inputBox.PlaceholderText = "Ask AI about exploiting, scripting, or anything..."
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
    
    -- Welcome message
    local welcomeFrame = Instance.new("Frame")
    welcomeFrame.Size = UDim2.new(1, -20, 0, 60)
    welcomeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    welcomeFrame.BorderSizePixel = 0
    welcomeFrame.Parent = chatScroll
    
    local welcomeCorner = Instance.new("UICorner")
    welcomeCorner.CornerRadius = UDim.new(0, 8)
    welcomeCorner.Parent = welcomeFrame
    
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(1, -20, 1, 0)
    welcomeText.Position = UDim2.new(0, 10, 0, 10)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Text = "🤖 AI: Hello! I'm your AI assistant. Ask me anything about Roblox exploiting, scripting, game analysis, or any questions you have!"
    welcomeText.TextColor3 = Color3.fromRGB(100, 200, 255)
    welcomeText.Font = Enum.Font.Gotham
    welcomeText.TextSize = 13
    welcomeText.TextWrapped = true
    welcomeText.TextXAlignment = Enum.TextXAlignment.Left
    welcomeText.TextYAlignment = Enum.TextYAlignment.Top
    welcomeText.Parent = welcomeFrame
    
    chatScroll.CanvasSize = UDim2.new(0, 0, 0, chatLayout.AbsoluteContentSize.Y)
    
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
    
    local function sendMessage()
        local msg = inputBox.Text
        if msg == "" then return end
        
        addMessage(msg, true)
        inputBox.Text = ""
        
        sendBtn.Text = "..."
        sendBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local result = aiRequest("/ai-chat", {message = msg})
        
        if result and result.success then
            addMessage(result.response, false)
        else
            addMessage("Error: Could not reach AI. Check API connection.", false)
        end
        
        sendBtn.Text = "Send"
        sendBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end
    
    sendBtn.MouseButton1Click:Connect(sendMessage)
    inputBox.FocusLost:Connect(function(enter)
        if enter then sendMessage() end
    end)
end

-- Update Content (Mobile Aware)
function updateContent(gui, tab)
    local contentFrame = gui:FindFirstChild("ContentFrame")
    if not contentFrame then return end
    
    -- Map mobile tab names to full names
    local tabMap = {
        ["Gen"] = "Generate",
        ["Scan"] = "Analyze", 
        ["Deob"] = "Deobfuscate",
        ["Remote"] = "Remote Scan",
        ["Chat"] = "Chat"
    }
    
    local fullTabName = tabMap[tab] or tab
    
    if fullTabName == "Generate" then
        createGenerateTab(contentFrame)
    elseif fullTabName == "Chat" then
        createChatTab(contentFrame)
    elseif fullTabName == "Analyze" then
        createAnalyzeTab(contentFrame)
    elseif fullTabName == "Deobfuscate" then
        createDeobfuscateTab(contentFrame)
    elseif fullTabName == "Remote Scan" then
        createRemoteScanTab(contentFrame)
    end
end

-- Initialize
local function init()
    print("🚀 Prime X AI Hub v2.0 Loading...")
    print("🤖 Powered by Groq AI (Llama 3.1 70B)")
    print("📱 Platform: " .. (isMobile and "Mobile" or "PC/Desktop"))
    print("✨ New Features: Tool Detection, Remote Scanning, Enhanced Deobfuscation")
    
    if playerGui:FindFirstChild("PrimeXAIHub") then
        playerGui:FindFirstChild("PrimeXAIHub"):Destroy()
        wait(0.5)
    end
    
    createUI()
    
    print("✅ Prime X AI Hub v2.0 Loaded Successfully!")
    print("💡 Features:")
    print("  • AI Script Generation")
    print("  • Game Analysis & Tool Detection")
    print("  • AI-Powered Deobfuscation")
    print("  • Remote Event Scanner")
    print("  • AI Chat Assistant")
    if not isMobile then
        print("📌 Drag the window to move it!")
    end
end

init()
