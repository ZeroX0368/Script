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

--// FORMAT NUMBER
local function formatNumber(n)
    local s = tostring(n)
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

--// HASH STOCK
local function getStockHash(stockTable)
    local list = {}
    for _, fruit in pairs(stockTable) do
        if fruit.OnSale then
            table.insert(list, fruit.Name .. ":" .. fruit.Price)
        end
    end
    table.sort(list)
    return table.concat(list, "|")
end

--// MAIN
local function sendToDiscord()
    local success, fruitData = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("CommF_")
            :InvokeServer("GetFruits")
    end)

    if not success or not fruitData then
        warn("❌ Không thể lấy dữ liệu stock")
        return
    end

    -- COUNT
    local count = 0
    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count = count + 1
        end
    end

    -- HASH
    local currentHash = getStockHash(fruitData)

    -- DETECT RESET
    local isReset = false
    if lastStockHash ~= nil and currentHash ~= lastStockHash and count > 0 then
        isReset = true
        warn("♻️ RESET STOCK detected")
    end

    -- logic gửi notify:
    -- 1. Nếu là Reset (stock thay đổi và không trống) -> Gửi luôn
    -- 2. Nếu không phải Reset:
    --    - Kiểm tra hash cũ (tránh spam khi không đổi)
    --    - Kiểm tra cooldown 4h
    
    if not isReset then
        if currentHash == lastStockHash then
            warn("⚠️ Stock không đổi → bỏ qua")
            return
        end
        
        if os.time() - lastSendTime < SEND_COOLDOWN then
            warn("⏳ Chưa đủ 4h → không gửi")
            return
        end
    end

    if count == 0 then
        warn("⚠️ Shop đang trống")
        lastStockHash = currentHash
        return
    end

    lastStockHash = currentHash
    lastSendTime = os.time()

    -- BUILD LIST
    local stockList = ""
    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            stockList = stockList .. "🍎 **" .. fruit.Name ..
                "** — `$" .. formatNumber(fruit.Price) .. "`\n"
        end
    end

    -- SERVER INFO
    local playerCount = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers
    local jobId = game.JobId

    -- EMBED
    local data = {
        embeds = {{
            title = isReset
                and "♻️ BLOX FRUITS STOCK RESET"
                or "🛒 BLOX FRUITS STOCK UPDATE",

            description = isReset
                and "🔄 **Shop vừa mới Reset Stock!**"
                or "📦 **Danh sách trái đang bán hiện tại:**",

            color = isReset and 16753920 or 65280,

            thumbnail = { url = THUMBNAIL_URL },
            image = { url = IMAGE_URL },

            fields = {
                {
                    name = "🍏 Danh sách Trái (" .. count .. " loại)",
                    value = stockList,
                    inline = false
                },
                {
                    name = "🖥️ Server Info",
                    value =
                        "🆔 **JobId:** `" .. jobId .. "`\n" ..
                        "👥 **Players:** `" .. playerCount .. "/" .. maxPlayers .. "`",
                    inline = false
                }
            },

            footer = {
                text = "⚡ Stock Notifier • " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }}
    }

    task.wait(1)
    requestFunc({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })

    print("✅ Đã gửi stock lên Discord" .. (isReset and " (RESET MODE)" or ""))
end

--// LOOP
task.spawn(function()
    while true do
        sendToDiscord()
        task.wait(CHECK_INTERVAL)
    end
end)

--// FIRST RUN
sendToDiscord()
