-- ═══════════════════════════════════════════════════════════
--  💬 UNIVERSAL CROSS-GAME CHAT
--  Ultra Aesthetic • Mobile Optimized • Smooth Animations
--  Version 3.0 - COMPLETE & OPTIMIZED
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ⚙️ CONFIGURATION
local CONFIG = {
    SERVER_URL = "https://roblox-chat-server-z35g.onrender.com",
    UPDATE_INTERVAL = 2,
    MAX_MESSAGE_LENGTH = 500,
    ANIMATION_SPEED = 0.35,
    
    -- 🎨 AESTHETIC THEME (Modern Discord-inspired)
    COLORS = {
        Background = Color3.fromRGB(16, 16, 20),
        Surface = Color3.fromRGB(24, 24, 28),
        SurfaceLight = Color3.fromRGB(32, 32, 38),
        Accent = Color3.fromRGB(114, 137, 218),  -- Blurple
        AccentHover = Color3.fromRGB(134, 157, 238),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(240, 71, 71),
        Warning = Color3.fromRGB(250, 166, 26),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        TextMuted = Color3.fromRGB(130, 130, 140),
        Border = Color3.fromRGB(40, 40, 48),
        Shadow = Color3.fromRGB(0, 0, 0),
        OwnMessage = Color3.fromRGB(88, 101, 242),
        OtherMessage = Color3.fromRGB(32, 34, 37)
    }
}

-- HTTP REQUEST
local httpRequest = (syn and syn.request) or (http and http.request) or 
                    http_request or (fluxus and fluxus.request) or request

if not httpRequest then
    LocalPlayer:Kick("⚠️ Your executor doesn't support HTTP requests!")
    return
end

-- STATE
local State = {
    lastMessageTime = 0,
    isMinimized = false,
    unreadCount = 0,
    currentGame = "Unknown Game",
    isLoading = false,
    isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    onlineUsers = 0
}

-- Get game name
pcall(function()
    State.currentGame = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

-- ═══════════════════════════════════════════════════════════
--  🎨 GUI CREATION
-- ═══════════════════════════════════════════════════════════

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalChat_v3"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Container (Mobile optimized size)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = State.isMobile and UDim2.new(0.95, 0, 0.7, 0) or UDim2.new(0, 400, 0, 600)
mainFrame.Position = State.isMobile and UDim2.new(0.025, 0, 0.15, 0) or UDim2.new(1, -420, 0.5, -300)
mainFrame.BackgroundColor3 = CONFIG.COLORS.Background
mainFrame.BackgroundTransparency = 0.02
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Corner & Stroke
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, State.isMobile and 24 or 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.COLORS.Border
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.6
mainStroke.Parent = mainFrame

-- Gradient Overlay
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
})
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.96),
    NumberSequenceKeypoint.new(1, 0.98)
})
gradient.Rotation = 135
gradient.Parent = mainFrame

-- Glow Effect
local glow = Instance.new("ImageLabel")
glow.Name = "Glow"
glow.BackgroundTransparency = 1
glow.Position = UDim2.new(0, -30, 0, -30)
glow.Size = UDim2.new(1, 60, 1, 60)
glow.ZIndex = 0
glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
glow.ImageColor3 = CONFIG.COLORS.Accent
glow.ImageTransparency = 0.9
glow.Parent = mainFrame

-- Pulse animation for glow
spawn(function()
    while mainFrame.Parent do
        TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            ImageTransparency = 0.95
        }):Play()
        task.wait(2)
    end
end)

-- ═══════════════════════════════════════════════════════════
--  📱 MINIMIZED BAR
-- ═══════════════════════════════════════════════════════════

local miniBar = Instance.new("Frame")
miniBar.Name = "MiniBar"
miniBar.Size = State.isMobile and UDim2.new(0, 180, 0, 60) or UDim2.new(0, 240, 0, 60)
miniBar.Position = State.isMobile and UDim2.new(0.5, -90, 1, -80) or UDim2.new(1, -260, 1, -80)
miniBar.BackgroundColor3 = CONFIG.COLORS.Surface
miniBar.BorderSizePixel = 0
miniBar.Visible = false
miniBar.Active = true
miniBar.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 20)
miniCorner.Parent = miniBar

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = CONFIG.COLORS.Accent
miniStroke.Thickness = 2
miniStroke.Transparency = 0.4
miniStroke.Parent = miniBar

