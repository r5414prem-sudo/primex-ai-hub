-- Prime X AI Hub v2.0 - Enhanced Edition
-- Powered by Groq AI with Auto-Detection Features

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local API_URL = "https://primex-ai-hub.onrender.com"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Detect platform
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Utility Functions
local function detectExploitTools()
    local tools = {
        dex = false,
        remoteSpy = false,
        hydroxide = false,
        simpleSpyV3 = false
    }
    
    -- Check for Dex Explorer
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:lower():find("dex") or gui.Name:lower():find("explorer") then
            tools.dex = true
        end
    end
    
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui.Name:lower():find("dex") or gui.Name:lower():find("explorer") then
            tools.dex = true
        end
    end
    
    -- Check for Remote Spy
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:lower():find("remote") or gui.Name:lower():find("spy") then
            tools.remoteSpy = true
        end
    end
    
    for _, gui in pairs(playerGui:GetChildren()) do
        if gui.Name:lower():find("remote") or gui.Name:lower():find("spy") or 
           gui.Name:lower():find("simplespy") then
            tools.remoteSpy = true
        end
    end
    
    return tools
end

-- Safe clipboard function
local function safeSetClipboard(text)
    local success, err = pcall(function()
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        elseif syn and syn.write_clipboard then
            syn.write_clipboard(text)
            return true
        else
            return false
        end
    end)
    return success
end

local function scanRemotes()
    local remotes = {events = {}, functions = {}}
    
    local function scanInstance(instance)
        for _, child in pairs(instance:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                table.insert(remotes.events, child:GetFullName())
            elseif child:IsA("RemoteFunction") then
                table.insert(remotes.functions, child:GetFullName())
            end
        end
    end
    
    scanInstance(ReplicatedStorage)
    scanInstance(game:GetService("Workspace"))
    
    return remotes
end

local function getGameInfo()
    return {
        name = game.Name,
        placeId = game.PlaceId,
        jobId = game.JobId,
        players = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        creator = game.CreatorType.Name
    }
end

-- AI Request Function (Enhanced)
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

-- Draggable Frame Function
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create Enhanced UI (Mobile Responsive)
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PrimeXAIHub"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    
    -- Responsive sizing based on platform
    local frameWidth = isMobile and 0.95 or 0
    local frameHeight = isMobile and 0.85 or 0
    local frameWidthOffset = isMobile and 0 or 750
    local frameHeightOffset = isMobile and 0 or 550
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(frameWidth, frameWidthOffset, frameHeight, frameHeightOffset)
    mainFrame.Position = UDim2.new(0.5, isMobile and 0 or -375, 0.5, isMobile and 0 or -275)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, isMobile and 10 or 15)
    corner.Parent = mainFrame
    
    -- Make draggable only on PC
    if not isMobile then
        makeDraggable(mainFrame)
    end
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, isMobile and 50 or 60)
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, isMobile and 10 or 15)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = isMobile and "🤖 Prime X v2.0" or "🤖 Prime X AI Hub v2.0"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 16 or 22
    title.TextScaled = isMobile
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.35, 0, 0.5, 0)
    subtitle.Position = UDim2.new(0.63, 0, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "⚡ Groq AI"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = isMobile and 10 or 11
    subtitle.TextScaled = isMobile
    subtitle.TextXAlignment = Enum.TextXAlignment.Right
    subtitle.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, isMobile and 40 or 45, 0, isMobile and 40 or 45)
    closeBtn.Position = UDim2.new(1, isMobile and -45 or -52, 0, isMobile and 5 or 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.white
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = isMobile and 18 or 20
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 10)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    local headerHeight = isMobile and 50 or 60
    tabFrame.Size = UDim2.new(1, -20, 0, isMobile and 45 or 50)
    tabFrame.Position = UDim2.new(0, 10, 0, headerHeight + 10)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame
    
    local tabs = isMobile and {"Gen", "Scan", "Deob", "Remote", "Chat"} or {"Generate", "Analyze", "Deobfuscate", "Remote Scan", "Chat"}
    local currentTab = isMobile and "Gen" or "Generate"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.19, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2 + 0.005, 0, 0, 0)
        local isActive = (isMobile and tabName == "Gen") or (not isMobile and tabName == "Generate")
        btn.BackgroundColor3 = isActive and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(35, 35, 40)
        btn.Text = tabName
        btn.TextColor3 = Color3.white
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = isMobile and 11 or 13
        btn.TextScaled = isMobile
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, isMobile and 8 or 10)
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
    local contentTop = headerHeight + (isMobile and 60 or 70)
    local contentHeight = isMobile and -contentTop - 10 or 410
    contentFrame.Size = isMobile and UDim2.new(1, -20, 1, contentHeight) or UDim2.new(1, -20, 0, contentHeight)
    contentFrame.Position = UDim2.new(0, 10, 0, contentTop)
    contentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, isMobile and 8 or 12)
    contentCorner.Parent = contentFrame
    
    screenGui.Parent = playerGui
    
    -- Initialize first tab
    updateContent(mainFrame, isMobile and "Gen" or "Generate")
    
    return screenGui
