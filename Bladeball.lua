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
    warn("❌ Executor không hỗ trợ HttpRequest")
    return
end

--// CONFIG
local WEBHOOK_URL = "YOUR_WEBHOOK_HERE"
local CHECK_INTERVAL = 10

local THUMBNAIL_URL = "https://cdn.discordapp.com/avatars/1142053791781355561/e599a27cab1ca92a444ed2839adbb4f9.webp"
local IMAGE_URL = "https://cdn.discordapp.com/banners/1205613504808357888/a_fef2751c07efa7a14abe0e968bdac50f.gif"

--// STATE
local lastStockString = ""
local wasEmpty = false

--// FORMAT NUMBER
local function formatNumber(n)
    local s = tostring(n)
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

--// GET CURRENT STOCK STRING
local function getStockString(stock)
    local list = {}
    for _, fruit in pairs(stock) do
        if fruit.OnSale then
            table.insert(list, fruit.Name .. ":" .. fruit.Price)
        end
    end
    table.sort(list)
    return table.concat(list, "|"), list
end

--// SEND DISCORD
local function sendWebhook(title, desc, stockList)
    local playerCount = #Players:GetPlayers()

    local data = {
        embeds = {{
            title = title,
            description = desc,
            color = 65280,
            thumbnail = { url = THUMBNAIL_URL },
            image = { url = IMAGE_URL },
            fields = {
                {
                    name = "🍏 Fruits đang bán",
                    value = stockList ~= "" and stockList or "❌ Shop trống",
                    inline = false
                },
                {
                    name = "🖥️ Server",
                    value = "👥 Players: `" .. playerCount .. "`\n🆔 JobId: `" .. game.JobId .. "`",
                    inline = false
                }
            },
            footer = {
                text = "Realtime Stock • " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }}
    }

    requestFunc({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

--// MAIN CHECK
local function checkStock()
    local ok, data = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("CommF_")
            :InvokeServer("GetFruits")
    end)

    if not ok or not data then return end

    local stockString, list = getStockString(data)
    local count = #list

    -- BUILD DISPLAY
    local display = ""
    for _, v in pairs(list) do
        local name, price = v:match("(.+):(.+)")
        display ..= "🍎 **" .. name .. "** — `$" .. formatNumber(price) .. "`\n"
    end

    -- RESET DETECT
    if wasEmpty and count > 0 then
        sendWebhook(
            "♻️ SHOP RESET DETECTED",
            "🔄 **Shop vừa reset và có fruit mới!**",
            display
        )
    end

    -- CHANGE DETECT
    if stockString ~= lastStockString then
        sendWebhook(
            "🛒 SHOP FRUIT CHANGED",
            "📦 **Danh sách fruit shop vừa thay đổi!**",
            display
        )
        lastStockString = stockString
    end

    wasEmpty = (count == 0)
end

--// LOOP
task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        checkStock()
    end
end)

--// FIRST RUN
checkStock()
