--// ================== SERVICES ==================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

--// ================== REQUEST ==================
local request =
    (syn and syn.request) or
    (http and http.request) or
    http_request or
    (fluxus and fluxus.request)

--// ================== CONFIG ==================
local WEBHOOK = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"
local AUTO_FARM = true
local AUTO_STAT = true
local CHECK_STOCK_DELAY = 10 -- giây

--// ================== UTIL ==================
local function SendWebhook(title, desc)
    if not request then return end
    local data = {
        embeds = {{
            title = title,
            description = desc,
            color = 0x00ff99,
            footer = { text = "Blox Fruits Auto Farm • "..os.date("%X") }
        }}
    }
    request({
        Url = WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode(data)
    })
end

--// ================== ANTI AFK ==================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

--// ================== EQUIP COMBAT ==================
local function EquipCombat()
    local tool = LP.Backpack:FindFirstChild("Combat")
    if tool then
        tool.Parent = Char
    end
end

--// ================== AUTO CLICK ==================
task.spawn(function()
    while task.wait(0.1) do
        if AUTO_FARM then
            VirtualUser:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            VirtualUser:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end
    end
end)

--// ================== FIND MOB ==================
local function GetMob()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end

--// ================== AUTO FARM ==================
task.spawn(function()
    while task.wait() do
        if not AUTO_FARM then continue end
        pcall(function()
            EquipCombat()
            local mob = GetMob()
            if mob and mob:FindFirstChild("HumanoidRootPart") then
                Char.HumanoidRootPart.CFrame =
                    mob.HumanoidRootPart.CFrame * CFrame.new(0,0,2)
            end
        end)
    end
end)

--// ================== AUTO STAT ==================
task.spawn(function()
    while task.wait(2) do
        if AUTO_STAT then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint","Melee",1)
        end
    end
end)

--// ================== LEVEL NOTIFIER ==================
local lastLevel = LP.Data.Level.Value
task.spawn(function()
    while task.wait(1) do
        local lv = LP.Data.Level.Value
        if lv > lastLevel then
            SendWebhook("⬆️ LÊN LEVEL",
                "**Level:** "..lv..
                "\n**Sea:** "..(LP.Data:FindFirstChild("World") and LP.Data.World.Value or "?")
            )
            lastLevel = lv
        end
    end
end)

--// ================== QUEST NOTIFIER ==================
local lastQuest = ""
task.spawn(function()
    while task.wait(0.5) do
        local gui = LP.PlayerGui:FindFirstChild("Main")
        if gui and gui:FindFirstChild("Quest") and gui.Quest.Visible then
            local title = gui.Quest.Container.QuestTitle.Title.Text
            if title ~= lastQuest then
                lastQuest = title
                SendWebhook("📜 NHẬN QUEST", title)
            end
        end
    end
end)

--// ================== STOCK FRUIT NOTIFIER ==================
local lastStockHash = ""
task.spawn(function()
    while task.wait(CHECK_STOCK_DELAY) do
        pcall(function()
            local fruits =
                ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
            if not fruits then return end

            local list = ""
            for _,f in pairs(fruits) do
                if f.OnSale then
                    list ..= "🍎 **"..f.Name.."** – $"..f.Price.."\n"
                end
            end

            local hash = HttpService:GenerateGUID(false)..list
            if hash ~= lastStockHash and list ~= "" then
                lastStockHash = hash
                SendWebhook("🛒 STOCK TRÁI ÁC QUỶ", list)
            end
        end)
    end
end)

SendWebhook("✅ SCRIPT STARTED","Auto Farm + Notifier đã chạy")
