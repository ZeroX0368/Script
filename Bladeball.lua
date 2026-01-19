--====================================================
-- ZEROX | FULL MARU HUB STYLE (SEA 1-2-3)
--====================================================

--================ SERVICES =================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local CommF = ReplicatedStorage.Remotes.CommF_

local request =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

--================ CONFIG ===================
getgenv().CFG = {
    AutoFarm = false,
    AutoQuest = true,
    BringMob = true,
    AutoHaki = true,
    AutoStat = true,
    FarmBoss = false,
    AutoRaid = false,
    Weapon = "Melee",
    Webhook = "https://discord.com/api/webhooks/1370529951052468295/KYT9QTHy5rrsYAkwKpMKeeYO4Db5X9YkrT5qOrudk0SGcyIbXsHO4s1tLAPHQL77k0fK",
    StatPriority = {"Melee","Defense","DevilFruit"}
}

--================ ANTI AFK =================
LP.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

--================ SEA DETECT ==============
local function GetSea()
    if workspace.Map:FindFirstChild("Dressrosa") then return 2 end
    if workspace.Map:FindFirstChild("CastleOnTheSea") then return 3 end
    return 1
end

--================ QUEST DATA (FULL RÚT GỌN) ==========
local QuestData = {
    [1] = {
        {Min=1,Max=60,Quest="BanditQuest1",Mob="Bandit"},
        {Min=60,Max=150,Quest="DesertQuest",Mob="Desert Bandit"},
    },
    [2] = {
        {Min=700,Max=900,Quest="Area1Quest",Mob="Raider"},
        {Min=900,Max=1200,Quest="Area2Quest",Mob="Mercenary"},
    },
    [3] = {
        {Min=1500,Max=1800,Quest="PiratePortQuest",Mob="Pirate"},
        {Min=1800,Max=2450,Quest="HauntedQuest1",Mob="Reborn Skeleton"},
    }
}

local function GetQuest()
    local sea = GetSea()
    local lv = LP.Data.Level.Value
    for _,q in pairs(QuestData[sea]) do
        if lv >= q.Min and lv <= q.Max then
            return q
        end
    end
end

--================ AUTO QUEST ===============
task.spawn(function()
    while task.wait(1) do
        if CFG.AutoFarm and CFG.AutoQuest then
            if not LP.PlayerGui.Main.Quest.Visible then
                local q = GetQuest()
                if q then
                    CommF:InvokeServer("StartQuest",q.Quest,1)
                end
            end
        end
    end
end)

--================ AUTO HAKI =================
local function EnableHaki()
    if not LP.Character:FindFirstChild("HasBuso") then
        CommF:InvokeServer("Buso")
    end
end

--================ EQUIP ====================
local function Equip()
    for _,v in pairs(LP.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == CFG.Weapon then
            LP.Character.Humanoid:EquipTool(v)
            break
        end
    end
end

--================ BRING MOB ================
local function Bring(name)
    for _,m in pairs(workspace.Enemies:GetChildren()) do
        if m.Name == name and m:FindFirstChild("HumanoidRootPart") then
            m.HumanoidRootPart.CFrame =
                LP.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
            m.HumanoidRootPart.CanCollide = false
        end
    end
end

--================ AUTO FARM CORE ===========
task.spawn(function()
    while task.wait() do
        if CFG.AutoFarm then
            pcall(function()
                local q = GetQuest()
                if not q then return end
                if CFG.AutoHaki then EnableHaki() end
                Equip()

                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == q.Mob and mob.Humanoid.Health > 0 then
                        repeat
                            LP.Character.HumanoidRootPart.CFrame =
                                mob.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                            if CFG.BringMob then Bring(q.Mob) end
                            mob.Humanoid.Health = 0
                            task.wait(0.15)
                        until mob.Humanoid.Health <= 0 or not CFG.AutoFarm
                    end
                end
            end)
        end
    end
end)

--================ AUTO STAT ================
task.spawn(function()
    while task.wait(2) do
        if CFG.AutoStat and LP.Data.Points.Value > 0 then
            for _,s in pairs(CFG.StatPriority) do
                CommF:InvokeServer("AddPoint",s,1)
                task.wait(0.25)
            end
        end
    end
end)

--================ AUTO STOCK DISCORD =======
local lastHash = nil
task.spawn(function()
    while task.wait(300) do
        if request then
            local fruits = CommF:InvokeServer("GetFruits")
            local list = {}
            for _,f in pairs(fruits) do
                if f.OnSale then
                    table.insert(list,"🍎 "..f.Name.." - $"..f.Price)
                end
            end
            table.sort(list)
            local hash = table.concat(list,"|")
            if hash ~= lastHash then
                lastHash = hash
                request({
                    Url = CFG.Webhook,
                    Method = "POST",
                    Headers = {["Content-Type"]="application/json"},
                    Body = HttpService:JSONEncode({
                        embeds={{
                            title="🛒 BLOX FRUITS STOCK UPDATE",
                            description=table.concat(list,"\n"),
                            color=65280,
                            footer={text="JobId: "..game.JobId}
                        }}
                    })
                })
            end
        end
    end
end)

--================ UI (MARU STYLE) ==========
local UI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
))()

local Win = UI.CreateLib("ZeroX | Maru Hub FULL", "DarkTheme")
local Main = Win:NewTab("Main"):NewSection("Auto Farm")

Main:NewToggle("Auto Farm", "", function(v) CFG.AutoFarm = v end)
Main:NewToggle("Auto Quest", "", function(v) CFG.AutoQuest = v end)
Main:NewToggle("Bring Mob", "", function(v) CFG.BringMob = v end)
Main:NewToggle("Auto Stat", "", function(v) CFG.AutoStat = v end)

Main:NewDropdown("Weapon","",{"Melee","Sword","Fruit"},function(v)
    CFG.Weapon = v
end)
