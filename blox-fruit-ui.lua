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
local CHECK_INTERVAL = 10 -- 10s

--// STATE (CHỈ để phát hiện reset, KHÔNG phải anti-dup)
local wasEmptyStock = false

--// FORMAT NUMBER
local function formatNumber(n)
    local s = tostring(n)
    return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

--// SEND STOCK
local function sendStock(fruitData, isReset)
    local stockList = ""
    local count = 0

    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count += 1
            stockList ..= "🍎 **" .. fruit.Name ..
                "** — 💰 `$" .. formatNumber(fruit.Price) .. "`\n"
        end
    end

    if count == 0 then return end

    local payload = {
        embeds = {{
            title = isReset
                and "♻️ BLOX FRUITS STOCK RESET"
                or "🛒 BLOX FRUITS STOCK",

            description = isReset
                and "🔄 **Shop vừa reset – stock mới nhất**"
                or "📦 **Shop hiện đang bán**",

            color = isReset and 16753920 or 65280,

            fields = {
                {
                    name = "🍏 Trái đang bán (" .. count .. ")",
                    value = stockList,
                    inline = false
                },
                {
                    name = "🖥️ Server Info",
                    value =
                        "🆔 JobId: `" .. game.JobId .. "`\n" ..
                        "👥 Players: `" .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "`",
                    inline = false
                }
            },

            footer = {
                text = os.date("%d/%m/%Y %H:%M:%S")
            }
        }}
    }

    requestFunc({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })

    print("✅ Sent stock | Reset:", isReset)
end

--// MAIN LOOP (RUN 1 LẦN – KHÔNG CẦN CHẠY LẠI)
task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        local ok, fruitData = pcall(function()
            return ReplicatedStorage
                :WaitForChild("Remotes")
                :WaitForChild("CommF_")
                :InvokeServer("GetFruits")
        end)

        if not ok or not fruitData then
            warn("❌ Không lấy được stock")
            continue
        end

        local sellingCount = 0
        for _, fruit in pairs(fruitData) do
            if fruit.OnSale then
                sellingCount += 1
            end
        end

        -- SHOP TRỐNG → CHỜ RESET
        if sellingCount == 0 then
            wasEmptyStock = true
            warn("⏳ Shop trống – đợi reset...")
            continue
        end

        -- SHOP CÓ LẠI SAU RESET
        if wasEmptyStock then
            sendStock(fruitData, true)
            wasEmptyStock = false
        else
            -- SHOP ĐANG BÁN (SEND LUÔN, KHÔNG SO SÁNH)
            sendStock(fruitData, false)
        end
    end
end)
