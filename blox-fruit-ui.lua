--// ================== SERVICES ==================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Char, HRP

local function BindCharacter(c)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
end
BindCharacter(LP.Character or LP.CharacterAdded:Wait())
LP.CharacterAdded:Connect(BindCharacter)

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
local CHECK_STOCK_DELAY = 30 -- giây

--// ================== UTIL ==================
local function SendWebhook(title, desc)
    if not request then return end
    request({
        Url = WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            embeds = {{
                title = title,
                description = desc,
                color = 0x00ff99,
                footer = {
                    text = "Blox Fruits Auto Farm • "..os.date("%X")
                }
            }}
        })
    })
end

--// ================== ANTI AFK ==================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

--// ================== EQUIP ==================
local function EquipTool()
    local tool = LP.Backpack:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = Char
    end
end

--// ================== FIND MOB ==================
local function GetNearestMob()
    local nearest, dist = nil, math.huge
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        local hum = v:FindFirstChild("Humanoid")
        local hrp = v:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local d = (HRP.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                nearest = v
            end
        end
    end
    return nearest
end

--// ================== AUTO CLICK ==================
task.spawn(function()
    while task.wait(0.25) do
        if AUTO_FARM then
            VirtualUser:Button1Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            task.wait()
            VirtualUser:Button1Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end
    end
end)

--// ================== AUTO FARM ==================
task.spawn(function()
    while task.wait() do
        if not AUTO_FARM or not HRP then continue end
        pcall(function()
            EquipTool()
            local mob = GetNearestMob()
            if mob and mob:FindFirstChild("HumanoidRootPart") then
                local mhrp = mob.HumanoidRootPart
                mhrp.Anchored = true
                mhrp.CanCollide = false
                HRP.CFrame = mhrp.CFrame * CFrame.new(0, 5, 0)
            end
        end)
    end
end)

--// ================== AUTO STAT ==================
task.spawn(function()
    while task.wait(5) do
        if AUTO_STAT and LP.Data:FindFirstChild("Points") then
            local pts = LP.Data.Points.Value
            if pts > 0 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint","Melee",1)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint","Defense",1)
            end
        end
    end
end)

--// ================== LEVEL NOTIFIER ==================
local lastLevel = LP.Data.Level.Value
task.spawn(function()
    while task.wait(1) do
        local lv = LP.Data.Level.Value
        if lv > lastLevel then
            SendWebhook(
                "⬆️ LÊN LEVEL",
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

--// ================== STOCK FRUIT ==================
local lastStock = ""
task.spawn(function()
    while task.wait(CHECK_STOCK_DELAY) do
        pcall(function()
            local fruits = ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits")
            if not fruits then return end

            local list = ""
            for _,f in pairs(fruits) do
                if f.OnSale then
                    list ..= "🍎 "..f.Name.." $"..f.Price.."\n"
                end
            end

            if list ~= "" and list ~= lastStock then
                lastStock = list
                SendWebhook("🛒 STOCK TRÁI ÁC QUỶ", list)
            end
        end)
    end
end)

SendWebhook("✅ SCRIPT STARTED","Auto Farm + Notifier đã chạy")
