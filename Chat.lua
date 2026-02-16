local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ✅ CONFIGURATION
[span_0](start_span)local SERVER_URL = "https://roblox-chat-830h.onrender.com" --[span_0](end_span)
[span_1](start_span)local UPDATE_INTERVAL = 3 --[span_1](end_span)

-- ✅ UI ROOT
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "AestheticChat"
[span_2](start_span)screenGui.ResetOnSpawn = false --[span_2](end_span)

-- ✅ MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
[span_3](start_span)mainFrame.Size = UDim2.new(0, 320, 0, 420) --[span_3](end_span)
mainFrame.Position = UDim2.new(1, 50, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 15)

-- ✅ TITLE BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "GLOBAL CHAT"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

-- ✅ CHAT AREA (Fixed Error: Removed AutomaticCanvasSize)
local chatFrame = Instance.new("ScrollingFrame", mainFrame)
chatFrame.Size = UDim2.new(1, -20, 0.72, 0)
chatFrame.Position = UDim2.new(0, 10, 0, 55)
chatFrame.BackgroundTransparency = 1
[span_4](start_span)chatFrame.ScrollBarThickness = 2 --[span_4](end_span)
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local layout = Instance.new("UIListLayout", chatFrame)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Manual Canvas Resize (Fix for the Enum error)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    [span_5](start_span)chatFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) --[span_5](end_span)
end)

-- ✅ INPUT FIELD
local inputFrame = Instance.new("Frame", mainFrame)
inputFrame.Size = UDim2.new(0.9, 0, 0, 40)
inputFrame.Position = UDim2.new(0.05, 0, 0.9, 0)
inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

local textBox = Instance.new("TextBox", inputFrame)
textBox.Size = UDim2.new(1, -20, 1, 0)
textBox.Position = UDim2.new(0, 10, 0, 0)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "Type message..."
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.TextXAlignment = Enum.TextXAlignment.Left

-- ✅ FUNCTIONS
local function createBubble(data)
    local msgFrame = Instance.new("Frame", chatFrame)
    msgFrame.Size = UDim2.new(0.95, 0, 0, 50)
    msgFrame.BackgroundTransparency = 1
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y

    local bubble = Instance.new("Frame", msgFrame)
    bubble.Size = UDim2.new(1, 0, 1, 0)
    bubble.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 10)

    local content = Instance.new("TextLabel", bubble)
    content.Size = UDim2.new(1, -20, 1, -10)
    content.Position = UDim2.new(0, 10, 0, 5)
    content.BackgroundTransparency = 1
    content.RichText = true
    [span_6](start_span)content.Text = "<b>" .. data.username .. "</b>: " .. data.message --[span_6](end_span)
    content.TextColor3 = Color3.new(1, 1, 1)
    content.TextWrapped = true
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.AutomaticSize = Enum.AutomaticSize.Y

    -- Smooth Animation
    msgFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(msgFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0.95, 0, 0, 50)}):Play()
    [span_7](start_span)chatFrame.CanvasPosition = Vector2.new(0, 99999) --[span_7](end_span)
end

-- ✅ INITIALIZE
[span_8](start_span)mainFrame:TweenPosition(UDim2.new(1, -340, 0.5, -210), "Out", "Back", 0.6) --[span_8](end_span)

-- Send Logic
textBox.FocusLost:Connect(function(enter)
    if enter and textBox.Text ~= "" then
        local msg = textBox.Text
        textBox.Text = ""
        createBubble({username = LocalPlayer.Name, message = msg})
        
        pcall(function()
            HttpService:PostAsync(SERVER_URL.."/send", HttpService:JSONEncode({
                username = LocalPlayer.Name,
                message = msg,
                [span_9](start_span)game = "Mobile" --[span_9](end_span)
            }))
        end)
    end
end)

-[span_10](start_span)- Fetch Logic[span_10](end_span)
task.spawn(function()
    while task.wait(UPDATE_INTERVAL) do
        pcall(function()
            local res = HttpService:GetAsync(SERVER_URL.."/messages")
            local data = HttpService:JSONDecode(res)
            -- Add logic here to filter and display new messages
        end)
    end
end)
