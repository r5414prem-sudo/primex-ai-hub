-- Prime X AI Hub v2.0 - Full Executor Version
-- Powered by Groq AI with Auto-Detection

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

-- Safe clipboard function
local function safeSetClipboard(text)
    local success = pcall(function()
        if setclipboard then
            setclipboard(text)
            return true
        elseif toclipboard then
            toclipboard(text)
            return true
        elseif syn and syn.write_clipboard then
            syn.write_clipboard(text)
            return true
        end
    end)
    return success
end

-- Detect exploit tools
local function detectExploitTools()
    local tools = {dex = false, remoteSpy = false}
    
    for _, gui in pairs(CoreGui:GetChildren()) do
        local name = gui.Name:lower()
        if name:find("dex") or name:find("explorer") then
            tools.dex = true
        end
        if name:find("remote") or name:find("spy") then
            tools.remoteSpy = true
        end
    end
    
    for _, gui in pairs(playerGui:GetChildren()) do
        local name = gui.Name:lower()
        if name:find("dex") or name:find("explorer") then
            tools.dex = true
        end
        if name:find("remote") or name:find("spy") or name:find("simplespy") then
            tools.remoteSpy = true
        end
    end
    
    return tools
end

-- Scan remotes
local function scanRemotes()
    local remotes = {events = {}, functions = {}}
    
    local function scan(instance)
        for _, child in pairs(instance:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                table.insert(remotes.events, child:GetFullName())
            elseif child:IsA("RemoteFunction") then
                table.insert(remotes.functions, child:GetFullName())
            end
        end
    end
    
    pcall(function() scan(ReplicatedStorage) end)
    pcall(function() scan(workspace) end)
    
    return remotes
end

-- Get game info
local function getGameInfo()
    return {
        name = game.Name,
        placeId = game.PlaceId,
        players = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers
    }
end

-- AI Request
local function aiRequest(endpoint, data)
    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = API_URL .. endpoint,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data),
            Timeout = 30
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body)
    end
    return nil
end

-- Make draggable
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Create UI
local function createUI()
    if playerGui:FindFirstChild("PrimeXHub") then
        playerGui.PrimeXHub:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "PrimeXHub"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = isMobile and UDim2.new(0.95, 0, 0.85, 0) or UDim2.new(0, 700, 0, 500)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = main
    
    if not isMobile then
        makeDraggable(main)
    end
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, isMobile and 50 or 55)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    header.BorderSizePixel = 0
    header.Parent = main
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 1, 0)
    title.Position = UDim2.new(0.02, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = isMobile and "🤖 Prime X AI" or "🤖 Prime X AI Hub"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 16 or 20
    title.TextScaled = isMobile
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 7.5)
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
    
    -- Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 45)
    tabFrame.Position = UDim2.new(0, 10, 0, isMobile and 60 or 65)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = main
    
    local tabs = isMobile and {"Gen", "Scan", "Deob", "Remote", "Chat"} or 
                              {"Generate", "Analyze", "Deobfuscate", "Remote Scan", "Chat"}
    local tabBtns = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.19, 0, 1, 0)
        btn.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(40, 40, 45)
        btn.Text = tab
        btn.TextColor3 = Color3.white
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = isMobile and 12 or 14
        btn.TextScaled = isMobile
        btn.Parent = tabFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        tabBtns[tab] = btn
    end
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    local contentTop = isMobile and 115 or 120
    content.Size = isMobile and UDim2.new(1, -20, 1, -contentTop - 10) or UDim2.new(1, -20, 0, 365)
    content.Position = UDim2.new(0, 10, 0, contentTop)
    content.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    content.BorderSizePixel = 0
    content.Parent = main
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = content
    
    gui.Parent = playerGui
    
    -- Tab switching
    local currentTab = tabs[1]
    for tabName, btn in pairs(tabBtns) do
        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(tabBtns) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
            currentTab = tabName
            updateContent(content, tabName)
        end)
    end
    
    updateContent(content, currentTab)
    return gui
end

-- Update content based on tab
function updateContent(parent, tab)
    parent:ClearAllChildren()
    
    -- Map mobile names to full names
    local tabMap = {Gen="Generate", Scan="Analyze", Deob="Deobfuscate", Remote="Remote Scan"}
    local fullTab = tabMap[tab] or tab
    
    if fullTab == "Generate" then
        createGenerateTab(parent)
    elseif fullTab == "Analyze" then
        createAnalyzeTab(parent)
    elseif fullTab == "Deobfuscate" then
        createDeobTab(parent)
    elseif fullTab == "Remote Scan" then
        createRemoteTab(parent)
    elseif fullTab == "Chat" then
        createChatTab(parent)
    end
