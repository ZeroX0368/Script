--// MARU HUB | FARM ALL BOSS + ESP
--// Made by ZeroX | Blox Fruits

repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()

-- VARS
local FarmBoss = false
local ESPFruit = false
local ESPPlayer = false
local BossStatus = "NONE"
local LastBossAttack = 0
local BossCooldown = 5 -- seconds (ANTI SPAM)

-- UI
local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "MaruHubBoss"

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromOffset(320,330)
Main.Position = UDim2.fromScale(0.05,0.32)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local function MakeBtn(text,y)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.fromOffset(280,38)
    b.Position = UDim2.fromOffset(20,y)
    b.Text = text.." : OFF"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "MARU HUB - BOSS & ESP"
Title.TextColor3 = Color3.fromRGB(255,80,80)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local BossBtn = MakeBtn("Farm All Boss",50)
local FruitBtn = MakeBtn("ESP Fruit",100)
local PlayerBtn = MakeBtn("ESP Player",150)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.fromOffset(280,40)
Status.Position = UDim2.fromOffset(20,200)
Status.BackgroundColor3 = Color3.fromRGB(25,25,25)
Status.TextColor3 = Color3.fromRGB(255,255,255)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 14
Status.Text = "Boss Status : NONE"
Instance.new("UICorner", Status).CornerRadius = UDim.new(0,8)

local function Toggle(btn,var)
    _G[var] = not _G[var]
    btn.Text = btn.Text:split(":")[1]..": "..(_G[var] and "ON" or "OFF")
    btn.BackgroundColor3 = _G[var] and Color3.fromRGB(255,80,80)
        or Color3.fromRGB(35,35,35)
end

BossBtn.MouseButton1Click:Connect(function() Toggle(BossBtn,"FarmBoss") end)
FruitBtn.MouseButton1Click:Connect(function() Toggle(FruitBtn,"ESPFruit") end)
PlayerBtn.MouseButton1Click:Connect(function() Toggle(PlayerBtn,"ESPPlayer") end)

-- GET ALL BOSS
local function GetBoss()
    for _,v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid")
        and v.Humanoid.Health > 0
        and v.Name:lower():find("boss") then
            return v
        end
    end
end

-- ESP FUNCTION
local function CreateESP(obj,color)
    if obj:FindFirstChild("ESP") then return end
    local box = Instance.new("BoxHandleAdornment", obj)
    box.Name = "ESP"
    box.Size = obj.Size
    box.Adornee = obj
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.5
    box.Color3 = color
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- FARM BOSS
    if FarmBoss then
        local boss = GetBoss()
        if boss and Char:FindFirstChild("HumanoidRootPart") then
            BossStatus = "ALIVE"
            Status.Text = "Boss Status : 🟢 ALIVE"

            if tick() - LastBossAttack > BossCooldown then
                LastBossAttack = tick()
                Char.HumanoidRootPart.CFrame =
                    boss.HumanoidRootPart.CFrame * CFrame.new(0,0,4)

                pcall(function()
                    RS.Remotes.CommF_:InvokeServer("Attack", boss)
                end)
            end
        else
            BossStatus = "RESPAWN"
            Status.Text = "Boss Status : 🔴 RESPAWN"
        end
    end

    -- ESP FRUIT
    for _,v in pairs(workspace:GetChildren()) do
        if ESPFruit and v:IsA("Tool") and v.Name:find("Fruit") then
            CreateESP(v.Handle, Color3.fromRGB(255,0,255))
        end
    end

    -- ESP PLAYER
    for _,plr in pairs(Players:GetPlayers()) do
        if ESPPlayer and plr ~= LP and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart") then
            CreateESP(plr.Character.HumanoidRootPart, Color3.fromRGB(0,255,255))
        end
    end
end)