-- Mini icon with pulse
local miniIcon = Instance.new("TextLabel")
miniIcon.Size = UDim2.new(0, 50, 1, 0)
miniIcon.BackgroundTransparency = 1
miniIcon.Text = "💬"
miniIcon.TextSize = State.isMobile and 32 or 28
miniIcon.Font = Enum.Font.GothamBold
miniIcon.Parent = miniBar

-- Pulse mini icon
spawn(function()
    while miniBar.Parent do
        if miniBar.Visible then
            TweenService:Create(miniIcon, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
                TextSize = State.isMobile and 36 or 32
            }):Play()
            task.wait(1)
            TweenService:Create(miniIcon, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
                TextSize = State.isMobile and 32 or 28
            }):Play()
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

local miniLabel = Instance.new("TextLabel")
miniLabel.Size = UDim2.new(1, -110, 1, 0)
miniLabel.Position = UDim2.new(0, 55, 0, 0)
miniLabel.BackgroundTransparency = 1
miniLabel.Text = "Universal Chat"
miniLabel.TextColor3 = CONFIG.COLORS.TextPrimary
miniLabel.TextSize = State.isMobile and 16 or 15
miniLabel.Font = Enum.Font.GothamBold
miniLabel.TextXAlignment = Enum.TextXAlignment.Left
miniLabel.Parent = miniBar

-- Unread badge
local unreadBadge = Instance.new("Frame")
unreadBadge.Size = UDim2.new(0, 40, 0, 40)
unreadBadge.Position = UDim2.new(1, -50, 0.5, -20)
unreadBadge.BackgroundColor3 = CONFIG.COLORS.Danger
unreadBadge.BorderSizePixel = 0
unreadBadge.Visible = false
unreadBadge.Parent = miniBar

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(1, 0)
badgeCorner.Parent = unreadBadge

local unreadText = Instance.new("TextLabel")
unreadText.Size = UDim2.new(1, 0, 1, 0)
unreadText.BackgroundTransparency = 1
unreadText.Text = "0"
unreadText.TextColor3 = CONFIG.COLORS.TextPrimary
unreadText.TextSize = State.isMobile and 16 or 15
unreadText.Font = Enum.Font.GothamBold
unreadText.Parent = unreadBadge

local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.new(1, 0, 1, 0)
miniButton.BackgroundTransparency = 1
miniButton.Text = ""
miniButton.Parent = miniBar

-- ═══════════════════════════════════════════════════════════
--  📱 TITLE BAR
-- ═══════════════════════════════════════════════════════════

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, State.isMobile and 70 or 60)
titleBar.BackgroundColor3 = CONFIG.COLORS.Surface
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, State.isMobile and 24 or 20)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = CONFIG.COLORS.Surface
titleFix.BackgroundTransparency = 0.2
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- App Icon
local appIcon = Instance.new("TextLabel")
appIcon.Size = UDim2.new(0, 50, 0, 50)
appIcon.Position = UDim2.new(0, 15, 0.5, -25)
appIcon.BackgroundColor3 = CONFIG.COLORS.Accent
appIcon.Text = "💬"
appIcon.TextSize = 28
appIcon.Font = Enum.Font.GothamBold
appIcon.BorderSizePixel = 0
appIcon.Parent = titleBar

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 14)
iconCorner.Parent = appIcon

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -200, 1, 0)
titleLabel.Position = UDim2.new(0, 75, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Universal Chat"
titleLabel.TextColor3 = CONFIG.COLORS.TextPrimary
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = State.isMobile and 20 or 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -200, 0, 16)
subtitle.Position = UDim2.new(0, 75, 1, -20)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Cross-game messaging"
subtitle.TextColor3 = CONFIG.COLORS.TextMuted
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = titleBar

-- Online Badge
local statusBadge = Instance.new("Frame")
statusBadge.Size = State.isMobile and UDim2.new(0, 120, 0, 32) or UDim2.new(0, 110, 0, 28)
statusBadge.Position = UDim2.new(1, State.isMobile and -215 or -190, 0.5, -14)
statusBadge.BackgroundColor3 = CONFIG.COLORS.SurfaceLight
statusBadge.BorderSizePixel = 0
statusBadge.Parent = titleBar

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 14)
statusCorner.Parent = statusBadge

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 10, 0.5, -5)
statusDot.BackgroundColor3 = CONFIG.COLORS.Success
statusDot.BorderSizePixel = 0
statusDot.Parent = statusBadge

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

