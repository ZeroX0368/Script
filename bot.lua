--// SERVICES (Giữ nguyên)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--// CONFIG MỚI
-- Thay IP_CUA_BAN bằng địa chỉ IP hiển thị ở trang chủ bot-hosting.net
-- Thay PORT bằng port bạn lấy trong tab Network
local API_URL = "https://7e0c438b-fb11-459a-8938-ee79ebba11eb-00-2hk476ql4jd8f.sisko.replit.dev/fruit-update"
local AUTH_KEY = "SECRET_KEY_123" -- Phải khớp với bên Python

--// ... (Các hàm formatNumber và getStockHash giữ nguyên như cũ) ...

--// PHẦN GỬI REQUEST (Sửa lại trong hàm sendToDiscord)
    task.wait(1)
    local success, response = pcall(function()
        return requestFunc({
            Url = API_URL,
            Method = "POST",
            Headers = { 
                ["Content-Type"] = "application/json",
                ["Authorization"] = AUTH_KEY 
            },
            Body = HttpService:JSONEncode(data)
        })
    end)

    if success then
        print("✅ Đã truyền dữ liệu qua Bot Python thành công!")
    else
        warn("❌ Lỗi kết nối tới Bot Hosting: " .. tostring(response))
    end
end
