-- ============================================
-- PRIME HUB V2.0 - EXECUTOR READY SCRIPT
-- Properly wrapped for variable limit fix
-- Paste this directly into your executor
-- ============================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

if player.PlayerGui:FindFirstChild("PRIMEHubGUI") then 
    player.PlayerGui.PRIMEHubGUI:Destroy()
end

-- Global debug variable
_G.debugEnabled = true

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================
local function convertMoneyToNumber(moneyString)
    moneyString = tostring(moneyString):gsub("%$", ""):gsub(",", ""):gsub("%s", "")
    
    local multipliers = {
        K = 1000, M = 1000000, B = 1000000000,
        T = 1000000000000, Q = 1000000000000000,
        QQ = 1000000000000000000
    }
    
    local number = tonumber(moneyString:match("[%d%.]+"))
    local suffix = moneyString:match("[KMBTQ]+")
    
    if not number then return 0 end
    if suffix and multipliers[suffix] then
        return number * multipliers[suffix]
    end
    return number
end

-- ========================================
-- KEY SYSTEM
-- ========================================
do
    local KeySettings = {
        Title = "PRIME Hub",
        Subtitle = "Key System",
        Note = "Click 'Get Key' button to obtain the key",
        FileName = "PRIMEHub_Key",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/CD4DyVWc"}
    }

    local function getSavedKey()
        if readfile then
            local s, r = pcall(function()
                return readfile(KeySettings.FileName .. ".txt")
            end)
            if s and r then return r end
        end
        return nil
    end

    local function saveKeyToFile(key)
        if writefile then
            pcall(function()
                writefile(KeySettings.FileName .. ".txt", key)
            end)
        end
    end

    local function getKeyFromSite(url)
        local s, r = pcall(function()
            return game:HttpGet(url, true)
        end)
        if s and r then
            return r:gsub("%s+", ""):gsub("\n", ""):gsub("\r", "")
        end
        return nil
    end

    local savedKey = getSavedKey()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "PRIMEHubKeyGUI"
    KeyGui.ResetOnSpawn = false
    KeyGui.Parent = player:WaitForChild("PlayerGui")

    local KeyFrame = Instance.new("Frame")
    KeyFrame.Size = UDim2.new(0, 400, 0, 250)
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Parent = KeyGui
    Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)

    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Thickness = 2
    KeyStroke.Color = Color3.fromRGB(255, 0, 0)
    KeyStroke.Parent = KeyFrame

    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Size = UDim2.new(1, 0, 0, 50)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = KeySettings.Title .. " - " .. KeySettings.Subtitle
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
    KeyTitle.TextSize = 20
    KeyTitle.Parent = KeyFrame

    local KeyNote = Instance.new("TextLabel")
    KeyNote.Size = UDim2.new(1, -20, 0, 30)
    KeyNote.Position = UDim2.new(0, 10, 0, 50)
    KeyNote.BackgroundTransparency = 1
    KeyNote.Text = KeySettings.Note
    KeyNote.Font = Enum.Font.Gotham
    KeyNote.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeyNote.TextSize = 12
    KeyNote.TextWrapped = true
    KeyNote.Parent = KeyFrame

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0, 350, 0, 40)
    KeyBox.Position = UDim2.new(0.5, -175, 0, 90)
    KeyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    KeyBox.BorderSizePixel = 0
    KeyBox.PlaceholderText = "Enter Key Here..."
    KeyBox.Text = ""
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.TextSize = 16
    KeyBox.Parent = KeyFrame
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

    local KeyBoxStroke = Instance.new("UIStroke")
    KeyBoxStroke.Thickness = 1
    KeyBoxStroke.Color = Color3.fromRGB(255, 0, 0)
    KeyBoxStroke.Transparency = 0.5
    KeyBoxStroke.Parent = KeyBox

    KeyBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = KeyBox.Text
        local cleanText = text:gsub(" ", "")
        if text ~= cleanText then KeyBox.Text = cleanText end
    end)

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0, 350, 0, 40)
    GetKeyBtn.Position = UDim2.new(0.5, -175, 0, 145)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    GetKeyBtn.TextSize = 18
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Parent = KeyFrame
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)

    local GetKeyStroke = Instance.new("UIStroke")
    GetKeyStroke.Thickness = 1.5
    GetKeyStroke.Color = Color3.fromRGB(255, 0, 0)
    GetKeyStroke.Parent = GetKeyBtn

    local SubmitKeyBtn = Instance.new("TextButton")
    SubmitKeyBtn.Size = UDim2.new(0, 350, 0, 40)
    SubmitKeyBtn.Position = UDim2.new(0.5, -175, 0, 200)
    SubmitKeyBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SubmitKeyBtn.Text = "Submit Key"
    SubmitKeyBtn.Font = Enum.Font.GothamBold
    SubmitKeyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    SubmitKeyBtn.TextSize = 18
    SubmitKeyBtn.BorderSizePixel = 0
    SubmitKeyBtn.Parent = KeyFrame
    Instance.new("UICorner", SubmitKeyBtn).CornerRadius = UDim.new(0, 8)

    local SubmitKeyStroke = Instance.new("UIStroke")
    SubmitKeyStroke.Thickness = 1.5
    SubmitKeyStroke.Color = Color3.fromRGB(255, 0, 0)
    SubmitKeyStroke.Parent = SubmitKeyBtn

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://direct-link.net/1462308/RRaO8s6Woee8")
        end
        game.StarterGui:SetCore("SendNotification", {
            Title = "PRIME Hub",
            Text = "Key link copied to clipboard!",
            Duration = 5
        })
    end)

    local function verifyKey(inputKey)
        local cleanInput = inputKey:gsub("%s+", ""):gsub("\n", ""):gsub("\r", "")
        for _, keyValue in pairs(KeySettings.Key) do
            if KeySettings.GrabKeyFromSite then
                local siteKey = getKeyFromSite(keyValue)
                if siteKey and cleanInput == siteKey then return true end
            else
                local cleanKey = keyValue:gsub("%s+", ""):gsub("\n", ""):gsub("\r", "")
                if cleanInput == cleanKey then return true end
            end
        end
        return false
    end

    local keyVerified = false

    if KeySettings.SaveKey and savedKey and verifyKey(savedKey) then
        keyVerified = true
        KeyGui:Destroy()
    else
        SubmitKeyBtn.MouseButton1Click:Connect(function()
            SubmitKeyBtn.Text = "Checking..."
            SubmitKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
            wait(0.3)

            if verifyKey(KeyBox.Text) then
                keyVerified = true
                if KeySettings.SaveKey then
                    saveKeyToFile(KeyBox.Text:gsub("%s+", ""))
                end
                game.StarterGui:SetCore("SendNotification", {
                    Title = "PRIME Hub",
                    Text = "Key Verified! Loading...",
                    Duration = 3
                })
                wait(0.3)
                KeyGui:Destroy()
            else
                SubmitKeyBtn.Text = "Submit Key"
                SubmitKeyBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "PRIME Hub",
                    Text = "Invalid Key!",
                    Duration = 3
                })
            end
        end)

        repeat wait() until keyVerified
    end
