-- OMEGA HUB V23 - Professional Loader
-- GitHub API + Private Repo + Token System

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ========== [CONFIGURATION - แก้ไขตามของคุณ] ==========
local CONFIG = {
    GITHUB_TOKEN = "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",  -- ใส่ Token ของคุณ
    REPO_OWNER = "yourusername",                         -- ชื่อ GitHub
    REPO_NAME = "omega-private",                         -- ชื่อ Private Repo
    CORE_FILE = "core.lua",
    KEYS_FILE = "keys.json",
}

local keyGUI = nil

-- ========== [GITHUB API FUNCTIONS] ==========
local function getFileFromRepo(filePath)
    local url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s",
        CONFIG.REPO_OWNER, CONFIG.REPO_NAME, filePath
    )
    
    local headers = {
        ["Authorization"] = "token " .. CONFIG.GITHUB_TOKEN,
        ["Accept"] = "application/vnd.github.v3.raw",
        ["User-Agent"] = "Omega-Loader/1.0"
    }
    
    local success, response = pcall(function()
        return HttpService:HttpGet(url, headers)
    end)
    
    return success and response or nil
end

-- ========== [KEY VALIDATION] ==========
local function validateKey(inputKey)
    local keysData = getFileFromRepo(CONFIG.KEYS_FILE)
    if not keysData then
        return false, "Cannot connect to server"
    end
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(keysData)
    end)
    
    if not success then
        return false, "Invalid data format"
    end
    
    for _, validKey in ipairs(data.keys or {}) do
        if validKey == inputKey then
            return true, "Key validated"
        end
    end
    
    return false, "Invalid license key"
end

-- ========== [KEY GUI] ==========
local function createKeyGUI()
    keyGUI = Instance.new("ScreenGui")
    keyGUI.Name = "OmegaKeyGUI"
    keyGUI.Parent = CoreGui
    
    local frame = Instance.new("Frame", keyGUI)
    frame.Size = UDim2.new(0, 400, 0, 250)
    frame.Position = UDim2.new(0.5, -200, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.Text = "Ω OMEGA HUB V23"
    title.TextColor3 = Color3.fromRGB(0, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.BackgroundTransparency = 1
    
    local subtitle = Instance.new("TextLabel", frame)
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 70)
    subtitle.Text = "Enter your license key"
    subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.BackgroundTransparency = 1
    
    local keyBox = Instance.new("TextBox", frame)
    keyBox.Size = UDim2.new(0.85, 0, 0, 45)
    keyBox.Position = UDim2.new(0.075, 0, 0, 100)
    keyBox.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
    keyBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 12
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
    
    local activateBtn = Instance.new("TextButton", frame)
    activateBtn.Size = UDim2.new(0.5, 0, 0, 42)
    activateBtn.Position = UDim2.new(0.25, 0, 0, 155)
    activateBtn.Text = "ACTIVATE"
    activateBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
    activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateBtn.Font = Enum.Font.GothamBold
    activateBtn.TextSize = 14
    Instance.new("UICorner", activateBtn).CornerRadius = UDim.new(0, 8)
    
    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 210)
    status.Text = "⚡ Waiting for key..."
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.BackgroundTransparency = 1
    
    activateBtn.MouseButton1Click:Connect(function()
        local inputKey = keyBox.Text
        if inputKey == "" then
            status.Text = "⚠️ Please enter a key!"
            status.TextColor3 = Color3.fromRGB(255, 200, 0)
            return
        end
        
        status.Text = "🔍 Contacting server..."
        status.TextColor3 = Color3.fromRGB(255, 200, 0)
        activateBtn.Enabled = false
        
        local isValid, msg = validateKey(inputKey)
        
        if isValid then
            status.Text = "✅ " .. msg
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
            task.wait(1)
            keyGUI:Destroy()
            loadCore()
        else
            status.Text = "❌ " .. msg
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            activateBtn.Enabled = true
        end
    end)
end

-- ========== [LOAD CORE] ==========
local function loadCore()
    local coreData = getFileFromRepo(CONFIG.CORE_FILE)
    if coreData then
        loadstring(coreData)()
    else
        local errGui = Instance.new("ScreenGui", CoreGui)
        local frame = Instance.new("Frame", errGui)
        frame.Size = UDim2.new(0, 300, 0, 60)
        frame.Position = UDim2.new(0.5, -150, 0.5, -30)
        frame.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = "❌ Failed to load OMEGA core!"
        label.TextColor3 = Color3.fromRGB(255, 100, 100)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.BackgroundTransparency = 1
        
        task.wait(3)
        errGui:Destroy()
    end
end

-- ========== [START] ==========
createKeyGUI()
