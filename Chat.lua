local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ✅ CONFIGURATION
local SERVER_URL = "https://roblox-chat-server-z35g.onrender.com" -- Your Java/Render Link
local UPDATE_INTERVAL = 2

-- ✅ UI ROOT
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "UnrealUniversalChat"

-- ✅ MAIN FRAME (Aesthetic Glass Design)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 340, 0, 420)
mainFrame.Position = UDim2.new(1, 50, 0.5, -210) -- Starts off-screen
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 20)

local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(60, 120, 255)
uiStroke.Transparency = 0.4

-- ✅ TOP BAR (Title & Minimize)
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "GLOBAL CHAT"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 35, 0, 35)
minBtn.Position = UDim2.new(0.85, 0, 0.2, 0)
minBtn.Text = "−"
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
minBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

-- ✅ CHAT AREA (Mobile Optimized Scrolling)
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 0.7, 0)
scrollingFrame.Position = UDim2.new(0, 10, 0, 60)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 2
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- ✅ INPUT BOX
local inputFrame = Instance.new("Frame", mainFrame)
inputFrame.Size = UDim2.new(0.9, 0, 0, 40)
inputFrame.Position = UDim2.new(0.05, 0, 0.88, 0)
inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

local textBox = Instance.new("TextBox", inputFrame)
textBox.Size = UDim2.new(1, -20, 1, 0)
textBox.Position = UDim2.new(0, 10, 0, 0)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "Type message..."
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.TextSize = 14
textBox.Font = Enum.Font.Gotham

-- ✅ MINIMIZE BAR (The small bar when closed)
local miniBar = Instance.new("TextButton", screenGui)
miniBar.Size = UDim2.new(0, 180, 0, 45)
miniBar.Position = UDim2.new(1, 10, 0.9, 0) -- Hidden off-screen
miniBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
miniBar.Text = "💬 Global Chat"
miniBar.TextColor3 = Color3.new(1, 1, 1)
miniBar.Font = Enum.Font.GothamBold
miniBar.Visible = false
Instance.new("UICorner", miniBar)

-- ✅ ANIMATIONS & LOGIC
local function createBubble(data)
    local bubble = Instance.new("Frame", scrollingFrame)
    bubble.Size = UDim2.new(0, 0, 0, 0) -- Start scale 0 for pop animation
    bubble.AutomaticSize = Enum.AutomaticSize.XY
    bubble.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    
    local corner = Instance.new("UICorner", bubble)
    corner.CornerRadius = UDim.new(0, 12)
    
    local av = Instance.new("ImageLabel", bubble)
    av.Size = UDim2.new(0, 35, 0, 35)
    av.Position = UDim2.new(0, 5, 0, 5)
    av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..data.userId.."&width=420&height=420&format=png"
    Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
    
    local content = Instance.new("TextLabel", bubble)
    content.Size = UDim2.new(0, 220, 0, 0)
    content.Position = UDim2.new(0, 45, 0, 5)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.RichText = true
    content.Text = "<b>"..data.displayName.."</b> <font color='#55AAFF'>@"..data.game.."</font>\n"..data.message
    content.TextColor3 = Color3.new(1,1,1)
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Pop Animation
    TweenService:Create(bubble, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {Size = UDim2.new(0.95, 0, 0, 45)}):Play()
    scrollingFrame.CanvasPosition = Vector2.new(0, scrollingFrame.AbsoluteCanvasSize.Y)
end

-- Toggle UI
minBtn.MouseButton1Click:Connect(function()
    mainFrame:TweenPosition(UDim2.new(1, 50, 0.5, -210), "In", "Quart", 0.5)
    task.wait(0.5)
    miniBar.Visible = true
    miniBar:TweenPosition(UDim2.new(0.98, -180, 0.9, 0), "Out", "Back", 0.5)
end)

miniBar.MouseButton1Click:Connect(function()
    miniBar:TweenPosition(UDim2.new(1, 10, 0.9, 0), "In", "Quart", 0.5)
    task.wait(0.5)
    mainFrame:TweenPosition(UDim2.new(0.98, -340, 0.5, -210), "Out", "Back", 0.5)
end)

-- Send Message
textBox.FocusLost:Connect(function(enter)
    if enter and textBox.Text ~= "" then
        local msg = textBox.Text
        textBox.Text = ""
        
        -- Local Echo (Smooth Feel)
        createBubble({userId = LocalPlayer.UserId, displayName = LocalPlayer.DisplayName, game = "You", message = msg})
        
        pcall(function()
            HttpService:PostAsync(SERVER_URL.."/send", HttpService:JSONEncode({
                username = LocalPlayer.Name,
                displayName = LocalPlayer.DisplayName,
                userId = LocalPlayer.UserId,
                message = msg,
                game = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
            }))
        end)
    end
end)

-- Intro
mainFrame:TweenPosition(UDim2.new(0.98, -340, 0.5, -210), "Out", "Back", 0.8)

-- Fetch Loop
local lastId = ""
task.spawn(function()
    while task.wait(UPDATE_INTERVAL) do
        local success, res = pcall(function() return HttpService:GetAsync(SERVER_URL.."/messages?user="..LocalPlayer.Name) end)
        if success then
            local data = HttpService:JSONDecode(res)
            for _, m in pairs(data.messages) do
                if m.username ~= LocalPlayer.Name then
                    createBubble(m)
                end
            end
        end
    end
end)
