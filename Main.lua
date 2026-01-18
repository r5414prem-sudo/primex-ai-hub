-- Prime X AI Hub v2.0 - Enhanced Edition
-- Powered by Groq AI with Auto-Detection Features

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local API_URL = "https://primex-ai-hub.onrender.com"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

-- Create Enhanced UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PrimeXAIHub"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 750, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -375, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Make draggable
    makeDraggable(mainFrame)
    
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
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🤖 Prime X AI Hub v2.0"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.35, 0, 0.5, 0)
    subtitle.Position = UDim2.new(0.63, 0, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "⚡ Groq AI + Auto-Detect"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
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
    
    local tabs = {"Generate", "Analyze", "Deobfuscate", "Remote Scan", "Chat"}
    local currentTab = "Generate"
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.19, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2 + 0.005, 0, 0, 0)
        btn.BackgroundColor3 = tabName == "Generate" and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(35, 35, 40)
        btn.Text = tabName
        btn.TextColor3 = Color3.white
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
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
    contentFrame.Size = UDim2.new(1, -20, 0, 410)
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

-- Generate Tab (Enhanced)
function createGenerateTab(parent)
    parent:ClearAllChildren()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "🎯 What script do you want to generate?"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 80)
    inputBox.Position = UDim2.new(0, 10, 0, 40)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputBox.PlaceholderText = "e.g., 'ESP with health bars and distance' or 'Auto-farm with collision removal'"
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
    generateBtn.Position = UDim2.new(0.5, -100, 0, 130)
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
    outputScroll.Size = UDim2.new(1, -20, 0, 215)
    outputScroll.Position = UDim2.new(0, 10, 0, 185)
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
            
            -- Copy to clipboard
            setclipboard(result.script)
            generateBtn.Text = "✅ Copied to Clipboard!"
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
            report = report .. "ℹ️ No exploit tools detected.\n"
            report = report .. "Consider loading Dex or Remote Spy for better analysis.\n"
        end
        
        resultText.Text = report
        resultText.TextColor3 = Color3.fromRGB(100, 255, 100)
        resultScroll.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 10)
        
        detectBtn.Text = "🔎 Detect Tools"
    end)
    
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeBtn.Text = "⏳ Analyzing..."
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local gameInfo = getGameInfo()
        local result = aiRequest("/analyze-game", {
            game_id = tostring(gameInfo.placeId),
            game_name = gameInfo.name
        })
        
        if result and result.success then
            resultText.Text = "=== AI GAME ANALYSIS ===\n\n" .. result.analysis
            resultText.TextColor3 = Color3.fromRGB(100, 200, 255)
            resultScroll.CanvasSize = UDim2.new(0, 0, 0, resultText.TextBounds.Y + 10)
        else
            resultText.Text = "❌ Failed to analyze game. Check API connection."
            resultText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        analyzeBtn.Text = "🤖 AI Analyze Game"
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Deobfuscate Tab (Enhanced)
function createDeobfuscateTab(parent)
    parent:ClearAllChildren()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "🔓 Script Deobfuscator"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 120)
    inputBox.Position = UDim2.new(0, 10, 0, 40)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputBox.PlaceholderText = "Paste obfuscated script here..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.white
    inputBox.Font = Enum.Font.Code
    inputBox.TextSize = 12
    inputBox.TextWrapped = true
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.TextYAlignment = Enum.TextYAlignment.Top
    inputBox.ClearTextOnFocus = false
    inputBox.MultiLine = true
    inputBox.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    local deobBtn = Instance.new("TextButton
