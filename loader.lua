-- OMEGA HUB V23 - GitHub API Loader
-- ผู้ใช้คัดลอกสคริปต์นี้ไปวางใน Executor

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ========== [CONFIGURATION - แก้ไขตรงนี้] ==========
local GITHUB_TOKEN = "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"  -- ใส่ Token ของคุณ
local REPO_OWNER = "codeinealon888-design"                         -- ชื่อ GitHub ของคุณ
local REPO_NAME = "omega-private"                        -- ชื่อ Private Repo
local KEYS_FILE = "keys.json"                            -- ไฟล์ที่เก็บคีย์
local CORE_FILE = "core.lua"                             -- ไฟล์โค้ดหลัก

local key = ""
local gui = nil

-- ========== [FUNCTION: ดึงไฟล์จาก Private Repo] ==========
local function getFileFromRepo(filePath)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s",
        REPO_OWNER, REPO_NAME, filePath
    )
    
    local headers = {
        ["Authorization"] = "token " .. GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw",
        ["User-Agent"] = "Omega-Loader/1.0"
    }
    
    local success, response = pcall(function()
        return HttpService:HttpGet(url, headers)
    end)
    
    if success then
        return response
    else
        warn("[Omega] Failed to fetch: " .. tostring(response))
        return nil
    end
end

-- ========== [FUNCTION: ตรวจสอบคีย์] ==========
local function validateKey(inputKey, statusLabel, guiToDestroy)
    statusLabel.Text = "🔍 Checking key..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local keysData = getFileFromRepo(KEYS_FILE)
    
    if not keysData then
        statusLabel.Text = "❌ Cannot connect to key server"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    local success, keysList = pcall(function()
        return HttpService:JSONDecode(keysData)
    end)
    
    if not success then
        statusLabel.Text = "❌ Invalid key data format"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    
    local isValid = false
    for _, validKey in ipairs(keysList) do
        if validKey == inputKey then
            isValid = true
            break
        end
    end
    
    if isValid then
        statusLabel.Text = "✅ Key valid! Loading OMEGA..."
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        task.wait(1)
        guiToDestroy:Destroy()
        loadCore()
    else
        statusLabel.Text = "❌ Invalid key! Please check and try again"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end

-- ========== [FUNCTION: โหลด Core Script] ==========
local function loadCore()
    local coreScript = getFileFromRepo(CORE_FILE)
    
    if not coreScript then
        local errorGui = Instance.new("ScreenGui", CoreGui)
        local errFrame = Instance.new("Frame", errorGui)
        errFrame.Size = UDim2.new(0, 350, 0, 100)
        errFrame.Position = UDim2.new(0.5, -175, 0.5, -50)
        errFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        Instance.new("UICorner", errFrame).CornerRadius = UDim.new(0, 8)
        
        local errText = Instance.new("TextLabel", errFrame)
        errText.Size = UDim2.new(1, 0, 1, 0)
        errText.Text = "❌ Failed to load OMEGA core!\nCheck your internet connection or contact support."
        errText.TextColor3 = Color3.fromRGB(255, 100, 100)
        errText.Font = Enum.Font.Gotham
        errText.TextSize = 12
        errText.BackgroundTransparency = 1
        
        task.wait(3)
        errorGui:Destroy()
        return
    end
    
    -- ส่งคีย์ไปให้ core (optional)
    getgenv().OMEGA_KEY = key
    
    -- Execute core script
    local success, err = pcall(function()
        loadstring(coreScript)()
    end)
    
    if not success then
        warn("[Omega] Core execution error: " .. tostring(err))
        local errGui = Instance.new("ScreenGui", CoreGui)
        local frame = Instance.new("Frame", errGui)
        frame.Size = UDim2.new(0, 300, 0, 60)
        frame.Position = UDim2.new(0.5, -150, 0.5, -30)
        frame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = "⚠️ Script error. Please report to developer."
        label.TextColor3 = Color3.fromRGB(255, 100, 100)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.BackgroundTransparency = 1
        
        task.wait(3)
        errGui:Destroy()
    end
end

-- ========== [FUNCTION: สร้าง GUI ขอคีย์] ==========
local function createKeyGUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "OmegaKeyGUI"
    gui.Parent = CoreGui
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 380, 0, 210)
    frame.Position = UDim2.new(0.5, -190, 0.5, -105)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    
    -- Logo / Title
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = "🔑 OMEGA HUB V23"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.BackgroundTransparency = 1
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel", frame)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 45)
    subtitle.Text = "Enter your license key to continue"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.BackgroundTransparency = 1
    
    -- Key input box
    local keyBox = Instance.new("TextBox", frame)
    keyBox.Size = UDim2.new(0.85, 0, 0, 40)
    keyBox.Position = UDim2.new(0.075, 0, 0, 75)
    keyBox.PlaceholderText = "XXXXX-XXXXX-XXXXX-XXXXX"
    keyBox.Text = ""
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 12
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)
    
    -- Activate button
    local activateBtn = Instance.new("TextButton", frame)
    activateBtn.Size = UDim2.new(0.45, 0, 0, 38)
    activateBtn.Position = UDim2.new(0.275, 0, 0, 125)
    activateBtn.Text = "ACTIVATE"
    activateBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.TextSize = 14
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 6)
    
    -- Status label
    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 175)
    status.Text = "⚡ Waiting for key..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.BackgroundTransparency = 1
    
    activateBtn.MouseButton1Click:Connect(function()
        key = keyBox.Text
        if key == "" then
            status.Text = "⚠️ Please enter a key!"
            status.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        validateKey(key, status, gui)
    end)
end

-- ========== [START] ==========
createKeyGUI()
