--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

--// HTTP REQUEST
local requestFunc =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)

if not requestFunc then
    requestFunc = function(options)
        local success, result = pcall(function()
            return HttpService:PostAsync(options.Url, options.Body, Enum.HttpContentType.ApplicationJson)
        end)
        return { Success = success, Body = result }
    end
end

--// CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"

local THUMBNAIL_URL = "https://cdn.discordapp.com/avatars/1142053791781355561/e599a27cab1ca92a444ed2839adbb4f9.webp?size=1024"
local IMAGE_URL = "https://cdn.discordapp.com/banners/1205613504808357888/a_fef2751c07efa7a14abe0e968bdac50f.gif?size=2048"

local CHECK_INTERVAL = 60
local SEND_COOLDOWN = 4 * 60 * 60 -- 4 giờ

--// STATE
local lastStockHash = nil
local lastSendTime = 0
local lastResetTime = 0
local sentItems = {} -- Anti-duplicate cache

--// UTILS
local function getInventory()
    local success, inventory = pcall(function()
        return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("getInventory")
    end)
    return success and inventory or {}
end

local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    end)
    
    if success then
        for _, server in pairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
end

--// SCANNING LOGIC
local function scanServer()
    -- Legendary Sword Dealer
    local success, dealer = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "Check") end)
    if success and dealer and dealer ~= "Left" then 
        sendToDiscord("Sword", { name = tostring(dealer) }) 
    end
    
    -- Legendary Haki (Color Specialist)
    local success, haki = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ColorSpecialist", "Check") end)
    if success and haki then 
        sendToDiscord("Haki", { name = tostring(haki) }) 
    end
    
    -- Soul Reaper
    local success, bone = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check") end)
    if success and bone then 
        sendToDiscord("Boss", { name = "Soul Reaper" }) 
    end
    
    -- Mirage Island
    if game.Workspace:FindFirstChild("Mirage Island") then
        sendToDiscord("Mirage", { time = os.date("%X") })
    end
end

--// MAIN
local function sendToDiscord(type, data)
    local embed = {
        footer = { text = "Humzy Notify | " .. os.date("%d/%m/%Y %H:%M") },
        fields = {}
    }

    if type == "Sword" then
        embed.title = "Sword Legendary"
        embed.color = 0x800080 -- Purple
        table.insert(embed.fields, { name = "Swords Name :", value = data.name or "Unknown", inline = false })
    elseif type == "Haki" then
        embed.title = "Haki Legendary"
        embed.color = 0x483D8B -- DarkSlateBlue
        table.insert(embed.fields, { name = "Colors Name :", value = data.name or "Unknown", inline = false })
        table.insert(embed.fields, { name = "World :", value = tostring(data.world or "3"), inline = false })
    elseif type == "Boss" then
        embed.title = "Common Boss"
        embed.color = 0x008000 -- Green
        table.insert(embed.fields, { name = "Boss Name :", value = data.name or "Soul Reaper", inline = false })
    elseif type == "Mirage" then
        embed.title = "Mirage Island"
        embed.color = 0xFF8C00 -- DarkOrange
        table.insert(embed.fields, { name = "🏝️ Spawn :", value = "🟢", inline = false })
        table.insert(embed.fields, { name = "⚪ Time Of Day :", value = data.time or os.date("%X"), inline = false })
    elseif type == "Stock" then
        embed.title = "🛒 Current Stock"
        embed.color = 0x00FF00
        table.insert(embed.fields, { name = "🍏 Stock List", value = data.list or "No stock", inline = false })
    end

    table.insert(embed.fields, { name = "Players :", value = #Players:GetPlayers() .. "/" .. Players.MaxPlayers, inline = false })
    table.insert(embed.fields, { name = "Job-Id :", value = game.JobId, inline = false })
    table.insert(embed.fields, { 
        name = "Script :", 
        value = "```lua\ngame:GetService(\"ReplicatedStorage\").__ServerBrowser:InvokeServer(\"teleport\", \"" .. game.JobId .. "\")\n```", 
        inline = false 
    })

    requestFunc({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ embeds = { embed } })
    })
end

local function scanServer()
    -- Legendary Sword Dealer
    local success, dealer = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("LegendarySwordDealer", "Check") end)
    if success and dealer and dealer ~= "Left" then 
        sendToDiscord("Sword", { name = tostring(dealer) }) 
    end
    
    -- Legendary Haki (Color Specialist)
    local success, haki = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("ColorSpecialist", "Check") end)
    if success and haki then 
        sendToDiscord("Haki", { name = tostring(haki) }) 
    end
    
    -- Soul Reaper
    local success, bone = pcall(function() return game.ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check") end)
    if success and bone then 
        sendToDiscord("Boss", { name = "Soul Reaper" }) 
    end
    
    -- Mirage Island
    if game.Workspace:FindFirstChild("Mirage Island") then
        sendToDiscord("Mirage", { time = os.date("%X") })
    end

    -- Stock
    local fruitSuccess, fruitData = pcall(function()
        return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("GetFruits")
    end)
    if fruitSuccess and fruitData then
        local stockList = ""
        local currentHashList = {}
        for _, fruit in pairs(fruitData) do
            if fruit.OnSale then
                stockList = stockList .. "🍎 **" .. fruit.Name .. "** — `$" .. formatNumber(fruit.Price) .. "`\n"
                table.insert(currentHashList, fruit.Name)
            end
        end
        table.sort(currentHashList)
        local currentHash = table.concat(currentHashList, "|")
        
        if currentHash ~= lastStockHash then
            lastStockHash = currentHash
            sendToDiscord("Stock", { list = stockList })
        end
    end

    print("✅ Scan complete. Hopping...")
    task.wait(2)
    serverHop()
end

--// LOOP
task.spawn(function()
    while true do
        scanServer()
        task.wait(CHECK_INTERVAL)
    end
end)

--// FIRST RUN
scanServer()