end

-- ========================================
-- MAIN GUI CREATION
-- ========================================
game.StarterGui:SetCore("SendNotification", {
    Title = "PRIME Hub",
    Text = "✓ FULLY LOADED | By WENDIGO",
    Duration = 5
})

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PRIMEHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TopBarStroke = Instance.new("UIStroke")
TopBarStroke.Thickness = 1
TopBarStroke.Color = Color3.fromRGB(255, 0, 0)
TopBarStroke.Transparency = 0.6
TopBarStroke.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PRIME Hub"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 0)
MinimizeBtn.TextSize = 20
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local MinimizeStroke = Instance.new("UIStroke")
MinimizeStroke.Thickness = 1.5
MinimizeStroke.Color = Color3.fromRGB(255, 255, 0)
MinimizeStroke.Transparency = 0.3
MinimizeStroke.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 18
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 1.5
CloseStroke.Color = Color3.fromRGB(255, 50, 50)
CloseStroke.Transparency = 0.3
CloseStroke.Parent = CloseBtn

-- Draggable functionality
do
    local drag = {active = false, input = nil, start = nil, startPos = nil}
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag.active = true
            drag.start = input.Position
            drag.startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag.active = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag.input = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == drag.input and drag.active then
            local delta = input.Position - drag.start
            MainFrame.Position = UDim2.new(drag.startPos.X.Scale, drag.startPos.X.Offset + delta.X, drag.startPos.Y.Scale, drag.startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Left Section
local LeftSection = Instance.new("ScrollingFrame")
LeftSection.Size = UDim2.new(0, 150, 1, -50)
LeftSection.Position = UDim2.new(0, 5, 0, 45)
LeftSection.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LeftSection.BorderSizePixel = 0
LeftSection.ScrollBarThickness = 6
LeftSection.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
LeftSection.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftSection.Parent = MainFrame
Instance.new("UICorner", LeftSection).CornerRadius = UDim.new(0, 8)

local LeftStroke = Instance.new("UIStroke")
LeftStroke.Thickness = 1
LeftStroke.Color = Color3.fromRGB(255, 0, 0)
LeftStroke.Transparency = 0.6
LeftStroke.Parent = LeftSection

local LeftListLayout = Instance.new("UIListLayout")
LeftListLayout.Padding = UDim.new(0, 5)
LeftListLayout.Parent = LeftSection

-- Right Section
local RightSection = Instance.new("Frame")
RightSection.Size = UDim2.new(0, 330, 1, -50)
RightSection.Position = UDim2.new(0, 160, 0, 45)
RightSection.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
RightSection.BorderSizePixel = 0
RightSection.Visible = false
RightSection.Parent = MainFrame
Instance.new("UICorner", RightSection).CornerRadius = UDim.new(0, 8)

local RightStroke = Instance.new("UIStroke")
RightStroke.Thickness = 1
RightStroke.Color = Color3.fromRGB(255, 0, 0)
RightStroke.Transparency = 0.6
RightStroke.Parent = RightSection

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -10)
ContentFrame.Position = UDim2.new(0, 5, 0, 5)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.Parent = RightSection

