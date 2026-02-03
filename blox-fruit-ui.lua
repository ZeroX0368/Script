--// ================= ANTI AFK =================
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--// ================= CONFIG =================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"
local AUTO_FARM = true
local AUTO_STAT = true
local FAST_ATTACK = true

--// ================= SERVICES =================
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--// ================= WEBHOOK =================
local function SendWebhook(title, desc)
    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            username = "Blox Fruits Auto Farm",
            embeds = {{
                title = title,
                description = desc,
                color = 5763719,
                timestamp = DateTime.now():ToIsoDate()
            }}
        })
    })
end

--// ================= AUTO STAT (MELEE) =================
task.spawn(function()
    while AUTO_STAT do
        pcall(function()
            RS.Remotes.CommF_:InvokeServer("AddPoint","Melee",1)
        end)
        task.wait(0.2)
    end
end)

--// ================= FAST ATTACK =================
task.spawn(function()
    while FAST_ATTACK do
        pcall(function()
            for _,v in pairs(LP.Character:GetChildren()) do
                if v:IsA("Tool") then
                    v:Activate()
                end
            end
        end)
        task.wait(0.08)
    end
end)

--// ================= QUEST DATA (FULL ALL SEA) =================
local QuestData = {
    -- SEA 1
    {Sea=1,Min=1,Max=9,Quest="BanditQuest1",NPC=CFrame.new(1060,16,1547),Mob="Bandit"},
    {Sea=1,Min=10,Max=29,Quest="MonkeyQuest",NPC=CFrame.new(-1601,36,153),Mob="Monkey"},
    {Sea=1,Min=30,Max=59,Quest="BuggyQuest1",NPC=CFrame.new(-1140,4,3828),Mob="Pirate"},

    -- SEA 2
    {Sea=2,Min=700,Max=724,Quest="Area1Quest",NPC=CFrame.new(-429,73,1836),Mob="Raider"},
    {Sea=2,Min=725,Max=774,Quest="Area2Quest",NPC=CFrame.new(638,73,918),Mob="Mercenary"},

    -- SEA 3
    {Sea=3,Min=1500,Max=1524,Quest="PiratePortQuest",NPC=CFrame.new(-290,43,5580),Mob="Pirate Millionaire"},
    {Sea=3,Min=1525,Max=1574,Quest="AmazonQuest",NPC=CFrame.new(5833,52,-1105),Mob="Dragon Crew Warrior"},
}

--// ================= GET SEA =================
local function GetSea()
    if game.PlaceId == 2753915549 then return 1 end
    if game.PlaceId == 4442272183 then return 2 end
    if game.PlaceId == 7449423635 then return 3 end
end

--// ================= GET QUEST =================
local function GetQuest()
    local lvl = LP.Data.Level.Value
    local sea = GetSea()
    for _,q in pairs(QuestData) do
        if q.Sea == sea and lvl >= q.Min and lvl <= q.Max then
            return q
        end
    end
end

--// ================= TAKE QUEST =================
local function TakeQuest(q)
    LP.Character.HumanoidRootPart.CFrame = q.NPC
    task.wait(1)

    RS.Remotes.CommF_:InvokeServer("StartQuest", q.Quest, 1)

    SendWebhook(
        "📜 Nhận Quest",
        "**Quest:** "..q.Quest..
        "\n**Mob:** "..q.Mob..
        "\n**Level:** "..LP.Data.Level.Value..
        "\n**Sea:** "..GetSea()
    )
end

--// ================= AUTO FARM =================
task.spawn(function()
    while AUTO_FARM do
        local q = GetQuest()
        if q then
            if not LP.PlayerGui.Main.Quest.Visible then
                TakeQuest(q)
            end

            for _,mob in pairs(workspace.Enemies:GetChildren()) do
                if mob.Name == q.Mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                    repeat
                        pcall(function()
                            LP.Character.HumanoidRootPart.CFrame =
                                mob.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                        end)
                        task.wait()
                    until mob.Humanoid.Health <= 0 or not AUTO_FARM
                end
            end
        end
        task.wait(0.5)
    end
end)
