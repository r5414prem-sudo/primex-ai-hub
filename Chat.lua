local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ✅ CONFIG
[span_1](start_span)local SERVER_URL = "https://roblox-chat-830h.onrender.com"[span_1](end_span)
[span_2](start_span)local UPDATE_INTERVAL = 3[span_2](end_span)

-- ✅ UI ROOT
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "SimpleGlobalChat"
[span_3](start_span)screenGui.ResetOnSpawn = false[span_3](end_span)

-- ✅ MAIN FRAME (Draggable)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 350)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Active = true
[span_4](start_span)mainFrame.Draggable = true[span_4](end_span) -- This makes it movable for you

local uiCorner = Instance.new("UICorner", mainFrame)
uiCorner.CornerRadius = UDim.new(0, 10)

-- ✅ TITLE
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "GLOBAL CHAT"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold

-- ✅ CHAT AREA
local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 0.7, 0)
scrollingFrame.Position = UDim2.new(0, 10, 0, 35)
scrollingFrame.BackgroundTransparency = 0.9
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", scrollingFrame)
layout.Padding = UDim.new(0, 5)

-- Fixed resizing logic (No Enums to prevent crashes)
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

-- ✅ INPUT BOX
local textBox = Instance.new("TextBox", mainFrame)
textBox.Size = UDim2.new(0.9, 0, 0, 35)
textBox.Position = UDim2.new(0.05, 0, 0.85, 0)
textBox.PlaceholderText = "Click here to chat..."
textBox.Text = ""
textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
textBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", textBox)

-- ✅ FUNCTIONS
local function addMessage(user, msg)
    local label = Instance.new("TextLabel", scrollingFrame)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = " [" .. user .. "]: " .. msg
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.AutomaticSize = Enum.AutomaticSize.Y
    
    scrollingFrame.CanvasPosition = Vector2.new(0, 9999)
end

-- ✅ SEND LOGIC
textBox.FocusLost:Connect(function(enter)
    if enter and textBox.Text ~= "" then
        local content = textBox.Text
        textBox.Text = ""
        addMessage("You", content)
        
        pcall(function()
            HttpService:PostAsync(SERVER_URL .. "/send", HttpService:JSONEncode({
                username = LocalPlayer.Name,
                message = content,
                [span_5](start_span)game = "Mobile"[span_5](end_span)
            }))
        end)
    end
end)

-- ✅ FETCH LOOP
local lastCheck = ""
task.spawn(function()
    while task.wait(UPDATE_INTERVAL) do
        pcall(function()
            [span_6](start_span)local res = HttpService:GetAsync(SERVER_URL .. "/messages")[span_6](end_span)
            [span_7](start_span)local data = HttpService:JSONDecode(res)[span_7](end_span)
            for _, m in pairs(data.messages) do
                if m.username ~= LocalPlayer.Name then
                    addMessage(m.username, m.message)
                end
            end
        end)
    end
end)