local ContentListLayout = Instance.new("UIListLayout")
ContentListLayout.Padding = UDim.new(0, 10)
ContentListLayout.Parent = ContentFrame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "P"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextSize = 28
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 30)

local ToggleBtnStroke = Instance.new("UIStroke")
ToggleBtnStroke.Thickness = 2
ToggleBtnStroke.Color = Color3.fromRGB(255, 0, 0)
ToggleBtnStroke.Transparency = 0.3
ToggleBtnStroke.Parent = ToggleButton

-- Draggable Toggle Button
do
    local drag = {active = false, input = nil, start = nil, startPos = nil}
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag.active = true
            drag.start = input.Position
            drag.startPos = ToggleButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag.active = false
                end
            end)
        end
    end)
    
    ToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag.input = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == drag.input and drag.active then
            local delta = input.Position - drag.start
            ToggleButton.Position = UDim2.new(drag.startPos.X.Scale, drag.startPos.X.Offset + delta.X, drag.startPos.Y.Scale, drag.startPos.Y.Offset + delta.Y)
        end
    end)
end

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local isMinimized = false
local originalSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 500, 0, 40), "Out", "Quad", 0.3, true)
        wait(0.3)
        LeftSection.Visible = false
        RightSection.Visible = false
    else
        MainFrame:TweenSize(originalSize, "Out", "Quad", 0.3, true)
        wait(0.3)
        LeftSection.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Canvas size auto-update
LeftListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LeftSection.CanvasSize = UDim2.new(0, 0, 0, LeftListLayout.AbsoluteContentSize.Y + 10)
end)

ContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentListLayout.AbsoluteContentSize.Y + 10)
end)

local currentSection = nil

-- ========================================
-- MAIN FEATURES SECTION
-- ========================================
do
    local MainBtn = Instance.new("TextButton")
    MainBtn.Size = UDim2.new(1, -10, 0, 35)
    MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainBtn.Text = "Main"
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    MainBtn.TextSize = 16
    MainBtn.BorderSizePixel = 0
    MainBtn.Parent = LeftSection
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

    local MainBtnStroke = Instance.new("UIStroke")
    MainBtnStroke.Thickness = 1
    MainBtnStroke.Color = Color3.fromRGB(255, 0, 0)
    MainBtnStroke.Transparency = 0.5
    MainBtnStroke.Parent = MainBtn

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(1, -20, 0, 500)
    MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainContainer.BorderSizePixel = 0
    MainContainer.Visible = false
    MainContainer.Parent = ContentFrame
    Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 8)

    local MainContainerStroke = Instance.new("UIStroke")
    MainContainerStroke.Thickness = 1.5
    MainContainerStroke.Color = Color3.fromRGB(255, 0, 0)
    MainContainerStroke.Transparency = 0.4
    MainContainerStroke.Parent = MainContainer

    local MainContainerTitle = Instance.new("TextLabel")
    MainContainerTitle.Size = UDim2.new(1, -20, 0, 35)
    MainContainerTitle.Position = UDim2.new(0, 10, 0, 10)
    MainContainerTitle.BackgroundTransparency = 1
    MainContainerTitle.Text = "⚡ Main Features"
    MainContainerTitle.Font = Enum.Font.GothamBold
    MainContainerTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
    MainContainerTitle.TextSize = 20
    MainContainerTitle.Parent = MainContainer

    local MainFeatures = Instance.new("Frame")
    MainFeatures.Size = UDim2.new(1, -20, 0, 450)
    MainFeatures.Position = UDim2.new(0, 10, 0, 50)
    MainFeatures.BackgroundTransparency = 1
    MainFeatures.Parent = MainContainer

    local MainFeaturesLayout = Instance.new("UIListLayout")
    MainFeaturesLayout.Padding = UDim.new(0, 15)
    MainFeaturesLayout.Parent = MainFeatures
    
    MainFeaturesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local h = MainFeaturesLayout.AbsoluteContentSize.Y
        MainFeatures.Size = UDim2.new(1, -20, 0, h)
        MainContainer.Size = UDim2.new(1, -20, 0, h + 60)
    end)

    -- Add your features here (Aut