-- Pulse dot
spawn(function()
    while statusDot.Parent do
        TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, 9, 0.5, -6)
        }):Play()
        task.wait(1)
    end
end)

local onlineCounter = Instance.new("TextLabel")
onlineCounter.Size = UDim2.new(1, -25, 1, 0)
onlineCounter.Position = UDim2.new(0, 25, 0, 0)
onlineCounter.BackgroundTransparency = 1
onlineCounter.Text = "👥 0 online"
onlineCounter.TextColor3 = CONFIG.COLORS.TextSecondary
onlineCounter.Font = Enum.Font.GothamBold
onlineCounter.TextSize = State.isMobile and 13 or 11
onlineCounter.Parent = statusBadge

-- Control Buttons
local function createButton(icon, color, xOffset)
    local btn = Instance.new("TextButton")
    btn.Size = State.isMobile and UDim2.new(0, 44, 0, 44) or UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(1, xOffset, 0.5, State.isMobile and -22 or -18)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = icon
    btn.TextColor3 = CONFIG.COLORS.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = State.isMobile and 20 or 16
    btn.AutoButtonColor = false
    btn.Parent = titleBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, State.isMobile and 12 or 10)
    corner.Parent = btn
    
    -- Ripple effect on press
    btn.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.5
        ripple.BorderSizePixel = 0
        ripple.Parent = btn
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        TweenService:Create(ripple, TweenInfo.new(0.4), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.4)
        ripple:Destroy()
    end)
    
    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.new(
                math.min(color.R * 1.3, 1),
                math.min(color.G * 1.3, 1),
                math.min(color.B * 1.3, 1)
            ),
            Size = State.isMobile and UDim2.new(0, 48, 0, 48) or UDim2.new(0, 40, 0, 40)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color,
            Size = State.isMobile and UDim2.new(0, 44, 0, 44) or UDim2.new(0, 36, 0, 36)
        }):Play()
    end)
    
    return btn
end

local minimizeBtn = createButton("─", CONFIG.COLORS.SurfaceLight, State.isMobile and -95 or -85)
local closeBtn = createButton("✕", CONFIG.COLORS.Danger, State.isMobile and -45 or -42)

-- ═══════════════════════════════════════════════════════════
--  💬 CHAT AREA
-- ═══════════════════════════════════════════════════════════

local chatContainer = Instance.new("Frame")
chatContainer.Size = UDim2.new(1, 0, 1, State.isMobile and -160 or -150)
chatContainer.Position = UDim2.new(0, 0, 0, State.isMobile and 70 or 60)
chatContainer.BackgroundTransparency = 1
chatContainer.BorderSizePixel = 0
chatContainer.Parent = mainFrame

local chatFrame = Instance.new("ScrollingFrame")
chatFrame.Size = UDim2.new(1, -20, 1, -10)
chatFrame.Position = UDim2.new(0, 10, 0, 5)
chatFrame.BackgroundTransparency = 1
chatFrame.BorderSizePixel = 0
chatFrame.ScrollBarThickness = State.isMobile and 6 or 5
chatFrame.ScrollBarImageColor3 = CONFIG.COLORS.Accent
chatFrame.ScrollBarImageTransparency = 0.5
chatFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
chatFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
chatFrame.ScrollingDirection = Enum.ScrollingDirection.Y
chatFrame.Parent = chatContainer

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
chatLayout.Padding = UDim.new(0, State.isMobile and 14 or 12)
chatLayout.Parent = chatFrame

-- ═══════════════════════════════════════════════════════════
--  ⌨️ INPUT AREA
-- ═══════════════════════════════════════════════════════════

local inputContainer = Instance.new("Frame")
inputContainer.Size = UDim2.new(1, -20, 0, State.isMobile and 80 or 70)
inputContainer.Position = UDim2.new(0, 10, 1, State.isMobile and -90 or -80)
inputContainer.BackgroundColor3 = CONFIG.COLORS.Surface
inputContainer.BorderSizePixel = 0
inputContainer.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, State.isMobile and 20 or 16)
inputCorner.Parent = inputContainer

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = CONFIG.COLORS.Border
inputStroke.Thickness = 1.5
inputStroke.Transparency = 0.6
inputStroke.Parent = inputContainer

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, State.isMobile and -90 or -85, 1, -16)
textBox.Position = UDim2.new(0, 15, 0, 8)
textBox.BackgroundTransparency = 1
textBox.Text = ""
textBox.PlaceholderText = "Type your message..."
textBox.TextColor3 = CONFIG.COLORS.TextPrimary
textBox.PlaceholderColor3 = CONFIG.COLORS.TextMuted
textBox.Font = Enum.Font.Gotham
textBox.TextSize = State.isMobile and 16 or 14
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextWrapped = true
textBox.ClearTextOnFocus = false
textBox.Parent = inputContainer

