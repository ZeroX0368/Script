-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- HTTP REQUEST (đa executor)
local request =
    (syn and syn.request)
    or (http and http.request)
    or http_request
    or (fluxus and fluxus.request)
    or request

-- ================== CONFIG ==================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1353511267889053767/AAHMBVG7vyD0SHEFK3pYf8sxsYS9_MEbQhINx_c1ASJbG_1fMrMlo8EvCaeGcF5wulcT"
local CHECK_DELAY = 60 -- số giây mỗi lần check (60 = 1 phút)
-- ============================================

local lastStockHash = ""

-- Hàm tạo hash để tránh gửi trùng
local function hashStock(tbl)
    local str = ""
    for _, v in pairs(tbl) do
        if v.OnSale then
            str ..= v.Name .. v.Price
        end
    end
    return HttpService:GenerateGUID(false) .. str
end

local function sendToDiscord()
    local success, fruitData = pcall(function()
        return ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("CommF_")
            :InvokeServer("GetFruits")
    end)

    if not success or not fruitData then
        warn("❌ Không lấy được dữ liệu Fruit Stock")
        return
    end

    local stockText = ""
    local count = 0

    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count += 1
            stockText ..= string.format(
                "🍎 **%s** — `$%s`\n",
                fruit.Name,
                fruit.Price
            )
        end
    end

    if count == 0 then
        print("⚠ Không có trái nào đang bán")
        return
    end

    local currentHash = hashStock(fruitData)
    if currentHash == lastStockHash then
        print("⏭ Stock không đổi, bỏ qua gửi Discord")
        return
    end
    lastStockHash = currentHash

    local payload = {
        embeds = {{
            title = "🛒 BLOX FRUITS STOCK UPDATE",
            description = "Danh sách trái ác quỷ đang bán:",
            color = 0x00ff66,
            fields = {
                {
                    name = "🍏 Fruits (" .. count .. ")",
                    value = stockText,
                    inline = false
                },
                {
                    name = "🌐 Server",
                    value = "`JobId: " .. game.JobId .. "`",
                    inline = false
                }
            },
            footer = {
                text = "Auto Stock Notifier • " .. os.date("%H:%M:%S")
            }
        }}
    }

    if request then
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
        print("✅ Đã gửi stock mới lên Discord")
    else
        warn("❌ Executor không hỗ trợ HttpRequest")
    end
end

-- LOOP AUTO CHECK
task.spawn(function()
    while task.wait(CHECK_DELAY) do
        sendToDiscord()
    end
end)
