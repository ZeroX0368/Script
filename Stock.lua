local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- CÀI ĐẶT TẠI ĐÂY
local url_webhook = "https://discord.com/api/webhooks/1370529951052468295/KYT9QTHy5rrsYAkwKpMKeeYO4Db5X9YkrT5qOrudk0SGcyIbXsHO4s1tLAPHQL77k0fK"

function sendToDiscord()
    -- Lấy dữ liệu trái ác quỷ từ Server
    local fruitData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("GetFruits")
    
    if not fruitData then 
        print("Không thể lấy dữ liệu Stock!")
        return 
    end

    local stockList = ""
    local count = 0

    -- Lọc các trái đang OnSale
    for _, fruit in pairs(fruitData) do
        if fruit.OnSale then
            count = count + 1
            stockList = stockList .. "🍎 **" .. fruit.Name .. "** - Giá: `$" .. fruit.Price .. "`\n"
        end
    end

    -- Tạo nội dung gửi đi (Embed)
    local data = {
        ["embeds"] = {{
            ["title"] = "🛒 BLOX FRUIT STOCK NOTIFIER",
            ["description"] = "Danh sách các trái ác quỷ đang bán trong Shop hiện tại:",
            ["color"] = 65280, -- Màu xanh lá
            ["fields"] = {
                {
                    ["name"] = "Danh sách Trái (" .. count .. " loại):",
                    ["value"] = stockList,
                    ["inline"] = false
                },
                {
                    ["name"] = "Server Info",
                    ["value"] = "JobId: `" .. game.JobId .. "`",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Blox Fruits Stock Checker • " .. os.date("%X")
            }
        }}
    }

    -- Gửi dữ liệu qua Webhook
    if request then
        request({
            Url = url_webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
        print("Đã gửi thông báo đến Discord!")
    else
        print("Trình thực thi của bạn không hỗ trợ HttpRequest!")
    end
end

-- Chạy script
sendToDiscord()