-- Character counter
local charCounter = Instance.new("TextLabel")
charCounter.Size = UDim2.new(0, 60, 0, 16)
charCounter.Position = UDim2.new(1, -70, 1, -20)
charCounter.BackgroundTransparency = 1
charCounter.Text = "0/" .. CONFIG.MAX_MESSAGE_LENGTH
charCounter.TextColor3 = CONFIG.COLORS.TextMuted
charCounter.Font = Enum.Font.Gotham
charCounter.TextSize = 10
charCounter.TextXAlignment = Enum.TextXAlignment.Right
charCounter.Parent = inputContainer

-- Update character counter
textBox:GetPropertyChangedSignal("Text"):Connect(function()
    local len = #textBox.Text
    charCounter.Text = len .. "/" .. CONFIG.MAX_MESSAGE_LENGTH
    
    if len > CONFIG.MAX_MESSAGE_LENGTH then
        charCounter.TextColor3 = CONFIG.COLORS.Danger
        textBox.Text = textBox.Text:sub(1, CONFIG.MAX_MESSAGE_LENGTH)
    elseif len > CONFIG.MAX_MESSAGE_LENGTH * 0.9 then
        charCounter.TextColor3 = CONFIG.COLORS.Warning
    else
        charCounter.TextColor3 = CONFIG.COLORS.TextMuted
    end
end)

-- Send Button
local sendBtn = Instance.new("TextButton")
sendBtn.Size = State.isMobile and UDim2.new(0, 64, 0, 64) or UDim2.new(0, 60, 0, 56)
sendBtn.Position = UDim2.new(1, State.isMobile and -72 or -68, 0.5, State.isMobile and -32 or -28)
sendBtn.BackgroundColor3 = CONFIG.COLORS.Accent
sendBtn.BorderSizePixel = 0
sendBtn.Text = "➤"
sendBtn.TextColor3 = CONFIG.COLORS.TextPrimary
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextSize = State.isMobile and 24 or 22
sendBtn.AutoButtonColor = false
sendBtn.Parent = inputContainer

local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, State.isMobile and 18 or 14)
sendCorner.Parent = sendBtn

-- Send button animations
sendBtn.MouseEnter:Connect(function()
    TweenService:Create(sendBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        BackgroundColor3 = CONFIG.COLORS.AccentHover,
        Size = State.isMobile and UDim2.new(0, 68, 0, 68) or UDim2.new(0, 64, 0, 60),
        Rotation = 15
    }):Play()
end)

sendBtn.MouseLeave:Connect(function()
    TweenService:Create(sendBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
        BackgroundColor3 = CONFIG.COLORS.Accent,
        Size = State.isMobile and UDim2.new(0, 64, 0, 64) or UDim2.new(0, 60, 0, 56),
        Rotation = 0
    }):Play()
end)

-- Focus animations
textBox.Focused:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.3), {
        Color = CONFIG.COLORS.Accent,
        Transparency = 0.2,
        Thickness = 2
    }):Play()
    
    TweenService:Create(inputContainer, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(1, -20, 0, State.isMobile and 85 or 75)
    }):Play()
end)

textBox.FocusLost:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.3), {
        Color = CONFIG.COLORS.Border,
        Transparency = 0.6,
        Thickness = 1.5
    }):Play()
    
    TweenService:Create(inputContainer, TweenInfo.new(0.3), {
        Size = UDim2.new(1, -20, 0, State.isMobile and 80 or 70)
    }):Play()
end)

-- ═══════════════════════════════════════════════════════════
--  🎯 DRAGGING (Mobile & PC)
-- ═══════════════════════════════════════════════════════════

local dragging = false
local dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    
    TweenService:Create(mainFrame, TweenInfo.new(0.1), {
        Position = newPos
    }):Play()
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dra