end

-- Generate Tab
function createGenerateTab(parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = isMobile and "🎯 Describe script:" or "🎯 What script to generate?"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = isMobile and 14 or 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, isMobile and 100 or 80)
    input.Position = UDim2.new(0, 10, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    input.PlaceholderText = isMobile and "e.g., ESP script..." or "e.g., ESP with health bars, Auto-farm script"
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Text = ""
    input.TextColor3 = Color3.white
    input.Font = Enum.Font.Gotham
    input.TextSize = isMobile and 13 or 14
    input.TextWrapped = true
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextYAlignment = Enum.TextYAlignment.Top
    input.MultiLine = true
    input.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = input
    
    local genBtn = Instance.new("TextButton")
    genBtn.Size = isMobile and UDim2.new(0.9, 0, 0, 50) or UDim2.new(0, 200, 0, 45)
    genBtn.Position = UDim2.new(0.5, 0, 0, isMobile and 150 or 130)
    genBtn.AnchorPoint = Vector2.new(0.5, 0)
    genBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    genBtn.Text = "🤖 Generate"
    genBtn.TextColor3 = Color3.white
    genBtn.Font = Enum.Font.GothamBold
    genBtn.TextSize = 16
    genBtn.Parent = parent
    
    local genCorner = Instance.new("UICorner")
    genCorner.CornerRadius = UDim.new(0, 10)
    genCorner.Parent = genBtn
    
    local output = Instance.new("ScrollingFrame")
    local outTop = isMobile and 210 or 185
    local outHeight = isMobile and -outTop - 20 or 150
    output.Size = isMobile and UDim2.new(1, -20, 1, outHeight) or UDim2.new(1, -20, 0, outHeight)
    output.Position = UDim2.new(0, 10, 0, outTop)
    output.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    output.ScrollBarThickness = 6
    output.BorderSizePixel = 0
    output.Visible = false
    output.Parent = parent
    
    local outCorner = Instance.new("UICorner")
    outCorner.CornerRadius = UDim.new(0, 8)
    outCorner.Parent = output
    
    local outText = Instance.new("TextLabel")
    outText.Size = UDim2.new(1, -10, 1, 0)
    outText.Position = UDim2.new(0, 5, 0, 5)
    outText.BackgroundTransparency = 1
    outText.Text = ""
    outText.TextColor3 = Color3.fromRGB(100, 255, 100)
    outText.Font = Enum.Font.Code
    outText.TextSize = 12
    outText.TextXAlignment = Enum.TextXAlignment.Left
    outText.TextYAlignment = Enum.TextYAlignment.Top
    outText.TextWrapped = true
    outText.Parent = output
    
    genBtn.MouseButton1Click:Connect(function()
        if input.Text == "" then
            outText.Text = "⚠️ Enter a description!"
            outText.TextColor3 = Color3.fromRGB(255, 100, 100)
            output.Visible = true
            return
        end
        
        genBtn.Text = "⏳ Generating..."
        genBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local info = getGameInfo()
        local result = aiRequest("/generate-script", {
            description = input.Text,
            game = info.name,
            placeId = info.placeId
        })
        
        if result and result.success then
            outText.Text = result.script
            outText.TextColor3 = Color3.fromRGB(100, 255, 100)
            output.Visible = true
            output.CanvasSize = UDim2.new(0, 0, 0, outText.TextBounds.Y + 10)
            
            if safeSetClipboard(result.script) then
                genBtn.Text = "✅ Copied!"
            else
                genBtn.Text = "✅ Done!"
            end
            wait(2)
        else
            outText.Text = "❌ Error: Check API connection or try again"
            outText.TextColor3 = Color3.fromRGB(255, 100, 100)
            output.Visible = true
        end
        
        genBtn.Text = "🤖 Generate"
        genBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Analyze Tab
function createAnalyzeTab(parent)
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
    detectBtn.Size = isMobile and UDim2.new(0.48, 0, 0, 40) or UDim2.new(0, 200, 0, 40)
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
    analyzeBtn.Size = isMobile and UDim2.new(0.48, 0, 0, 40) or UDim2.new(0, 200, 0, 40)
    analyzeBtn.Position = isMobile and UDim2.new(0.52, 0, 0, 45) or UDim2.new(0, 220, 0, 45)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    analyzeBtn.Text = "🤖 AI Analyze"
    analyzeBtn.TextColor3 = Color3.white
    analyzeBtn.Font = Enum.Font.GothamBold
    analyzeBtn.TextSize = 14
    analyzeBtn.Parent = parent
    
    local analyzeCorner = Instance.new("UICorner")
    analyzeCorner.CornerRadius = UDim.new(0, 8)
    analyzeCorner.Parent = analyzeBtn
    
    local result = Instance.new("ScrollingFrame")
    local resHeight = isMobile and -105 or 280
    result.Size = isMobile and UDim2.new(1, -20, 1, resHeight) or UDim2.new(1, -20, 0, resHeight)
    result.Position = UDim2.new(0, 10, 0, 95)
    result.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    result.ScrollBarThickness = 6
    result.BorderSizePixel = 0
    result.Parent = parent
    
    local resCorner = Instance.new("UICorner")
    resCorner.CornerRadius = UDim.new(0, 8)
    resCorner.Parent = result
    
    local resText = Instance.new("TextLabel")
    resText.Size = UDim2.new(1, -10, 1, 0)
    resText.Position = UDim2.new(0, 5, 0, 5)
    resText.BackgroundTransparency = 1
    resText.Text = "Click a button to start..."
    resText.TextColor3 = Color3.fromRGB(180, 180, 180)
    resText.Font = Enum.Font.Gotham
    resText.TextSize = 13
    resText.TextXAlignment = Enum.TextXAlignment.Left
    resText.TextYAlignment = Enum.TextYAlignment.Top
    resText.TextWrapped = true
    resText.Parent = result
    
    detectBtn.MouseButton1Click:Connect(function()
        detectBtn.Text = "🔍 Scanning..."
        
        local tools = detectExploitTools()
        local info = getGameInfo()
        
        local report = "=== TOOL DETECTION ===\n\n"
        report = report .. "Game: " .. info.name .. "\n"
        report = report .. "Place ID: " .. info.placeId .. "\n"
        report = report .. "Players: " .. info.players .. "/" .. info.maxPlayers .. "\n\n"
        report = report .. "Dex Explorer: " .. (tools.dex and "✅ FOUND" or "❌ Not Found") .. "\n"
        report = report .. "Remote Spy: " .. (tools.remoteSpy and "✅ FOUND" or "❌ Not Found") .. "\n\n"
        
        if tools.dex or tools.remoteSpy then
            report = report .. "💡 Active tools detected!\n"
        else
            report = report .. "ℹ️ No tools detected. Load Dex/RemoteSpy for better analysis.\n"
        end
        
        resText.Text = report
        resText.TextColor3 = Color3.fromRGB(100, 255, 100)
        result.CanvasSize = UDim2.new(0, 0, 0, resText.TextBounds.Y + 10)
        
        detectBtn.Text = "🔎 Detect Tools"
    end)
    
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeBtn.Text = "⏳ Analyzing..."
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        
        local info = getGameInfo()
        local aiResult = aiRequest("/analyze-game", {
            game_id = tostring(info.placeId),
            game_name = info.name
        })
        
        if aiResult and aiResult.success then
            resText.Text = "=== AI ANALYSIS ===\n\n" .. aiResult.analysis
            resText.TextColor3 = Color3.fromRGB(100, 200, 255)
            result.CanvasSize = UDim2.new(0, 0, 0, resText.TextBounds.Y + 10)
        else
            resText.Text = "❌ Failed to analyze. Check API or try again."
            resText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        
        analyzeBtn.Text = "🤖 AI Analyze"
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    end)
end

-- Deobfuscate Tab
function createDeobTab(parent)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "🔓 Deobfuscator"
    label.TextColor3 = Color3.white
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 0, isMobile and 100 or 100)
    input.Position = UDim2.new(0, 10, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    input.PlaceholderText = "Paste obfuscated code here..."
    input.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    input.Text = ""
    input.TextColor3 = Color3.white
    input.Font = Enum.Font.Code
    input.TextSize = 12
    input.TextWrapped = true
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextYAlignment = Enum.TextYAlignment.Top
    input.MultiLine = true
    input.Parent = parent
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = input
    
    local deobBtn = Instance.new("TextButton")
    deobBtn.Size = isMobile and UDim2.new(0.9, 0, 0, 45) or UDim2.new(0, 220, 0, 40)
    deobBtn.Position = UDim2.new(0.5, 0, 0, isMobile and 150 or 150)
    deobBtn.AnchorPoint = Vector2.new(0.5, 0)
    deobBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    deobBtn.Text = "🔓 Deobfuscate