end

-- Generate Tab (Enhanced)
function createGenerateTab(parent)
    parent:ClearAllChildren()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, isMobile and 20 or 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = isMobile and "🎯 What to generate?" or "🎯 What script do you want to generate?"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMobile and 14 or 16
    label.TextScaled = isMobile
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, isMobile and 100 or 80)
    inputBox.Position = UDim2.new(0, 10, 0, isMobile and 35 or 40)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputBox.PlaceholderText = isMobile and "ESP, Auto-farm, etc..." or "e.g., 'ESP with health bars and distance' or 'Auto-farm with collision removal'"
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.white
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = isMobile and 13 or 14
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
    generateBtn.Size = UDim2.new(isMobile and 0.9 or 0, isMobile and 0 or 200, 0, isMobile and 50 or 45)
    generateBtn.Position = UDim2.new(0.5, isMobile and 0 or -100, 0, isMobile and 145 or 130)
    generateBtn.AnchorPoint = Vector2.new(0.5, 0)
    generateBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    generateBtn.Text = "🤖 Generate Script"
    generateBtn.TextColor3 = Color3.white
    generateBtn.Font = Enum.Font.GothamBold
    generateBtn.TextSize = isMobile and 15 or 16
    generateBtn.Parent = parent
    
    local genBtnCorner = Instance.new("UICorner")
    genBtnCorner.CornerRadius = UDim.new(0, 10)
    genBtnCorner.Parent = generateBtn
    
    local outputScroll = Instance.new("ScrollingFrame")
    local outputTop = isMobile and 205 or 185
    local outputHeight = isMobile and -outputTop - 20 or 215
    outputScroll.Size = isMobile and UDim2.new(1, -20, 1, outputHeight) or UDim2.new(1, -20, 0, outputHeight)
    outputScroll.Position = UDim2.new(0, 10, 0, outputTop)
    outputScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    outputScroll.ScrollBarThickness = isMobile and 6 or 8
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
    outputText.TextSize = isMobile and 11 or 12
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Parent = outputScroll
    
    generateBtn.MouseButton1Click:Connect(function()
        local desc = inputBox.Text
        if desc == "" then
            outputText.Text = "⚠️ Please enter a description!"
            outputText.TextColor3 = Color3.fromRGB(255, 100, 100)
            outputScroll.Visible = true
            return
        end
        
        generateBtn.Text = "⏳ Generating..."
        generateBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local gameInfo = getGameInfo()
        local result = aiRequest("/generate-script", {
            description = desc,
            game = gameInfo.name,
            placeId = gameInfo.placeId
        })
        
        if result and result.success then
            outputText.Text = result.script
            outputText.TextColor3 = Color3.fromRGB(100, 255, 100)
            outputScroll.Visible = true
            outputScroll.CanvasSize = UDim2.new(0, 0, 0, outputText.TextBounds.Y + 10)
            
            -- Try to copy to clipboard
            local copied = safeSetClipboard(result.script)
            if copied then
                generateBtn.Text = "✅ Copied to Clipboard!"
            else
                generateBtn.Text = "✅ Generated! (Manual copy)"
            end
            wait(2)
        else
            outputText.Text = "❌ Error: Failed to generate script. Check API connection."
            outputText.TextColor3 = Color3.fromRGB(255, 100, 100)
            outputScroll.Visible = true
        end
        
        generateBtn.Text = "🤖 Generate Script"
        generateBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Analyze Tab (Enhanced)
function createAnalyzeTab(parent)
    parent:ClearAllChildren()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "🔍 Game Analysis & Tool Detection"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local detectBtn = Instance.new("TextButton")
    detectBtn.Size = UDim2.new(0, 200, 0, 40)
    detectBtn.Position = UDim2.new(0, 10, 0, 45)
    detectBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    detectBtn.Text = "🔎 Detect Tools"
    detectBtn.TextColor3 = Color3.white
    detectBtn.Font = Enum.Font.GothamBold
    detectBtn.TextSize = 14
    detectBtn.Parent = parent
    
    local detectCorner = Instance.new("UICorner")
    detectCorner.CornerRadius = UDim.new(0, 8)
    detectCorner.Parent = detectBtn
    
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Size = UDim2.new(0, 200, 0, 40)
    analyzeBtn.Position = UDim2.new(0, 220, 0, 45)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    analyzeBtn.Text = "🤖 AI Analyze Game"
    analyzeBtn.TextColor3 = Color3.white
    analyzeBtn.Font = Enum.Font.GothamBold
    analyzeBtn.TextSize = 14
    analyzeBtn.Parent = parent
    
    local analyzeCorner = Instance.new("UICorner")
    analyzeCorner.CornerRadius = UDim.new(0, 8)
    analyzeCorner.Parent = analyzeBtn
    
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
    resultText.Text = "Click a button to start analysis..."
    resultText.TextColor3 = Color3.fromRGB(180, 180, 180)
    resultText.Font = Enum.Font.Gotham
    resultText.TextSize = 13
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.TextYAlignment = Enum.TextYAlignment.Top
    resultText.TextWrapped = true
    resultText.Parent = resultScroll
    
    detectBtn.MouseButton1Click:Connect(function()
        detectBtn.Text = "🔍 Scanning..."
        
        local tools = detectExploitTools()
        local gameInfo = getGameInfo()
        
        local report = "=== TOOL DETECTION REPORT ===\n\n"
        report = report .. "Game: " .. gameInfo.name .. "\n"
        report = report .. "Place ID: " .. gameInfo.placeId .. "\n"
        report = report .. "Players: " .. gameInfo.players .. "/" .. gameInfo.maxPlayers .. "\n\n"
        report = report .. "--- Detected Tools ---\n"
        report = report .. "Dex Explorer: " .. (tools.dex and "✅ DETECTED" or "❌ Not Found") .. "\n"
        report = report .. "Remote Spy: " .. (tools.remoteSpy and "✅ DETECTED" or "❌ Not Found") .. "\n\n"
        
        if tools.dex or tools.remoteSpy then
            report = report .. "💡 Tools are active! You can use them to:\n"
            if tools.dex then
                report = report .. "  • Browse game hierarchy\n"
                report = report .. "  • Find hidden objects\n"
                report = report .. "  • Inspect properties\n"
            end
            if tools.remoteSpy then
                report = report .. "  • Monitor remote events\n"
                report = report .. "  • Log remote calls\n"
                report = report .. "  • Find exploitable remotes\n"
            end
        else
            report = report .. "ℹ️ No exploit tools det
