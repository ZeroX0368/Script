-- Blox Fruits: Auto Pick ALL Fruits + Auto Store + Auto Hop (SEA 1)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PLACE_ID = 2753915549 -- Sea 1

if game.PlaceId ~= PLACE_ID then
    player:Kick("Script chỉ hỗ trợ SEA 1")
    return
end

local visitedServers = {}

-- 🔍 Tìm TẤT CẢ fruit trong map
local function findAllFruits()
    local fruits = {}
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") and string.find(v.Name, "Fruit") then
            table.insert(fruits, v)
        end
    end
    return fruits
end

-- 👜 Auto store tất cả fruit trong Backpack
local function storeAllFruit()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if string.find(tool.Name, "Fruit") then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer(
                    "StoreFruit",
                    tool.Name
                )
                warn("📦 Đã cất:", tool.Name)
                task.wait(0.3)
            end)
        end
    end
end

-- 🍎 Nhặt 1 fruit
local function pickFruit(fruit)
    pcall(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        hrp.CFrame = fruit.Handle.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.3)

        firetouchinterest(hrp, fruit.Handle, 0)
        firetouchinterest(hrp, fruit.Handle, 1)

        task.wait(0.8)
        storeAllFruit()
    end)
end

-- 🔁 Hop server
local function hopServer()
    local servers = HttpService:JSONDecode(
        game:HttpGet(
            "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        )
    )

    for _, s in pairs(servers.data) do
        if s.playing < s.maxPlayers and not visitedServers[s.id] then
            visitedServers[s.id] = true
            TeleportService:TeleportToPlaceInstance(PLACE_ID, s.id, player)
            task.wait(6)
            return
        end
    end
end

-- ♻ MAIN LOOP
while task.wait(2) do
    local fruits = findAllFruits()

    if #fruits > 0 then
        warn("🍏 Tìm thấy", #fruits, "fruit – đang nhặt ALL")
        for _, fruit in pairs(fruits) do
            if fruit and fruit.Parent then
                pickFruit(fruit)
                task.wait(1)
            end
        end
    else
        warn("❌ Không còn fruit → hop server")
        hopServer()
    end
end
