--// ================= SERVICES =================
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

local request =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

--// ================= CONFIG =================
local AUTO_FARM = true
local AUTO_STAT = true
local FAST_ATTACK = true

local WEBHOOK_URL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"
local STOCK_CHECK_INTERVAL = 60 -- giây

--// ================= ANTI AFK =================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--// ================= WEBHOOK =================
local function SendNotify(title, desc)
    if not request or WEBHOOK_URL == "" then return end
    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            username = "Blox Fruits Auto System",
            embeds = {{
                title = title,
                description = desc,
                color = 5793266,
                timestamp = DateTime.now():ToIsoDate()
            }}
        })
    })
end

--// ================= GET SEA =================
local function GetSea()
    if game.PlaceId == 2753915549 then return "Sea 1" end
    if game.PlaceId == 4442272183 then return "Sea 2" end
    if game.PlaceId == 7449423635 then return "Sea 3" end
    return "Unknown"
end

--// ================= AUTO STAT =================
task.spawn(function()
    while AUTO_STAT do
        pcall(function()
            RS.Remotes.CommF_:InvokeServer("AddPoint","Melee",1)
        end)
        task.wait(0.2)
    end
end)

--// ================= EQUIP MELEE =================
local function EquipMelee()
    local char = LP.Character
    local bp = LP.Backpack
    if not char or not bp then return end
    if char:FindFirstChildOfClass("Tool") then return end

    for _,tool in pairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            tool.Parent = char
            break
        end
    end
end

--// ================= FAST ATTACK =================
task.spawn(function()
    while FAST_ATTACK do
        pcall(function()
            EquipMelee()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local tool = char and char:FindFirstChildOfClass("Tool")

            if hum and tool and hum.Health > 0 then
                tool:Activate()
                VirtualUser:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end
        end)
        task.wait(0.045)
    end
end)

--// ================= QUEST DATA =================
local QuestData = {
    {Sea=1,Min=1,Max=9,Quest="BanditQuest1",NPC=CFrame.new(1060,16,1547),Mob="Bandit"},
    {Sea=1,Min=10,Max=29,Quest="MonkeyQuest",NPC=CFrame.new(-1601,36,153),Mob="Monkey"},
    {Sea=1,Min=30,Max=59,Quest="BuggyQuest1",NPC=CFrame.new(-1140,4,3828),Mob="Pirate"},

    {Sea=2,Min=700,Max=724,Quest="Area1Quest",NPC=CFrame.new(-429,73,1836),Mob="Raider"},
    {Sea=2,Min=725,Max=774,Quest="Area2Quest",NPC=CFrame.new(638,73,918),Mob="Mercenary"},

    {Sea=3,Min=1500,Max=1524,Quest="PiratePortQuest",NPC=CFrame.new(-290,43,5580),Mob="Pirate Millionaire"},
    {Sea=3,Min=1525,Max=1574,Quest="AmazonQuest",NPC=CFrame.new(5833,52,-1105),Mob="Dragon Crew Warrior"},
}

local function GetQuest()
    local lvl = LP.Data.Level.Value
    local sea = tonumber(GetSea():match("%d"))
    for _,q in pairs(QuestData) do
        if q.Sea == sea and lvl >= q.Min and lvl <= q.Max then
            return q
        end
    end
end

--// ================= QUEST + LEVEL NOTIFIER =================
local LastLevel = LP.Data.Level.Value
LP.Data.Level:GetPropertyChangedSignal("Value"):Connect(function()
    if LP.Data.Level.Value > LastLevel then
        SendNotify("⬆️ LEVEL UP",
            "Level: "..LastLevel.." ➜ "..LP.Data.Level.Value..
            "\nSea: "..GetSea()
        )
        LastLevel = LP.Data.Level.Value
    end
end)

local LastQuestName = nil
local LastProgress = ""

local function GetQuestGui()
    return LP.PlayerGui.Main:FindFirstChild("Quest")
end

task.spawn(function()
    while task.wait(0.5) do
        local qg = GetQuestGui()
        if not qg or not qg.Visible then
            if LastQuestName then
                SendNotify("✅ Hoàn Thành Quest", LastQuestName)
                LastQuestName = nil
                LastProgress = ""
            end
            continue
        end

        local title = qg.Container.QuestTitle.Title.Text
        local desc = qg.Container.QuestDesc.Desc.Text

        if title ~= LastQuestName then
            LastQuestName = title
            LastProgress = ""
            SendNotify("📜 Nhận Quest", title.."\n"..desc)
        end

        if desc ~= LastProgress then
            LastProgress = desc
            SendNotify("📊 Tiến Độ Quest", desc)
        end
    end
end)

--// ================= AUTO FARM =================
task.spawn(function()
    while AUTO_FARM do
        local q = GetQuest()
        if q and not LP.PlayerGui.Main.Quest.Visible then
            LP.Character.HumanoidRootPart.CFrame = q.NPC
            task.wait(1)
            RS.Remotes.CommF_:InvokeServer("StartQuest", q.Quest, 1)
        end

        for _,mob in pairs(workspace.Enemies:GetChildren()) do
            if q and mob.Name == q.Mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                repeat
                    LP.Character.HumanoidRootPart.CFrame =
                        mob.HumanoidRootPart.CFrame * CFrame.new(0,0,2.2)
                    task.wait()
                until mob.Humanoid.Health <= 0 or not AUTO_FARM
            end
        end
        task.wait(0.3)
    end
end)

--// ================= SHOP STOCK FRUIT NOTIFIER =================
local LastStockHash = ""

local function GetFruitStock()
    local ok, data = pcall(function()
        return RS.Remotes.CommF_:InvokeServer("GetFruits")
    end)
    if not ok or not data then return end

    local list = {}
    for _,f in pairs(data) do
        if f.OnSale then
            table.insert(list, f.Name..":"..f.Price)
        end
    end
    table.sort(list)
    return list
end

task.spawn(function()
    while task.wait(STOCK_CHECK_INTERVAL) do
        local stock = GetFruitStock()
        if stock then
            local hash = table.concat(stock)
            if hash ~= LastStockHash then
                LastStockHash = hash
                SendNotify(
                    "🛒 SHOP FRUIT STOCK",
                    table.concat(stock, "\n")..
                    "\n\nSea: "..GetSea()..
                    "\nJobId: "..game.JobId
                )
            end
        end
    end
end)

print("✅ FULL AUTO FARM + NOTIFIER + STOCK READY")
