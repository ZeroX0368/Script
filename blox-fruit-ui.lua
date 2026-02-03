--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--// HTTP REQUEST (đa executor)
local request = (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

--// CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"

local THUMBNAIL_URL = "https://cdn.discordapp.com/avatars/1142053791781355561/e599a27cab1ca92a444ed2839adbb4f9.webp?size=1024"
local IMAGE_URL = "https://cdn.discordapp.com/banners/1205613504808357888/a_fef2751c07efa7a14abe0e968bdac50f.gif?size=2048"

--// ANTI DUP (runtime)
local lastStockHash = nil

--// HASH STOCK (chống gửi trùng)
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

--// MAIN FUNCTION
local function sendToDiscord()
    local success, fruitData = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("CommF_")
            :InvokeServer("GetFruits")
    end)

    if not success or not fruitData then
        warn("❌ Không thể lấy dữ liệu Stock")
        return
    end

    -- 🔒 Check trùng stock
    local currentHash = getStockHash(fruitData)
    if currentHash == lastStockHash then
        warn("⚠️ Stock không đổi → Bỏ qua gửi Discord")
        return
    end
    lastStockHash = currentHash

    local stockList = ""
    local count = 0

    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count += 1
            stockList ..= "🍎 **" .. fruit.Name .. "** — `$" .. fruit.Price .. "`\n"
        end
    end

    if count == 0 then
        warn("⚠️ Không có trái nào đang bán")
        return
    end

    --// EMBED DATA
    local data = {
        embeds = {{
            title = "🛒 BLOX FRUITS STOCK NOTIFIER",
            description = "Danh sách các trái ác quỷ đang bán trong Shop hiện tại:",
            color = 65280,

            thumbnail = {
                url = THUMBNAIL_URL
            },

            image = {
                url = IMAGE_URL
            },

            fields = {
                {
                    name = "🍏 Danh sách Trái (" .. count .. " loại)",
                    value = stockList,
                    inline = false
                },
                {
                    name = "🖥 Server Info",
                    value = "JobId: `" .. game.JobId .. "`",
                    inline = false
                }
            },

            footer = {
                text = "Blox Fruits Stock Checker • " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }}
    }

    --// SEND WEBHOOK
    if not request then
        warn("❌ Executor không hỗ trợ HttpRequest")
        return
    end

    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(data)
    })

    print("✅ Đã gửi stock mới lên Discord")
end

--// RUN ONCE
sendToDiscord()
